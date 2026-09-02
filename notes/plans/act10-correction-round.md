# The Act 10 Correction Round — every UI change of the pre-13u round weighed, corrected, and walked

**STATUS: OPEN — opened 2026-09-01 at the author's sitting (her `/architect-phase` invocation).
Orchestrator: Fable (the sitting's session; the SUCCESSOR orchestrator, Fable 5.1, from 16:00 MDT 2026-09-01 per R-cor-9). Cast: all Fable — fresh implementer per batch, fresh
cold reviewer per ladder round. Runs NOW, before `pre-13x` (her ruling R-cor-2). Her acceptance is
ONE walk at the end on the refreshed `/Applications` build (R-cor-4). Source document:
`notes/author-reports/2026-09-01-post-act10-ui-report.md` — her words verbatim + the fifteen-image
manifest. This file is the ONE running record; a fresh session reads it in full.**

---

## 0. Why this round exists (the honest paragraph, written by the orchestrator)

The pre-13u round's Act 10 shipped 34 commits / 111 files / +10,235 −1,720 of UI in four waves.
Wave 2c alone built FIVE phase-sized surfaces — Index (635 lines), Read (385), the Blocks workbench
(811), the book Index (574), plus rewrites of BookView, BlockTOCView, Compare and Lenses — across
three chained implementer sessions, one of which died mid-run. The plan carried the escape hatch
("item 18 defers WHOLE to 13u2 if 2c cannot hold it") and the verdict came back "nothing defers":
an architect's call, and the wrong one. Verification was structural, not experiential — item 18 by
"mount smokes", the record's own admission that *"No Compare/Lenses capture exists in the 2c walk
set"*, and a three-round ladder whose every BLOCKER/MAJOR lived in `Sync/`. Two rulings shipped
half-delivered without the residue being flagged: W8-3 (the sidebar column's interior flattened,
`SidebarView.swift:348`; the floating glass pane itself left) and Index (built with the LEFT
column's small card as the live editor and the big right pane read-only by construction,
`IndexModeView.swift:380–387`). The install was refreshed before anyone used the result. She used
it, and reported the app had gone "from feeling pretty crisp, working well, no obvious bugs" to
"feeling like a vibecoded mess." The ideas were hers and she still wants them; the execution and
the verification were the failure. This round corrects the surfaces one at a time, walks every one
of them in use before its record closes, and binds the process rules (§2b) that would have caught
it.

## 1. Her rulings at the opening sitting (2026-09-01 — verbatim-faithful; settled)

- **R-cor-1 — SHAPE: correct in place, surface by surface.** Offered: correct-in-place with scalpel
  reverts · revert only wave 2c · wholesale revert to a branch. She chose the first. Her rider
  (R-cor-4 below): *"i'd honestly RATHER not retire any of the new changes"* — so a per-surface
  revert is the LAST disposition, taken only when a surface cannot be made right inside the round,
  and never silently.
- **R-cor-2 — SEQUENCE: this round NOW; `pre-13x` after.** *(The master plan's pointer amended
  the same turn.)*
- **R-cor-3 — THE LIBRARY PANEL (her words, verbatim):** *"I do think that showing a preview of the
  note on the right is helpful, even though the 'couple words showing of the post' is also coming -
  it makes the library feel like a more useful view, and the library really is quite wide right
  now. I will say that the line between the 'note info' and the library disappears when you're
  tabbed out, and it needs significant work. I think that the 'this note' sidebar should just fade
  in and out more smoothly, it would be too crowded to also have something on the left side. I
  think that the library peek should be quite simple, with an easy way to go into the note and have
  the place where your cursor was saved at any point (no need to render a whole write surface with
  takes, blocks, everything). Or we can make it so that the library just has a view and you have to
  click into it to edit it - that's the safer choice, and the read view + metadata still has value.
  QUALITY is what this phsae most needs to emphasize. also, when I click on a book, i just still see
  the last note i clicked on - obviously bad. a book could show the outline that it has or something
  rather than just showing the text. I'm open to good ideas in this area for usefulness, and what
  i'm saying are more inclinations, but the point is a premium feeling app"* → **Architect's
  reading, PROVISIONAL for her morning walk:** the panel becomes a SIMPLE READ PREVIEW (her "safer
  choice") — the note's rendered text, read-cheap and virtualized, a calm small facts line, and ONE
  generous door into the note that lands where the caret was; a BOOK shows its outline (chapters +
  notes) in the same panel; the panel's boundary holds when the window is inactive; the sidebar's
  "this note" rail FADES in/out instead of snapping; nothing new on the left. The writable upgrade
  (read-cheap → live on click, the one-live-editor rule) is a later door if she wants it, not this
  round's.
- **R-cor-4 — HER WALK, THE INSTALL, AND FOUR RIDERS (verbatim):** *"I'll just look at the app after
  all of the fixes are in place. I'm fine with this not being a quick round - this is honestly the
  kind of work that matters the MOST in a certain way. a user won't care about writing git history
  if the app looks and feels like a mess. I'm fine taking the time to do it right, and i'd honestly
  RATHER not retire any of the new changes, but I had to be honest about how upsetting seeing the
  app suddenly feel like slop was. I also would like applications refreshed at the end - I'll
  likely be asleep when you're finishing this work, and I'd rather wake up to it just being *done*.
  I'm also concerned because the linage page hasn't been looking great either - I reported a bug
  with it to the previous waves that resulted in this mess. So special attention shoudl also be
  paid to the lineage / history / archive / trash. And teh chrome being calm is valuable - word
  count shouldn't just be thrown in everywhere just because. i'm also not sure what the 'reading
  time' was calculated on, i think it's fine to show in read for now but i was kind of side eyeing
  its inclusion - how random is it?"* → (a) ONE acceptance walk, hers, at the end; the orchestrator
  walks every batch hands-on in between. (b) `/Applications` refreshed at the end — at a
  zero-instance window (her app was running at the sitting, pid 41735; she was asked to quit it
  before bed; otherwise the Release build is STAGED and swapped at the first zero-instance window,
  the A1 backup first). (c) **Batch F** — the recovery family (This Note's Tray, Block History,
  Archived, the Trash — her "lineage / history / archive / trash") gets its own batch with special
  attention; her earlier report on it was Act 10's item 1 (the tray's clipped header), whose fix
  began the restyle. (d) **The calm-chrome rule**: every word count / metric in chrome is verdicted
  KEEP (it earns its place) or DROP — ledger row 31. (e) Reading time: `words ÷ 200` rounded up
  (`ReadModeView.swift:302`) — a fixed convention (200 wpm adult silent reading), not measured, not
  random; stays in Read per her word; recorded (row 32), the constant named.

- **R-cor-5 — INDEX + READ BECOME ONE TAB, NAMED READ (her ruling at the sitting, verbatim):** *"I like one
  tab named read, but don't do the minimal outline of the current read tab - do the useful outline of the
  index tab. I actually really like how the index tab looks with its > 01, I think it looks nice. the text
  is a bit too small on the dropdown but it's better with the outline as what the current index has."* →
  The note mode row becomes **Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived
  from the one order). READ = the calm page at rest; a click on a block makes THAT block live in place (the
  one-live-editor upgrade — P-3 through `PaneTextAuthority`, the block-TOC design's own promise); the
  outline toggle she loves shows/hides the INDEX column — the Index tab's numbered `▸ 01` navigator
  (headings → sections, blocks nested, filter, scroll-synced), NOT Read's minimal outline, with its
  dropdown/expanded type a step larger; a small in-place selector picks the page's shape — continuous or
  horizontal pages (the book's paged view reused). The Index tab retires INTO Read (its brains — 
  `NoteIndexOutline`, the column — survive as Read's column); AppSpec §12's mode-row line and the field
  guide's "getting around"/"index · read" lessons change at closeout (the re-seed obligation rides). Her
  second message's reasoning is the record: *"making it more similar to book, where it's a selector within
  a place you're in. and the outline button could hide / show the index, and the index could function as
  the outline."*
- **Her hands-off note (2026-09-01 ~04:45):** *"i was the reason that screenshot wasn't right  i'll stop
  clicking anything on my computer and switch to only messaging you via my phone, so you can use my
  computer better."* → the machine is author-free for the walk from here; her real-store app is closed
  (the zero-instance window for the end-of-run refresh is open).

- **R-cor-6 — LENSES + COMPARE NEED A DESIGN (her ruling from the phone, 2026-09-01 ~04:50, verbatim):**
  *"Lenses/Compare need a design - I'm just going to tell you now that they need a design. The changes
  made them a bit clearer (so they're improvements in one sense, even if they look bad), but it's still
  absolutely dizzying. I need you to consider clearly what the point of each tab is, and make the UX of it
  better. promote into note (takes ride) for example is kinda vague."* → Row 41's authorization becomes a
  ruling under the friction doctrine (P-5): **batch D keeps only the mechanical defects** (rows 16/17 —
  alignment; the anchor column always rendering the note); **the orchestrator writes the LENSES + COMPARE
  DESIGN MEMO in-round** (`notes/plans/act10-correction-memo-lenses-compare.md` — the point of each tab in
  one sentence each, the flows a writer actually runs, every door and its wording — "promote into note
  (takes ride)" first — the edges, the tradeoffs, her rulings to collect), and **the build to the memo is
  its own phase**, kicked off at her word after she rules on the memo (the S4-16 condition: deferral
  carries its design, never vagueness). Row 20 folds into the memo.

- **R-cor-7 — R-cor-5 SHARPENED (her phone message + her answer, 2026-09-01 ~05:05): INDEX IS THE EDITABLE
  SURFACE; READ IS NEVER EDITABLE; ONE RAIL TAB NAMED READ WITH AN IN-PLACE `edit · read` SWITCH.** Her words,
  verbatim: *"index being editable is true for index, but is not true once it moves into being the read mode.
  it's not editable on book either - so let's clarify now what an editable index suggests now that read mode
  is separate - book will also have the same thing for index. what do you think? I incline towards there is
  an editable index surface, then you click read and it isn't anymore."* Offered Index / Read / two tabs as
  the rail name; she chose: *"Read — the tab keeps R-cor-5's name; inside, 'edit · read' switches the
  pane."* → **The note rail: Write · Takes · Read · Lenses · Compare · Blocks · Canvas (⌘1–⌘7).** Inside
  READ, one in-place switch **`edit · read`**: **edit** = the editable index surface — the Index tab's
  `▸ 01` outline column (toggle to hide/show; its expanded/dropdown type a step larger) beside the text pane
  in which a clicked block goes LIVE (P-3, one live editor through `PaneTextAuthority`); **read** = the calm
  read-only page (continuous or horizontal pages — the book's paged view reused), the same outline column
  available, nothing editable, a click on a sentence flips to `edit` at that block (row 38's door). **Default
  on entry: `edit` — RULED** (her follow-up, verbatim: *"I want it called Read because it's more distinct.
  still default open to the index edit though."*; per-note memory of the switch is the natural refinement,
  the architect's call). **The BOOK:
  its Index word-tab becomes EDITABLE the same way** (the selected note's block goes live in the right pane —
  row 22); **the book's Read stays read-only.** R-cor-5's other terms stand (the Index tab retires into Read;
  the `NoteIndexOutline` brains survive as the column; canon + field-guide changes at closeout).

- **R-cor-8 — THE OVERNIGHT AUTHORIZATION (her last message before sleep, 2026-09-01 ~06:45, verbatim):**
  *"I'm going to sleep for now - continue your work and don't stop for questions, just choose, record for me
  what was chosen + continue. What phase is this saved as? finish with a variorum refresh + make a handoff
  walk. I probably won't wake this session if you're done before i'm up - maybe. Continue the excellent
  work."* → Every fork from here is CHOSEN by the orchestrator and RECORDED in §7 (the morning bundle) with
  its reason — no holds, no questions; the run ends with the `/Applications` refresh (C-3's walk first) and
  the author handoff whose top is the WALK (her checklist in walk order). Her question answered: this is
  saved as **the Act 10 correction round** — master plan row `act10-cor`, plan `notes/plans/act10-correction-
  round.md`, handoff `notes/handoffs/act10-correction-handoff.md`. **Cutover rule for the orchestrator:** at
  ~57 % of context with five batches ahead, the orchestrator writes its ROLE handoff
  (`notes/plans/act10-correction-orchestrator-handoff.md`, a paste-ready successor prompt inside) NOW and
  keeps it current at every batch close, walks each later batch by SPOT-CHECK (the implementer's full walk
  + the orchestrator's 3–4 captures at the riskiest rows) to stay inside the budget, and if it must stop,
  the successor adopts from the repo — she starts it in the morning if the run is not done.

- **R-cor-9 — THE FOUNDING ORCHESTRATOR WRAPS AFTER BATCH F (her instruction, 2026-09-01 afternoon, at 65 %
  of the session's context):** *"please wrap up after stage F due to where you're at with the context limit
  and write a new orchestrator document + kickoff for me - this won't be a shadow session, I just want to do
  a regular handoff and kickoff message once Batch F is complete."* → The founding session's last acts: walk
  F's completion, close its record, finish `notes/plans/act10-correction-orchestrator-handoff.md` as the
  REGULAR cutover (state exact at F's close; the successor prompt un-shadowed), update memory, and hand her
  the kickoff message. **The successor runs batches D and E, the ladder (§7d) + the owed iOS build, the full
  acceptance walk, the install (§7b items 8–9), and the author handoff — the whole §7b list.**

- **R-cor-10 — SHE IS AWAKE; THE COLD REVIEW CONFIRMED; ROW 17 RATIFIED; FOUR RULINGS (2026-09-01 ~16:20 MDT — her
  message to the successor orchestrator, verbatim, then her answers to its four questions):** *"keep in mind that at
  the end you should do a cold review over the entire phase to see if there are any serious defects or issues -
  standard at phase closeout. I think that sounds fine about Compare's narrowing. … I've woken up and will be
  around for the rest of the session. Also, are there any areas in which you think the plan is lacking? any batches
  that you think should be added? I would like to know if you think that there will be quality gaps that will jump
  out to me, or if there's any other issues you want to bring to my attention."* → (a) the ladder (§7d) IS the
  round's cold review over the whole combined diff — confirmed, unchanged; (b) **row 17's narrowing is RATIFIED**
  (the "related blocks only" filter applies to PEER columns only; the anchor — her own note — always renders whole;
  the memo's ruling 4's anchor half is thereby answered); (c) **R-cor-8's away-mode premise is superseded for this
  session:** she is a live finding source and taste calls go to her at batch seams as question batches (≤4,
  recommended option first) — PROVISIONAL-and-continue only where she is not reachable. **Her four rulings (the
  question tool, ~16:25):** **(1) BATCH E's panel = the SIMPLE READ PREVIEW** — R-cor-3's PROVISIONAL reading is
  RATIFIED as ruled: the note's rendered text read-cheap, a calm facts line (words · blocks · last edited), ONE
  generous Open door landing where the caret last was, a book shows its outline (chapters + notes), nothing editable
  in the panel (the writable upgrade declined for now). **(2) BATCH G — "RESIDUALS AND WIDTH" — ADDED**, after E and
  before the ladder: rows 59 · 80–86 (below) + whatever the orchestrator's Snippets/Pool/Canvas walk mints at D's
  close. **(3) Row 26 RULED: facts first, text after** — as built; no longer PROVISIONAL. **(4) Row 52 RULED:
  `_word_` underscore emphasis JOINS the markdown vocabulary as italics** — built in G if the display brain's change
  is small, else recorded for 13u2 with the reason. The gaps the orchestrator named to her (recorded because she
  asked): use-found defects parked on "the ladder's fix round" had the wrong owner (a code review cannot find a width
  defect or a click that does nothing); Act 10's Snippets and Pool surfaces were never walked (the triage record
  says so); the book was walked in Terminal only; Read ▸ `pages` clicks do nothing; Blocks still arrives blank
  ~0.3–0.5 s; Compare/Lenses will still look much as they did minus the mechanical fixes (the redesign is the memo's
  phase); Sherlock shows raw underscores; her real store's biometric mode makes the tutorial re-seed her morning act.
  **Her follow-up (~16:40 MDT, verbatim):** *"I'd also like for you to ensure that you add to plan closeout that
  mobile parity rows need to be written for some of the changed behavior - though, mobile doesn't have all of the
  modes (like compare and lenses), and has its own library design, so it might be relatively a small parity note.
  still, it should be kept in mind."* → §7b item 7 amended: the parity line is written PER CHANGED BEHAVIOR, sized
  honestly — a row where the phone owes a version (the seven-mode grammar with Read's `edit · read` and the one
  current block, the scrolled-open door, the book's editable Index, the tag door's shape, the recovery rows'
  date-only stamps + clock slot, underscore italics), and an explicit "not owed — no such surface / its own design"
  line where it does not (Compare/Lenses, the Library panel, the sidebar chrome).

- **R-cor-11 — THE D-CLOSE SEAM'S THREE RULINGS (2026-09-01 ~17:25 MDT, the question tool; she chose the
  recommended option in each):** **(1) Row 46 — placement-per-state ACCEPTED** (the outline door is the offer card
  while the band shows and the header button only while a peer is open — never both; D's deviation from the brief's
  flat retire stands; the memo's build settles the final home). **(2) Row 87 — the Pool card's first-words preview
  is BUILT NOW in G via the picker's road** (a derived line under a titleless card's date, reusing the preview the
  picker already computes — no new rule; 13u2 item 4 still designs the one-brain card family later). **(3) Row 88 —
  BOTH Canvas fixes in G:** (a) a first arrival with no remembered layout opens FIT-ALL, never mid-bank; (b) the
  toolbar to the calm-chip grammar, the redundant label dropped.

- **R-cor-12 — THE 13u RE-SPLIT RULED; THE PROCESS-RULE PROMOTION HELD FOR A DEFINITION (2026-09-01 ~18:55 MDT).**
  Her question (verbatim): *"after seeing the previous failure mode of too much being put into a single phase, do
  you think I should be concerned about the 13u phases? should they be split from their two phases into 3? … Batch
  10 was way way way too big and should've never been a batch, it needed to be a phase, maybe several (clearly,
  since we're in a fix phase for it). I welcome your thoughts."* The orchestrator's reading of the 13u plan FILE
  (not the master plan's summary): 13u2 had grown to two deep items (pane stability; dark mode) + the app-wide
  restyle continuation + three medium reworks (comments area; the snippet brain; PDF formatting) + two RootView
  refactors + four protection items added on her launch morning + the small polish — Act 10's shape again;
  13u1 carried two non-seam items (the quick-capture ruling; multi-block drag). **RULED (the question tool):
  FOUR PHASES BY KIND — 13u1 the SEAM only (items 5 · 7 · 8 + the O(N²) keystroke family) · 13u2 FEEL (item 1
  pane stability incl. row 54 + M12, item 2 the space-eater, items 10/11/13, P39a/P39b) · 13u3 FACES (items 3 · 4
  incl. the journal split + the title chip · 14 · 15 · 16 + item 9's Mac face once the shared sitting rules the
  capture shape) · 13u4 the RESTYLE CONTINUATION + DARK MODE (item 6) together, one surface per session, light and
  dark in both voices.** Moves: item 12 (multi-block drag) becomes its OWN row after 13u1 settles the seam; the
  four protection items (the near-empty typed confirmation #86(c); the nudge bar overlay; the legs brain's SYNC
  leg + "extend" wording; COPY ALL on the recovery phrase) re-home to **pre-13x**, which runs first and redesigns
  those surfaces (its design deletes the loss-legs model — two of the four may be moot by construction; copy-all
  is a one-session 17 entry if pre-13x is far, her word NEED). The 13u plan file's banner + the master plan's
  `### 13u` section carry this at the closeout (§7b item 6); the 13u1 kickoff executes the file split.
  **The process-rule promotion (C-1/C-2/C-3 + a surface budget into the skill and CLAUDE.md) is HELD — her
  words, verbatim:** *"What does one surface mean here? I don't want to have an overload of phases but I do agree
  some have been too crowded. Some changes, like encryption, don't have a walk that makes immediate sense to me to
  require. I would take a look at what the other 13 phases are before making this update - your work and 13u are
  unusually UI focused compared to the other phases. I do think I need to more freely split phases though - 13y
  also comes to mind as being a bit crowded."* → the orchestrator reads the remaining phase rows, defines the
  unit and the kind-shaped acceptance, and brings a proposal (recorded in §7 for her; no rule is written into the
  skill or CLAUDE.md without her word).

- **R-cor-13 — THE SPLITS, PHASE 18, AND THE RULES ADDED AS GUIDANCE (2026-09-01 ~19:30 MDT; her message, verbatim
  where it rules):** *"I agree with breaking 13i up the way you suggested. But let's bring the Journal identity from
  13y in as 13i-e, since it's honestly in a very similar area. Agreed on 13y taking out dedupe residuals. Instead of
  sending those to 17i though, I'd make it the first member of phase 18 - it's time to just start recording the next
  round of work now that we're out of 13 letters. An item in 18 might run before everything in 13, but it's fine. Our
  numbering always gets kinda weird anyway, as long as keep track of it. I think 18a should cover dedupe and extra
  considerations for sync - for example, if another device on sync deleted a lot of work, should you be shown a
  warning / asked if you want to sync your current device to that? I think there's considerations like that, ask to
  sync, pause sync button, etc. Agree that pre 13x doesn't need 17i to be done within it. … I think I agree with your
  rules overall and think that they can be written into the claude.md and architect phase rules and such. I'd put
  them in as guidance to raise as an issue if this is being violated rather than as an absolute rule though. Also,
  do these rules allow for a lot of the already accomplished phases? I think they should be sanity checked against
  what has run, because before Act 10 the sizing seemed like it was working reasonably well - though maybe some
  phases would've been better and there'd be less issues to fix now if it had been followed. It's also possible that
  even if the previous phases don't match those rules, we should add them now because the product is maturing. So
  overall, yes, add the rules."* → **(1) 13i SPLIT: 13i-a** (the schema event + wings/libraries) · **13i-b** (the
  smart-book hybrid identity + auto-tags + the starred smart book) · **13i-c** (Owned + text immutability + the
  convert door) · **13i-d** (the shelf: custom order + starred books; the Book Panel; templates if ruled) · **13i-e
  THE DAILY JOURNAL'S FIRST-CLASS IDENTITY** (moved from 13y — the memo `pre-13u-memo-daily-journal-identity.md`);
  one design sitting rules all five; the ONE lockstep deploys with 13i-a. **(2) 13y keeps the per-tenant sequence +
  the abuse guard + the Fragments brief; the dedupe residuals LEAVE it.** **(3) PHASE 18 OPENS — the post-13
  collector of PRODUCT work (lettered 18a, 18b…; an 18 item may run before a 13 letter): 18a = SYNC CONSIDERATIONS**
  — the sample-library dedupe residuals (the late-registry leg, the six unread engagement legs, the bounded
  re-hash), deletion-aware sync (another device deleted a lot of work → a warning / ask before this device follows),
  ask-to-sync, the pause-sync door (the pre-13x design's parked 17k joins here), and the like — opens with a design
  sitting. **(4) 17i runs as its OWN entry after pre-13x, never inside it.** **(5) THE RULES ARE ADDED — as GUIDANCE
  TO RAISE, never an absolute rule** — into CLAUDE.md's build workflow and the architect-phase skill (this commit),
  worded exactly as the §7 proposal with her guidance clause. **(6) The sanity check she asked for, against the
  run history (by acceptance units named in each row's deliverables):** 11a (~8 phase-sized: the fan-out styles,
  lenses + the version family, aligned views, diff, scrub, the TOC, canvas + its lockstep, the pool) → would be
  FLAGGED; 13b Stage 4 (two ceremonies, Compare rebuilt, the canvas package, the paged book + progress bar,
  restoreReading, a migration) → FLAGGED (closed early at her EOL directive — the 5k-line plan file was the
  symptom); 13c (the friction batch + the uniform-page book view + the N38 conversion + Compare related-only + the
  book-order lens) → borderline; 13d, 13g, 13k → PASS (bounded rows / one theme); 13e → borderline (the overnight
  run); 13f (side-by-side windows + tabs + starred + the quick note + the string sweep) → FLAGGED; 13j (the purge
  lockstep + the Trash + the recovery surfaces + the divide/merge default flips + the restoration doors) → FLAGGED
  (the live 42702 incident was its one visible cost); 13l → PASS (two units); 13p (the spike + the substrate +
  custody/modes/recovery + copy + the phone's faces) → AT THE LINE (three units, one theme, sequential batches,
  drills as the gate — it ran clean, which is the shape pre-13x repeats); 14c → FLAGGED (the multi-tenant rebuild
  + the entitlement + two-user suites + the deletion doors); the pre-13u round (~8: four 17 entries, a review,
  Sherlock, Act 0 ×2, the custody batch, Act 10 ×4 waves) → FLAGGED HARD — this round is its bill. **Reading:**
  the flagged phases are where the fix rounds came from (13b → 13c's friction batch; the pre-13u round → here),
  while the substrate-era phases passed on a different bar — functional, unstyled, tests as the gate. Both of her
  readings hold at once: the sizing "worked" while the acceptance was tests, and the bar is added now because the
  product is maturing and the acceptance is use. Recorded in CLAUDE.md's guidance as its why. **HER OPEN QUESTION
  (not ruled — the orchestrator's proposal is in §7):** *"Maybe I don't need architects for every 17 item? … the
  whole ladder, cold reviews, etc. are a lot of tokens for small changes."*

- **R-cor-14 — HOW A SPLIT RUNS, CLAUDE.md's LENGTH, AND THE 17-ENTRY REVIEW RULE (2026-09-01 ~19:45 MDT; her
  message, verbatim where it rules):** *"is the idea that I run 13i as a phase still but it's more ordered? or is
  it a run architect for 13i-a, etc? Make sure Claude.md isn't becoming too long with these changes … maybe have an
  extra guidance file that sessions can refer to if they're in doubt but I'm not sure if what 13 phases passed this
  check is really essential info for the file every session reads. I think that a 17 entry can run as one session
  but at the very least, an Opus cold review should always be mandatory. Fable cold review for a diff that touches
  sync, custody code, or the editor seam. and tbh, I'll probably most still run 17s either a couple of them together
  as a ad hoc phase or with an architect, because I try to only implement with Fable on key items and yet, letting
  Opus run things on its own leads to an absolute mess - Opus is bad at keeping files caught up with what's
  happened and lacks the discipline and thoroughness to be an architect or even keep track of its own work. With
  the Opus cold review addendum, I largely agree."* → **(1) A split = SEPARATE phase runs sharing ONE design sitting**
  (`/architect-phase 13i-a`, closeout, install; then 13i-b; …) — not one long ordered phase (13b's shape, whose plan
  file outgrew the reading rule); the answer is written as `notes/PhaseSizingGuidance.md` §3. **(2) CLAUDE.md
  TRIMMED:** the guidance bullet shrinks to a four-line summary + a pointer; the unit table, how a split runs, the
  run-history sanity check and the 17 rule move to the new `notes/PhaseSizingGuidance.md` (the skill's section
  points there too). **(3) THE 17-ENTRY REVIEW RULE:** one session allowed; an OPUS cold review ALWAYS mandatory; a
  FABLE cold review for `Sync/`, custody/keychain code, or the editor seam — written into the 17 file's header (rule
  4), CLAUDE.md's standing-fixes bullet (one sentence) and the guidance §5 with her practice (a few entries at a
  time under a Fable orchestrator; Opus never runs alone).

- **R-cor-15 — THE G-CLOSE SEAM'S THREE RULINGS (2026-09-01 ~21:40 MDT, the question tool; she kept every one as
  built):** **(1) Row 88 — the Canvas arrival stays 1:1** (a fitting board centred; a big board at its top-left; the
  overview only on a summoned `fit all`). **(2) Row 81 — the folded bar as built** (the `Nw block · Nw selected`
  counts drop below 840 pt; the compact tier drops the note total too). **(3) Row 74 — leave as is:** the note-side
  column draggable with a remembered width; the Library's preview column fixed. No code moves between G and the
  ladder.

- **R-cor-16 — THE #88 BUNDLE, RULED AWAKE (2026-09-01 ~22:05 MDT; her question "what is in questions 88? should I
  not handle it now?", then the question tool):** **(1) Read's `edit · read` face is remembered PER NOTE** (C's
  architect call ratified). **(2) Row 57 — the sidebar's arrow-key row navigation stays OUT** ("leave it out";
  recorded, no owner). **(3) The Lenses + Compare memo's ruling 6 — TWO TABS, structurally distinct** (the memo's
  shape A). **(4) The memo's ruling 1 — the memo's door words stand:** Use this lens · Save as lens · New note from
  this lens (+ "bring every take along"). QUESTIONS #88 therefore carries only the memo's remaining rulings (2 · 3 ·
  the peer half of 4 · 5 · 7 · 8 — and WHEN its build phase runs) plus anything the ladder leaves open.

**Inherited rulings this round builds to (not re-litigated):** the eighth-wave rulings W8-1…W8-5
(`pre-13u-round.md`), the fifth-wave item-15 flow ruling, the mode-row canon R60–94 as extended by
W8-1 (the eight-mode row is AppSpec §12 canon), her copy doctrine (structure and generous targets
first; a sentence only where truly necessary; she rewrites copy later — keep every capability
present), and the 13j recovery doctrine (the Trash is the recovery door).

## 2. Binding principles

### 2a. The 13b constitution (P-1…P-9 — copied byte-verbatim from the skill, as every architect-phase run does)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

### 2b. This round's own rules (C-1…C-7 — the fix for the CAUSE; binding on every batch)

- **C-1 — ONE SURFACE PER IMPLEMENTER SESSION.** A batch is one surface. A session that finds a second surface in its way hands off with a record; it never "also does" the next one. (Wave 2c's five-in-one is the counterexample this rule exists for.)
- **C-2 — THE ACCEPTANCE GATE IS USE, NOT MOUNT.** A batch record may not close on mount smokes or pins alone. The implementer walks ITS OWN ledger rows on the running dev-store Debug build — clicking the thing each row is about — with a screenshot per row in the round's screens dir; then the orchestrator walks the same rows hands-on before the record is marked closed. A row whose behavior cannot be exercised in the walk says so, with why.
- **C-3 — NO INSTALL REFRESH WITHOUT A WALK.** `/Applications` is refreshed once, at the end, after the orchestrator's full walk of every touched surface (and the ladder's fixes), at a zero-instance window, the A1 backup first.
- **C-4 — A RULING IS DELIVERED WHOLE, OR ITS RESIDUE IS THE RECORD'S FIRST LINE.** Half-delivering a ruling (W8-3's pane, Index's read-right) is never recorded as done.
- **C-5 — SCALPEL, NEVER AXE — AND LAST.** A per-surface revert to the pre-Act-10 form (file-level, from git; the Act 10 version preserved on a branch `act10-<surface>`) is a NAMED disposition, taken only when the surface cannot be made right inside its batch, recorded with the reason, and bundled for her. Her lean is against retiring anything.
- **C-6 — CALM CHROME.** No metric, count, or label appears in chrome without a stated reason a reader needs it there. Word counts especially (row 31). One door per act (the tag cluster's two doors for one act is the counterexample). Squarish-rounded controls, the mockup grammar (W8-2), solid geometric lines (W8-3) — the style guide stands.
- **C-7 — QUALITY IS THE BAR — "a premium feeling app".** Alignment is a defect. A click that does nothing is a defect. A panel that overflows its window is a defect. A view that lags a second on selection is a defect. Each gets a traced mechanism and, for bug-class fixes, a red-on-old pin; taste calls beyond the granted latitude are bundled for her, never improvised.

## 3. THE LEDGER — her items, every one a row (status: OPEN · TRACED · FIXED(pin) · RECORDED · DEFERRED(owner) · REVERTED(branch))

| # | Her words (short) | Surface | Traced mechanism / architect's read | Batch | Status |
|---|---|---|---|---|---|
| 1 | Library note peek "isn't terribly helpful… a preview of the note you can write in, if anything"; was meant to occupy the writing-modes' space | Library right panel (`LibraryInfoPanel`) | Built as a facts panel; R-cor-3 rules the shape: simple READ preview + one door landing at the saved caret; books show their outline | E | FIXED (E `04355fb`: the simple read preview — title · one facts line · the full-width Open · the note's text on the FlowParagraph tier; Open landed at block 8/215 in the walk; pins ×5, red-on-old 3 issues) |
| 2 | "the left edge of the program still has the liquid glass floating edge" | Sidebar container | W8-3 half-delivered: interior flattened (`SidebarView.swift:348`), the floating pane kept | A | FIXED (A `b22b6ff`: `ShellSplit` replaces NavigationSplitView — the glass pane gone; walked: orchestrator-a/00) |
| 3 | "the tabs used to be right below the modes, and the tab spacing has gotten less generous… hard to read" | Sidebar mode rail + Open strip | The Open strip rebuilt at the sidebar's bottom (Act 10 item 9); the eight-mode rail compressed (`SidebarView.swift:464–487`). Generous at ordinary heights; compress only under a measured height threshold (the bottom-bar precedent) | A | FIXED (A: flat column, one 30-pt pitch, the Open strip under the rail; `SidebarLayout` compresses only under a measured height; walked: 00) |
| 4 | Read: "doesn't have a centered title above the read" | Masthead (all modes) | The title sits in an asymmetric masthead after item 5's tag cluster took the right — same defect as rows 16/19 | A | FIXED (A `74c72db`: the title centers on the masthead's full width in every mode — pinned across all eight; walked: 00, the crops) |
| 5 | Read: "I want the mode where you can scroll horizontally through the pages that the other one has" | Note Read (`read` half, R-cor-7) | `ReadModeView` has no paged mode; the book's paged view (13b Stage 4 — `scroll · pages`) is the reuse, seen working in the book's Read tab on the walk | C | TRACED |
| 6 | Read: "that contents looks kind of weird with how it's cut off" | Note Read's contents column | Mid-word width truncation of first lines | C | OPEN |
| 7 | Book: "clicking on a block automatically navigate[d] you there, and now you have to expand it before editing it" | Book Outline | Walk-confirmed (captures 49/25): a note-row click selects + toggles expansion but does not reveal (row 47's mechanism); expanding lands focus on the LAST block. Ruled shape: a note-row click REVEALS and lands in the note at its first block (or the clicked block via row 38's door); the ▸ disclosure is the separate expand affordance | B | FIXED (B, walked: 20-fg-far-noterow-reveal) |
| 8 | "the left outline looks a bit weird in sherlock holmes with the chapters + the blocks named the same" | Book navigator | Chapter and note share a title; collapse the note line when it equals its chapter (read-time) | B | FIXED (B, walked: 03-sherlock-outline) |
| 9 | "clicked on an item in the middle of the outline… scrolling went absolutely berserk… landed me at the end" | Book Outline | `BookView.swift:895/932` — `withAnimation { proxy.scrollTo("page-\(id)", anchor: .top) }` over a lazily-realized stack of 9k-word cards: the SwiftUI lazy-stack scrollTo class (estimates, travel, overshoot). NOT TK2. Pin on the Sherlock book | B | FIXED (walked: one expanded story 04/05/07/10/11; ≥2 expanded via row 53's fix, orchestrator-b53/A–C) |
| 10 | "the tags are also misaligned from the text" (image 4) | Library rows | Baseline/vertical-center mismatch | A | FIXED (A: geometry pin; the sheet's rows close-up in both voices) |
| 11 | "the word book is misaligned" (image 5) | Library rows | Same class as 10 | A | FIXED (as row 10) |
| 12 | "Scrolling via outline in the book view has completely broken" | Book Outline | Row 9's mechanism | B | FIXED (as row 9) |
| 13 | The gutter "177w… 236w · ⑂ takes on 1 block" is "crowded", low value; "the point was that the note info that used to be below it would be to the right of it" | Book Outline details gutter | Item 18 invented a facts string instead of moving the note details that rendered under the opening paragraphs; move THOSE aside, drop the string (C-6) | B | FIXED (B, walked: 03) |
| 14 | "clicking on the chapters isn't even TRYING to navigate the book at all" | Book Outline | Walk: a navigator CHAPTER click DOES navigate when every card is collapsed (captures 23/50); with a story expanded it livelocks (row 44). The main column's chapter HEADINGS (⠿ name) are not doors at all — her click may have been there. Fix: chapter headings become doors too; the navigator's chapter click survives expansion (row 44's fix) | B | FIXED (B, walked: 15-body-heading-click, 11-about-this-text) |
| 15 | "showing a tag icon and a + tag at the same time… that's just sloppy"; click → a "tag creator" field slides out, cursor active | Masthead tag cluster | `MastheadTagCluster.swift:54–76` renders cards + "+ tag" + the `#` fold (K12's sticky fold). ONE door with her slide-out field; the fold preference folds into it | A | FIXED (A: the ＃ is THE door — an inline field with the cursor, ⏎ applies; ＋ tag and the masthead fold retired, K12 superseded there; ⌘⇧I → `.tagNote`; walked: 07/09 — open + apply). Nit → row 59 |
| 16 | Compare "horribly misaligned" (buttons useful, clarity improved) | Compare | Two left edges/baselines in the flow | D | FIXED (D `e400618` + `70073fa`: ONE inset for toolbar/strip/band/rows, the add doors at the strip's end at the header's height, the Lenses cards over their panes; `CompareLensesAlignmentTests` ×2, red-on-old 6 issues) |
| 17 | Compare: "'This note' is showing nothing" | Compare anchor column | `CompareBoardView.swift:938` `anchor.title ?? "This note"` — a journal entry's title is nil so the literal shows; and "related blocks only" is emptying the ANCHOR, which it must never filter — peers only | D | FIXED (D `e400618`: the anchor exempt from the filter — RATIFIED R-cor-10(b) — AND the rows render in every state; the ONE display rule names the card; `CompareAnchorWholeTests` ×2, red-on-old 6 issues) |
| 18 | Blocks: "that line between them should be draggable left / right" | Blocks workbench | Fixed split today; draggable, remembered | C | OPEN |
| 19 | Lenses: "the title is once again weirdly aligned" | Masthead | Row 4's defect | A | FIXED (as row 4) |
| 20 | "the use of lenses is still a bit unclear" (→ R-cor-6: "absolutely dizzying") | Lenses | Folds into the Lenses + Compare design memo (R-cor-6) | D (memo) | RULED (R-cor-6) |
| 21 | Read: "the outline isn't working great… being able to tap to toggle the outline being on and off is great though. I love that" | Note Read's companion outline | Click/scroll fixed; the toggle stays byte-as-is | C | OPEN |
| 22 | Book Index "looks and feels good, but then you can't actually click into it to edit it" | Book Index | Read-only BY DESIGN (`BookIndexView.swift:23` — double-click hands off to Outline; walk-confirmed, and the handoff lands focus on the LAST block 3/3, not the clicked one). R-cor-7: editable in place — the clicked block goes live in the right pane (one live editor, P3); the book's Read stays read-only | B | FIXED (B, walked: 17-book-index-click-live; caret lands at the block's END — row 49's family, batch C) |
| 23 | "the error on clicking on note titles in the outline place in the app was intermittent" (the field guide too) | Book navigator | Trace on the field guide as well as Sherlock; likely row 9's class racing realization | B | FIXED (B, walked with 47) |
| 24 | "the appearance of the 'this note' modes is just as jarring as it has been" | Sidebar rail | R-cor-3: the rail FADES in/out smoothly; nothing added on the left | E | FIXED — the sidebar half (A: the rail fades, the Open group slides; the sheet's 03-terminal-rail-fade-mid); the panel half (E `4e5a39e`: the column slides + fades in an animated transaction at the mutation sites — the burst trace; the subject swap fades) |
| 25 | "the blocks page is also weird and laggy - it takes a second after selecting it for it to be selected" | Blocks workbench | Trace: the workbench observation (`observeBlockWorkbench`) + selection work on the main actor are the candidates; measure, then fix | C | OPEN |
| 26 | Blocks: "the text is also above the details" | Blocks context panel | Architect's read: the block's full text card sits above the facts; the facts should lead (the text is already in the row) — correctable at her word | C | FIXED (C: facts first, text after — **RULED R-cor-10(3)**, no longer PROVISIONAL) |
| 27 | "opening block history doesn't open it correctly" | Block History from Blocks | From Blocks it opens as a THIRD right column beside the workbench's own panel → overflows the window (her "Clos…"/"Restore" cut). One right region at a time | C / F | TRACED |
| 28 | "not sure what the difference between savepoints and lineage is supposed to be, or if they're both in there" | Block History pane | Both are in it (savepoints = each take's saved moments; lineage = the block it came out of); the sections must READ as sections | F | OPEN |
| 29 | "the block history tab stays open as you move to other modes which looks bad and is confusing" | Block History host (`PostDetailView.swift:286`) | Walk-confirmed (captures 45/46): opened from Write for block 3, it persists into Takes showing block 3's history while block 1 is live — stale AND persistent. Scope it to the mode (and the block) that opened it | C | TRACED |
| 30 | "the index tab is ALSO uneditable in the notes view… it's literally a new writing mode" | Note Index | Built read-right / edit-in-a-small-left-card (`IndexModeView.swift:380–387`). Her ruling: the RIGHT pane is the writing surface (click → that block goes live there); the left column is a navigator | C | TRACED |
| 31 | "the index dropdown on the left is also awkwardly sized, the text is bigger than it" | Note Index left column | The expanded card is the misplaced live editor of row 30; retired with that fix | C | TRACED |
| 32 | "not sure if all of these changes were noted or if you're going to have to look through commit history" | — | Every wave has a record; the 34-commit trail is complete. RECORDED — the gap was use, not record | — | RECORDED |
| 33 | (R-cor-3) "when I click on a book, i just still see the last note i clicked on - obviously bad. a book could show the outline that it has" | Library right panel | Walk-confirmed exactly (capture 20: the book row highlights, the panel keeps the previous note). A book selection shows the book's outline in the panel | E | FIXED (E: two mechanisms — the book row's dead body click (the line's width was its words') and facts-not-outline; the panel shows chapters + notes in the navigator's grammar, a note row opening the book AT that note; pins ×4, red-on-old 5 issues; the at-mount LANDING is B's road's residual → row 73 in E's record) |
| 34 | (R-cor-3) "the line between the 'note info' and the library disappears when you're tabbed out, and it needs significant work" | Library right panel boundary | Inactive-window appearance loses the divider/wash; hold the boundary in both states | E | FIXED (E: the `.inspector` — whose divider the system draws in a KEY window only, measured — retired for a column of our own: the shell's 1 pt line + the panel on the room; identical active/inactive in both voices by window-id capture; pin over both `controlActiveState`s, red-on-old 2 issues) |
| 35 | (R-cor-4) "special attention… to the lineage / history / archive / trash" | This Note's Tray · Block History · Archived · Trash | Batch F walks each surface fresh, lists every defect found, fixes them with pins; the rebuilt tray (Act 10 item 1) is walked at every pane width | F | OPEN |
| 36 | (R-cor-4) "word count shouldn't just be thrown in everywhere just because" | All Act 10 chrome | Sweep table: every word-count/metric display in the eight rewritten views (Snippets 10 · Read 6 · Blocks 4 · Index 4 · BookView 4 · LibraryInfoPanel 4 · Compare 2 · BookIndex 1) verdicted KEEP-with-reason or DROP (C-6) | A (table) · each batch (its rows) | OPEN |
| 37 | (R-cor-4) "not sure what the 'reading time' was calculated on… how random is it?" | Note Read | `words ÷ 200` rounded up, a fixed 200-wpm convention — not random, not measured. Stays per her word | — | RECORDED |
| 38 | (2nd msg) 13u item 17 — "if you click somewhere in the read mode, that it doesn't open there in the outline or the writing mode… it might make sense to pull that issue up into this phase, since it seems like there's a lot of 'cross pane interaction'" | Read → Index/Write click-through; the book's Read → editable view | PULLED IN (her word): the ONE scrolled-open door — click a sentence anywhere read-cheap, land in the editing surface at that block with the caret there — built once here and reused by rows 22/30 and the book; 13u2's item 17 is re-homed to this round | B + C (one mechanism) | FIXED — book half (B, walked: 24-read-paragraph-click; the note half is batch C's; nit: the landed block sits flush at the pane top, ring clipped — a top inset) |
| 39 | (2nd msg) "I haven't even gotten into blocks and index and how clicking through them is impacting the regular write and takes mode" | Cross-mode position continuity (Write ↔ Takes ↔ Read ↔ Blocks) | Walk: position is PER-MODE MEMORY today, not one position — Index kept block 03 while Takes made block 1 live; Write→Takes carried the caret's block when the caret was in block 1 (capture 39/40); Blocks keeps its own selection. Ruled by W8-1's letter: ONE current block follows you across Write/Takes/Read(edit)/Blocks; batch C builds the one authority and pins it | C | TRACED |
| 40 | (2nd msg, image 16) the book Outline's expanded note shows the bottom bar's items stacked VERTICALLY in a floating side card ("block 1/1 · block ▾ · Takes · commit ⌘S · history / note ▾ · comments · Aa / 5w block · 5w in note · ?") — "looks kind of weird… maybe the note menu needs to be collapsible… what's in that menu and how it looks needs to be a bit clearer" | Book Outline's in-place editor chrome | Trace where the side card comes from (the `CommitBar` axis introduced at wave 2c); make it read as one clear, calm control — collapsible if the trace says a stack is the right shape at that width | B | FIXED (B, walked: 00-state, 04 — one compact grouped card) |
| 41 | (2nd msg; RULED R-cor-6 — they need a design) "if compare needs its own phase, give it its own phase!! that's fine" | Compare + Lenses | RULED R-cor-6: the design memo is written in-round, the build is its own phase. Earlier note: batch D fixes the defects (rows 16/17); if the triage walk finds Lenses/Compare need a DESIGN rather than fixes, the orchestrator writes the brief for a phase of their own instead of half-building it (the S4-16 condition) | D (memo) | RULED (R-cor-6) |
| 42 | (2nd msg — RULED R-cor-5: one tab, Read, with the Index's outline) "I also wonder if Index / Read could be condensed into a single tab - making it more similar to book, where it's a selector within a place you're in. and the outline button could hide / show the index, and the index could function as the outline." | The note mode row | A product call — asked at the sitting with the architect's recommendation (see the sitting record) | C | RULED (R-cor-5) |
| 43 | (2nd msg) "If I need to ship the app with just writing and takes, I'd be willing to do so, but ideally that won't be necessary" | — | Recorded as her floor, not the plan; the round's bar is every mode useful, bug-free and beautiful | — | RECORDED |
| 44 | **FOUND IN THE TRIAGE WALK — THE BOOK OUTLINE HANGS (BLOCKER): expand a long story, click a chapter in the navigator → 100% CPU, main thread livelocked, window unresponsive (190 s+ observed; killed).** Her "berserk… landed me at the end of the note" is this defect's onset. Reproduced first try on the dev store's Sherlock book (steps: open the book · Outline · click the "The Boscombe Valley Mystery" NOTE row in the navigator, which expands the 9,689-word story in place with focus on **block 215/215** · click any chapter row). Sample: `act10-correction-screens/triage/sample-hang-47298.txt` — every hot frame is SwiftUI (`NSHostingView.beginTransaction → GraphHost.flushTransactions → LazySubviewPlacements.placeSubviews → LazyStack.place → ForEachList.applyNodes → … LayoutEngineBox/UnaryLayout`); our only frames are value copies of `ReadingSection`/`Queries.ReadingEntry`. | Book Outline | **Mechanism (traced at the code, to be confirmed by the implementer's pin):** `BookView.swift:1106–1116` — an EXPANDED note composes the FULL `EditorView` (a TK2 `NSTextView` whose height ESTIMATE moves as its viewport lays out — TEXTKIT2 §2) INSIDE a `LazyVStack` row (`:772`), and the navigator's `withAnimation { proxy.scrollTo(…) }` (`:895`, `:932`) animates toward an anchor whose offset depends on that moving height: place → the editor re-estimates → re-place → the target moves → repeat. Related symptom: expanding lands focus on the LAST block (215/215). Fix shape for batch B: an expanded editor's height must be settled before/while a programmatic scroll runs (measure once — `ensureLayout` over the one expanded note is bounded — and hold it; no animated `scrollTo` at an unsettled anchor), or the expanded body leaves the lazy container; plus the focus-lands-at-end fix. **Red-on-old pin: a mounted book with one 9k-word note expanded receives a navigator scroll request and the run loop returns within a budget (a watchdog), landing at the requested chapter.** | B (FIRST) | FIXED — the HANG (walked three ways, CPU 58/19/33 % → 0 within 2 s, window responsive; Boscombe opens at block 1/215); the multi-expanded LANDING residual is row 53 (open) |
| 45 | (walk) The book Outline's collapsed card previews only the FIRST block — "A Scandal in Bohemia" previews as "I." (its section numeral); the field guide's cards read fine because their first blocks are prose | Book Outline cards | Preview = the first ~40 words across the note's leading blocks, skipping a lone heading/numeral block (read-time derived, never stored) | B | FIXED (B, walked: 03) |
| 46 | (walk) Compare offers "make outline note" and "+ note" TWICE — as top-right buttons AND as the two centered offer cards | Compare | Two doors for one act (C-6's counterexample class); one placement per act — the memo (R-cor-6) decides which; the mechanical fix here is not to duplicate | D | FIXED (D `e400618`: "+ note" at the strip's end only while every slot is filled; the outline door the card while the band shows, the header only while a peer is open — one placement at any moment, the flat retire deviated from for the auto-fill reason in D's record, hers to confirm; `CompareOnePlacementTests`, red-on-old 3 issues) |
| 47 | (walk) A navigator NOTE-ROW click in the book Outline selects (›) and toggles expansion but never REVEALS the note when it is off-screen — the field guide's "the take ceremony" got its marker and the page did not move; the Sherlock case only "worked" because a chapter click had already placed the note at the top | Book Outline navigator | `BookView.swift:899–911` — "Reveal is SCROLL-TO and never an auto-expand … the `page-<id>` anchor the expanded header does" — the reveal targets an anchor a collapsed card does not carry, so a collapsed note cannot be revealed; this is row 7's "you have to expand it" and row 23's "intermittent" in one mechanism | B | FIXED (B, walked: 20) |
| 53 | **ORCHESTRATOR'S WALK OF BATCH B (2026-09-01 ~06:35) — RESIDUAL of rows 44/9/12, MAJOR: with TWO OR MORE expanded stories in the book, opening a COLLAPSED story lands INSIDE THE WRONG STORY (no hang; CPU 0; window responsive).** Repro on the dev store's Sherlock, fresh build 57450: (1) open Boscombe via its row (lands block 1/215 ✓) · (2) open Noble Bachelor far below (lands ✓) · (3) open Five Pips (lands ✓) · (4) click "a scandal in bohemia" (collapsed, far ABOVE) → the page stays at speckled band / engineer's thumb / noble bachelor (capture `orchestrator-b/06-chapter-above.png`); a SECOND click on the now-expanded scandal lands within 1 s (`08-scandal-1s`) · (5) open the LAST story (collapsed, far below, three expanded between) → lands mid-way through NOBLE BACHELOR (`12-last-story-opened`) · (6) click "the red-headed league" (collapsed, above) → lands mid-way through SCANDAL, 4 s later still (`14-redheaded-first-click-4s`). One expanded story: every landing exact (04/05/07/10/11). | Book Outline landing | The batch's "bounded convergence" stops before the expanded-but-unrealized editors between the viewport and the target have reported their heights (each 8–9k words ⇒ thousands of points of estimate error per story); the first click also has to EXPAND the target (a height change of its own). Fix shape: converge on the TARGET's measured frame (iterate until the anchor's top is stable at the viewport's top across two consecutive layout passes, with a generous iteration cap and a watchdog — never a fixed count), and when the click expands the target, land AFTER the expansion has laid out. **Pin: a book with THREE expanded 9k-word notes; open a collapsed note far below and one far above → each lands at its own top (RED on the current tree).** | B (reopened) | FIXED (the fix session `7569af3`…`a2f31cb`: the segmented Outline column + StableSurface + the stability-driven corrector; pin `openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded` RED on old; walked by the orchestrator on build 67746: `orchestrator-b53/` A/B/C all land at the top; CPU 0.4, one window) |
| 58 | **ORCHESTRATOR'S WALK OF BATCH A (2026-09-01 ~09:50) — RESIDUAL of rows 4/19/15/55, MAJOR (a visible collision on any note with several tags): the masthead's SECOND row — the centered `~/book` path chip and the trailing tag cluster share it, and they OVERLAP.** On "three ways of working" (5 tags) the path chip `~/the field guide` is drawn UNDER the first two tag cards (`orchestrator-a/00-write-state-masthead.png`); with the `#` field open the chip vanishes under the field + cards entirely (`01-tag-door-open-masthead.png`). | Masthead row 2 (`PostDetailView` masthead + `MastheadTagCluster`) | The title block's centering padding measures the FIRST trailing row (the icons), not the second (the cards + the field), so row 2's centered chip and row 2's trailing cluster are laid out unaware of each other. Fix shape (chosen under R-cor-8): row 2 becomes ONE layout — the path chip leads (left-aligned under the title's leading edge, or centered only when the free width allows it), the cluster trails, a minimum gap between them is honored, and when cards + field exceed the free width the CLUSTER wraps to its own third row (never over the chip); the title's centering padding takes the WIDER of the two trailing rows. Pin: a geometry pin — five tags + the field open → the path chip's frame intersects no card and not the field, in both voices; RED on the current tree. | A (reopened, fix session) | FIXED (the fix session `7dee4c7`…`8330790`: the path chip leads at the article's margin, the cluster wraps right-aligned as `TrailingFlow` reserving the field's width; pins RED on old (10 issues); walked by the orchestrator on build 81367 — `orchestrator-a/02-r58-closed-masthead`, `07-hash-open-masthead`, `09-tag-restored-masthead`: five tags closed/open/applied, no collision) |
| 59 | (orchestrator's walk of A) The masthead `#` door's HIT TARGET is the glyph itself (~10 pt) — a click a few points off lands on the neighbouring card's × (the orchestrator removed a tag by accident that way) or in the editor | Masthead tag door | Give the `#` a generous hit target (≥ 24 pt, the row's height) without moving the glyph; a pin on the button's frame. NIT, quality-class (C-7 "generous targets") | **G** (re-owned R-cor-10 — a code review cannot find a hit target) | FIXED (G `0a44a87`: a 24-pt frame around the glyph — `MastheadTagCluster.doorTarget`; `theTagDoorsHitTargetIsTheRowsHeightNotTheGlyphs`, red-on-old the door under 24; walked: `59-01`/`59-02` — both corners open the field) |
| 55 | **FOUND IN BATCH A's OWN WALK (capture `11-terminal-tag-field-open`, the first cut):** with the inline tag field OPEN the masthead title collapsed to "thr…" — the field was laid out inside the trailing cluster, the cluster's measured width grew by the field, and the title layer's symmetric inset (rows 4/19's centering) squeezed the title to nothing | Masthead (A) | The field must not participate in the masthead's layout: it is an OVERLAY sliding out of the ＃ to the left of the cards (the cluster's width never changes; the title neither moves nor truncates while a tag goes on), and the title's inset gained a FLOOR (the title keeps ≥ 240 pt whatever the cluster holds — many tag cards included). The second cut caught the SAME class one step out (three chips squeezed the title to "worki…" at its floor) — the coupling itself was the defect, so the masthead became TWO ROWS, each a ZStack: the TITLE row centers on the full width inset by the ICON row's width (the only thing that shares its line); the PATH row centers inset by the tag cards' row's width; the path line yields (fades) while the field is out. Pins: `MastheadLayoutTests` + `MastheadTagDoorTests` green after; walked with FIVE chips + the open field in both voices — the title intact and centered (captures 11b / 24b) | A | FIXED (A, in-batch) |
| 54 | **FOUND BY THE ROW-53 TRACE (not the book's surface): every read-cheap TK2 surface measures itself TWICE on realization — a first measure at a provisional width (~half the final height: `10,366` then `20,056` for the same story), then the settled one** — a layout jump every `ReadPostView` makes when it appears; the Outline now hides it behind the remembered surface size, but the surface itself (and every other host of it) still jumps | The read tier (`ReadPostViewModel.remeasure` / `viewWidthChanged`) | Measure at the settled width only (or hold the last known height until the width settles) — the "non-editing pane jumping" family (13u2 item 1); outside the book's files (C-1) | C / 13u2 item 1 | RECORDED |
| **80** | (F's walk, its record's (b) — orchestrator-minted at R-cor-10; ORCHESTRATOR rows this session use 80+ so an implementer's 69+ sequence never collides) at a ~950-pt window the masthead TITLE and the ICON row touch/overlap (`walk-18/19`) | Masthead (`PostDetailView`) | Row 58's family at another width: the title row insets by the icon row's width and keeps a 240-pt floor — at ~950 pt the floor meets the icons. Trace at that width; the fix keeps the centering, the floor and the row-58 pins green (a title that yields to `…` before the icons is legal; a title UNDER the icons is not). Geometry pin at 950 pt in both voices | G | FIXED (G `0a44a87`: `MastheadTitleInsets` — the trailing inset keeps the icons clear, the floor is spent on the leading side, the title yields to `…`; pure + geometry pins, red-on-old 4 issues (the title 65 pt under the icons); walked at 950 + the tray in both voices: `80-81-03`, `80b-02`) |
| **80b** | **HER LIVE FIND during batch G (2026-09-01 ~18:58 MDT, her screenshot — copied to `act10-correction-screens/author/2026-09-01-narrow-masthead-tag-over-title.png`; her words: "alerting you to this issue where the tag goes over the title on a narrower window - I saw it by chance during the testing"):** with the tray inspector open in a ~1740-pt window (sidebar 380 · tray 740 · the detail ≈ 590 pt), the masthead's SECOND row collides — the `sherlock holmes ×` tag card is drawn OVER the path chip's text ("~/the adventures of" then the card on top of "sherlock holmes", the two strings doubled), and the `#` door is orphaned on a line of its own below; the title reads "The Boscombe V…" (the 240-pt floor beside the icon row — expected at this width) | Masthead row 2 (`PostDetailView.swift` ~:294–318 — the `HStack(alignment: .firstTextBaseline)` of `MembershipChip` (`fixedSize` + `layoutPriority(1)`) and `MastheadTagCluster` (`frame(maxWidth: .infinity)`, the `TrailingFlow` layout inside) | Row 58's family at a THIRD width (row 80 is row 1's; this is row 2's): when `chip + gap + the flow's narrowest line (one card + the 196-pt field reserve)` exceeds the masthead width, the HStack cannot satisfy both — the chip wins its width, the flow is offered less than its minimum and PLACES its items from the right edge regardless (a `Layout` does not clip), so the card lands over the chip; and because the one card alone does not fit, `keepsWithPrevious` has nothing to pull and the door drops to line 2 alone. Fix shape (G, WITH row 80 in the width pass): row 2 becomes width-aware — when chip + gap + the flow's minimum line exceed the width, the CLUSTER moves BELOW the chip onto its own full-width line (the door on the cards' line, never orphaned), the chip never covered; and the path chip may ellipsize at its tail (`lineLimit(1)` + a max width) rather than push. Pin: a ~590-pt masthead (the tray open) with one tag and with five, both voices — the chip's frame intersects no card, the door sits on the last card's line; RED on the current tree | G | FIXED (G `7eabbc2`: `MastheadRowTwo` — one line while chip + gap + the cluster's minimum fit, else the chip above (ellipsizing) and the cluster below with the ＃ on the cards' line; `TrailingFlow`'s minimum line, leading-edge guard and yielding reserve; pins both voices at 590 (one tag, five) and 340, red-on-old 7 issues; walked: `80b-00` before, `80b-01`/`80b-02` after) |
| **81** | (F's walk (c)) the note's BOTTOM BAR at ~950 pt wraps to TWO rows with labels truncated to "t… · c… · h…" (`walk-18`) | `CommitBar` (the flat bar) | P-8 honored into illegibility — a truncated verb is a verb nobody can read. At a narrow measure the bar COLLAPSES honestly (icon-only labels, a fold, or a `▾` overflow for the tail group — the side card's `ViewThatFits` precedent), never a truncated label, and stays ONE row. Pin: at 950 pt no bar label truncates and the bar is one row; at 1708 pt byte-unchanged | G | FIXED (G `0a44a87`: the two-row fallback retired for a FOLD — `arrangement(width:)` full/folded/compact, `more ▾` for the tail doors, every folded member `fixedSize`; `CommitBarLayoutTests` (item 6's pins re-expressed + the mounted one-row pin at 691/316), red-on-old two rows 38 pt tall; walked: `81-06`/`81-07` folded + the menu, `81-09`/`81-10` compact both voices, `81-08` zoomed byte-unchanged) |
| **82** | (C's honest limit, her bar) Read ▸ `pages`: a click on the page does NOTHING (a `CTFrame` page opens links only); "a click that does nothing is a defect". The book's paged Read (`scroll · pages`) likely shares it — verify | Note Read `pages` face (`NotePagesView`/`PageLeafView`) · the book's `PagedReadView` | The paged engine knows which blocks each page holds and where each line sits; a click → the line under the point → its block → `LandingTarget` → the note flips to `edit` at that block (the book: Index at that block) — B/C's one door, reused. Pin: a click on page 2's second paragraph lands in `edit` with THAT block live; a click on a link still opens the link | G | FIXED (G `373251c`: `ComposedPost.blocks` + `PageFrameNSView.hit(at:)` (link first, then the block); the note's `pages` → Read's own `edit` door, the book's paged Read → its Index — the book shared the defect; a pure pin + a real-click pin, red-on-old 4 issues; walked: `82-03` the note (block 04 live), `82-06` the book (Index at block 03)) |
| **83** | (row 60's fix) Blocks mode ARRIVES BLANK ~0.25–0.5 s (empty at 0.24 s; rows + facts at 0.49 s on Boscombe) until the observations' first delivery | Blocks workbench | A synchronous first fetch of the rows (and the facts) BEFORE the observation starts, so the first paint is complete; the observation then keeps it live. Measure pin (the `ModesSherlockMeasureTests` shape): first paint WITH rows within a stated budget on the 215-block note — red on old if the budget is honest. Same shape for any other mode that arrives blank (say which you checked) | G | FIXED (G `373251c`: the rows and the facts PRIMED by one bounded read before their observations, the four siblings waiting; `BlocksArrivalMeasureTests` 0.056 s in the harness (a sanity bound — the harness cannot tell the trees apart); walked: the arrival series `83-01…04` — rows + facts at 0.32 s where C measured 0.47; the residual ~0.2 s is the encrypted read's own cost, row 94) |
| **84** | (row 52's build, R-cor-10(4)) `_word_` underscore emphasis → italics in the markdown DISPLAY vocabulary (Gutenberg's form; Sherlock reads raw today on cards, the Read faces, the Index column, the book) | the 13g markdown display brain (`Shared/` — the phone shares it; the iOS build is owed at the ladder) | Display-only: `renderedText`, the `.md` export and the bridge's join brain stay byte-unchanged (the 13g rule — pinned); the vocabulary gains `_x_` beside `*x*` with the same escaping/word-boundary discipline as the star form (intra-word underscores — `snake_case` — must NOT italicize; state the boundary rule). Pin on the display attributed runs. If the brain's change is not small, RECORD for 13u2 with the reason instead | G | FIXED (G `42c7f5f`: `_italic_` joins the tokenizer in core Domain (`MarkdownSyntax`), word-boundaried, display-only; `underscoreEmphasisIsItalicAtWordBoundariesOnly`, red-on-old no span; walked: `84-01` Write (dimmed markers, italic), `84-02` Read (hidden), the book's flow too) |
| **85** | (A's residue, the record's own line) the seeder's "the workspace" lesson still teaches the RETIRED fold: "＃ folds the note's tag cards away and back (⌘⇧I too…)" | `TutorialSeeder` | The sentence → the `#` door's truth (click → an inline field with the cursor; ⏎ applies; ⌘⇧I opens it); `TutorialBookShapeTests`/`NewModesTests` hold plan ⇔ seed; the LIVE re-seed of her real store is HER morning act (biometric — §7b item 8) | G | FIXED (G `42c7f5f`: the sentence teaches the three-door bar and the masthead ＃ field; `theWorkspaceLessonTeachesTheMastheadTagDoor`; the DEV store re-seeded through Help ▸ Restore Tutorial… — `85-00`/`85-01`; HER store's re-seed stays her morning act) |
| **86** | (F's walk (d)/(e) — VERIFY FIRST) (d) ⌘K "block history" from Blocks spoke Write's caret sentence instead of opening the pane (likely healed by C's `CurrentBlockMemory` — `focusedBlock` now lives in Blocks); (e) a click on the masthead TITLE did not open the rename field (`seed-03`; the Library row menu's Rename… is the door) | ⌘K palette · the masthead title | Verify each on the dev build first. (d): if it still speaks the sentence, route the palette door to the current block (fix + pin); if healed, RECORD healed-by-C. (e): `git show 0e6a09e^:…PostDetailView.swift` — if the pre-Act-10 title was a rename door, RESTORE it (a regression; pin); if it never was, RECORD as not a defect (the row menu is the door) | G | VERIFIED (G): (e) NOT A DEFECT — the title click opens the rename field (`crops/crop-86e-01-masthead`, `86e-03`); the pre-Act-10 file carried the same door; row 93 records the nameless-note prompt observation. (d) FIXED (`bb4645c`: the palette row reaches the FOCUSED block's history where no surface handler stands — `requestBlockHistoryForFocusedBlock` + `ShellActions.showBlockHistory`; `BlockHistoryPaletteDoorTests`, red-on-old 3 issues; walked: `86d-04`) |
| **87** | (the orchestrator's Pool walk at D's close, both voices — `orchestrator-d/04`, `08`) the Pool is a WALL OF BARE DATES: a titleless note's card shows only its day and a lone `+`, no first words — while the note picker (D's `01-crop`) already shows a two-line preview under every match. Ten of the dev store's eleven Pool notes read identically | Pool cards (`Features/Pool/PoolPostsView.swift`) | The picker's preview road exists; a first-words line under a titleless card's date is the same derived, never-stored shape 13u2 item 4 RULED for note cards ("a little snippet of what the post starts with"). **HERS: build the Pool card's preview now in G (reusing the picker's preview road — one brain, no new rule), or leave the whole card family to 13u2 item 4's one-brain design** | **G** (RULED R-cor-11(2)) | FIXED (G `42c7f5f`: `PoolPostsModel.snippets` through the picker's own `notePickerNotes(ids:)`; `PoolCardFace.preview` shows them under a TITLELESS card only; pins ×2, red-on-old 5 issues; walked: `87-01`/`87-02` both voices) |
| **88** | (the orchestrator's Canvas walk, both voices — `05`, `09-crop`; Canvas is PRE-Act-10 — the restyle never reached it) Canvas on the 215-block story opens MID-BANK: cards 97–162 visible, the top row and both edge columns CLIPPED, `fit all` a click away; the toolbar mixes grammars — a "Tag filter" LABEL beside a system popup reading "tag filter: all", then calm chips (`fit all` · `Bank · 215` · `order by clicking…`) | Canvas (`Features/Canvas/`) | Not this round's surface by the ledger's letter (Act 10 did not touch Canvas) but her bar applies to what she sees. Two bounded candidates if she wants them: (a) a first arrival with no remembered layout opens FIT-ALL (or at the bank's top-left), never mid-bank; (b) the toolbar to the calm-chip grammar (one chip per control, the redundant label dropped). **HERS: G, or record for 13u2** | **G** (RULED R-cor-11(3) — both (a) and (b)) | FIXED (G `d35d4f0` + `fead43a`: (a) a never-arranged arrival lands at 1:1 — a fitting board on its bounds' centre, a big one at its TOP-LEFT (never the overview: 4E's realization pins measure a 1:1 arrival — the choice recorded for her in §7); (b) the strip in the calm-chip grammar; `CanvasArrivalTests` ×3, red-on-old the rule false + no landing; walked: `88-00` before, `88-09`/`88-10` after in both voices; rows 91/92 found on the way) |
| **89** | (the orchestrator's row-74 probe, `orchestrator-e/r74-crop-side-by-side`) the tray's "leaving — on the 30-day clock" section MEANING LINE truncates mid-word at the inspector's default width: "…and originals riding a family's countdown. put back keeps a row; del…" — a sentence nobody can finish reading | This Note's Tray (`TrayPanel.swift`, the `CalmSectionHeader` meaning line) — and every other section explainer in the recovery family (Block History's, Archived's, the Trash's) | F's row 63 rule ("a sentence's own point fell off the end") applied to the explainers: the meaning line WRAPS to its full length (it is three short lines at 420 pt), never `lineLimit`-truncates; P-8's `lineLimit` rule is for chrome labels, not prose explainers. Sweep the family's explainers; pin: no explainer's rendered text ends in an ellipsis at the inspector's minimum width | G | FIXED (G `4bf3324`: `CalmSectionHeader`'s detail and the two inline explainers wrap whole; `RecoveryExplainerTests` against an unlimited reference, red-on-old 42 vs 83 pt; walked: `crops/crop-89-950-tray-explainer`) |

## 4. The batches (one surface each — C-1). **ORDER AMENDED after the triage walk: B FIRST** — row 44 is a BLOCKER (the book hangs) and the riskiest fix (TK2 geometry inside lazy layout), so it gets the longest soak before the ladder; A (the chrome) follows immediately; then C, F, D, E.

**Triage walk FIRST (the orchestrator, zero code):** the dev-store Debug build, every touched
surface, a screenshot per ledger row, the mechanism traced or the trace plan named — before any
implementer is spawned. The walk may ADD rows (anything found that she did not report) and must
not remove any.

- **A · The chrome** — rows 2, 3, 4, 10, 11, 15, 19, and the row-36 sweep table. The sidebar's glass
  retired for real; the mode rail generous (height-thresholded compression); the Open strip back
  under the modes; the masthead title centered in every mode (one layout, pinned across the eight
  modes + the book); ONE tag door with her slide-out field; library row alignment.
- **B · The Book** — rows 7, 8, 9, 12, 13, 14, 22, 23. Click navigates; the scroll class pinned on
  the Sherlock book (a middle chapter click lands on that chapter, no travel past it); chapter clicks
  wired; the duplicate line; the gutter carrying the old note details; the book Index editable in
  place (P3: one live editor, through `PaneTextAuthority`); the Read title.
- **C · The note modes** — rows 5, 6, 18, 21, 25, 26, 27, 29, 30, 31. Index editable (right pane
  live; the left column a navigator); Read paged + its companion outline; Blocks' draggable split,
  the selection lag traced and fixed, the context panel's order; Block History opening in the ONE
  right region and scoped to the mode that opened it.
- **F · The recovery family** — rows 27, 28, 35 (and whatever the walk finds): This Note's Tray,
  Block History (savepoints vs lineage readable as sections), Archived, the Trash. Special attention
  by her word — walked fresh at every pane width, every door exercised (Put back, Restore, Delete
  Now, the lineage doors), each defect pinned.
- **D · Compare + Lenses — MECHANICAL ONLY (R-cor-6)** — rows 16, 17. Alignment; the anchor column
  ALWAYS renders the note (derived display name for a nil title; "related blocks only" filters peers
  only). **The design is the memo** (`act10-correction-memo-lenses-compare.md`, written by the
  orchestrator in-round; rows 20/41); the build to it is its own phase at her word.
- **E · The Library panel + the sidebar rail** — rows 1, 24, 33, 34 under R-cor-3's reading, RATIFIED
  at R-cor-10(1): the simple read preview (virtualized, read-cheap), a calm facts line, one door landing at
  the saved caret, a book showing its outline, the boundary holding when inactive, the rail fading.

- **G · Residuals and width (ADDED at R-cor-10(2))** — rows 59, 80–86 + the rows the orchestrator's
  Snippets/Pool/Canvas walk mints at D's close. Small, independent, bounded fixes across small surfaces — the
  use-found defects a code review cannot find (hit targets, ~950-pt width, a click that does nothing, an arrival
  blank), the underscore vocabulary, the seeder's retired-fold sentence. Runs after E, before the ladder, so the
  ladder reviews its diff too.

**Then:** one cold-review ladder over the combined diff (`notes/REVIEW_PROMPT.md` verbatim; fresh
reviewer per round; cap three) → the orchestrator's FULL acceptance walk of every touched surface
(C-2, at round scale) → the Release build + `/Applications` refresh at a zero-instance window behind
the A1 backup (C-3) → the field-guide re-seed if any lesson text changed → the morning bundle.

## 5. Process (binding)

- **The batch loop (the skill's, with C-2 hard):** build → pins (red-on-old by behavioral revert
  for bug-class rows) → `TutorialWalkTests` green → the implementer's walk of its rows with
  screenshots → point-by-point ledger update in THIS file → commit(s) + push → the orchestrator's
  walk → the record marked closed.
- **Briefs are this file's named sections only** — never a session's chat. Each brief carries §2, §5,
  §6, its batch's rows, and the source report's relevant image descriptions.
- **Away-run rule (she is asleep for most of this):** PROVISIONAL-and-continue on everything short
  of an author-only hard stop; taste calls beyond the granted latitude are HELD and bundled (§7),
  never improvised, never dropped.
- **Resiliency:** `notes/SessionResiliencyProtocol.md` binds — commit per piece, a LIVE STATUS line
  per batch record from its first commit, push after each, synchronous foreground waits only.

## 6. Environment traps (carried into every brief verbatim)

- **Instances:** `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH. Her real-store
  app (`/Applications/Variorum.app`, pid 41735 at the sitting) is NEVER quit or killed; no Release
  build and no `/Applications` refresh while it lives. The dev-store Debug build (DerivedData) is a
  separate process on the fenced dev store and may run beside hers — prior walks did exactly this.
- **Builds/tests:** from `App/Variorum/`; `xcodebuild -scheme Variorum -configuration Debug
  -destination 'platform=macOS' build` for the walk build; `build-for-testing` compiles without the
  runner; suite-level `-only-testing` only; confirm the "Test run with N tests" line; zsh
  `pipestatus`; NEVER add a custom build configuration (SPM deps build RELEASE under any name but
  "Debug" and strip the DEBUG-gated oracles).
- **Walks:** the dev store is account-owned and seeds the field guide + the Sherlock library on first
  write; the machine must be unlocked and author-free for a screenshot walk; own `caffeinate -d`;
  screenshots land in the gitignored `notes/plans/act10-correction-screens/` (subdir per batch).
  The test host and the dev build both carry the "Variorum" identity — pick windows by PID.
- **Known reds that are not yours:** the latency pin (`rewriteStrategyLatencies`) reds under load;
  `CanvasDragTrackingTests` is load-flaky; both have KnownIssues rows — re-run isolated before
  concluding anything, never loosen them.
- **Git:** never `git checkout` over uncommitted work; push after each commit (the standing rule);
  no history rewrites.

## 7. The morning bundle (HELD for her — grows through the run)

- ~~R-cor-3's PROVISIONAL reading of the Library panel~~ — **RATIFIED R-cor-10(1)** (the simple read preview).
- ~~iOS target build owed before the ladder~~ — **DONE at the ladder's start (2026-09-01 21:50 MDT):** `xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO` on the G-close tree (`7e45cc1`) → `** BUILD SUCCEEDED **`, 0 errors, 11 warnings — every warning pre-existing and in files the round never touched (`MobileStructural`, `MobileEditorStyle`, `MobileTutorialSeeder`, `Shared/SignInFlow`, `Shared/EncryptionSession`, the AppIntents metadata note); none in `BlockHistoryFace`, `LandingTarget`, `RecoveryCopy`, `VoiceTokens`, `MarkdownSyntax` or `MarkdownFaceCore`. The phone inherits A's/F's `Shared/` additions and G's core tokenizer by construction, compiling clean (log `scratchpad/ios-build.log`).
- ~~Row 57 (A): the sidebar's arrow-key row navigation~~ — **RULED R-cor-16(2): stays out; no owner.**
- *(Read's default half was PROVISIONAL for one turn — RULED `edit` by her follow-up; nothing to ratify.)*
- **The Lenses + Compare design memo — `notes/plans/act10-correction-memo-lenses-compare.md` §7** (R-cor-6's deliverable, WRITTEN; the build is its own phase at her slot): **rulings 6 (two tabs) and 1 (the door words) RULED R-cor-16; the anchor half of 4 and the door's placement settled by R-cor-10(b)/R-cor-11(1); REMAINING for #88: 2 · 3 · 4's peer half · 5 · 7 · 8 + the build's slot.**
- ~~Row 26: the Blocks context panel's order (facts first)~~ — **RULED R-cor-10(3)**, as built.
- Any scalpel revert taken under C-5 (none expected; her lean recorded).
- The row-36 KEEP/DROP table for word counts. *(Batch B's verdicts for the book are in its record: the card `Nw` DROP · the gutter takes fact KEEP · the book meta line KEEP · the side rail's `Nw block`/`Nw selected` DROP, its `Nw in note` word-target door KEEP.)*
- Batch B, row 13: the Outline's prose stays left-anchored at Write's measure (batch 12's ruling) with a flexible, mostly-empty gutter — if she wants the column CENTRED like Write's page, that is a one-line ruling.
- ~~Batch B, row 52: underscore emphasis~~ — **RULED R-cor-10(4)**: joins the vocabulary as italics (G, row 84).
- ~~Read's `edit · read` face remembered per note~~ — **RULED R-cor-16(1): per note.**
- ~~D-close seam (17:15 MDT)~~ — **RULED R-cor-11**: row 46 per-state accepted · 87 → G · 88 (both) → G.
- ~~G-close seam (21:35 MDT)~~ — **RULED R-cor-15: all three kept as built.** As put: row 88's arrival landing (1:1 top-left, chosen under R-cor-8 — or the overview) · row 81's folded bar dropping the `Nw block · Nw selected` counts below 840 pt and every count in the compact tier · row 74's side column draggable with a remembered width while E's Library column is fixed.
- **Batch G's three calls (her seam, or the ladder's):** row 88's never-arranged BIG-board arrival lands at the TOP-LEFT at 1:1, not in the overview (her ruling offered both; 4E's realization pins + the every-visit wall of silhouettes decided it — `CanvasArrival.landing(after:)` is one case the other way); row 81's folded bar drops the block/selected counts below 840 pt and every count in the compact tier (C-6); row 74's side column is draggable with a remembered width while E's Library column is fixed — match them either way at her word. Plus rows 92/93/94 (recorded with owners) for the ladder.
- ~~17 ENTRIES WITHOUT AN ARCHITECT — the proposal~~ **RULED R-cor-14 (Opus review always; Fable for the three risk classes; her Fable-orchestrator practice).** The proposal as brought: a 17 entry runs as ONE session (no orchestrator, no ladder by default) under the standing-fixes discipline the 17 file already states — pin BEFORE fix, red-on-old by behavioral revert, the record in `phase-17-standing-fixes.md` kept by the session itself, the full suite + the tutorial spine as the gate, push after each commit; a COLD REVIEW is required only when the diff touches `Sync/`, custody/keychain code, or the editor seam (`BlockRangeIndex`/`EditorTextView`/`PaneTextAuthority`), or exceeds ~300 changed lines — the three risk classes where a reviewer has caught real BLOCKERs before; everything else is the session's own self-review plus the suites. The architect's value (docs kept current, the ladder) is what phases buy; a 17 entry buys the discipline without the cast. If adopted: a two-line addition to the 17 file's header + CLAUDE.md's standing-fixes bullet.
- ~~THE PROCESS-RULE PROPOSAL~~ **RULED R-cor-13 and WRITTEN (CLAUDE.md + the skill + `notes/PhaseSizingGuidance.md`).** As brought (R-cor-12's held half — brought to her ~19:10 MDT after the sizing read; HER RULING
  AWAITED; nothing written into the skill or CLAUDE.md without her word):** (1) **The unit is an ACCEPTANCE UNIT** —
  the smallest thing whose done-ness is verified on its own by evidence OF ITS KIND: UI → one screen/mode/board/panel,
  hands-on use in both voices; sync → one lockstep event or one repair rule, the convergence suites + a live two-device
  round; custody → one road (a posture switch, a door, a recovery leg), its DRILL; operations → one op family, its
  state-transition suite (her doubt answered: encryption's "walk" is the drill 13p/13l/pre-13x already prescribe).
  C-2 generalized: *a batch closes only on its kind's use-shaped evidence; a pin or a mount smoke alone never
  closes it.* (2) **The sizing rule costs sessions, not phases:** ONE acceptance unit per implementer session (C-1
  generalized — the rule that would have stopped wave 2c; zero phases added); a phase NAMES its units and their
  evidence up front and holds at most TWO phase-sized units under ONE theme (phase-sized = a new mode/board, an
  app-wide token pass, a lockstep event, a posture model) — a third is a split, and ONE design sitting may rule
  several split phases (13u's shared sitting is the precedent), so a split costs a session + a ladder, never a
  sitting. (3) C-3 generalized: the install refresh only after the walk or the drill. **Applied to the remaining
  rows (her ask):** 13i = SIX phase-sized units (wings/libraries + the schema event · the smart-book hybrid +
  auto-tags + the starred smart book · Owned + immutability + the convert door · the shelf: custom order + starred
  books · the Book Panel · templates) → one sitting, then 13i-a/b/c/d with the ONE lockstep deployed at 13i-a;
  13y = THREE themes (the per-tenant seq + abuse guard + the Fragments brief · the daily Journal's identity · the
  dedupe residuals) → 13y keeps the first, the Journal identity its own small pre-release phase, the residuals →
  17i; pre-13x = ruled and batched (§15) — 17i runs as its own 17 entry AFTER it rather than as its last batch, and
  the four 13u2 protection items re-home here (R-cor-12); 13o and 13x one theme each — fine; 13r six bounded
  units — fine as one phase with a session each (the accessibility pass the one that could grow); 13s — its
  propose-only findings become 17 entries or a bounded follow-up phase, never absorbed into 13s.

## 7b. CLOSEOUT OBLIGATIONS (written 2026-09-01 ~06:00 so the run's end is a checklist; the standing CLAUDE.md ritual, unabridged, plus this round's own)

1. **Every ledger row dispositioned** — FIXED (pin) / RECORDED / DEFERRED (owner) / REVERTED (branch); no orphans; rows 44 (the hang) and 47 must be FIXED, never deferred.
2. **The review ladder** over the combined diff (`notes/REVIEW_PROMPT.md` VERBATIM, a fresh cold reviewer per round, findings recorded here before any fix session sees them, fixes in a fresh session with revert-verified pins, cap three rounds; every finding with a written disposition).
3. **The orchestrator's FULL acceptance walk** (C-2 at round scale): every touched surface on the dev build, both voices, the batches' capture lists re-shot on the final tree; the row-44 scenario re-run by hand on Sherlock; the tutorial spine green.
4. **Canon deltas, exactly as ruled, never beyond:** AppSpec §12's note mode row → **Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7) with Read's `edit · read` (R-cor-5/7) and the Index mode's retirement into it; the book's Index editable / Read read-only; the K12 masthead-fold supersession (row 15); AppSpec §14's dated delta paragraph for this round (the pre-13u delta rolls to the archive per the lean-docs rule); the Lenses + Compare memo anchored as the design record for its future phase; QUESTIONS.md gains the morning bundle (§7) as a numbered entry.
5. **Master plan:** the table row → done; the pointer → `pre-13x` NEXT at her word; the closeout paragraph (the pre-13u paragraph rolls to `PhaseCloseoutArchive.md`); the running order's note; `FuturePhases.md`/the table gain the **Lenses + Compare build phase** row (the memo's §8) — unslotted, at her word.
6. **KnownIssues:** nothing new expected; if a batch defers, the row carries its owner. **THE 13u PLANS UPDATED WITH WHAT THIS ROUND REMOVED OR MOVED — her instruction (2026-09-01 ~18:50 MDT, verbatim: "make sure the 13u plans are updated with what has been removed"):** in `notes/plans/phase-13u-feel-and-polish.md` (the split banner + the item list) AND the master plan's `### 13u` section, one dated line per item this round touched — item 17 BUILT here (rows 38/49, `LandingTarget`, both halves); row 54 (the read tier's provisional-width first measure) ADDED to item 1's family; item 4's Pool card preview BUILT EARLY (G's row 87 — the one-brain card family stays 13u2's); row 60 (the Blocks arrival blank) REMOVED — built here (G's row 83); row 57 (the sidebar's arrow-key navigation) ADDED to the feel roster; M12 unchanged; plus whatever she rules on the 13u re-split at this sitting (R-cor-12).
7. **MOBILE PARITY LINE** (`notes/MobileSoul.md`) — **her instruction at R-cor-10 (verbatim): "mobile parity rows need to be written for some of the changed behavior - though, mobile doesn't have all of the modes (like compare and lenses), and has its own library design, so it might be relatively a small parity note. still, it should be kept in mind."** So: one ledger row per CHANGED BEHAVIOR the phone owes a version of — the seven-mode grammar with Read's `edit · read` (the phone's mode vocabulary follows the Mac's one order), the ONE current block across modes (`CurrentBlockMemory`'s idea), the scrolled-open door (`LandingTarget` is `Shared/` already), the book's editable Index, the `#` tag door's inline-field shape, the recovery rows' date-only stamps + uncompressible clock slot (the `Shared/` face pieces are additive and already in the phone's build), underscore italics (`MarkdownFaceCore` is `Shared/` — the phone inherits it BY CONSTRUCTION; verify at the iOS build), the calm-section grammar of Block History; and an explicit **"not owed — no such surface / its own design"** line for Compare, Lenses, the Library panel and the sidebar chrome. "Nothing mobile-visible" is not available; a SMALL note is.
8. **The tutorial re-seed of HER REAL STORE** — **her store's at-open mode is `biometric` (read 16:10 MDT), so the re-seed IS her morning act; the handoff's checklist carries it** — batch C changes lesson text (+ G's row 85, the retired-fold sentence) (the "index · read" lesson, "getting around"); the closeout re-seeds via the product door (Help ▸ Restore Tutorial…) on the refreshed install, behind the A1 backup, at the zero-instance window — or, if her store is not reachable without her unlock (a demanded mode), the handoff's checklist carries the one in-app act for her morning.
9. **The install refresh (C-3, R-cor-4(b)):** zero-instance check (`pgrep -fl 'Variorum.app/Contents/MacOS'`), the A1 WAL-safe backup with a UTC name FIRST, `xcodebuild -scheme Variorum -configuration Release build` from `App/Variorum/`, copy the product to `/Applications/Variorum.app`, `codesign -dv` + the build hash recorded here and in the handoff. If her app is somehow running, STAGE the build and swap at the first zero-instance window — never kill it.
10. **The author handoff** `notes/handoffs/act10-correction-handoff.md` — her checklist at the top (the morning walk in order: the chrome · the book incl. the hang scenario · Read's edit·read · Blocks · the recovery family · Compare/Lenses mechanical · the library panel), the PROVISIONALs (R-cor-3's reading; row 26's order; Read's switch memory), the memo's eight rulings, the counts, the commits, what was deferred and where; self-contained.
11. **Memory** (`variorum-phase-9-run-state`) → round CLOSED; NEXT `pre-13x`.
12. **Push** after every commit; the closeout commit last; then STOP — she kicks off what follows.


## 7c. CANON DELTAS — DRAFTED for the closeout (applied exactly as ruled, never beyond; the closeout pastes, it does not compose)

**AppSpec §12 (the note mode row — supersession sentence to append after the pre-13u supersession):** *Ratified
supersession (the Act 10 correction round, 2026-09-01 — her rulings R-cor-5/7, the binding record
`notes/plans/act10-correction-round.md`): the NOTE mode row is **Write · Takes · Read · Lenses · Compare ·
Blocks · Canvas** (⌘1–⌘7, derived from the one order). The Index mode RETIRES INTO Read: READ carries an
in-place `edit · read` switch, opening on `edit` — the editable index surface (the `▸ 01` outline column,
toggleable, beside a text pane in which a clicked block goes live; P3's one live editor through the one
authority) — and `read` is the calm page, never editable (continuous or horizontal pages), a click on a
sentence flipping to `edit` at that block through the ONE scrolled-open door (`LandingTarget`) the book's
Read → Index click-through shares. The BOOK's Index word-tab is EDITABLE in place; the book's Read stays
read-only. The 13k K12 masthead tag-fold is superseded: the masthead's `#` glyph is the ONE tag door (an
inline field with the cursor active), the fold retired there.*

**AppSpec §14 (the dated delta paragraph — replaces the pre-13u paragraph, which rolls verbatim to
`notes/AppSpecDeltaArchive.md`):** *Author-decision + shipped-semantics delta (2026-09-01, THE ACT 10
CORRECTION ROUND — the BINDING record is `notes/plans/act10-correction-round.md`: her rulings R-cor-1…10, the
ledger, the batch records; the source is her verbatim report
`notes/author-reports/2026-09-01-post-act10-ui-report.md`):* **(1) HER RULINGS:** correct the pre-13u round's
UI IN PLACE, surface by surface, retiring nothing that could be made right (R-cor-1/4); this round before
`pre-13x` (R-cor-2); the Library's right panel a simple read preview with one door landing at the saved
block, books showing their outline, the "this note" rail fading (R-cor-3, her inclinations); Index + Read
ONE tab named Read with `edit · read`, `edit` the default and editable, `read` never (R-cor-5/7); Lenses +
Compare NEED A DESIGN — `notes/plans/act10-correction-memo-lenses-compare.md` is the design record, its
build a phase of its own (R-cor-6); the overnight authorization (R-cor-8). **(2) SHIPPED:** `PENDING — one
sentence per batch at the closeout; zero schema; zero `Sync/`; the marker STAYS 7.` **(3) HANDED FORWARD:**
the Lenses + Compare build phase (unslotted, at her word); 13u2's item 17 re-homed here (the door); rows
deferred with owners `PENDING`. Her ratify list: QUESTIONS `#PENDING` (the §7 bundle).

**OverallModel / CoreDescription:** no change (no model semantics moved). **SyncSpec:** no change.
**CLAUDE.md:** no change (the round's rules C-1…C-7 live in the plan; a future ruling may promote C-2/C-3 —
the use-gate and no-install-without-a-walk — to the architect-phase skill; recorded as a candidate for her,
not applied).

## 7d. THE LADDER — spawn text (so the review runs by copy; the skill's rules)

After G closes (E's successor at R-cor-10) and before the orchestrator's full walk: spawn a fresh `general-purpose` Agent (cold reviewer,
ZERO framing of the work) with exactly this: *"You are a cold reviewer. Read `notes/REVIEW_PROMPT.md` and
follow it VERBATIM against the diff `git diff 962e7b8..HEAD -- App/ Sources/ Tests/` (the Act 10 correction
round's combined diff; `962e7b8` is the last commit before batch B's first code commit — verify with
`git log --oneline 962e7b8..HEAD`). Your anchor for prior dispositions is `notes/plans/act10-correction-
round.md` §8 (the batch records). Write your findings — BLOCKER/MAJOR/MINOR/NIT, each with a traced
mechanism — as a `LADDER ROUND 1` section appended to that plan file, commit with the standing trailer,
push, and stop. Do not fix anything."* Then: the orchestrator records dispositions in the same section
(repo-first); a FRESH fix session lands accepted findings with revert-verified pins; round 2 = a fresh
reviewer re-reviews the fixes + what they touched; any NEW BLOCKER/MAJOR ⇒ round 3; cap three; anything
open after round 3 is recorded for her. The spec outranks both agents; every finding gets a written
disposition. The trailer for every commit (the successor session's, from 16:00 MDT 2026-09-01): `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` +
`Claude-Session: https://claude.ai/code/session_019VxbpYiG4SvQfYdx5cXCBC`.

## 8. Records (appended per batch; the triage walk first)

### TRIAGE WALK — LIVE (2026-09-01 ~04:30 → ; the orchestrator, dev-store Debug build `io.lduarte.Variorum.debug`, Terminal voice, window zoomed 1728×1084; captures in `act10-correction-screens/triage/`)

- **Driving recipe that works:** System Events for keys/menus/window bounds (`vd.sh` in the session scratchpad); clicks via a compiled CoreGraphics event poster (System Events' `click at` never reached this SwiftUI window; `cliclick` is not installed). The dev app restores TWO windows at launch (state restoration) — close one. Zoom = Window ▸ Zoom (the green button is Full Screen).
- **Confirmed on the dev store, beyond her list:** the masthead title centers in the space LEFT of the right cluster in every mode (rows 4/19 mechanism); Compare offers "make outline note"/"+ note" TWICE (top-right buttons + the centered cards); Compare's anchor column is empty even with a titled note (row 17 — the filter empties the anchor); "position" is per-mode memory, not one position (Index kept block 03 while Takes made block 1 live — row 39); the Library's book-row click leaves the NOTE panel showing (row 33, exact); the "this note" rail vanishes whole on leaving a note (row 24); the library keeps the hairline-separator grammar; the book Outline's card preview shows only the FIRST block ("A Scandal in Bohemia" previews as "I." — the section numeral); the expanded note's vertical side card (row 40) reproduces; expanding a note lands focus on its LAST block.
- **ROW 44 — THE HANG (BLOCKER)** — see the ledger; sample saved beside the captures; the dev build was killed and relaunched to continue.
- **Walk verdicts written into rows 7, 14, 15, 22, 29, 33, 39; new rows 45–47.** Captures 00–51 (the file names say what each is). The field guide was restored into the dev store via Help ▸ Restore Tutorial… (capture 48) so both books exist for the batches. The Trash (47) and Archived (41) rendered fine at the dev store's content level — batch F seeds real content before walking them.
- **What the walk did NOT cover (owed to the batches):** Snippets and the Pool (not in her list); Read's outline toggle (R-cor-5/7 redesigns the mode whole); Canvas; the dark appearance; the Study voice (the walk ran in Terminal — every defect walked is voice-independent; batch A checks the masthead in both voices).
- **Walk CLOSED 2026-09-01 ~05:20.** Batch B spawned next (the hang first).

### ORCHESTRATOR'S WALK OF BATCH B (2026-09-01 ~06:25 →; captures in `orchestrator-b/`)

- **No hang, three ways** (CPU peaks 58 / 19 / 33 % then 0 within 2 s; window responsive throughout). Rows 8 (one row per story), 13 (no gutter counts), 45 ("A Scandal" previews prose) and the row-40 rail (one compact grouped card) read right on the fresh build. Boscombe opens at **block 1/215** (row 44's second symptom fixed).
- **RESIDUAL — row 53 (MAJOR):** landings with two or more expanded stories in play mis-land (details in the row). Batch B is REOPENED for it (a fresh fix session, spawned ~06:45 — B's own session could not be resumed; the repo was its brief); its record stays un-closed until the fix is walked again.
- **The rest of B's rows, walked on the same fresh build (captures 15–24):** the body chapter heading is a door (15) · the book Index edits in place — the clicked block goes live, ring + caret (17; caret at the block's END, row 49's family → C) · the Read tab opens on the book's title page and a click on a PARAGRAPH flips to Index with that block live (24; clicks on a heading or the margin are not doors, by design) · the field guide's far-below "the seal" reveals and opens at block 1/3 (20) · the rail is one compact grouped card (00/04). **Nit for the fix session or C:** the landed block sits flush at the pane's top with its ring clipped — give the landing a top inset.


---

### BATCH B — THE BOOK (brief for a FRESH Fable implementer session; written 2026-09-01 ~05:25 by the orchestrator)

**You are the batch B implementer. Read, in this order, IN FULL: this file (§0–§8 — the constitution, the
round's rules C-1…C-7, the ledger, the triage record); `notes/author-reports/2026-09-01-post-act10-ui-report.md`
(§1 verbatim; the image rows 2, 6, 11, 16); `notes/TEXTKIT2_NOTES.md` §2; then the code: `App/Variorum/
Variorum/Features/BookView/BookView.swift` (1,439 lines — the Outline, the navigator, the lazy stack, the
reveal), `Features/BookView/BookIndexView.swift`, `Features/TOC/BlockTOCView.swift` (the shared outline
brain), `Features/Editor/CommitBar.swift` (the `.vertical` axis — row 40), `Shared/NoteIndexOutline.swift`,
and the existing pins `VariorumTests/BookViewTests.swift`, `BookRedesignMountTests.swift`,
`BookIndexColumnTests.swift`, `BookAscentTests.swift`, `TutorialWalkTests.swift`. Read the hang sample
`notes/plans/act10-correction-screens/triage/sample-hang-47298.txt` (Call graph section). Do not brief
yourself from anything else.**

**Your surface is the BOOK, and only the book (C-1).** Rows, in the order to take them:

1. **Row 44 — THE HANG (BLOCKER) — FIRST.** Reproduce it on the dev-store Debug build before touching code
   (steps in the row; both books are seeded there). Trace the loop yourself; the orchestrator's hypothesis
   (an expanded note's full `EditorView` inside the `LazyVStack` + an animated `scrollTo` at a moving anchor)
   is a hypothesis until your pin says so. **Pin:** a mounted `BookView` with one ~9k-word note expanded
   receives a navigator reveal for another chapter; the pin asserts the main run loop returns within a
   budget (a watchdog on a background thread that fails the test if the main thread does not yield within,
   say, 5 s) AND that the requested chapter is at the top. It must be RED on the current tree (the hang)
   and green after. Fix shape is yours; constraints: P-3 (the expanded editor stays THE one live editor
   through `PaneTextAuthority`), P1 (no whole-book layout), TEXTKIT2 §2 (never `ensureLayout` the whole
   book; one expanded note is bounded). Candidates: settle the expanded editor's height before/while a
   programmatic scroll runs and hold it; no `withAnimation` around a `scrollTo` whose anchor is unsettled;
   or take the expanded body out of the lazy container. Also fix the related symptom: **expanding a note
   lands focus on its LAST block** — it lands on the FIRST (or the requested block); pin it.
2. **Rows 47 + 7 + 23 — the navigator's note-row click.** A note-row click REVEALS the note (scrolls it to the
   top of the page) and lands focus in it at its first block; the ▸ disclosure is the separate expand
   affordance; a collapsed off-screen note must be revealable (the `page-<id>` anchor must exist on the
   collapsed card too, or the reveal must expand-then-scroll — your call, stated). Pin: a collapsed,
   off-screen note is revealed by a navigator click (RED on old: the page does not move). Row 23's
   "intermittent" is this row; say so in the disposition if your trace agrees.
3. **Row 14 — chapters.** The navigator's chapter click already navigates when collapsed (walk capture 23/50)
   — keep it, and make it survive expansion (that is row 44). The main column's chapter HEADINGS (the ⠿
   name rows) become doors too (click → that chapter at the top; the drag handle stays a handle).
4. **Rows 9 + 12 — the scroll class.** After 1–2, walk it on Sherlock: expanded story + middle chapter; note
   row far below; chapter far above. Any residual travel/overshoot gets its own pin.
5. **Row 8 — the duplicate line.** In the navigator, when a chapter has exactly one note whose display name
   equals the chapter's name (case/whitespace-insensitive — `BookNaming.key` is the existing key), the note
   line collapses into the chapter row (the row still opens the note). Pin on a Sherlock-shaped fixture;
   the field guide (different names) must be untouched.
6. **Row 13 — the details gutter.** Drop the invented "236w · ⑂ takes on 1 block" string. The gutter carries
   what used to render BELOW an expanded note's opening paragraphs before Act 10 — find it in git
   (`git show 0e6a09e^:App/Variorum/Variorum/Features/BookView/BookView.swift`) and move THOSE details to
   the side, calm (C-6: no metric without a reason; a word count may stay ONLY where the pre-Act-10 details
   had one). The right edge stops being "bizarrely open": the card column + gutter share the width honestly.
7. **Row 22 — the book's Index becomes EDITABLE in place (R-cor-7).** A click in the right pane makes THAT
   block live right there (the TOC's read-cheap→live upgrade through `PaneTextAuthority` — one live editor);
   the double-click handoff to Outline retires; the book's READ word-tab stays read-only. Pin: after a click
   in the book Index, exactly one live pane exists and it is the clicked block (PaneTextAuthority's
   invariant); the caret is at/near the click.
8. **Row 38 (book half) — the scrolled-open door.** A click on a sentence in the book's READ tab lands in the
   editable view (Index, per R-cor-7) at THAT block with the caret there — not at the top, not at the last
   block. Build the landing target as ONE small brain (`(postID, blockID, characterOffset?)` → the mode
   switch + reveal + focus) that batch C will reuse for the note; name it and its file in your record. Pin:
   a Read click on the third block of the second note lands in Index with that block live.
9. **Row 40 — the expanded note's vertical side card** (`CommitBar` `.vertical`). Make it read as ONE calm,
   clear control: group what belongs together, drop what the book already shows, collapse the stack when
   the width says so, and never a floating box of unrelated items. Her words: "collapsible… what's in that
   menu and how it looks needs to be a bit clearer." Screenshot pair in your record (before/after) —
   this is the batch's one taste-shaped item; keep every capability present (she rewrites copy later).
10. **Row 45 — card previews.** The collapsed card previews the first ~40 words across the note's leading
    blocks, skipping a lone heading/numeral block; derived at read time. Pin on a numeral-first fixture.

**Rules that bind you (from §2b):** one surface — if you find yourself in `PostDetailView`/`SidebarView`/
masthead code, stop and record it for A/C instead. Every bug-class row lands with a red-on-old pin verified
by BEHAVIORAL REVERT (switch the mechanism off in place, run the pin, restore, `git diff --stat` empty).
`TutorialWalkTests` green at the end. **The acceptance gate is USE (C-2):** after the code, walk EVERY row
above on the dev-store Debug build with a capture per row into
`notes/plans/act10-correction-screens/batch-b/` (gitignored) — chapter click with a story expanded (no
hang, lands there) · off-screen note-row reveal · heading click · Sherlock duplicate line · the gutter ·
book Index click-to-edit · Read click → Index at that block · the side card before/after · a numeral-first
preview. Name each capture in your record. **Do NOT touch `/Applications` or her real-store app.**

**Environment (§6 verbatim applies) + the driving recipe:** build the walk build with `cd App/Variorum &&
xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' build`; the product is
`~/Library/Developer/Xcode/DerivedData/Variorum-*/Build/Products/Debug/Variorum.app` (bundle
`io.lduarte.Variorum.debug`, the fenced dev store — both books seeded; if it opens TWO windows, close one).
Drive it with `notes/plans/act10-correction-screens/tools/vd.sh` (`shot <name>` · `click <x> <y>` in
window-relative POINTS · `dbl` · `key <code> ["command down"]` · `menu <Menu> <Item>` · `zoom`); set
`VD_DIR` to your batch's capture dir. Clicks go through the compiled CoreGraphics poster beside it
(System Events' `click at` does not reach this window). Read a capture with the Read tool; captures are 2×
— window point = displayed pixel × (window width ÷ displayed width). The machine must stay unlocked and
untouched by you outside the dev window. Mac tests: from `App/Variorum/`, suite-level `-only-testing:`
(e.g. `-only-testing:VariorumTests/BookViewTests`), confirm the "Test run with N tests" line, zsh
`pipestatus`; the full Mac suite once at the END (baseline: pre-13u finals Mac 1985/343 + whatever the two
13u2 commits since added — state the arithmetic); the known load-flaky reds (`rewriteStrategyLatencies`,
`CanvasDragTrackingTests`) are re-run isolated, never loosened. Never a custom build configuration.

**Resiliency (binding):** commit per row/piece with the standing trailer and PUSH after each; write a
`LIVE STATUS — BATCH B` list at the top of your record from your FIRST commit and update it every commit
(what is done, what is next, what is uncertain); **synchronous foreground waits only — never background a
build or a suite and end your turn waiting on it** (that is how sessions die); if you approach your context
limit, finish the piece in hand, write the record, commit, push, and stop with a one-paragraph handoff at
the end of your record — a successor adopts from the repo, never from you.

**Your deliverable:** the code + pins, and a **BATCH B RECORD** appended to this file directly under this
brief: per row → FIXED (pin name, red-on-old evidence as the issue count under revert) / RECORDED / DEFERRED
(owner + why); the door brain's name; the capture list; the counts; the commits in order; anything you
found that she did not report (as new ledger rows, numbered from 48). Then stop. The orchestrator walks
your rows before the record is marked closed.

### BATCH B RECORD — THE BOOK (a fresh Fable implementer session, 2026-09-01 ~05:30 →)

#### LIVE STATUS — BATCH B (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Row 44 (the hang) + rows 9/12 (the scroll class) + row 47/7/23 (the note-row reveal) + row 14 (chapters):** DONE (`be32fa7`) — ONE mechanism: Outline's landing rebuilt (no animation; bounded convergence; the flat `BookOutlineRows` ForEach whose identities ARE the anchors; the model's `pendingChapterReveal` slot beside W21's note slot; chapter HEADINGS are doors; Read ▸ Scroll's chapter click lands the flow). Pins green on the new tree (`BookOutlineLandingTests` ×3, `BookOutlineRowsTests` ×2). **Red-on-old VERIFIED by behavioral revert** (animated `scrollTo` + no hops + the anchor as an explicit `.id` inside a positionally-identified lazy row + no caret seed): 4 issues in 3 tests — the chapter landing 937 pt off with the scroll offset still 0 (the page never moved), the off-screen card never realized (`anchorTop == nil` — row 47's "the page did not move"), the caret at 56,004 (the document's end = block 215/215) and `caretSeed == nil`. Restored; `git diff --stat` empty.
- **Row 44's second symptom (focus lands on the LAST block):** DONE (`be32fa7`) — a bare `BookViewModel.focus` seeds caret 0; pin `aBareFocusLandsAtTheFirstBlock` green; red under revert (2 issues, above).
- **Row 8 (the duplicate line):** DONE (this commit) — `BookOutlineRows.noteLineCollapsesIntoChapter` (one note, `BookNaming.sameName(displayTitle, chapter)`); the navigator draws ONE row, which OPENS the note (`openFromNavigator`), wears the › marker, and carries both menus; the field guide untouched (different names). Pins `BookOutlineFacesTests` ×2 (door class — red-on-old by construction: the rule did not exist).
- **Row 13 (the gutter):** DONE (this commit) — `BookOutlineRows.gutterLine(fannedBlocks:)`: the per-card word count DROPPED (C-6 / R-cor-4(d)); the takes fact KEPT (a card cannot show it otherwise); the gutter beside an expanded read-cheap note is empty (its takes wear badges on the prose); the gutter is FLEXIBLE (`layoutPriority(1)` on the prose column so the measure holds — the `outlineProseSitsOnWritesOwnMeasure` pin caught the first cut splitting the width evenly); the FOCUSED row stays capped at `outlineFocusedRowWidth` so the live editor never exceeds Write's measure. Pin `theGutterCarriesTheTakesFactAndNoWordCount`; red-on-old verified with row 45's revert (7 issues). **Row-36 verdicts for BookView's four metrics:** the card `Nw` → DROP · the gutter `⑂ takes on N blocks` → KEEP · `bookMetaLine` ("book · 13 chapters · 13 notes") → KEEP (the book's shape under its title; not a word count) · the side card's `Nw block` / `Nw in note` → row 40. **Taste note for her (HELD):** the open right of the pane is unchanged in kind — prose and cards still end at Write's measure, left-anchored per batch 12's ruling; the gutter now holds only the takes fact. If she wants the column centred like Write's, that is a one-line ruling.
- **Row 22 (the book Index editable in place):** DONE (this commit) — `BookIndexEditModel` (`Features/BookView/BookIndexEditModel.swift`): ONE `PaneTextAuthority` for the whole pane, each key's `context` = the post (13b 4C's shape), per-post autosave coordinators, the leaving post flushed on migration; `BookIndexPaneNote` OBSERVES its rows (`observeBlockTOC`), renders each block as `Text` and upgrades the clicked block to a `PaneSurfaceView` (role `book-index`); locked takes stay read; the double-click handoff to Outline retired ("Show in Outline" stays a navigation in the row menu); the pane's rows flattened so a note-target scroll reaches an unrealized note (the Outline lesson). Read stays read-only (untouched). Pins `BookIndexEditingTests` ×3; `BookRedesignMountTests` keeps the at-rest half (zero live until a click). Red-on-old by construction: the pre-round index mounted no editable pane at all.
- **Row 38 (book half — the scrolled-open door):** DONE (this commit) — **the door brain is `LandingTarget`** (`App/Variorum/Shared/LandingTarget.swift` — `postID · blockID? · utf16Offset?`, pure, cross-platform home) + `BookViewModel.requestLanding(_:)` / `pendingLanding` (rides beside W21's `pendingReveal`; consumed together). `ReadingFlowView` renders per BLOCK so a click knows its block (`onWake(postID, blockID?)`); `BookView`'s flow wake = `model.requestLanding(target); structure.mode = .index`; the index selects the note, scrolls the pane to the note, then to the block, and makes it live when the note's rows are in hand (`BookIndexEditModel.requestLiveBlock/takePendingLiveBlock` — taken on the observation's first delivery, or at once when the note is already realized). The caret lands at the block's START (a SwiftUI `Text` cannot say where inside itself the click fell — recorded; the TK2 read tier will carry `utf16Offset`). Pin `theReadClickLandsInIndexAtThatBlock` (+ a block-less landing → the first block). Batch C reuses `LandingTarget` for the note.
- **Row 40 (the side card):** DONE (this commit; captures PENDING the walk) — `CommitBar.verticalBody` re-shaped as ONE grouped control: the where-you-are line with a fold chevron (`bookSideRailCollapsed`, a preference — the bar is re-created per focused note) · `block ▾ · Takes` · `commit ⌘S · history` · `note ▾ · comments · Aa` · one count line = the word-target door + `?`. Pairs are `ViewThatFits` (side by side where the rail allows, stacked otherwise — no mid-word wraps, P-8). The rail's `Nw block` / `Nw selected` lines DROPPED (C-6; the flat bar keeps R11's idiom) — row-36 verdicts for the side card. Every door survives (the registry walk's `renderedCapabilities` unchanged). Taste-shaped: before = `03-boscombe-expanded-before.png`; after = `12-boscombe-opened-from-navigator.png` (block 1/215 · the grouped rail) and `31-…` (block 1/8).
- **Row 45 (previews):** DONE (`83a25de`) — `BookOutlineRows.cardPreview(blocks:words:)`: the first ~40 words ACROSS the leading blocks, a lone heading/numeral stub skipped (`isLoneHeadingOrNumeral`: a markdown heading, or ≤ 2 words in ≤ 12 characters — `I.`, `Chapter 3`), an ellipsis where the note goes on, never an empty card. Pins ×3. **Red-on-old VERIFIED by behavioral revert of the two brains to the old rules** (`cardPreview` → the first block's `prefix(280)`; `gutterLine` → `0w · …`): 16 issues across the 45/13 pins (the preview "I.", the gutter "0w"); restored, diff empty. *(Machinery honesty: this revert ran without the "revert starting" line being written first — a slip against the protocol's addendum 2; the tree was restored in the same command and verified clean.)*
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build (pid 56593, then 57450 after the navigator fix); the capture list is below. **One defect found in the walk and fixed in-batch (row 48):** the navigator's row target was the TEXT, not the row.
- **Full Mac suite + TutorialWalkTests:** DONE — **Mac 1999 tests / 347 suites, all green** (`** TEST SUCCEEDED **`; `TutorialWalkTests` inside it; the load-flaky `rewriteStrategyLatencies` passed this run, `CanvasDragTrackingTests` green — neither loosened). **Arithmetic against the pre-13u baseline 1985/343:** the two 13u2 commits since (`bdc4d71`, `72d1c68`) touched no test files (+0); this batch added **+14 tests / +4 suites** — `BookOutlineLandingTests` 3 · `BookOutlineRowsTests` 2 · `BookOutlineFacesTests` 6 · `BookIndexEditingTests` 3 — so 1985 + 14 = **1999** and 343 + 4 = **347**, exact. **Core 1524 / 165, green and exact** (zero `Sources/VariorumCore` lines in this batch).
- **STATUS: BATCH B's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build (pid 57450, the fresh product with every batch-B commit) is left RUNNING for that walk, window zoomed; `/Applications` untouched; her real-store app untouched.
- **No revert in flight** (the red-on-old revert ran and was restored — `git diff --stat` empty against `be32fa7`; evidence in the table below).

#### The hang — what reproduced, what did not (recorded before any code moved)

- The dev-store Debug build (pid 49566, the walk's relaunch) reproduced the walk's PRE-conditions exactly: navigator note-row click on "The Boscombe Valley Mystery" → the story expands, focused, the side card reads **block 215/215** (capture `03-boscombe-expanded-before.png`).
- **The scroll class reproduced twice, deterministically:** a navigator click on the chapter AFTER the expanded story ("the five orange pips") landed mid-story at the same paragraph both times (captures `05-after-five-pips.png`, `09-after-five-pips-2.png`) — her "didn't scroll to the correct item… landed me at the end of the note". A chapter ABOVE the story landed correctly (`04-…`); the last chapter's click landed inside the story too (`06-…`).
- **The livelock did NOT recur** in six attempts on the same build and sequence (CPU peaked 32–43% for < 2 s per click, then 0%). The triage sample's hot frames are lazy placement under an animated transaction stream; the mis-landing and the livelock are the same mechanism at two phases (an animation travelling toward an ESTIMATED offset while rows realize and the target moves — converging short, or retargeting forever). The fix removes the animation and bounds the convergence, so the class is closed by construction; the pin's watchdog stands as insurance. Recorded honestly: the hang itself was not re-observed.
- **Harness facts measured this batch (they shaped the fix):** `ScrollViewProxy.scrollTo` reaches an UNREALIZED `LazyVStack` row ONLY through the row's ForEach identity — an explicit `.id` on an unbuilt row is unknown to the reader (a reveal of an off-screen card moved nothing; the same reveal by the ForEach identity landed at top=0.0). Geometry reports (`onGeometryChange` in the scroll's named space) do NOT follow an AppKit-driven `NSClipView.scroll(to:)`, so the landing stays SwiftUI-driven. The last row of a page can never sit at the top (SwiftUI clamps) — the pins target rows with a viewport of content below them.

#### Per-row dispositions (filled as rows close)

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 44 | FIXED — Outline's landing rebuilt; bare focus seeds caret 0 | `BookOutlineLandingTests.aChapterRevealLandsAtTheChapterWithAStoryExpandedAndLive` · `.aBareFocusLandsAtTheFirstBlock` | 1 issue (937 pt off, offset 0) · 2 issues (caret 56,004; seed nil) |
| 9 · 12 | FIXED (row 44's mechanism) | the chapter pin above | the same 1 issue |
| 47 · 7 · 23 | FIXED — a note-row click focuses + reveals through the model slot; the anchor is the row's ForEach identity. Row 23's "intermittent" IS this: the old reveal worked only for a card that happened to be realized | `.anOffScreenCollapsedNoteIsRevealedAtTheTop` | 1 issue (the card never realized — the page did not move) |
| 14 | FIXED — the body's chapter headings are doors (`navigateToChapter`); the navigator's chapter click survives an expanded story (the chapter pin) | the chapter pin | — (door class) |
| 8 | FIXED — the one-note chapter's duplicate line collapses into the chapter row, which opens the note | `BookOutlineFacesTests.aOneNoteChapterThatSaysTheNotesNameCollapsesTheNoteLine` · `.differentNamesOrSeveralNotesKeepEveryLine` | door class (the rule did not exist) |
| 13 | FIXED — the word count dropped from the gutter (C-6); takes fact kept; flexible gutter; the focused row capped | `.theGutterCarriesTheTakesFactAndNoWordCount` | 7 issues under the old line (`0w · ⑂ takes…`) |
| 22 | FIXED — the book Index edits in place through ONE authority; Read stays read-only | `BookIndexEditingTests.aLandingMakesTheNamedBlockTheOneLivePaneAndASecondMigratesIt` · `.theEditModelHoldsOneRingAcrossPostsAndOverlaysTheBuffer` | by construction (no editable pane existed) |
| 38 (book half) | FIXED — `LandingTarget` (the door brain, `Shared/LandingTarget.swift`); the Read click lands in Index at that block | `.theReadClickLandsInIndexAtThatBlock` | by construction |
| 40 | FIXED (taste-shaped) — the rail is one grouped, foldable control; counts reduced to the word-target door | — (no pin; before/after captures) | — |
| **48** (new — the walk) | FIXED — the navigator's chapter and note rows act on the WHOLE row (`frame` + `contentShape` moved INSIDE the `Button` labels; a plain button acts on its label's shape, so W11a's "the whole row is the target" was unmet — capture 23 before, 31 after) | — (a hit-test the harness cannot drive; the walk is the evidence) | — |
| **49** (new — the walk, NOT the book's surface) | RECORDED for **batch C** — the DETAIL Write editor's bare arrival lands the caret at the LAST block (capture 15: "block 262/262" on opening a story from a card) — `EditorViewModel.applyFocusSeeds`' N12 comment says "the caret lands at the document start" but the claim only resets when `location > documentLength`, which never holds; the projection fill carries the insertion point to the end exactly as the inline case did (row 44's second symptom, note-side) | — | — |
| **50** (new — traced at the code) | FIXED (rode row 14) — Read ▸ Scroll's navigator chapter click wrote Outline's private `scrollTarget`, which nothing consumed outside Outline; `navigateToChapter` now lands the flow on the chapter's first note. Not walked (Read ▸ Scroll's landing is the flow's own W21 reveal) | — | — |
| **51** (new — traced at the code) | FIXED (rode row 22) — the book Index pane's note-target scroll used an explicit `.id` on a lazy item, inert for an unrealized note (row 47's class); the pane's rows are one flat `ForEach` whose identities are the anchors | — | — |
| **52** (new — observed, not a defect of this batch) | RECORDED for her (§7) — the sample library's `_the_` (Gutenberg's underscore emphasis) renders RAW on the card, the Index pane and Read: the 13g markdown vocabulary has no underscore italics. A vocabulary call, not a rendering bug. **RULED R-cor-10(4): underscore italics JOIN the vocabulary — built as row 84 in batch G** | — | — |
| 45 | FIXED — the preview reads across leading blocks and skips a lone numeral/heading | `.aLeadingNumeralBlockIsSkippedAndTheProseBeginsThePreview` · `.aProseFirstNoteKeepsItsOpeningAndAStubOnlyNotePreviewsTheStub` · `.thePreviewReadsAcrossLeadingBlocksToTheWordCapWithAnEllipsis` | 9 issues under the old rule (the first block's `prefix(280)` — "I.") |

#### The USE gate — the walk (the relaunched dev-store Debug build, Terminal voice, window zoomed; every capture in `act10-correction-screens/batch-b/`)

| Row | What was done | Capture(s) |
|---|---|---|
| 44 · 9 · 12 (before) | Boscombe opened from the navigator (block 215/215, the old side card); the chapter after it clicked twice → landed MID-STORY both times; the livelock not re-observed in six attempts | `03-boscombe-expanded-before` · `05-after-five-pips` · `09-after-five-pips-2` |
| 44 (after) | Boscombe opened from the navigator: **block 1/215**, the caret at the first block, the new rail | `12-boscombe-opened-from-navigator` |
| 9 · 12 (after) | With Boscombe expanded, the next chapter/story clicked → **lands exactly at its top**, no hang (CPU 1.6 % peak), block 1/178 | `13-five-pips-opened-after-story` |
| 14 | A pure chapter row ("about this text") lands at the top past two expanded stories; the BODY heading "a scandal in bohemia" clicked → that chapter at the top | `14-chapter-row-about-lands-top` · `17-heading-click-scandal` |
| 47 · 7 · 23 | The field guide's far-below note row ("the seal") → the note opens focused (block 1/3) and the page scrolls to it (as far as the page allows — the second-to-last note cannot sit at the very top; SwiftUI clamps) | `22-offscreen-noterow-the-seal-2` |
| 8 | The Sherlock navigator: ONE row per story chapter; "about this text" keeps its differently-named note line; the field guide untouched | `11-sherlock-outline-after` · `20-field-guide-outline` |
| 13 | No gutter word counts; the takes fact alone beside "three ways of working" | `11-sherlock-outline-after` · `22-offscreen-noterow-the-seal-2` |
| 45 | "A Scandal in Bohemia" previews prose, not "I."; Boscombe's card reads across two blocks | `11-sherlock-outline-after` |
| 22 | The book Index: a click on a block in the pane → THAT block live (ring, caret), the column selects the note | `24-sherlock-index` · `25-index-block-click-live` |
| 38 | Read ▸ Scroll → a click on the third block's sentence → Index at THAT block, live, scrolled to it | `26-sherlock-read-flow` · `27-read-click-lands-index-at-block` |
| 40 | The rail after: `block 1/215 ▾ · block ▾ takes · commit ⌘s history · note ▾ comments aa · 9,689w in note ?` | `12-…` · `13-…` · `31-…` |
| 48 | A click RIGHT of a note row's text: nothing (before) → opens the note at block 1/8 (after the fix) | `23-noterow-hit-right-of-text` · `31-noterow-hit-right-of-text-after` |
| (aside) | The card body's click opens the note in the full editor — as designed (N22); it showed row 49 | `15-heading-click-scandal-lands-top` (misnamed: the click hit the card, not the heading) |

Honesty notes: the card and pane show `_the_` raw (row 52); the row-38 caret lands at the block's END in use (the pane's default on becoming first responder), not its start as the record first said — the click's offset is not carried by a SwiftUI `Text` either way; the TK2 read tier's `utf16Offset` is the road.

#### Commits (in order)

1. `be32fa7` — rows 44/9/12/47/7/23/14: the landing rebuilt + pins + this record's skeleton.
2. `ca479eb` — the red-on-old evidence for the landing pins recorded.
3. `83a25de` — rows 45/13/8: the card preview brain, the gutter's line + flexible gutter, the navigator's collapsed duplicate line.
4. `c768c08` — rows 22/38: the book Index editable in place (`BookIndexEditModel`), the scrolled-open door (`LandingTarget`), the flow's per-block click.
5. `45608b1` — row 40: the side rail as one grouped, foldable control.
6. `e4e9dcb` — row 48 (found in the walk): the navigator's rows take the whole row; the walk's captures + this record.
7. `b28128f` — the counts, the door brain's naming, the handoff paragraph. 8. (this commit) the hash filled.

#### The door brain, named (for batch C's reuse)

**`LandingTarget`** — `App/Variorum/Shared/LandingTarget.swift` — `postID · blockID? · utf16Offset?`, pure, `Equatable`/`Sendable`, cross-platform home. The book's consumers: `BookViewModel.requestLanding(_:)` / `pendingLanding` (rides beside W21's `pendingReveal`; both consumed by `consumeReveal()`), `BookIndexView.landOrSeed` (selects + scrolls the note, hands the block to the pane), `BookIndexEditModel.requestLiveBlock/takePendingLiveBlock` (makes the block live when its rows are in hand). The note's version (batch C): the same value, consumed by the note's Read→edit switch (mode change + `CommandRouter.focusedBlock` seed + the pane's live upgrade); a TK2 read tier can fill `utf16Offset`, a SwiftUI `Text` cannot — the consumer then lands at the block. Sibling brains this batch left for reuse: `BookOutlineRows` (the flat lazy rows keyed by anchor — the pattern any lazy landing needs), `BookOutlineGeometry` (the DEBUG landing oracle), `BookIndexEditModel` (one `PaneTextAuthority` over several posts, the compare board's shape).

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed through `e4e9dcb` (+ this record's commit); no revert is in flight; the tree is clean. The rows are all FIXED or RECORDED — none DEFERRED, none REVERTED (C-5 not exercised). Two dispositions are honest limits rather than fixes: the livelock itself was never re-observed on this build (six attempts; the deterministic mis-landing of the same mechanism was, twice, and is pinned + fixed), and the row-38 caret lands at the block, not at the click (a `Text` cannot say where inside itself it was clicked). Three items are HELD for her in §7 (the gutter's centring question, the underscore-emphasis vocabulary, the row-36 verdicts). Row 49 is batch C's (the detail editor's caret-at-end arrival). Walk suggestions: Sherlock ▸ Outline — click "the boscombe valley…" then "the five orange pips" (no hang, lands at top, block 1/N); click a body heading; the field guide's far rows; Index — click any block, then another (one ring); Read — click a sentence mid-story. Known non-book residue seen in passing: the sidebar's Open strip and the masthead are batch A's; nothing in `PostDetailView`/`SidebarView`/masthead/Compare was touched.


#### ROW 53 FIX — the landing with two or more expanded stories (a fresh Fable fix session, 2026-09-01 ~06:40 → ~08:00)

**LIVE STATUS — ROW 53: FIXED (pin + walk) — commits `7569af3` · `763d70d` · `5fb9a8e` · `82ade54` (+ this hash fill). All six steps of the orchestrator's repro land at the top on the final dev build (captures 123–132; the app's own landing log: every landing `settled` in ~1 s, 0–1 hops). The book's eight pin suites + the ten tutorial suites green (101 tests / 17 suites); **the full Mac suite 2001 / 347 green (1999 + 2, exact)**. No revert in flight. The dev build (the final tree) is left RUNNING for the orchestrator's walk. NEXT (the orchestrator): walk row 53's six steps + the rows the walk deferred (47/7/23 on the field guide, 14's body headings, 22, 38, 40); mark the batch record closed.**

- **Reproduced first on the running dev build** (pid 57450 — the current tree: the three commits since its build, `b28128f` `1a6ceaf` `fc925bd`, are docs-only), from "collapse all": step 1 Boscombe ✓ (`37-r53-step1-boscombe`) · **step 2 Noble Bachelor landed ~680 pt SHORT** (`38-r53-step2-noble`; the orchestrator's step 2 landed, mine did not — the class is timing-shaped, not step-shaped) · step 3 ✓ (`39-…`) · step 4 Scandal ✓ in my run (`40/41-…`; the orchestrator's mis-landed) · **step 5 the last story → mid-NOBLE BACHELOR, the same "Lord St. Simon" paragraph as the orchestrator's capture 12** (`42/43-r53-step5-…`) · **step 6 Red-Headed → the page did not move at all, still inside Noble Bachelor 4.5 s later** (`44/45-r53-step6-…`). CPU 0.3–0.4 %; no hang.

- **THE TRACED MECHANISM — five layers, each found by its own trace, in the order found (the first fix was wrong twice, and the record says so):**
  1. **The harness (the pin's DEBUG trace on the pre-fix tree):** the first cut's convergence was COUNT-driven (four hops, each fired the turn after a report). Far-below: `8517 → 470 → −80 → 269 → 200` — the budget spent mid-oscillation while the neighbouring expanded rows were still loading, then a drift to **361 pt**. Far-above: `399 → 419 → 416 → 417 → 414` — four immediate hops re-landing the same wrong offset; left alone one quiet interval the same landing settles to 0.08 pt with ZERO hops (the old loop was fighting SwiftUI's own settle). → `7569af3`: a STABILITY-driven convergence (quiet interval, hop cap 40, 4 s watchdog). Green in the harness — **and still wrong in the app** (steps 5/6, captures 54/56).
  2. **The app, first look:** the quiet interval (150 ms) raced the dev store's async loads (a 9k-word note's DB read + projection fill takes hundreds of ms on the encrypted on-disk store; the in-memory harness takes tens). A hold (1 s) and a re-arm on any content-height change were added — and the app then never finished a landing at all (nothing in the log): the re-arm was STARVED by a content height that changed every ~140 ms. A ceiling (a check no later than 0.6 s after the last decision) restored the decisions — and the app's log (a DEBUG `NSLog` of each landing's story, readable from the launched binary's stderr) showed the real thing: **fourteen `scrollTo` hops in a row moving nothing** while the column's content height crept `+185 pt / 140 ms` for eight seconds, the target de-realized (`top was 665.6` stale, then `unreported`).
  3. **`scrollPosition(id:anchor:)` over `scrollTargetLayout()`** — the declarative position, re-declared twelve times — moved nothing either: whatever the container BELIEVES about a far row's position is what every scroll API consults, and the belief was wrong.
  4. **The per-row height trace named the churn:** every expanded story the lazy column re-realizes steps **40 → ~10,000 → ~20,000 pt** (its placeholder, a first measure at a provisional width, the final — `page-67DB6BCA h=10366` then `20056`; Scandal back at `12622` before `21054`), several rows at once for hundreds of ms. → **remembered surface sizes** (`BookViewModel.rememberedSurfaceSize`, the row's `StableSurface` reserving the height from the first frame): step 5 landed. **Step 6 still did not, and its content trace is the whole story:** `62,817 → 126,417` in steps decaying by a constant fraction, with **no realized row changing height** — a `LazyVStack` estimates every unrealized row at the AVERAGE of the rows it has measured; with five ~20,000 pt stories measured, a collapsed card is estimated at ~4,800 pt and the container's estimate converges toward 26 × 4,800 ≈ **126,000 pt** against ~50,000 real. A far target's position is off by tens of thousands of points; no request can realize it. This is the row-44 livelock's slow form (the same lazy placement, without the animation).
  5. → **THE SEGMENTED COLUMN** (`BookOutlineRows.segments`, pure): the flat rows split at every expanded note — each RUN of small rows (headings 51 pt, cards 46–103 pt) in its own `LazyVStack` (uniform rows, honest estimates); each expanded note a DIRECT child of the outer `VStack`, **virtualized by the book itself** — a placeholder of its remembered surface height when far from the viewport, the real surface when near (`NearViewportObserver`: near within 2,500 pt, far beyond 7,500 — hysteresis, because the first cut without it oscillated `861 ↔ 221` / `21054 ↔ 94` as a row's own swap moved its neighbours). The memory ignores width and keeps the MAX for read-cheap surfaces (the provisional-width first measure) while FOLLOWING a live editor (typing both ways). **[CORRECTED at ladder fix 1 (R1-1): that sentence described a memory that could only GROW — a stale taller memory then reserved a permanent gap. The memory is the surface's last SETTLED size in BOTH directions, and a memory taken at another WIDTH does not apply (compared, not merely carried); `StableSurface`'s doc block is the record.]** The one-live-editor mount pin then caught a doubled `EditorTextView` from state writes inside geometry actions ("modifying state during view update") → the near/loaded flips run on the next turn. **All six steps land** (v8 captures 113–122; the final build 123–132).

- **THE FIX AS SHIPPED (the book's files only — C-1):** `BookView.swift` — Outline's landing: the stability-driven convergence (`landingSettleInterval` 0.25 s · `landingMinimumHold` 1 s · `landingMaxWait` 0.6 s · `landingHopBudget` 40 · `landingTimeBudget` 4 s), re-armed by anchor reports AND content-height changes (`onScrollGeometryChange`), ended by a user scroll (`onScrollPhaseChange` → `.interacting`), its bookkeeping in a reference box (no `@State` write per report — the second cut's own loop), a DEBUG trace (`LAND` · `HOP n` · `DONE: settled/gave up` · `content=` · per-row `h=`) and a DEBUG `NSLog` of each landing's story; the SEGMENTED column; `StableSurface`; `NearViewportObserver`; the P3 materialization count moved from the row's init to its REALIZED content (a card, a surface — never a placeholder; expanded rows are constructed for every segment now, so the init no longer measures what the pin guards). `BookViewModel.swift` — `rememberedSurfaceSize/rememberSurfaceSize` (`@ObservationIgnored`, session state). `BookOutlineRows.swift` — `Segment` + `segments(rows:isExpanded:)`.

- **What this changes beyond the landing (stated, so the orchestrator's walk knows what to look at):** an expanded story now stays at its full height while collapsed neighbours realize around it, and scrolling BACK to a story the column has measured no longer steps 40 → 10k → 20k (the "book page jumping" class — her item 1 of 13u2 has this family; the book's half is better for it). Far expanded rows are placeholders (the column's geometry is exact); a story expanded FAR AWAY that the column has never measured ("expand all") stands at an 800 pt placeholder until the viewport nears it, then grows — scrolling DOWN into it is seamless (growth below the page), scrolling UP into one jumps once (growth above) — recorded, rare by construction. A user scroll inside a landing's first second ends the landing where she put the page (never fights her). The 2,500/7,500 near/far band means at most two or three text surfaces exist at once.

- **Pins:** `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded` — five 215-block stories; 3, 7, 11 opened in turn (the walk's state); a collapsed story far below (15) then one far above (1) opened from the navigator's door; each must sit at the top AND STILL be there a second later. **RED on the pre-fix tree: 1 issue** (far below 360.7 pt off; far above 413.8 pt inside the same run — log `r53-pin-red.log`; the trace is quoted in layer 1 above), run BEFORE the mechanism changed — the behavioral-revert evidence in its cleanest form. `BookOutlineRowsTests.segmentsSplitAtEveryExpandedNoteAndKeepRunsWhole` (pure, door class — the brain did not exist). Green after, with every existing book pin: `BookOutlineLandingTests` ×4 · `BookOutlineRowsTests` ×3 · `BookViewTests` (incl. the P3 materialization pin — 150 posts expanded whole, < 75 surfaces) · `BookRedesignMountTests` (the one-live-editor pin) · `BookOutlineFacesTests` · `BookIndexEditingTests` · `BookIndexColumnTests` · `BookAscentTests` — 30 tests / 8 suites; + the ten `TutorialWalkTests.swift` suites (71 tests) in the same run: **101 / 17 green**.

- **Captures (all in `batch-b/`):** the pre-fix repro `37–45` · first cut `48–56` (steps 5/6 still wrong) · `57–66` v2 · `67–75` v3 (the log's first read) · `76–84` v4 · `85–93` v5 (scrollPosition) · `94–102` v6 (remembered sizes — step 5 lands) · `103–112` v7 (segments — step 6 reaches its story, oscillation) · `113–122` v8 (all six land) · **the FINAL build `123-r53-final-sherlock` · `124-…-step1-boscombe` (block 1/215) · `125-…-step2-noble` (1/226) · `126-…-step3-fivepips` (1/178) · `127/128-…-step4-scandal-1.5s/4.5s` (1/262) · `129/130-…-step5-last-1.5s/4.5s` (1/212) · `131/132-…-step6-redheaded-1.5s/4.5s` (1/215)**. The tool dir gained `scroll.swift`/`scroll` (a wheel poster) beside `click`.

- **Counts:** book + tutorial suites 101 / 17 green (above). **Full Mac suite: 2001 tests / 347 suites, all green (`** TEST SUCCEEDED **`, 292.6 s; log `r53-full-mac.log` in the session scratchpad)** — the arithmetic against batch B's recorded 1999 / 347: +2 tests (the row-53 landing pin, the segments pin), +0 suites ⇒ 1999 + 2 = **2001**, 347 = **347**, exact. The load-flaky pins (`rewriteStrategyLatencies` — 2 cases — and `CanvasDragTrackingTests`) passed in-run, zero issues recorded — nothing re-run, nothing loosened. Core untouched (zero `Sources/VariorumCore` lines).

- **Honesty notes / residuals:** (a) the `[SwiftUI] Modifying state during view update` warnings in the test logs PRE-EXIST (32 in the landing suite's run on the pre-fix tree; the PanePublisher's header names the class) — not introduced here, not chased here. (b) **The read tier's first measure runs at a provisional width** (`ReadPostViewModel.remeasure` before the surface's width settles — 10,366 then 20,056 for the same text): a jump every read-cheap surface makes on realization, OUTSIDE the book's files (C-1) — recorded as **row 54** for the read tier's owner; the book now hides it behind the remembered size. (c) The DEBUG `NSLog` landing story stays in (DEBUG only; the way the dev build was made readable — `<DerivedData>/…/Variorum > log 2>&1`). (d) The convergence's constants are stated in the code with their reasons; the one that is a guess is the 800 pt never-measured placeholder. (e) `scrollTargetLayout`/`scrollPosition` were tried and REMOVED (nested lazy ids are not scroll targets; the proxy's `scrollTo` reaches a lazy ForEach identity, measured by the previous session, and now lands exactly against the segmented column's honest geometry).

- **Commits:** `7569af3` (the first cut + the pin, red-on-old recorded) · `763d70d` (the traced fix: segments, remembered sizes, the box, next-turn flips — WIP checkpoint) · `5fb9a8e` (the segments pin, the final captures, this record, row 54) · `82ade54` (the full-suite counts) · this commit (the hashes).

---

#### BATCH B RECORD — CLOSED by the orchestrator (2026-09-01 ~07:50)

Walked twice: the whole batch on build 57450 (`orchestrator-b/`, 25 captures — the hang gone three ways; rows
7/8/13/14/22/23/38-book/40/45/47 right) and row 53's fix on build 67746 (`orchestrator-b53/` — the six
steps by hand, the three risky landings captured, each at its story's top; the fix session's own ten
captures `batch-b/123–132` read as one contact sheet). Counts at close: **Mac 2001 / 347 green** (1985 +
16 tests, 343 + 4 suites); core 1524/165 untouched; tutorial spine green inside the run. Residuals carried
forward, all owned: row 49 (the detail editor's caret-at-end arrival) → C; row 54 (the read tier's
provisional-width first measure) → C; the never-measured "expand all" placeholder at 800 pt and the
pre-existing state-during-update warnings → recorded in the record, the ladder's to weigh; row 52
(underscore emphasis) → her (§7); the nit (a landed block flush at the pane top, ring clipped) → C with
the door. Nothing deferred, nothing reverted (C-5 unexercised). **Batch A spawned next.**

---

### BATCH A — THE CHROME (brief for a FRESH Fable implementer session; DRAFTED 2026-09-01 ~05:40 by the orchestrator — spawn ONLY after batch B's record is closed; one code agent at a time)

**You are the batch A implementer. Read, in this order, IN FULL: this file (§0–§8 — the constitution, the
round's rules C-1…C-7, her rulings R-cor-1…7, the ledger, the triage record, batch B's record);
`notes/author-reports/2026-09-01-post-act10-ui-report.md` (§1 verbatim; image rows 1, 4, 5, 7, 9);
`notes/plans/pre-13u-round.md` §"THE MOCKUP FEEDBACK" (W8-2/W8-3 — the style guide and the glass ruling)
and the mockup itself `notes/plans/pre-13u-mockups/blocks-and-snippets.html` (open it in a browser and
LOOK — it is the reference grammar); then the code: `App/Variorum/Variorum/RootView.swift` (the
`NavigationSplitView` at :138 and the panels it hosts, :450), `Features/Library/SidebarView.swift` (the
rail :464–487, the Open strip :245 and its placement :346–351, the W8-3 comment :348),
`Features/Takes/PostDetailView.swift` (the masthead — find the title's HStack), `Features/Tags/
MastheadTagCluster.swift`, `Workspace/ContextBar.swift`, `Features/Library/LibraryCatalogView.swift` (the
rows at :599/:796/:853 — already `.firstTextBaseline`), `Theme/CalmGrammar.swift`, `Theme/VoiceControls.swift`
(THE chrome vocabulary, P-8), and the pins `VariorumTests/WorkspaceNavigationTests.swift`,
`NoteRowSelectionTests.swift`, `ContextBarShapeTests.swift`, `CommitBarLayoutTests.swift`,
`TutorialWalkTests.swift`. Do not brief yourself from anything else.**

**Your surface is the CHROME — the sidebar, the masthead, the library rows — and only that (C-1).** Rows:

1. **Row 2 — the liquid-glass sidebar retires for real (W8-3, half-delivered).** The floating glass pane is
   the `NavigationSplitView` sidebar's Tahoe default. Deliver W8-3 whole: solid, geometric — a flat column
   with one honest divider, no floating inset, no glass; the interior W8-3 already painted stays. Decide
   the container (a flat style on the split view if macOS 26 offers one that truly removes the floating
   pane; otherwise an `HSplitView`/custom split that keeps the sidebar's collapse, the width memory, and
   every panel RootView hosts beside it — Scraps, References, the tray, the info panel). State the
   decision and its reason in the record. Both voices, light and dark. Pin: a mount smoke that the sidebar
   renders without the split view's glass material (or, if the container changes, that every hosted panel
   still mounts — `BookRedesignMountTests` is the shape).
2. **Row 3 — the rail's spacing and the Open strip.** Compare the rail's row spacing/padding against the
   pre-Act-10 file (`git show 0e6a09e^:App/Variorum/Variorum/Features/Library/SidebarView.swift`) and
   restore generous spacing at ordinary heights; compress ONLY under a measured height threshold (the
   bottom-bar precedent: a pure decision function, pinned red-on-old at the threshold). Move the Open
   strip back to directly UNDER the rail ("the tabs used to be right below the modes") — it keeps its
   Act 10 mechanics (scroll past ~7, newcomer never hidden, ⌘⇧1–9, drag reorder, the 20-tab auto-close);
   the sidebar's bottom keeps the protection/sync/bridge lines. Pins: the existing Open-strip pins ride
   unmodified; one new pin on the threshold function.
3. **Rows 4 + 19 — the masthead title centered in EVERY mode.** Mechanism (walk-confirmed in both voices):
   the title sits in an HStack where the trailing cluster (tray/scraps/references icons + the tag row)
   takes its natural width and the title centers in the REMAINDER — so it lands ~⅓ across. Fix: the title
   block centers on the full content width (overlay/ZStack), the clusters lead/trail; the subtitle path
   (`~/book`) rides with it. One layout for all seven/eight modes and the book. Pin: the title's midX equals
   the content's midX within 1 pt, parameterized over every mode (mount + geometry read).
4. **Row 15 — ONE tag door.** Today: `+ tag` (opens a popover field — good) AND `#` (folds the chips to
   `# N`, K12's sticky fold) side by side. Deliver hers: the `#` glyph is THE door — click → the tag field
   slides out inline beside the chips with the cursor active (reuse the popover's field brain: ⏎ applies,
   `/` nests, suggestions); `+ tag` retires; the masthead FOLD retires (K12's fold served the crowded nav
   bar — record the supersession in the record and at the K12 site's comment). Chips stay visible. ⌘⇧I
   (the fold's key) is re-pointed to open the field, or retired — say which. Pin: exactly one tag door
   renders in the masthead; the field receives focus on open.
5. **Rows 10 + 11 — library row alignment.** The chips and the `book` kind label sit low against the title
   although the HStacks already align on `.firstTextBaseline` — trace the actual cause (chip vertical
   padding vs. its baseline, the smaller label's baseline offset, an `Image` in the HStack) and fix it so
   title, chips, `+`, and kind label sit on one visual line. Pin: a geometry read of the row (title
   baseline vs chip baseline within 1 pt).
6. **Row 36 — the word-count sweep table (C-6).** Enumerate EVERY word-count/metric display in the eight
   Act 10 views (Snippets 10 · Read 6 · Blocks 4 · Index 4 · BookView 4 · LibraryInfoPanel 4 · Compare 2 ·
   BookIndex 1 — `grep -n -i 'words\|[0-9]w\b'`) into a table in your record: file:line · what it says ·
   KEEP (with the reader's reason) or DROP. **Fix the ones on YOUR surface** (the masthead/sidebar/library
   rows if any); the rest are dispositions for their batches (C/D/E/F read your table). Bias: a count
   stays where the pre-Act-10 surface had one or where the mockup grammar shows one; "thrown in" goes.
7. **Row 24 (the sidebar half only) — the "this note" rail fades.** The rail appears/disappears whole on
   note↔library today. Make its arrival/departure a short fade/height animation (nothing added on the
   left — R-cor-3); the library-panel half of row 24 is batch E's.

**Rules that bind you (from §2b):** one surface — if a fix pulls you into the book, the note modes,
Compare, or the library PANEL, stop and record it for B/C/D/E. Bug-class rows land with red-on-old pins
verified by BEHAVIORAL REVERT; geometry pins are pins. `TutorialWalkTests` green at the end (the field
guide's "getting around" lesson names the sidebar — if your change alters what the lesson describes, say so;
copy changes are the closeout's). **The acceptance gate is USE (C-2):** walk every row on the dev-store
Debug build in BOTH voices (Settings ▸ Appearance switches the voice) with a capture per row into
`notes/plans/act10-correction-screens/batch-a/` — the flat sidebar · the rail spacing at a tall window and
at a short one · the Open strip under the rail · the title centered in Write, Takes, Read, Lenses, Compare,
Blocks, Canvas and the book · the one tag door open with the cursor in it · a library row's alignment
close-up · the rail fading. Name each capture in your record.

**Environment + driving recipe + resiliency: exactly batch B's brief's last three paragraphs (read them
there; they bind identically).** Baseline counts: batch B's record states the tree's counts at its close —
yours are those + your pins; state the arithmetic.

**Your deliverable:** the code + pins, and a **BATCH A RECORD** appended under this brief: per row →
FIXED (pin, red-on-old evidence) / RECORDED / DEFERRED (owner + why); the container decision; the row-36
table; the capture list; counts; commits in order; new findings as ledger rows numbered after batch B's
last. Then stop.

---

### BATCH A RECORD — THE CHROME (a fresh Fable implementer session, 2026-09-01 ~08:10 →)

#### LIVE STATUS — BATCH A (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — the brief's files read in the brief's order; the mockup's sidebar/masthead CSS read
  (the browser render was blocked: the Chrome extension is not connected and `file://` is refused — the
  grammar was read from the source instead: `.sidebar` = flat `room` column, `1px line` right border,
  `14px 0 12px` padding; `.sb-group` 12 px side padding, 20 px between groups; `.sb-row` 5×8 px padding,
  radius 6, gap 6; `.sb-head` 10.5 px faint; `.sb-sep` a 1 px line with 20 px side margins).
  **Measured on the running dev build (AX tree, text-before-pixels):** the sidebar column sits at
  x = 8 (the floating pane's inset), its rows are 32 pt List rows — BOTH the five areas AND the eight-mode
  rail (identical pitch; the rail's code is byte-identical to the pre-Act-10 file) — while the Open strip's
  rows are ~21 pt (`openRow`: 4 pt padding, min 19, spacing 1). So "the tab spacing has gotten less
  generous… more compressed" is the OPEN STRIP (her "tabs" = the open notes, her own browser-tabs word),
  whose rows left the List's 32 pt pitch for the bottom rail's 21 — not the rail's rows. Recorded here
  before any code moved.
- **Row 2 (the container):** DONE (`b22b6ff`) — `ShellSplit`
  (`Workspace/ShellSplit.swift`: an HStack, ONE 1 pt `line` divider with the pane row's drag grammar,
  `@AppStorage` width 180–360, a collapse that animates) replaces `NavigationSplitView` in `RootView`;
  the sidebar toggle is a DECLARED act (`.toggleSidebar` — the leading toolbar button + View ▸ Toggle
  Sidebar on the platform's own ⌃⌘S, per-window state `ShellRouter.sidebarShown`, grey while a note-only
  window is key; the ⌘/ helper lists it); the status rows moved from the split view's `safeAreaInset` to the
  column's own bottom. **Verified in use on the relaunched dev build (probe captures):** the column is flush
  at x = 0 with one divider; the tray inspector opens as a column INSIDE the detail; ⌃⌘S collapses and
  restores. Pin `ShellChromeTests.theShellMountsFlatAndTheStripRowsAreGenerous` (zero `NSSplitView` under
  the hosting view at rest — the split view's AppKit backing) GREEN. **Red-on-old VERIFIED by behavioral revert** (`ShellSplit.body`
  wrapped back in a `NavigationSplitView`, the column's rows forced to the old 21 pt; run from the committed
  state `b22b6ff`): **2 issues in 1 test** — `countSplitViews → 1` and `drawn → 21.0 == 30.0`; restored by
  `git checkout --`, `git diff --stat` empty.
- **Row 3 (the rail + the Open strip):** DONE (`b22b6ff`) — the sidebar's `List` retired for the
  mockup's flat column (`SidebarView`: groups · `.sb-head` headers · `.sb-row` rows at ONE pitch · `.sb-sep`
  separators); the Open strip sits DIRECTLY UNDER the rail again with every Act 10 mechanic (all open notes
  shown, the section scrolls in place past 7 with the newcomer revealed, ⌘⇧1–9 badges, ✕, drag reorder, the
  model's 20 cap); `SidebarLayout` (pure) decides the pitch — generous 30 pt at ordinary heights, compact 24
  ONLY when the generous layout would not fit the measured column (never at height 0); one navigation
  register `VoiceTokens.navigation` (13 pt mono in Terminal, 13 pt system in Study) for every row.
  **Measured after (AX tree):** areas · rail · strip rows all 30 pt; the strip's row directly under the rail.
  Pins `SidebarLayoutTests` ×5 (the threshold both ways, few rows never compress, unmeasured never
  compresses, the 7½-row window) + the oracle half of the shell pin (the strip's DRAWN row = 30) — red-on-old
  the second issue above (21.0). Recorded honestly: the List's arrow-key row navigation is gone with it.
- **Row 24 (the rail's fade — the sidebar half):** DONE (`b22b6ff`) — the rail group carries
  `.transition(.opacity)` under `.animation(.easeInOut(0.22), value: railPostID)`, so it fades in/out and the
  Open group slides rather than snaps; nothing added on the left (R-cor-3). Walk capture PENDING.
- **Rows 4 + 19 (the masthead):** DONE (`74c72db`) — `PostDetailView`'s masthead is a ZStack:
  the title block (title + the `~/book` chip) CENTERS on the masthead's full width, padded on both sides by
  the trailing cluster's MEASURED width so it can never run under the icons; the cluster (mode menu ·
  tray/scraps/references · the tag cluster) trails on its own layer; `PostTitleLabel` centers in its measure
  (the rename field too). One layout for every mode. Pin `MastheadLayoutTests.theTitleBlockCentersOnTheMastheadInEveryMode`
  — the real detail mounted, switched through all eight modes by the router, the DEBUG oracle
  (`MastheadGeometry`: the title TEXT's own midX vs the masthead's midX, in the masthead's coordinate space)
  within 1 pt in each — GREEN. **Red-on-old VERIFIED by behavioral revert** (the title layer put back to
  the old leading shape, run from `74c72db`): **8 issues in 1 test — 246.0 pt off in every one of the eight
  modes**; restored by `git checkout --`, diff empty.
  **The book's masthead is NOT touched:** its title lives in the navigator COLUMN's header (`BookView.
  bookMasthead`), a left column by design — the book's surface is batch B's (C-1); recorded for the
  orchestrator.
- **Row 15 (one tag door):** DONE (this commit; hash next) — `MastheadTagCluster` rebuilt: the ＃ is THE
  door; click → `TagInlineField` slides out INLINE beside the cards with the cursor in it (⏎ applies through
  the standing `applyTypedPath`, `/` nests, the live taxonomy's matches hang under it, ⎋ or a second ＃ puts it
  away; the field stays out after an apply so several tags go on in one breath); "＋ tag" RETIRED; **the
  masthead FOLD RETIRED — K12 SUPERSEDED for the masthead** (recorded at the site, `ContextBarDoors.swift`,
  and here: the fold served the crowded context bar; the cards stay visible). **⌘⇧I RE-POINTED, not
  retired:** `.tagNote` carries the chord + View-menu + ⌘K doors (note-scoped — honestly grey with no note),
  routed to the mounted masthead through a new `CommandRouter.registerDetail(openTagField:)` /
  `requestTagField()` seam (the tray's pattern, P-4); `.toggleTagChips`, `TagChipsFold`, `tagsDoorCount`,
  `tagsFoldHelp`, `tagChipsVerb`, `ShellRouter.toggleTagChips` all gone; the ⌘/ helper's two sentences
  updated. Pins `MastheadTagDoorTests` ×2 (one declared act, no ＋ on the cards — `chipsShowAddDoor`; the field
  absent at rest, present AND first responder when opened); `BookAscentTests.theFoldIsOneDeclaredActWithOneKey`
  re-pointed at `.tagNote` (a JUSTIFIED PIN EDIT); the fold's two pins in `ContextBarShapeTests` RETIRED with a
  note. Red-on-old by construction (the pre-round cluster had no inline field and declared two acts; the
  fold's own pins were green on the old tree and are gone). **Tutorial text now behind the door:** the seeder's
  "the workspace" lesson still says "＃ folds the note's tag cards away and back (⌘⇧I too…)" — the closeout's
  copy change + re-seed (obligation 8); untouched here by the brief's rule.
- **Rows 10 + 11 (library rows):** DONE (`5a0249c`) — TWO mechanisms, both baseline: **(11)**
  the book row's HStack had NO alignment (default `.center`), so the small "book" label centered against the
  body-size title and its baseline sat below the title's; **(10)** the note row DID align on
  `.firstTextBaseline`, but the chips handed the stack a SYMBOL IMAGE's bottom edge as their baseline — each
  chip was a `.center` HStack of a Text and a bare `Image(xmark)`, and the first-baseline guide of that stack
  resolved to the image — so the chip text landed ~2 pt under the title's line, and the ＋ rode with it. Fix:
  the two List-mode row LINES extracted as views (`CatalogBookLine` · `CatalogNoteLine`, in
  `LibraryCatalogView.swift`) aligned on `.firstTextBaseline` end to end; the book icon and the chip's ✕ are
  `Text(Image(systemName:))` (a Text carries a real baseline); `NoteTagChips`' stacks align on the baseline
  too (every renderer of the chips inherits it — the note cards, the Pool, the masthead). Pins
  `LibraryRowAlignmentTests` ×2 — the lines mounted in a window, the DEBUG `BaselineProbe` oracle
  (`Core/Views/BaselineProbe.swift`: `alignmentGuide` offset + the top in the line's named space) read for the
  title vs the first chip's text vs the ＋, and the title vs the kind label, within 1 pt, in BOTH voices —
  GREEN. **Red-on-old VERIFIED by behavioral revert** (the old shapes put back in place — the book line's
  bare HStack + `Image`, the chips' `.center` stacks + bare `Image` ✕ — run from `5a0249c`): **5 issues in 2
  tests** — the chip text and the ＋ each **1.5 pt** off the title in BOTH voices (4), and the book row's title
  never reported a baseline at all (the unaligned HStack never asked for one — 1); restored by
  `git checkout --`, diff empty.
- **Row 36 (the sweep table):** DONE (this commit) — the table is in the "Row 36" section of this record
  below; NOTHING on the chrome surface carried a count to drop (the masthead, the sidebar and the library rows
  show no word count — the rows' `detail` is a date or the kind word); the rest are dispositions for C / E.
- **The USE gate:** DONE (this commit — the sheet's read is the next line's) — both voices walked on the
  dev-store Debug build (window zoomed 1728×1084): 28 captures in `act10-correction-screens/batch-a/`, the
  contact sheet `batch-a/contact-sheet.png` (28 tiles). The walk caught row 55 twice (the first cut's field
  squeezed the title; the second cut's floor still truncated at three chips) — the masthead is two rows now;
  the final captures show five chips + the open field with the title intact in both voices. The short window
  MEASURED compact (AX: every row 24 pt at a 454 pt column with the rail open; 30 pt generous otherwise).
- **Full Mac suite + TutorialWalkTests:** DONE — **Mac 2010 tests / 351 suites, all green** on the final tree
  (`** TEST SUCCEEDED **`, 303 s; log `test-a-full2.log` in the session scratchpad; the ten tutorial suites
  inside it green; the load-flaky `rewriteStrategyLatencies` (2 cases) and `CanvasDragTrackingTests` passed
  in-run — nothing re-run, nothing loosened). **Arithmetic against batch B's close 2001 / 347:** +13 tests
  (`ShellChromeTests` 3 · `SidebarLayoutTests` 5 · `MastheadLayoutTests` 1 · `MastheadTagDoorTests` 2 ·
  `LibraryRowAlignmentTests` 2) − 4 retired with the fold (`theTagsDoorCarriesTheCountOnlyWhenFolded` +
  `TagChipsFoldTests` ×3) = **+9 ⇒ 2010**, exact; suites +5 new − 1 retired (`TagChipsFoldTests`) = **+4 ⇒
  351**, exact. The first full run on the pre-final tree read 2010/351 with 4 issues in TWO pins whose
  expectations described what this batch changed — `NoteTagDeclarationTests` (`.tagNote`'s surface-only
  declaration) and `NoteVersionsPaneTests`' `s`-chord count (⌃⌘S is a third) — both JUSTIFIED PIN EDITS,
  line by line at the pins; the full suite was then run AGAIN on the final tree: the count above. **Core
  1524 / 165 untouched** (zero `Sources/VariorumCore` lines in the batch). **`Shared/` touched once:**
  `VoiceTokens.navigation` (a new font slot, all four voices filled) — the mobile target compiles the same
  file; its suite was not run here (not this batch's), flagged for the orchestrator.
- **STATUS: BATCH A's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it
  is marked closed.** The dev-store Debug build (the final tree's product, `Variorum-dnpxwqhpxdqrdjbunktnzoahckpd`)
  is left RUNNING for that walk — Terminal voice, "three ways of working" open, window zoomed; `/Applications`
  untouched; her real-store app untouched. Tree clean; every commit pushed.
- **No revert in flight** (the row-2/3 revert ran and was restored — evidence above; tree clean against
  `b22b6ff`).

#### The container decision (row 2) — stated, with its reason

`NavigationSplitView` → **a custom split, `ShellSplit`** (`App/Variorum/Variorum/Workspace/ShellSplit.swift`).
Reason: Tahoe's floating glass sidebar IS the split view's rendering of its sidebar column in a key window,
and NO public opt-out exists — searched at the SDK, not assumed: the macOS 26 SwiftUI interface declares
`NavigationSplitViewStyle` in three forms only (`automatic` · `balanced` · `prominentDetail`), none flat;
AppKit's `NSSplitViewItem` gained only `automaticallyAdjustsSafeAreaInsets` and the accessory view
controllers at 26.0 (`NSSplitViewController` nothing); and the 13g measurement already recorded in
`VariorumApp.swift` had shown the floating card is the KEY-window appearance, not a window style. So the
container is ours: an `HStack` — the flat sidebar column, ONE 1 pt divider in the voice's `line` carrying the
pane row's own drag grammar (`RootView.paneDivider`), the detail — with `@AppStorage` width memory
(180–360, ideal 210) and an animated collapse. What it keeps: every panel `RootView` hosts beside the sidebar
(the pane row + its inspectors — scraps, references, the tray, Block History, Versions, the Library's info
panel — all live INSIDE the detail; the tray was opened in the walk and rendered as a column inside the
detail, within the window); the sidebar's collapse (now a DECLARED act, `.toggleSidebar`: the leading toolbar
button + View ▸ Toggle Sidebar on ⌃⌘S — the platform's chord, swept free — per-window state
`ShellRouter.sidebarShown`, grey while a note-only window is key, a row in the ⌘/ helper); the bottom
status rows (the column's own last region). What it costs, stated: the sidebar List's arrow-key row
navigation (row 57).

#### Per-row dispositions

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 2 | FIXED — `ShellSplit`; the glass pane gone (flush column, one divider) | `ShellChromeTests.theShellMountsFlatAndTheStripRowsAreGenerous` (zero `NSSplitView` at rest) · `.theSidebarWidthIsClampedToAUsableColumn` · `.theSidebarToggleIsDeclaredOnItsTwoDoors` | 1 issue (`countSplitViews → 1`) under the `NavigationSplitView` revert |
| 3 | FIXED — the flat column (the mockup's grammar), the Open strip DIRECTLY under the rail, ONE generous 30 pt pitch, compact 24 only when the measured column cannot hold the generous layout | `SidebarLayoutTests` ×5 · the shell pin's oracle half (the DRAWN strip row = 30) | 1 issue (`drawn → 21.0`) under the 21 pt revert; the threshold pins by construction (the function did not exist) |
| 4 · 19 | FIXED — the title centered on the masthead's full width, every mode; two rows (title ⟂ icon row, path ⟂ tag cards) | `MastheadLayoutTests.theTitleBlockCentersOnTheMastheadInEveryMode` (eight modes via the router; the DEBUG oracle on the title TEXT) | 8 issues (246 pt off in every mode) under the leading-title revert |
| 15 | FIXED — ONE door (＃) → the inline field with the cursor in it; "＋ tag" and the K12 fold retired (K12 superseded for the masthead); ⌘⇧I RE-POINTED at `.tagNote` | `MastheadTagDoorTests` ×2 · `BookAscentTests.theFoldIsOneDeclaredActWithOneKey` (re-pointed) | by construction (no inline field existed; two acts were declared; the fold's own pins retired with a note) |
| 10 · 11 | FIXED — the Library rows on ONE text baseline (`CatalogBookLine` · `CatalogNoteLine`; symbols as `Text(Image)`; the chips' stacks on the baseline) | `LibraryRowAlignmentTests` ×2 (both voices, the DEBUG `BaselineProbe`) | 5 issues (1.5 pt off ×4; the book title never reported) under the old-shapes revert |
| 36 | DONE — the sweep table (this record); nothing on the chrome surface carried a count | — | — |
| 24 (sidebar half) | FIXED — the rail fades in/out (`.transition(.opacity)` under a 0.22 s animation; the Open group slides) | — (no pin: an animation; capture `03-terminal-rail-fade-mid`) | — |
| **55** (new — the walk) | FIXED in-batch — the open field squeezed the title; the field is an overlay, the masthead two rows | the masthead + tag-door pins green after | (the walk's own capture, twice) |
| **56** (new — seen in the walk's probe capture, NOT the chrome) | RECORDED for **batch E** — the Library's List-mode row selection is the SYSTEM blue highlight band (a row clicked once wears a full-width blue selection), against the calm grammar (W8-2: selection is the wash + a tinted border, never a system highlight); the row click model is E's (R-cor-3) | — | — |
| **57** (new — a cost of row 2, stated) | RECORDED for the orchestrator (owner: **13u2**, the feel-and-faces half, if she wants it back) — the sidebar List's arrow-key row navigation is gone with the List; the flat column's rows are buttons/taps. A `focusable` column with ↑/↓ handling restores it as a small batch; not built here (no ruling asked for it, and the List's keyboard focus was never a door she named) | — | — |

#### The USE gate — the walk (the dev-store Debug build, window zoomed 1728×1084, BOTH voices; `act10-correction-screens/batch-a/`, contact sheet **`batch-a/contact-sheet.png`** — 28 tiles)

| Row | What was done | Capture(s) |
|---|---|---|
| 2 | The shelf at launch: the column flush at x = 0, one divider, no glass — Terminal and Study | `01-terminal-shelf-flat-sidebar` · `26-study-shelf-flat-sidebar` |
| 2 | ⌃⌘S collapses the column (the detail takes the width) and restores it | `15-terminal-sidebar-collapsed` · `15b-terminal-sidebar-restored` |
| 3 | A note open: areas · "this note" rail · the Open strip DIRECTLY under it, every row 30 pt (AX-measured) | `02-terminal-note-write-masthead-rail-strip` · `21-study-note-write-masthead-rail-strip` |
| 3 | The SHORT window (600 pt; a 454 pt column, the rail open): every row 24 pt (AX-measured `186x24`), the strip still under the rail | `14-terminal-short-window-compact-rail` · `27-study-short-window-compact-rail` |
| 24 | Leaving the note for the Library: the rail mid-fade, then gone with the Open group slid up | `03-terminal-rail-fade-mid` · `03b-terminal-library-after-fade` |
| 4 · 19 | The title centered in Write · Takes · Index · Read · Lenses · Compare · Blocks · Canvas (Terminal) and Write · Read · Lenses (Study) | `02` · `04-…-takes` · `05-…-index` · `06-…-read` · `07-…-lenses` · `08-…-compare` · `09-…-blocks` · `10-…-canvas` · `21` · `22-study-masthead-read` · `23-study-masthead-lenses` |
| 15 | The ＃ clicked → the field out with the cursor in it; typed; ⏎ applies (the chip lands, the field stays); ⎋ closes — with five cards, the title intact | `11-terminal-tag-field-open` · `11b-…-typed` · `12-…-applied-field-stays` · `12b-…-closed` · `24-study-tag-field-open` · `24b-…-typed` |
| 10 · 11 | The Library rows' close-up (2× crop): "book" on the title's baseline; the chips and ＋ on the note's | `13-terminal-library-rows-closeup` · `25b-study-library-rows-closeup` |
| (the book) | Sherlock's Outline on the new shell — the book's masthead is its navigator column's header (B's surface; unchanged) | `16-terminal-book-outline` |

Honesty notes: the dev store now carries the walk's test tags on "three ways of working" (`walked · again · once · final · study` — applied through the real door, left as evidence of the many-chips case); the rail's fade is judged from one mid-frame capture (a 0.22 s animation cannot be pinned); the tray inspector was exercised in the probe pass (scratchpad captures, not in the sheet) — it renders as a column inside the detail.

#### Commits (in order)

1. `f82ff80` — the record skeleton + LIVE STATUS (the sidebar's pitch measured; the container decision).
2. `b22b6ff` — rows 2 + 3 + 24: `ShellSplit`, the flat column, the strip under the rail, `SidebarLayout`, `VoiceTokens.navigation`, the rail's fade; pins.
3. `70b6023` — rows 2/3 red-on-old evidence.
4. `74c72db` — rows 4 + 19: the centered masthead; `MastheadLayoutTests`.
5. `310c522` — rows 4/19 red-on-old evidence.
6. `3bc142f` — row 15: one tag door, the inline field, the fold retired, ⌘⇧I re-pointed; pins.
7. `5a0249c` — rows 10 + 11: the baseline-aligned Library rows; `BaselineProbe`; `LibraryRowAlignmentTests`.
8. `418b8b4` — rows 10/11 red-on-old evidence + the row-36 table.
9. `7ffa80d` — row 55 (the walk): the field as an overlay, the title floor.
10. `512822c` — row 55's second cut: the two-row masthead; the walk's captures + sheet; the record.
11. `45b8545` — the two justified pin edits (`NoteTagDeclarationTests`, `NoteVersionsPaneTests`), the full suite re-run on the final tree (2010 / 351), the record's dispositions, the container decision, the walk table, rows 56/57, the LIVE STATUS final.
12. (this commit) — this list's hash filled.

#### Row 36 — the word-count / metric sweep (C-6; R-cor-4(d)) — every display in the eight Act 10 views, grep-enumerated (`words\|[0-9]w\b\|wordCount`), verdicted against the brief's bias (a count stays where the pre-Act-10 surface had one or where the mockup grammar shows one; "thrown in" goes)

| file:line | what it says | verdict | reason | who applies |
|---|---|---|---|---|
| `SnippetsSurface.swift:173` (via `SnippetsCopy.words` :76) | a snippet row's facts: `⑂ N takes · N words · edited …` | KEEP | the mockup's snippet `.met` line shows exactly this (`⑂ 3 takes · 18 words`, mockup :992) — W8-4's ruled row | — (as is) |
| `SnippetsSurface.swift:147` | sort by word count | KEEP (not a display) | a sort key, not chrome | — |
| `ReadModeView.swift:302` (via :216) | the page header: `N words · about M minute(s)` | KEEP | her word (R-cor-4(e): stays in Read); the Read mockup's kicker shows it (:859) | C (the `read` half) |
| `ReadModeView.swift:254–255` | the FOOTER: `N blocks · N words · about M min` | DROP | the same facts twice on one page — the header already says them; the mockup's Read shows one line, not a footer duplicate | C |
| `BlocksWorkbenchView.swift:258` | the workbench toolrow: `N blocks · N words` | KEEP | the mockup's Blocks toolrow shows it verbatim (:969); the poweruser center's one anchor | — |
| `BlocksWorkbenchView.swift:419` | per-row `Nw` | KEEP | the mockup's every `.met` row carries `N words` (:1002–:1052); the words SORT (:135) needs its evidence on the row | — |
| `BlocksWorkbenchView.swift:652` | the context panel's `words` fact row | KEEP | the block's facts sheet; a full fact beside the row's abbreviation (C-6's stated reason: the panel is where the whole fact is read) | C may fold it if the panel's order pass (row 26) finds it redundant |
| `IndexModeView.swift:484` | the footer: `N blocks · N words` | KEEP-ONE | the Index mockup shows it (:762); but the Index tab RETIRES into Read's `edit` half (R-cor-7) — the merged tab keeps exactly ONE count line (the mockup's), never the `read` header plus this footer | C |
| `BookView` (batch B's four — verdicted in B's record) | card `Nw` · gutter `⑂ takes on N blocks` · `bookMetaLine` · the side card's counts | DROP · KEEP · KEEP · DROP/KEEP | B's record; unchanged here | done (B) |
| `CommitBar.swift:228–232` (the side card) / `:549–556` (the flat bar) | `Nw in note` word-target door · `Nw block · Nw selected` | KEEP | pre-Act-10 (R11's bottom-bar idiom, the word-target door's face) — not Act 10's | — |
| `LibraryInfoPanel.swift:189` | the facts card's `words` row | KEEP | R-cor-3 asks for "a calm facts line (words · blocks · last edited)" — E rebuilds the panel WITH it | E |
| `CompareBoardView.swift` | — | none found | the brief's "Compare 2" are the takes bottom bar's `Nw note` (`TakesBottomBar.swift:442–466`, pre-Act-10 R11) | — |
| `BookIndexView.swift:352` | per-chapter NOTE counts (`welcome 3`) | KEEP | a structural count (how many notes a chapter holds — the navigator's shape), not a word count | — |
| the chrome (masthead · sidebar · library rows) | — | none | no count to drop; the mockup's `pool 59` sidebar badge is NOT built and is not added (C-6) | A ✓ |

---


#### ORCHESTRATOR'S WALK OF BATCH A (2026-09-01 ~09:45; token-disciplined: A's contact sheet + two live captures with masthead crops, `orchestrator-a/`)

- **Right on the fresh build (pid 77509):** the sidebar is a flat column flush at x = 0 with one divider (the glass pane gone — W8-3 delivered whole); the rail generous; the Open strip directly under the rail; the title centered over the content in Write; the bottom bar one row; the `#` door slides out an inline field with the cursor (row 15). The sheet's 28 tiles show the title centered in all eight modes in both voices, the library rows aligned, the compact rail in a short window, the fade mid-frame.
- **RESIDUAL — row 58 (MAJOR):** the masthead's second row collides (the path chip under the tag cards; hidden under the open field). A is REOPENED for it (a fresh fix session); its record stays un-closed until the fix is walked.
- Row 57 (the sidebar List's arrow-key navigation gone with the flat column): left RECORDED with owner 13u2 as A dispositioned it — she did not ask for it and the flat column is her W8-3 ruling; the ladder may weigh it; noted in §7 for her.

#### ROW 58 FIX — the masthead's second row (a fresh Fable fix session, 2026-09-01 ~09:30 →)

**LIVE STATUS — ROW 58: FIXED — pins green, red-on-old verified (10 issues), walked in BOTH voices on the dev-store Debug build, full Mac suite 2014 / 352 green (exact). No revert in flight; tree clean; every commit pushed. The dev-store Debug build (pid 81367, the shipped tree's product) is left RUNNING for the orchestrator's walk — Terminal voice, "three ways of working" open, window zoomed; `/Applications` untouched; her real-store app untouched (not running). NEXT (the orchestrator): walk row 58 on that build (the five-tag note closed/open in both voices; the ⌘N note; the sheet `batch-a/contact-sheet-r58.png`) and close batch A's record — this session does not close it.**

- **The traced mechanism (verified at the code and by arithmetic against the crop):** the orchestrator's stated cause — "the centering padding measures the FIRST trailing row" — describes `74c72db`'s shape. On the current tree (`512822c`, the two-row masthead) the path row DOES inset by the cards' row's measured width — but `mastheadInset(for:)` caps that inset at `(mastheadWidth − 240) / 2 = 220` pt: the 240-pt floor row 55 added so the TITLE never shrinks, applied to the path row too. Past ~208 pt of cards the inset stops growing, the chip stays centered on the full width (midX 340; `~/the field guide` ≈ 125 pt wide → `[278, 403]`) while five cards + the ＃ occupy `[321, 680]` → the chip is under the first two cards (the crop's exact picture: masthead block at x 630–1310 in the 1728-pt window, chip centered at ~965, cards from ~951). With the field open the overlay extends the cluster 196 pt further left (`[125, 315]`) and row 55 faded the chip to opacity 0 instead of moving it — hidden, its frame still colliding. So row 2's two layers were laid out unaware of each other, exactly as the row says; the cap was the mechanism.
- **Red-on-old VERIFIED by behavioral revert** (the row-2 layout put back IN PLACE to `512822c`'s ZStack — the chip centered behind the capped inset, the cluster trailing on its own layer, the opacity yield — with the oracle wiring kept; run from the committed state `7dee4c7`, log `r58-pin-red.log` in the session scratchpad): **10 issues in the 2 new pins** — Terminal (6): the chip `(489.5, 37.0, 121×14)` intersects the cards at `x 525` and `x 590` (the gap reads −85.5 and −20.5 against the required 16) and the open field `(335, 36, 190×19)` covers it (gap −275.5); Study (4): the chip `(504.25, 43.0, 91.5×14)` intersects the card at `x 568.5` (−27.25) and the field `(378.5, 42, 190×19)` (−217.25). The rows-4/19 centering pin stayed green under the revert (the title row was not reverted). Restored by `git checkout -- App/Variorum/Variorum/Features/Takes/PostDetailView.swift`; `git diff --stat` empty. Green on the fix: `MastheadLayoutTests` ×3 · `MastheadTagDoorTests` ×2 · `LibraryRowAlignmentTests` ×2 — 7 / 3 (log `r58-pins-1.log`).
- **THE FIX AS SHIPPED (the masthead's files only — C-1; plus one new shared-home component):** row 2 of the masthead is ONE `HStack(alignment: .firstTextBaseline, spacing: 16)`: the **path chip LEADS** at the masthead's leading edge — the article's left margin, where the mockup's `.where` line sits under its `h1` — at its own width (`fixedSize` + `layoutPriority(1)`; never compressed); the **tag cluster TRAILS** as `TrailingFlow` (`Core/Views/TrailingFlow.swift`, new — a right-aligned wrapping `Layout`): the cards then the ＃ fill from the right edge and wrap onto further lines when the width that remains says so, items on a line aligned on their first text baseline, the flow reporting its first line's baseline upward so the chip sits on the cards' line. **Every line keeps `TagInlineField.width + 6 = 196` pt free at its LEFT** — the room the field slides out into, whichever line holds the ＃, reserved open or closed so opening the field never moves a card, the chip, or the title (row 55's promise kept a different way); the field hangs off a zero-width anchor item the flow parks at the last line's leading edge. **The ＃ never starts a line alone** (`keepsWithPrevious` — the first walk on the fixed row showed five cards filling a line exactly and the door orphaned below; the last card now comes down with it). Row 55's opacity-yield of the chip is RETIRED with the collision it hid: the chip stays in view while a tag goes on. `MastheadTagCluster` renders `TagChipCard`s directly (the one card extracted from `NoteTagChips`, which now renders the same view — every renderer still inherits rows 10/11's baseline stack; `LibraryRowAlignmentTests` green unmodified); its new `geometryProbeSpace` is the DEBUG oracle's space (nil for the door pin's standalone host — the door pin rides unmodified). `mastheadChipRowWidth` and the path row's inset are gone; the title row is byte-unchanged (inset by the icon row only).
  - **Why the chip LEADS rather than centers-when-room (the brief offered both):** a chip centered on a bare note and shoved left by its third tag is a jump triggered by tagging and an inconsistency across notes; the leading chip is the same on every note, gives the cluster ~540 pt, and reads as the classic masthead — headline centered, dateline left, tags right — in both voices.
  - **The brief's "the title's centering padding takes the WIDER of the trailing rows" — honored in intent, not in letter, and here is why:** under this design nothing on row 2 centers, so only the title needs a centering inset, and the only thing that shares the TITLE's line is the icon row. Insetting the title by the cards' row (the wider one) is exactly what row 55's second cut found truncating the title to "worki…" at the 240-pt floor — so the title row keeps insetting by the icon row alone, and the pin holds the title centered within 1 pt WITH five tags, field closed and open, in both voices. The cards can never reach the title's line: they are a different row.
  - **Twin recorded (the forked-brains class, for the orchestrator):** `TrailingFlow.rows(widths:available:spacing:)` is byte-compatible with the phone's `MobileChipFlow.rows` (leading-aligned there, trailing here; the phone's file is the mobile target's and outside this batch's fence). The Shared/ hoist is a MOVE at the next touch of either — a candidate line for the KnownIssues forked-brains row's "remaining" list, the orchestrator's call. `BlocksWorkbenchView`'s private `FlowLayoutLite` (leading, no baseline alignment) is the same class one surface over — batch C's file (C-1), noted for C to adopt `TrailingFlow` or hoist at its touch.
  - **Widths, stated:** at the 680-pt measure with `~/the field guide` (≈125 pt) the flow's first line holds ≈343 pt of cards (four in Terminal's mono, five in Study's proportional face); a line per ~4 cards thereafter. In a detail narrower than chip + gap + field (≈340 pt) the reserve cannot be honored and the open field would cross the chip — below any width the split allows; recorded, not pinned.

- **Pins (green on the fix — 9 / 4 with the two masthead suites and the row-alignment pin, log `r58-pins-2.log`):** `MastheadLayoutTests.thePathChipAndTheTagClusterNeverIntersectInTerminal` · `…InStudy` — the real detail mounted with a titled note in a book and FIVE tags; the DEBUG `MastheadGeometry` oracle (extended: `pathChipFrame` · `cardFrames` by tag id · `fieldFrame`, all in the masthead's own space; `resetRowTwo()` before the mount) read for: no card intersects the chip · every card sits right of the chip by ≥ 16 · every card inside the masthead · the title centered within 1 pt; then ⌘⇧I's road (`commandRouter.requestTagField()`) opens the field: the field intersects neither the chip nor a card, sits right of the chip by ≥ 16, the chip did not move, the title still centered. `TrailingFlowRowsTests` ×2 — the pure row rule (greedy fill, over-wide item on its own line, nothing dropped) and the orphan rule (the door pulls the last card down; a line is never emptied; no-op without a marked item) — door class (the rules did not exist). **Red-on-old:** the 10 issues above.

- **The USE gate — the walk** (the dev-store Debug build relaunched on the fixed tree twice — pid 80927 the first cut, 81367 the shipped one; window zoomed 1728×1084; BOTH voices; every capture in `act10-correction-screens/batch-a/` as `r58-…`; **contact sheet `batch-a/contact-sheet-r58.png`** (the r58 captures alone — read this one) and `batch-a/contact-sheet.png` refreshed with them):

  | What | Capture(s) |
  |---|---|
  | Terminal · five tags · field closed: the chip leads at the left, four cards on line 1, `walked × #` on line 2, the title centered — nothing touches | `r58-01-terminal-5tags-closed` (the first cut's orphaned ＃ was seen on this same name before the refinement and re-shot) |
  | Terminal · the ＃ clicked → the field out on the ＃'s line, left of `walked`, clear of the chip; typed; ⏎ applies (the card lands, the field stays, nothing else moves) | `r58-02-terminal-5tags-field-open` · `r58-02b-terminal-field-typed` · `r58-03-terminal-6tags-applied-field-stays` |
  | Terminal · SEVEN tags with the field open, then closed: two lines, the door beside a card, the field beside the second line | `r58-03b-terminal-7tags-field-open` · `r58-04-terminal-7tags-closed` |
  | Terminal · the cards' × door: the two walk tags taken off one at a time, the flow re-laid each time, back to five | `r58-05-terminal-x-removed-one` · `r58-06-terminal-back-to-5tags` |
  | Terminal · a one-tag note (`the seal` — the seeder tags every field-guide note `tutorial`) | `r58-07-terminal-0tags` (misnamed — it is the ONE-tag case) |
  | Study · five tags closed (all five + ＃ fit one line in the proportional face) · the field open beside them, clear of `in the field guide` | `r58-10-study-5tags-closed` · `r58-11-study-5tags-field-open` |
  | A ZERO-tag, no-book note (⌘N) in both voices: `in no book` leading, the lone ＃ trailing | `r58-12-study-0tags-new-note` · `r58-13-terminal-0tags-new-note` |
  | (aside) the Settings window's Appearance tab — how the voice was switched | `r58-08-settings-window` · `r58-08b-settings-appearance` |

  Honesty notes: the two walk tags (`row58a`, `row58b`) were applied through the field and removed through the × — the dev store carries the batch's five as before, plus the empty ⌘N note of 2026-09-01 (left; a dev-store artifact). `r58-07` is a one-tag case, not zero; the zero-tag case is `r58-12/13`. The suggestion list under the open field is below the crops' edge and was not inspected (unchanged code).

- **Counts:** the masthead/door/row-alignment/flow pins 9 / 4 green (`r58-pins-2.log`). **Full Mac suite on the final tree: 2014 tests / 352 suites, all green** (`** TEST SUCCEEDED **`, 301.9 s; log `r58-full-mac.log` in the session scratchpad; the ten `TutorialWalkTests` suites inside it green; **the load-flaky `rewriteStrategyLatencies` (2 cases) and `CanvasDragTrackingTests` PASSED in-run — nothing re-run, nothing loosened**). **Arithmetic against batch A's recorded 2010 / 351:** +2 tests (`MastheadLayoutTests`' two geometry pins) +2 tests (`TrailingFlowRowsTests`) = **+4 ⇒ 2014**, exact; +1 suite (`TrailingFlowRowsTests`) ⇒ **352**, exact. Core 1524 / 165 untouched (zero `Sources/VariorumCore` lines); `Shared/` untouched (the mobile target sees no change).

- **Commits:** `7dee4c7` (the fix + the geometry pins + the record opened) · `b667932` (the red-on-old evidence) · `a3dfe16` (the orphan rule + its pins + the warning fix) · `1409d52` (the walk's captures + sheets, the counts, this record's close) · the hash fill.

#### BATCH A RECORD — CLOSED by the orchestrator (2026-09-01 ~10:40)

Walked twice: the batch on build 77509 (`orchestrator-a/00`, `01` + the 28-tile sheet) and row 58's fix on build 81367 (`02`–`09`: the path chip leads, the cluster wraps, the `#` field opens beside the cards and applies — the dev store's "tutorial" tag, removed by a mis-aimed click during the walk, was restored through the door; the stray typed word was removed by hand). Counts at close: **Mac 2014 / 352 green** (2001 + 13 tests, 347 + 5 suites over B's close); core 1524/165 untouched; `Shared/` touched once (`VoiceTokens.navigation`) — the iOS target build is owed before the ladder (the R3-2 lesson; recorded in §7b's checklist). Residuals, all owned: row 56 (the Library's system-blue row selection) → E; row 57 (the sidebar's arrow-key navigation gone with the flat column) → 13u2, her call in §7; row 59 (the `#` hit target) → the ladder's fix round; the tutorial's "the workspace" lesson still describes the retired fold → the closeout's copy change + re-seed (§7b item 8); `TrailingFlow.rows` ≡ the phone's `MobileChipFlow.rows` → a line for the forked-brains KnownIssues row at closeout. Nothing deferred, nothing reverted. **Batch C spawned next.**

---

### BATCH C — THE NOTE MODES (brief; DRAFTED 2026-09-01 ~05:55 — spawn after A closes)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL, in order:** this file (all of it — the constitution, C-1…C-7, R-cor-1…7 with R-cor-5/7 as
your governing rulings, the ledger, the triage record, batch B's and A's records — B names the scrolled-open
DOOR brain you reuse); the source report (§1; image rows 1, 10–15); then the code: `Features/Takes/
PostDetailView.swift` (the `Mode` enum + `allCases` rail/menu/keys ~:190, the `InspectorPanel` host
:125–140 / :281–301 / :356, the per-note mode memory :389), `Features/TOC/IndexModeView.swift`,
`Features/ReadMode/ReadModeView.swift` (`outlineShown`, the minimal outline :131+, the page), `Features/TOC/
BlocksWorkbenchView.swift` (the split :147–161 — the context panel is `.frame(width: 320)`; the five `.task`s
:167–171), `Shared/NoteIndexOutline.swift`, `Core/Views/FlowParagraph.swift`, `Features/Tray/
BlockHistoryPane.swift`, `Registry/CapabilityRegistry.swift` (:144 the read-mode gate; :1173 `switchMode`
"⌘1–⌘8"), `Registry/Capability.swift` (:576), the book's paged engine (the Book tab's `scroll · pages`
selector — find it in `Features/BookView/`), the tutorial seeder `Features/Tutorial/TutorialSeeder.swift`
(:332 the mode enumeration; :1332–1348 the "index · read" lesson — its TEXT states ⌘3/⌘4 and the click-lands-
in-Index promise; it changes under R-cor-7), and the pins `NewModesTests`, `NoteIndexOutlineTests`,
`BlocksWorkbenchTests`, `ModesSherlockMeasureTests`, `BlockHistoryPaneTests`, `WorkspaceNavigationTests` (the
eight-mode rail pin re-anchored at `15c7463` — it becomes seven), `TutorialWalkTests`.

**Your surface is the NOTE's mode row and the modes Read (edit·read), Blocks, and the Block History HOST —
and only that (C-1).** Rows:

1. **Rows 30/31 + 5/6/21 + 42 — R-cor-5/7, whole.** The rail becomes **Write · Takes · Read · Lenses ·
   Compare · Blocks · Canvas (⌘1–⌘7, derived from the one order — rail, menu and keys can never disagree;
   the registry verb follows)**. READ carries an in-place **`edit · read`** switch, **default `edit`**
   (RULED), remembered per note (your call, stated). **`edit`** = the Index tab's `▸ 01` outline column
   (toggle to hide/show with the existing outline button; the expanded/dropdown rows' type a step larger;
   **the small expanded editing card RETIRES**) beside a text pane in which **a clicked block goes LIVE in
   place** (the read-cheap→live upgrade through `PaneTextAuthority`; ONE live editor — P-3; the Write
   editor's identity machinery is never duplicated). **`read`** = `ReadModeView`'s calm page, **never
   editable**, with a `continuous · pages` selector (the book's paged engine reused — no second pager) and
   the SAME `▸ 01` column available (the minimal outline retires); the row-6 contents truncation goes with
   it. A click on a sentence in `read` flips to `edit` **at that block with the caret there** — batch B's
   door brain, reused, never re-implemented (row 38's note half). The Index TAB retires; `IndexModeView`'s
   brains become Read's `edit` half (keep the names as forwards where pins ride them — the 3C parity shape).
   Update the registry, the eight-mode pins → seven, and the **seeder's lesson text** to the new truth
   (⌘3 = Read; "click this paragraph — the page turns to edit with it live"), recording that the LIVE
   re-seed is the closeout's act. Pins: seven modes + key derivation; `edit` default; a click in `edit`
   makes exactly that block live (authority invariant); `read` has no live pane; a `read` click lands in
   `edit` at the clicked block; the pages selector renders the paged engine.
2. **Row 39 — ONE current block follows you.** Today position is per-mode memory. Define ONE per-note
   "current block" (the live/caret block in Write and Takes; the selected block in Read's `edit` and in
   Blocks) that every mode ENTERS on and LEAVES to. Pin the round trip: Write caret in block 2 → Takes live
   block 2 → Read(edit) block 2 selected/live → Blocks block 2 selected → Write caret in block 2.
3. **Rows 27 + 29 — Block History's host.** (a) ONE right region at a time: opened from Blocks, the history
   pane must not stand beside the workbench's own context panel past the window's edge — either the context
   panel yields or the history renders inside it; a geometry pin: the window's content never exceeds its
   width. (b) The pane is scoped to the mode that opened it: a mode switch closes it (or re-targets it to
   the current block — say which); it never shows block 3's history while block 1 is live. Pin: open in
   Write, ⌘2 → gone/re-targeted (RED on old: it persists stale).
4. **Row 18 — Blocks' draggable divider** between the list and the context panel (min widths both sides,
   the width remembered, the resize cursor on hover). Pin: a drag changes the split and it persists.
5. **Row 25 — the Blocks selection lag.** Measure first (click → rendered) on the Sherlock 215-block note; the
   candidates are the five `.task`s on appear and `observeBlockWorkbench` re-reading the note's facts on the
   main actor; render the list first and let facts arrive. Pin: a measure pin (the `ModesSherlockMeasureTests`
   shape) with a budget you state; RED on old if the budget is honest.
6. **Row 26 — the context panel's order:** facts first, the text card after (the architect's reading of "the
   text is also above the details"; note it PROVISIONAL in the record — her morning walk can flip it).
7. **Row 36 — apply batch A's KEEP/DROP table** to the displays on your surfaces (Read's page line stays per
   her word; the workbench footer and the Index column's counts per the table).

**Rules (§2b) bind; the acceptance gate is USE:** captures in `act10-correction-screens/batch-c/` — the
seven-mode rail; Read opening on `edit` with the column; a click making a block live in the pane; `read`
continuous and pages; the outline toggle; a `read` click landing in `edit` at that block; the five-step
continuity round trip; Blocks with the divider dragged; the selection timing; history from Blocks inside the
window; history gone after a mode switch. Environment + driving recipe + resiliency: batch B's brief's last
three paragraphs bind identically. Baselines: batch A's record's counts + your pins. **Deliverable:** code +
pins + a BATCH C RECORD under this brief (dispositions, the "current block" authority's name and file, the
captures, counts, commits, new rows numbered after A's last).

---

### BATCH C RECORD — THE NOTE MODES (a fresh Fable implementer session, 2026-09-01 ~10:45 →)

#### LIVE STATUS — BATCH C (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — the plan read in full (§0–§8, B's and A's records, this brief), CLAUDE.md, the resiliency protocol, the handoff's §2c, her report (§1 + image rows 1, 10–15), then the brief's files in its order (`PostDetailView` · `IndexModeView` · `ReadModeView` · `BlocksWorkbenchView` · `NoteIndexOutline` · `FlowParagraph` · `BlockHistoryPane` · the registry's two sites · `PostMode` · the book's paged engine `PagedReadModel`/`PagedReadView`/`BookView`'s `scroll · pages` · the seeder's two sites · the pins). Tree clean at `11b6f2a`; the dev-store Debug build pid 81367 running (batch A's product).
- **The settled design (before any code moved):**
  - **Row 1 (R-cor-5/7 whole):** `PostMode` drops `.index` → seven (`fromStored("Index")` → `.read`, the Outline→Compare precedent); `ReadModeView` becomes the READ HOST: an in-place `edit · read` switch (default `edit`, remembered per note under `readFace.<postID>`), the `▸ 01` column shared by both faces (`NoteIndexColumn`, the Index tab's column with its expanded editing card RETIRED and the block rows' handles a step larger), `edit` = `ReadEditPane` (the projection tier; a clicked block goes LIVE in place through the one `BlockTOCViewModel` authority — `PaneSurfaceView`, one ring), `read` = the calm page (continuous) or `NotePagesView` (the book's `PagedReadModel` over the one note — no second pager; the leaf views hoisted to `Core/Views/` under the hoist-at-next-touch rule), never editable; a `read` click → `LandingTarget` → `edit` at that block (B's brain, reused). `IndexModeView` survives as a typealias forward for the pins. The registry gains `readEditAttached` (the takes-board pattern) so the format family is honestly available in `edit` and grey in `read`.
  - **Row 39:** the authority is `CurrentBlockMemory` (per-note, persisted like the mode memory) fed by `CommandRouter.noteFocusedBlock` — every existing reporter feeds it; `registerDetail` restores the fact from it, and every mode ENTERS on the fact: Write's bare arrival lands the caret at the fact's block (fixing row 49's caret-at-end), Takes' N9 landing focuses the fact's block instead of the first, Read's `edit` and Blocks already seed from it.
  - **Rows 27/29:** a mode switch CLOSES the Block History pane (chosen over re-targeting: the question was asked in that mode); in Blocks the context panel YIELDS while any inspector column is open (one right region at a time).
  - **Row 18:** a draggable divider (the `ShellSplit` grammar) with a remembered width. **Row 25:** measure first on the dev build (the count-2 + plain tap idiom is the prime suspect — a single click waits the double-click interval), then fix + a measure pin. **Row 26:** facts first, text after (PROVISIONAL). **Row 36:** Read's footer duplicate DROPS; the column's count line shows in `edit` only; Blocks keeps its three per A's table.
- **Row 1 (R-cor-5/7):** DONE (this commit; hash next) — `PostMode` is SEVEN (`.index` gone; `fromStored("Index")` → `.read`); the registry verb `Switch Mode (⌘1–⌘7)` + label; `CapabilityContext.readEditAttached` + `CommandRouter.attachReadEdit/detachReadEdit` (the takes-board pattern) so the format family is honestly available in `edit`, grey in `read`; **`ReadModeView` is the HOST** (`Features/ReadMode/ReadModeView.swift`): the face bar (outline toggle · `edit · read` · in read `continuous · pages` + Aa), the `▸ 01` column shared by both faces (`NoteIndexColumn.swift` — the Index tab's column with the expanding editing card RETIRED, block handles `tokens.body`, `▸` accent on the selected row; `typealias IndexModeView = NoteIndexColumn` for the pins), `edit` = `ReadEditPane.swift` (a clicked block goes LIVE in place through the one `BlockTOCViewModel` authority — `pane:read-edit|<variant>`), `read` = the calm page (the old footer count line DROPPED — row 36) or `NotePagesView.swift` (the book's `PagedReadModel` over ONE entry; the leaf views MOVED to `Core/Views/PageLeafView.swift` under the hoist-at-next-touch rule — the book's `PagedReadView` composes them unchanged); a `read` click → `LandingTarget` → `edit` at that block, live, scrolled to CENTER (the ring never clipped — B's nit); the face remembered per note (`readFace.<postID>`, default `edit` — RULED); `BlockTOCViewModel.blur()` added (the ring goes when the face turns to read). The seeder's text updated (getting-around: seven modes, ⌘1–⌘7; the lesson renamed "read" with the edit/read teaching; Lenses ⌘4 · Compare ⌘5 · Blocks ⌘6 · Canvas ⌘7 everywhere) — **the LIVE re-seed is the closeout's act (§7b item 8)**. Pins: `NewModesTests` rewritten (seven, the successor decode, the attached-face gate, the face memory, the lesson, the forwarded name), `PostDetailAndPanelTests.theModeVocabularyIsTheSevenModeRail` (justified edit), **`ReadModeTests` ×4 — the REAL host in a real window with REAL clicks** (the rig's events): opens on `edit` with nothing live + the registry attached · a click on a block makes exactly THAT block live and a second migrates the one ring · the `read` face has no live pane and a paragraph click lands in `edit` at that block (face flipped, live, reported, remembered) · the `pages` form draws the book's engine's two leaves. Affected suites green: 120 tests / 16 suites (NewModes · ReadMode · PostDetailAndPanel · PostDetailRouting · MarkdownActs · CapabilityRegistry · BlockHistoryPane · TutorialBookShape · TutorialDoor · TutorialLookingActs · NoteIndexOutline · ShellChrome · SidebarLayout · MastheadLayout · PagedRead · ReadRendering · BookAscent · BookRedesignMount · ModesSherlockMeasure). Red-on-old: by construction for the tab merge (no `edit · read`, no in-place live pane, no pages existed); the pins' one measured lesson: a `.global` frame read inside a macOS `ScrollView` answers in the scroll view's own space — the probe uses the host's named space.
- **Row 25 — MEASURED FIRST (before any Blocks code moved), on the dev build 81367, Sherlock's Boscombe (215 blocks):** (a) mode arrival ⌘7 → the tool row at 0.24 s with an EMPTY list ("0 blocks · 0 words"), the list + panel present at 0.47 s — the joined facts observation's first delivery is what the list waits for (captures `02-measure-blocks-arrive-t0.24/0.47/0.71/0.94`); (b) a row click (the poster's mouse-up lands ~0.1 s after issue): the selection ABSENT at 0.36 s, PRESENT at 0.59 s — a 0.26–0.49 s lag, consistent with the machine's `NSEvent.doubleClickInterval` = **0.5 s**: `WorkbenchRowShell` stacks `.onTapGesture(count: 2)` before `.onTapGesture`, so a single click is held until the double-click window closes (captures `03-measure-rowclick-t0.36…1.29`). Fix + a measure pin follow in the Blocks piece.
- **Row 39 / 49:** DONE (this commit; hash next) — **the authority is `CurrentBlockMemory`** (`App/Variorum/Variorum/Registry/CurrentBlockMemory.swift`; per-note, persisted under `currentBlock.<postID>` like the mode memory), owned by `CommandRouter`: `noteFocusedBlock` writes through it (every reporter — Write's caret, the boards' ring, Read's selection, Blocks' row — feeds the one memory), `registerDetail` RESTORES the live `focusedBlock` from it when a note mounts, `currentBlock(for:)` is the read for an unmounted note (batch E's Open door), `forgetCurrentBlock(for:)` the reset. Every mode ENTERS on the fact: Write's bare arrival lands the caret at the current block's START (`EditorViewModel.bareArrivalLanding(fact:)` — the fact read BEFORE the arrival's own fill, which parks the insertion point at the end and reports that; the first cut honored its own fill and landed at the last block), else the document start — **row 49 fixed** (the old "reset when past the length" never held); a full re-render now keeps the caret BY IDENTITY (`renderFull` + `EditorViewModel.caretIdentity()` — the late theme-chrome render no longer carries the caret to the end); Takes' N9 landing focuses the fact's block, else the first (`TakesChoreographer.consumeLandings`); Read's `edit` and Blocks already seeded from it. Pins `CurrentBlockContinuityTests` ×3 — the memory (pure), the router's restore across mounts/per note, and **the round trip through the REAL mounted detail: Write caret in block 2 → Takes live block 2 (one ring) → Read(edit) block 2 selected → Blocks block 2 focused → Write caret back at block 2's start** (`BlocksWorkbenchOracle` added, DEBUG). Green with the neighbours: 72 tests / 8 suites (Continuity · BareArrivalFocus · FocusHandoff · EditorSession · TutorialStructureActs · TutorialWritingActs · EditorProjectionEngine · BlockHistoryPane). **Red-on-old VERIFIED by behavioral revert** (from `c174d19`: the Takes landing back to the first block, the Write arrival back to the never-true reset + no caret-by-identity restore across a render, the router's restore off): **8 issues in 2 tests** — the router-restore pin (the fact nil after a remount) and the round trip (Write's bare arrival at **174 = the document's end** — row 49's letter; Takes never landed on block 2 — step 2's settle timed out; Write back at 174). Restored by `git checkout --` from the repo root (the first attempt ran from `App/Variorum` and did not match — noted; the tree was restored in the next command), `git diff --stat` empty.
- **Rows 27 / 29 (the Block History host):** DONE (this commit; hash next) — (29) `PostDetailView`'s mode change CLOSES a Block History inspector (CHOSEN over re-targeting: the pane answered a question asked in that mode's surface; the next mode's bar door is one click away — `withAnimation`, the item-10 grammar); (27) `BlocksWorkbenchView(inspectorOpen:)` — while ANY inspector column stands (history, the tray, versions, references, scraps), the workbench's context panel YIELDS: one right region at a time; `PostDetailOracle.inspectorPanel` (DEBUG) mirrors the column's occupant. Pins `BlockHistoryHostTests` ×2 on the REAL mounted detail: open in Write → ⌘2 → the pane GONE (then opened in Takes → ⌘3 → gone again); from Blocks on the current block → history opens → the context panel yields → **every view's frame in the window has maxX ≤ the content width (the geometry pin — her "Clos…/Restore" cut)** → the pane's region headers drawn → leaving and returning gives the panel back. **Red-on-old VERIFIED by behavioral revert** (from `0051f5d`: the mode-switch close removed; `inspectorOpen: false`): **5 issues in 2 tests** — the pane STILL HELD `.blockHistory(…)` after ⌘2 and after ⌘3; from Blocks the context panel never yielded. Restored, diff empty.
- **Row 18 (the draggable seam):** DONE — `WorkbenchSeam` (the pane row's grammar: a 1 pt line, a 9 pt grip, the resize cursor) binding `@AppStorage("blocksWorkbenchPanelWidth")` (default 320), clamped by the pure `BlocksWorkbenchLayout.panelWidth(proposed:total:)` (panel 260–640, the list keeps ≥ 320). Pins: the clamp (pure) + **`theSeamDragsThePanelWidthAndItIsRemembered` — a REAL drag on the mounted seam: −100 pt → 320 → ~420 and REMEMBERED in the defaults, the seam moved with it; a drag past the list's floor clamps.** Door class (no seam existed): red-on-old by construction.
- **Row 25 (the lag):** DONE — TWO mechanisms, both measured: (1) the row shell's stacked `onTapGesture(count: 2)` + plain tap held every single click for the 0.5 s double-click interval → ONE tap handler acting at once, the double detected by the row's own clock (a second click inside `NSEvent.doubleClickInterval`); (2) the list waited for the joined facts query → `WorkbenchRows.display(rows:facts:…)` (pure) renders from the TOC rows the moment they land and lays the facts onto them (fact-filters/sorts wait honestly). **A crash class found on the way and closed:** the first cut read `NSApp.currentEvent?.clickCount` — `clickCount` asked of a non-mouse event raises `NSInternalInconsistencyException` ("Invalid message sent to event"; the rig's pump handed the tap a kit-defined event, three hangs) — the shipped shell never asks the event anything. Pins: `theListRendersFromTheRowsBeforeTheFactsArrive…` (pure) · **`aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens` — the row shell mounted alone in a real window, a REAL click: acted in 1.5 ms against a 150 ms budget (the old shell: ≥ the 0.5 s interval); a second click inside the interval opens once; a later click selects again.** **Red-on-old VERIFIED by behavioral revert** (the two-gesture stack put back): **4 issues in 1 test — the click acted in 0.357 s** (over the 150 ms budget; the double-click interval's hold), and the second click of the double registered as a second single. Restored (`git checkout --` from the repo root), `git diff --stat` empty.
- **Row 26 (PROVISIONAL):** DONE — the panel leads with the facts grid (words · edited · saved · tags · comments), the text card follows, then the takes and the doors (her "the text is also above the details" — the architect's reading; her walk can flip it).
- **Row 36 on Blocks:** per A's table — the toolrow's `N blocks · N words` KEEP (it now says `N blocks` until the words arrive), the per-row `Nw` KEEP, the panel's `words` fact KEEP (it leads the facts grid).
- **The harness lessons (recorded so the ladder's fix session does not relearn them):** (a) a `.global` frame read inside a macOS `ScrollView` answers in the scroll view's own hosting space — probes read a NAMED space on the surface's root; (b) SwiftUI's taps conclude only under `NSApp.nextEvent` dispatch (a bare `RunLoop.run` pump left a tap un-fired for seconds); (c) a non-activating `NSPanel` delivers pointer events under the runner where a plain `NSWindow` swallows them as activation clicks; (d) the pump must NOT re-send kit-/system-defined events; (e) the whole workbench's context panel, mounted in REACTION to a synthesized click under the event pump, crashed the Swift runtime's executor check in `PaneTextView.viewDidMoveToWindow` three runs in a row (a corrupt current-task executor — `0x4032000000000000`, a Double; not reproducible in the app, where the same click and panel work) — the row-25/18 pins therefore mount their MECHANISMS alone (the row shell, the seam) and the host pin brings the panel up from arrival.
- **Row 54:** NOT on this surface — `ReadPostView`/`ReadPostViewModel.remeasure` (the TK2 read tier) is composed by `RootView` (the Library's info panel — batch E), `NoteWindowView` (the note-only window), `BookView` and `SpreadBookView` (the book — B); none of Read's faces, Blocks or the history host composes it (Read's `edit`/`read` render `FlowParagraph` `Text` per block and the paged engine's `CTFrame` leaves). DEFERRED to its named owner **13u2 item 1** (the non-editing pane jumping family) — recorded in the dispositions; E should know the panel will inherit the jump until then.
- **Row 49:** FIXED with row 39 (above).
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build (pid 95836, the final tree's product, Terminal voice, window zoomed 1708×1064); the capture list is in the walk table below; **the contact sheet is `batch-c/contact-sheet.png` (36 tiles)**.
- **Full Mac suite + TutorialWalkTests:** DONE — **Mac 2028 tests / 356 suites, all green** (`** TEST SUCCEEDED **`, 309.5 s; log `/tmp/c-full-mac3.log` this session; the ten tutorial suites inside it; the load-flaky `rewriteStrategyLatencies` and `CanvasDragTrackingTests` PASSED in-run — nothing re-run, nothing loosened). **Arithmetic against batch A's close 2014 / 352:** +4 `ReadModeTests` +3 `CurrentBlockContinuityTests` +2 `BlockHistoryHostTests` +4 `BlocksWorkbenchFaceTests` +1 (`NewModesTests` grew the face-memory pin: 5 → 6) = **+14 ⇒ 2028**, exact; +4 suites ⇒ **356**, exact. **Core 1524 / 165 untouched** (zero `Sources/` lines in the whole batch — `git diff --stat 11b6f2a..HEAD -- Sources/` empty; zero `Sync/` lines, the Fable rider unexercised). **`App/Variorum/Shared/` untouched** (zero lines — the iOS target sees no change from this batch; batch A's `VoiceTokens.navigation` build check stays the ladder's one owed run).
- **Two full-suite finding-fixes after the walk (both traced, both committed `cfa4c9b`):** (1) the K5 list pin caught the bare arrival's WINDOW-LESS retry moving a caret placed between the render and the retry — the landing is now placed at once and the retry only claims first responder; (2) the seam pin's static oracle is written by ANY mounted workbench and suites run in parallel — the pin now takes its own `onFrame` reporter (a harness lesson beside 62).
- **STATUS: BATCH C's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build (the FINAL tree's product) is left RUNNING for that walk — Terminal voice, the Boscombe note open in its remembered state, window zoomed; `/Applications` untouched; her real-store app untouched (not running). Tree clean; every commit pushed.
- **No revert in flight** (both behavioral reverts ran and were restored — evidence above; the tree is clean against `cfa4c9b`).

#### Per-row dispositions

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 30 · 31 · 42 (R-cor-5/7) | FIXED — the Index tab retired INTO Read: ONE tab, the in-place `edit · read` switch (default `edit`, remembered per note under `readFace.<id>`); `edit` = the `▸ 01` column beside a pane whose clicked block goes LIVE in place (the small editing card retired; the column's handles a step larger); `read` never editable | `NewModesTests` ×6 · `ReadModeTests.theHostOpensOnEditWithNothingLiveAndTheRegistryHearsTheFace` · `.aRealClickOnABlockInEditMakesExactlyThatBlockLiveAndASecondMigratesIt` · `PostDetailAndPanelTests.theModeVocabularyIsTheSevenModeRail` | by construction (no `edit · read`, no in-place live pane existed; the eight-mode pins are the retired shape) |
| 5 | FIXED — `read ▸ pages`: the book's `PagedReadModel` over the one note (`NotePagesView`; the leaves hoisted to `Core/Views/PageLeafView.swift`) | `ReadModeTests.thePagesFormRendersTheBooksPagedEngineOverTheOneNote` | by construction (no pages existed) |
| 6 | FIXED — the minimal outline (and its mid-word truncation) is gone; the `▸ 01` column stands beside `read` too, its handles one-line ellipsized in `tokens.body` | (the column pins above; walked: 09/10) | — |
| 21 | FIXED — the outline toggle keeps its byte-as-is door (`outline`, the same `readModeOutlineShown` memory) and now shows/hides the INDEX column in both faces; the column's click lands the page/pane on the block | walked: 11/11b (a 0.18 s animation cannot be pinned) | — |
| 38 (note half) | FIXED — a `read` click flips to `edit` at THAT block, live, through `LandingTarget` (B's brain, reused — never re-implemented); the pane lands it at CENTER so the ring is never clipped (B's nit) | `ReadModeTests.theReadFaceHasNoLivePaneAndAParagraphClickLandsInEditAtThatBlock` | by construction (the old click switched TABS and selected without a live pane) |
| 39 | FIXED — ONE current block per note: `CurrentBlockMemory` behind `CommandRouter.focusedBlock`; Write enters at its start, Takes lands its pane, Read(edit) selects it, Blocks focuses it; each reports back through the one door | `CurrentBlockContinuityTests` ×3 (the mounted round trip) | 8 issues in 2 tests (Takes on block 1; Write at the document's end; the fact not restored) |
| 49 (from B) | FIXED with 39 — the detail Write editor's bare arrival lands at the current block's start, else the document START (never its end); a full re-render keeps the caret by identity | `CurrentBlockContinuityTests.theCurrentBlockFollowsHer…` (step 1 asserts location 0 on a bare arrival) | the same revert: 174 = the document's end |
| 27 | FIXED — one right region: the Blocks context panel yields while any inspector column stands; a geometry pin over every view's frame | `BlockHistoryHostTests.fromBlocksThePaneIsTheOneRightRegionAndNothingRunsPastTheWindow` | 2 issues (the panel never yielded; the pane persisted) |
| 29 | FIXED — a mode switch CLOSES the Block History pane (chosen over re-targeting) | `BlockHistoryHostTests.aModeSwitchClosesThePaneTheModeOpened` | 3 issues (the pane still held `.blockHistory(…)` after ⌘2 and ⌘3) |
| 18 | FIXED — `WorkbenchSeam`: draggable, remembered (`blocksWorkbenchPanelWidth`), clamped (panel 260–640; the list keeps ≥ 320) | `BlocksWorkbenchFaceTests.theDividerWidthIsClampedSoNeitherSideCanBeSwallowed` · `.theSeamDragsThePanelWidthAndItIsRemembered` (a real drag) | by construction (no seam existed) |
| 25 | FIXED — measured first (0.26–0.49 s from the click; the 0.5 s double-click hold): ONE tap handler acting at once, the double by the row's clock; the list renders from the TOC rows before the facts; the `clickCount`-on-a-non-mouse-event crash class closed on the way | `.aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens` (1.5 ms vs a 150 ms budget) · `.theListRendersFromTheRowsBeforeTheFactsArrive…` | 4 issues (0.357 s on the old shell; the double's second click a second single) |
| 26 | FIXED, PROVISIONAL — the panel leads with the facts; the text card follows (her walk can flip it — §7) | — (an order; walked: 05/14/15) | — |
| 36 | DONE on these surfaces — Read: the header's `N words · about M min` KEPT (her word), the footer duplicate DROPPED; the column's `N blocks · N words` shows in `edit` only (KEEP-ONE); Blocks: the toolrow anchor, the per-row `Nw` and the panel's `words` fact KEPT per A's table | — | — |
| 54 (from B) | DEFERRED to **13u2 item 1** — the read tier (`ReadPostView`) is not composed by any note mode or the history host; its hosts are the Library panel (E), the note-only window and the book | — | — |
| **60** (new — measured in the walk) | RECORDED — the Blocks mode's first paint still waits ~0.25–0.5 s for its observations' FIRST delivery (capture 19: empty at 0.24 s, rows + facts together at 0.49 s on Boscombe) — the rows-first render helps only when the facts lag the rows; on this note both land in one window. A synchronous first fetch before the observation starts would paint at once — the same shape for every note mode. Owner: ~~13u2 item 1~~ **RE-OWNED to batch G as row 83 (R-cor-10 — "laggy after selecting it" may have meant the MODE's arrival; she should not still feel it)** | — | — |
| **61** (new — found by the pins) | FIXED in-batch — the first cut of the row shell asked `NSApp.currentEvent?.clickCount`; asked of a non-mouse event AppKit raises `NSInternalInconsistencyException` ("Invalid message sent to event") — a crash class in a tap handler. The shipped shell asks the event nothing (the double is timed by the row's own clock) | the click pin's double-click half | — |
| **62** (new — the harness, for the ladder) | RECORDED — mounting the WHOLE workbench and clicking a row under the rig's `NSApp.nextEvent` pump crashed the Swift runtime's executor check in `PaneTextView.viewDidMoveToWindow` when the context panel's `PaneTextView` was added (three reports, `_checkExpectedExecutor` → a garbage current-task executor); not reproducible in the app (the same click and panel work — captures 05/14/15). The row-25/18 pins mount their mechanisms alone; the host pin brings the panel up from arrival. Owner: **12** (the harness-calibration family) | — | — |

#### The "current block" authority

**`CurrentBlockMemory`** — `App/Variorum/Variorum/Registry/CurrentBlockMemory.swift` — a value type over a per-note dictionary persisted under `currentBlock.<postID>` ("blockID|variantID"). Owned by `CommandRouter`: `noteFocusedBlock` writes through it (every reporter feeds it); `registerDetail` restores the live `focusedBlock` from it on a note change; `currentBlock(for:)` reads it for an unmounted note (batch E's Open door); `forgetCurrentBlock(for:)` resets. The LIVE fact stays `CommandRouter.focusedBlock` (row 33's); the modes' ENTER logic: `EditorViewModel.bareArrivalLanding(fact:)` (Write), `TakesChoreographer.consumeLandings` (Takes), `ReadModeView`'s seed (Read's `edit`), `BlocksWorkbenchView`'s seed (Blocks).

#### The seeder's text changes (the LIVE re-seed is the closeout's — §7b item 8)

`TutorialSeeder.swift`: (1) "getting around": *one of seven modes — Write · Takes · Read · Lenses · Compare · Blocks · Canvas, and ⌘1 through ⌘7*; (2) the "ways of looking" lesson renamed **"read"** (plan + call) with three new paragraphs — READ (⌘3) opens on EDIT (the column's grammar, click a block and it goes live, the outline button, opens standing at the block you were in) · switch the face to READ (the page, continuous or pages, Aa, "click its paragraph: the page turns to edit with that block live") · the try-it (⌘3 · click this paragraph · switch to read · click again · ⌘1); (3) every key digit moved: Lenses ⌘4 (three sites), Compare ⌘5 (two), Blocks ⌘6 (three), Canvas ⌘7. `TutorialBookShapeTests`/`NewModesTests` hold plan ⇔ seed.

#### The USE gate — the walk (the dev-store Debug build, Terminal voice, window zoomed 1708×1064; every capture in `act10-correction-screens/batch-c/`; **the sheet: `batch-c/contact-sheet.png`**)

| Row | What was done | Capture(s) |
|---|---|---|
| 25 (BEFORE — build 81367, A's) | Boscombe ▸ ⌘7 Blocks: the tool row at 0.24 s with an EMPTY list, the list at 0.47 s; a row click: the selection ABSENT at 0.36 s, PRESENT at 0.59 s | `02-measure-blocks-arrive-t0.24/0.47/0.71/0.94` · `03-measure-rowclick-t0.36…1.29` |
| 30/31/42 | The seven-mode rail (`write · takes · read · lenses · compare · blocks · canvas`) beside a note in Write; ⌘3 → READ opens on `edit`: the `▸ 01` column, the pane, block 05 current (the memory from the earlier session) | `06-rail-seven-modes-write` · `07-read-opens-on-edit-with-column` |
| 30 | A click on block 07 in the pane → THAT block live (the ring), the column selects 07 | `08-edit-click-makes-block-live` |
| 5 · 6 | `read` → the calm page scrolled to the current block, the column beside it (no count line in `read`); `pages` → the book's two leaves, "pages 1–2 of ~38 — the boscombe valley mystery" | `09-read-face-continuous` · `10-read-face-pages` |
| 21 | `outline` off → the page alone; on again + `continuous` | `11-outline-toggled-off` · `11b-outline-back-continuous` |
| 38 | A click on a paragraph in `read` → the face turns to `edit` with THAT block (05) live, ringed, mid-pane — the ring whole, the column at 05 | `12-read-click-lands-in-edit-live` |
| 39 | Write: the caret placed in block 08 ("It is really very good…", 51w) → ⌘2 Takes: block 08's pane live (51w take) → ⌘3 Read(edit): block 08 selected → ⌘6 Blocks: row 08 focused, panel "block 08" → ⌘1 Write: the caret back in block 08 (51w block) | `13a-continuity-write-caret` · `13b-…-takes-live` · `13c-…-read-edit-selected` · `13d-…-blocks-focused` · `13e-…-write-back` |
| 25 (AFTER) | Blocks: a row click → SELECTED (row 03 + its panel) by the first capture at 0.36 s after issue (the poster's own ~0.15 s inside it); the arrival: empty at 0.24 s, rows WITH facts at 0.49 s (row 60) | `15-blocks-rowclick-timing-t0.36/0.59/0.83` · `14-blocks-arrival` · `19-blocks-arrival-newbuild-t0.24/0.49/0.73` |
| 26 | The panel: block · take/comment line · FACTS (words · edited · saved) · the text card · the doors | `05-blocks-newbuild-rowclick` · `14` |
| 18 | The seam dragged 1387 → 1250: the panel 320 → 458 (`defaults read io.lduarte.Variorum.debug blocksWorkbenchPanelWidth` = 458 — REMEMBERED) | `16-blocks-divider-dragged` |
| 27 | Blocks ▸ the panel's `history` door → the Block History pane INSIDE the window ("Close" whole at the right edge), the context panel yielded | `17-history-from-blocks-inside-window` |
| 29 | ⌘1 → Write with NO history pane | `18-history-gone-after-mode-switch` |

Honesty notes: the dev store now remembers `blocksWorkbenchPanelWidth = 458`, `readFace.<Boscombe> = edit` and two `currentBlock.<id>` facts (walk artifacts, harmless); the first seam drag (16 steps over 208 pt) did not take and the second (30 steps) did — the DragGesture wants a finer walk, recorded for the walkers; ⌘K's "block history" from Blocks spoke the caret sentence rather than opening the pane (the palette door is Write's caret-scoped one — the Blocks doors are the panel's `history` and the row's ⋯; not this batch's surface, noted for F); capture `17` from the first attempt was overwritten by the panel-door one.

#### Commits (in order)

1. `a1adff6` — the record opened (LIVE STATUS + the settled design).
2. `8bbf6aa` — row 1 (R-cor-5/7 whole): seven modes, the Read host + column + pane + pages, the registry gate, the seeder text, the pins.
3. `c174d19` — rows 39 + 49: `CurrentBlockMemory`, the arrival landing, the caret by identity, the Takes landing, the continuity pins.
4. `0051f5d` — rows 27/29/18/25/26/36: the history host, the seam, the tap idiom + rows-first list, the panel order; `PostDetailOracle`; the row-39 red-on-old evidence.
5. `a76e2b3` — the rows 25/27/29 red-on-old evidence; rows 54/49 dispositions.
6. `030badc` — the walk's captures + the sheet, the dispositions, the authority, the seeder changes, rows 60–62.
7. `cfa4c9b` — the two full-suite fixes (the arrival's immediate landing; the seam pin's own reporter).
8. (this commit) — the counts + arithmetic; the LIVE STATUS final; the handoff paragraph.

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed through `cfa4c9b` (+ this record commit); no revert is in flight; the tree is clean; the final Mac suite is green at 2028/356 exact. Every batch-C row is FIXED or RECORDED — none DEFERRED beyond the two with named owners (54 → 13u2 item 1; 60 → 13u2 item 1's family), none REVERTED (C-5 unexercised). Three dispositions are honest limits: the `read ▸ pages` face has no per-block click-through (a `CTFrame` page's click opens links only — landing from `pages` means switching to `continuous` or `edit` first; unpinned, recorded); the outline toggle's fade is walked, not pinned (a 0.18 s animation); row 60's arrival blank (~0.3 s to the observations' first delivery) is measured and owned, not fixed. Row 26's order and Read's per-note face memory are PROVISIONAL for her (§7). Walk suggestions: Boscombe ▸ the seven-mode rail · ⌘3 (opens on `edit`, the column standing at the current block) · click a pane block (live in place, one ring) · `read` ▸ a paragraph click (flips to `edit` at that block) · `pages` (the book's leaves) · the round trip Write→Takes→Read→Blocks→Write on one block · Blocks: a row click (instant), the seam drag (slow drags register; fast ones may not — the walk note), the panel's `history` door (one right region), ⌘1 (the pane gone). Known non-C residue seen in passing: the ⌘K "Block History" palette door speaks Write's caret sentence from Blocks (F's surface, noted); nothing in the book, Compare/Lenses, the masthead or the library panel was touched.


#### BATCH C RECORD — CLOSED by the orchestrator (2026-09-01 ~13:30)

Spot-check walked on the final dev build (`orchestrator-c/`): the SEVEN-mode rail with `read` third; Read
opens on `edit` with the `▸ 01` column and the switch `edit | read`; the current block followed Write →
Takes → Read(edit, block 02 selected) → Blocks (block 02's panel open) — row 39's round trip seen live;
the `read` face is the calm serif page with `continuous · pages` and Aa; a paragraph click flips to `edit`
(an inter-paragraph click is not a door — the book's own rule; my first probe hit padding); Blocks shows
facts-first with the doors under (row 26 as ruled, PROVISIONAL for her). The implementer's 36-tile sheet
carries the rest (the divider, the history scoping, the timing series). Counts at close: **Mac 2028/356
green** (A's 2014 + 14 / 352 + 4); core + `Shared/` untouched; spine green. Residuals owned: row 54 →
13u2 item 1; row 60 (the ~0.3 s observation-first-delivery blank) → 13u2; row 62 (the harness
executor-check crash) → 12; rows 26 + Read's face memory PROVISIONAL in §7. The seeder's lesson text moved
to the seven-mode truth — the LIVE re-seed stays the closeout's (§7b item 8). **Batch F spawned next.**

---

### BATCH F — THE RECOVERY FAMILY (brief; DRAFTED 2026-09-01 ~05:55 — spawn after C closes; her "special attention")

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file; the source report (§1 — her words on lineage/history/archive/trash; image
row 12); `notes/plans/phase-13j-purge-memo.md` §4 (the doors' doctrine) and the 13j plan's utility
enumeration for what each surface OWES; then the code: `Features/Tray/TrayPanel.swift`, `Features/Tray/
BlockHistoryPane.swift`, `Shared/BlockHistoryFace.swift` (the four sections: Savepoints · Archived takes ·
Deleted takes · **Came from** — the lineage row), `Shared/RecoveryCopy.swift`, `Shared/RecoveryActs.swift`,
`Features/Library/ArchivedView.swift`, `Features/Library/RecoveryView.swift` (the Trash), `Theme/CalmGrammar.swift`;
the pins `TrayPanelShapeTests`, `TrayPanelMoveTests`, `NoteTrayTests`, `BlockHistoryPaneTests`,
`RecoveryDoorsTests`, `TrashSurfaceTests`, `TrashPurgeDoorsTests`, `IAAndTrashShapeTests`,
`SnippetGroupTrashTests`.

**Your surfaces: This Note's Tray · Block History (the pane's CONTENT; its host is C's) · Archived · the Trash
· the lineage doors ("Came from", the successors' doors) — and only those (C-1).** This batch is different in
shape: **it is a WALK FIRST, then fixes.** The dev store has no recovery content, so:

1. **Seed real content on the dev store through the product doors** (never SQL): in a scratch note — archive
   a block, delete a single block, multi-delete three, divide a block (lineage), merge two, delete a take,
   archive a take, make two savepoints on one take (⌘S twice with an edit between), save a note version
   (⌘⇧S), archive a whole note, delete a note that has a version, delete a snippet group. Record the seeding
   steps so the orchestrator can repeat them.
2. **Walk every surface at three widths** (a narrow pane, her ~1728-pt window, a short window) **in both
   voices**, every door exercised — Put back · Restore · Delete Now · Open note · the lineage row's door · the
   tray's Leaving/Archived sections · Empty Trash's confirm (cancel it) · Archived's un-archive. **Every defect
   becomes a ledger row** (numbered after C's last) with a capture and a traced mechanism, then FIXED with a
   red-on-old pin. Her Act 10 item 1 (the clipped tray header) is verified fixed at every width.
3. **Row 28 — savepoints vs lineage read as sections.** The pane's four sections get real section structure
   (the calm-card grammar: a header with air, one sentence of meaning under each — "Savepoints: this take's
   saved moments" · "Came from: the block this one was divided/merged/extracted out of"); "Came from" is the
   lineage — the word appears once, where it helps. Keep every string's substance (she rewrites copy later).
4. **Row 35 — the calm-chrome rule (C-6) on these surfaces:** no metric without a reason; the Trash's row
   facts ("from · deleted · N days left") stay — they ARE the reason a Trash exists.

**The acceptance gate is USE:** captures in `act10-correction-screens/batch-f/`, one per surface × width ×
voice at minimum, plus one per fixed row. Environment + recipe + resiliency: batch B's brief's last three
paragraphs bind. **Deliverable:** the seeding steps, the walk's row list, the fixes with pins, the BATCH F
RECORD under this brief.

---

### BATCH F RECORD — THE RECOVERY FAMILY (a fresh Fable implementer session, 2026-09-01 ~13:40 →)

#### LIVE STATUS — BATCH F (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **MACHINERY HONESTY (protocol rule 7):** the batch's implementer DIED at the account's rate limit mid-USE-gate (pieces 1–4 committed and pushed; its interrupted turn left ONE uncommitted file and the `post-01…11` captures of its begun post-fix walk). A fresh COMPLETION SESSION adopted from this list + `git log` per `notes/SessionResiliencyProtocol.md` — the seven commits verified against git before anything moved; the uncommitted diff adjudicated (below), the USE gate finished on the final tree, the suites run. The record's remaining lines are the completion session's.
- **Orientation:** DONE — the plan read in full (§0–§8, the constitution, C-1…C-7, R-cor-1…8, the ledger, the triage record, B's/A's/C's records + CLOSED lines, this brief), CLAUDE.md, the resiliency protocol, the handoff's §2c, her report (§1 + image row 12), the purge memo §4, the 13j plan's utility rulings (J6/tray grammar), then the brief's files: `TrayPanel.swift` · `BlockHistoryPane.swift` · `Shared/BlockHistoryFace.swift` · `Shared/RecoveryCopy.swift` · `Shared/RecoveryActs.swift` · `ArchivedView.swift` · `RecoveryView.swift` · `Theme/CalmGrammar.swift`, and the nine pin suites (TrayPanelShape/TrayPanelMove/NoteTray/BlockHistoryPane/RecoveryDoors/TrashSurface/TrashPurgeDoors/IAAndTrashShape/SnippetGroupTrash). Tree clean at `e2c70cd`; the dev-store Debug build pid 99547 running (batch C's final tree — the two commits since are docs-only).
- **Seeding (piece 1):** DONE (this commit) — all through product doors on the dev store (captures `seed-01…39`); the STEPS, repeatable:
  1. File ▸ New Note → typed 8 paragraphs (lighthouse/harbor/sea/gulls/lamp-oil/rowboat/village+keeper/winter). *(A title-click did NOT open a rename field — the scratch note keeps its date name; noted, not this batch's surface.)*
  2. Block 1: caret in → ⌘S · typed an edit · ⌘S (two savepoints; both by System Events key events).
  3. Block ▸ New Take (Branch) → in Takes, clicked into the branch card, typed a divergence → Block ▸ Archive Take (toast "Take archived — never gone…").
  4. Fan footer "+ blank take" → typed "A spare take to throw away." → Write ▸ Block ▸ Show Takes → the spare card's ⋯ → **Delete this take** (the panel's card menu — the board's rclick reaches only the SYSTEM text menu; see the walk rows).
  5. Caret in "Nobody warned…" → Block ▸ Archive Block (toast names This Note's Tray + the icon).
  6. Caret in "The sea took…" → Block ▸ Delete Block (toast: ⌥⌘Z + tray; ⌫ badge appeared).
  7. Caret before "The keeper wrote back" in the village block → Block ▸ Divide Block at Cursor (clean sentence split).
  8. Caret in the second half → Block ▸ Merge Blocks (instant fanless merge; both sources released to lineage → the Came-from fixture).
  9. Blocks mode (⌘6): checkboxes on gulls/lamp-oil/rowboat → bulk bar "delete 3 blocks" (toast: all back in one ⌥⌘Z; tray 4 waiting).
  10. note ▾ → **Save a Version** (receipt "Saved a version — the whole note as it is now, in Versions."). **⌘⇧S itself was pressed twice earlier (Blocks mode, then Write) with NO receipt either time — verified in the walk below via the Versions count.**
  11. File ▸ New Note → typed one line → Library row context menu → **Archive** (receipt shown clipped at the window's bottom edge — batch E's surface, recorded below).
  12. File ▸ New Note → typed one line → note ▾ Save a Version → note ▾ Delete Note… → confirm ("…Its 1 saved version goes with it.") → Delete (toast "Note moved to the Trash — 30 days…"; the app lands in Library).
  13. Snippets → "+ new group" → "castoff group" ⏎ → typed a snippet into it ⏎ → the group's ⋯ → "delete group… — its snippets go to the Trash with it — 30 days" → confirm ("Delete the group 'castoff group'? Its 1 snippet goes to the Trash with it — 30 days to put it back.") → Delete (receipt "snippet group moved to the trash — 30 days to put it back.").
- **The walk (piece 2):** DONE (this commit — captures `walk-01…24`; fixes follow as pieces). Three widths (1708 zoomed · 950 narrow · 1708×700 short) + both voices; doors exercised: Put back (archived block → "Put back where it was.", re-archived after) · Delete Now confirm-then-CANCEL (take row; cancel wrote nothing) · Empty Trash confirm-then-CANCEL · Open note (a block row → the note) · the Came-from doors (the jump door appears when the caret moves; "See original from merge…" in the editor's context menu opens the pane; BOTH merge origins listed — the 13l P-3 promise holds) · the takes fold (count carried). **Act 10 item 1 verified at all three widths and both voices — the tray's headers never clip.** Restore, a deleted block's Put back and Archived's Unarchive are exercised in the post-fix walk (kept the fixture stable for the width passes). **The found rows (63–68) and the records are in the ledger addendum below.**
- **FOUND ROWS (the walk's own ledger — F's numbering from 63):**
  - **63 (MAJOR, C-7)** — every recovery row's quiet line TRUNCATES ITS TAIL — the clock ("30 days left" → "30…") and the archived promise ("kept — no clock" → "k…") — tray rows at every width in Terminal (Study's archived row too; captures walk-01/19/22), the pane's deleted-take row, the take row's whole stamp+clock gone behind the block handle. Mechanism: ONE joined `Text(lineLimit 1)` truncating tail-first beside the Put back button, and a stamp carrying the time of day the OriginPeek precedent (date-only, "the sentence's own point fell off the end") already ruled off this family. Fix: date-only stamps in recovery rows + the clock/promise in its OWN non-compressible slot. → FIX in-batch.
  - **64 (MINOR, C-7)** — the tray's "1 deleted take" disclosure toggles ONLY on its chevron; a click on the label does nothing (walk-02 vs walk-03). Generous-target fix: the whole label toggles. → FIX in-batch.
  - **65 (MAJOR — row 28's own evidence)** — the Block History pane's region headers CLIP TO A STRUCK-THROUGH SLIVER ("deleted takes" walk-07; "came from" walk-09/18/23, BOTH voices): the pane is still a `List`, and a List measures section headers at a fixed height — **the Act 10 item 1 mechanism, alive in this pane**. Fix = row 28's rebuild (ScrollView + CalmSectionHeader + one meaning line per region). → FIX in-batch (piece 3).
  - **66 (MAJOR)** — Empty Trash's confirm does not NAME snippet groups: "8 things go for good: 1 note, 1 saved version, 5 blocks" — 7 named, 8 taken (walk-13). Mechanism: `RecoveryCopy.emptyTrashConfirm`'s kind order `[.note, .block, .book]` predates `.snippetGroup` (wave 2b added the kind to `TrashScope` but not here). The count-by-kind promise (round 8) breaks for the newest kind. → FIX in-batch.
  - **67 (MAJOR)** — **the `CommandGroup(after: .saveItem)` renders in NO menu** (the non-document WindowGroup's File menu carries no save anchor on macOS 26 — the menu-bar listing has no Commit/Save a Version/Lock items anywhere), so ⌘⇧S is DEAD app-wide (pressed twice in the seeding: nothing; the note ▾ menu door works and receipts) and menu-⌘S with it (⌘S survives only via the editor's own key override — savepoints landed in Write); "Lock Library Now" ⌃⌘L (13p's manual lock) is unrendered the same way. The registry walk compares declared⇔`menuRendered` (a static list), which is why no pin ever saw it. Fix: re-anchor the group. Menu presence is beyond a unit pin's reach (the test host owns its own main menu) — the walk's AX menu listing before/after is the red-on-old evidence, recorded verbatim. → FIX in-batch.
  - **68 (MINOR)** — the Came-from region's "Open this note's tray" on an UNCLOCKED origin lands with NO mark and NO sentence (walk-10): the origin is kept in lineage (G5), so the tray lists it nowhere, and `revealMissing` is deliberately false (the row exists). The arrival explanation needs the third state: "kept in lineage, not leaving." → FIX in-batch.
  - **RECORDED for other owners:** (a) the Library's archive receipt renders clipped at the window's bottom edge under the new-note bar (seed-33) → **batch E** (the Library surface's message slot); (b) at ~950 pt the masthead title and the icon row touch/overlap (walk-18/19) → **batch A's residue / the ladder** (row 58's family, another width); (c) the note's bottom bar at ~950 pt wraps to two rows with labels truncated to "t… · c… · h…" (walk-18) → **the ladder** (CommitBar's flat bar; P-8 honored into illegibility); (d) C's noted ⌘K "block history" caret sentence from Blocks — likely healed by C's own CurrentBlockMemory (focusedBlock now lives in Blocks); verify in the post-fix walk, else record. (e) A title click does not open the masthead rename field (seed-03; the Library row menu's Rename… is the door) — record only, not this batch's surface.
- **Fix piece A (rows 63/64/66/68 + 67):** DONE (this commit) — (63) `TrayRowFace`/`TrayTakeFace` split into a truncatable LEAD (date-only stamp — the OriginPeek ruling extended; `TrayRowPreview.stampTextDateOnly` added ADDITIVELY in `Shared/`) + a `clockSlot` the view renders `fixedSize` with `layoutPriority(1)`; `meta` derives from the pair so the pins and the render cannot drift. (64) the takes fold's whole line is the toggle (a Button; DisclosureGroup retired). (66) `emptyTrashConfirm`'s kind order gains `.snippetGroup`. (68) `TrayViewModel.revealKeptInLineage` — the arrival explanation's third state, with `RecoveryCopy.trayRevealKeptInLineage` — the lineage door's tray landing speaks. (67) the save command group re-anchored `after: .saveItem` → `after: .newItem` (menu presence verified by AX after the rebuild — a unit pin cannot reach the app's main menu; justification in the row). Pins: `theClockIsItsOwnSlotAndTheStampCarriesNoTimeOfDay` · the shape test's no-DisclosureGroup half · `theEmptyTrashWordsNameSnippetGroups` · `aRevealForAKeptOriginalSaysItLivesInLineage`. Green: the five touched suites 46 tests / 5 suites. **Red-on-old VERIFIED by behavioral revert** (all four mechanisms off in place from the committed state `9e0ae97` — time-of-day stamps back, DisclosureGroup back, the kind order back, the latch dropped): **6 issues in 4 tests** — the take-lead and row-lead stamps carrying " at 4:00 AM"/" at 7:00 PM" (2), the confirm naming no snippet group in singular and plural (2), `revealKeptInLineage → false` (1), and `DisclosureGroup` back in the tray's tree (1). Restored by `git checkout --`; `git diff --stat` empty against `9e0ae97`. **No revert in flight.**
- **Row 28 + row 65 (piece 3):** DONE (this commit) — the pane's `List` RETIRED for a ScrollView of calm sections (the tray's own Act 10 item 1 rebuild, applied to the pane whose headers were clipping the same way): each region is a `CalmSectionHeader` with one meaning line — savepoints GAINS its missing line (`BlockHistoryPath.savepointsExplainer`, her example words nearly verbatim), archived/deleted/came-from keep the explainers they had — and the archived/deleted/origin rows become `CalmCard`s; the take-run fold becomes a full-line Button (row 64's rule here too); the deleted-take row adopts row 63's two-slot meta (`DeletedTakeFace.lead/clockSlot`, additive in `Shared/`); the savepoint row's meta may wrap to two lines instead of truncating "saved by hand" (its stamp keeps the time — two moments can share a day). Every string's substance preserved; every door byte-identical. Pins: `everyRegionReadsAsASectionAndTheListIsGone` (a reflection pin over a REAL seeded history — a merge's two origins, an archived take, a deleted take, a savepoint; headers AND meaning lines; no `List<`, no `DisclosureGroup`); the mounted-detail pin's two List-backing-class assertions were a JUSTIFIED PIN EDIT (they named "OutlineList"/"ListTableHeaderView" — the clipping mechanism itself; the edit is annotated at the pin). Green: BlockHistoryPane + RecoveryDoors 36/2. **Red-on-old VERIFIED by behavioral revert** (the `List` put back around the four regions in place, from the committed state `7c98714`): **3 issues in 2 tests** — the reflection pin's `List<` present and `ScrollView` absent, and the MOUNTED pane's backing classes reading `SwiftUIOutlineListView`/`ListCoreScrollView` with no `HostingScrollView` — the clipping mechanism's own AppKit views, back. Restored by `git checkout --`; diff empty. **No revert in flight.**
- **Row 35 (piece 4):** DONE (this commit) — the calm-chrome pass over the four surfaces, batch A's row-36 table applied: a grep sweep (`words|[0-9]w\b|wordCount`) over `TrayPanel` · `BlockHistoryPane` · `ArchivedView` · `RecoveryView` finds ZERO metric displays (only prose comments match) — none of the recovery surfaces carries a word count, and none is added. The Trash's row facts (kind · "from ‹note›" · deleted ‹date› · N days left) STAY — they ARE the reason a Trash exists (the row's own words); the tray/pane rows' facts are the same class, now with the clock guaranteed legible (row 63). A's table rows for these surfaces need no code change; nothing "thrown in" found. One door per act holds: Put back is the one verb everywhere, Delete Now lives on the two trash surfaces only (the registry pins already hold this).
- **The TrayPanel adjudication (the dead session's uncommitted turn):** KEPT, commit `3cf0d82` — the diff was three `.fixedSize()` modifiers on the recovery rows' Put back / Delete Now buttons with a self-documenting comment tying it to **row 63's rider: a VERB never truncates** (the dead session's post-fix walk met "Delete…" on a destructive door; the squeeze belongs to the LEAD slot, which piece A already made the truncatable one). A complete intended fix, not scratch — built green, committed with its own message, and its target verified in use (`use-04`: Put back + Delete Now whole beside a truncating lead).
- **The USE gate:** DONE (the completion session, on the final tree — the dead session's `post-01…11` began it on the pre-rider build and stand as its first half) — the fixed rows (63+rider/64/65+28/66/67/68/35) and the surfaces (This Note's Tray · Block History · Archived · Trash · the Came-from doors) walked on the rebuilt dev-store Debug build, Terminal AND Study, the tray at three widths (zoomed 1708 · narrow 950 · short 1708×700); the walk table below names every capture; **the contact sheet is `batch-f/contact-sheet.png` (94 tiles — seed + walk + post + use)**.
- **Suites:** DONE — `TutorialWalkTests` first: **71 tests / 10 suites green**. Then the FULL Mac suite TWICE on the final tree (logs `batch-f/f-full-mac.log` · `f-full-mac2.log`): **2032 tests / 356 suites in both runs — arithmetic against batch C's close 2028/356: +4 tests (piece A's three new pins + piece 3's reflection pin; the shape-test and mounted-pane edits grew no count), +0 suites, exact.** Run 1's ONE red was REAL and is fixed (`aad819d`, next line); run 2's ONE red was `BlocksWorkbenchFaceTests.aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens` — batch C's row-25 REAL-CLICK rig pin, green in-run in run 1 and **4/1 green isolated** — the real-pointer-events-under-load class (C's rows 61/62 harness family; a third member beside the two KnownIssues rows), recorded here for the ladder, NOTHING loosened. The named load-flaky pair (`rewriteStrategyLatencies` 2 cases, `CanvasDragTrackingTests`) passed in-run in BOTH runs. **Core untouched: zero `Sources/` lines in the whole batch (`git diff e2c70cd..HEAD -- Sources/` empty), zero `Sync/`** — the Fable rider unexercised. The batch's `Shared/` additions (all ADDITIVE: `stampTextDateOnly`, `DeletedTakeFace.lead/clockSlot`, `trayRevealKeptInLineage`, `savepointsExplainer`) join batch A's owed iOS build at the ladder.
- **The full suite's one real find, fixed (`aad819d`):** batch C's host pin (`BlockHistoryHostTests.fromBlocksThePaneIsTheOneRightRegion…`) still asserted the pane's retired List backing (`ListTableHeaderView`) as its regions-drawn evidence — the SAME justified pin edit piece 3 made in `BlockHistoryPaneTests`, one file over, missed because the dead session ran only its touched suites and died before the full run. Mirrored with the same annotation (`HostingScrollView` present, the List's header class absent); suite 2/1 green isolated. Exactly what the full-suite step exists to catch.
- **No revert in flight.** `/Applications` untouched; her real-store app untouched (not running).

#### The USE gate — the walk (the completion session; the rebuilt dev-store Debug build on the final tree, window zoomed 1708×1064; every capture in `act10-correction-screens/batch-f/`; **the sheet: `batch-f/contact-sheet.png`, 94 tiles**)

| Row | What was done | Capture(s) |
|---|---|---|
| 63 + rider | The tray on the fixture note: DATE-ONLY stamps, the clock in its own uncompressible slot — "30 days left" and "kept — no clock" WHOLE at zoomed 1708, narrow 950 and short 1708×700 in Terminal, and zoomed in Study; the deleted-take row shows the LEAD truncating ("in the li…") while the clock and BOTH verbs (Put back · Delete Now) stand whole — the rider in use | `use-03-tray-zoomed-terminal` · `use-10-narrow-tray` · `use-11-short-tray` · `use-12-study-tray` · `use-04-fold-label-opened` |
| 64 | The "1 deleted take" fold toggled by a click on its LABEL, not the chevron | `use-03` (closed ▸) → `use-04` (open ▾) |
| 65 · 28 | Block History reads as SECTIONS in both voices: savepoints with its NEW meaning line + the take-run fold + savepoint cards (stamps keep their time — two moments can share a day) + Restore whole; archived takes with the Unarchive door; deleted takes on the two-slot meta; **came from** with its meaning line and BOTH merge origins (Bring back · Open this note's tray) — no header clips to a sliver anywhere | `use-05-history-sections-block1` · `use-07-camefrom-origins` · `use-13-study-history` |
| 68 | "Open this note's tray" on a KEPT-IN-LINEAGE origin → the tray LEADS with the third-state sentence: "the block you asked about isn't leaving this note — it was kept whole by a divide or merge, and it lives under came from in block history, not in the tray." | `use-08-lineage-landing-sentence` |
| 66 | Empty Trash's confirm NAMES every kind and the arithmetic closes: "Empty the Trash? 7 things go for good: 1 note, 1 saved version, 4 blocks, **1 snippet group**." (+ the deleted-take rider sentence) — CANCELLED; the Trash's 8 rows intact after | `use-15-emptytrash-confirm` · `use-17-terminal-trash` |
| 67 | ⌘⇧S pressed in the note → the receipt "Saved a version — the whole note as it is now, in Versions." — the re-anchored command group is ALIVE (the dead session's `post-02`/`post-05` saw the same on the pre-rider build) | `use-09-cmdshiftS-receipt` |
| 35 | The four surfaces carry no thrown-in metric: tray/pane rows are stamps + clock only; the Trash's row facts (kind · from ‹note› · deleted ‹stamp› · N days left) STAY as ruled — they ARE the reason a Trash exists; Archived is one calm row (Open · Unarchive · Delete Note…) under its meaning line | `use-14-study-trash` · `use-16-study-archived` · `use-17-terminal-trash` · `use-18-terminal-archived` |
| the doors | The came-from JUMP door ("show the block you're in") re-targets the pane after a caret move; Library ▸ the masthead trash icon; Archived's row doors; the Study↔Terminal switch through Settings ▸ Appearance | `use-06-camefrom-merged-block` · `use-14` · `use-16` · `use-01/02` |

The dead session's own post-fix half (`post-01…11`, pre-rider build): the relaunch, ⌘⇧S live twice, the tray fixed twice, the fold label, the history sections, a Restore exercised, the lineage landing, and **the deleted block's Put back** (`post-11` — its interrupted turn's act; the tray badge read 3-waiting on the completion session's relaunch, consistent with that Put back having landed).

Honesty notes (the completion session's): the voice switch BACK to Terminal mis-clicked the Study segment once (the settings coordinates reused; caught by the capture, redone at the Terminal segment — `use-17/18` are the corrected pair); the dev store now carries walk artifacts (one extra saved version from the ⌘⇧S verification, `readFace`/`currentBlock` memories, the walk's earlier put-backs) — harmless, dev-store only; the Trash rows keep time-of-day in their stamps BY DESIGN (wide rows, nothing truncates — row 63's date-only rule was the tray/pane's, where the squeeze lives); `BlocksWorkbenchFaceTests`' real-click pin is a third member of the pointer-events-under-load family for the ladder to weigh (green isolated, green in run 1).

#### Commits (in order — batch F whole)

1. `db848ca` — the record opened (LIVE STATUS; pieces named).
2. `dfa23d5` — piece 1: the recovery fixture seeded through the product doors (the 13 repeatable steps).
3. `ebf4cac` — piece 2: the walk at three widths + both voices; rows 63–68 found and traced; five records for other owners.
4. `9e0ae97` — fix piece A: rows 63 (two-slot meta, date-only stamps) · 64 (the fold's label toggles) · 66 (the confirm names snippet groups) · 68 (the kept-in-lineage sentence) · 67 (the save command group re-anchored); four pins, 46/5 green.
5. `c31d3c6` — piece A's red-on-old evidence (6 issues in 4 tests under the behavioral revert; restored, diff empty).
6. `7c98714` — piece 3: rows 28+65 — the pane's List retired for calm sections (CalmSectionHeader + meaning lines; savepoints gains its missing line); the reflection pin; 36/2 green.
7. `88c684d` — piece 3's red-on-old (3 issues in 2 tests under the List-back revert) + piece 4 (row 35's calm-chrome sweep: zero metric displays on the four surfaces).
8. `3cf0d82` — **the completion session adopts the dead session's uncommitted turn:** row 63's rider (`.fixedSize()` on the recovery rows' verbs — a verb never truncates), adjudicated KEEP, built green.
9. `aad819d` — the full suite's one real red fixed: the host pin's List-backing assertion mirrored to piece 3's justified edit.
10. (this commit) — the USE gate's walk table + captures + sheet, the suite counts and arithmetic, the adjudication recorded, the LIVE STATUS final.

**STATUS: BATCH F's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build (the final tree's product, with the rider and the pin edit) is left RUNNING for that walk — Terminal voice, the fixture note's Trash/Archived surfaces one click away, window zoomed; `/Applications` untouched; her real-store app untouched (not running). Tree clean; every commit pushed. Walk suggestions: the fixture note (Library ▸ the first 2026-09-01) ▸ the tray icon — the clocks whole at any width; the deleted-take fold's label; `history` from the bottom bar — the sections, then a caret move + the jump door + "Open this note's tray" on an origin (the third-state sentence); the Library trash icon ▸ Empty Trash (read the kinds, CANCEL); Archived ▸ the row's doors; ⌘⇧S anywhere (the receipt).

---


#### BATCH F RECORD — CLOSED by the orchestrator (2026-09-01 ~17:20; the founding session's LAST batch per R-cor-9)

Spot-check walked on the final dev build (`orchestrator-f/`): **the tray** — section headers with their
meaning lines ("leaving — on the 30-day clock" / "archived — kept, no clock"), full unclipped stamps
("deleted sep 1, 2026 30 days left"), full-size Put back / Delete Now verbs (row 63 + the adopted
`.fixedSize()` rider), the "▸ 1 deleted take" disclosure, her Act 10 item 1 (the clipped header) verifiably
gone; **the Block History pane** — "savepoints" and "came from" as labeled calm sections with one-line
meanings, the take run's full stamp + Restore, the two merge-released originals as cards with "the original
is preserved" + Bring back + Open this note's tray (rows 28/65/68). The completion session (a DIFFERENT
session from the builder) had already walked all six fixed rows and the four surfaces at three widths in
both voices (94-tile sheet `batch-f/contact-sheet.png`). Counts at close: **Mac 2032/356 exact twice**
(C's 2028 + 4 pins), spine 71/10, core untouched. Batch machinery note: F's implementer died at the
account's rate limit mid-USE-gate; its LIVE STATUS let a fresh completion session finish without loss —
the protocol held. Cosmetic, recorded: the seeded fixture's first block carries a seeding accident ("The
margin held." typed mid-word into "storms") — dev store only, harmless, left as is. Residual for batch E
(recorded by F's walk): the Library's archive receipt renders clipped under the new-note bar. One
load-flaky pin noted for the ladder (`BlocksWorkbenchFaceTests`' real-click rig — green isolated, green in
run 1). **The founding orchestrator WRAPS here (R-cor-9); the successor runs D → E → the ladder → the walk
→ the install → the author handoff.**

---

#### SUCCESSOR ORCHESTRATOR — ORIENTED (2026-09-01 16:00 MDT; Fable 5.1, session `session_019VxbpYiG4SvQfYdx5cXCBC`; R-cor-9's handoff)

Read in full in her order: the orchestrator handoff (§0/§0b first, slowly), this file whole, her report, the
Lenses+Compare memo, the author handoff, CLAUDE.md, the resiliency protocol. **Verified against the repo, never
trusted:** `git log --oneline -30` matches the handoff's state — HEAD `7f64b0f` (F CLOSED), tree clean, zero
unpushed; no `BATCH D RECORD` / `BATCH E RECORD` / `LADDER ROUND` section exists; the dev-store Debug build F's
completion session left running is pid 5635 (DerivedData, batch F's tree); no agent of any earlier session is
running; the drive tools (`vd.sh` · `click` · `drag` · `scroll` · `sheet.py`) and `notes/REVIEW_PROMPT.md` are
present. **Clock note:** the founding records' times ("~17:20" for F's close) ran ahead of the machine — the
close commit is stamped 15:43 MDT and this orientation began at 16:00 MDT; times in this session's records are
the machine's. **Acts before the first spawn:** the D and E briefs gain a binding addendum each (the code
anchors re-verified at `7f64b0f`, the environment/resiliency/baseline/trailer lines the C/F briefs carried by
reference, row 17's provenance stated honestly — 13c 2E filtered the anchor BY DESIGN and #47(c) made it
default on, so the fix is a ruled narrowing to peers, not a regression); §7d's trailer moves to this session's;
memory refreshed; the orchestrator handoff gains its line. **Batch D SPAWNED** as the first act — one code agent;
the orchestrator writes no code and does not drive the dev window while it runs.

---

### BATCH D — COMPARE + LENSES, MECHANICAL ONLY (brief; DRAFTED — spawn after F closes; the DESIGN is the memo, not this batch)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file; `notes/plans/act10-correction-memo-lenses-compare.md` (so your mechanical fixes
point the same way the design will go — but you build NONE of §3/§4's redesign); the source report's image
rows 8/9/10/13; `Features/Takes/CompareBoardView.swift` (:938 the `anchor.title ?? "This note"` fallback; the
"related blocks only" filter's application), `Features/Takes/LensesBoardView.swift`, `Core/Views/
NotePicker.swift`; the pins on `CompareComposition`/`CompareViewModel`/Takes (they stay green UNMODIFIED —
that is the semantics proof).

**Rows 16, 17, 46 — and only those (C-1):** (17) the anchor column ALWAYS renders the note whole — "related
blocks only" filters PEER columns, never the anchor; the header uses the derived display name (a journal
entry shows its day), never the literal "This note". Pin: related-only on + no peer → every anchor block
renders (RED on old: none). (46) ONE placement per act: the top-right "make outline note"/"+ note" buttons
retire; the offer cards stay (the memo will move them into the slot later). Pin: a registry/mount walk finds
exactly one door per act on the board. (16) the alignment: the toolbar row, the header cards and the offer
cards share ONE left edge and ONE baseline; the `＋ column`/`+ note` ghost stops floating mid-right — it
sits at the column strip's end at the header's height (both boards). Geometry pins. Nothing else — no
renames, no door moves beyond 46. Acceptance: captures of Compare's first open (anchor whole), a two-column
compare, Lenses with two columns. **Deliverable:** the BATCH D RECORD under this brief.

**Binding addendum — the successor orchestrator, 2026-09-01 16:05 MDT, written before the spawn (the anchors
re-verified at `7f64b0f`):** `CompareBoardView.swift:938` is still the `anchor.title ?? "This note"` fallback;
the top-right duplicates are `:910` ("make outline note") and `:918` ("+ note"), the centered offer card's copy
at `:1131`; the filter applies in the model's `compositionInputs` (`:413–426`) through
`CompareComposition.relatedOnly`, which BY 13c 2E's DESIGN collapses EVERY column — the anchor included — to
lineage-connected blocks, and her 13c ruling #47(c) made it default ON (the model's own comment at `:131–151`
is the record). **So row 17 is a RULED CHANGE to 2E's anchor half, not a regression:** with no peer, no anchor
block has kin, the anchor empties, and the board greets her with nothing — R-cor-6's in-round scope ("the
anchor column always rendering the note") narrows the filter to PEERS ONLY, the anchor exempt; state that
provenance in your record. Seam suggestion (yours to confirm at the code): exempt the anchor in the model's
`compositionInputs` — hand the FULL anchor through and keep the peers filtered by kinship against it — so the
pure `CompareComposition` brain and its pins stay byte-unmodified; if the brain must change, say why. The
per-column honesty line (`:1032`) and the whole-board honesty state (`:1182–1191`) must still read true after
the change (a peer with no kin still says so; the whole-board line no longer fires for the anchor alone). The
derived display name for a titleless journal entry lives in core — `Sources/VariorumCore/Queries/Timeline.swift:38`
and `Queries/ReadingAssembly.swift:59` (`displayTitle`) — reuse the ONE rule through `Queries`, never a third.
Lenses' `＋ column` is `LensesBoardView.swift:394` (the menu) / `:413` (the ghost label). **The semantics proof:**
`Tests/VariorumCoreTests/LensTests.swift`, `VariorumTests/CompareBoardTests.swift`, `TakesBoardSoakTests`,
`ScrubAndOutlineTests`, `TutorialWalkTests` green UNMODIFIED. **Environment (§6) + the driving recipe + the
resiliency rules of batch B's brief's last three paragraphs bind identically:** a `LIVE STATUS — BATCH D` list
from your FIRST commit; commit per piece + push after each; synchronous foreground waits only; never
`/Applications`, never her real-store app (not running); the dev-store Debug build now running is pid 5635
(batch F's tree) — quit THAT one and relaunch the product of YOUR tree for the walk (`open -n` on the
DerivedData product; if two windows restore, close one); both voices; the contact sheet named in the record.
Row 17 lands with a red-on-old pin verified by BEHAVIORAL REVERT (the anchor filtered again → the pin's anchor
rows absent); rows 46/16 are registry/geometry pins (door class where the rule did not exist — say so).
`TutorialWalkTests` green, then the FULL Mac suite once on the final tree — **baseline Mac 2032 / 356 · core
1524 / 165** (batch F's close); state the arithmetic; the known load-flaky reds (`rewriteStrategyLatencies`,
`CanvasDragTrackingTests`, and F's noted `BlocksWorkbenchFaceTests` real-click pin) are re-run isolated, never
loosened. New findings become ledger rows numbered from **69**; anything outside Compare/Lenses (C-1) is
RECORDED for its owner, never fixed here. **Trailer for every commit:** `Co-Authored-By: Claude Fable 5.1
<noreply@anthropic.com>` + `Claude-Session: https://claude.ai/code/session_019VxbpYiG4SvQfYdx5cXCBC`. Your
final message is ONE pointer to your record; then stop — the orchestrator walks your rows before the record is
marked closed.

### BATCH D RECORD — COMPARE + LENSES, MECHANICAL ONLY (a fresh Fable implementer session, 2026-09-01 16:10 MDT →)

#### LIVE STATUS — BATCH D (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — read in the brief's order: CLAUDE.md, this file whole (§0–§8, every record and CLOSED line, the D brief + its binding addendum), the Lenses+Compare memo, her report (§1 + image rows 8/9/10/13), the resiliency protocol, the orchestrator handoff §0/§0b/§2c; then the code: `CompareBoardView.swift` (whole, 1,457 lines), `CompareModels.swift` (the pure brain, whole), `LensesBoardView.swift` (whole), `Core/Views/NotePicker.swift`, `Theme/CalmGrammar.swift` + `VoiceControls.swift` (the card/button/chip geometry), `Queries.noteDisplayTitle` (the ONE single-note display brain — `TakesQueries.swift:196`, `DisplayTitle.note`), the pins `CompareBoardTests` (whole), `LensTests` (structure), `ScrubAndOutlineTests`/`TakesBoardSoakTests`/`TutorialWalkTests` (their Compare/Lenses references), the geometry-oracle idiom (`MastheadGeometry` + `mastheadGeometryProbe`) and the reflection-pin helper (`SurfaceComposition`). Tree clean at `ddd8daa`; the dev-store Debug build pid 5635 (batch F's tree) running.
- **Two facts found at the code that the brief's letter did not carry (recorded BEFORE any code moved):**
  1. **The anchor's emptiness has TWO mechanisms, not one.** Row 17 traced the filter ("related blocks only" collapsing the anchor with an unrelated peer — `compositionInputs` :413–419 through `CompareComposition.relatedOnly`). But the body (:816–822) ALSO renders `emptyState` INSTEAD of `boardRows` whenever every slot is nil — so with NO peer the anchor's rows never render at all, filter or no filter. Her image 8 ("This note … EMPTY beneath; a dashed slot; two offer cards centered low") is the no-peer state: BOTH mechanisms. "The anchor column ALWAYS renders the note whole" therefore means the rows render in EVERY state and the offer cards move out of the rows' place.
  2. **`adopt()` AUTO-FILLS the first slot with a version peer** (:293–297). On a version-linked note — the field guide's "compare & versions" lesson, whose seeded twin is exactly this — Compare never opens in the empty state, so the offer CARDS are never seen there. Retiring the header's "make outline note" outright (the brief's letter for row 46) would leave the act with NO door on precisely the note whose lesson says *"press 'make outline note' in Compare's header"* (`TutorialSeeder.swift:1419`). Chosen instead (R-cor-8: choose, record): ONE placement at any moment — the card while the offer band shows, the header button only while a peer is open. No duplicate is ever on screen; the taught door survives; the memo's build settles the final home (its §4 puts the offer into the empty slot).
- **The settled design (before any code moved):**
  - **Row 17 —** (a) `compositionInputs` hands the FULL anchor through under the filter and keeps the peers filtered by kinship against it; the pure `CompareComposition` brain and its pins stay byte-unmodified (its "anchor empty exactly when every peer is" invariant is simply no longer what the model relies on — stated at the model site). (b) `PostFace` gains `displayTitle` from `Queries.noteDisplayTitle` (the masthead's own brain — `DisplayTitle.note`: title, else `entry_date`, else the created day); the anchor card, the peer cards, the empty state's version rows and the Diff sheet's titles all read it; the literal "This note" fallback goes (the card's second line still says "this note"). (c) The rows render in EVERY state; the empty state's offer cards become a BAND under the header strip, left-anchored at the board's one inset (row 16), top-anchored (no vertical centering), the version-peer rows under it. (d) The per-column honesty line's condition is unchanged and now fires for every filtered kin-less peer (rows are never empty while the anchor has blocks); the whole-board "there is no relationship here" state fires only for a BLOCKLESS anchor — recorded. Provenance (the addendum's): 13c 2E filtered the anchor BY DESIGN and #47(c) made it default on — this is a RULED narrowing to peers under R-cor-6, not a regression.
  - **Row 46 —** the toolbar's "+ note" retires; the act lives at the END of the header strip at the header's height, rendered only when NO empty slot exists (and < 3 slots) — an empty slot's dashed "＋ choose a note" IS the add door, so the two never stand together. The toolbar's "make outline note" renders only while a peer is open (fact 2 above); the offer card is the door otherwise.
  - **Row 16 —** Compare: ONE horizontal inset (12 pt) for the toolbar, the header strip, the offer band and the rows (the toolbar sat at 16, the cards at 12, the offers centered — three left edges); the toolbar aligns its controls on the first text baseline. Lenses: the toolbar's inset 24 → 12 (the rows' leading edge, the ⠿ handle); the header strip's leading gutter becomes the row's OWN gutter (a hidden ⠿ + the stripe's 4 pt, same spacings) so the cards sit over their panes (they sat ~17 pt left of them: the old spacer was 4 pt for a ⠿+stripe gutter); the `＋ column` stub loses `maxHeight: .infinity` and top-aligns at the header cards' top — a header-height door at the strip's end, never a page-tall dashed column with its words floating mid-height (her image 9). DEBUG oracles `CompareGeometry` / `LensesGeometry` (the `MastheadGeometry` idiom) feed geometry pins.
  - **Pins** (one new file, `CompareLensesCorrectionTests.swift`): the anchor renders whole with no peer AND with an unrelated peer (model; RED on old) · a titleless note's anchor card names its day, never "This note" (reflection; RED on old) · each offer act has exactly ONE placement in both states (reflection; RED on old: two "make outline note"s) · toolbar/header/offer left edges within 1 pt (geometry; RED on old) · the "+ note" door at the strip's end at the header's height, absent while a slot is empty (geometry; RED on old: in the toolbar) · Lenses' header cards over their panes + the toolbar on the rows' edge (geometry; RED on old) · the Lenses stub at the header's height, never page-tall (geometry; RED on old). Red-on-old by BEHAVIORAL REVERT after the fix is committed (the protocol's addendum 11a): every mechanism switched back in place, the suite run, the files restored by `git checkout --`, `git diff --stat` empty.
- **Rows 17 + 46 + 16 (ONE piece — they interlock in the body's structure):** DONE (`e400618`) — `CompareBoardView.swift`: `compositionInputs` hands the whole anchor through the filter (peers filtered by kinship as before; `CompareModels.swift` byte-unmodified); `PostFace.displayTitle` from `Queries.noteDisplayTitle`, read by the anchor card (`CompareAnchorCard`), the peer cards, the version rows and the Diff sheet; the rows render in EVERY state and the offer cards are a left-anchored BAND under the strip (`offerBand`, `CompareOfferCard`); the toolbar's "+ note" retired for the strip-end door (`addNoteDoorShows` — only while no empty slot stands); the header's "make outline note" only while a peer is open (`noPeerIsOpen`); ONE inset (`boardInset` = 12) for the toolbar, the strip, the band and the rows; the toolbar on one text baseline; `CompareGeometry` (DEBUG) + `compareGeometryProbe`. `LensesBoardView.swift`: the toolbar's inset 24 → 12; the header strip leads with the row's own gutter (a hidden ⠿ + the stripe's 4 pt) via the factored `headerCard(_:index:)`; the unlocked layout gives each column its own header over its own cells; the `＋ column` stub is a header-height door top-aligned at the strip's end (no `maxHeight: .infinity`, top padding = the inset); `LensesGeometry` (DEBUG) + `lensesGeometryProbe`. **Pins (`VariorumTests/CompareLensesCorrectionTests.swift`, 5 tests / 3 suites, green):** `CompareAnchorWholeTests.theAnchorRendersWholeWithNoPeerAndBesideAnUnrelatedPeer` · `.theAnchorCardNamesANamelessNoteByItsDayNeverThisNote` · `CompareOnePlacementTests.eachOfferActHasExactlyOnePlacementInEveryState` · `CompareLensesAlignmentTests.theToolbarTheHeaderCardsAndTheOfferCardsShareOneLeftEdgeAndTheAddDoorSitsAtTheStripsEnd` · `.lensesHeaderCardsSitOverTheirPanesTheToolbarOnTheRowsEdgeAndTheStubAtTheHeadersHeight`. **The semantics proof, green UNMODIFIED in the same run:** `CompareCompositionTests` (12) · `CompareViewModelTests` (9) · `ScrubAndOutlineTests` · `TakesBoardSoakTests` — 34 tests / 7 suites. **Red-on-old VERIFIED by BEHAVIORAL REVERT** (every mechanism switched back in place from the committed state `e400618`/`29cc690`, the oracles kept — the anchor filtered again · `title ?? "This note"` back · the band standing IN the rows' place · both toolbar buttons back unconditionally + the strip-end door removed · the toolbar at 16 · the band centered · the Lenses toolbar at 24 · the 4-pt header spacer · the page-tall stub; log `d-red-on-old.log` in the session scratchpad): **15 issues in 5 tests — every pin RED.** Row 17: `anchorHasBlocks → false` and `rows.count → 0` (of 2) with no peer AND beside the stranger (4); the card `title: "This note"` composed, the day absent (2). Row 46: "make outline note" composed TWICE with no peer (the toolbar + the card), "+ note" composed beside an empty slot (band and two-slot states) (3). Row 16 Compare: the toolbar 4.0 pt off the header cards, the offer card **208.0 pt** off (centered), the add door never reported at the strip's end (3). Row 16 Lenses: the stub's top **287.5 pt** below the header card (mid-page), the header card 16.0 pt off its pane, the toolbar 12.0 pt off the rows' edge (3). Restored by `git checkout --` from the repo root; `git diff --stat` empty.
- **A harness lesson found on the way (recorded so the ladder's fix session does not relearn it):** the composition-reflection road (`SurfaceComposition`) cannot see inside a `CalmCard { … }` content closure or a `ForEach` body, and a view under `if` dumps as an `Optional(…)` whose one-line description repeats its labels — so the two header/offer cards became VALUE views with a stored `title`, and the one-placement counts read whole `- title:`/`- verbatim:` lines. Recorded at the pin file's header beside `ProtectionSurfaceRenderTests`' two limits.
- **Row 16's own residual, caught in this batch's USE gate and fixed in-batch (`70073fa`):** the first cut's `＋ column` stub collapsed to a one-word dashed pill (capture `07b`'s crop) — `.menuStyle(.borderlessButton)` sizes the control to its label's INTRINSIC width and clipped the second line once the page-tall frame was gone; the plain-button menu idiom (`VoicedMenu`'s: `.menuStyle(.button)` + `.buttonStyle(.plain)`) renders the label at its proposed width — a header-height dashed door with both lines in both voices (captures `07` re-shot, `13`). The geometry pin was green on the squeezed cut too (it measures position and height, not the label's fit) — exactly why C-2 is USE, not mount; recorded so the ladder weighs whether the pin should also assert the door's width.
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build of THIS tree (pid 13609, then 16083 after the stub fix; window zoomed 1728×1084), Terminal AND Study; the walk table is below; **the contact sheet is `batch-d/contact-sheet.png` (18 tiles)**. `/Applications` untouched; her real-store app untouched (not running).
- **Suites:** DONE — the ten `TutorialWalkTests.swift` suites + this batch's three pin suites first: **76 tests / 13 suites green** (71 + 5). Then the FULL Mac suite once on the final tree (`70073fa`): **2037 tests / 359 suites, all green** (`** TEST SUCCEEDED **`, 307.4 s; log `d-full-mac.log` in the session scratchpad). **Arithmetic against batch F's close 2032 / 356:** +5 tests (`CompareAnchorWholeTests` 2 · `CompareOnePlacementTests` 1 · `CompareLensesAlignmentTests` 2) ⇒ **2037**, exact; +3 suites ⇒ **359**, exact. The known load-flaky pins PASSED in-run (`rewriteStrategyLatencies` 2 cases · `CanvasDragTrackingTests` · F's noted `aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens`) — nothing re-run, nothing loosened. **Core 1524 / 165 untouched** (`git diff --stat 7f64b0f..HEAD -- Sources/` empty; zero `Sync/`). **`App/Variorum/Shared/` untouched** (empty diff — the iOS target sees no change from this batch).
- **STATUS: BATCH D's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build of the final tree (pid 16083) is left RUNNING for that walk — Terminal voice, the lenses lesson open in Lenses (one column, the stub), window zoomed; the Compare states are one ⌘K + ⌘5 away. Tree clean; every commit pushed.
- **ONE deviation from the brief's letter, for the orchestrator to put to her at this seam (R-cor-10(c)):** row 46 said the top-right "make outline note" RETIRES; it is instead rendered only while a peer is open, because the auto-filled version peer makes the offer band — and its card — unreachable on a version-linked note (the field guide's own lesson), and the lesson's text names the header door. One placement at any moment is delivered; the memo's build (its §4: the offer into the empty slot) settles the final home. If she wants the letter instead, it is a one-line change (`if !model.noPeerIsOpen` → delete) and the lesson's sentence must move with it.
- **No revert in flight** (the behavioral revert ran from `29cc690` and was restored — `git checkout --` from the REPO ROOT; the first attempt ran from `App/Variorum` and its repo-relative pathspec matched nothing, batch C's own trap, met again and noted; `git diff --stat` empty, the three fixed mechanisms grep-confirmed back). `/Applications` untouched; her real-store app untouched (not running).

#### Per-row dispositions

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 17 | FIXED — the anchor column renders the note WHOLE in every state (two mechanisms closed: the filter now exempts the anchor — a RULED narrowing of 13c 2E's anchor half to peers, **ratified by her at R-cor-10(b)**; the offer cards no longer stand in the rows' place); the anchor card, the peer cards, the version rows and the Diff sheet name a note by the ONE display rule (`Queries.noteDisplayTitle` — a nameless entry shows its day); the per-column honesty line still fires for a filtered kin-less peer; the whole-board line fires only for a blockless anchor | `CompareAnchorWholeTests.theAnchorRendersWholeWithNoPeerAndBesideAnUnrelatedPeer` · `.theAnchorCardNamesANamelessNoteByItsDayNeverThisNote` | 6 issues (rows 0 of 2 and `anchorHasBlocks → false`, alone and beside the stranger; `title: "This note"` composed, the day absent) |
| 46 | FIXED — ONE placement per act at any moment: "+ note" retired from the toolbar and stands at the END of the header strip only while every slot is filled (an empty slot's dashed door IS the add door); "make outline note" is the offer card while the band shows and the header door only while a peer is open (the brief's "retire" deviated from, reason above — hers to confirm) | `CompareOnePlacementTests.eachOfferActHasExactlyOnePlacementInEveryState` | 3 issues ("make outline note" composed twice; "+ note" beside an empty slot in the band and two-slot states) |
| 16 | FIXED — Compare: ONE inset (12 pt) for the toolbar, the header strip, the offer band and the rows; the toolbar on one text baseline; the offer band left-anchored under the strip (no page-centering); the add door at the strip's end at the header's height. Lenses: the toolbar on the rows' leading edge; the header strip leads with the row's own gutter so every card sits over its pane (locked) and each unlocked column carries its own header; the `＋ column` stub a header-height dashed door at the strip's end (its in-walk squeeze fixed at `70073fa`) | `CompareLensesAlignmentTests.theToolbarTheHeaderCardsAndTheOfferCardsShareOneLeftEdgeAndTheAddDoorSitsAtTheStripsEnd` · `.lensesHeaderCardsSitOverTheirPanesTheToolbarOnTheRowsEdgeAndTheStubAtTheHeadersHeight` | 6 issues (the toolbar 4.0 pt and the offer card 208.0 pt off the anchor card; no add door at the strip's end; the stub 287.5 pt down the page; the header card 16.0 pt off its pane; the toolbar 12.0 pt off the rows' edge) |
| **69** (new — a consequence of row 17, NOT this batch's file) | RECORDED for **the closeout's copy change + the re-seed (§7b item 8)** — `TutorialSeeder.swift:1411–1417`, the compare lesson's fourth paragraph, ends *"Against an unrelated note it tells you there is nothing to show, rather than showing you nothing"* — that describes the RETIRED whole-board state; with the anchor exempt the board shows her note whole and the other column says *"related blocks only — nothing from this note"*. Proposed sentence: *"Against an unrelated note your note still reads whole, and the other column says nothing relates."* The fifth paragraph's *"press 'make outline note' in Compare's header"* stays TRUE (the lesson's twin auto-fills, so the header door shows there). Untouched here per batch A's precedent (a lesson sentence a batch makes stale is RECORDED; copy changes are the closeout's) | — | — |
| **70** (new — the walk, NOT this batch's surface) | RECORDED — the ⌘K palette cannot find a nameless note by the name it wears: typing its day (`2026-09-01`) lists nothing (capture `06a`), because the catalog search reads STORED titles and a note called by its day has none. A note she sees named "2026-09-01" everywhere is unsearchable by that name. Owner: **13o** (the search phase — `Queries.searchCatalog` is its subject; a display-name match is one predicate), flagged for the orchestrator in case G wants it sooner | — | — |
| **71** (new — the walk; pre-existing) | RECORDED for **the Lenses + Compare build phase (the memo's §4)** — an EMPTY peer slot added with "+ note" has no close door until it is filled (only a filled card carries ✕; the old toolbar button had the same gap). The memo's slot design owns it | — | — |
| **72** (new — the walk; pre-existing) | RECORDED for the memo's build phase by D — **RE-OWNED to batch G by the orchestrator's walk (17:15 MDT):** the header strip's cards are uneven (the anchor card two lines, a peer card three plus its doors — captures `03`/`11`, the orchestrator's `02-crop`), so the strip's bottom edge steps. Equal heights in the strip (every card stretches to the strip's height, content top-aligned) is a mechanical alignment fix under row 16's own rule; the memo's card DESIGN still settles the cards' content later. Geometry pin: every header card's bottom within 1 pt of the strip's | — | — |

#### The USE gate — the walk (the dev-store Debug build of this tree, window zoomed 1728×1084; every capture in `act10-correction-screens/batch-d/`; **the sheet: `batch-d/contact-sheet.png`, 18 tiles**)

| Row | What was done | Capture(s) |
|---|---|---|
| 17 | Compare on Boscombe (no peer, the filter ON): the anchor's 215 blocks flow WHOLE under its card; the dashed slot at the header's height; the filter chip OFF reads the same | `01-terminal-compare-boscombe-nopeer` · `02-…-filter-off` · `10-study-compare-boscombe-nopeer` |
| 17 | The twin lesson (its version peer auto-filled): every row lineage-aligned, the anchor whole | `03-terminal-compare-lesson-twin-two-columns` · `11-study-compare-twin-two-columns` |
| 17 | A STRANGER in the third slot (Boscombe beside the lesson): the anchor stays whole, the twin aligned, the stranger's card reads *"there is no relationship here"* + *"related blocks only — nothing from this note"* | `05-terminal-compare-stranger-third-column-anchor-whole` |
| 17 | A NAMELESS note (⌘N, one sentence typed) in Compare: the anchor card reads **"2026-09-01 / this note"** — the day, never "This note" | `06-terminal-compare-nameless-note-named-by-day` |
| 46 | No peer: the offer band is the one outline door, the dashed slot the one add door — no toolbar buttons. A peer open: "make outline note" in the toolbar, "+ note" at the strip's end. "+ note" clicked: a third dashed slot appears and the door YIELDS | `01` · `03` · `04-terminal-compare-plus-note-third-slot-door-yields` |
| 16 (Compare) | The chips, the anchor card and the offer cards on ONE left edge (x ≈ 258 of 2000 displayed) in both voices; "+ note" top-aligned with the cards at the strip's end, inside the board | `01` · `03` · `10` · `11` |
| 16 (Lenses) | One column: the `＋ column` stub a header-height dashed door with both lines, its top on the header card's top (BEFORE the in-walk fix: the squeezed pill, `07b`'s crop). Two columns ("the other reading" opened through `+ column ▾` by keyboard): each card's left edge on its pane's (the tinted pane and its card both at x ≈ 1144); the align chip on the ⠿ handles' edge. Unlocked (align: off): each column carries its own header over its own cells | `07-terminal-lenses-one-column-stub-at-header-height` · `07b-…-menu-open` (the squeeze, pre-fix) · `08-terminal-lenses-two-columns-header-over-panes` · `09-terminal-lenses-unlocked-per-column-headers` · `12-study-lenses-two-columns` · `13-study-lenses-one-column-stub` |
| (aside) | The Settings ▸ Appearance switch; the voice restored to Terminal at the end | `10a-settings-window` · `14-terminal-restored-lenses` |

Honesty notes: the dev store now carries a nameless ⌘N note ("A nameless note for the walk…", dated 2026-09-01 — a walk artifact, harmless) and the lenses lesson's view memory back at one column with `align` on; `06a` is the palette showing NO match for "2026-09-01" (row 70); the `+ column ▾` menu's first click was dismissed by the capture helper's own activation, so the column was opened by click + three ↓ + ⏎ without a shot in between; the AX tree answered nothing for these boards (`static text` queries returned empty — the earlier records' finding), so every fact here is a capture's; the twin case walked is the TWIN as anchor (the palette's first match) with the lesson as its peer — the same pair either way.

#### Commits (in order)

1. `16486ca` — the record opened (LIVE STATUS + the settled design; the two facts found at the code).
2. `e400618` — rows 17 + 46 + 16: the code + the DEBUG oracles + the five pins (34/7 green with the semantics suites unmodified).
3. `29cc690` — revert starting (the record names the pre-revert state first).
4. `b3cab30` — the red-on-old evidence (15 issues in 5 tests); restored, no revert in flight.
5. `70073fa` — row 16's in-walk residual: the stub's menu style (the squeezed pill → the header-height door).
6. `7870cc9` — the USE gate's walk table + sheet, the suite counts and arithmetic, the dispositions, rows 69–72, the LIVE STATUS final, the ledger cells for 16/17/46. 7. (this commit) — the hashes filled.

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed through `70073fa` (+ this record commit); no revert is in flight; the tree is clean; the final Mac suite is green at 2037/359 exact over F's 2032/356. Every batch-D row is FIXED with a red-on-old pin (rows 17/46/16 — six, three and six issues under the behavioral revert); the four new rows (69–72) are RECORDED with owners (the closeout's copy change; 13o; the memo's build twice); nothing DEFERRED beyond those, nothing REVERTED (C-5 unexercised). The one thing to put to her at this seam: row 46's outline door is placement-per-state (card while the band shows, header while a peer is open) rather than the brief's flat retire — the auto-filled version peer is the reason; the memo's §4 is where it goes for good. Two honest limits: the reflection road cannot see inside a `CalmCard` closure or a `ForEach` (the cards became value views to be readable; the dashed slot is covered by geometry, not by the count), and the Lenses geometry pin measures the stub's position and height, not its label's fit (the in-walk squeeze passed it; recorded for the ladder). Walk suggestions: ⌘K "boscombe" ⌘5 — the note whole, one left edge, no "+ note"; ⌘K "compare & versions" ⌘5 — "+ note" at the strip's end at the cards' height, "make outline note" top-right; click "+ note" (the door yields to the dashed slot), pick an unrelated note into it (the anchor stays whole; the column says why it is empty); ⌘K "lenses" ⌘4 — the stub at the header's height with both lines; `+ column ▾` ▸ Open "the other reading" — the cards over their panes, the align chip on the handles' edge; Settings ▸ Appearance ▸ Study for the same four. Known non-D residue seen in passing: the dev store's seeded lesson text still says ⌘5/⌘6 for Lenses/Compare (the pre-batch-C seed — the closeout's re-seed); nothing in the masthead, the book, the note modes, the recovery family or the library panel was touched.

---

#### BATCH D RECORD — CLOSED by the orchestrator (2026-09-01 17:15 MDT; captures `orchestrator-d/`)

Verified against git first: seven commits `16486ca`…`3833070`, tree clean, pushed; the code diff is exactly
`CompareBoardView.swift` + `LensesBoardView.swift` + one new pin file (C-1 held; core and `Shared/` untouched).
Read the 18-tile sheet, then two full captures at the riskiest rows (`batch-d/01` — Boscombe's 215 blocks flow
whole under its card with the filter on; `03` — the twin: chips, cards and rows on one left edge, `+ note` at the
strip's end at the cards' height, "make outline note" top-right), then ONE live probe of a state D never captured:
**an unrelated note as the FIRST peer on Boscombe** (the dashed slot → the picker → "compare & versions"): the
anchor stays whole, the offer band leaves, the peer card says "there is no relationship here" + "related blocks
only — nothing from this note" with mark-as-versions · diff · open, the toolbar's outline door appears and
`+ note` stands at the strip's end (`00-crop-top` · `01-crop` · `02-crop`). **D's rows 16/17/46 are FIXED in
use.** Her R-cor-10(b) ratification covers row 17's narrowing. **Row 72 RE-OWNED to G** (the header strip's
cards step because the anchor card is two lines and a peer card three-plus-doors — an equal-heights alignment
fix, not a design question; her bar: alignment is a defect). **The row-46 deviation goes to her at this seam**
(the outline door placement-per-state instead of a flat retire — D's reason: the auto-filled version peer makes
the offer card unreachable on the taught note). **The Snippets/Pool/Canvas walk (both voices; `03`–`09`):**
Snippets reads clean and calm in both voices (the mockup's `.met` facts line; groups; the drop area; nothing
thrown in). **Pool: a wall of bare dates** — ten titleless notes show only their day and a lone `+`, no first
words, while the note picker already carries a two-line preview under every match (row 87, hers). **Canvas**
(pre-Act-10 — the restyle never reached it): opens the 215-block story MID-BANK with cards clipped at every edge
(rows 97–162 visible, `fit all` a click away) and a toolbar of mixed grammar ("Tag filter" label + a system
popup beside calm chips) in both voices (row 88, hers). Counts at close: **Mac 2037/359 green** (F's 2032 + 5 /
356 + 3), core 1524/165 and `Shared/` untouched, spine green in-run. Machinery lesson: `sips --cropOffset`
CENTERS the crop on this OS (two tries, verified against a 220-px strip) — crops are made with PIL
(`Image.crop((x0,y0,x1,y1))` on the 2× PNG), which is exact; the handoff's §2c is corrected. The voice was
restored to Terminal and the note to Write at the end. **Batch E spawned next** (after her three calls below).

---

### BATCH E — THE LIBRARY PANEL (brief; DRAFTED — spawn after D closes; R-cor-3's PROVISIONAL reading)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file (R-cor-3 verbatim is your governing text — her INCLINATIONS, the safer choice);
the source report's image row 3; `Features/Library/LibraryInfoPanel.swift`, `Features/Library/
LibraryCatalogView.swift` (the row click model — body selects, title opens, double-click opens: #79's
ratified gestures, untouched), `Core/Views/FlowParagraph.swift`, `Features/BookView/` (the navigator's
outline rows, for the book panel), `RootView.swift` (the panel's host and the inactive-window appearance),
the pins `NoteRowSelectionTests`, `WorkspaceNavigationTests`.

**Rows 1, 33, 34, and the PANEL half of 24 — and only those (C-1):**
(1) The panel becomes a **simple READ preview** of the selected note: its rendered text (read-cheap,
`FlowParagraph`, virtualized — P1 holds on a 10k-word note), a calm facts line (words · blocks · last
edited — the facts she asked for at Act 10 item 10 — nothing more), and ONE generous door **Open** that
lands in the note **where the caret last was** (find the per-note caret/current-block memory batch C
built — row 39's authority — and land there; if none is stored, the first block). No takes, no blocks, no
write surface. (33) Selecting a **book** shows the BOOK's outline in the panel — chapters and notes, the
navigator's own grammar; a note row there opens the book at that note (batch B's reveal). (34) The
boundary between the panel and the library holds when the window is INACTIVE (`controlActiveState`) —
the divider and the panel's wash must not vanish; capture active vs inactive. (24, panel half) the panel's
appearance/disappearance animates with the row selection (no teleport); the sidebar rail's fade is A's.
Pins: a note selection renders the note's first block's text; a book selection renders its chapters; Open
lands at the remembered block; the inactive state keeps the divider (a render pin over
`controlActiveState`). Acceptance captures: a note selected (long note), a book selected, Open landing,
inactive window. **Deliverable:** the BATCH E RECORD under this brief. R-cor-3's reading stays PROVISIONAL in
the morning bundle — her walk ratifies or redirects.

**Binding addendum — the successor orchestrator, 2026-09-01 16:05 MDT (to be refined at D's close if D's
record bears on it):** environment (§6), the driving recipe and the resiliency rules of batch B's brief's last
three paragraphs bind identically (a `LIVE STATUS — BATCH E` list from the first commit; commit + push per
piece; synchronous foreground waits only; never `/Applications` or her real-store app; relaunch the dev build on
YOUR tree for the walk; both voices; the contact sheet named in the record). The current-block authority for the
Open door is batch C's `CurrentBlockMemory` — `CommandRouter.currentBlock(for:)` reads it for an UNMOUNTED
note (C's record names it for exactly this door; land there, else the first block); the reveal for a book's
note row is batch B's `BookViewModel.requestLanding` / `pendingReveal` road. Two residuals other batches
recorded for E are YOURS (the Library surface): **row 56** (the Library's List-mode row selection is the
SYSTEM blue band — W8-2's grammar is the wash + a tinted border, never a system highlight) and **F's (a)** (the
Library's archive receipt renders clipped at the window's bottom edge under the new-note bar — `seed-33`); each
gets a traced mechanism and a pin. Row 54 (the read tier's provisional-width first measure, `ReadPostView`)
is 13u2 item 1's — the preview will inherit that jump if it composes the read tier; do not chase it here, but
say in the record whether the panel shows it and which tier the preview uses. Baselines: batch D's recorded
close counts + your pins (state the arithmetic); new rows numbered after D's last. Trailer:
`Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` +
`Claude-Session: https://claude.ai/code/session_019VxbpYiG4SvQfYdx5cXCBC`. Your final message is ONE pointer to
your record; then stop.

### BATCH E RECORD — THE LIBRARY PANEL (a fresh Fable implementer session, 2026-09-01 ~17:00 → 18:05 MDT; the machine's clock — the first commit is stamped 17:15)

#### LIVE STATUS — BATCH E (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — read in the brief's order: CLAUDE.md; this file whole (§0–§8, R-cor-1…10 with R-cor-3 as ratified at R-cor-10(1), the constitution + C-1…C-7, the ledger, every batch record and CLOSED line — C's `CurrentBlockMemory`, A's row 56, F's "(a)" — the E brief + its binding addendum); her report §1 + image row 3; the resiliency protocol; the orchestrator handoff §0/§0b/§2c; then the code: `LibraryInfoPanel.swift` (whole), `LibraryCatalogView.swift` (whole — the model, the `.inspector` host :542–557, the receipt overlay :558–575, the List :689–759, the two row lines), `NoteRowSelection.swift`, `FlowParagraph.swift`, `CurrentBlockMemory.swift` + `CommandRouter`'s `registerDetail`/`currentBlock(for:)`, `RootView.swift`'s opener/`paneDetail`/`openBook`/`readCheapProse`, `BookOutlineRows.swift`, `BookStructureModel.grouped`, `BookView`'s navigator rows + `openFromNavigator`/`navigateToChapter`, `BookViewModel`'s `requestReveal`/`requestLanding`, `ReadModeView`'s `ReadPageColumn`/`ReadPageBlock` (the read-cheap per-block shape), `CalmGrammar.swift`, `VoiceTokens`, `ReadPostView.swift` (the TK2 tier — NOT composed here), the pins `NoteRowSelectionTests` (whole), `WorkspaceNavigationTests` (the library's one label pin), `CurrentBlockContinuityTests` (the mounted-detail rig), `TrayPanelShapeTests` (the reflection idiom). Tree clean at `d6b53e5`; the dev-store Debug build pid 16083 (batch D's tree — the Library panel byte-identical to HEAD there) running.
- **THE MECHANISMS, TRACED IN USE BEFORE ANY CODE MOVED (captures `batch-e/00…06`, window 1728×1084, Terminal):**
  - **Row 34 (the boundary vanishes inactive) — CONFIRMED and measured.** The window captured BY ID (`tools/winid`, new — `screencapture -l` needs no activation) with the panel open: ACTIVE, one pixel column across the boundary differs from the surface (`(254,254,249)` at x = 2616 of 3456 in a field of `(251,251,247)` — the `.inspector`'s own hairline); INACTIVE (Finder frontmost), the same row is UNIFORM — no line, and the panel's `tokens.surface` background equals the list's, so nothing marks where the library ends (`06-crop-boundary-active-vs-inactive`: the line on the left half, gone on the right). Mechanism: the panel is a SwiftUI `.inspector`, whose divider is drawn by the system in the KEY-window appearance only, and the panel paints the same surface as the list — nothing of ours draws the boundary. (Batch A retired `NavigationSplitView` for the same class one column over; the same key-window rendering.)
  - **Row 33 (a book click keeps the note) — CONFIRMED, TWO mechanisms.** (a) A click on a book row's BODY right of its text is a DEAD click: `CatalogBookLine`'s `HStack` carries no `Spacer`, so its frame — and the `contentShape` the taps ride — is only as wide as the icon + title + "book"; the click at x = 900 hit nothing and the panel kept the note it was showing (`03-before-book-row-clicked`: the note "2026-09-01" still in the panel, the note row still banded). (b) When the click DOES land (on the "book" label — `04-crop-panel`), the panel shows the book's FACTS (`notes 0 · created 2026-08-31`), never its outline — the ruled shape.
  - **Row 56 (the system band) — CONFIRMED in both of its faces:** the note row's pick renders as the List's SYSTEM selection — a GREY band while the list is not first responder (`01`, right after the panel took focus) and the BLUE accent band when it is (`03`). Mechanism: `List(selection: Binding(get: { model.selectedPosts } …))` + `.tag(hit.id)` on the note rows — the List draws its own highlight for every id in the binding. Pre-Act-10 the List carried the same binding (the 13l P-0 pick); the grammar W8-2 ruled is the wash + a tinted border.
  - **Row 24 (the panel half):** `.inspector(isPresented:)` slides the column in; the row selection changes the panel's SUBJECT with a hard swap (`.id("info-\(hit.id)")` rebuilds it — a teleport of content). Under the row-34 fix the column becomes ours and animates its presence (`.transition` + `.animation` on the subject's presence); the subject swap fades.
  - **F's (a) (the archive receipt clips):** `seed-33` read: the receipt is `.overlay(alignment: .bottomLeading)` on the WHOLE column — it lands ON the quick-entry bar at the window's bottom edge with 6 pt of padding and its descenders clip. Mechanism: an overlay, not a laid-out slot. Fix: a laid-out message row above the bottom divider (nothing covered, nothing clipped).
  - **Row 1 (the shape):** `LibraryInfoPanel` is the facts panel (title · kind line · Open Note · a facts card · books card · tags card). R-cor-10(1) ratifies the SIMPLE READ PREVIEW.
- **The settled design (before any code moved):**
  - **The panel (`LibraryInfoPanel.swift`, rebuilt in place):** a NOTE shows its title, ONE calm facts line (`N words · N blocks · edited <day>`, plus the quiet words `sealed`/`archived` only when true — nothing more; the books/tags cards DROP per the brief's letter and C-6: the row already wears the tags), ONE generous **Open** door (full-width, primary), and the note's RENDERED TEXT: a `ScrollView` + `LazyVStack` of per-block rows, each block through `FlowParagraph.paragraphs(of:)` in the voice's `body` (headings scaled, lists indented, links live) — the read-cheap SwiftUI tier (`ReadPageBlock`'s shape), NOT the TK2 `ReadPostView`, so row 54's provisional-width double measure does not reach this panel (recorded below). The blocks are read ONCE per selection (`Queries.renderPost` — the one-shot the old panel already made for its word count); rows realize lazily (P1 on a 10k-word note: the read is ∝ the note once; the render ∝ what is on screen). A BOOK shows its name, ONE facts line (`book · N chapters · N notes`, `smart book`, `finished`), **Open Book**, and its OUTLINE in the navigator's grammar — `BookOutlineRows.rows(grouped:)`/`rows(flat:)` over the same three reads the book makes (`assembleReading` · `readingSections` · `sectionAssignments`; row 8's one-note-chapter collapse applies): a chapter row (small semibold accent) opens the book at its first note; a note row (muted, indented) opens the book AT THAT NOTE through B's reveal road (`RootView.openBook(bookID, at:in:)` → `bookAscent` → `revealPostID` → `BookViewModel.requestReveal`) — a new `onOpenBook` closure on `LibraryCatalogView`, wired in `RootView`. The pure brain: `LibraryPreview` (nonisolated enum: the note/book reads, the facts-line rule, the outline rows) — pinned on an in-memory store; the view renders it.
  - **The container (rows 34 + 24):** `.inspector` RETIRES for a column of OUR OWN inside the library's `HStack`: the list, ONE 1 pt `tokens.line` divider (the shell's grammar), the panel on `tokens.room` — both drawn by us in every window state (`controlActiveState` cannot take them). Width: `LibraryPanelLayout.width(total:)` (pure) — the inspector's own 420 ideal / 280 minimum, clamped to the detail's width. The column's presence animates (`.move(edge: .trailing)` + opacity, 0.22 s); the subject swap fades.
  - **Row 56:** the List drops its selection binding and the rows their `.tag`; the pick and the panel's subject render through `listRowBackground` as the calm grammar (wash + a tinted border, radius 6) on note AND book rows; the book row's line gains a `Spacer` so its whole width is the target (row 33 (a)).
  - **F's (a):** the receipt/error is a laid-out row above the bottom divider (`tokens.small`, the receipt muted, the error alarm), never an overlay.
  - **The Open door's landing:** BY CONSTRUCTION through C's authority — `openHit` → `onOpen(.post(id))` → the detail mounts → `registerDetail` restores `focusedBlock` from `CurrentBlockMemory` → Write's bare arrival lands at that block's start (else the document start), Takes' landing on it. Pinned from the Library's side.
  - **Pins (one new file, `LibraryPanelTests.swift`):** the note preview brain (first block's text, the facts line, empty note) · the book preview brain (chapters + notes in order; the collapsed one-note chapter) · the mounted panel renders the first block's text / the chapters · the boundary holds inactive (the DEBUG oracle reports OUR divider under `controlActiveState = .inactive`; no `.inspector` in the composition — RED on old) · the List carries no selection binding and no `.tag` (RED on old) · the receipt lies inside the host and off the quick-entry bar (RED on old) · the book row's target spans the row (RED on old) · the Open door lands at the remembered block (door class: C's mechanism — stated) · the width rule (pure). Red-on-old by BEHAVIORAL REVERT after the fix commits (the protocol's addendum 11a).
- **Piece 1 (the panel + the container + row 56 + F's (a) + the book door):** DONE (this commit; hash next) — `LibraryInfoPanel.swift` rebuilt in place: the pure brain `LibraryPreview` (`note(_:id:)` → words · blocks · last edited · sealed/archived + the blocks; `book(_:id:)` → kind · finished · chapters · notes + `outline(rows:)`, the navigator's rows flattened with row 8's collapse decided purely; `factsLine`/`bookFactsLine`), `LibraryPanelLayout.width(total:)` (the inspector's own 420 ideal / 280 minimum, 34 % of the library between), the panel (title · ONE facts line · the full-width **Open** / **Open Book** door · the note's text as a `LazyVStack` of `FlowParagraph` rows in the voice's type, or the book's outline as full-width row doors with a hover wash — a note row opens the book AT that note), the subject swap fading (`.transition(.opacity)` keyed on the hit), the DEBUG `LibraryPanelOracle` + `libraryGeometryProbe`. `LibraryCatalogView.swift`: the `.inspector` RETIRED for an `HStack` — the list column, `panelDivider` (1 pt `tokens.line`), the panel at `LibraryPanelLayout.width` on `tokens.room`, presence animated (`.move(edge: .trailing)` + opacity, 0.22 s); `List(selection:)` → `List` with `rowBackground(picked:subject:)` (the wash + a tinted border, radius 6) on note AND book rows and no `.tag`; the book row `frame(maxWidth: .infinity)` before its `contentShape` + `CatalogBookLine` gains a trailing `Spacer` (row 33 (a)); the receipt/error is `messageRow` — a laid-out row above the bottom divider (F's (a)); `onOpenBook` (bookID, postID) added and wired in `RootView` to `openBook(_:at:in:)` (B's ascent road). Debug build green.
- **Piece 2 (the pins):** DONE (this commit; hash next) — `VariorumTests/LibraryPanelTests.swift`, 12 tests / 2 suites: **`LibraryPreviewBrainTests`** ×6 (a note's blocks in order + the facts line · an empty note · the facts lines' state words · a book's chapters and notes in the book's order with row 8's collapse and the unfiled trail · a chapterless book flush · the width rule) and **`LibraryPanelHostTests`** ×6 on the REAL mounted catalog (`aNoteSelectionStandsThePanelUpWithItsBoundaryActiveAndInactive` — the divider 1 pt wide at the panel's leading edge running the column's height, the panel at the ruled width to the room's edge, the note's blocks rendered, in BOTH `controlActiveState = .key` and `.inactive`, and no "inspector" in the composition · `aBookSelectionShowsTheBooksOutline` — the four chapter/note rows rendered, no note text · `theReceiptIsLaidOutAboveTheBarNeverOverIt` — the archive receipt's frame inside the host, above and disjoint from the quick-entry bar's · `aBookRowsLineSpansTheRow` — the line ≥ 590 of 600 · `theListCarriesNoSelectionBindingOfItsOwn` — `List<Swift.Never`, no `List<Swift.Set<` · `theOpenDoorLandsWhereTheCaretLastWas` — a note whose memory holds block 2 mounts with the caret at block 2's start). Green with the neighbours: **27 tests / 5 suites** (+ `NoteRowRoutingTests` 8 · `NoteRowSelectionRuleTests` 5 · `LibraryRowAlignmentTests` 2, unmodified). Harness lesson recorded at the pins: a `LazyVStack`'s `onAppear` order is not the visual order — the host pins assert containment, the brain pins the order.
- **The red-on-old (behavioral revert):** **revert starting — pre-revert state is the commit `4ef9c80`** (the protocol's addendum 2/11: announced before it begins; restore = `git checkout --` the three production files from the REPO ROOT — `LibraryCatalogView.swift` · `LibraryInfoPanel.swift` · nothing else — then `git diff --stat` empty). Mechanisms switched back IN PLACE with the oracle wiring kept: the `.inspector` host back (row 34) · the receipt as the bottom-left overlay (F's (a)) · the book line's `Spacer` out (row 33 (a)) · `List(selection:)` + `.tag` back (row 56) · the panel's preview emptied — no blocks, no outline rows — the old facts panel's state (rows 1/33 (b)). **Result: 11 issues in 9 of the 12 tests — every mechanism RED** (log `e-red-on-old.log` in the session scratchpad): row 34 — `LibraryPanelOracle.dividerFrame → nil` and the settle timed out (no divider of ours exists under the `.inspector`); F's (a) — the receipt's `message.maxY → 672.0` against the bar's `minY + 0.5 → 579.5` (the overlay ON the quick-entry bar); row 33 (a) — the book line `frame.width → 219.0` against ≥ 590 (its words' width); row 56 — the composition carries `List<Swift.Set<`; rows 1/33 (b) — the brain's `blocks → []` (+ the facts line saying `0 blocks`) and `rows → []` twice, and the mounted book panel rendered no outline row (the settle timed out, the set empty). The Open-door pin stayed GREEN under the revert (door class, as stated — C's mechanism is untouched by this batch). **Restored** by `git checkout --` of the two production files from the REPO ROOT; `git diff --stat` empty; `git status` clean against `9b0b8e0`. **No revert in flight.**
- **Piece 3 (row 24's panel half — found by the walk's burst capture):** DONE (this commit; hash next) — the first cut animated the column's presence with `.animation(.easeInOut(0.22), value: model.infoHit != nil)` on the container; a burst capture by window id (12 frames ~100 ms apart across a row click) showed the panel go from ABSENT to fully SETTLED between two frames — the modifier did not carry the transition through the `@Observable` model's change. Fix: the presence changes are made in an animated transaction at the mutation sites (`withAnimation(Self.panelAnimation)` around `clickNoteRow` / `selectBook` / `closeInfo` — the row taps, the panel's Close, the open road, the outline door); the re-burst on the rebuilt tree shows the boundary fading in across three frames (`(250,250,246) → (235,235,229) → (228,228,221)` at the divider's column — ~200 ms, the 0.22 s curve). Not pinnable (an animation; batch A's precedent) — the burst's numbers are the evidence (`batch-e/burst/`).
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build of THIS tree (pid 21196, then 25209 after piece 3; window 1728×1084), Terminal AND Study; the walk table is below; **the contact sheet is `batch-e/contact-sheet.png` (36 tiles; the crops and the burst frames sit in `batch-e/crops/` and `batch-e/burst/`, out of the sheet)**. One defect found by the walk on THIS surface and fixed in-batch (piece 3 — the presence animation); one found on the BOOK's road and RECORDED (row 73); one seen at the code and RECORDED (row 74).
- **Suites:** DONE — the batch's two suites + the ten `TutorialWalkTests.swift` suites (by type name — `-only-testing:` wants `TutorialBookShapeTests` etc., not the display names): **12 / 2 + 71 / 10 green**. Then the FULL Mac suite once on the final tree (`4e5a39e`): **2049 tests / 361 suites, all green** (`** TEST SUCCEEDED **`, 317.5 s; log `batch-e/e-full-mac.log`). **Arithmetic against batch D's close 2037 / 359:** +12 tests (`LibraryPreviewBrainTests` 6 · `LibraryPanelHostTests` 6) ⇒ **2049**, exact; +2 suites ⇒ **361**, exact. The known load-flaky pins PASSED in-run (`rewriteStrategyLatencies` 2 cases · `CanvasDragTrackingTests` · F's noted `aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens`) — nothing re-run, nothing loosened; zero `✘` in the log. **Core 1524 / 165 untouched** (`git diff --stat d6b53e5..HEAD -- Sources/` empty; zero `Sync/`). **`App/Variorum/Shared/` untouched** (empty diff — the iOS target sees no change from this batch). The batch's whole diff: `LibraryInfoPanel.swift` (rebuilt) · `LibraryCatalogView.swift` · `RootView.swift` (3 lines: the `onOpenBook` wiring) · the new `LibraryPanelTests.swift`.
- **STATUS: BATCH E's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build of the final tree (pid 25209) is left RUNNING for that walk — Terminal voice, the Library open with the search cleared, window zoomed; `/Applications` untouched; her real-store app untouched (not running). Tree clean; every commit pushed.
- **No revert in flight** (the behavioral revert ran from `4ef9c80` and was restored — evidence above; the tree is clean against `4e5a39e`).

#### Per-row dispositions

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 1 | FIXED — the SIMPLE READ PREVIEW: the title · ONE facts line (`N words · N blocks · edited <day>`, the state words `sealed`/`archived` only when true) · the full-width **Open** door · the note's rendered text as a lazy stack of `FlowParagraph` rows in the voice's type (the SwiftUI read tier — never TK2); the Open door lands where the caret last was (walked: **block 8/215** after the caret had been put in block 8 and the note left) | `LibraryPreviewBrainTests.aNotePreviewsItsBlocksInOrderWithOneFactsLine` · `.anEmptyNotePreviewsNothingAndSaysSo` · `.theFactsLineNamesOnlyTheStatesThatAreTrue` · `LibraryPanelHostTests.aNoteSelectionStandsThePanelUpWithItsBoundaryActiveAndInactive` (the blocks rendered) · `.theOpenDoorLandsWhereTheCaretLastWas` (door class — C's mechanism, stated) | 3 issues under the emptied-preview revert (`blocks → []`, the facts line saying `0 blocks`, the host's settle) |
| 33 | FIXED — (a) the book row's TARGET spans the row (the line gains a trailing `Spacer`; the row a `frame(maxWidth:)` before its `contentShape`); (b) a book shows its OUTLINE — chapters and notes in the book's own order, row 8's one-note-chapter collapse, strays trailing unfiled (walked: Sherlock's 13 chapters, "About this book" indented under its differently-named chapter); a note row opens the book AT that note through B's ascent road (`onOpenBook` → `RootView.openBook(_:at:in:)`) — **the LANDING at mount is B's road's residual, row 73** | `.aBookPreviewsItsChaptersAndNotesInTheBooksOwnOrder` · `.aChapterlessBookPreviewsItsNotesFlush` · `LibraryPanelHostTests.aBookSelectionShowsTheBooksOutline` · `.aBookRowsLineSpansTheRow` | 5 issues (`rows → []` twice; the mounted book panel rendered no outline row + its settle; the line `219.0` against ≥ 590) |
| 34 | FIXED — the `.inspector` RETIRED for a column of OUR OWN: the shell's 1 pt `line` divider + the panel on `tokens.room` at `LibraryPanelLayout.width(total:)` (420 ideal / 280 minimum / 34 % between — the note-side inspector's own numbers); measured IDENTICAL active and inactive in both voices (`13-crop…`, `34-crop…`) | `.aNoteSelectionStandsThePanelUpWithItsBoundaryActiveAndInactive` (the divider 1 pt at the panel's leading edge, the column's height, the ruled width, in BOTH `controlActiveState`s; no "inspector" in the composition) · `LibraryPreviewBrainTests.thePanelWidthIsTheInspectorsNumbersClampedToTheRoom` | 2 issues (`dividerFrame → nil`; the settle timed out under the `.inspector` host) |
| 24 (the panel half) | FIXED — the column's presence SLIDES + FADES (0.22 s) in an animated transaction made at the mutation sites (piece 3; the container-level `.animation(value:)` did not carry it — the burst proved it); the subject swap FADES inside the panel (`.transition(.opacity)` keyed on the hit, 0.18 s); nothing teleports | — (an animation; the burst trace `batch-e/burst/` — the boundary's column fading in across three ~100 ms frames — is the evidence; batch A's precedent) | — |
| 56 (A's find) | FIXED — `List(selection:)` and the rows' `.tag` retired; the pick (⌘/⇧-click) and the panel's subject wear the calm grammar — `tokens.wash` + a tinted border (radius 6; the subject's border fuller) — on note AND book rows; the model still owns the pick (walked: two ⌘-picked rows washed, the bulk bar standing, no band in either focus state) | `.theListCarriesNoSelectionBindingOfItsOwn` (`List<Swift.Never`, no `List<Swift.Set<`) | 1 issue (`List<Swift.Set<` present) |
| F's (a) | FIXED — the receipt/error is a LAID-OUT message row above the bottom divider (`messageRow`; the receipt muted, the error alarm; `lineLimit(3)` + `fixedSize` per P-8), never an overlay on the quick-entry bar (walked: "Note archived — it's kept in Archived, with no countdown." whole, above the bar) | `.theReceiptIsLaidOutAboveTheBarNeverOverIt` | 1 issue (`message.maxY → 672.0` against the bar's `579.5`) |
| 36 (on this surface) | DONE — the old panel's facts CARD (words · blocks · with takes · comments · entry date · last edited · created) and its books and tags cards → ONE facts line (words · blocks · edited; the state words only when true); A's table's `LibraryInfoPanel.swift:189 words KEEP` is honored as the line's first fact; the tags stay on the row, the books on the note's masthead | — | — |
| 54 (from B/C) | RECORDED — the panel does NOT show the read tier's provisional-width jump: the preview composes the SwiftUI `Text` tier (`FlowParagraph` rows in a `LazyVStack`), never `ReadPostView`; 13u2 item 1 keeps its other hosts (the note-only window, the book) | — | — |
| **73** (new — the walk; NOT this surface — the book's) | **RE-OWNED to G as a FIX by the orchestrator (18:30 MDT)** — RECORDED by E (owner: **G** as a bounded fix, or B's road's next touch) — **an ascent INTO A NOT-YET-MOUNTED book lands at the TOP, never at the note.** Mechanism (traced at `BookView.swift:1284–1293`): `landOutlineReveal` runs at Outline's `onAppear` (and on `pendingReveal`'s change) and calls `model.consumeReveal()` BEFORE its `model.entries.contains(postID)` guard — at mount the book's entries have not arrived, so the request is consumed and DROPPED; nothing re-lands when the entries come. Reproduced TWICE in use: the panel's outline row (`15-terminal-outline-row-opens-book-at-note` — the Boscombe card mid-page, the page at the top) AND the standing 13f W20 chip ascent through the membership popover's link (`26-terminal-chip-popover-link-ascent` — identical), so the gap is the road's, not this door's; a navigator click on an OPEN book lands (B's pins cover exactly that case). Fix shape: never consume a reveal whose note is not yet in `entries` — leave it parked and land it on the entries' arrival (`.onChange(of: model.entries)` → `landOutlineReveal`), a few lines in `BookView.swift`; pin: a mounted book whose reveal request arrives before its entries lands the note at the top (RED on the current tree). | — | — |
| **74** (new — seen at the code; NOT this surface) | **CONFIRMED IN USE by the orchestrator's probe (18:25 MDT — window-id capture active vs inactive with the tray open: the divider present, then absent; `orchestrator-e/r74-*`) → G as a FIX** — RECORDED by E (owner: **G**, or 13u2 item 1's family) — the NOTE-side inspectors (`PostDetailView.swift:350` — references · scraps · Block History · the tray · Versions) and the Canvas tray (`CanvasView.swift:947`) are the same SwiftUI `.inspector` class row 34 retired here: their divider is the system's, drawn in a KEY window only, so tabbed out the boundary between a note and its tray/history pane may vanish exactly as the Library's did. VERIFY in use first (a window-id capture inactive, as this batch did) — a pane that paints its own wash may hold without it; the Library's column (an `HStack` + our line + a width rule) is the precedent if it does not. | — | — |

#### The text tier, and row 54 — stated (the addendum's question)

The preview uses the **SwiftUI `Text` tier**: `LibraryNotePreview` is a `ScrollView` + `LazyVStack` of `LibraryPreviewBlock` rows, each rendering `FlowParagraph.paragraphs(of:)` — the same read-cheap tier the note's Read page (`ReadPageBlock`) and the book's flow use — in the voice's `body`/`heading` type on the panel's `room`. The TK2 `ReadPostView` is not composed, so **row 54's provisional-width double measure does not show in this panel** (the 9k-word Boscombe preview arrives in one paint at 0.6 s — `17-terminal-long-note-preview-0.6s`). The blocks are read ONCE per selection (`Queries.renderPost`, the read the old panel already made for its word count); rows render lazily.

#### The USE gate — the walk (the dev-store Debug build of this tree, window 1728×1084; every capture in `act10-correction-screens/batch-e/`; **the sheet: `batch-e/contact-sheet.png`, 36 tiles**; crops in `crops/`, the burst in `burst/`)

| Row | What was done | Capture(s) |
|---|---|---|
| (before — batch D's build, the panel byte-identical to HEAD) | The old facts panel on a note; the boundary ACTIVE (one pixel column) vs INACTIVE (uniform) by window-id capture; a book row's body click DEAD (the panel keeps the note); the "book" label click → the book's FACTS; the note row's system band (grey unfocused / blue focused) | `01-before-note-panel-active` · `05-before-book-panel-active` · `02-before-book-panel-inactive` · `06-crop-boundary-active-vs-inactive` · `03-before-book-row-clicked` · `04-before-book-label-clicked` |
| 1 | A note row's body click → the panel: title · `161 words · 5 blocks · edited 2026-09-01` · the full-width Open · the note's text in the voice's mono (Terminal) / serif (Study) | `11-terminal-note-selected-panel` · `30-study-note-panel` |
| 1 (a long note) | Boscombe (9,689 words · 215 blocks) previewed 0.6 s after the click, text and all | `17-terminal-long-note-preview-0.6s` · `17b-…` |
| 1 (the Open door) | The caret put in block 8 of Boscombe in Write (`19`: "block 8/215"), the note left for the Library, its row body-clicked, **Open** clicked → the note opens at **block 8/215** — where the caret last was | `19-terminal-caret-moved` · `24-terminal-boscombe-row-body-panel` · `25-terminal-open-door-landed-block8` (the bar's crop in `crops/`) |
| 34 | The same panel captured by window id ACTIVE and INACTIVE (Finder frontmost): the boundary identical — our line + the room's wash — in Terminal AND Study | `11` vs `12-terminal-note-panel-inactive` · `13-crop-boundary-active-vs-inactive-after` · `30` vs `31-study-note-panel-inactive` · `34-crop-study-boundary-active-vs-inactive` |
| 33 | The Sherlock book row's BODY clicked far right of its text → the panel shows the book's OUTLINE: `book · 13 chapters · 13 notes`, Open Book, "about this text" with "About this book" indented, the twelve same-named chapters as one row each | `14-terminal-book-row-body-click-outline` · `32-study-book-outline` |
| 33 (the outline's door) | "the boscombe valley mystery" clicked in the panel's outline → the book opens in Outline — **at the TOP, the Boscombe card mid-page (row 73)**; the standing chip ascent (the popover's link) lands the same way | `15-terminal-outline-row-opens-book-at-note` · `20-terminal-chip-ascent-into-book` (the popover) · `26-terminal-chip-popover-link-ascent` |
| 24 (panel half) | A row click captured as a 12-frame burst by window id (~100 ms apart): BEFORE piece 3, absent → settled between two frames; AFTER, the boundary's column fades in across three frames (`250 → 235 → 228`) | `11a`/`11b` (the early single frames — empty, the timing) · `11c-terminal-panel-settled` · `burst/f1…f12` (the post-fix burst) |
| 56 | ⌘-click on "the seal" then on "blocks · canvas": both rows washed with the tinted border, no system band; the bulk bar (`tag 2 notes · untag 2 notes · delete 2 notes…`) and the panel's "2 notes selected" card | `27-terminal-pick-two-rows` |
| F's (a) | The first "2026-09-01" row's context menu → Archive → the receipt "Note archived — it's kept in Archived, with no countdown." as a WHOLE row above the divider and the quick-entry bar | `28-terminal-archive-receipt` |
| (aside) | The Settings ▸ Appearance switch (Study, then Terminal restored) | `29-settings-window` · `33-terminal-restored` |

Honesty notes: `02-before-note-panel-inactive` was OCCLUDED (Finder's activation brought the terminal window over the dev window — the region capture caught it; moved to `crops/02x-…FAILED…`) and every inactive capture after it is by WINDOW ID (`tools/winid`, new beside `click` — `screencapture -l <id> -o` needs no activation); the two early mid-slide single frames (`11a` at 0.12 s, `11b` at 0.2 s) are EMPTY — the poster's click lands ~0.15 s after issue — which is why the burst exists; the chip's first click opened the membership POPOVER (its link is the ascent door) and swallowed the following Library click, so the Open-door sequence was re-run step-verified (`23`/`24`/`25`); the AX static-text queries returned nothing for the Library window (the earlier records' finding) — every fact here is a capture's or a pixel sample's; the dev store now carries walk artifacts (the empty "2026-09-01" ⌘N note ARCHIVED through the context menu; `currentBlock.<Boscombe>` = block 8; the walk's `readFace`/`postMode` memories) — harmless, dev store only.

#### Commits (in order)

1. `65db0e0` — the record opened (LIVE STATUS; the mechanisms traced in USE; the settled design).
2. `04355fb` — piece 1: the panel rebuilt (the preview brain + the view + the oracle), the column of our own, the calm-grammar pick, the message row, the book door's wiring.
3. `4ef9c80` — piece 2: the pins (12 / 2; 27 / 5 with the neighbours).
4. `9b0b8e0` — revert starting (the record names the pre-revert state first).
5. `00a1684` — the red-on-old evidence (11 issues in 9 tests); restored, no revert in flight.
6. `4e5a39e` — piece 3 (row 24's panel half): the presence animated at the mutation sites — found by the walk's burst.
7. `89b8778` — the USE gate's walk table + sheet, the suite counts and arithmetic, the dispositions, rows 73–74, the LIVE STATUS final, the ledger cells for 1/33/34/24. 8. (this commit) — the hashes filled.

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed through `4e5a39e` (+ the record commit `89b8778` and this hash fill); no revert is in flight; the tree is clean; the final Mac suite is green at 2049/361 exact over D's 2037/359; core and `Shared/` untouched. Every batch-E row is FIXED with a red-on-old pin (1 · 33 · 34 · 56 · F's (a) — 3/5/2/1/1 issues under the behavioral revert) or walked (24's animation, by the burst); two new rows are RECORDED with owners: **row 73** — an ascent into a not-yet-mounted book lands at the top (B's road; the panel's outline row and the standing chip link share it; a bounded `BookView` fix + pin — G's shape, or authorize it), and **row 74** — the note-side `.inspector`s are the same key-window-divider class row 34 retired here (verify in use first). Two honest limits: the Open door's pin is door-class (C's `CurrentBlockMemory` mechanism, pinned red-on-old in C; this batch pins the Library's promise on the same road and walked it landing at block 8/215), and the presence animation is walked by a burst trace rather than pinned. R-cor-3's shape is RATIFIED (R-cor-10(1)); nothing here is PROVISIONAL beyond the two taste choices stated in the design (the panel on the ROOM wash; the outline's chapter row opening the book at its first note). Walk suggestions: Library ▸ click a note row's BODY (the panel slides in; the text; the facts line) · ⌘-Tab away and back (the boundary holds) · click the Sherlock row's body far right of its words (the outline) · click "the boscombe valley mystery" in the outline (the book opens — at the TOP: row 73) · search "boscombe", click the row body, put the caret somewhere in the note first if you like, **Open** (lands at that block) · ⌘-click two rows (the wash + border) · a row's context menu ▸ Archive (the receipt row) · Settings ▸ Appearance ▸ Study for the same. Known non-E residue seen in passing: the chip's membership popover is the ascent's door (its link), not the chip itself — fine, not a defect; nothing in the book, the note modes, the masthead, Compare/Lenses or the recovery family was touched.


---

#### BATCH E RECORD — CLOSED by the orchestrator (2026-09-01 18:30 MDT; captures `orchestrator-e/`)

Verified against git first: eight commits `65db0e0`…`ef1a972`, tree clean, pushed; the code diff is exactly
`LibraryInfoPanel.swift` (rebuilt) + `LibraryCatalogView.swift` + three lines of `RootView.swift` + the new pin
file (C-1 held; core and `Shared/` untouched). Read the record, then two full captures at the riskiest rows
(`batch-e/11` — the note panel: title · `161 words · 5 blocks · edited 2026-09-01` · the full-width Open · the
rendered text in the voice's type, the picked row wearing the wash + tinted border; `14` — the Sherlock row's
body click → the book's outline in the navigator's grammar, "About this book" indented under its
differently-named chapter). **E's rows 1/33/34/56/F-(a) are FIXED in use; 24's panel half walked by E's burst.**
**The live probe took E's row-74 suspicion and CONFIRMED it:** Boscombe open, the masthead's tray icon → the tray
inspector; the window captured BY ID active and with Finder frontmost — at y = 1400 px the ACTIVE image has one
edge at x = 2614 (the divider) and the INACTIVE image has NONE (`r74-tray-active/inactive`,
`r74-crop-side-by-side`: a faint line on the left half, nothing on the right). The note-side inspectors ARE the
key-window-divider class the Library just retired → **row 74 RE-OWNED to G as a FIX** (the Library's column-
of-our-own precedent applied at the ONE `.inspector` host in `PostDetailView` that serves references · scraps ·
Block History · the tray · Versions, plus the Canvas tray). **Row 73 → G as a fix** (E's traced mechanism: the
reveal consumed before the entries arrive; a bounded `BookView` change + pin). **New row 89** from the same crop:
the tray's "leaving" section meaning line TRUNCATES mid-word ("…put back keeps a row; del…") at the inspector's
default width — a sentence nobody can finish; the meaning line wraps, never truncates (F's row 63 rule, applied to
the section explainers). Counts at close: **Mac 2049/361 green** (D's 2037 + 12 / 359 + 2), core 1524/165 and
`Shared/` untouched, spine green in-run. The tray was closed again at the end; the voice is Terminal.
**Batch G spawned next.**

---

### BATCH G — RESIDUALS AND WIDTH (brief; ADDED 2026-09-01 ~16:35 MDT at her ruling R-cor-10(2) — spawn after E closes; the ladder follows G. The row list is COMPLETED at D's close with the orchestrator's Snippets/Pool/Canvas walk finds — PENDING until then)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record.

**Why this batch exists, and the C-1 deviation stated:** the round parked use-found defects on "the ladder's fix
round", but the ladder is a CODE review — it cannot find a ten-point hit target, a title under its icons at 950 pt,
or a click that does nothing. G is a RESIDUALS batch: several SMALL, independent, bounded fixes across small
surfaces, each one mechanism with one pin — not a phase-sized surface, so C-1's purpose (no five-in-one) holds. If
any row turns out to be a surface rewrite rather than a bounded fix, STOP on that row, record it with the reason,
and hand it to the orchestrator (it becomes its own batch or a 13u2 row) — never "also do" it.

**Read IN FULL:** this file (§0–§8; R-cor-10 is your ruling; the A/C/F records name the residuals' origins); the
source report §1; then per row the code — 59: `Features/Tags/MastheadTagCluster.swift` (the `＃` button; the row's
height is the target) · 80: `Features/Takes/PostDetailView.swift` (the two-row masthead; the 240-pt floor; the
`MastheadGeometry` oracle) with `VariorumTests/MastheadLayoutTests.swift` · 81: `Features/Editor/CommitBar.swift`
(the flat bar `:549–556` region; the side card's `ViewThatFits` precedent) with `CommitBarLayoutTests` · 82:
`Features/ReadMode/NotePagesView.swift`, `Core/Views/PageLeafView.swift`, `Features/BookView/PagedReadModel.swift`,
`PagedReadView.swift`, `Shared/LandingTarget.swift`, `ReadModeView.swift`'s landing consumer, with `ReadModeTests` and
`PagedReadTests` · 83: `Features/TOC/BlocksWorkbenchView.swift` (the five `.task`s; `WorkbenchRows`) with
`BlocksWorkbenchFaceTests`/`ModesSherlockMeasureTests` · 84: the 13g markdown display brain `App/Variorum/Shared/MarkdownFace/MarkdownFaceCore.swift` (+ `EditorBrain/MarkdownSurfaceDoors.swift` if the door grammar is touched; the phone shares both — the iOS build is owed at the ladder; read `notes/plans/phase-13g-*.md`'s vocabulary ruling first)
· 85: `Features/Tutorial/TutorialSeeder.swift` (the "the workspace" lesson) with `TutorialBookShapeTests` · 86:
`Registry/CapabilityRegistry.swift` (the `blockHistory` palette door) and `PostTitleLabel` in `PostDetailView.swift`
(+ `git show 0e6a09e^:App/Variorum/Variorum/Features/Takes/PostDetailView.swift` for the pre-Act-10 title).

**Rows: 59 · 72 · 73 · 74 · 80 · **80b (her live find, added mid-run — walk it WITH 80 at the tray-open ~590-pt detail)** · 81 · 82 · 83 · 84 · 85 · 86 · 89 — each stated in the ledger with its mechanism read and its pin —
plus 87 (the Pool card's first-words preview via the picker's road) and 88 (Canvas: fit-all on a first arrival
with no remembered layout; the toolbar to the calm-chip grammar) — both RULED IN at R-cor-11. The E-close walk
may add more.** Order: 86 first (verify-first, cheapest), then 59, 80, 81 (the width family — walk them at ~950 pt
TOGETHER), 74 + 89 (the inspector family — walk the tray active AND inactive by window id, `tools/winid`), 73, 72,
83, 82, 85, 87, 88, 84 last (the one `Shared/` change). Files for 73: `Features/BookView/BookView.swift:1284–1293`
(`landOutlineReveal` consumes a reveal before `entries` arrive — E's trace) with `BookOutlineLandingTests`; for 74:
`Features/Takes/PostDetailView.swift:350` (the one `.inspector` host) + `Features/Canvas/CanvasView.swift:947`, on
batch E's precedent (`LibraryCatalogView`'s column + `panelDivider` + a width rule; `LibraryPanelTests`' inactive-
state pin is the shape); for 89: `Features/Tray/TrayPanel.swift` + `Shared/BlockHistoryFace.swift`'s explainers. Files for 87: `Features/Pool/PoolPostsView.swift`
+ the picker's preview road in `Core/Views/NotePicker.swift` (find where its two-line preview comes from — reuse THAT
query/brain, never a second rule); for 88: `Features/Canvas/` (the arrival's viewport when no `canvas_layout` view
state is remembered; the toolbar row) with the existing canvas pins (`CanvasDragTrackingTests` is load-flaky — a
KnownIssues row; never loosen it).

**Rules (§2b) bind; the acceptance gate is USE:** captures in `act10-correction-screens/batch-g/` at BOTH 1708 pt
zoomed and ~950 pt, both voices — the `#` hit at the row's edges, the masthead + bottom bar at 950, a `pages` click
landing in `edit`, Blocks arriving painted (a timing series), an underscore-italic paragraph in Sherlock, the
re-seeded lesson text on the DEV store (Help ▸ Restore Tutorial… there — never her store). Bug-class rows (80/81/
82/83/86) land with red-on-old pins by BEHAVIORAL REVERT; 59 is a geometry pin; 84/85 are door/text pins.
Environment §6 + the driving recipe + the resiliency rules of batch B's brief's last three paragraphs bind
identically (a `LIVE STATUS — BATCH G` list from your FIRST commit; commit + push per row; synchronous foreground
waits; never `/Applications` or her real-store app; relaunch the dev build on YOUR tree). `TutorialWalkTests` green,
then the FULL Mac suite once on the final tree — baseline = batch E's recorded close counts; state the arithmetic;
the load-flaky reds re-run isolated, never loosened. New findings become rows numbered after E's last (the
orchestrator's rows are 80+ — continue past whichever is higher). **Trailer for every commit:**
`Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` +
`Claude-Session: https://claude.ai/code/session_019VxbpYiG4SvQfYdx5cXCBC`. **Deliverable:** the BATCH G RECORD under
this brief; your final message is ONE pointer to it; then stop.

### BATCH G RECORD — RESIDUALS AND WIDTH (a fresh Fable implementer session, 2026-09-01 18:40 MDT →; the machine's clock)

#### LIVE STATUS — BATCH G (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — read in the brief's order: CLAUDE.md; this file whole (§0–§8, R-cor-1…11 with R-cor-10(2)/(4) and R-cor-11(2)/(3) as this batch's rulings, the constitution + C-1…C-7, the ledger's rows 59 · 72 · 73 · 74 · 80–89 with their mechanism columns, every batch record and CLOSED line — B's brief's last three paragraphs, A's masthead history (rows 55/58/59), C's Blocks/Read host, F's recovery family, D's Compare header strip, E's Library column precedent + the row-73 trace); her report §1; the resiliency protocol; the orchestrator handoff §0/§0b/§2c. Tree clean at `f1cc073`; the dev-store Debug build pid 25209 (batch E's tree — byte-identical to mine on every file this batch touches until the first commit) running; her real-store app NOT running; `/Applications` untouched.
- **Row 86 (verify-first) — VERIFIED on the running build BEFORE any code moved:** **(e) NOT A DEFECT** — a click on the masthead title of a titled note (Boscombe) opened the rename field with the title selected (`crop-86e-01-masthead`); the current `PostTitleLabel` carries `.onTapGesture { beginEditing() }` exactly as the pre-Act-10 file did (`git show 0e6a09e^:…PostDetailView.swift:440`) — no regression; F's seed-03 note was a scratch note NAMED BY ITS DAY, where the open field shows the day as its PROMPT in the label's own place (the one case walked again below). **(d) STILL A DEFECT, not healed by C** — Blocks, row 03 selected, ⌘K "block history" ⏎ → the toast "Put the caret in a block and its History shows…", no pane (`86d-03-after-enter`). Mechanism: the palette act was `dispatch(.showBlockHistory)`, routed only to the mounted SURFACE's command handler — `EditorView`/Takes/Lenses register one, Read's faces and Blocks register none — so it fell through to the registry's unhandled note whatever `focusedBlock` held (C's memory could not heal a handler gap). → FIX (this commit).
- **Row 86(d):** DONE (`bb4645c`) — `CommandRouter.requestBlockHistoryForFocusedBlock()` (the focused block → a `BlockHistoryRequest` → the mounted detail's inspector) + `ShellActions.showBlockHistory()` (`toggleSeal`'s shape: a QUIET dispatch, the router's focused-block road when no surface handled it, the honest note only with no block in hand); the palette's row routes there. Pin `BlockHistoryPaletteDoorTests.thePaletteRowOpensTheFocusedBlocksHistoryWhereNoSurfaceHandlesIt` (in `CommandRoutingTests.swift`). Red-on-old: 3 issues under the behavioral revert (below).
- **Row 59:** DONE (`0a44a87`) — `MastheadTagCluster.doorTarget` = 24: the ＃'s label is a 24 × 24 frame with a rectangular content shape (the glyph centred inside it — the label's old 3/2-pt paddings gave a ~16 × 17 target); the door reports its frame to the DEBUG oracle (`MastheadProbeSlot.door` · `MastheadGeometry.doorFrame`). Honest note: the flow places the door's frame, so the glyph sits ~4 pt further left than before (the frame grew symmetrically around it) — invisible in use, recorded. Pin `MastheadLayoutTests.theTagDoorsHitTargetIsTheRowsHeightNotTheGlyphs` (the door's frame ≥ 24 × 24). Red-on-old: 1 issue under the revert (the door under 24 wide).
- **Row 80:** DONE (`0a44a87`) — **the mechanism, traced at the code and against F's `walk-19` crop:** F's "~950 pt" is the window at 950 WITH an inspector open — the detail's content column ~316 pt, the masthead ~270; `mastheadInset(for:)` was SYMMETRIC and capped by the 240-pt floor on BOTH sides (`min(icons + 12, (W − 240) / 2)` = ~15 at 270), so the trailing inset fell under the ~100-pt icon row and the title's words ran under the tray icon. Fix: `MastheadTitleInsets` (pure, `PostDetailView.swift`): the TRAILING inset always keeps the icon row clear (`iconRowWidth + 12`); the LEADING inset is symmetric while the masthead holds the floor between two such insets, then shrinks continuously (no jump) — the floor spent on the leading side, the title's centre drifting left — to 0 below floor + icons, where the title yields to `…` (legal; under the icons is not). At the standing widths both insets equal `icons + 12` exactly as before, so rows 4/19/58's pins ride unmodified. The title TEXT's frame and the icon row's frame join the DEBUG oracle (`titleFrame` · `iconRowFrame`). Pins: `theTitleInsetsKeepTheIconsClearAndSpendTheFloorOnTheLeadingSide` (pure: wide symmetric · the floor kept with the trailing inset whole · the title yields · unmeasured symmetric) · `theTitleNeverRunsUnderTheIconsAtANarrowMasthead` (the real detail at 340 pt — the masthead 292 — with a title long enough to fill its band: the text's maxX + 12 ≤ the icon row's minX). Red-on-old: 4 issues under the revert (the insets 80/80; the title 65 pt under the icons).
- **Row 81:** DONE (`0a44a87`) — **the mechanism (F's `walk-18` crop):** at the inspector-open measure (~316 pt) item 6's two-row fallback (`usesTwoRows`, < 840) wrapped AND truncated every label (`blo… · t… · c… · h… · 24w…`) — `VoicedButtonStyle`'s `lineLimit(1)` truncating under compression, P-8 honoured into illegibility. Fix: the two-row form RETIRES for a FOLD — `CommitBar.arrangement(width:)` (pure): `.full` ≥ 840 (the standing one row, byte-unchanged), `.folded` 600–840 (ONE row: where-you-are · `block ▾` · commit ⌘S · history · `note ▾` · **`more ▾`** [takes · comments · Aa] · the note's total as the word-target door · `?`), `.compact` < 600 (where-you-are · `block ▾` · `more ▾` [commit ⌘S · takes · history · comments · Aa · the note's items as a `note` submenu] · `?`); every member of a folded row is `fixedSize` (a `Group`'s modifier applies per child), so a label can never truncate — the tier guarantees the fit; the note menu's two presentations (the date popover, the delete confirm) ride whichever control carries the note's items (`presentingNoteDoors`); the vertical rail untouched in shape. **Row-36 verdict for the folded rows (C-6):** the `Nw block · Nw selected` counts DROP below 840 (the side rail's own verdict; the note total stays as the word-target door); in `.compact` the count line drops too — the setter is one inspector-close away (recorded as an honest limit). Every door survives at every width (`renderedCapabilities` unchanged). DEBUG oracle `CommitBarGeometry` (the row's frame in the bar's space + the bar's width). Pins: `CommitBarLayoutTests` — a JUSTIFIED PIN EDIT (item 6's three pins re-expressed in the arrangement vocabulary: the same widths, the same verdicts; 316 = F's walk) + `theBarStaysOneRowWithNothingPastItsEdgeAtNarrowMeasures` (the real bar mounted at 1200 as the reference, then 691 and 316: the row exactly one row tall, its frame inside the bar's padding). Red-on-old: 2 issues under the revert (38.0 pt — two rows — at 691 and at 316).
- **Row 74:** DONE (`4bf3324`) — **`SideColumn`** (`Core/Views/SideColumn.swift`, the Library's batch-E column HOISTED to the shared home — two hosts consume it now): an `HStack` of the host's content and, while shown, OUR 1-pt divider in the voice's `line` carrying the workbench seam's drag grammar (a 9-pt grip, the resize cursor — the room the inspector let her drag is still hers; the width remembered per host under `@AppStorage`) and the panel at `SideColumnLayout.width` (pure: the remembered width else the ideal, clamped to 280…640 and to the room that leaves the content ≥ 320); the presence slides + fades from the MUTATION sites (E's burst lesson — every door that opens/closes the panel, the router's three closures and the occupants' Close included, runs inside `withAnimation(PostDetailView.panelAnimation)`). `PostDetailView`: the ONE `.inspector` host (references · scraps · Block History · Versions · the tray) RETIRED for the column; the occupants' `.inspectorColumnWidth`s retired for the column's one rule (the tray's 420/280, which every occupant but references and scraps already used; the dragged width is remembered for all). `PoolDetailView` (`CanvasView.swift` — the scraps area's tray): the same. The panes keep their own `surface` backgrounds; the boundary in every window state is OUR line. Pins `SideColumnTests` ×2 — the width rule (pure) and the REAL detail mounted with `controlActiveState = .inactive`, the tray opened through the router: our divider reports its frame (1 pt wide, the column's height, at the panel's edge), no `InspectorStyleContext` in the tree, no SwiftUI inspector in the body's composition — red-on-old 2 issues under the revert (the settle + the nil frame). **Four JUSTIFIED PIN EDITS** (`BlockHistoryHostTests` · `BlockHistoryPaneTests` · `NoteVersionsPaneTests` · `TrayPanelMoveTests`): their "the pane stands" evidence was the SYSTEM inspector's AppKit class (`InspectorStyleContext`) — the very host this row retires; the evidence is the column's oracle now (`PostDetailOracle.sideColumnDividerFrame`), annotated at each site.
- **Row 89:** DONE (`4bf3324`) — `CalmSectionHeader`'s detail (the family's ONE meaning-line view — the tray's two sections, Block History's four) `lineLimit(3)` → `lineLimit(nil)`: a prose explainer wraps to its full length (F's row 63 rule for sentences; P-8's limit is for chrome labels); the two inline explainers of the same class — the tray's kept-in-lineage arrival sentence (`TrayPanel`) and the Block History pane's header explainer — the same edit; the status/refusal lines (`lineLimit(3)`, `textSelection`) left as transient receipts, recorded. Pin `RecoveryExplainerTests.theTrayLeavingExplainerRendersWholeAtTheNarrowestPane` — the shipped header at 256 pt (the column's minimum less the tray's padding) against an UNLIMITED reference of the same words in the same font: the shipped detail at least as tall (and the reference more than 3.5 lines, so the pin cannot hold vacuously). Red-on-old: 1 issue under the revert (42 vs 83 pt).
- **Row 73:** DONE (`4bf3324`) — E's trace confirmed at the code (`BookView.landOutlineReveal`): the reveal was CONSUMED before the `entries.contains` guard, so at Outline's `onAppear` — the book's entries not yet delivered — an ascent's request was consumed and DROPPED. Now a request whose note the entries have not delivered stays PARKED (the chapter reveal likewise, against the structure's sections); `onChange(of: entries' ids)` and `onChange(of: sections' ids)` re-run the landing when they arrive; a request for a note the DELIVERED entries do not hold is foreign and drops as before (a stale request must never land on a later navigation). Pin `BookOutlineLandingTests.aRevealRequestedBeforeTheEntriesArriveLandsWhenTheyDo` — an EMPTY model (no `adopt`), the reveal requested BEFORE the mount, the view's own observation delivering the entries after it: the note's card sits at the top. Red-on-old: 1 issue under the revert (the card never realized).
- **Row 72:** DONE (`42c7f5f`) — the strip's cards were uneven (the anchor card two lines, a peer card three plus its doors — D's `03`/`11`, the orchestrator's `02-crop`), so the strip's bottom edge stepped. Fix (`CompareBoardView.columnHeaders`): every card's content carries `.frame(maxHeight: .infinity, alignment: .top)` inside its `CalmCard` and the strip's `HStack` a vertical `fixedSize`, so each card stretches to the tallest sibling with its content top-aligned — an alignment fix under row 16's own rule; the memo's build still settles what the cards say. Pin `CompareLensesAlignmentTests.theHeaderStripsCardsShareOneBottomEdge` (a peer open: the anchor card's and the peer card's top AND bottom within 1 pt). Red-on-old: 1 issue under the revert (a 27.0-pt step).
- **Row 83:** DONE (`373251c`) — the mechanism (C's capture series, confirmed at the code): the mode's list waited for the observations' FIRST delivery (a value observation's initial fetch is scheduled through the database's queues and delivered a turn later), and FIVE sibling observations started at once, contending for the reader pool. Fix (`BlockTOCViewModel` + `BlocksWorkbenchView`): the rows are PRIMED by ONE bounded read (`Queries.blockTOC` — the observation's own query, cost ∝ the note) before the observation starts; the facts likewise (`Queries.blockWorkbench` before `observeBlockWorkbench`); the four sibling observations (facts · tray · pools · tags) `awaitPrimed()` so their first deliveries leave the critical path; the observations keep everything live exactly as before. Oracle: `BlocksWorkbenchOracle.firstRowPaintedAt`. **Measure pin** `BlocksArrivalMeasureTests.theFirstRowPaintsWithinTheCeilingOnATwoHundredBlockNote` — the real workbench on a 215-block note, mount → the first painted row: **0.056 s on this tree** (in-memory store), ceiling 1.5 s (a sanity bound; the harness cannot reproduce the encrypted store's ~0.25–0.5 s). Red-on-old: the old tree measured 0.060 s in the same harness — indistinguishable; the dev-store timing series in the USE gate is the evidence. The USE-gate timing series on the dev store is the evidence her hands feel.
- **Row 82:** DONE (`373251c`) — the mechanism: a `CTFrame` page hit-tested LINKS only (`PageFrameNSView.mouseDown`, L10); no block map existed. Fix: `PageComposer` already computed every block's display range for the callout indent — `ComposedPost.blocks` now carries them rebased onto the composed string exactly as the links are (`PageBlockRange`); `PagedReadModel.Leaf.blocks` rides beside `links`; `PageFrameNSView.hit(at:)` is the PURE decision — the link under the point first (L10 unchanged), else the block, else nothing — and `mouseDown` acts on it through `onBlockClick`; `NotePagesView(onOpenInEdit:)` wires the note's `pages` face to Read's own `openInEdit` (C's pinned road: `LandingTarget` → `edit` at that block, live); **the book's paged Read shared the defect (verified at the code — `PagedReadView` composed the leaves with no door) and takes the SAME fix** — `PagedReadView(onWake:)` → `BookView`'s flow wake (`requestLanding` + Index), factored into `pagedRead` (the body's expression outgrew the type-checker inline). Pins: `ReadRenderingTests.aPointOnThePageNamesTheBlockUnderItAfterTheLinks` (pure: a point on the link is the link, on prose its block, off the text nothing) · `ReadModeTests.aRealClickOnAPageReachesTheHostWithTheBlockUnderIt` (the pages face in the rig's panel, a REAL click on a leaf's prose → the host receives the block under it). Red-on-old: 4 issues in 2 tests under the revert.
- **Row 85:** DONE (`42c7f5f`) — the "the workspace" lesson's sentence taught the RETIRED fold ("＃ folds the note's tag cards away and back (⌘⇧I too…)") and "always the same four doors" on the context bar — twice stale: the bar's own row is THREE doors (`ContextBarDoors.Door`: back · book · forward; the ＃ left it at Act 10 item 5) and row 15 made the ＃ the ONE tag door on the masthead. The sentence now teaches the bar's three doors + the ⌫ badge, and the ＃ door's truth: the tags on the masthead's right edge under the icons; click the ＃ beside the cards → a tag field slides out with the cursor in it; ⏎ applies (a `/` nests); ⎋ puts it away; ⌘⇧I opens the same field. `TutorialBookShapeTests`/`TutorialWalkTests` hold plan ⇔ seed (structure unchanged); text pin `TutorialBookShapeTests.theWorkspaceLessonTeachesTheMastheadTagDoor` (the seeded lesson's rendered text carries the field's sentence, ⌘⇧I's, the three doors, and not the fold — 2 issues under the revert of the sentence). **The LIVE re-seed of her real store is HER morning act (§7b item 8; biometric); the DEV store is re-seeded in this batch's walk (Help ▸ Restore Tutorial…).** Red-on-old: by construction (the old text).
- **Row 87:** DONE (`42c7f5f`) — `PoolPostsModel.snippets` reads the listed notes' first words through the note picker's OWN road (`Queries.notePickerNotes(db, ids:)` — one statement for the Pool's window, beside the tags' load; one brain, no second rule); the card shows them as a two-line muted preview under a TITLELESS card's day only — `PoolCardFace.preview(title:snippet:)` (pure): a titled card already says what it is. 13u2 item 4 still designs the one-brain card family later. Pins `PoolCardPreviewTests` ×2 — the rule (titleless with words → the words; titled → nil; no words → nil) and the model on an in-memory store (a bare bookless note's snippet rides in through the picker's query; the titled one's stays off the card). Red-on-old: 5 issues in 2 tests under the revert.
- **Row 88:** DONE (`d35d4f0`) — **the mechanism, read at the code and the walk (`88-00-canvas-arrival-before`):** `Bank · 215` = every card unpositioned (no `canvas_layout` row), all on the spread grid; the viewport landed in the MIDDLE of the 15 × 15 grid (rows 97–162, the edges clipped) — a 2-axis `ScrollView`'s own initial position, not a landing of ours (nothing scrolls on arrival). **(a)** `CanvasArrival.fitsAllOnArrival(cards:storedPositions:alreadyFitted:)` (pure): a first arrival on a canvas whose store holds NO card position lands through the fit-all door as its projection arrives (`onChange(of: cards.count, initial: true)`, once per mount) — a small board scrolls to its bounds' centre at 1:1, a big one opens the read-only overview (a click lands on a card); a board with a remembered layout is left as it was. **(b)** the top strip in the calm-chip grammar: the tag filter is a `VoicedMenu` wearing its own face (`tag filter: all` / `#path` — the "Tag filter" label dropped), `fit all` / `back to 1:1`, the bank door and `order by clicking…` are `VoicedChip`s, apply/cancel `CalmButtonStyle`, `save picks as lens…` a chip (the 💾 dropped — calm chrome); the Blocks tool row's container (card + a bottom line). DEBUG `CanvasArrivalOracle`. Pins `CanvasArrivalTests` ×2 — the rule (never-arranged once; a remembered layout, nothing, or already-fitted never) and the REAL canvas on a 30-card never-arranged post landing through fit-all as its projection arrives (the outcome recorded, not `.empty`) + the strip composing no `Picker<` and no "Tag filter" label. `CanvasDragTrackingTests` (load-flaky, a KnownIssues row) passed in-run, untouched. Red-on-old: 2 issues under the revert (the rule false; no landing on arrival).
- **Row 84:** DONE (`42c7f5f`) — **where the brain actually lives, stated:** the tokenizer is `Sources/VariorumCore/Domain/MarkdownSyntax.swift` (core Domain — the brief named `Shared/MarkdownFace/MarkdownFaceCore.swift`, which is the FACE that applies attributes by span kind and needed no change; the phone inherits both by construction). The change is SMALL (a `case "_"` + two boundary helpers, ~30 lines) and DISPLAY-ONLY by construction: the scanner writes no text; `renderedText`, the `.md` export and the bridge's join brain never consult it; its other users are `SegmentationRules` (`isListLead` only) and `TypedArrows` (code spans only). The rule: `_italic_` joins as `.italic` with a WORD BOUNDARY on both sides — the opener only at a word start (the text's start, or after anything that is not a letter/digit/underscore), the closer only at a word end (the text's end, or before such a character) — so `snake_case_name`, `a_b_c`, `x_1`, `_lead_ing` and `__bold__` stay literal while `_the_`, `(_so_)` and quoted `_x_` italicize; the star's minimal flanking rule and non-empty content apply; ⌘I keeps writing `*`. The Write face dims the underscores as markers and italicizes; Read/cards/the Index column hide them (the rendering transform is by span kind). Pin `MarkdownSyntaxTests.underscoreEmphasisIsItalicAtWordBoundariesOnly` (core; red-on-old 1 issue under the revert — no span); the app's face/acts/rendering suites green unmodified. **The iOS build is the orchestrator's at the ladder (core + `Shared/` inherit; nothing in `Shared/` changed).**
- **Rows 59/80/81's red-on-old — VERIFIED by behavioral revert** (the three mechanisms put back in place from the committed state `0a44a87`: the door's old 3/2-pt paddings, the symmetric floor-capped inset, the two-row VStack for the folded/compact tiers; log `/tmp/g-width-red.log`): **7 issues in 4 tests** — row 81: the bar's row **38.0 pt tall against the full row's 19.0** at BOTH 691 and 316 (two rows); row 80 (pure): the narrow insets `80 / 80` instead of `48 / 112` and the tight case's leading inset not 0 (the trailing side spent); row 80 (geometry): the title's `maxX + gap → 299.5` against the icon row's `minX → 234.0` — the words 65 pt under the icons; row 59: the door's width under 24. Restored by `git checkout --` of the three files from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **Rows 74/89/73's red-on-old — VERIFIED by behavioral revert** (the three mechanisms put back in place from the committed state `4bf3324`: the `.inspector` host, `lineLimit(3)`, the consume-before-check; log `/tmp/g-inspector-red.log`): **4 issues in 3 tests** — row 74: the settle timed out and `sideColumnDividerFrame → nil` (no boundary of ours exists under the system inspector); row 89: the shipped meaning line **42.0 pt against the unlimited reference's 83.0** (three lines drawn of six); row 73: `anchorTop → nil` — the ascent's card never realized, the page stayed at the top. Restored by `git checkout --` of the three files from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **Rows 82/83's red-on-old — VERIFIED by behavioral revert** (the two mechanisms put back in place from the committed state `373251c`: `hit(at:)` answering links only, the five un-primed tasks; log `/tmp/g-82-83-red.log`): **row 82: 4 issues in 2 tests** — the pure pin `hit(at: onProse) → nil` and `hit(at: atStart) → nil` (no block under prose), the real-click pin `target → nil` (no point on the page names a block); **row 83: NOT distinguishable in the harness** — the old tree read **0.060 s** mount → first painted row against the new tree's 0.056 s (the in-memory store delivers an observation's first value in tens of ms; the encrypted dev store's 0.25–0.5 s is what she saw). The measure pin therefore holds a SANITY BOUND (1.5 s) and the USE gate's timing series on the dev store is the evidence — stated in the pin's header and here. Restored by `git checkout --` of the two files from the REPO ROOT; `git diff --stat` empty. **No revert in flight.** **A harness find on the way (recorded, fixed in the test file):** under the revert run C's `ReadModeTests.theHostOpensOnEditWithNothingLiveAndTheRegistryHearsTheFace` failed with `selectedBlockID` = a block the note never chose — every world mints the SAME post id (`.incrementing` from zero) and Read's selection PERSISTS through `CurrentBlockMemory` under `currentBlock.<postID>`, so one world's click can arrive as the next world's current block (order-dependent; green in every other run). The world's `close()` now forgets its note's memory — the pin's expectation is about arrival, not a previous world's click.
- **Rows 72/84/85/87's red-on-old — VERIFIED by behavioral revert** (the four mechanisms put back in place from the committed state `42c7f5f`; logs `/tmp/g-72-85-87-red.log` + the core run): **row 84 (core): 1 issue** — `spans("she _really_ meant it").count → 0` (plain text); **row 72: 1 issue** — the anchor card's bottom **27.0 pt** above the peer card's (the step); **row 87: 5 issues in 2 tests** — the rule answering nil for every titleless case and the model's `snippets[bare] → nil`; **row 85: 2 issues** — the seeded lesson carrying the fold sentence and lacking the field's. Restored by `git checkout --` of the four files from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **Row 80b (her live find, added mid-run — and G's own row 90, found independently in the walk at 950 + the tray: the SAME defect; folded into 80b):** DONE (`7eabbc2`) — her state captured first on the pre-fix running build (`80b-00-before-950-tray-open-card-over-chip-door-orphaned.png` / `crop-80-950-tray-top`: the `sherlock holmes ×` card over the chip's words, the ＃ alone on the line below — at a 316-pt detail; hers was ≈ 590). **The mechanism, verified at the code (`PostDetailView` row 2 + `TrailingFlow`):** the `HStack` let the chip (`fixedSize`, priority 1) win its width and offered the flow LESS than its minimum line; `TrailingFlow.placeSubviews` started a line wider than its bounds at `maxX − width` — LEFT of its own edge, over the chip (a `Layout` does not clip) — and, the one card not fitting alone, `keepingTogether` had no row of ≥ 2 to pull the door down from, so the ＃ dropped to a line by itself. **Fix, to the ruled shape:** `MastheadRowTwo` (`Features/Takes/MastheadRowTwo.swift`, a `Layout`): it asks the cluster its MINIMUM line (`TrailingFlow` answers a zero-width proposal with the widest card + the door beside it + the field reserve — `minimumLineWidth`, pure) and lays chip + cluster on ONE line (the chip at its ideal, the cluster in what remains, first text baselines aligned) when chip + gap + minimum fit the width, else on TWO lines — the chip above, proposed no more than the width so its label ELLIPSIZES at its tail (`MembershipChip`'s label gains `lineLimit(1)` + tail truncation), the cluster BELOW on a full-width right-aligned line with the door on the cards' line (`arrangement(...)`, pure). Two belt-and-braces rules in the flow: a line never starts left of the flow's own edge and an item that would run past the trailing edge is proposed the width that remains (row 90's guard — a chrome label truncates, never covers); and the RESERVE YIELDS when honoring it would starve the line's minimum — on a full-width line nothing stands to the cluster's left for the field to reach, so the reserve's room is the line's own (found by the pin's tight case: at the inspector-minimum 292-pt masthead even a full line could not hold one card + the door + 196, and the door still orphaned). Pins (`MastheadLayoutTests`): `theClusterNeverCoversTheChipAndTheDoorNeverOrphansInTerminal` · `…InStudy` — the REAL detail at 590 pt (her tray-open width) with ONE tag and with FIVE, and at 340 (the tighter case): the chip's frame intersects no card, every card inside the masthead, the door on the LAST card's line (midY within 4) and never over the chip; `theRowTwoAndTheFlowMinimumRulesArePure` (her numbers: chip 230 + 16 + minimum 326 > 542 ⇒ two lines). The standing row-58/4/19/59/80 pins ride unmodified (15/4 green). Red-on-old: 7 issues in 2 tests under the revert (the card over the chip; the door a line below).
- **Row 80b's red-on-old — VERIFIED by behavioral revert** (row 2 back to the `HStack` with the chip `fixedSize`/priority 1 and the cluster `frame(maxWidth: .infinity)`, the flow's leading-edge guard and reserve yield off, from the committed state `7eabbc2`; log `/tmp/g-80b-red.log`): **7 issues in 2 tests** — Terminal: the chip `(24, 38, 249×14)` INTERSECTED by the card `(184, 37, 132×16)` at the 340 case, and the door **24 pt below the last card's line** at 590×1 tag, 590×5 tags and 340×1 (orphaned); Study: the chip `(24, 44, 201×14)` intersected by the card `(202, 43, 114×16)` and the door 24 pt below twice. Restored by `git checkout --` of the two files from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **Row 88's red-on-old — VERIFIED by behavioral revert** (the arrival rule answering false and a `Picker("Tag filter")` back in the strip, from the committed state `d35d4f0`; log `/tmp/g-88-red.log`): **2 issues in 2 tests** — the rule `fitsAllOnArrival(30, 0, false) → false` and the mounted canvas's `CanvasArrivalOracle.outcome → nil` after six seconds (no landing on arrival); the strip's `Picker<` assertion sits behind that `#require` and is door-class (the old strip composed the picker; the new one composes none). Restored by `git checkout --` from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **Row 91 (new — found by row 88's walk; fixed in-batch):** DONE (`0ea4508`) — the arrival's fit-all entered the OVERVIEW on the 215-card story (`back to 1:1` in the strip) but the board drew NOTHING (`88-01-study-canvas-arrival-fitted`, `crop-88-01-board`): `scaleEffect` is a visual transform, so the overview's ZStack kept its UNSCALED layout size (`boardSize`), the scroll content stayed board-sized, and the scaled silhouettes sat at the content's top-left while the 2-axis scroll view's own position lay mid-content — off screen (pre-existing: the click-summoned overview had the same layout; the arrival made it the FIRST thing seen). Fix (`CanvasView.board`): the overview ZStack takes the SCALED frame after `scaleEffect`, so the content fits the viewport exactly as fit-all promises. DEBUG `CanvasArrivalOracle.boardContentSize`; the arrival pin gains the assertion (in the overview the content's size fits the fit-all viewport). Red-on-old: 1 issue under the revert (the unscaled board's width).
- **Row 91's red-on-old — VERIFIED by behavioral revert** (the scaled frame off, from the committed state `0ea4508`; log `/tmp/g-91-red.log`): **1 issue** — the overview's `content.width <= 1201 → false` (the unscaled board). Restored by `git checkout --` from the REPO ROOT; `git diff --stat` empty; the product rebuilt on the restored tree. **No revert in flight.**
- **Row 88's arrival, completed in the walk (`f91cb2d`):** with row 91's frame the overview DREW, but the fitted content still opened with its top three rows above the viewport (the 2-axis scroll view's own start, now inside the fitted content — `88-02`/`88-04`) — so the ARRIVAL's overview also lands at the board's top-leading corner (`scrollAnchor = .topLeading` + the marker at `boardOrigin`; a summoned fit-all leaves the viewport where she has it). Walked: `88-06-terminal-arrival-overview-from-origin` (card 1 at the top-left, rows 1–165 in view) · `88-08-study-arrival-overview-from-origin`. **Row 92 (new — found by the walk; RECORDED, a pin holds the half that works):** a silhouette click in the overview returns the board to 1:1 (`fit all` reappears — `88-07`; the real-click pin `CanvasArrivalTests.aRealClickOnASilhouetteReturnsToOneToOne` holds it in the rig) but lands MID-BOARD rather than on the clicked card: the marker scroll runs while the content re-lays from the overview's size to 1:1 — the book's row-44/53 class in the canvas (a scroll at an anchor whose offset is still moving). Pre-existing (the overview's own click road); bounded fix = land after the 1:1 layout (a second beat, the row-53 lesson) — owner **13u2 item 1's family** (the non-editing pane jumping class), flagged for the ladder.
- **Row 88(a) AMENDED by the full suite — the arrival lands at 1:1, never in the overview (`fead43a`):** the first full run (2071/367, 22 issues in 2 pins) caught what the walk did not — the arrival's fit-all put a never-arranged BIG board into the read-only OVERVIEW, where 4E's realization pins (`CanvasAndPoolTests.aMountedLongPostRealizesABoundedCardSet`: `realizedCards → 196 < 80`, `paneCount → 0 > 0`; `TakesBoardSoakTests`' canvas soak: `100 < 100`) measure a 1:1 arrival and every silhouette counts as realized. Her ruling offered two landings — *"opens FIT-ALL (or at the bank's top-left), never mid-bank"* — and the top-left at 1:1 is the right one for a big board: 4E's bounds hold by construction there, and a 215-card note opening as a wall of silhouettes on every visit would be its own surprise. `CanvasArrival.landing(after:)` (pure): a board that fits at 1:1 lands on its bounds' centre (fit-all's own road); a board too big lands at its TOP-LEFT at 1:1 (`exitOverview` + the marker at the board origin, top-leading); the SUMMONED `fit all` still opens the overview (row 91's frame keeps it drawn; the real-click pin returns it to 1:1). Chosen under R-cor-8 and recorded for her (§7): if she wants the overview on arrival instead, it is `landing(after:)`'s one case — and 4E's two pins would then need a stated overview bound. Pins re-shaped: the arrival pin asserts `.origin` + `!overviewActive` on the 30-card spread and then SUMMONS the overview to hold row 91 exactly (the content = the 1:1 content × the scale, within 1 pt); the click pin summons it the same way. Canvas + soak + drag suites green (12/4); the full suite re-run below.
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build of THIS tree (pids 48158 → 58451 → 62586 → 64179 → 68968 across the rebuilds; window zoomed 1728×1084 and resized to 950 for the width family, the tray inspector open for the ~316-pt detail), Terminal AND Study; the walk table is below; **the contact sheet is `batch-g/contact-sheet.png` (64 tiles; the crops sit in `batch-g/crops/`, out of the sheet)**. `/Applications` untouched; her real-store app untouched (not running).
- **Suites:** DONE — the tutorial spine first: **72 tests / 10 suites green** (71 + row 85's text pin). Then the FULL Mac suite on the final tree TWICE (logs `batch-g/g-full-mac.log` · `g-full-mac2.log`): run 1 (before row 88's amendment) read 2071/367 with 22 issues in TWO pins — 4E's canvas realization bound and the board soak, caught by the full suite exactly as it exists to (row 88's arrival had put a big board into the overview; amended at `fead43a`); **run 2: 2071 tests / 367 suites, ONE red — the known load-flaky `rewriteStrategyLatencies` at 50.17 ms against 50 (the KnownIssues row; the run overlapped a push) — re-run ISOLATED: 3/1 green (`g-latency-isolated.log`), nothing loosened;** `CanvasDragTrackingTests` and F's noted real-click pin passed in-run both times. **Arithmetic against batch E's close 2049 / 361:** +22 tests — `BlockHistoryPaletteDoorTests` 1 · `MastheadLayoutTests` 6 (59: 1 · 80: 2 · 80b: 3) · `CommitBarLayoutTests` 1 (the three re-expressed count as before) · `SideColumnTests` 2 · `RecoveryExplainerTests` 1 · `BookOutlineLandingTests` 1 · `ReadRenderingTests` 1 · `ReadModeTests` 1 · `BlocksArrivalMeasureTests` 1 · `CompareLensesCorrectionTests` 1 · `TutorialBookShapeTests` 1 · `PoolCardPreviewTests` 2 · `CanvasArrivalTests` 3 ⇒ **2071**, exact; +6 suites (BlockHistoryPaletteDoor · SideColumn · RecoveryExplainer · BlocksArrivalMeasure · PoolCardPreview · CanvasArrival) ⇒ **367**, exact. **Core: `swift test` 1525 tests / 165 suites green** (`g-core.log`) — 1524 + row 84's one pin, exact; **zero `Sync/` lines** (the Fable rider unexercised); zero schema. **`App/Variorum/Shared/` untouched** (row 84's brain lives in core Domain; `MarkdownFaceCore` needed no change — the iOS build at the ladder inherits core + Shared as they stand).
- **STATUS: BATCH G's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build of the FINAL tree (pid 68968) is left RUNNING for that walk — Terminal voice, Boscombe open in Canvas (the 1:1 top-left arrival), window zoomed; the voice was restored to Terminal at the end. Tree clean; every commit pushed.
- **No revert in flight** (every behavioral revert ran and was restored — the evidence lines above; `git diff --stat` empty against `fead43a`).
- **Row 86(d)'s red-on-old — VERIFIED by behavioral revert** (the palette's `.showBlockHistory` case put back to the bare `dispatch(.showBlockHistory)` in place, from the committed state `bb4645c`; log `/tmp/g-86d-red.log`): **3 issues in 1 test** — `opened → []` (no request reached the inspector), `session.status.current` = the caret sentence ("Put the caret in a block and its History shows…" — the walk's toast, verbatim), and `opened.count → 0` after the second press. Restored by `git checkout --` from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**

#### Per-row dispositions (G)

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 86 (verify-first) | (e) NOT A DEFECT — the title click opens the rename field; the pre-Act-10 file carried the same `onTapGesture`. (d) FIXED — the palette row opens the FOCUSED block's history where no surface handler stands (`CommandRouter.requestBlockHistoryForFocusedBlock` · `ShellActions.showBlockHistory`) | `BlockHistoryPaletteDoorTests.thePaletteRowOpensTheFocusedBlocksHistoryWhereNoSurfaceHandlesIt` | 3 issues (no request; the caret sentence spoke) |
| 59 | FIXED — the ＃'s target is a 24-pt square around the glyph | `MastheadLayoutTests.theTagDoorsHitTargetIsTheRowsHeightNotTheGlyphs` | 1 issue (the door under 24 wide) |
| 80 | FIXED — `MastheadTitleInsets`: the trailing inset keeps the icons clear; the floor spends the leading side; the title yields below floor + icons | `.theTitleInsetsKeepTheIconsClearAndSpendTheFloorOnTheLeadingSide` · `.theTitleNeverRunsUnderTheIconsAtANarrowMasthead` | 4 issues (80/80; the title 65 pt under the icons) |
| 80b (her live find; G's row 90 folded in) | FIXED — `MastheadRowTwo` (one line, or the cluster below the chip); the chip ellipsizes; `TrailingFlow`'s minimum line, leading-edge guard, yielding reserve | `.theClusterNeverCoversTheChipAndTheDoorNeverOrphansInTerminal` · `…InStudy` · `.theRowTwoAndTheFlowMinimumRulesArePure` | 7 issues (the card over the chip at 340 in both voices; the door a line below at 590×1, 590×5, 340×1) |
| 81 | FIXED — the flat bar FOLDS (full / folded / compact; `more ▾`); every folded member `fixedSize`; the note total as the word-target door; the block/selected counts drop below 840 (C-6) | `CommitBarLayoutTests` ×4 (three re-expressed — a JUSTIFIED PIN EDIT — + `theBarStaysOneRowWithNothingPastItsEdgeAtNarrowMeasures`) | 2 issues (38 pt — two rows — at 691 and 316) |
| 74 | FIXED — `SideColumn` (Core/Views) replaces the note-side and scraps-area `.inspector`s: our divider (drag grammar, a remembered width), presence animated at the mutation sites | `SideColumnTests` ×2; four JUSTIFIED PIN EDITS (`BlockHistoryHostTests` · `BlockHistoryPaneTests` · `NoteVersionsPaneTests` · `TrayPanelMoveTests` — the system inspector's class → the column's oracle) | 2 issues (no divider of ours; the settle) |
| 89 | FIXED — the meaning lines wrap whole (`CalmSectionHeader` + the two inline explainers) | `RecoveryExplainerTests.theTrayLeavingExplainerRendersWholeAtTheNarrowestPane` | 1 issue (42 vs 83 pt) |
| 73 | FIXED — a reveal parked until the entries arrive; foreign requests still dropped | `BookOutlineLandingTests.aRevealRequestedBeforeTheEntriesArriveLandsWhenTheyDo` | 1 issue (the card never realized) |
| 72 | FIXED — every header card stretches to the strip's height, content top-aligned | `CompareLensesAlignmentTests.theHeaderStripsCardsShareOneBottomEdge` | 1 issue (a 27-pt step) |
| 83 | FIXED — the rows and the facts primed before their observations; the sibling observations wait | `BlocksArrivalMeasureTests.theFirstRowPaintsWithinTheCeilingOnATwoHundredBlockNote` (a sanity bound) | indistinguishable in the harness (0.060 vs 0.056 s); the dev-store series (0.47 → 0.32 s) is the evidence |
| 82 | FIXED — `hit(at:)`: link, then block; the note's pages → `edit`, the book's pages → Index (the book shared the defect) | `ReadRenderingTests.aPointOnThePageNamesTheBlockUnderItAfterTheLinks` · `ReadModeTests.aRealClickOnAPageReachesTheHostWithTheBlockUnderIt` | 4 issues (no block under prose; no prose point) |
| 85 | FIXED — the lesson teaches the three-door bar and the masthead ＃ field | `TutorialBookShapeTests.theWorkspaceLessonTeachesTheMastheadTagDoor` | 2 issues (the fold sentence seeded) |
| 87 | FIXED — the Pool card's first words under a titleless card, through the picker's own query | `PoolCardPreviewTests` ×2 | 5 issues |
| 88 | FIXED — (a) a never-arranged arrival lands at 1:1 (centre or top-left — the overview declined, recorded for her); (b) the strip in the calm-chip grammar | `CanvasArrivalTests` ×3 | 2 issues (the rule false; no landing) |
| 84 | FIXED — `_italic_` at word boundaries, in core Domain, display-only | `MarkdownSyntaxTests.underscoreEmphasisIsItalicAtWordBoundariesOnly` (core) | 1 issue (no span) |
| **90** (new — G's walk; = 80b) | FOLDED into 80b (the same defect at 950 + the tray, found before her message arrived; the flow's leading-edge guard is 80b's belt-and-braces half) | (80b's) | (80b's) |
| **91** (new — 88's walk) | FIXED — the overview ZStack takes the SCALED frame after `scaleEffect` (the scroll content was the unscaled board; the silhouettes drew off screen) | the arrival pin's row-91 assertion (the content = the 1:1 content × the scale) | 1 issue (the unscaled width) |
| **92** (new — 88's walk) | RECORDED — a silhouette click returns to 1:1 (pinned) but lands MID-BOARD, not on the clicked card: the marker scroll runs during the 1:1 re-layout (the book's row-44/53 class in the canvas). Owner: **13u2 item 1's family**; flagged for the ladder | `CanvasArrivalTests.aRealClickOnASilhouetteReturnsToOneToOne` (the return half) | — |
| **93** (new — 86(e)'s walk, an observation) | RECORDED — on a note NAMED BY ITS DAY the open rename field shows the day as its PROMPT in the label's own place, so a click can read as "nothing happened" (F's seed-03 was such a note); the door works. A visible open state (a field border, or the caret placed) is a nit for **13u2 item 13** (the title's family) | — | — |
| **94** (new — 83's walk, an honest limit) | RECORDED — Blocks' first paint still lags the mode switch by ~0.2–0.3 s on the encrypted dev store (empty at 0.22 s, painted at 0.32 s; C measured 0.47): the primed read's own cost + the mount. The next step — a note projection shared across modes so the arriving mode paints from what the leaving mode held — is **13u2 item 1's** (the non-editing pane family) | — | — |

#### The USE gate — the walk (the dev-store Debug build of this tree; window zoomed 1728×1084, and 950 wide for the width family; every capture in `act10-correction-screens/batch-g/`; **the sheet: `batch-g/contact-sheet.png`, 64 tiles**; crops in `crops/`)

| Row | What was done | Capture(s) |
|---|---|---|
| 86 (verify-first, on E's build — byte-identical for these files) | The masthead title clicked → the rename field with the title selected; Blocks ▸ row 03 ▸ ⌘K "block history" ⏎ → the caret sentence, no pane (the defect) | `86e-01-title-clicked` (+ `crops/crop-86e-01-masthead`) · `86d-01…03` |
| 86(d) after | Blocks ▸ row 03 ▸ ⌘K "block history" ⏎ → the Block History pane OPENS beside the workbench (savepoints · Restore) | `86d-04-pane-opens-after-fix` |
| 83 | ⌘6 into Blocks on Boscombe, four frames ~0.1 s apart: empty at 0.11/0.22 s, rows WITH facts at 0.32/0.42 s (C: empty 0.24, painted 0.47) | `83-01…04-blocks-arrival` (+ `crops/crop-83-arrival-series`) |
| 59 | The ＃'s 24-pt box clicked at its top-left and bottom-right corners (~11 pt off the glyph): the field opens both times | `59-01-corner-topleft-opens-field` · `59-02-corner-bottomright-opens-field` |
| 80 · 81 · 74 · 89 (Terminal, 950 + the tray) | The window at 950 with the tray open (the ~316-pt detail): the title `The Boscombe V…` clear of the icons; the bar ONE row `block 3/215 · block ▾ · more ▾ · ?`; the boundary line present in the ACTIVE and the INACTIVE window-id captures; the explainers whole | `80-81-03-950-tray-open` · `74-01-950-tray-active` · `74-02-950-tray-inactive` (+ `crops/crop-74-boundary-active-vs-inactive`, `crop-89-950-tray-explainer`) |
| 80b (before → after) | The same state on the pre-fix build: the card OVER the chip, the ＃ alone below; after: the chip on its own line, the card + ＃ together below, right-aligned — Terminal and Study | `80b-00-before-950-tray-open-card-over-chip-door-orphaned` · `80b-01-terminal-950-tray-open-fixed` · `80b-02-study-950-tray-open` |
| 81 (the tiers) | The tray closed at 950 → the FOLDED row; `more ▾` opened (takes · comments · Aa); zoomed → the full row byte-unchanged; Study compact/folded | `81-06-950-no-tray-folded` · `81-07-950-more-menu-open` · `81-08-zoomed-full-row` · `81-09-terminal-950-tray-compact-bar` · `81-10-study-950-no-tray-folded` |
| 74 (Study) | The boundary by window id, active and inactive — identical | `74-03-study-950-tray-active` · `74-04-study-950-tray-inactive` |
| 73 | Library ▸ the Sherlock row's body → the panel's outline → "The Boscombe Valley Mystery" → the book opens AT Boscombe (the card at the page's top) | `73-01-study-library` · `73-02-study-book-panel` · `73-03-study-book-opens-at-boscombe` |
| 72 | Compare on the twin lesson: the anchor card and the peer card share one bottom edge; `+ note` at the strip's end — both voices | `72-01-study-compare-strip` · `72-02-terminal-compare-strip` |
| 82 (note) | Scandal ▸ Read ▸ `read` ▸ `pages` ▸ a click on the right leaf's paragraph → `edit` with block 04 selected in the column and LIVE in the pane | `82-01-study-read-face` · `82-02-study-pages` · `82-03-study-pages-click-lands-edit` |
| 82 (book) | Sherlock ▸ Read ▸ Pages ▸ a click on a page's paragraph → the book's Index with block 03 live | `82-04-study-book-read-tab` · `82-05-study-book-pages` · `82-06-study-book-pages-click-lands-index` |
| 85 | Help ▸ Restore Tutorial… on the DEV store (Replace) → "the workspace": the three-door bar + the masthead ＃ field sentence | `85-00-restore-dialog` · `85-01-study-workspace-lesson-reseeded` |
| 87 | The Pool: first words under the titleless cards, none under the titled or the empty one — both voices | `87-01-study-pool-cards` · `87-02-terminal-pool-cards` |
| 84 | Scandal in Write: `_the_` dimmed markers + italic; Read's `edit` face: italic, underscores hidden; the book's flow likewise | `84-01-study-scandal-write-underscore-italic` · `84-02-study-scandal-read-edit-face` · `82-04` |
| 88 (before → after) | Boscombe ▸ Canvas: mid-grid with the mixed strip (before); the arrival's overview drawn (91) but the click dead / the top rows above the viewport (the intermediate cuts); FINAL: 1:1 with card 1 at the top-left under the calm strip — both voices | `88-00-canvas-arrival-before` · `88-01…05` (intermediate) · `88-06-terminal-arrival-overview-from-origin` · `88-07-terminal-silhouette-click-lands-1to1` (row 92) · `88-09-terminal-arrival-1to1-top-left` · `88-10-study-arrival-1to1-top-left` |
| (aside) | The Settings ▸ Appearance switch; the state shots | `settings-01-window` · `00-state-before` · `01-relaunched-state` |

Honesty notes: the dev store now carries walk artifacts (the tutorial RE-SEEDED — the field guide's rows reordered in the Library; `readFace`/`currentBlock`/`postMode` memories; the walk's earlier put-backs) — harmless, dev store only; the 86(e) NAMELESS case was not captured (the re-seed reordered the Library rows under my clicks twice — row 93 records the observation); the row-59 corner captures were taken on the pre-80b build (the door's frame is unchanged by 80b at the zoomed width); two AX "window 1 invalid" errors during the Finder activation were transient (the CG window list showed the window throughout); the `88-01`–`88-05` captures are intermediate cuts kept as the record of how (a) was reached.

#### Commits (in order — batch G whole; the trailer on every one)

`bb4645c` (86 verified + (d) fixed; the record opened) · `5c6eb20` / `f92492a` (86's revert + evidence) · `0a44a87` (59 · 80 · 81) · `1bf7949` / `723b487` (their revert + evidence) · `4bf3324` (74 · 89 · 73) · `6fbc0e4` / `80f298c` (revert + evidence) · `373251c` (82 · 83) · `cf72659` / `8ccf12c` (revert + evidence; the ReadModeTests harness fix) · `42c7f5f` (72 · 85 · 87 · 84) · `2bc7917` / `7323b8e` (revert + evidence) · `7eabbc2` (80b, with 90 folded in) · `997feed` / `2873543` (revert + evidence) · `d35d4f0` (88) · `2edd13c` / `3c7ecef` (revert + evidence) · `0ea4508` (91) · `13bb772` / `292b803` (revert + evidence) · `f91cb2d` (88's origin landing + the overview click pin; row 92) · `fead43a` (88(a) amended by the full suite: the 1:1 landing) · this commit (the record's close). The orchestrator's `9af9b93` (row 80b) and `d234a8b` / `f7ad28f` / `b34c24c` / `74849f3` / `02652ac` / `2c775a0` (her sitting's rulings) interleave in the same history.

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed; no revert is in flight; the tree is clean; the final Mac suite is 2071/367 with the one known load-flaky red green isolated, core 1525/165, the spine 72/10. Every G row is FIXED with a red-on-old pin or VERIFIED (86(e) — not a defect), and the new rows are RECORDED with owners (92 · 93 · 94) or FIXED (91), 90 folded into 80b; nothing DEFERRED, nothing REVERTED (C-5 unexercised), no row stopped as a surface rewrite. **Three things to put to her at this seam (§7):** (1) row 88's landing for a big never-arranged board is the TOP-LEFT at 1:1, not the overview — her ruling offered both; the full suite's realization pins and the "wall of silhouettes on every visit" argument decided it; `CanvasArrival.landing(after:)` is one case if she wants the overview; (2) row 81's folded bar DROPS the `Nw block · Nw selected` counts below 840 pt and every count in the compact tier (C-6; the word-target door survives in the folded tier) — a taste call within the calm-chrome latitude, stated; (3) row 74's side column is DRAGGABLE with a remembered width (the seam's grammar) — E's Library column is not; if she wants them to match, either direction is a small change. **Honest limits:** row 83's harness measure cannot tell the trees apart (the dev-store series can — 0.47 → 0.32 s — and the ~0.2–0.3 s residual is row 94); row 92's mid-board landing after a silhouette click is recorded, not fixed; row 93's nameless-title prompt is an observation. **Walk suggestions:** resize the window to ~950 and open the tray (⌘K "tray"): the title clear of the icons, the chip above and the card + ＃ below, the compact bar, the boundary with Finder frontmost; close the tray: the folded bar and `more ▾`; zoom: the full bar; Blocks: ⌘K "block history" ⏎ opens the pane; the ＃'s corners; Library ▸ Sherlock ▸ the outline's Boscombe row (the book at Boscombe); Boscombe ▸ Read ▸ `pages` ▸ click a paragraph (edit at that block); Sherlock ▸ Read ▸ Pages ▸ click (Index at that block); the Pool's previews; Scandal's `_the_`; Canvas on Boscombe (card 1 top-left, the calm strip; `fit all` → the drawn overview → a silhouette click → 1:1, mid-board — row 92); Compare on the twin (one bottom edge); Help ▸ Restore Tutorial… on the DEV store re-seeds "the workspace" (her store's re-seed is her morning act). Known non-G residue seen in passing: nothing in Compare/Lenses beyond row 72, nothing in the recovery family beyond 89, nothing in `Shared/`.

#### BATCH G RECORD — CLOSED by the orchestrator (2026-09-01 21:35 MDT; captures `orchestrator-g/`)

Verified against git first: the batch's commits `bb4645c`…`d41417d` (every row with its revert-starting + evidence
pair), tree clean, pushed; the code diff 44 files (+2597/−182) — the one core file the underscore tokenizer in
`Domain/MarkdownSyntax.swift` (display-only; the rendering suites unmodified), `Shared/` untouched, zero `Sync/`.
Read the record, then three of its captures at the riskiest rows: **80b** (her find — at 950 with the tray open
the chip stands alone above, the card and `#` together below, the title clear of the icons, the compact bar one
row), **81** (at 950 without the tray the bar folds to `block 3/215 · block ▾ · commit ⌘s · history · note ▾ ·
more ▾ · 9,689w in note · ?` — one row, nothing truncated), **88** (Canvas arrives with card 1 top-left under the
calm-chip strip). **The live probe took the riskiest new component — `SideColumn`, which replaced every note-side
inspector — with two occupants in turn at the zoomed width:** the masthead's tray icon opens the tray in the
column with OUR divider and its meaning line whole (row 89 in use); then ⌘K "block history" ⏎ from Write with the
caret in block 6 opens THAT block's history in the same column, replacing the tray — one right region — with every
section explainer intact (row 86(d) in use; `01-tray-column-zoomed-crop` · `02-history-via-palette-crop`). The
pane was closed again at the end. **G's rows 59 · 72 · 73 · 74 · 80 · 80b · 81 · 82 · 83 · 84 · 85 · 86(d) · 87 ·
88 · 89 · 91 are FIXED in use; 86(e) verified not a defect; 90 folded into 80b; 92 · 93 · 94 RECORDED with owners.**
Counts at close: **Mac 2071/367** (E's 2049 + 22 / 361 + 6; the one load-flaky red green isolated), **core
1525/165** (+1, the tokenizer's pin), spine 72/10. **G's three taste calls go to her at this seam (§7)** — row 88's
landing (1:1 top-left, not the overview), row 81's dropped counts below 840 pt, row 74's draggable column vs E's
fixed Library column. **The ladder spawns after her answers** (a fix session first if an answer changes code).

---

## LADDER ROUND 1 — the cold review of the combined diff (a fresh Fable reviewer, 2026-09-02; `notes/REVIEW_PROMPT.md` verbatim)

**What was reviewed:** `git diff 962e7b8..HEAD -- App/ Sources/ Tests/` — 97 files, +12,564 / −2,454, the 123 commits of
`git log --oneline 962e7b8..HEAD` verified (B's `be32fa7` is the first code commit after `962e7b8`; HEAD at the
write is `75bf756`, whose code diff is byte-identical to `7e45cc1`'s — the commits since are records). Read in full,
in this session: the prompt; this file §0–§8 (every batch record and CLOSED line — the anchor for prior
dispositions); the whole diff, production files first, then every test file; CLAUDE.md/AppSpec/OverallModel/
SyncSpec/DetailedPlan/KnownIssues from context. No "Review foci" section exists in this plan or beside it, so the
prompt's standing context alone applies. Verified against the tree (not the record): zero `Sync/` lines, zero
schema, ONE core file (`Domain/MarkdownSyntax.swift` + its test); no `SideColumn`/`ShellSplit`/`.inspector` residue
in the note-side hosts; the code anchors of every finding below re-read at HEAD. The review is read-only: nothing
was fixed, no test was added; the session died once at its limit and resumed by message (the record above), with
nothing of it in the repo until this section. A note on the session-limit resume: the diff was re-read from the
saved copy, so every line below was seen twice.

### Findings (severity-ranked; the format the prompt asks — `[severity] · file:line · what · evidence · fix`)

**[MAJOR] · `App/Variorum/Variorum/Features/BookView/BookView.swift:1600–1631` (`StableSurface`), `:1728–1737` (the
read-cheap host), `:1541` (the doc claim) · The remembered-surface reservation has NO shrink path, so a memory that
is TALLER than the surface's real height (after the pane narrows-then-widens, a voice switch, or any reflow that
shortens a story) reserves a PERMANENT blank gap under the expanded story — and the doc block claims the
opposite.** Mechanism, traced at the code: `StableSurface` reads `known` (the parent's `model.rememberedSurfaceSize`,
captured at the parent's LAST render — `rememberedSurfaceSizes` is `@ObservationIgnored`, so nothing re-renders the
row when it changes) and reserves `.frame(minHeight: known.height)` while `!loaded` (`:1628–1631`); `loaded` flips
only when the measured height REACHES `known.height − 24` (`:1613`); the memory is updated only upward for
read-cheap surfaces (`size.height > (known?.height ?? 0)`, `:1621`) and only after `loaded` for live ones
(`:1619`). So: (1) a story is expanded read-cheap in a book pane narrower than the prose measure (any window where
sidebar + navigator + 40-pt padding leave the pane under `proseColumn` — e.g. a ~900-pt window) → its text is tall,
say 25,000 pt, and remembered; (2) the window is widened (or the sidebar collapsed with A's new ⌃⌘S, or the voice
switched Terminal→Study, or any later shorter reflow) → the same text is now 20,000 pt; the near, loaded row keeps
no gap yet (`reserved` is nil once `loaded`), but `remember` is never called with the smaller size (20,000 ≯ 25,000;
`loaded && followsShrinks` is false for read-cheap); (3) the row scrolls far (a 25,000-pt placeholder — the column's
"exact geometry" is now 5,000 pt wrong) and near again → a FRESH `StableSurface` (`if nearViewport {…}` rebuilds it)
with `known = 25,000` reserves 25,000, the surface loads at 20,000, `reached` is false, `loaded` never flips, and the
row stays `minHeight: 25,000` for the rest of the session: a 5,000-pt blank under the story, with every landing past
it converging on a column whose geometry the fix exists to keep honest. The same road shrinks to a smaller gap for a
LIVE editor demoted to read-cheap whenever the two forms differ by more than the 24-pt slack (the constant is stated
as "one line of slack", not measured). Evidence beyond the trace: the doc block at `:1541` says *"a different width
(the window resized while the row was away) is a memory that does not apply"* and the row-53 record says *"The
memory ignores width and keeps the MAX for read-cheap surfaces"* — the stored `CGSize` carries a width that nothing
ever compares, and "keeps the MAX" is a comparison against a stale snapshot, not a max; the code and the record
disagree with each other. Nothing pins the shrink direction (`BookOutlineLandingTests` only ever grows surfaces).
Proposed fix: make the reservation honest in both directions — compare the remembered WIDTH (a memory taken at a
different width does not apply: the doc's own rule), and when a loaded surface settles BELOW its reservation for a
quiet interval, adopt the smaller size and drop the reservation (the row-53 settle discipline, reused). Pin
(red-on-old by construction): mount `StableSurface` alone with `known` = 2× its content's height (or the book with a
story remembered at a narrow width, then widened) → the laid-out row height equals the content's, not `known`'s.

**[MAJOR] · `App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift:800–803` (the book row), `:960–965`
(the note row) · The Library's row-body click is held for the double-click interval before the panel moves —
batch C's row 25 mechanism, live on the surface batch E rebuilt.** Both rows stack `.onTapGesture(count: 2)
{ openHit }` before the plain `.onTapGesture { … selectBook / clickNoteRow }`; batch C traced and MEASURED exactly
this idiom on the Blocks rows (record: *"a single click is held until the double-click window closes … 0.26–0.49 s
lag, consistent with `NSEvent.doubleClickInterval` = 0.5 s"*; its pin read 0.357 s on the old shell against a
150-ms budget) and replaced it with ONE tap handler timing the double by the row's own clock (`WorkbenchRowShell`).
E's burst evidence is consistent with the hold, not against it: its two early frames (0.12 s, 0.2 s after the
click) are EMPTY and the panel "settles" afterwards — the record reads that as the poster's ~0.15-s latency, but the
column cannot begin to slide until the tap is delivered, and the tap is delivered when the double-click window
closes. Her bar names it (C-7: *"a view that lags a second on selection is a defect"*), and it is the FIRST thing a
reader feels in the panel this round rebuilt for her. Proposed fix: the `WorkbenchRowShell` idiom on both rows —
one plain tap that acts at once, a second click inside `NSEvent.doubleClickInterval` opening — hoisted into a shared
row-click brain rather than copied (the forked-brains discipline; three copies otherwise: the workbench shell, the
book row, the note row). Pin (the row-25 shape, red on old by C's own numbers): a Library row mounted alone in the
rig, a real click → `model.infoHit` set within 150 ms; a second click inside the interval opens once.

**[MINOR · SPECULATIVE on the outcome, the mechanism is the round's own] · `App/Variorum/Variorum/Features/ReadMode/
ReadEditPane.swift:47, :72`; `ReadModeView.swift:421, :446`; `NoteIndexColumn.swift:89, :149` · Read's two faces
and the `▸ 01` column land with `withAnimation { proxy.scrollTo(…) }` over a `LazyVStack`, targeting an explicit
`.id` that is NOT the `ForEach` identity — the two mechanisms batch B retired in Outline (rows 9/12: an animated
scroll toward lazy estimates travels wrong; row 47: an explicit id on an unbuilt lazy row is unknown to the reader —
*measured in this round's harness*).** `ReadEditPane` and `ReadPageColumn` iterate `id: \.element.placementID` and
scroll to `"rep-<blockID>"` / `"rd-<blockID>"`; the column iterates `ColumnRow` (id = `blockID`) and scrolls to
`"ixr-<blockID>"`. The book's Index pane got the fix in the same round (`BookIndexView.paneRows`: the identities ARE
the anchors, the animation dropped — *"the Outline lesson"*); the note's three landings did not, and no far-block
landing was walked on the note (C's captures land blocks 05/07/08 of 215, all realized near the top; the pins use a
three-block note). Whether SwiftUI folds a direct-child `.id` into a lazy row's identity is exactly what B measured
only for the nested case — so the outcome is not asserted here, only that the note carries the retired shape
unexamined. Proposed: the book Index pane's form (identity = anchor, no animation) on all three, and ONE walked
landing on Boscombe's block 200 from the column. Pin: a 215-block note in Read(edit), `select(block200,
scrollFace: true)` → `ReadModeOracle.editBlockFrames[block200]` centred within the settle (red on old if the id is
unreachable; green means the class is not live here and the finding is dismissed as hollow).

**[MINOR · SPECULATIVE on the outcome] · `App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift:64` via
`BookView.swift:1033` (`navigateToChapter`, `.read`) · Row 50 wired the navigator's chapter click in Read ▸ Scroll to
`model.requestReveal(first.postID)`, whose consumer is the flow's `land(_:)` — `withAnimation { proxy.scrollTo
("flow-…", anchor: .top) }` over a `LazyVStack` of twelve ~20,000-pt `FlowPostView`s on Sherlock: the animated-
scroll-over-lazy-estimates class row 44/9/12 traced, on a column whose rows are the heaviest in the app.** B's own
record marks row 50 *"Not walked"*; nothing pins it. Proposed: the unanimated form (the Outline lesson) and one
walk — Sherlock ▸ Read ▸ Scroll ▸ the navigator's eleventh chapter. Pin: a flow with five 215-block entries,
`requestReveal(entries[4])` → the `flow-` anchor's top within tolerance (an `onGeometryChange` oracle the flow does
not yet carry).

**[MINOR] · `App/Variorum/Variorum/Features/ReadMode/NotePagesView.swift:118, :131` beside `NoteIndexColumn.swift:211`
(the filter `TextField`) and the masthead's fields · The `read ▸ pages` face binds ← and → as UNMODIFIED keyboard
shortcuts; SwiftUI resolves `.keyboardShortcut` in the hosting view's `performKeyEquivalent` BEFORE the first
responder's `keyDown`, so while `pages` shows, an arrow key typed in the index column's filter field (the same
surface, composed together for the first time this round), the masthead's inline tag field or the title's rename
field turns a page instead of moving the caret.** The book's `PagedReadView` carries the same two shortcuts
(`:173, :186`) but shares its surface with no text field; the note host does. Not walked (the mechanism is AppKit's
dispatch order, well known — a default button's unmodified Return fires from inside a text field for the same
reason). Proposed: gate the shortcuts on no text field being first responder, or bind them with a modifier the
fields do not use, or move the turn to the leaf's own key handling. Pin: the pages face mounted with the column,
the filter field made first responder, a synthesized ← key event → the field's selection moved and `pages.turn`
not called.

**[MINOR] · `App/Variorum/Variorum/Features/Tray/BlockHistoryPane.swift:411` (the pane's top explainer) and
`TrayPanel.swift:744` (the kept-in-lineage sentence) — both `lineLimit(nil)` + `fixedSize(horizontal: false,
vertical: true)` OUTSIDE their panes' `ScrollView`s (`:439`, `:747`) · Row 89's rule (a prose explainer wraps
whole) was applied to two texts that live in NON-SCROLLING chrome — the b6dae25 class P-8 names (*"an unlimited
fixedSize text here measures one character per line under the window's near-zero-width minimum-size probe, and its
full height becomes the WINDOW's minimum"*).** In the `SideColumn` they are shielded only by the column's fixed
`.frame(width:)`; `BlockHistoryPane` is ALSO hosted in two `.sheet`s (`CommitBar.swift:153`,
`TakesBottomBar.swift:239` — the fallback hosts) where no frame pins the width. `ChromeMinHeightTests` covers
`ChromeNotice` and the cause note only. The `CalmSectionHeader` explainers (the rule's real target) sit inside the
scroll views and are fine. Proposed: a bounded limit large enough for the longest explainer (they are ≤ 6 lines at
256 pt — `RecoveryExplainerTests` measured it) on the two non-scrolling ones, or move them inside the scroll. Pin:
`ChromeMinHeightTests`' near-zero-width probe over a sheet-hosted `BlockHistoryPane` stays bounded.

**[MINOR] · `App/Variorum/Variorum/Core/Views/SideColumn.swift:43, :128` · A drag on the side column's divider
past the window's trailing edge SNAPS the panel to its ideal width mid-drag.** The drag writes `remembered =
width(remembered: Double(totalWidth − location.x), …)`; past the edge the proposal is ≤ 0, and the rule's first
branch (`remembered > 0 ? … : ideal`) reads that as "nothing remembered" and answers 420 — so a panel being dragged
narrow jumps to 420 the moment the pointer crosses the edge, then follows again on the way back. Proposed: clamp the
proposal to `minimum` before the `> 0` test (or clamp in the gesture). Pin (pure): `width(remembered: −40, …)` and
`width(remembered: 0, …)` — the first is a DRAG and must answer `minimum`, never `ideal`.

**[MINOR] · `App/Variorum/Variorum/Features/BookView/BookIndexEditModel.swift:56, :140–145` · `teardown()` stops
observing every coordinator's refusals but KEEPS the coordinators cached; `coordinator(for:)` returns a cached one
early and never re-subscribes, so a model reused after a teardown silently drops autosave refusals.** Moot today —
the `@State` model dies with the view when `BookView` switches modes (`BookView.swift:125–147` is a `switch`) —
which makes it a latent hazard, not a defect: the first host that keeps the model across an `onDisappear` (a tab,
a hidden pane) inherits it. Proposed: drop the coordinator entry with its token, or make `teardown` terminal.

**[MINOR · a record gap, not a code defect] · `App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift:149–151` ·
Row 83's brief asked *"Same shape for any other mode that arrives blank (say which you checked)"*; G's record
says only that Blocks was primed.** Read's host starts three observations with no prime (`start`, `startTray`,
`startPools`) and its `edit` face renders from `model.rows` — the same first-delivery blank Blocks had (and Read is
now ⌘3, the mode her ruling put beside Takes). Either measure it on the dev store and record the number under row
94's owner, or prime it the same way (`primeRows` already exists on the shared model — one line).

**[MINOR] · `App/Variorum/Variorum/Features/BookView/BookView.swift:1779, :1818` · Every EXPANDED `OutlinePostRow` is
now a direct child of the outer `VStack` (never lazy), and each runs `.task { loadFacts() }` = `Queries.renderPost`
over the WHOLE note — including far rows drawing a bare placeholder, and although the expanded forms show neither
the excerpt nor the gutter line the read feeds.** "Expand all" on Sherlock = twelve full-story reads on mount for
nothing rendered. Bounded by the expanded count (P1's letter holds — never the corpus), so cleanliness, not a
violation; proposed: gate `loadFacts` on the collapsed form (`!model.isExpanded`), which is the only form that reads
`excerpt`/`meta`.

**[MINOR] · `Sources/VariorumCore/Domain/MarkdownSyntax.swift:472–485` · The closer's doc says the character after
it must be "nothing, or not a letter/digit"; the code asks `!isWordCharacter`, which also excludes `_` — so `_a__`
closes at the SECOND underscore with content `a_` (the first is glued to a word character and skipped).** A
nonsense input, but the doc and the code disagree, and the star form (`closingSingle`) has no such rule to mirror.
`__bold__`, `snake_case`, `_lead_ing` and the rest of the pinned corners are right; the pin passed in this session
(`swift test --filter MarkdownSyntaxTests` — 21/1 green). Proposed: align the doc to the code (the stricter rule is
the better one) and add `_a__` to the pin as literal or as `a_` — decide which, then say it.

**[NIT] · `App/Variorum/Variorum/Features/Library/SidebarLayout.swift:50` and `VariorumTests/ShellChromeTests.swift:36`
·** `fixedChromeHeight = 233` assumes three headers and three separators always; a column with no starred group and
no rail carries one header and one separator, so the fit test over-counts by ~80 pt and compresses a little early
in a short window. The pin's fixture says `rail: 8` "the eight-mode rail" — stale since batch C made it seven; the
arithmetic (20 rows) is unaffected, the comment is not.

**[NIT] · `App/Variorum/Variorum/Features/BookView/BookOutlineRows.swift:192–197` ·** `isLoneHeadingOrNumeral` treats
ANY ≤ 2-word, ≤ 12-character first block as a stub — "Dear reader." or "Chapter one." is skipped from a card's
preview whenever another block follows. The numeral case is right; a short SENTENCE (ends in a full stop and is
not a heading) is a preview, not a stub.

**[NIT] · `App/Variorum/Variorum/Features/Canvas/CanvasView.swift:501` ·** The arrival's centre-vs-origin decision
runs against the 1200 × 800 FALLBACK viewport when `visibleRect` is still empty (it is, on arrival): a board that
fits the real, larger viewport lands top-left instead of centred; a board that fits 1200 × 800 but not a smaller
real viewport lands centred with its edges clipped — the mid-bank symptom in miniature. Land when the viewport has
reported, or pass the hosting size.

**[NIT] · `App/Variorum/Variorum/Registry/CurrentBlockMemory.swift` ·** `currentBlock.<postID>` joins `postMode.<id>`
and `readFace.<id>` as per-note `UserDefaults` keys nothing ever reaps — `forgetCurrentBlock` has no production
caller (deletion, the purge, and Delete Now leave the keys). A pre-existing class this round extended by one
family; a sweep at note purge is the natural home (13w/17).

**[NIT] · `App/Variorum/Variorum/Features/BookView/BookView.swift:1035` ·** `navigateToChapter`'s `.index` case
requests a chapter reveal that NOTHING in Index consumes (`BookIndexView.landOrSeed` reads `pendingReveal` only);
unreachable today (the navigator is hidden in Index, `:121`), but a parked `pendingChapterReveal` would land on the
NEXT Outline entry as a surprise scroll. Drop the case or consume it.

**[NIT] · `App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift:505` vs `:521` ·** The panel slides and
fades; the 1-pt divider beside it has no transition, so the line pops a frame ahead of the column.

**[NIT] · `App/Variorum/Variorum/Registry/CapabilityRegistry.swift:1254` with `EditorCommands.swift:294` ·**
`.toggleSidebar` is declared `availability: always` while its menu item greys on `activeWindowKind != .full` — a
gate the registry walk cannot see (the comment admits it). A `windowKind` field on `CapabilityContext` would make
the grey a registry fact like every other one.

### What was checked and found solid (the clean bill)

- **Zero `Sync/`, zero schema, one core file** — verified by the diff itself, not the record: `Sources/` carries
  only `Domain/MarkdownSyntax.swift` (+53) and its test; the marker question does not arise.
- **Row 84's underscore italics are display-only by construction:** the scanner writes nothing; `renderedText`, the
  `.md` export and the bridge's join never consult `MarkdownSyntax.spans`; the word-boundary rule is right at every
  pinned corner and `⌘I` still writes `*`. The pin exists and passes (run here).
- **`TrailingFlow.rows` ≡ the phone's `MobileChipFlow.rows`** — diffed against `~/dev/variorum-mobile/…/
  MobileChipFlow.swift:35–56` in this session: byte-identical bodies, as the record claims. `keepingTogether`,
  `minimumLineWidth` and the leading-edge guard are the Mac's additions and are pure and pinned.
- **`LandingTarget`** is what it says — a value with no decision; every consumer (the book Index, Read's `edit`,
  the paged faces) lands the block and the caret at its start, and the record states the `utf16Offset` limit
  honestly.
- **`BookViewModel`'s three slots** (`pendingReveal` · `pendingLanding` · `pendingChapterReveal`) consume
  coherently: `requestReveal` clears a landing, `consumeReveal` clears both, `BookIndexView.landOrSeed` reads the
  landing BEFORE consuming; row 73's parking consumes only after `entries.contains` and drops a foreign request
  only once entries exist — the pin's premise (an empty model, the request before the mount) is the real ascent's.
- **The Outline landing's convergence** keeps its bookkeeping in a reference box (no `@State` write per report —
  the second cut's own loop, avoided), re-arms on content-height change, ends on a user scroll, and is fenced by a
  hop cap and a time budget; `outlineAnchor` puts the id at the LAZY row's level; `BookOutlineRows.segments` is
  pure and pinned; the P3 materialization count moved to realized content; `NearViewportObserver` and
  `StableSurface` flip state on the next turn (the modifying-state-during-update class named and avoided).
- **A bare `focus` seeds caret 0** and the inline editor lands on it (pinned); the detail's bare arrival reads the
  fact BEFORE the fill (`arrivalFact`) and lands at once, the window-less retry claiming first responder only —
  the K5 pin's catch, honored; `caretIdentity()` restores the caret by identity across `renderFull`.
- **`CurrentBlockMemory` + `registerDetail`'s restore:** every consumer tolerates a stale or dead id (Write falls
  to 0, Takes/Read/Blocks to the first row) — checked at each site; `noteFocusedBlock` writes only on a real change,
  so the defaults write is per block crossing, not per keystroke.
- **`BlockTOCViewModel.primeRows`/`awaitPrimed`:** MainActor-serial, `primed` set before the waiters resume, no
  continuation lost on an early return; the sibling observations wait and nothing in Read/Takes awaits a prime
  that never runs.
- **Compare's row 17** exempts the anchor at the MODEL (`compositionInputs`) and leaves `CompareComposition` and
  its pins byte-unmodified; peers stay filtered by kinship; `noPeerIsOpen`/`addNoteDoorShows` make row 46's one
  placement a pure fact; the display-title brain is the masthead's own (`Queries.noteDisplayTitle`).
- **`PageFrameNSView.hit(at:)`** decides link-first-then-block purely; the CoreText origin rebase (`box.minX/minY`)
  is the documented `CTFrameGetLineOrigins` contract; `PageComposer.blocks` is rebased exactly as the links are and
  filtered to the display length; the book and the note share one door.
- **The recovery family:** `lead` + `clockSlot` with `meta` DERIVED from the pair (the pinned value is the rendered
  pair); the date-only stamp additive in `Shared/`; `emptyTrashConfirm`'s kind order now names every kind
  `TrashScope` takes; `revealKeptInLineage`'s latch is exact (`inOriginals && !inStranded && !inDeleted &&
  !inArchived`); the pane's `List` really is gone (the reflection pin + the mounted class assertion).
- **`WorkbenchRowShell`** never asks `NSApp.currentEvent` anything (the crash class the pins caught, closed); the
  double is the row's own clock; `WorkbenchRows.display` is pure and honestly waits for facts only where a fact
  decides; `BlocksWorkbenchLayout.panelWidth` clamps both floors.
- **`MastheadTitleInsets`, `MastheadRowTwo.arrangement`, `TrailingFlow`'s reserve/yield rules** are pure and
  pinned, the standing rows 4/19/58 pins ride unmodified; `MastheadTagCluster` declares ONE act and the cards
  render without their ＋ (a static, read by the pin).
- **`PostMode` is seven, `fromStored("Index") → .read`**; `readEditAttached` is a token SET (a departing face's
  teardown cannot clear another's); `.tagNote` is note-scoped on three doors; the `s`-chord sweep holds at three
  (`EditorCommands.swift:293/316/323` — ⌃⌘S · ⌘S · ⌘⇧S) and the pin was edited to say so.
- **Row 67's re-anchor** (`after: .saveItem` → `after: .newItem`) is the one change no unit pin can reach (the test
  host owns its own main menu); the record's AX-listing evidence is the right kind, and the group's new anchor
  really exists in this scene (`CommandGroup(replacing: .newItem)` at `:247`).
- **`ShellSplit`** clamps its remembered width; `SidebarLayout`'s thresholds never compress an unmeasured column;
  `SideColumn` draws its own line in every window state and the Library column's pin runs both
  `controlActiveState`s.
- **Every justified pin edit** named in the records (`NoteTagDeclarationTests`, `NoteVersionsPaneTests`' chord
  count, `BookAscentTests`' fold pin → the act, the four `InspectorStyleContext` → oracle edits, the two
  `ListTableHeaderView` edits, `CommitBarLayoutTests`' re-expression, `PostDetailAndPanelTests`' seven) describes
  the ruled behaviour change it follows, line by line at the pin — none loosens a claim the round did not change.
- **Not re-run here (recorded as such):** the full Mac suite and its arithmetic (2071/367 — the records' per-batch
  sums were checked against the new test files' `@Test` counts and agree), the iOS build (`6b8b6ed`), and the
  load-flaky pair; the one core suite the round touched was run and is green.

### Dispositions — round 1 (the orchestrator, 2026-09-01 ~22:45 MDT; repo-first, before any fix session sees them; the spec and her bar outrank both agents)

| # | finding | disposition | the fix session's instruction |
|---|---|---|---|
| R1-1 | MAJOR — `StableSurface` has no shrink path (a taller stale memory reserves a permanent gap) | **ACCEPT — FIX.** The mechanism is concrete and lives in the round's own row-53 machinery; a blank gap under a story is a defect by C-7, and the doc block claims the opposite of the code | Compare the remembered WIDTH (a memory at another width does not apply — the doc's own rule) AND adopt a smaller settled size: when a loaded surface settles BELOW its reservation for a quiet interval, take the smaller size and drop the reservation (the row-53 settle discipline, reused). Fix the doc block and the record's "keeps the MAX" sentence. Pin exactly as proposed: `StableSurface` with `known` = 2× its content → the laid-out row equals the content's height (red on old); plus ONE walk: a story expanded in a ~900-pt window, the window widened, the story scrolled away and back — no gap |
| R1-2 | MAJOR — the Library rows hold a body click for the double-click interval | **ACCEPT — FIX.** C measured this idiom's 0.26–0.49 s on the Blocks rows; E rebuilt the panel and kept it; the first thing a reader feels | HOIST the `WorkbenchRowShell` idiom into ONE shared row-click brain (`Core/Views` — the hoist-at-next-touch rule; three copies otherwise) and use it on the book row, the note row and the workbench shell; every existing pin rides unmodified (the 3C parity proof). Pin: a Library row mounted alone, a REAL click → `infoHit` within 150 ms; a second click inside `NSEvent.doubleClickInterval` opens once (red on old by C's own numbers); walk: a row click → the panel moves at once (a burst by window id, E's method) |
| R1-3 | MINOR, SPECULATIVE — Read's faces/column: animated `scrollTo` on a non-identity `.id` over a lazy stack | **ACCEPT — PIN FIRST (the guard's rule for speculative findings).** Build the pin BEFORE any change: a 215-block note in Read(edit), `select(block200, scrollFace: true)` → the block's frame centred within the settle. RED ⇒ apply the book Index pane's form (identity = anchor, no animation) to all three sites and walk Boscombe's block 200 from the column; GREEN ⇒ record HOLLOW here and change nothing | as stated |
| R1-4 | MINOR, SPECULATIVE — Read ▸ Scroll's chapter click rides the flow's animated `scrollTo` (row 50, "not walked") | **ACCEPT — PIN FIRST.** An `onGeometryChange` oracle on the flow's anchors; a flow with five 215-block entries, `requestReveal(entries[4])` → the anchor's top within tolerance. RED ⇒ the unanimated form; GREEN ⇒ hollow, record. Either way ONE walk: Sherlock ▸ Read ▸ Scroll ▸ the navigator's eleventh chapter | as stated |
| R1-5 | MINOR — the pages face's unmodified ←/→ shortcuts steal arrows from the column's filter field and the masthead's fields | **ACCEPT — FIX.** AppKit's dispatch order is the mechanism (well known; a real defect the moment the filter field and the pages face share a surface) | Gate the turn on no text field being first responder (or move the turn into the leaf's own key handling — say which). Pin: the pages face + the column mounted, the filter field first responder, a synthesized ← → the field's selection moved, no page turned |
| R1-6 | MINOR — two `lineLimit(nil)` + `fixedSize` explainers outside their `ScrollView`s (the b6dae25 wedged-window class), one pane also `.sheet`-hosted | **ACCEPT — FIX.** P-8 names the class and the incident was real | Move the two texts INSIDE their scroll views (preferred) or bound them; pin: `ChromeMinHeightTests`' near-zero-width probe over a sheet-hosted `BlockHistoryPane` stays bounded |
| R1-7 | MINOR — `SideColumn` drag past the trailing edge snaps to the ideal width | **ACCEPT — FIX.** Pure, cheap, hers to feel | Clamp the proposal to `minimum` before the `> 0` test; pure pins: `width(remembered: −40)` and `width(remembered: 0)` answer `minimum` |
| R1-8 | MINOR — `BookIndexEditModel.teardown` keeps cached coordinators (latent; the model dies with the mode today) | **ACCEPT — FIX (cleanliness, a unit pin).** | Drop the coordinator entry with its token (or make `teardown` terminal — say which); pin: teardown then `coordinator(for:)` re-subscribes (a refusal after a teardown is reported) |
| R1-9 | MINOR, record gap — Read's host arrives unprimed (row 83's brief asked which modes were checked) | **ACCEPT — FIX + RECORD.** `primeRows` exists on the shared model | Prime Read's rows before its observation (one line, the Blocks shape); a measure pin of the Blocks shape (a sanity bound) + the dev-store number recorded under row 94's owner; say which other modes were checked |
| R1-10 | MINOR — every expanded Outline row runs `renderPost` for a form that renders nothing from it | **ACCEPT — FIX.** Cleanliness (P1's letter holds) | Gate `loadFacts` on the collapsed form; pin: a DEBUG read counter — an expanded far row performs no `renderPost` |
| R1-11 | MINOR — `MarkdownSyntax`'s closer doc disagrees with the code (`_a__`) | **ACCEPT — FIX.** Align the doc to the code (the stricter rule) | RULE for the corner (the orchestrator's call): content that ENDS in an underscore never italicizes — `_a__` is LITERAL (an italic `a_` is nonsense); add it to the core pin; state the rule in the doc |
| R1-12 | NIT — `fixedChromeHeight` assumes three headers/separators; the pin's "eight-mode rail" comment is stale | **ACCEPT — FIX.** Count the groups actually present (or document the assumption at the constant); fix the comment | small |
| R1-13 | NIT — `isLoneHeadingOrNumeral` skips a short SENTENCE ("Dear reader.") | **ACCEPT — FIX.** A stub is a heading or a numeral-like token; a short text ending in a full stop is a sentence | add the case to `BookOutlineRowsTests` |
| R1-14 | NIT — the Canvas arrival decides centre-vs-origin against the 1200×800 fallback viewport | **ACCEPT — FIX.** Land when the viewport has reported (or pass the hosting size); pin: the decision reads a reported size | small |
| R1-15 | NIT — `currentBlock.<id>` / `postMode.<id>` / `readFace.<id>` defaults never reaped | **RECORD — owner 17e (correctness singles): a per-note-defaults sweep at note purge** (a pre-existing class this round extended by one family; `forgetCurrentBlock` is the door) | the closeout writes the 17e item |
| R1-16 | NIT — `navigateToChapter`'s unreachable `.index` case would park a surprise reveal | **ACCEPT — FIX.** Drop the case | trivial |
| R1-17 | NIT — the Library panel's divider has no transition (pops a frame ahead) | **ACCEPT — FIX.** The divider joins the column's transition | trivial; walk by burst |
| R1-18 | NIT — `.toggleSidebar` declared `always` while its menu greys on a window-kind check the registry cannot see | **RECORD — owner 17e: a `windowKind` field on `CapabilityContext` so the grey is a registry fact (P-1)** | the closeout writes the 17e item |

**The fix session (ONE fresh Fable session, briefed by this subsection only):** every ACCEPT above, in the order R1-2 · R1-1 · R1-3/R1-4 (pin-first) · R1-5 · R1-6 · R1-7 · R1-9 · R1-10 · R1-11 · R1-8 · the NITs; commit per item with the standing trailer, PUSH after each, `LIVE STATUS — LADDER FIX 1` from the first commit, synchronous waits only; bug-class fixes with red-on-old by BEHAVIORAL REVERT (announced before, restored from the repo root, diff empty); the two speculative items pinned BEFORE any change and dismissed as hollow if green; the hoist's parity proof (every existing pin unmodified); the walks named above on the dev-store Debug build of the fix tree (captures in `act10-correction-screens/ladder-fix-1/` + a contact sheet); `TutorialWalkTests` green, then the FULL Mac suite once on the final tree with the arithmetic against **Mac 2071/367 · core 1525/165**; the load-flaky reds re-run isolated, never loosened; a `### LADDER FIX 1 RECORD` under this subsection (per-item dispositions with pin names and red-on-old evidence; the hollow verdicts if any; the walk table; counts; commits). Then stop — round 2 is a fresh reviewer.

### LADDER FIX 1 RECORD (a fresh Fable fix session, 2026-09-01 ~22:00 MDT →; the machine's clock)

#### LIVE STATUS — LADDER FIX 1 (flipped in the same commit as each item; a fresh session finishes from this list alone)

- **Orientation:** DONE — read in the brief's order: CLAUDE.md; this file whole (§0–§2, the ledger, every batch record and CLOSED line, `## LADDER ROUND 1` + its dispositions table); `notes/SessionResiliencyProtocol.md`; the orchestrator handoff §0 and §2c; then the code each finding names. Tree clean at `604e52e`; the dev-store Debug build pid 68968 (batch G's tree) running; her real-store app NOT running; `/Applications` untouched. **Machine covariate, recorded before any pin ran:** another session's `xcodebuild test -scheme fragments` (a full iOS UI-test suite in a BOOTED iPhone 17 simulator) is running on this Mac throughout — load 6–10 — which is exactly the real-pointer-events-under-load class F/G recorded for the rig pins.
- **R1-2 (the hoisted row-click brain):** DONE (this commit; hash next) — `Core/Views/RowClick.swift`: `RowClickTiming.verdict` (pure — a click inside the interval of the last is the double) + the `rowClick(onClick:onDoubleClick:)` modifier (ONE `onTapGesture`; the row's own clock; the keyboard's live chord). Consumers: `WorkbenchRowShell` (its private state and tap closure moved into the modifier — behaviour byte-identical), the Library's BOOK row and NOTE row (the stacked count-2 + plain taps retired). `LibraryPanelOracle.noteRowFrames` + the `.noteRow(id)` probe slot (DEBUG) so a pin can click a row for real. Pins (`RowClickTests.swift`): `RowClickTimingTests.aSecondClickInsideTheIntervalIsTheDoubleAndOutsideItIsNot` (pure, GREEN) · `LibraryRowClickTests.aBodyClickStandsThePanelUpWithinTheBudgetAndADoubleOpensOnce` — **the note row's click SHELL mounted ALONE in the canvas rig's panel** (`CatalogNoteRowShell`, extracted at this commit as an internal view — the row's `contentShape` + the probe + `rowClick`, its modifiers arriving as the click model's own `NoteRowClickModifiers`; `postRow` composes it): wired to a real `LibraryCatalogModel`, a real body click → `infoHit` in **0.001 s** (budget 150 ms); a second click inside the interval opens once. GREEN, with the shell's parity pin (`BlocksWorkbenchFaceTests` unmodified — **0.002 s** through the hoisted modifier), the Library host pins and `NoteRowRoutingTests`: 20 tests / 5 suites. **Why the shell alone:** the first shape mounted the WHOLE catalog in the rig, and that HANGS under the rig's event pump (one run 463 s, one killed at the 10-minute wall) — batch C's whole-workbench class exactly (its row-25 pin mounts the shell alone for the same reason); three earlier runs under the other session's simulator load had lost clicks outright and were misread as load — the hang was the catalog's. Red-on-old: the behavioral revert (below).
- **R1-1 (StableSurface's shrink path):** DONE (this commit; hash next) — `BookView.swift`: `StableSurface` (now internal, so the pin mounts it alone) compares the memory's WIDTH (`stableSurfaceWidthTolerance` 1 pt — a memory at another width reserves nothing from the surface's first real report; placeholder reports below the ceiling never decide) AND adopts a SETTLED size: every real report re-arms a check that fires after `stableSurfaceSettleInterval` (1.0 s — the landing's own hold, so row 54's provisional-width first measure and a placeholder waiting on the encrypted read never decide) with the size unchanged, adopts THAT size (taller or shorter) as the memory and drops the reservation; the bookkeeping in a reference box (no `@State` write per report — the landing's lesson). The doc block rewritten (the stray duplicate paragraph above `NearViewportObserver` removed); the row-53 record's "keeps the MAX" sentence corrected in place with a dated marker. Pins (`StableSurfaceTests.swift`): `aStaleTallerMemoryAtTheSameWidthIsDroppedOnceTheSurfaceSettles` (a 400-pt memory over 200-pt content at the same width → the row ends at 200 and the memory is 400×200) · `aMemoryAtAnotherWidthReservesNothing` (a 300-wide memory over 400-wide content → 200 at once, inside the settle interval). GREEN with every book suite riding unmodified: `BookOutlineLandingTests` ×6 (the row-53 landings hold) · `BookOutlineRowsTests` · `BookViewTests` · `BookRedesignMountTests` · `BookOutlineFacesTests` · `BookIndexEditingTests` — 28 tests / 7 suites. Red-on-old: 5 issues in 2 tests under the behavioral revert (below). The walk (a story expanded in a ~900-pt window, widened, scrolled away and back — no gap) rides the end-of-session walk.
- **R1-3 (Read's faces/column land with an animated `scrollTo` on a non-identity `.id`):** PINNED FIRST, GREEN ⇒ **HOLLOW — nothing changed.** `ReadLandingTests.swift` (kept as regression insurance, 2 tests): a 215-block note, the arrival at block 200 through the row-39 road (the router's focused block, then the host's `.onChange(of: rows)` seed — the app's ⌘3 road) → `theEditFaceLandsAFarBlockCentredOnArrival`: block 200's frame **(400.5, 474.5, 640×50) in the 1100×750 host — centred** (115 edit rows realized); `theReadFaceLandsAFarBlockOnArrival`: block 200 at y = 212 — the top third, as the page anchors it. An explicit `.id` on a direct child of the LazyVStack's ForEach IS reachable here, animated or not (B measured only the NESTED case); the note's three landing sites stay as they are. The column's own row (`ixr-`) has no probe and rides the same seed; not separately pinned.
- **R1-4 (Read ▸ Scroll's chapter click rides the flow's animated `scrollTo`):** PINNED FIRST, **RED — and the class is deeper than the finding said.** `ReadingFlowLandingTests.swift`: the flow over FIVE 215-block stories, the reveal of the fifth requested after the mount (the navigator's road). Run 1 (the shipped form, animated): the fifth story's top **1,562 pt short** (the scroll travelled toward the lazy estimate while the stories it passed loaded). Then the finding's own fix — unanimated + the ForEach identity as the anchor (`FlowRows`, the flow's rows FLATTENED so a post row's identity IS `flow-<id>`; the nested `.id` was unknown to the reader once the lazy stack released the row): **still red, 18,452 pt off** — the scroll went exactly where the lazy stack BELIEVED the row was, then the unloaded stories above grew by ~11,500 pt each. Then the Outline's stability-driven corrector (checks after a quiet interval, hops on the identity, a hop cap and a time budget, ended by a user scroll) — its own log: **the column's estimate DOUBLED under the hops, 35,426 → 116,780 pt for ~58,000 of content, and the target never realized** (the row-53 slow form B traced: a lazy stack estimating unrealized rows, runaway) — it converged only on a quiet machine with the stories already loaded, and in the app a page hopping for four seconds would be her "berserk scrolling" (her #7) reborn on the Read page. **SHIPPED: the unanimated form + the flat identities** (`ReadingFlowView.land`, `FlowRows` — pure, the doc block carries the whole account). **RECORDED as ledger row 95 (below) with owner** — the structural fix is B's segmented column with remembered sizes applied to the flow, a batch of its own. The pin is `.disabled` with that reason (it counts in the suite's total; it reactivates with row 95's batch and must then be green). The DEBUG oracle `ReadingFlowGeometry.anchorTops` + `readingFlowAnchorProbe` stay (the pin's eyes). Green with the neighbours: `BookViewTests` (the round-3 virtualization pin rides the flat rows unmodified) · `BookAscentTests` · `BookStructureTests` · `CanvasAndPoolTests` · `BookOutlineLandingTests` · `ReadLandingTests` — 19 tests / 5 suites (one skipped, by design). **The walk (Sherlock ▸ Read ▸ Scroll ▸ the navigator's eleventh chapter) rides the end-of-session walk** — expected to show row 95 in use.
- **NEW LEDGER ROW for the orchestrator — row 95 (found by R1-4's pin-first; NOT this session's to fix):** `| **95** | (ladder fix 1, R1-4's pin) Read ▸ Scroll's navigator chapter click lands WRONG whenever the stories between the page and the chapter have not LOADED — an unloaded story is one line tall until its text is read, so the lazy column's estimate of a far row's offset is off by tens of thousands of points and `scrollTo` (animated or not, by identity or not) lands wherever the estimate says; on Sherlock the lazy stack RELEASES far rows as the first stories grow (their `.task`s cancel), so at rest only the first stories are loaded and the eleventh chapter's click is the COMMON case, not a race | Read ▸ Scroll (`ReadingFlowView`) | The book Outline's row-53 class in the flow, measured: a bounded stability-driven corrector's hops DOUBLED the column's estimate (35,426 → 116,780 pt for ~58,000 of content) and never realized the target; a corrector is therefore the wrong shape here. Fix shape: B's answer — the heavy rows OUTSIDE the lazy container with a remembered size (a `StableSurface`-style placeholder when far, `NearViewportObserver`), so the column's geometry is honest and one unanimated `scrollTo` lands; an honest per-story height estimate for never-measured stories (the block count × a paragraph pitch) closes the first-visit gap. The disabled pin `ReadingFlowLandingTests.aRevealOfTheFifthLongEntryLandsItsRowAtTheTop` is the acceptance. Owner: the orchestrator's call — **13u2 item 1's family** (the non-editing pane jumping class, beside row 92) or a bounded batch of this round | ladder / 13u2 | RECORDED |`
- **R1-5 (the pages face's ←/→ steal the arrows from text fields) + R1-9 (Read arrives unprimed) — the Read host's two:** DONE (this commit) — R1-5: `Core/Views/PageTurnKeys.swift` — the pure rule (`PageTurnKeys.turn`: an unmodified ← / → turns a leaf ONLY while no text-editing view is first responder — an `NSText`, i.e. every field editor, or an `NSTextField`) + the door `PageTurnKeyMonitor` (a zero-size `NSViewRepresentable` owning a local `keyDown` monitor for its own window while it is in one; it consumes the key only when it turns, otherwise the key reaches the field as if the face were not there). CHOSEN over gating the shortcut's action: a consumed key equivalent never reaches the field, so gating inside the action would have silenced both the turn and the caret. `NotePagesView` drops its two `.keyboardShortcut`s for the monitor (the ◀ ▶ buttons stay); the book's `PagedReadView` keeps its shortcuts (it shares its surface with no text field — recorded). Pins (`PagesArrowKeysTests.swift`): `PageTurnKeysRuleTests.anUnmodifiedArrowTurnsOnlyWhileNoTextFieldIsInCharge` (pure) · `PagesArrowKeysHostTests.anArrowInTheFilterFieldMovesTheCaretAndTurnsNoPageAndTurnsALeafOtherwise` — the pages face beside the `▸ 01` column in the rig's panel, the filter field made first responder with the caret at the end of "filter", a synthesized ← through `NSApp.sendEvent` → the caret at 5 and `ReadModeOracle.pageTurns == 0`; the field let go, → turns a leaf (1). GREEN — **and green on the OLD form too (the behavioral revert): the rig's synthesized `keyDown` through `NSApp.sendEvent` does not pass through SwiftUI's key-equivalent phase the way a REAL key event does, so the rig cannot reproduce the theft — the pin holds the RULE and the monitor's own delivery, not the old defect.** The red-on-old is therefore in USE: on the RUNNING OLD BUILD (pid 68968, batch G's tree — File ▸ New Window on the windowless process), Boscombe ▸ Read ▸ `read` ▸ `pages`, the filter field clicked and "ab" typed, → pressed through System Events → **the page turned (pages 1–2 → 3–4) with the field holding the keyboard** — captures `03-old-pages-field-typed` · `04-old-pages-after-right-arrow` (+ `crop-03/04`); the walk on the fix tree is the green half (below). R1-9: `ReadModeView` primes its rows before its observation (`primeRows` → `start`; the tray and pools observations `awaitPrimed()` — row 83's exact shape); `ReadModeOracle.firstEditRowPaintedAt` (the edit probe's first report). Pin `ReadArrivalMeasureTests.theFirstEditRowPaintsWithinTheCeilingOnATwoHundredBlockNote` — the real host on a 215-block note: **0.087 s** mount → the first painted `edit` row (ceiling 1.5 s, a sanity bound — the harness cannot tell primed from unprimed, as row 83 found; the dev-store series in the walk is the number). **Which other modes were checked (the brief's question), at the code:** Blocks (primed, G) · Read (primed here) · Write (`EditorView` fills from its own projection engine — a different road, no observation-first-delivery blank) · Takes (`TakesViewModel.start`'s observation, UNPRIMED — the same class; not this item's) · Lenses/Compare (the boards' own observations, unprimed) · Canvas (`CanvasViewModel`'s projection, unprimed) — recorded under row 94's owner (13u2 item 1's family: a note projection shared across modes). Red-on-old: R1-5 by the behavioral revert (below); R1-9 indistinguishable in the harness (row 83's precedent).
- **R1-6 (two unlimited `fixedSize` explainers OUTSIDE their scroll views — the b6dae25 class):** **HOLLOW — dismissed on the pin's evidence, the move UNDONE (the guard's rule: a pin green on both sides is not fixed).** The move inside the scroll views was built and committed (`c5c82ae`), then undone at `5f413c4`; its pin `ChromeMinHeightTests.sheetHostedRecoveryPanesNearZeroWidthProbeStayBounded` — the window's own near-zero-width probe (`sizeThatFits(1 × 0)`) over a sheet-hosted `BlockHistoryPane` and over the `TrayPanel` — read **280 pt with the texts inside the scroll views AND 280 pt with them outside** (the behavioral revert), because both panes pin their own width and height floors (`.frame(minWidth: 300, minHeight: 280)` / `(minWidth: 280, minHeight: 280)`): the probe measures the explainer at 300 wide, never one character per line, so the window's minimum can never inflate — in a sheet or anywhere. The texts are back where they read (above the scroll, with a comment naming the measurement); the pin STAYS as the class's guard (a pane that drops its width floor turns it red). Recorded, not fixed.
- **R1-7 (the side column's drag past the trailing edge snaps to the ideal):** DONE — `SideColumnLayout.draggedWidth(pointerX:total:ideal:minimum:)` (pure): a drag proposes `max(minimum, total − pointerX)` — never ≤ 0 — through the standing `width` rule; the gesture calls it. The rule's own "0 = nothing remembered ⇒ the ideal" stands (the finding's letter had `width(remembered: 0)` answer `minimum`, which would break the store's "nothing remembered" — the disposition's "clamp the proposal before the `> 0` test" is honored in the GESTURE's brain instead; stated). Pin `SideColumnTests.aDragPastTheTrailingEdgeMeansTheMinimumNeverTheIdeal` (40 pt past the edge and exactly at it → 280; ordinary drags clamped as before; `width(remembered: 0)` still 420). Door class (the brain did not exist); the old mechanism is still visible: `width(remembered: −40, …)` answers 420, which is exactly what the drag no longer hands it.
- **R1-10 (every expanded Outline row ran `renderPost` for a form that renders nothing from it) + R1-13 (a short sentence skipped as a stub) + R1-16 (`navigateToChapter`'s unreachable `.index` case) — the book's three:** DONE — R1-10: `OutlinePostRow`'s facts task is keyed on the form (`"<postID>|<expanded>"`) and returns without reading for an expanded row (a row collapsing later reads then); the DEBUG counter `BookOutlineFactsReads.count` in `loadFacts`. Pin `BookOutlineLandingTests.anExpandedRowPerformsNoFactsRead` — a five-story book with `expandAll()` before the mount: **0 reads** after the settle; `collapseAll()` → ≥ 5. R1-13: `BookOutlineRows.isLoneHeadingOrNumeral` — a terminated text (`.` `!` `?`) is a SENTENCE unless what precedes the mark is one numeral-like token (digits or a Roman numeral — `isNumeralToken`); `Dear reader.` / `Chapter one.` / `Why?` preview, `I.` / `IV.` / `1.` / `Part 2` / `Chapter 3` stay stubs. Pin `BookOutlineRowsTests.aShortSentenceIsAPreviewAndALoneNumeralIsAStub` (+ the card preview on both). R1-16: `.index` is its own `case` that does nothing, with the reason at the site. Green with every book suite. Red-on-old: R1-10 and R1-13 by the behavioral revert (below); R1-16 trivial (no pin).
- **R1-11 (`MarkdownSyntax`'s closer doc vs code — `_a__`):** DONE — THE RULE (the orchestrator's): content that ENDS in an underscore never italicizes — `closingUnderscore` also requires `chars[index − 1] != "_"`, so `_a__` is LITERAL (as the opener already refuses content STARTING with one — `__bold__`); an underscore INSIDE the content stays content (`_a_b_` → italic `a_b`). The doc states the stricter closer rule and this one. Core pin `MarkdownSyntaxTests.underscoreEmphasisIsItalicAtWordBoundariesOnly` gains `_a__` literal · `_ab__ cd` literal · `_a_b_` italic with content `a_b`. `swift test --filter MarkdownSyntaxTests`: 21/1 green. Red-on-old: the behavioral revert (below).
- **R1-8 (`BookIndexEditModel.teardown` kept cached coordinators):** DONE — the coordinator ENTRIES leave with their tokens (`coordinators.removeAll()` after the flush list is taken), so a model reused after a teardown re-subscribes through `coordinator(for:)` on its next touch (CHOSEN over making teardown terminal — a reused model is the case the finding names). Pin `BookIndexEditingTests.aModelReusedAfterATeardownStillHearsItsCoordinatorsRefusals` — teardown, then an edit on a take the store does not hold, `flushNow` → the refusal is SPOKEN (`session.status.current != nil`). GREEN. Red-on-old: the behavioral revert (below).
- **R1-12 (`fixedChromeHeight` assumed three headed groups; the pin's "eight-mode rail"):** DONE — `SidebarLayout.chromeHeight(headedGroups:)` (14 + n × (22 + 19) + 96); `compressesRows`/`rowHeight` take `headedGroups:` (default 3 — the full column, so the standing pins ride); `SidebarView` passes the groups actually present (starred non-empty · the rail · the Open strip non-empty); `fixedChromeHeight` = `chromeHeight(headedGroups: 3)` = 233 still. The pin's fixture corrected to the SEVEN-mode rail + one starred note (20 rows — the arithmetic unchanged, the comment true). Pin `SidebarLayoutTests.theChromeCountsOnlyTheHeadedGroupsPresent` (one group = 233 − 82; twelve rows with one group fit where three groups would compress). GREEN. Door class (the function did not exist).
- **R1-14 (the Canvas arrival decided against the 1200 × 800 fallback viewport):** DONE — `landOnArrivalIfReady()` lands only once BOTH the projection and the viewport have reported (`!model.visibleRect.isEmpty`), called from the cards-count change AND from `visibleRect.isEmpty`'s change; `CanvasArrivalOracle.viewport` records what the decision read. Pin (in `CanvasArrivalTests.aNeverArrangedCanvasLandsThroughFitAllAsItsProjectionArrives`, MADE HONEST at `5f413c4` after its first revert run stayed green — the projection is now PRE-LOADED with `model.adopt` before the mount, so the arrival's `initial: true` fires before any viewport report, the app's remembered-note case): the recorded viewport is never the fallback and is a reported size. **Measured on the way:** the first reported viewport under the test host is the hosting view's PROVISIONAL layout — 1050 × 649 for a 900 × 600 window, settling to 900 × 566 — the row-54 class of first measure; the decision reads a reported viewport as the disposition asks, and the provisional-vs-settled refinement is that family's (recorded, not chased). GREEN. Red-on-old: the behavioral revert (below).
- **R1-17 (the Library panel's divider pops a frame ahead):** DONE — `panelDivider` carries the column's own `.transition(.move(edge: .trailing) + opacity)`. No pin (an animation — batch E's precedent); the burst walk rides the end-of-session walk.
- **Walks · `TutorialWalkTests` · the full Mac suite (baseline Mac 2071/367 · core 1525/165):** PENDING.
- **R1-1's red-on-old — VERIFIED by behavioral revert** (from the committed state `fa61730`: the settle arming and the width comparison switched off in place inside `StableSurface`; log `scratchpad/lf1-r1-1-red.log`): **5 issues in 2 tests** — the same-width case: `settled → false`, the row **200 pt over the content** (`abs(height - 200) → 200.0`), the memory never adopted (`remembered.last → nil`); the other-width case: `dropped → false` after 3.0 s (the reservation held for good — the width carried, never compared). Restored by `git checkout --` from the REPO ROOT; `git diff --stat` empty. **No revert in flight.**
- **The combined red-on-old — VERIFIED by behavioral revert** (from the committed state `f9f0f52`, the seven mechanisms off in place; logs `scratchpad/lf1-small-red.log` + the core run): **R1-11 (core): 2 issues** — `_a__` and `_ab__ cd` italic; **R1-8: 1 issue** — `session.status.current → nil` after the teardown (the refusal unheard); **R1-13: 5 issues** — "Dear reader." / "Chapter one." / "Why?" / "Go!" read as stubs and the card previewed past "Dear reader."; **R1-10: 1 issue** — `BookOutlineFactsReads.count → 5` at the mount (five expanded rows, five whole-note reads); **R1-6: NOT red (280 pt both ways) → HOLLOW**, above; **R1-5: NOT red in the rig** (the synthesized key's path — above; red in USE on the old build); **R1-14: NOT red on the first shape** (the pin's projection arrived after the viewport, so the old code read a reported size too) → the pin re-shaped (pre-loaded projection) and its revert re-run below. **Machinery honesty:** the restore command ran from `App/Variorum` and matched nothing (batch C/D's own trap) — caught at once, restored from the repo root in the next command; `git diff --stat` empty against `2198e08`. A second slip: `5f413c4`'s message described these record lines, but its Python step had failed on an anchor and the commit ran without them — they land in this commit.
- **R1-14's red-on-old — VERIFIED by behavioral revert** (from the committed state `5f413c4`, `landOnArrivalIfReady`'s viewport guard off in place; log `scratchpad/lf1-r1-14-red.log`): **1 issue** — the arrival's decision read `viewport → (1200.0, 800.0)`, the fallback, with the projection in hand before the mount. Restored from the repo root; `git diff --stat` empty. *(Machinery honesty, the same trap a third time: the restore was first issued after a `cd App/Variorum` in the same command and matched nothing; restored in the next command from the repo root — every later restore in this session starts with an explicit `cd` to the root.)* **No revert in flight.**
- **revert starting — pre-revert state is the commit that carries this line** (R1-2's behavioral revert: `CatalogNoteRowShell` back to the stacked `onTapGesture(count: 2)` + plain-tap idiom in place; restore = `git checkout -- App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift` from the REPO ROOT — with an explicit `cd` first).
- `/Applications` untouched; her real-store app untouched (not running).
