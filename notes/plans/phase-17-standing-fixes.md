# Phase 17 — Standing Fixes (STANDING PLAN)

> **THE ALPHABET IS FULL (her word, 2026-10-04):** 17z took the last letter the same night it was
> minted, and the author ruled the succession at the 13i family close — **new entries open in
> `notes/plans/phase-19-standing-fixes.md` (19a, 19b, … 19z) from now on.** This file stays the
> binding record for every 17 entry: the OPEN ones (17e-residue riders, 17r, 17s, 17w, 17x, 17y,
> 17z) still run and close HERE under their own letters; nothing moves. The same rules bind both
> files; CLAUDE.md's live rule names 19 as the active ledger.

> **This phase does not close.** It is a standing home for bug fixes and tech debt, opened by the
> author on 2026-08-30. Its **entries** (17a, 17b, 17c, …) are what open, run, and close — the phase
> itself stays open for the life of the project. A closed entry is never reopened; a recurrence gets
> a fresh letter.

## The philosophy (author, 2026-08-30 — her words)

> *"I would start a new phase, not filling the detailed plan for phases doc since we just reduced how
> full it was but just with a pointer there, and that phase will be standing quick bug fixes. from now
> on, when I notice a quick bug or issue or something that I want fixed, it'll be added as an entry
> like 17a, 17b, 17c, etc. […] bascially, I want to be able to active phase discipline and share where
> random fixes and changes are going in one cohesive phase, without it polluting the detailed plan for
> phases document with bug fixes / tech debt rather than product advancement."*

**The rule this establishes, stated plainly:**

1. **`DetailedPlanForPhases.md` is for PRODUCT ADVANCEMENT.** New capability, new surfaces, new
   design — things that change what the app *is*. It carries exactly **one pointer row** to this
   file and nothing else about fixes. This extends her 2026-08-30 lean-docs ruling (the one that
   created `notes/FuturePhases.md`) along a second axis: that ruling moved far-future work out by
   TIME; this one moves fixes out by KIND.
2. **Fixes, bugs and tech debt live HERE**, grouped into lettered entries — so they still get real
   phase discipline (a scope, a cast, tests, a closeout) instead of becoming ad-hoc side work, and so
   there is **one place to look** for where a random fix went.
3. **A 17-entry is a valid owner** under `KnownIssuesAndTechDebt.md`'s rule ("no entry without naming
   the owner that resolves it"). Naming `17c` satisfies it exactly as naming a phase number does —
   the same widening her 2026-07-26 R2-7 ruling made for project rows. **A blank owner is still
   forbidden.**
4. **THE REVIEW RULE (author, 2026-09-01 at the Act 10 correction round's sitting — R-cor-14):** an
   entry MAY run as ONE session without an orchestrator, under this file's discipline (pin before fix,
   red-on-old by behavioral revert, the record kept here by the session itself, the full suite + the
   tutorial spine as the gate, push after each commit) — **but an OPUS cold review is ALWAYS
   mandatory, and a FABLE cold review whenever the diff touches `Sync/`, custody/keychain code, or
   the editor seam** (`BlockRangeIndex` / `EditorTextView` / `PaneTextAuthority`). Her stated practice:
   mostly a few entries at a time as an ad-hoc phase under a **Fable orchestrator** (Opus alone does
   not keep records) — `notes/PhaseSizingGuidance.md` §5 has her words.
4. **This file is not a bug tracker and not a scratchpad.** An entry is a scoped, runnable unit of
   work. Something with no traced mechanism is not ready to be an entry.

## How an entry works

- **Adding one.** When the author notices a bug or names something she wants fixed, it becomes a new
  lettered entry (or joins an open one where it genuinely belongs). Her word opens it; nothing is
  added autonomously beyond recording what a sweep or a phase found.
- **Grouping.** Entries group by **shared root cause** where one exists, and by **shared consequence
  class** otherwise. A group large enough to want its own kickoff sitting should be split, not run wide.
- **Cast and review depth** are decided per entry at the author's word, exactly as at any kickoff. A
  two-line fix does not owe a three-round ladder; a credential-layer entry does. **The standing
  `Sources/VariorumCore/Sync/` Fable rider binds regardless of what any entry decides.**
- **Closing.** An entry closes with a written disposition for every item it carried — FIXED (naming
  its pin), DISMISSED AS HOLLOW (the pin passed on both sides), or DEFERRED with a named owner. An
  item that is silently dropped is a closeout defect. Anything deferred lands in
  `KnownIssuesAndTechDebt.md` with its owner.
- **Ordering.** Letters are allocation order, **not** priority. The running order is the author's, and
  entries interleave with product phases at her word.

## Standing rules for every entry

1. **PIN BEFORE FIX — no exceptions.** The hallucination guard binds here exactly as in a phase
   review: no item is fixed until whoever fixes it has **traced the mechanism themselves**, and every
   bug-class fix lands with a **red-on-old pin** — a test that fails on the pre-fix code and passes
   after. **A pin that passes on both sides exposes the item as hollow: it is dismissed, recorded,
   and NOT fixed.** Architectural and clarity items need no pin but still need the traced mechanism
   and a written justification.
2. **Nothing in this file has a pin yet.** Every item below arrived from a review, carrying a traced
   mechanism and a file:line and nothing more. Step zero for each is the pin.
3. **No product invention.** A fix that requires deciding behaviour the spec does not define is not a
   fix — it goes to `notes/QUESTIONS.md` and waits for the author. The author-only calls in
   `CLAUDE.md` bind unchanged.
4. **Measure before believing a number.** Sweep-sourced performance claims are traced-by-reading
   unless they say otherwise.
5. **Schema changes get their own commit**, ahead of anything using them, per CLAUDE.md.

---

## Allocation register (read before adding an entry)

**2026-09-01 — PHASE 18 EXISTS (author, R-cor-13): the post-13 collector of PRODUCT work (18a, 18b, …) on the master plan's table — product advancement that has no 13 letter left goes THERE, never here; 17 stays fixes and tech debt.** 17e gained items (11)–(12) from the correction round's ladder; 17i runs AFTER pre-13x; 17k → 18a.

Letters are **allocation order, not priority**, and more than one session may be adding entries at
once. Claim a letter here first.

| Letter | Subject | State |
|---|---|---|
| **17a** | **CLOSED 2026-08-30 — the pre-13u round's Act 9 (the Fable custody batch).** All 8 items FIXED with revert-verified red-on-old pins; per-item dispositions in the entry below; the two KnownIssues rows that carried owner "17a" without being in the item list are RE-ROUTED to **17h** (opened at her word) | **closed** |
| **17b** | Doors that lose or mis-copy her text (+ KnownIssues row 65 at the 13u4 refresh) | **CLOSED 2026-09-21 — RUN A batch A1 + the run's ladder.** All 7 items FIXED with revert-verified red-on-old pins; the ladder extended the class twice (the quick-note park's quit rider hardened; the comment-draft park born on both platforms); one undo-side residue DEFERRED → 17e. Dispositions in the entry below |
| **17d** | Purge & sync honesty (P8/P9/P28/P31; P30 dissolved 2026-09-04) | **CLOSED 2026-09-22 — RUN B** (dispositions in the entry; the live-round leg PASSED at her 2026-09-22 morning round) |
| 17e | The 2026-08-30 sweep's remaining group (has since gained rows: P6's undo-side residue, the launch seeder's cross-device deletion, the canvas router fact, the content-replacement undo row) | **RIDING 18k + 18o (her ruling R-18k-1, 2026-09-25):** the concurrency five (row 59 · P26 · P27 · P33 · P38) = 18k's C5; the rest (P23 · P29 · P32 · P34 · P35 · P37 · (12) · row 66 · row 64 record-only) = 18o; (11) verified partly discharged by 18d. This entry stays the BINDING record; dispositions land here at each run's close |
| **17t** | **The two unwired protection doors** (KnownIssues rows "The typed NEAR-EMPTY sync confirmation" + "COPY ALL on the recovery phrase") — minted 2026-09-25 at the 18k kickoff sitting (R-18k-2, her words *"17t and add that to an 18"*) | **RIDES 18o** (right after 18k); the custody Fable rider fires |
| **17u** | **The locked lobby's backdrop** — her 2026-09-25 between-rounds ask: the tessellating endpaper tile (the humanoid figures and the book) OUT of the app everywhere, replaced by an animated monochrome glyph rain. Built in the author-attended Fable session the same day (a one-file view + a pure brain, the asset removed, a grep pin) | **CLOSED 2026-09-26** — the entry below; **the standing Opus cold review WAIVED by her** (verbatim: *"we don't need an Opus cold review on this purely cosmetic change"*); installed `c09f81be…` |
| **17v** | **The AppSpec split (the context trim's second act)** — `notes/AppSpec.md` had grown to 112k chars because every phase landed its rulings INLINE (§9 alone 42k). The act: AppSpec keeps the CONTRACT (per operation: what it does, what it refuses, what it owes the invariants, the ruling's ID; per table: DDL + a one-line column note; §12 the current surface list + pointers to the binding plan files) and the whole pre-split file lives BYTE-VERBATIM in `notes/AppSpecRulingsArchive.md` (canon, not loaded; `cmp`-proven identical at the copy), so nothing was lost and every ruling still binds. Minted and **CLOSED the same sitting, 2026-09-26, at her word** (*"why did you not just do the appspec split?"*): AppSpec 112k → 54.7k; every operation name and every table from the old §7/§9 verified present in the new text; the auto-loaded set 149,981 → ≈92.5k chars of the 150k limit. **The standing rule that stops regrowth** (CLAUDE.md + both skills' closeout text): a canon delta lands as a contract line plus a pointer to the plan's ruling, never a paragraph of history. **Retracted the same sitting, at her objection:** the interim "move an equal amount to the archives" line — a size-balancing rule rewards deletion, the one failure a canon file must never have | **closed** |
| **17w** | **VisualWalk hardening** (minted 2026-09-28 at the 18l-c closeout — the round's harness finds, none product defects): (1) **a scenario must never TYPE after a failed keyboard-focus probe** — the `takes-find` full-suite failures typed "Hyde" into takemania's LIVE BLOCK when the ⌘F field's claim was refused, corrupting the dev store's fixture (eight literal prefixes found and healed by hand at the U8 acceptance walk; the poisoned store then failed every later run's count precondition REGARDLESS of build); the guard: probe-confirm the field holds the keyboard BEFORE `keystroke`, abort the scenario otherwise; (2) **fixture self-heal** — a scenario whose precondition reads a seeded note's content should restore the book (the product door) or re-seed on a failed precondition rather than inheriting corruption; (3) **the shared `vw_set_voice` adopts the probe-verify-and-retry** the `takes-find` chip press already uses (the AXPress return code lies both ways — U7 rows 10/11, the `074442`/Study-`091332` aborts on green passes); (4) **the `takes-find` order dependency's residue** — after (1)+(2), re-run the full seeded suite and re-attribute what remains (the store-poisoning mechanism explains the count preconditions; the ORIGINAL field-claim refusal after earlier scenarios is still untraced — possibly the arrival's born-live claim racing the bar's field focus under a warm session). Records: 18l-c U7 RECORD rows 10–11 + NOTICED 2/5/6, the U8 acceptance walk's mechanism note | **open** (runs at her word or beside the next VisualWalk-touching unit) |
| **17f** | **CLOSED 2026-08-31 — the pre-13u round's Act 5.** 8 of 9 items FIXED (each with its evidence class named: three red-on-old drills, two grep-verified dead-code removals, one hoist, one canon correction, one documented mechanism); **P50 DISMISSED AS HOLLOW by measurement** — the WAL it claimed was checkpointed away measures byte-identical before and after `lock()`. Per-item dispositions in the entry below | **closed** |
| **17c** | **CLOSED 2026-08-31 — the pre-13u round's Acts 3+4.** All 4 read-layer items (P18–P21) FIXED with revert-verified red-on-old pins (query plans and statement counts, never timings); the P20 index landed as its own schema commit and is NOT a §12 lockstep event (marker stays 7). Per-item dispositions with before/after numbers in the entry below; one residual (`container_block(block_id)`) re-routed to **12** in KnownIssues | **closed** |
| **17g** | **CLOSED 2026-08-30 — the `13p-fix` session** (author's live session of 2026-08-30: an issue she found testing the refreshed 13p install). That session owns this letter and writes its own entry; it does **not** fold into 17a. | **closed** |
| **17h** | **The custody riders 17a never listed** — opened at the author's word 2026-08-30 (the pre-13u sitting: "Open 17h, run it this round"). TWO items, both already traced in `KnownIssuesAndTechDebt.md` rows that carried owner "17a" without being in its 8-item list: **(1)** the `saveGated` delete-before-add window (13p-fix ladder R2-7 — a failed `SecItemAdd` after the forced delete leaves no custody; remedy sketch on the row: add under a temporary account → verify → swap → delete old, or an explicit accepted-window doc line); **(2)** the delete-status-discarded family (R3-5 — `deleteAuto`/`deleteGated` drop `OSStatus`, so the custody law binds writes only; remedy on the row: `Bool`-returning delete seams + refuse/report on failed release + a `deletesSucceed` knob pin; the riders travel with it: `E2EECustodyStorage.live` wiring coverage R3-4, `setMode`'s MainActor SecItem calls R3-6). The rows' mechanisms and remedies are the brief; runs as a small fresh Fable session inside the pre-13u round, after Act 9 closes. **CLOSED 2026-08-31** — both items FIXED (R2-7 as probe-first narrowing with the residual window recorded; R3-5 with all riders), every pin red-on-old by behavioral revert; the entry below is the record | **closed** |
| **17i** | **Sync across devices — the reconciliation probes, the scenario sweep, and the harness-realism fix** — opened at the author's word 2026-08-31 (the pre-13u round's tail): *"this is really hunting for bugs + discrepancies + issues in the implementation of sync across devices, so I think it's fine to have there… I want to have a more proper phase."* The brief is `notes/plans/pre-13u-memo-sync-disagreements.md` — the posture in five rules, the scenario table, and the UNSETTLED probes at its top (P1 delete-vs-edit-plus-new-take; P2 the purged-past-30-days + returner corner; P3 edit-vs-edit; P4 the production-round-shape sweep of every convergence suite). Structural item: the harness runs production's pull→push chunked round shape by DEFAULT. All `Sync/` — the standing Fable rider applies; pin before fix; a probe whose expected and actual agree is recorded, not "fixed". Not run inside the pre-13u round (her ruling). | **CLOSED 2026-09-22 — RUN B** (the hunt, the fixes incl. F-1/F-3, the harness deliverable; dispositions in the entry; the live-round leg PASSED at her 2026-09-22 morning round) |
| **17o** | **The 2026-09-06 use-report round's DEFECTS** — opened 2026-09-07 at her word (the fixes half of that round; its product half is 18c · 18d · 18e · 18f). Batches: **b** the landing family (every door into Write lands at the remembered caret offset; the fan panel's Takes landing scrolls; Blocks → Write scrolls) · **c** the Takes faces (the live pane honors the editing-indicator setting everywhere; the chosen bar the card's full height; "＋ new block" on an empty note; the pane's stale height after a big deletion) · **d** the chrome singles (the sidebar divider's grip; the Messages fill-code popover; the title LEADS from the path chip — supersedes Act 10 rows 4/19; the title faces' baseline; the sidebar headers' inset and air; the versions link on a blockless note MINTS the first block; the one-shot chrome titles become observations; the Index count ↔ ⋯ column; the tag field collapses; the divider's white top) · **e** the Snippets area (the card door opens the CARD's pool and lands on the block; the tag door findable) — **Opus only** on e, her word. **The record is the round's plan, `notes/plans/use-report-round-2026-09-06.md`** (ledger rows 6–21 · 27 · 38–42; §5.3); the dispositions block is copied here at the entry's close. Cast: `opus-implementer` (xhigh); `fable-reviewer` on batch b, `opus-reviewer` on c/d/e | **CLOSED 2026-09-08** — all 27 rows FIXED with pins (6–21 · 27 · 38–47), two ladders capped (b: Fable ×3; c/d/e: Opus ×3); the dispositions block in the entry below |
| **17p** | **The 2026-09-12 use-report round's DEFECTS** — opened 2026-09-12 at her word (the fixes half of that round; its product half is 18g · 18h · 18i). Batches: **a** the Takes board (the article scrolled its current block to the TOP on every entry — image 1; a per-note scroll memory + a reveal-only landing rule; the empty block's face and the ＋ new block door's alignment) · **b** the chrome singles (the tray's block rows gain Delete Now — the explainer promised it; the Callout Emoji alert's collapsed field; the comment badge and the callout emoji drawn OVER the text in the book Outline — a reserved left lane, the emoji inside the frame) · ~~**c** the phone's opening scroll~~ (RETIRED at the sitting — hers to run in a mobile session, standalone or with 13u; the `mobile` branch's handoff §12.2 carries it). **The record is the round's plan, `notes/plans/use-report-round-2026-09-12.md`** (ledger rows 1–7; §4.1–§4.4, §4.9; §5.1); the dispositions block is copied here at the entry's close. Cast: `opus-implementer` (xhigh); `fable-reviewer` on BOTH batches (b's decor lane reached the editor seam — the adjudication's J4) | **CLOSED 2026-09-12** — rows 1–6 FIXED with pins, row 7 RETIRED to the mobile session; two Fable ladders (a: three rounds to the cap; b: two); the dispositions block in the entry below |
| **17q** | **The 2026-09-12 use-report round's MORNING BUILDS + the 18h cap's residue** — opened 2026-09-13 at her word (the successor session's first act, before 18i). Items: **(1)** R-Q20 — J3 ruled *"the block I came from wins"*: when the Takes entry landing names a block, the landing wins and the remembered place is not restored (one condition in `TakesBoardLayout`'s restore/landing step + the 60-block remount pin's sibling) · **(2)** R-Q17 — QUESTIONS #103 ruled: the Library's Notes card shows the stated day AND the sort's stamp where there is room, the masthead's click-flip where small; with it R3-2 (the List row's raw `entry_date` slot through the one brain, never one day twice) · **(3)** the 18h ladder's cap residue (KnownIssues row "The 18h ladder's residue at the cap", owner 17q): R3-1 the synchronous selection clear on a mode change, and the seven NITs R3-4…R3-10. **The record is the round's plan, `notes/plans/use-report-round-2026-09-12.md`** (`### R-8 · 17q — BRIEF` / `RECORD`); the dispositions block is copied here at the entry's close. Cast: `opus-implementer` (xhigh); `fable-reviewer` (the Takes half is the landing family; cross-model flow) | **CLOSED 2026-09-13** — R-Q20/R-Q21, R-Q17 (+R3-2), R3-1 and R3-4…R3-10 all FIXED with pins; one Fable ladder to the cap (three rounds: 2 + 3 + 1 MAJOR, all fixed; the restore had never run in the app before this entry); the residue owned on KnownIssues row 54 (13u2); the dispositions block in the entry below |
| **17l** | pre-13x residuals (items 1–4, 6–7 + the phrase-transit rider) | **CLOSED 2026-09-21 — RUN A batch A2 + the run's ladder.** Items 1–4/6–7 FIXED/VERIFIED with pins (item 1 with ONE stated deviation: the purged_row consult is unbuildable on the ledger's own ids-only design — the per-book device mark shipped instead); the phrase-transit rider VERIFIED with its one found world fixed (KnownIssues 32 resolved); **item 5 DEFERRED → RUN B** (the `Sync/` fence; KnownIssues 41 re-owned). Dispositions in the entry below |
| **17m** | The Re-link-your-Apple-account door | **CLOSED 2026-09-21 — RUN A batch A3.** FIXED to the entry's spec via the F2 heal road behind consent (reads, never mints; every refusal leaves the vault's revision unmoved); `AppleRelinkDoorTests` (8); placement on the Protection pane PROVISIONAL (#139(a)); PL-37 for the phone's face. Disposition in the entry below |
| **17n** | The encryption passphrase's 12-character floor | **CLOSED 2026-09-21 — RUN A batch A2.** FIXED — the floor named once, two real gaps closed (the four `PassphraseSetModel.commit` door sites; sync setup's no-wrap arm), never at unlock (negative pins), walked live. Disposition in the entry below |
| **17r** | The stamp faces' midnight rollover tick (minted at the 13u4 closeout) | open — at her word only |
| **17s** | The drop-out returner's rescue — QUESTIONS #141 ruled (b)-eventually (minted 2026-09-21 at the RUN B kickoff sitting) | open — at her word only |
| **17x** | **The obsolete structural undo/redo's FALSE RECEIPT** — minted 2026-10-03 at the family-close sitting, her word at the question tool ("Open the 17 entry"); the KnownIssues row re-owned 12 → here. The defect (13i-d F-U6-2): a replay whose target died or moved wings does NOTHING (the standing silent-obsolete pattern) yet `UndoStack` returns the label either way and the bottom bar announces "Undid: …" — against §12's message-kind rule (a door that did nothing speaks a refusal). The row's own caution binds the shape: the fix is an undo-core DESIGN (the inverse must report whether it acted — many registrations), never a sweep's patch | **open** — at her word |
| **17y** | **THE 13i FAMILY FIX PASS** — minted 2026-10-03 mid-walk at her word ("this 13i fix pass that's going to have to happen"); items ACCUMULATE here as the combined walk proceeds. So far: **(a)** dragging a book from the Bookcase's UNSHELVED group onto a shelf does not work (her walk report; the U1 contract promised drop targets — "drop targets + drag reorder + Move to Start/End"); **(b)** under order ▾ = MY ORDER there is no visible way to reorder beyond Send to Top/Bottom — drag reorder is absent or undiscoverable even where P-13id-U1-13 promised "a book dropped on a row lands right above it"; her ask: drag bars (or an equivalent affordance) when my order is active; walk-note: few shelves existed, so the strip's drop targets were sparse — the mechanism trace decides built-and-broken vs never-built; **(c)** Duplicate as Version CARRIES TAGS — her ruling, same sitting, two beats: first "should probably carry the tags… doesn't have to be built right now", then mid-walk "let's just build [it] now — I think it's a bit sloppy to not have it"; Diverge STAYS tag-less (her lean: a diverged copy is meant to differ from what's already there); **(d)** the Library cards view renamed **"Cards"** (F-U6-5, her pick at the question tool; one string, 13s may re-voice); **(e)** the BOOK PANEL's drag handles render but drag-to-reorder does nothing (her walk screenshot, the Jekyll seeded book: four rows, handles drawn, no drag) — the U2 contract promised "drags over the existing ops with menu twins", so either the drag is built-and-broken or gated (trace: does `sort_field` ≠ manual gate it? is a finished-book refusal staying silent against U2-8's "refuse WITH the road"?); her stance either way: a handle that cannot drag must not render; **(f)** THE CROSS-WING WORKSPACE EXPERIENCE (her mid-walk direction, refining her same-sitting F-U5-6 keep — design-weight, final shape at the pass's own mini-sitting): an Open-list item from another wing needs (i) a visible wing indicator on its row, and (ii) clicking it and starting to edit should NAVIGATE the app to that wing — her lived confusion verbatim: "click on a note, then click on the library and the note isn't there. or star it and it doesn't appear in starred because you're still in a different wing"; at the very least "your left bar showing 'library' should reflect the wing you're editing in". **THE SHAPE RULED BY HER 2026-10-04 (the mid-walk follow-up, on the architect's proposal):** the wing switches on **OPEN** ("I said edit but I meant on open"), with the quiet "Now in X" receipt (agreed); under split panes the sidebar **FOLLOWS THE FOCUSED PANE'S NOTE on focus too** ("I don't think it makes much sense to me to not change on focus if we normally change on open") — the damping PROVISIONAL is RESOLVED: follow on focus. The standing frame: ONE app-wide wing stays the truth (U5-3); editors NEVER close on a wing switch (wings scope LISTINGS, not open editors — the Open list already proves cross-wing editors legal); plus the wing indicator on cross-wing Open rows. What remains at the pass is build detail, not shape; **(g)** THE RULE EDITOR'S TAG PICKERS grow up (her walk, the field-guide rule sheet): the "+ tag ▾" menus (the rule builder's terms AND the outflow chooser's) must let her CREATE A NEW TAG in place, and the flat dropdown must become SEARCHABLE — her words: "this is the exact sort of selector that looks really bad when you have a lot of different options — we should build for the need to search through tags now" (type-to-filter at minimum; scope at the pass whether every tag picker adopts it); **(h)** ARRIVALS DISCOVERABILITY + the one word (her lived confusion verbatim: "I also have no idea where arrivals are… I don't see it anywhere and I don't know where the item tagged happy went") — the intake WORKED exactly as designed (the #happy act belled; the dial said wait; the chip is rightly silent — an arrival is never worded as membership), but the answering surface is the unlabeled "▸ N at the door" line atop Index/Outline while the DIAL says "wait at Arrivals": one word must win across dial/line/chip/receipts, and the line needs more presence when N > 0 (the word itself, or a glyph). **HER PLACEMENT DIRECTION, the same walk ("I don't like it being there"):** the door line LEAVES the top of the editor/content area; her two candidates — (1) a little ICON in the book's mode-row area beside the settings gear, "calm when nothing is there and has presence when something is there" (her lead candidate and the architect's lean: the book's own chrome, presence-by-state, never below the fold; kin to 18l-c's `arrival_flash` spirit), or (2) at the navigator's bottom under + new chapter / + new note — the pass mocks both for her pick. AND the waiting rows must open: "you should be able to click on the note to see what it is — it's annoying that I don't have much info about it" — an arrival is a real live note, so the row opens it read-normal (opening never seats; only Add does); **(i)** the unsectioned header's word — the Outline says "unfiled" while the move menu says "No Chapter" (two words for one state; her report's confusion — she moved an already-chapterless note to No Chapter and read the no-op as a failure); one word wins, 13s may re-voice; **(j)** THE IN-NOTE INDEX SCROLL'S PERFORMANCE (her walk close, pre-existing — not this family's, fixed now at her word): "every scroll in this app works beautifully with no lag except for index scroll within a long note (not the book view, the in note view, though they probably have the same issue)… laggy, sometimes a quick scroll will send you straight to the top, just bad performance" — a P1/P3 violation on its face (scroll cost must be viewport-proportional; the quick-scroll-to-top smells like a height-estimate/jump-correction defect, the JumpPrimitive/read-tier family); the trace covers the note's index surface FIRST and checks whether the book Index shares the mechanism; **(k)** THE LIBRARY'S 40-NOTE WINDOW → INFINITE SCROLL — **A LAUNCH BLOCKER, her words: "the fact that the library only shows you the first 40 notes is completely unacceptable… we need an area in which people can scroll through ALL of their notes, that kind of access is literally what library is supposed to be. has to be fixed before launch even — otherwise people could literally lose their work basically."** The located mechanism: `LibraryCatalogModel.pageSize = 40` with no load-more firing on scroll; the KnownIssues "Bounded view windows show markers, not more" row carried this deferred (owner 12) — its LIBRARY leg re-owns HERE (the other windows — book view 300, folder 200, recovery 500 — stay with 12). The designed road exists: the schema's keyset sort keys `(stamp, id)` with matching indexes were built for exactly this pagination (AppSpec §7) — infinite scroll rides them, P1-clean, never a raised cap. **THE BAR, hers verbatim (2026-10-04): it "needs to be SMOOTH like the rest of the app — no performance losses are acceptable for it! including if it's in the notes view, which might have a different performance due to rendering differently" — BOTH Library views (List AND the cards view, "Cards" after item (d)) scroll at corpus scale with zero felt degradation; use-shaped evidence required (a live scroll walk on a large fixture + her feel at the close — pins alone cannot prove smoothness).** RIDER, same item, her words: on the "All" screen, "once books hit ~half of the vertical area, books start to scroll within their own little view, so that many books won't mean you see no notes" (the pass locates the exact surface her words name and caps the books region at ~half height with internal scroll). **(l)** CONTEXT-MENU PARITY FOR BOOK ROWS BEYOND THE BOOKCASE (her walk close, with the capture): "it's really weird that you get the menu of things to do when you two finger press on a note from within library, but don't get a book's options (maybe not all of them, like the move up and down, and the move to shelf, but at least the basic ones like star)" — the Bookcase row carries the full menu (her capture names it: Star · Move to Shelf/Wing · Send to Top/Bottom · Rename · Settings · Edit Rule · Bind · Make a Book · Exports · Archive · Delete Book); the pass ENUMERATES every surface that renders a book/gathering row outside the Bookcase (the Library's book rows, the sidebar's Starred section, any sibling — pickers aside) and gives each the book context menu TRIMMED of Bookcase-positional items where position means nothing there (her carve-out: Move Up/Down and Move to Shelf may drop; STAR at minimum, the sensible basics per the pass's proposal). **(m)** THE QUICK-NOTE BOX'S DOUBLE BLINKING CURSOR (her report, the 2026-10-04 evening planning sitting): the quick-capture note box blinks TWO cursors at once — her rule verbatim: "if the terminal cursor is blinking open at the end, your cursor shouldn't be blinking as well"; exactly ONE cursor blinks at a time (the Terminal voice's decorative block cursor wins while it is shown; the trace decides the suppression's mechanism and owner); **(n)** THE TITLE'S CHROME SHIFT, STILL (her report + her capture `notes/plans/17y-screens/title-chrome-shift.png`): "the chrome is still shifted up when you click on the title" — her "still" marks a survivor or regression of an earlier landing, so the trace FINDS the prior fix first and pins red-on-old against the mechanism, never the symptom; **(o)** THE ADD-NOTE-TO-BOOK PICKER grows SEARCH + A CREATE DOOR (her ask, same sitting; THE SHAPE RULED at the question tool the same evening — INLINE MINT): the picker gets type-to-filter search (item (g)'s idiom — one pattern across the pickers), and the search field doubles as the mint — a 'New book "X"' row mints a plain book in the current wing, adds the note as an ORDINARY membership (the ownership consult and the capacity gate run exactly as on every other add road, never bypassed) and speaks a quiet receipt; deeper setup (rule, shelf, trait) stays in Book Settings; **(p)** CANVAS GOES DEBUG-ONLY (her word, same sitting: "let's just do that now, in this run of things", debug-only ratified): Canvas leaves the note mode row in RELEASE builds (Debug keeps it — her tinkering surface continues); the ⌘1–⌘7 derivation shortens to the remaining modes (her explicit ok on ⌘7 no longer being Canvas); the pass enumerates Canvas's other doors (the palette, any settings face) and gates them the same way; **(q)** THE TUTORIAL-NOT-IN-THE-DEFAULT-LIBRARY TRACE (her report, same sitting — routed HERE at her word: "we can trace the bug before i install on the new mac tomorrow — that can be part of the next fix phase"): on her onboarding pass the field guide was NOT in the default library — it had to be RESTORED via Help ▸ Restore Tutorial… while everything else "was just there"; the trace runs EARLY (her Monday fresh-install + sign-in on the new Mac is the verification bed, so the mechanism should be in hand before it); the seeder is Sync-adjacent (`ensureWelcomeShelf`, `SampleLibraryDedupeFacts`) — the Fable review rule applies to that diff. Pin before fix binds per item; the cold-review rule per the diff's reach | **READY TO RUN — the list RE-CLOSED at a–q at her word (the 2026-10-04 evening planning sitting appended m–q; (o)'s shape ruled at the question tool); runs at her go. 19e AND 19g RUN FIRST (their reviews WAIVED at her word, same sitting) so this pass's finals read fully green** |
| **17z** | **THE DUPLICATE/VERSION-OF MARKING EXPLORATION** — minted 2026-10-03 mid-walk at her word, deliberately NOT a decision: *"we won't do duplicate tag and we won't add the chip FOR NOW, but make 17z an exploration of adding duplicate or version of tags and how that might look — it might be worth it, I just haven't decided right now and won't be deciding right now since it isn't a bug / critical issue."* The ground: `version_of` edges are the structural truth (Compare reads them); the architect's recorded lean against an AUTOMATIC tag (a second, weaker copy of edge-truth; tag application is an intake EVENT living books hear; a system tag seeds the per-wing vocabulary) with the alternatives sketched — a "version" mark in the badge family (the owned/shared marks' sibling, reading edges), a Library filter, and/or a rule TERM over the edge in the v2 grammar if duplicates should ever be GATHERABLE (grammar change = its own design event). The exploration's deliverable: options with faces mocked against the model, for HER ruling; zero build before it | **open** — exploration at her word; no decision pending |

**Why 13p-fix is 17g and not part of 17a.** 17a is the *sweep's* 13p residue — eight findings from a
review that read the code. 13p-fix is a *tested* defect she hit in the running app, with its own plan
file, KnownIssues updates and handoff already complete. They are the same subject and adjacent in
time, but they are different work with different provenance, and a completed entry should not be
retro-fitted into an unstarted one. **Her sequencing pairs them anyway:** 13p-fix runs first, then a
session that does 17a *and* cold-reviews 13p-fix.

**Sequencing note (author, 2026-08-30): 17a runs BEFORE 13y.** It is live on the real encrypted store,
needs no user action to fire, is small, and is 13p's own residue — running it now closes that phase
properly while the layer is warm. **13x depends on it** (P1 breaks the copied-library road that
"AirDrop your library" is built on).

---

# The entries

## Provenance of 17a–17f

These six were populated on 2026-08-30 from a **proactive whole-codebase tech-debt sweep** run at the
author's instruction immediately after Phase 13p closed: 18 independent cold review lenses over the
tree, partitioned by area and by lens, each finding then put to an adversarial verifier instructed to
**refute** it by opening the real code, defaulting to refuted under uncertainty and treating any
documented-and-owned tradeoff as refuted. **65 raw findings → 50 survived → 15 killed.** 49 of the 50
were new; one already had a KnownIssues row.

**The full artifact is `notes/ProactiveTechDebtReview-2026-08-30.md`** — it holds every finding's
verbatim code evidence, the verifier's own trace, and the 15 refutations (kept so a later sweep does
not re-find them). The P-numbers used throughout this file are that document's. **That document is a
dated snapshot and is not a tracking surface** — it is never edited to reflect progress; this file
and `KnownIssuesAndTechDebt.md` carry the live state.

**Seven further findings from the same sweep went to 13u1, not here** (P16, P17, P22, P24, P25, P40,
P41) — the editor-seam O(N²) family, the churn pair, and two forked brains — because 13u1's item 5
rewrites that exact seam and fixing them elsewhere would mean fixing them twice. Their record is the
fold section at the end of `notes/plans/phase-13u-feel-and-polish.md`.

| Entry | Subject | Items | Note |
|---|---|---|---|
| **17a** | The 13p residue — key custody, at-open modes & the re-lock teardown | 8 | **CLOSED 2026-08-30** (the pre-13u round's Act 9; all 8 FIXED) |
| **17b** | Doors that lose or mis-copy her text | 6 | — |
| **17c** | The read layer's P1 debt (query-side) | 4 | — |
| **17d** | Purge, sync & bridge honesty | 5 | **The `Sources/VariorumCore/Sync/` Fable rider binds P8, P9, P28 and P31.** |
| **17e** | Correctness & honesty singles | 10 | — |
| **17f** | Dead code, canon corrections & test pins that cannot fail | 9 | **CLOSED 2026-08-31** (the pre-13u round's Act 5; 8 FIXED, 1 dismissed as hollow) |

---

## 17a — The 13p residue — key custody, at-open modes & the re-lock teardown

**Status: CLOSED 2026-08-30 — the pre-13u round's Act 9 (Fable custody batch,
commits `270bf4f…d6a4911` on `main`).** All 8 items **FIXED**, each with a
red-on-old pin verified by a faithful behavioral revert (the drill red
reproduced the traced end state in every case — the both-Keychain-items-deleted
library for P2, the tail-in-no-row loss for P3, the full 64-hex key on the
error channel for P15). The batch record is the **ACT 9 BATCH RECORD** section
of `notes/plans/pre-13u-round.md`; suite counts and environment notes live
there.

### Dispositions (per item)

| item | verdict | pin(s) | notes |
|---|---|---|---|
| **P1** | **FIXED** | `Phase13pControllerTests.reconcileNeverOverwritesAnUnreadableSidecar` | ONE seam: `StoreLaunchGate.readEnvelope` (absent / loaded / UNREADABLE); `ensuredEnvelope` THROWS on unreadable — foreign is a move, unreadable is a refusal, only true absence mints. The launch reconcile can no longer overwrite an unreadable sidecar or orphan the escrow item; the nudge stays quiet over unknown facts. |
| **P2** | **FIXED** | `…aModeChangeAuthorizesFromTheDiskNotTheCachedProjection` | `setMode`'s demanded-arm authorization is a FRESH disk read at the act (the `deleteBlock` in-transaction-precondition doctrine); the two invalidating doors (`setEscrow`, reconcile's escrow arm) refresh the projection as a belt. The old red reproduced the catastrophe: auto item nil, mode persisted. |
| **P3** | **FIXED** | `MacWillLockTests` (2 pins) | `macWillLock` factory (the `mobileWillLock` twin), wired in `VariorumApp`: the active editor's full `finalizeWork` (tail crystallized, pending cross-block compound landed) runs BEFORE the registry and the services stop. Recorded corner: only the ACTIVE editor gets the full finalize — identical to the quit door it mirrors; widening both is a design act. |
| **P10** | **FIXED** | `…aRecoveryWrapLandedDuringTheKDFSurvivesSetPassphrase` | `setPassphrase` derives the wrap FIRST (envelope-free, off-main — `StoreKeyEnvelope.makePassphraseWrap`/`adoptPassphraseWrap`, format guard kept) and reads the envelope FRESH after the derivation; every MainActor envelope writer is now an awaitless read→write, so the window is closed structurally, not narrowed. The pin's `makeKDF` hook stands in for the concurrent land deterministically. |
| **P11** | **FIXED** | `…setPassphraseRefusesOverAnUnreadableSidecarInsteadOfOverwritingIt` · `Phase13pLobbyTests.anUnreadableSidecarLobbySaysTheTrueCauseNeverTheAbsentOne` | Every envelope-writing door refuses with the true (unreadable) sentence; the lobby's ONE `deadEndMessage` brain serves both platforms' faces. Recorded corners, deliberately unchanged: `failedOutcome` stays doorless on unreadable (widening that surface is design); `verifyPassphraseAgainstStore` answers nil on unreadable (a third guard answer is design) — doc'd at the site, harmless since every write door refuses regardless. |
| **P12** | **FIXED** | `KeyedStoreTests.aPresentButUnreadableStoreClassifiesAsUnknownNeverAbsent` | `classify`: present-but-unreadable ⇒ `.encryptedOrUnknown` (nil-at-EOF distinguished from a throwing read; empty-file-as-absent pinned deliberate). No persisted mode downgrade; all classify consumers audited unchanged. |
| **P13** | **FIXED** | `KeyedStoreTests.openStoreNeverMintsOverAPresentButUnreadableStore` | The never-mint refusal fires TYPED (`keyUnavailable`) for unreadable stores — the recovery road can render; nothing lands in custody (the old red reproduced the untyped "SQLite error 14" + minted-custody dead end). Rider: `routeAndOpen`'s nil-URL `?? .absent` → `?? .encryptedOrUnknown` — recorded as unpinnable without refactoring the private URL resolution into a seam. |
| **P15** | **FIXED** | `StoreEncryptionMigrationTests.aFailedAttachNeverCarriesTheKeyHexInAnyErrorChannel` · `…redactionScrubsEveryOccurrenceOnBothChannels` | Catch-and-sanitize at BOTH key-bearing statements (`StoreKey.redactedDescription(of:)`; `RedactedKeyedStatementError` covers `localizedDescription` too, so the backup-log channel is closed at origin). The PRAGMA site is pinned pure only — that statement's failure is not drivable (SQLCipher defers key validation to the first page read); recorded, not skipped. |

**The two KnownIssues rows that carried owner "17a" without being in this
entry's item list** (the `saveGated` delete-before-add window, R2-7; the
delete-status-discarded family, R3-5): **RE-ROUTED to 17h** — opened at the
author's word at the pre-13u sitting; their rows in
`KnownIssuesAndTechDebt.md` now name 17h. Not resolved here, not orphaned.

**Landed WITH the batch (the same subsystem, the same commits):** the Act 1
review's routed findings F1 (the state-dependent custody pin, fully faked),
F4 (the `KeychainTestTripwire` — the R3-1 rule made structural), F5 (the fact
suite's header), F6 (the E2EE arm's own `wroteButUnreadable` sentence); the
R-pre13u-2 CF-12 rework (sync gate opt-in, default off, legacy gates reset);
the R-pre13u-3 #82 build (the store key device-bound via the TN3137
migration); and the R-pre13u-4/5 detection half (the `ProtectionLegs` nudge
brain + the VERIFIED-LANDED escrow observable and its Console evidence line).
Their records ride the batch record, not this entry.

*(The original 8-item briefs below are kept verbatim as the entry's record —
the finder claims, the verifier traces, and the provenance note.)*

Eight findings, and **six of them are one root cause**: `StoreKeyEnvelope.load` and
`StoreFilePresence.classify` throw typed errors that exist *precisely* to distinguish a corrupt or
unreadable file from an absent one — and every production consumer discards that distinction with
`try?`. `StoreKeyEnvelope.swift:201` states the rule about itself in a doc comment forty lines from
the code that breaks it.

**Why this is first, and why it is not merely a review finding.** These roads are live on the real
encrypted store migrated at 13p's overnight, on the machine she writes on daily. P1 needs no user
action at all: the escrow reconcile fires on every ready launch, escrow defaults ON, and the write is
an unconditional `.atomic` replace whose failure is itself swallowed by `try?`. The thing destroyed is
the **recovery phrase** — the insurance that made adopting whole-store encryption safe in the first
place. P3 is a different mechanism in the same phase's work: 13p's automatic re-lock never calls
`finalizeWork()`, so the open tail (the paragraph being typed, not yet crystallized into a block) is
dropped when the app re-locks itself.

**Two forward dependencies make deferring this actively expensive.** **13x** ("AirDrop your library")
is built directly on P1's road — a copied library folder with an incomplete sidecar *is* the promise —
so shipping 13x over this means fixing it twice. **13r** ships opt-in crash reporting, which is a
plausible new exfiltration path for P15 (the raw 256-bit store key reaching a GRDB error description)
that does not exist today.

**One honesty temper, carried from the verifier and not to be dropped when this is scoped:** for P1
the strict *destruction* case is a transient read failure (an I/O error, a permissions blip, a
concurrent replace by a backup tool). Where the sidecar is genuinely corrupt, its wraps were already
unusable, and restoring it from a backup folder still heals afterwards. What fires in **both** cases
is the false dead-end (the lobby asserting "no passphrase or recovery phrase is on file" over a
library where the file is present) and the orphaned escrow item. That is still a silent, launch-time,
no-action-required regression on the credential-insurance layer — it is simply not the case that
every instance destroys a good key.

### Items

#### P1. An unreadable variorum-keys.json is read as absent, so the next launch silently overwrites it with an empty envelope — destroying the passphrase and recovery-phrase wraps

`App/Variorum/Shared/ProtectionController.swift:159` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.85

StoreKeyEnvelope.load throws a typed `unreadable` specifically so corruption is never read as absence, but both consumers discard it with `(try? gate.loadEnvelope(...)) ?? nil` (ProtectionController.swift:159, AppBootstrap.swift:438). `ensuredEnvelope` (ProtectionController.swift:161-169) therefore cannot tell 'no file' from 'unreadable file', and only the FOREIGN branch gets the protective `setAsideEnvelope` move — the unreadable case falls through to `return (StoreKeyEnvelope(), false)`. Concrete path, no user action needed: a zero-byte or truncated sidecar (the ordinary artifact of an interrupted copy of the library folder, a half-finished restore from a backup folder, or a transient read error) decodes as `unreadable` because fileExists is true, Data(contentsOf:) succeeds and JSONDecoder throws. AppBootstrap.finish fires `protection.reconcile()` on every ready launch (AppBootstrap.swift:351-353); with the escrow dial ON, reconcileEscrowOffMain (ProtectionController.swift:488-493) calls ensuredEnvelope, sees `!ensured.onDisk`, and runs `try? gate.saveEnvelope(envelope, ...)` -> StoreLaunchGate.live's `try $0.write(at:)` -> `data.write(to: url, options: .atomic)` (StoreKeyEnvelope.swift:221), an unconditional replace. The fresh envelope carries a NEW random storeID, so `guardSeam.loadEscrow(envelope.storeID) != key` is true and a new iCloud escrow item is written, orphaning the old one. After one launch the passphrase wrap and recovery wrap are gone, the twelve words the user wrote down open nothing, and the `try?` even discards a write failure. Two further roads reach the same replace: refreshEnvelopeFacts (:124-128) sets hasPassphraseWrap/hasRecoveryWrap false from the swallowed nil, so resetPassphrase refuses with 'No passphrase is set yet — use Set a Passphrase instead' (:229) and StandardNudgePolicy (:529) raises the set-a-passphrase nudge — both steering into setPassphrase -> ensuredEnvelope -> saveEnvelope. Third consequence at launch under a demanded mode: passphraseOffered/recoveryOffered come from the same swallowed nil, so StoreLobby.noRoadExists (StoreLaunchGate.swift:172) is true and StoreLockView renders `deadEnd` (StoreLockView.swift:40-43) asserting a false cause — 'no passphrase or recovery phrase is on file beside the library' (StoreProtection.swift:452-457) — over a library where the file is present.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in the real source. StoreKeyEnvelope.load (Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:201-211) throws .unreadable for a file that exists but will not decode, with the doc comment stating exactly why absence must not be inferred; the 13p plan file (line 1481) repeats the design promise verbatim ("a corrupt sidecar THROWS (never reads as 'no passphrase')"). Both consumers then discard it: ProtectionController.swift:159 `(try? gate.loadEnvelope(...)) ?? nil` and AppBootstrap.swift:438. ensuredEnvelope (ProtectionController.swift:162-170) is exactly as quoted — the setAsideEnvelope move fires only on the FOREIGN branch; nil (which now means absent-or-unreadable) falls through to `return (StoreKeyEnvelope(), false)` with a fresh random storeID (StoreKeyEnvelope.init default `UUID().uuidString.lowercased()`). The overwrite road is live and default-on: escrowOn defaults true (StoreProtection.swift:49, and :115 reads the inverted `escrowOff` key so an unset default reads ON); AppBootstrap.finish schedules `protection.reconcile()` on every non-test ready launch (AppBootstrap.swift:351-353); reconcile's escrow arm (ProtectionController.swift:486-493) takes `residentKey ?? guardSeam.loadAuto()` — satisfied under the default Auto mode — then `if !ensured.onDisk { try? gate.saveEnvelope(...) }`, whose live implementation is `try $0.write(at: ...)` → `data.write(to: url, options: .atomic)` (StoreLaunchGate.swift:46, StoreKeyEnvelope.swift:219-221), an unconditional replace of the existing file. `loadEscrow(newStoreID) != key` is then necessarily true, so a second escrow item lands and the old one is orphaned. I looked for the refutations and none holds: no caller anywhere sets aside on unreadable (setAsideEnvelope has exactly one production call site, the foreign branch); no test pins this behavior (every controller/lobby test drives StoreLaunchGate.scripted, whose loadEnvelope closure cannot throw, so the unreadable case is entirely unexercised); nothing in notes/ or KnownIssuesAndTechDebt.md records it as an accepted consequence; and AppBootstrap's own comment ("tolerant of an unreadable sidecar (the lobby's roads re-load and WORD that refusal)") is only deliberate for the FACTS road, not for the controller's write road — and even there it is defeated when both offers read false and StoreLobby.noRoadExists renders ProtectionCopy.deadEnd's false cause over a present file, while the correct .unreadable sentence (StoreProtection.swift:477-484) stays unreachable because no door renders to trigger a re-load. One honest temper on impact: when the file is genuinely corrupt its wraps were already unusable, and restoring the sidecar from a backup folder still heals afterwards (the fingerprint match makes it belong again) — the strict destruction case is a transient read failure (I/O error, permissions, a concurrent replace by a backup/sync tool), where good recovery legs are replaced with no message and `try?` even swallows a failed write. That still violates two rules the file states about itself, silently, at launch, on the credential-insurance layer.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P1.

#### P2. Entering a demanded at-open mode is authorized by a cached `hasPassphraseWrap` projection that two doors invalidate without refreshing, so the mode transition can delete both Keychain items over a wrap-less envelope

`App/Variorum/Shared/ProtectionController.swift:311` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.82

`hasPassphraseWrap` is written ONLY by `refreshEnvelopeFacts()` (:124). Two doors call `ensuredEnvelope(for:)`, which SETS ASIDE a foreign sidecar and writes a fresh WRAP-LESS envelope, and neither refreshes afterwards: `setEscrow(true)` (:354-393, ensuredEnvelope at :360) and `reconcile()`'s escrow arm (refresh at :452, ensuredEnvelope at :488, no re-refresh). Concrete road, all through app doors: (1) a demanded mode over a store whose file is gone/unreadable takes `.openResettingModeToAuto` (AppBootstrap.swift:228-236), which mints a NEW store key — the old `variorum-keys.json` is now FOREIGN (fingerprint mismatch); (2) `init`'s `refreshEnvelopeFacts()` reads that foreign envelope, so `hasPassphraseWrap = true`; (3) `reconcile()` (escrow ON is the Standard default) sets the foreign sidecar aside and writes a fresh envelope with NO passphrase and NO recovery wrap, leaving the stale `true` in place — ProtectionPane.swift:353 now renders "Passphrase — Set" over a library that has none; (4) the user picks "Ask for the passphrase": `setMode` passes the stale guard at :311 and runs `guardSeam.deleteAuto()` / `deleteGated()` (:333-334), keeping `residentKey` so the session still works; (5) next launch routes to `.lobby(demand: .passphrase)` with passphraseOffered=false, recoveryOffered=false, biometryOffered=false → `StoreLobby.noRoadExists`. No copy of that store key exists anywhere (the set-aside `variorum-keys.stale-*.json` wraps the PREVIOUS key). The library is permanently unopenable. `setEscrow(true)` over a foreign sidecar reaches the same end state in two clicks. `applyPreset` reads the same stale field at :400.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced in full. `hasPassphraseWrap` is written only at ProtectionController.swift:97 (init) and :452 (reconcile), both via `refreshEnvelopeFacts()`; grep confirms no other writer and no caller elsewhere in either app. `reconcile()` refreshes at :452 and THEN runs the escrow arm at :467-472, whose `reconcileEscrowOffMain` (:485-500) calls `ensuredEnvelope(for:)` — which at :162-166 sets a non-belonging sidecar aside and returns a fresh empty envelope, saved to disk at :490-493 — with no refresh afterwards. `setEscrow(true)` (:354-372) has the same shape and also never refreshes. `setMode`'s only authorization for the irreversible `deleteAuto()`/`deleteGated()` pair (:333-334) is `guard hasPassphraseWrap` at :311, and `applyPreset` reads the same field at :400. The pane never refreshes either (ProtectionPane.swift has no refresh call), so the stale `true` renders as "Passphrase — Set" at :353 and passes the guard. End state verified: StoreLaunchRoute.resolve returns `.lobby(demand:)` for a present store under a demanded mode, `makeLobby` computes passphraseOffered/recoveryOffered from the (now empty) envelope, and `StoreLobby.noRoadExists` is true — the very state StoreProtection.swift:441-445 asserts is "practically unreachable through the app's own doors." CORRECTIONS to the reviewer's road, which narrow it: (a) `reconcile` runs only from `finish(.ready)` (AppBootstrap.swift:352), so a foreign sidecar can only meet it over a store that OPENED — which in practice means the `.openResettingModeToAuto` fresh mint (AppBootstrap.swift:228-236) or a hand-copied wrong sidecar, not an ordinary restore; (b) the set-aside arm requires `dials.escrowOn == true`, and the Locked-down preset (the usual route into a demanded mode) sets escrowOn FALSE, so the compound needs hand-adjusted dials or the Standard default carried forward. Real and unrecoverable when it fires, but a compound of three preconditions rather than a common road — hence MAJOR, not BLOCKER.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P2.

#### P3. The Mac's automatic re-lock never runs `finalizeWork()`, so open-tail text and a pending cross-block compound are dropped and the pool closes under the late teardown

`App/Variorum/Variorum/VariorumApp.swift:81` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.75

`onWillLock` runs only `session.quitFinalize.finalizeAll()` + `services.stop()`. `quitFinalize` holds one closure per open post (AppSession.swift:183) running `savepointOnLeaving`, which is only `flushExistingAutosave` + `closeAutoCommit` (AppSession.swift:378-384). The OPEN TAIL has no variant, so the AutosaveCoordinator holds nothing for it and neither line can reach it. The quit door runs BOTH halves (VariorumAppDelegate.swift:58-65) because `EditorViewModel.finalizeWork()` is the only thing that awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail through `CrystallizationPlanner` + `ops.newBlock`. `finalizeWork` has exactly three callers — the quit door, `teardown()` (fire-and-forget from `.onDisappear`, EditorView.swift:107), and the seal road — and the lock road reaches none. `AppBootstrap.lock():404-427` then sets `state = .locked(...)` and immediately `await Task.detached { binding.lock() }.value`, closing the pool; the `.onDisappear` teardown fires only on the next render pass and its `runner.run { ops.newBlock(...) }` races that close, throwing `StoreLockedError` at `AppDatabase.currentWriter()` onto a view that no longer exists. Concrete: with `relockOnSleepAndScreenLock` on, type a paragraph at the end of a note (in `one_block` segmentation the whole entry is the open tail) and hit ⌃⌘Q or close the lid inside `tailIdleDebounce = .seconds(2)` — the text is on screen, in no row, and the lobby replaces the view.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end and the asymmetry is exactly as claimed. VariorumApp.swift:81-85 wires `onWillLock` to `quitFinalize.finalizeAll()` + `services.stop()` only; the quit door (VariorumAppDelegate.swift:53-68) additionally awaits `session?.editorRouter.active?.finalizeWork()`. The registry's closure is `savepointOnLeaving` (AppSession.swift:367-384) = `flushExistingAutosave` + `closeAutoCommit` — neither can reach the open tail, which has no variant and therefore nothing in the AutosaveCoordinator. Only `finalizeWork` (EditorViewModel.swift:531-587) awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail via CrystallizationPlanner + `ops.newBlock`. `finalizeWork` is called only from the quit door, `teardown()` (EditorView.swift:107 `.onDisappear { model.teardown() }` — result discarded), and the seal road; `onWillLock` is wired in exactly two places (Mac + phone) and the Mac's is the one without it. AppBootstrap.lock():404-427 then flips `state = .locked` and awaits a detached `binding.lock()`, which nils and closes the writer (StoreBinding.swift:89-102), so the late `.onDisappear` teardown genuinely races the pool close. The phone's twin is the mirror image: mobileWillLock (MobileRelock.swift:90-106) calls `editors.flushAll()` → `MobileEditorViewModel.finish()` (:461-473) which mints the tail — under a comment claiming it mirrors the Mac's closure. One factual nit in the finding: Lock Now is ⌃⌘L (EditorCommands.swift:305-308), not ⌃⌘Q — but ⌃⌘Q is the system screen-lock chord and reaches the same road through the `com.apple.screenIsLocked` observer (ProtectionController.swift:628,654) when relockOnSleepAndScreenLock is on. Severity kept MAJOR: real loss of the paragraph on screen on a deliberate leaving road, no filesystem anomaly required; not BLOCKER because it needs a demanded mode and the ~2 s tailIdleDebounce window.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P3.

#### P10. ProtectionController.setPassphrase writes a stale envelope over a recovery wrap landed during its KDF — the shown twelve words stop opening the library

`App/Variorum/Shared/ProtectionController.swift:177` · **MINOR** · CONFIRMED · data-loss · finder confidence 0.55

`setPassphrase` reads the whole envelope from disk at :180, suspends in the detached Argon2id derivation at :183 (hundreds of ms by construction), then writes the WHOLE file back at :189 with no version/fingerprint check. `generateAndLandRecoveryPhrase` (:258-275) has NO await between its own read (:265) and write (:267), so it completes entirely inside that window. Reachable across two windows over the ONE controller: `ProtectionNoticeBar` is mounted on the MAIN window (VariorumApp.swift:104-106) over `bootstrap.protection`, while the set sheet is presented in the SETTINGS window, and a macOS `.sheet` is window-modal, so the main window's nudge bar stays clickable. Trace: (1) Settings set-sheet, tap Set — reads envelope E0 (no wraps), suspends in the KDF; (2) main-window nudge bar → "take the recovery phrase" (ProtectionPane.swift:565-578 → PhraseOffer.take → generateAndLandRecoveryPhrase) reads E0, writes E1 = E0 + recoveryWrap, and the twelve words are displayed via PhraseOnlySheet for the user to write down; (3) the KDF returns and line 189 writes E2 = E0 + passphraseWrap — E1 is overwritten and the recovery wrap is gone from disk.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified exactly as quoted. ProtectionController.swift:177-190: `var envelope = ensuredEnvelope(for: key).envelope` is read BEFORE `try await Task.detached { ... setPassphraseWrap ... }.value`, then `try saveEnvelope(envelope)` writes the WHOLE envelope back. `saveEnvelope` (:134-137) is a straight `gate.saveEnvelope(...)` — no merge, no version/fingerprint check, no reload. `generateAndLandRecoveryPhrase` (:258-275) reads and writes with zero awaits between, so it completes atomically inside that window and is then clobbered. Reachability verified rather than assumed: VariorumApp.swift:104-106 mounts `ProtectionNoticeBar(controller: bootstrap.protection)` on the MAIN window and :239-243 hands the SAME `bootstrap.protection` to the Settings window's pane, and the pane presents its own set sheet at ProtectionPane.swift:185 — a macOS sheet is window-modal, so the main window's nudge stays clickable. The nudge's phrase button (ProtectionPane.swift:565-578) routes through `PhraseOffer.take` (PassphraseSetModel.swift:262-273) straight into `generateAndLandRecoveryPhrase`, and neither road consults `controller.busy`. Nothing in the file, CLAUDE.md, or notes/ documents a single-writer assumption for the envelope. Two things keep this MINOR and no higher, both of which the finding states honestly: the window is one Argon2id derivation (~hundreds of ms), and it needs a deliberate click in the OTHER window inside it — a same-window nudge cannot do it, because the notice bar hosts both sheets itself and is covered while either is up.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P10.

#### P11. Both production readers of the key sidecar discard `StoreKeyEnvelopeError.unreadable`, so the lobby dead-ends with a false cause and the set-screen then overwrites the recovery wrap

`App/Variorum/Shared/AppBootstrap.swift:438` · **MINOR** · CONFIRMED · crypto · finder confidence 0.85

`StoreKeyEnvelope.load` deliberately throws `.unreadable` for a file that exists but cannot be decoded, and its own doc states why: "reading corruption as absence would let a surface claim 'no passphrase is set' over a library that has one." Both callers do exactly that with `(try? gate.loadEnvelope(url)) ?? nil`. (a) AppBootstrap.swift:239-245 and the re-lock's lock() at :414-420 build LobbyFacts from the nil, so `passphraseOffered`/`recoveryOffered` are false; with `demand == .passphrase` nothing is offered, `StoreLobby.noRoadExists` is true, and the surface renders `ProtectionCopy.deadEnd` — "no passphrase or recovery phrase is on file beside the library" — over a sidecar that holds both. The correct sentence for this exact case already exists at StoreProtection.swift:476-483 and is unreachable at the lobby. (b) ProtectionController.ensuredEnvelope:165-169 returns a BLANK `StoreKeyEnvelope()` on the nil; `setPassphrase`:180-189 wraps the key into that blank and `saveEnvelope` writes it with `options: .atomic` (StoreKeyEnvelope.swift:221), overwriting the file on disk — so the `recovery` blob (her twelve written-down words) and the `storeID` that names the iCloud escrow item are destroyed with no word said. A FOREIGN sidecar is carefully MOVED aside (`setAsideEnvelope`, line 167) precisely so its wraps survive; an UNREADABLE one is obliterated.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified verbatim. StoreKeyEnvelope.load (:201-212) throws `.unreadable` for an existing-but-undecodable file with the exact doc the finding quotes, and BOTH production readers discard it: AppBootstrap's `loadedEnvelope` (:433-439) and ProtectionController's nonisolated `loadEnvelope` (:157-160), both `(try? gate.loadEnvelope(...)) ?? nil`. (a) The lobby facts built from that nil give passphraseOffered=false/recoveryOffered=false; under `.passphrase` demand biometryOffered is false by construction, so `noRoadExists` (StoreLaunchGate.swift:172) is true and StoreLockView.swift:40 renders `deadEnd`, whose passphrase arm says "no passphrase or recovery phrase is on file beside the library" — a false cause over a sidecar that has both. The correct sentence does exist unreachable at ProtectionCopy.message(for:) :476-483. The `loadedEnvelope` doc's justification ("the lobby's roads re-load and WORD that refusal") is true only when a road renders — StoreLaunchGate.envelopeRoad:268 does propagate and word it — so it is a documented ASSUMPTION that fails in exactly this case, not a documented tradeoff. (b) ensuredEnvelope (:162-170) returns a blank `StoreKeyEnvelope()` on the nil (no setAside, because nil never enters the foreign branch), and setPassphrase (:180-189) writes it through `write(at:)`/`.atomic` (StoreKeyEnvelope.swift:216-221) — an atomic rename over a file the app could not read but the directory lets it replace. Worse than the finding says: reconcileEscrowOffMain (:487-493) does the same `try? gate.saveEnvelope` automatically at every reconcile when the escrow dial is ON. The FOREIGN/UNREADABLE asymmetry the finding names is real (setAside is a move, never a delete). One correction: a NEWER-format envelope decodes fine (formatVersion is a plain Codable field; requireCurrentFormat only guards wrap/unwrap), so `.unreadable` means corruption or an IO/permission failure — which is why severity comes down: the destroyed wraps are only recoverable in the transiently-unreadable-but-intact case.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P11.

#### P12. `StoreFilePresence.classify` reports an existing-but-unreadable store as `.absent`, silently downgrading the persisted at-open mode to Auto and authorizing a fresh key mint over an encrypted store

`Sources/VariorumCore/Persistence/StoreKey.swift:244` · **MINOR** · CONFIRMED · correctness · finder confidence 0.75

`classify` has no `fileExists` check: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }`, so a present, ciphertext-filled store that cannot be opened or read (EACCES/EBUSY/EIO; also a zero-length file after a failed copy) answers `.absent`. `routeAndOpen` additionally maps a failed `defaultStoreURL()` to `.absent` (`storeURL.map(StoreFilePresence.classify(at:)) ?? .absent`, AppBootstrap.swift:222-224). Two irreversible things key off that answer: (1) `StoreLaunchRoute.resolve` returns `.openResettingModeToAuto` and `routeAndOpen` PERSISTS the downgrade — `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` (AppBootstrap.swift:233-235) — so a transient I/O error permanently drops the user out of Locked-down; (2) `resolveStoreKey` re-classifies, sees `.absent` with empty custody (the demanded modes deleted both Keychain items) and takes the MINT branch, saving a brand-new key as the Auto item (AppDatabase+Dependency.swift:136-144). The subsequent `AppDatabase.onDisk` then fails to decrypt the real file, and because that failure is not the typed `keyUnavailable` refusal, `failedOutcome` returns `.failed(error, recovery: nil)` (AppBootstrap.swift:278) — a doorless screen despite a wraps-bearing sidecar sitting beside the store. The bogus key is now persisted, so once the I/O condition clears, every later launch repeats the same doorless failure: `custody.load()` returns it, `resolveStoreKey` returns it unconditionally, the open fails again with `keyUnavailable == false`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Code checks out exactly as quoted. StoreKey.swift:243-249: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }` — there is no `fileExists` check, so a present ciphertext store that cannot be opened for reading answers `.absent`. `StoreFilePresence`'s own doc (:225-226) says `.absent` means "No file (or an empty one)" — the unreadable case is undocumented, unlike the deleted-store case, which IS deliberate and documented (StoreLaunchGate.swift:129-138 and AppBootstrap.swift:228-236 both record it as PROVISIONAL). Both consequences trace: (1) `routeAndOpen` persists the downgrade via `gate.saveDials(dials, scope)` at :235; (2) `openStore` re-classifies at AppDatabase+Dependency.swift:98 and `resolveStoreKey` (:123-143) skips the `keyUnavailable` refusal, mints, and `custody.save(minted)` persists the bogus key — after which the subsequent `AppDatabase.onDisk` failure is NOT typed `keyUnavailable`, so `failedOutcome` (AppBootstrap.swift:278) returns `recovery: nil` and the wraps-bearing sidecar beside the store is never offered, permanently, on every later launch. SEVERITY CORRECTED DOWN to MINOR: the trigger requires a store file that is present, non-empty, and unreadable via FileHandle (broken ownership/permissions after a hand restore is the plausible instance) — narrow. Note the sharp edge is the persisted mint, not the mode downgrade: it converts a recoverable state into a doorless one that survives the I/O condition clearing.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P12.

#### P13. StoreFilePresence.classify reports an unreadable store file as `.absent`, disabling the at-open gate and defeating the never-mint-over-ciphertext refusal

`Sources/VariorumCore/Persistence/StoreKey.swift:244` · **MINOR** · CONFIRMED · crypto · finder confidence 0.70

`classify` maps every FileHandle open/read failure (EACCES, EMFILE on fd exhaustion, EIO, an unsatisfied iOS data-protection class) onto `.absent`, which is indistinguishable from "no store here". Two consumers treat `.absent` as authorization. (a) AppBootstrap.swift:222-224 feeds it to `StoreLaunchRoute.resolve`, whose `guard presence != .absent else { return .openResettingModeToAuto }` (StoreLaunchGate.swift:143) makes AppBootstrap.swift:228-235 **persist** `dials.mode = .auto` via `gate.saveDials` — one unreadable moment permanently turns off her Biometric/Passphrase-at-open gate with nothing said. (`storeURL == nil`, i.e. `defaultStoreURL()` throwing, reaches the same `?? .absent` and the same persisted downgrade.) (b) AppDatabase+Dependency.swift:125-145 skips its `presence == .encryptedOrUnknown` refusal, mints a fresh StoreKey and SAVES it into the Keychain before `AppDatabase.onDisk` fails against the real ciphertext with a generic SQLCipher error (`keyUnavailable == false`). Passphrase mode deletes both Keychain items by design (ProtectionController.swift:330-333), so "encrypted store + empty custody" is its normal steady state — precisely where this fires. On the next launch `custody.load()` returns the bogus key at line 128, `presence` is never consulted again, and AppBootstrap.failedOutcome's `guard error.keyUnavailable` (line 275) can never build the sidecar-unlock recovery road: a doorless dead end over a library whose variorum-keys.json is right beside it.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced both consumers in real source (the only two non-test call sites). StoreKey.swift:243-249 does map every FileHandle-open/read failure to `.absent`, and the enum's own doc only claims `.absent` means "No file (or an empty one)". (a) AppBootstrap.swift:220-235 feeds it to StoreLaunchRoute.resolve (StoreLaunchGate.swift:139-143: `guard presence != .absent else { return .openResettingModeToAuto }`) and that case does `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` — a persisted downgrade of the R13p-5 gate with no sentence at the moment it happens. `storeURL == nil` reaches the same `?? .absent`. (b) AppDatabase+Dependency.swift:124-146 is exactly as quoted: `custody.load()` first, then the `presence == .encryptedOrUnknown` refusal (keyUnavailable: true), then mint + `custody.save`. And ProtectionController.setMode (:331-333) does delete BOTH Keychain items under `.passphrase`, so encrypted-store-with-empty-custody is that mode's steady state — the exact state where the mint fires. Once a bogus key is in custody, `custody.load()` short-circuits before presence is consulted again and AppBootstrap.failedOutcome (:275) requires `error.keyUnavailable`, so the sidecar-recovery road can no longer be built: the dead end is real. Nothing in the 13p plan or the code documents the absent/unreadable conflation (grep for 'classify' in the plan file returns nothing). Severity corrected DOWN: every leg is real, but the trigger is a filesystem/IO anomaly (EACCES after an oddly-permissioned restore, fd exhaustion, an iOS pre-first-unlock background launch under completeUntilFirstUserAuthentication), not an ordinary user road — real but narrow.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P13.

#### P15. The raw 256-bit store key is embedded in SQL statement text, and GRDB puts the executed SQL into every error description — a failure renders the key on the store-failure screen and can persist it into UserDefaults

`Sources/VariorumCore/Persistence/AppDatabase.swift:116` · **MINOR** · CONFIRMED · crypto · finder confidence 0.80

Two statements carry the key as a literal: `PRAGMA key = "x'<hex>'"` in `configuration(key:)`'s `prepareDatabase` (AppDatabase.swift:116, run on EVERY pool connection) and `ATTACH DATABASE ? AS encrypted KEY "x'<hex>'"` (StoreEncryptionMigration.swift:100). GRDB throws `DatabaseError(resultCode:message:sql:)` carrying that statement text (GRDB Statement.swift:440) and `DatabaseError.description` appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally (DatabaseError.swift:566-575; `trimmedSQLStatement` only trims whitespace/semicolons), with `errorUserInfo[NSLocalizedDescriptionKey] = description` (:621) so `localizedDescription` carries it too. GRDB's `publicStatementArguments` redaction protects arguments, not the SQL. Trace: a store whose one-time migration hits a throwing ATTACH (SQLITE_CANTOPEN on a full or read-only volume, an unwritable `.encrypting` temp, the attached-db limit) — the `do` block at StoreEncryptionMigration.swift:96-115 has no `catch`, so the DatabaseError escapes to `AppDatabase.openStore`'s generic arm, which does `StoreOpenError(storePath: url.path, reason: String(describing: error))` (AppDatabase+Dependency.swift:108); `StoreFailureView.swift:49` renders that as `Text(error.reason).textSelection(.enabled)` beside a "Reveal in Finder" button (mobile: MobileStoreFailureView.swift:51). Second path: `StoreBackup.integrityCheck` opens the copy with the KEYED artifact configuration and, on failure, returns `"could not be checked: \(error.localizedDescription)"` (StoreBackup.swift:417); that string becomes `BackupRunRecord.Leg.integrity`, is written to UserDefaults by `BackupLog.append`, and is rendered as a sentence at DataSafetyModel.swift:263/:279.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The channel is real and undocumented. Verified: AppDatabase.swift:116 `try db.execute(sql: "PRAGMA key = \"x'\(key.hexEncoded)'\"")` and StoreEncryptionMigration.swift:100 `ATTACH DATABASE ? AS encrypted KEY \"x'\(key.hexEncoded)'\"` are the only two `hexEncoded` uses outside StoreKey itself. In the pinned checkout (.build/checkouts/GRDB.swift), `DatabaseError.description` at DatabaseError.swift:571 appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally, `errorUserInfo[NSLocalizedDescriptionKey] = description` at :620-622, and `Statement` constructs DatabaseError with `sql:` set. The migration's export block (StoreEncryptionMigration.swift:96-115) is a bare `do {}` with NO catch, so an ATTACH failure escapes uncaught to `openStore`'s generic arm, which does `String(describing: error)` into `StoreOpenError.reason` (AppDatabase+Dependency.swift:101-107), rendered as `Text(error.reason).textSelection(.enabled)` at StoreFailureView.swift:49. Nothing in notes/ or the 13p plan records this; StoreKey.swift:58-61's redaction shows the intent runs the other way. SEVERITY CORRECTED DOWN: the leak needs an error thrown BY one of the two key-bearing statements. `PRAGMA key` almost never errors (SQLCipher defers key validation to the first page read, so a wrong-key/corrupt store fails at `PRAGMA journal_mode`/the first SELECT, whose SQL carries no key), which also weakens the StoreBackup.integrityCheck path the finding cites — its realistic failures come from the fallback `PRAGMA integrity_check` read, not the key pragma. The one genuinely traceable road is a throwing ATTACH during the one-time plaintext migration (unwritable temp path, CANTOPEN, attached-db limit) — real, but a once-per-store road on a shrinking population. Worth fixing (bind the key as an argument, or catch-and-sanitize at both sites), at MINOR.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P15.

---

## 17b — Doors that lose or mis-copy her text

**Status: open, unstarted.** 6 items, no pins.

Six independent doors where the traced outcome is her prose destroyed, a wrong take copied, or a
block resurrected from a timeline she abandoned. They share no mechanism — they are grouped because
they share a **consequence class**, and because that class is the one this project refuses by
construction (*"mutation never reaches anything the author has decided to keep"*).

P4 and P14 are the same anti-pattern on the phone: **state cleared, or a result assumed, before the
write is known to have succeeded** — so a refusal eats the thing the refusal was protecting. P7 is
its desktop cousin: the boards' branch / ＋ new take / ⌘T doors copy the STORE past a dirty buffer,
while the Write editor's identical gesture flushes first — so the same gesture means two different
things depending on which surface issued it. P5 violates **I10 at birth** (a live block must have a
live active variant) and copies text the column was not showing. P6 leaves the redo future unclear ed
across a whole-note content replacement.

### Items

#### P4. The comments sheet clears the typed draft before the write is attempted, so a refusal destroys her comment

`App/Variorum/VariorumMobile/Features/Write/MobileCommentsSheetView.swift:105` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.85

`submitDraft()` reads `draftField.text`, sets `draftField.text = ""` (line 105), then fires `Task { await model.comments.submitDraft(text) }` (line 107). `MobileCommentsController.submitDraft` -> `run { }` handles a throw with `model.report(Self.refusalMessage(error))` only (MobileComments.swift:113-140) — nothing restores the field. The refusal is reachable by construction: `MobileCommentsController.open(blockID:)` (MobileComments.swift:50-57) has no seal check (fire-and-DO), and `Operations.addBlockComment` calls `ensurePlacementUnlocked` before anything else (Sources/VariorumCore/Operations/Operations+Comments.swift:29-31), throwing `.lockedPost` under a sealed note — the controller even ships the sentence for it. Concrete run: open a sealed note, tap ... -> Comments, type a paragraph, tap Submit. The field empties, the store gains nothing, and she reads "This note is locked — unlock it to change comments." with her text gone and no undo. The `editBlockComment` arm additionally nils `editingID` before running (MobileComments.swift:114-115), so a refused edit loses the target too. A 13p store re-lock produces the same loss with a raw `String(describing:)` dump as the sentence.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. MobileCommentsSheetView.submitDraft (lines 101-108) reads `draftField.text`, writes `draftField.text = ""`, then fires `Task { await model.comments.submitDraft(text) }`; `MobileCommentsController.run` (MobileComments.swift:128-140) catches with `model.report(Self.refusalMessage(error))` and nothing anywhere restores the field. The refusal is genuinely reachable: `open(blockID:)` (MobileComments.swift:50-57) guards only that the slot exists, `MobileBlockMenu.menuElements` appends the Comments row unconditionally (MobileBlockMenu.swift:138-140) and `MobileBlockDecor.swift:259` does the same — fire-and-DO, no seal gate — while `Operations.addBlockComment` calls `try ensurePlacementUnlocked(db, blockID:)` before anything else (Operations+Comments.swift:31) and throws `.lockedPost` under a sealed note; the controller even ships the sentence for it ("This note is locked — unlock it to change comments.", MobileComments.swift:152). Nothing in MobileCommentsSheetView gates the draft field or Submit on `isSealed`. So: sealed note → ⋯ → Comments → type → Add empties the field, writes nothing, and prints a refusal, with no undo. The `editingID = nil` before `run` (MobileComments.swift:114-116) loses the edit target on the same road. Severity held at MAJOR: it is unrecoverable text loss on an ordinary gesture over a shipped note state, and the project has ruled this exact class twice (the quick note's Q2 rule, stated at MobileQuickNote.swift:113-116: "no refusal here is ever reached by a road that discarded her text"). The finding's secondary 13p store-re-lock sub-case is weaker than claimed — a lock tears down the whole `.ready` subtree the sheet lives in — but the sealed road alone carries it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P4.

#### P5. promotePicks copies an ARCHIVED pick as a block's ONLY take — I10 violated at birth, and the copied text is not what the column showed

`Sources/VariorumCore/Operations/Operations+Versions.swift:674` · **MAJOR** · CONFIRMED · invariant-violation · finder confidence 0.85

copyPlacements' fan read (:663) has NO status filter, so an archived take is in `fan`; `lensShown = chosenPicks?[block.id].flatMap { fan.first { $0.id == pick } }` (:674) therefore RESOLVES an archived pick, and with `carryFans: false` `toCopy = [shownVariant]` (:683) makes it the copy's only take. `copyFan` preserves status verbatim (`status: take.status`, Operations+Variant.swift:374), and both `chosenCopyID` and `defaultCopyID` (:710-717) land on that one archived copy. Concrete path: on the Takes/Lenses board pick take T for block B into a scratch column (TakesViewModel.swift:853); archive T from the same board (TakesViewModel.swift:1171 — `ensureNotLastActive` permits it whenever B has another active take); scratch picks are never pruned, so the column silently falls through to B's chosen take (resolvedTake, TakesViewModel.swift:487-499); then ⧉ 'Make this a note' → 'New note, only what this column shows' (LensesBoardView.swift:707) → promoteColumn(carryFans:false) → promotePicks (TakesViewModel.swift:955). RESULT: the new note holds a LIVE, PLACED block whose single variant is status='archived' — zero live active variants (I10). The block still renders (Queries.renderPost's `dflt` join deliberately omits the active check, PostRender.swift:155-157) but every keystroke refuses: autosave → editableVariant throws `archivedVariant` (Operations+Variant.swift:317-321). And the text is wrong: the column was displaying B's chosen take, while the copy carries the archived pick's prose — a door labelled 'only what this column shows' produces different words. `divide` on that block then reads activeVariants == 0 and refuses with `fannedBlock` (Operations+Structural.swift:200), naming a fan that is not there. `promoteLens` is immune because Queries.effectiveLensSelection joins `AND v.status = 'active'` (LensQueries.swift:55-59); the sibling door adoptPicksPreservingChosen validates `take.status == .active` explicitly (Operations+Versions.swift:361-365) — promotePicks alone does not.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced every leg in source. (1) Operations+Versions.swift:663-670 fetches the fan with `WHERE block_id = ? AND deleted_at IS NULL` — no status filter, so archived takes are in `fan`; :673-675 `lensShown = chosenPicks?[block.id].flatMap { pick in fan.first { $0.id == pick } }` therefore resolves an archived pick, and :681-684 `toCopy = [shownVariant]` under carryFans:false makes it the sole copied take. (2) copyFan (Operations+Variant.swift:373-379) copies `status: take.status` verbatim, and :709-717 land BOTH chosenCopyID (from sourceChosenID == the pick) and defaultCopyID (block.defaultVariantId not in the copied set ⇒ falls to shownVariant's copy) on that archived copy ⇒ a live, placed block with zero live ACTIVE variants (I10 as the ops layer enforces it — cf. archiveVariant's ensureNotLastActive, Operations+Deletion.swift:43). (3) copyPost (:583-601) performs no pick validation, so nothing upstream filters. (4) The caller path is real and reachable: TakesViewModel.pick (:745-752, scratch case) and adoptMintIntoColumn (:850-854) write scratch picks with no status re-check; archiveTake (:1171) → archiveVariant permits archiving whenever another active take exists; NOTHING prunes column.picks (all 16 `picks` sites checked — only :881 clears them, on save-as-lens); resolvedTake (:487-499) → PaneTextAuthority.resolvedText (:157-165) falls through to the slot's chosen because projection.fans is the live ACTIVE fan (TakesQueries.swift:13-16); promoteColumn's scratch arm (:947-957) passes the raw picks; the carryFans:false door exists (LensesBoardView.swift:707). (5) Consequences confirmed: PostRender.renderPost's `dflt` join deliberately omits the active check (PostRender.swift:155-157 + the doc at :116-120), so the block renders; autosave → editableVariant throws archivedVariant (Operations+Variant.swift:18, 317-321); divide reads activeVariants == 0 and throws fannedBlock (Operations+Structural.swift:192-200). (6) The asymmetry is real: promoteLens goes through effectiveLensSelection, which joins `AND v.status = 'active'` (LensQueries.swift:53-59), and adoptPicksPreservingChosen validates `take.status == .active` (Operations+Versions.swift:363-365); promotePicks alone does not. No test covers archived + carryFans:false (VersionOperationsTests.swift:366 uses a nonexistent id at the default carryFans:true), and I found no note in notes/ or in the code documenting this as an accepted consequence — the promotePicks docstring (:385-387) claims the opposite. ONE overstatement in the finding, which does not refute it: the copy's archived take IS reachable — TakesBoardView.swift:1113-1150 renders the per-block "archived · n" disclosure with an Unarchive button for any block that has a slot, so the note is not unrecoverable; the wrong-prose half and the I10-at-birth half stand.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P5.

#### P6. restoreNoteVersion replaces a note's whole content without clearing the redo future, so a redo injects a block from the abandoned timeline into the restored note

`Sources/VariorumCore/Operations/Operations+NoteVersions.swift:187` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.85

The redo future is cleared ONLY inside UndoStack.register (redoEntries.removeAll() at UndoStack.swift:136); nothing else clears it (removeAll() has no production caller). restoreNoteVersion registers nothing — it self-classifies as "the recovery-door class" — yet it tombstones every live block of the note plus a purge intent each, and copies a fresh family in. Trace: (1) in note N holding A,B run merge(A,B) → A' minted, entry E registered; (2) press ⌥⌘Z → revertStructural tombstones A' at stamp t2 (its placement row cascades to the same stamp) and E moves onto redoEntries; (3) restoreNoteVersion(N, from: V) replaces the note's content and leaves redoEntries alone; (4) press ⇧⌥⌘Z → reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) reads block.deletedAt == t2, finds the container_block row WHERE block_id = ? AND deleted_at = t2, sees container N still live, revives it, then sets block.deletedAt = nil (:420) and flips the cascade victims (:423). A', holding merged text from the state she explicitly replaced, is resurrected into the restored note with no refusal and no message. The divide flavour wedges instead: restoringTexts names A's variant, which step 2 cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the reapply rolls back, and the entry stays on the redo stack forever (its target is purge-intent-fenced out of the tray, so the refusal is unresolvable) — and redo is strictly LIFO, so every entry beneath it is unreachable for the session. deleteContainer is the same root cause with a milder outcome (live unplaced block inside a tombstoned note). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 uses deleteBlock — a REGISTERING act — so it cannot catch this class.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in source. redoEntries is cleared ONLY at UndoStack.swift:136 (inside register) and :276 (undoing past a redo:nil entry); removeAll() at :304 has no production caller (grep over Sources+App finds only test callers). restoreNoteVersion (Operations+NoteVersions.swift:187) registers nothing — its doc self-classifies as "the recovery-door class" at :176 — yet step 2 (:218-234) tombstones every live placement's block and mints a purge intent per block, and step 3 copies a fresh family in. Its only door, VersionActs.restore (App/Variorum/Shared/VersionActs.swift:40-48), adds no stack handling. Merge's registration (Operations+Structural.swift:747-754) passes restoringTexts: [] for redo, so reapplyStructural's untombstoningBlocks loop (:404-424) hits nothing that can refuse: the minted block's placement row still carries the undo's stamp, container N is live and unlocked, so ensureUnlocked passes, block.deletedAt = nil at :420 and flipBlockCascadeTombstones at :423 — the merged block is resurrected into the note whose content was just replaced. The divide flavour's wedge is equally real: its redo carries restoringTexts: [sourcePreImage] (:246-249) on a variant the restore's Delete Now road cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the whole reapplyStructural transaction rolls back, and UndoStack.redo (:296-303) leaves the entry on redoEntries — strictly LIFO, so the session's redo stack is unreachable thereafter, and no user door can void the fencing intent (PoolAndTray.swift:107-109 / Trash.swift:169 hide the target). Not documented as accepted: notes/plans/post-13l-polish-round.md contains no occurrence of "redo" at all, and AppSpec §9 + OverallModel §3 + UndoStack's own header all state the contrary rule ("any new structural act clears the redo future"). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 does use deleteBlock, a registering act, so it cannot cover this class. deleteContainer (Operations+Container.swift:383) is confirmed to register nothing either, the same root with the milder outcome. Severity held at MAJOR: the road is narrow (structural op → undo → version restore → redo) but the outcome is silent wrong prose in a live note, plus a session-permanent redo wedge, against an explicitly canonized contract.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P6.

#### P7. The boards' branch / "＋ new take" / ⌘T doors copy the STORE past a dirty buffer — the Write editor's identical gesture flushes first

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1047` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.90

A live take pane on the Takes board is buffer-authoritative: each keystroke goes to `authority.bufferEdited` + `autosave.record`, and `AutosaveCoordinator`'s debounce is 500 ms (AutosaveCoordinator.swift:95), so the `variant` row lags the screen for up to half a second. ⌘T is bound to `.newTake` (EditorCommands.swift:153) and the board's routed handler hands the LIVE pane straight to the branch door: TakesBoardView.swift:330 `case .branch: guard let pane = model.focusedPane ... await model.branchTakeRevealed(blockID: pane.blockID, from: pane.variantID, ...)` → `branchTakeRevealed` (TakesViewModel.swift:2002) → `branchTake` (:1047) → bare `session.runner.run { ops in try ops.branchVariant(...) }`. No link in that chain flushes. `branchVariant` copies the source's ROW text inside the transaction (Operations+Variant.swift:196, `text: source.workingText`). Concrete sequence: pane shows "…and then she left."; she types " Or did she?" (pending[V] set, unflushed); within 500 ms she presses ⌘T; the minted take is a copy of "…and then she left." without the new sentence; the ring then moves onto the new card and she keeps writing there, so the two takes permanently diverge on text she never chose to drop. This contradicts OverallModel §3 ("Branching a variant INHERITS the current buffer's text") and the app's own flush-first doctrine — `AppSession.runCopying` (AppSession.swift:316) exists for exactly this hazard ("the copying operations read `working_text` ROWS, so a copy taken inside the editor's autosave debounce lacks the last seconds of typing"), and the Write editor's twin gesture `EditorViewModel.mintCaretTake` (EditorViewModel.swift:2363) does `await autosave.flushNow()` before `ops.branchVariant`. Same-class siblings on the same bare `runner.run`: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) — the Lenses diverge-here door; `addWriteColumn` (:625), `replaceColumnWithNewWrite` (:672) and `writeNewTakesEverywhere` (:989), which call `ops.branchAllFans(post:)` and mint a per-block branch from `shown.workingText` (Operations+Versions.swift:474); and `WriteTakesPanel.swift:238`, whose branch button shares the Write editor's coordinator. Every neighbouring board door — `copyAllTakes`, `moveTake`, `mergeSelectedBlocks`, `commitFocusedTake`, `duplicateAsVersion`/`promoteColumn` via `runCopying` — flushes first, so one gesture behaves two ways depending on which surface it is pressed from.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. TakesBoardView.swift:330 `.branch` → `model.branchTakeRevealed(blockID:from:preferredColumnID:)` (TakesViewModel:2002) → `.takes` arm → `branchTake` (:1047) = `session.runner.run { try ops.branchVariant(...) }` with no flush anywhere in the chain; `Operations+Variant.swift:195` returns `text: source.workingText` (the ROW). Panes are genuinely buffer-authoritative and lag the store: `paneEdited` (:567-576) does `authority.bufferEdited` + `autosave.record`, and AutosaveCoordinator.swift:96 defaults `debounce: .milliseconds(500)`. `revealTake` → `focus()` only flushes AFTER the branch has already read the stale row (:530-531), so the source keeps her text and the COPY is what loses it. The correct sibling exists: `EditorViewModel.mintCaretTake` (:2363-2374) awaits `autosave.flushNow()` before `ops.branchVariant`, so the same ⌘T behaves two ways. Not a documented exemption: the 13e E10 sweep table (notes/plans/phase-13e-takes-block-management.md:2843) is explicitly headed "every door that mints a copy from stored text" and lists only duplicateAsVersion/promoteLens/promotePicks/MembershipChip/divergeForBook/poolDrop — no branchVariant door appears, and the `runCopying` doc's stated reason (:2165-2168) is only that non-copy doors shouldn't pay; branch mints a copy. Strong corroboration that the project treats this as a defect, not a tradeoff: the phone's `branchDisplayed` (MobileTakesBrowser.swift:330-350) flushes first with a comment naming the identical mechanism, landed as a Stage-2-ladder MAJOR (mobile-app-plan.md:2803, :2947). Siblings verified live too: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) are bare `runner.run`; `writeNewTakesEverywhere` (:989) calls `ops.branchAllFans(post:)` on the bare runner. Severity stays MAJOR: wrong content in the copy on a common keyboard road; the original's text is not lost (its flush lands), so it is not BLOCKER-class.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P7.

#### P14. The quick note's `try?` folds a read failure into "There's nothing to save yet", orphans a note that WAS created, and lets the clock mint it a second time

`App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift:682` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.70

`adopt` does `let blocks = (try? await session.database.read { try Queries.renderPost(db, containerID: containerID) }) ?? []` and then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { lastError = refusal(.emptyImport); saveState = .typing; return nil }`. The guard's comment argues unreachability from `importPost` alone ("it mints at least one block or throws") — but `try? … ?? []` converts a READ failure into the identical empty result, which that argument does not cover. Finding 1 supplies the reachable failure: `AppBootstrap.lock()` calls `binding.lock()` and closes the pool while this read can be in flight, after `importPost`'s write has already committed. Consequences, each traced: (a) she is shown "There's nothing to save yet." about a note that exists in SQLite; (b) `postID = containerID` on line 693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` passes on her next keystroke and `mintNow` runs `importPost` again — a second note with the same text, repeatably; (c) `variantID` stays nil, so `record(tail:)`'s `guard let variantID` returns and nothing she types afterwards is autosaved anywhere.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The chain is exactly as described. MobileQuickNote.swift:681-691: `let blocks = (try? await session.database.read { … Queries.renderPost … }) ?? []`, then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { … refusal(.emptyImport); saveState = .typing; return nil }` — and the guard's own justification ("Unreachable through `importPost` (it mints at least one block or throws)") argues only about the WRITE, so the `try? … ?? []` road is genuinely uncovered. Consequences verified: `postID = containerID` at :693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` (:623-624) passes and the next keystroke's `handleTextChange` falls into `armMintClock()` (:497-500) → a second `importPost` with the same text; `variantID` stays nil so `record(tail:)`'s `guard let variantID` (:613) drops every later keystroke. Note the deliberate asymmetry the finding correctly implies: the sibling A1-19 arm DOES set `postID` first, so only this arm can double-mint. Reachability is the narrow part, which is why MINOR is right: it needs the pool to close between the committed write and the read — the `AppBootstrap.lock()` race (binding.lock() on a detached task) is the credible cause, while the file-protection cause the file's other comments name is unlikely after first unlock, since the store directory is deliberately `.completeUntilFirstUserAuthentication` (AppBootstrap.swift:491-501).

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P14.

#### P36. A failed re-read in `applyPendingIfClean` discards the deferred projection instead of restoring it, while both sibling guards restore

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:803` · **NIT** · CONFIRMED · error-swallowing · finder confidence 0.60

`applyPendingIfClean` sets `pendingProjection = nil` before spawning the read task; the `guard let fresh = try? await session.database.read(...) else { return }` arm then returns without restoring it, whereas the two guards immediately after both write `pendingProjection = fresh` on their failure paths. If the read throws — the plausible post-13p trigger is a re-lock / Lock Now closing the keyed store while a settle is in flight — the externally-changed projection (a sync-applied conflict variant, a chosen-variant flip from another surface) is discarded and the surface keeps showing pre-change content until some later store write produces a fresh observation delivery.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The code asymmetry is exactly as described and unambiguous. EditorViewModel.swift:795-816: the method sets `pendingProjection = nil` before spawning the read task; the failure arm is `guard let fresh = try? await session.database.read(...) else { return }` — a bare return with no restore — while the two guards immediately below both write `pendingProjection = fresh` before returning (the busy guard and the generation-fence guard, which additionally re-calls `applyPendingIfClean()`). So on a thrown read the deferred marker is dropped and nothing re-arms it; the surface then waits on the next ValueObservation delivery, which only fires on a further store change. Two honest qualifications that hold the severity at NIT rather than higher: the discarded value is a STALE photograph that would have been re-fetched anyway (so restoring it costs nothing but gains only a retry), and the plausible post-13p trigger the finding names — a re-lock closing the keyed store — would very likely also error the observation itself (EditorViewModel.swift:622-624 sets `statusMessage = "Note observation failed"`), which is a louder failure than the lost marker. The Task is unstructured with no cancellation source, so `try?` is swallowing a store error rather than a cancellation. NIT confirmed: a real one-line asymmetry against the surrounding machinery's own never-lose-the-marker rule, with narrow and mostly-moot consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P36.

### CLOSED 2026-09-21 — the dispositions (RUN A batch A1 + the run's ladder; the record is `notes/plans/run-a-custody-text-loss.md` — the BATCH A1 RECORD, its ORCHESTRATOR ADJUDICATION, and THE LADDER)

**Seven items (the six above + KnownIssues row 65, which joined at the 13u4 closeout's refresh) —
every one FIXED with a named red-on-old pin; nothing dismissed as hollow; one residue DEFERRED
with an owner:**
- **P4 FIXED** — `MobileCommentDraftTests` (3), the door driven on a mounted sheet under a real
  seal; revert-verified. **The ladder then widened the class twice, and both widenings are
  BUILT:** round 2 found the sheet's CLOSE destroyed the refused draft P4 preserved (the sheet had
  inherited the pad's pre-park shape), and round 3 found the fix's own two generational holes —
  the landed shape is the **comment-draft park on BOTH platforms** (`Shared/CommentDraftPark`: a
  NON-CONSUMING peek restored at the same block's next open, the clear keyed to THE SAME DRAFT,
  the Mac's restore in the installed lifecycle), pins `MobileCommentParkTests` (7) +
  `CommentPanelParkTests` (8) with five discriminating reverts across the rounds. QUESTIONS #140.
- **P5 FIXED** — `PromotePicksArchivedPickTests` (3), red on the pre-fix tree: a stale pick reads
  as NO pick for the shown take and the chosen pointer; I10-at-birth impossible on every arm.
- **P6 FIXED** — `ContentReplacementRedoTests` (5): `UndoStack.clearRedoFuture()` at the two
  recovery-door acts (`restoreNoteVersion`, `deleteContainer`), post-write; two shipped pins
  re-based as the ruled-change class. **The UNDO-side residue DEFERRED → 17e** (a KnownIssues row;
  clearing a session-wide stack for one note's restore would take her other notes' history — the
  note-scoped-entries design is 17e's, the product half hers at #136(b)).
- **P7 FIXED** — `BranchDoorFlushTests` (7): a branch IS a copy, five doors onto
  `AppSession.runCopying`; the 15-door sweep table in the run plan (6 FIXED · 9 provably SAFE);
  blank takes deliberately bare, pinned as such.
- **P14 FIXED** — `MobileQuickNoteReadFailureTests` (3); the revert reproduced the double-mint
  LIVE (`count → 2` with *"There's nothing to save yet."* over a note in SQLite).
- **P36 FIXED** — `DeferredProjectionRetryTests` (2), the marker restored like its siblings.
- **Row 65 FIXED to the orchestrator's recorded ruling** (the design fork ruled repo-first):
  `QuickNotePark` — a memory-only session-scoped park restored at the next summon, PLUS the 1b
  one-shot quit decline (a second consecutive ⌘Q always proceeds; hardened at ladder round 1,
  whose MAJOR found the one-shot re-armed by every press with the pad open — the integrated
  second-press pin is `theSecondQuitsOwnReRefusalDoesNotReArmTheDecline`). `QuickNoteParkTests`
  (6). QUESTIONS #137.

**Evidence at the letter's close:** the run's finals (the run plan's CLOSEOUT section); zero
`Sync/` lines; zero schema. **This letter's ratify rows: #136 · #137 · #140.**

---

## 17c — The read layer's P1 debt (query-side)

**Status: CLOSED 2026-08-31** — the pre-13u round's Act 4 (this batch also built Act 3, whose
Sherlock corpus was the instrument). All four items **FIXED**, each with a red-on-old pin verified by
reverting the fix and watching the pin go red. Commits `e08762b` (the schema change, on its own) and
`edee416`.

### Dispositions (per item)

Every pin is a **shape** fact — a query plan or a statement count — never a timing, so it cannot pass
or fail with machine load (P48's own lesson, applied here: a pin that cannot fail is a hole in the
mechanism). All pins live in `Tests/VariorumCoreTests/ReadLayerP1Tests.swift`. Numbers are Debug
builds on the author's M3; the corpus is a seeded probe at 2,000 and 20,000 containers (≈12k and
≈122k variants), plus the real seeded Sherlock library where the surface is a note-level one.

| Item | Verdict | Before → after | Pin (red-on-old verified) |
|---|---|---|---|
| **P18** trayTakes scans `variant` | **FIXED** | ordinary 1-block note **0.836 → 4.783 ms** across the corpus growth; after **0.472 → 0.470 ms — FLAT**. (800-block note: 1.116→5.358 before, 1.715→1.741 after.) | `theTrayTakesListingIsDrivenByTheNoteAndNeverScansTheVariantTable` — plan must not contain `SCAN v` and must name `idx_cblock_order`/`idx_block_last_container`. **Red on old:** both assertions fail (`SCAN v`). Plus an equivalence pin, `theRewrittenTrayListingSelectsExactlyWhatTheCoalesceDid` (moved-away block excluded, released original included), which passes on BOTH shapes by design — that is what makes it an equivalence pin. |
| **P19** versionOfNote N+1 in the Trash | **FIXED** | fifteen versions at 20,000 containers **551 → 15.0 ms**; a single lookup **35.9 → 8.0 ms** | `theTrashListingCostsTheSameStatementsHoweverManyVersionsItLists` — statements for a listing with one version must equal those for ten. **Red on old: 6 vs 16.** Plus `theBatchedPeerLookupKeepsTheSingleDoorsAnswer` (live-peer-then-smallest-id ordering preserved; the single-id door now delegates, so the two cannot disagree). |
| **P20** the classifier has no index | **FIXED** (schema `v1_15`, its own commit) | plain note with zero versions **0.374 → 1.791 ms** across the corpus growth; after **0.215 → 0.218 ms — FLAT** | `theVersionClassifierSeeksItsOwnIndexInsteadOfWalkingEveryPost` + `theDeletedWithRoadSeeksTheSameIndex`. **Red on old:** with the index dropped, the plan is `SEARCH v USING INDEX idx_container_kind (kind=?)`. |
| **P21** activeFans one query per block | **FIXED** | 40 blocks: **40 statements → 1**. On the seeded Sherlock corpus (a 212-block story, on disk and encrypted) `takesProjection` **71.0 → 32.3 ms**; the 800-block fan fetch 353 → 237 ms | `theFanFetchIsOneStatementForTheWholeNote` (**red on old: 40**) + `theBatchedFanFetchMatchesThePerBlockShape` (an entry for every block asked about, empty where the fan is; `(fan_position, id)` order). |

**The verifier's temperings were right, and the record says so.** P20's consequence really is
single-digit milliseconds at any corpus she will have this year (its value is that the shape becomes
flat, on the WRITE path, inside `deleteContainer`'s transaction); P21 really is a constant factor and
not a P1 break, and its improvement is smaller than the statement count suggests because what remains
is decoding the same rows. P18 was the sharpest of the four: it was corpus-linear on an ORDINARY
one-block note, which is what made the doc comment's "never the corpus" false rather than optimistic.

**One residual, recorded not fixed:** P19's pass is still LINEAR in the corpus — the peer is reached
through `container_block` BY BLOCK ID, and the only index on that column is the live-rows partial one,
while the lookup is deliberately tombstone-insensitive. Closing it needs an index on
`container_block(block_id)`, a second schema change with its own write-path cost. It has a
`KnownIssuesAndTechDebt.md` row owned by **12 (Hardening)**, beside its P1-tension siblings.

**False doc comments corrected in the same commits** (the sweep named them): `PoolAndTray.swift`'s
"Cost ∝ this note's own fan history … never the corpus" was false and is now true, with the mechanism
written down; `NoteVersions.swift`'s two "never the corpus" claims now say exactly what is and is not
corpus-shaped.

**Verification at close:** core `swift test` **1465/155 green** (baseline 1457/154; +8 pins in one
suite), three consecutive clean runs. Mac suite **1897/321** with ONE failure — the known load-flaky
`EditorWindowSmokeTests.rewriteStrategyLatencies` pin at 52.98 ms against its 50 ms budget —
**adjudicated PRE-EXISTING**: it failed isolated too (51.9–53.8 ms over four runs, load average
12–20 on a 42-day-up box), and the **pre-round baseline commit `626c8c2`, built in a worktree and run
under the same load, measured 52.53 ms** on the same test. Its KnownIssues row gains this covariate.
Tutorial spine green; the iOS target builds.

---

**Original brief (kept as written, so the closing verdicts can be read against what was claimed):**

4 items, no pins.

Deliberately split from 13u1's O(N²) family: those are editor-seam and belong with the rewrite that
touches that seam. **These four are `Queries/` — a different file, a different fix, and no reason to
wait.**

P20 is the one to look at first and the cheapest to fix: the version-history classifier has no index,
so `deleteContainer` walks every post in the corpus **inside its own write transaction**, even for a
note with zero versions — a corpus-scaled hold on the write lock, not merely a slow read. **A local
index is free under §12**: the Postgres mirrors deliberately carry no indexes beyond the PK
(SyncSpec §2), so adding one locally is not a lockstep event and needs no deploy window. It is still a
schema change, so per CLAUDE.md it takes **its own commit** ahead of anything that uses it.

### Items

#### P18. Queries.trayTakes full-scans the `variant` table inside the tray panel's held observation, contradicting its own P1 doc claim

`Sources/VariorumCore/Queries/PoolAndTray.swift:359` · **MAJOR** · CONFIRMED · perf-p1 · finder confidence 0.92

trayTakes starts FROM variant and only reaches the note through a post-join filter, `COALESCE(cb.container_id, b.last_container_id) = :post`, which is not seekable. idx_variant_block is (block_id, status) and cannot serve a query with no block_id; there is no index on variant.deleted_at anywhere in Migrations.swift. Verified plan against the rebuilt real schema: `SCAN v` — a full B-tree scan of the largest table in the store — then per-row seeks into block/container_block, then USE TEMP B-TREE FOR ORDER BY. Measured: 2.31 ms at 12,030 variants, 25.57 ms at 120,830 — exactly linear, and this is the cheapest possible case because the probe has ZERO deleted variants, so every row is rejected on `deleted_at IS NOT NULL` before any join fires. The call site is not a one-shot: TrayPanel.swift:357-377 puts it inside a single `session.database.observe { ... }` held for as long as the note is open, whose region includes `variant`, so every autosave re-runs the scan. Its four siblings in that same snapshot (trayBlocks, archivedBlocks, preservedOriginals, originFamilyClocks) are correctly note-scoped via `b.last_container_id = :post` on idx_block_last_container; trayTakes is the lone one that is not. Post-13p, each pass also decrypts every page of the variant table under SQLCipher.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and measured. The SQL at PoolAndTray.swift:363-380 is quoted accurately, and the plan against the rebuilt real schema is `SCAN v` (then correlated purge_intent seek, then seeks into block / container_block / variant, then USE TEMP B-TREE FOR ORDER BY). I confirmed the index premise exhaustively: `grep -n INDEX Migrations.swift` shows every index in the store, and there is none on variant.deleted_at — idx_variant_block is (block_id, status) and cannot serve a query with no block_id, and COALESCE(cb.container_id, b.last_container_id) = :post is not sargable, so nothing can seek. Timings: 0.58 ms at 24,000 variants -> 9.35 ms at 240,000 — exactly linear. The sibling contrast is accurate: trayBlocks/archivedBlocks/preservedOriginals/trayCounts all drive from `FROM block b ... WHERE b.last_container_id = :post` (PoolAndTray.swift:95/99, 180/183, 258-278) on idx_block_last_container; trayTakes alone starts FROM variant. The hold is real — TrayPanel.swift:375 sits inside the single session.database.observe at :357, started by `.task { await model.start() }` at :800, and the panel lives in the inspector, which can stay open while she types (the existing KnownIssues row says so in as many words). The doc at PoolAndTray.swift:353-355 ("Cost ∝ this note's own fan history ... never the corpus") is therefore false, and the KnownIssues row that owns this pane explicitly asserts the opposite of the defect ("P1's letter intact; the FREQUENCY changed, not the scaling"), so this is NOT a documented, accepted tradeoff — it is a documented denial of it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P18.

#### P19. Queries.versionOfNote is an N+1 in the Trash listing, and each call scans every post in the corpus (96 ms at 20k notes)

`Sources/VariorumCore/Queries/Trash.swift:180` · **MAJOR** · CONFIRMED · perf-p1 · finder confidence 0.90

trash()'s .note arm calls versionOfNote once per born-archived row inside a Swift .map (Trash.swift:180-182). That statement (NoteVersions.swift:292-311) has no seekable driver for the note side, so SQLite's plan — verified with EXPLAIN QUERY PLAN against the real schema rebuilt from Migrations.swift, stats-free exactly as ships (the repo never runs ANALYZE) — is: SEARCH mine USING INDEX idx_cblock_order (container_id=?) / SEARCH n USING INDEX idx_container_kind (kind=?) / SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX / SEARCH theirs USING INDEX idx_cblock_order. `n` is driven before `theirs`, so the loop is (the version's placements x every post in the corpus). Measured on a seeded probe: 7.02 ms at 2,005 containers, 96.36 ms at 20,006 containers — one call. trash() is HELD live: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit: Self.window + 1 where window = 500 (RecoveryView.swift:199), and the observation's region includes `variant` (the .take arm and strandedOriginals' preview join), so it re-fires at autosave rate. Concrete failure: with 20 deleted saved versions in the Trash and a 20k-note corpus, each observation fire costs ~1.9 s of container walking, and every keystroke's autosave triggers one.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. Trash.swift:180-182 does call `versionOfNote` inside the `.note` arm's `.map`, once per row whose selected `born_archived` is 1. I rebuilt the shipping schema from Migrations.swift (verified: no ANALYZE anywhere in Sources/App, so the planner runs stats-free exactly as it ships) and ran EXPLAIN QUERY PLAN on the verbatim statement from NoteVersions.swift:292-311. The plan is exactly as claimed: `SEARCH mine USING INDEX idx_cblock_order (container_id=?)` / `SEARCH n USING INDEX idx_container_kind (kind=?)` / `SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX` / `SEARCH theirs USING INDEX idx_cblock_order` — `n` is driven before `theirs`, so the inner loop really is (the version's placements x every post in the corpus). My own timings on a seeded probe: 3.06 ms at 2,001 containers -> 34.48 ms at 20,001, i.e. linear in corpus (about 1/3 the reviewer's absolute numbers, presumably a different blocks-per-note density, but the same shape and order of magnitude). The hold is real: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit 501, and AppDatabase.observe's own doc (AppDatabase.swift:200-217) confirms table-grained region tracking that re-fires "in the worst case at autosave rate". One correction to the finding's supporting detail, which does not change the verdict: the `.take` arm never runs here — TrashScope.listedKinds (RecoveryActs.swift:466-468) is {.note,.book,.block,.preservedOriginal} — but the `.block` arm's `LEFT JOIN variant dv` puts `variant` in the region anyway, so the autosave-rate claim survives. Not documented as accepted: trash()'s own header concedes only the strandedOriginals walk and asserts it is "not a held per-keystroke one" (it is a held observation), and versionOfNote's doc makes no cost claim at all. Realistic trigger is ordinary, not exotic: versions ride a note's deletion on its exact stamp, so deleting one note with 15 saved moments puts 15 born-archived rows in the window at once.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P19.

#### P20. The version-history classifier has no index, so deleteContainer walks every post in the corpus inside its write transaction — even for a note with zero versions

`Sources/VariorumCore/Queries/NoteVersions.swift:230` · **MINOR** · CONFIRMED · perf-p1 · finder confidence 0.90

versionHistoryPredicate (NoteVersions.swift:146-185) has only two non-subquery terms — `archived_at IS NOT NULL` and `archived_at = created_at` — and neither column is indexed in Migrations.swift. Verified plan for noteVersionIDs against the rebuilt real schema: `SEARCH v USING INDEX idx_container_kind (kind=?)`, i.e. a walk over every post in the corpus, with the correlated EXISTS evaluated for each born-archived row. Operations+Container.swift:387 calls it on the WRITE path, inside `try database.write { db in ... for versionID in try Queries.noteVersionIDs(db, of: id) }`. The EXISTS is correlated on v.id, so it cannot short-circuit: a note with no saved versions pays the full walk. Measured for a PLAIN note with zero versions: 0.15 ms at 2,005 containers -> 4.29 ms at 20,006 (and ~300-350 ms on a cold page cache). restoreContainer:428 pays the same shape through versionHistoryDeletedWith (`WHERE v.deleted_at = :stamp`, also unindexed; 0.11 -> 1.09 ms). Multi-select delete loops the whole operation (NoteDeletion.swift:139-147 `for id in postIDs { try ops.deleteContainer(id) }`), so selecting 50 notes costs 50 corpus walks in 50 serialized write transactions (~215 ms warm at 20k, far worse cold) during which every autosave blocks on the writer. Same root on the read side: noteVersions (held via observeNoteVersions, NoteVersions.swift:330 — 0.32-5.4 ms at 2k -> 11-15 ms at 20k warm, 353 ms cold) and archivedPosts' `NOT (versionHistoryPredicate(.anyLiveNote))` fence (held via observeArchivedPosts — 0.18 -> 5.22 ms).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism confirmed, magnitude corrected down. versionHistoryPredicate (NoteVersions.swift:174-186) really does have only `archived_at IS NOT NULL` and `archived_at = created_at` as non-subquery terms, neither indexed; the plan for noteVersionIDs against the rebuilt schema is `SEARCH v USING INDEX idx_container_kind (kind=?)` with the EXISTS as a correlated subquery, i.e. a walk over every post. The call site is exactly as quoted: Operations+Container.swift:383-387 runs it inside `try database.write`, and restoreContainer:428-431 runs versionHistoryDeletedWith the same way; NoteDeletion loops deleteContainer per selected note. So the shape is real and P1's letter is broken, and both doc comments (NoteVersions.swift:190-192 "never the corpus"; observeNoteVersions "P1: never the corpus") are false as written. What I could not reproduce is the consequence: my seeded probe measures 0.11 ms at 2,001 containers and 1.18 ms at 20,001 for a plain note — the `archived_at = created_at` test rejects almost every row before the EXISTS fires, so the walk is a cheap index scan plus a deferred row read, not the 4.29 ms claimed, and a 50-note multi-select costs ~60 ms warm rather than ~215 ms. The cold-cache figures (~300-350 ms) are unverified and I would not rely on them. Real, traced, and worth fixing (an index on the classifier, or narrowing the driver), but the actual cost at any corpus she will have this year is single-digit milliseconds inside a short write transaction — narrow, not a defect a user hits.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P20.

#### P21. Queries.activeFans issues one SQLite query per block in a Swift loop, on the held takes projection

`Sources/VariorumCore/Queries/TakesQueries.swift:123` · **MINOR** · CONFIRMED · perf-p1 · finder confidence 0.85

activeFans loops the block ids and runs a separate Variant fetch per block. takesProjection (TakesQueries.swift:87) passes every non-gap slot of the post, and takesProjection is the body of observeTakes (TakesQueries.swift:337), a held observation whose region includes `variant` — so it re-fires at autosave rate, issuing one statement per block each time. Measured on an 800-block note against the rebuilt real schema: 7.81 ms for the shipped N-query shape vs 1.96 ms for the equivalent single `block_id IN (...)` statement — ~4x. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. Both shapes are proportional to the note rather than the corpus, so this is a constant factor, not an asymptotic P1 break.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Accurate as written, including the self-correction that it is a constant factor and not a P1 break. TakesQueries.swift:119-133 is a per-block `Variant.filter(...)` fetch in a Swift `for` loop; takesProjection:87 hands it every non-gap slot of the post; observeTakes:333-338 holds takesProjection, and its region includes `variant` (renderPost and activeFans both read it), so it re-fires at autosave rate. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. I reproduced the measurement almost exactly on the seeded corpus: 7.23 ms for the N-query shape vs 1.98 ms for the equivalent single IN-list statement at 800 blocks (the reviewer got 7.81 / 1.96). Two things keep this narrow: cost is proportional to the note, never the corpus, so observeTakes' own doc ("bounded by construction (cost ∝ this post)") is TRUE and no documentation is falsified; and 800 blocks is a book-chapter outlier — an ordinary note of 20-50 blocks pays a few hundred microseconds of difference, off-main. Real, measured, trivially fixable, low consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P21.

---

## 17d — Purge & sync honesty *(the bridge half DISSOLVED 2026-09-04 — P30)*

**The `Sources/VariorumCore/Sync/` Fable rider binds P8, P9, P28 and P31.**

**Status: open, unstarted.** 4 items, no pins *(was 5: **P30 DISSOLVED 2026-09-04** — its file, `Sources/VariorumCore/Bridge/BridgeEngine.swift`, left `main` with the Fragments bridge's retirement, pre-13x batch 0b; the trace survives at tag `archive/fragments-bridge-2026-09-04`; found by that unit's cold review, MINOR-3)*.

The standing rider makes any change inside `Sources/VariorumCore/Sync/` sync-engine surgery and
therefore Fable work in every phase — that is not a cast decision this entry gets to make. *(P30 was
`Bridge/`, not `Sync/` — moot since its 2026-09-04 dissolution.)*

**P8 is the only finding in the entire sweep the verifier would not confirm by reading**, and it is
the highest-consequence one in this entry: a permanent, unrecoverable pull stall. Its next step is
therefore **not a fix and not a pin — it is a run.** The Phase 5 harness (two in-memory clients
against the in-process fake server) is where it either reproduces or dies, and *reproducing it is the
red-on-old pin*. If it does not reproduce, it is recorded as refuted and closed; the purge design's
own memo (`notes/plans/phase-13j-purge-memo.md` §4f) is the contract to read it against.

P31 (and P30, DISSOLVED 2026-09-04) are the honesty half: a permanently stalled cursor currently reports a **clean, successful
round forever**, and the bridge's shelving failure promises a retry in its own comment that the
advanced cursor makes impossible. Both are cases of the system telling her something is fine when it
is not — which in a sync engine is worse than the underlying fault.

### Items

#### P8. A purge expands the family from the local store only, so a peer row above the purging device's cursor is left on the mirror pointing at a container purged everywhere — a permanent, unrecoverable pull stall

`Sources/VariorumCore/Sync/PurgeJanitor.swift:175` · **MAJOR** · PLAUSIBLE · sync-correctness · finder confidence 0.50

PurgeJanitor.sweep() expands a purge family with `PurgeFamily.expand(db, roots: [root])` against the LOCAL store and hands exactly `expansion.orderedRows` to `transport.executePurge`; the server 'deletes EXACTLY the rows it is handed' with no orphan check (10_phase13j_purge.sql, sync_purge_execute). The horizon that gates eligibility is `min(transport.syncHorizon(...), cursor)` (PurgeJanitor.swift:114), and the device's own cursor sits at head-minus-the-A5-visibility-band (`server_written_at <= clock_timestamp() - interval '2 seconds'`, 10_phase13j_purge.sql:443/455) — so rows written on another device in the last ~2s exist on the mirror and are ABOVE this device's cursor when the sweep runs (the sweep is the round's last step, after pull and push). The intent road has no 30-day gate: collectRoots (PurgeJanitor.swift:318-340) makes a live intent eligible on `s.server_seq <= :horizon` alone. Concrete sequence: phone B creates block X inside note N offline; Mac A deletes N and Delete-Now's it; both devices pull the intent (that is what makes it horizon-eligible); B's next round applies N's tombstone — the container cascade tombstones X and its container_block row with N's exact stamp — and then PUSHES X plus its placement, landing above A's cursor if the push commits inside the visibility band; A's sweep in that same window expands N's family from A's store, which has never seen X, and purges only what it knows. The mirror keeps X's container_block row referencing a container that has been physically deleted from the mirror and from every device. No ledger entry names it (sync_purge_execute ledgers only what it was handed), and nothing re-collects it: reconcileLedger (PurgeJanitor.swift:277-291) expands the ledger roots on B and physically removes X locally there too, so no device holds a tombstone for it. A's next pull delivers that placement row; SyncEngine.foreignKeysSatisfiable resolves `container_block.container_id` -> `container` N, which exists neither locally nor in the arriving batch, so it returns false, stopIndex truncates, and the cursor holds forever — N can never arrive. Tombstoned rows get no exemption: the FK walk runs on every row regardless of deleted_at.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every code link checks out and no guard covers the case. (1) Repairs.swift:505-577 `enqueueSuppressedCascadeVictims` explicitly enqueues container_block/block/variant rows on a live→dead container transition applied from a pull — so a peer that has JUST learned the note is dead is REQUIRED by SyncSpec §7 direction (1) to push rows of that dead family, which directly contradicts the memo §2 premise "no peer can re-push them because no peer still believes the thing is live". (2) PurgeJanitor.sweep :138 expands with `PurgeFamily.expand(db, roots:[root])` against the LOCAL store and hands `expansion.orderedRows` to executePurge; PurgeFamily.expandContainer (:104-125) can only see rows this device holds. (3) 10_phase13j_purge.sql sync_purge_execute is exactly as quoted — `delete from %I where owner_id=$2 and %I=$1` per handed item, ledgering only what it was handed, no orphan check; the 'purged' push refusal keys on the row's OWN id, which the purging device never knew. (4) SyncEngine.foreignKeysSatisfiable (:503-515) introspects FKs from the live schema and has NO deleted_at exemption, so an arriving container_block whose container is neither local nor in-batch truncates the batch and holds the cursor — permanently, since the referent is gone from the mirror. (5) reconcileLedger (:277-291) expands the ledger roots and deleteLocal's them on the peer, removing the child LOCALLY only; nothing ever removes it from the mirror, and no device retains a root to re-collect it. The B2 fix and its pin `aReturnersUnpushedChildNeverLandsAsAMirrorOrphan` cover only the never-pushed variant, as the finding says. WHY PLAUSIBLE AND NOT CONFIRMED — one narrowing fact the finding understates: SyncEngine.pull sends `deviceID` only on the first window, where `since` is the PRE-pull committed cursor, so the peer's device_cursor (and hence the horizon) rises only on its NEXT pull — one full round after it pushed the child. By then the child is normally already visible and the purging device's own pull integrates it into the family, closing the hole. The orphan survives only inside the A5 visibility band (10_phase13j_purge.sql:443/455, `server_written_at <= clock_timestamp() - interval '2 seconds'`) or the pull→sweep gap, i.e. a ~2 s cross-device interleaving. That window is genuine, not hypothetical — FakeSyncServer already models it (`visibilityHorizon`, `holdPushes`/`commitHeldPushes` at :109-153, built for the A5 skew), so a deterministic repro is constructible: hold B's push, let A pull + sweep, release. Whether it is reachable in her real two-device use is a timing question I cannot settle by reading. Severity kept MAJOR: the outcome is a permanent one-way inbound jam (silent, given finding 1) recoverable only by re-onboard, and it falsifies a stated safety premise of the bent-S2 design — but no data is lost locally and the trigger is race-gated.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P8.

#### P9. expandContainer's member-block arm is liveness-conditional, so expanding a LIVE container purges the note and its placements while orphaning every block it held

`Sources/VariorumCore/Sync/PurgeFamily.swift:118` · **MINOR** · CONFIRMED · invariant-violation · finder confidence 0.50

PurgeFamily.expandContainer picks up member blocks with `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at` (PurgeFamily.swift:112-118). If the container row is LIVE, c.deleted_at is NULL and the equality is never true, so the expansion returns ZERO blocks — while the rest of expandContainer still takes all of container_block, lens, lens_choice, canvas_layout, reference, post_tag and reading_post for that container. The one call site that can hand it a live container root is the push path's ledger refusal, SyncEngine.swift:157-176, which expands from the pushed row with no liveness precondition: `let family = try PurgeFamily.expand(db, roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)]); try PurgeFamily.deleteLocal(...)`. Outcome on that path: the container row, its placements and its side rows are physically deleted; its blocks and variants stay LIVE, unplaced, and with last_container_id NULLed by deleteLocal's own detachment arm — the same zero-surface state as Finding 1, and permanently unpurgeable afterwards (a live row is never a tombstone root, and joinStrandedOriginals only reaches ancestors of family blocks). PRECONDITION, stated honestly: reconcileLedger normally screens this safely because a peer's executePurge ledgers EVERY family row, so the blocks arrive as roots of their own; reaching the live-container case needs the ledger scan point to have skipped that peer's entries — which the code itself records as possible (PurgeJanitor.swift:117-122, B9) — plus the row being live locally after a Put back. The reportable part is that B9's stated mitigation does not cover it: "those families re-collect through the 30-day road" is false for a LIVE container, which has no tombstone to re-collect.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The SQL claim is exact and I re-read it: PurgeFamily.swift:112-120 selects member blocks `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at`, so a LIVE container root yields zero blocks while lens/lens_choice/canvas_layout/reference/post_tag/reading_post AND every container_block row (collected by container_id, liveness-blind) still enter the family. deleteLocal then removes them; the surviving blocks/variants keep living, their last_container_id NULLed by the detachment arm, unplaced — invisible (the global unplaced listing is debug-only since J6) and unreachable by any later purge (a live row is never a tombstone root; joinStrandedOriginals returns immediately on an empty familyBlocks set). No FK failure catches it, because block→container is the nullable last_container_id that deleteLocal pre-nulls. I verified no call site guards liveness on the engine's `.purged` handler (SyncEngine.swift:169-175) or on reconcileLedger (PurgeJanitor.swift:~285, which filters only on rowExists). The finding's own cited road is weaker than it thinks and it says so honestly — a peer's executePurge ledgers EVERY family row, so the blocks are usually refused 'purged' as their own roots in the same push loop and self-heal. But a MORE reachable road it did not find strengthens it: PurgeJanitor.swift:179-186 re-expands inside the removal's own transaction AFTER executePurge, with no second verdict, and its own comment rules "a restore that raced the await loses to the purge" — a Put back landing in that network window makes the root live, so the note and its placements go while the just-revived blocks stay live and orphaned. familyVerdict's .stale check (PurgeJanitor.swift:441-447) closes the collection-time case but not this one. Contradicts PurgeFamily's own header contract ("purge is never partial"; the FK-closure argument does not cover the nullable pointer) and B9's stated mitigation ("re-collect through the 30-day road") is indeed false for a live row. Severity MINOR is right: deep race/skip preconditions, no crash or corruption, and the prose survives on disk — it just goes invisible.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P9.

#### P28. reapplyStructural is the only revive road that does not void purge intents; a leftover Delete-Now intent later claims the block and strips its 30-day recovery window

`Sources/VariorumCore/Operations/Operations+UndoInverses.swift:404` · **MINOR** · CONFIRMED · data-loss · finder confidence 0.75

revertDeleteBlock, revertDeleteVariant, restoreVariant and restoreContainerRows all call voidPurgeIntents when they flip a tombstone back, with the reason written at the site (13j ladder B, B1). reapplyStructural's untombstoningBlocks loop flips exactly the same block tombstone and does not. Trace: divide a block, type in the minted successor C (so revertStructural's `diverged` test at :300 stamps last_container_id and C lists in the note's tray) → ⌥⌘Z → press Delete Now on C in the tray, which mints a LIVE purge_intent for ('block', C) → ⇧⌥⌘Z, which un-tombstones C while the intent stands (single-device convergence is then saved only by the janitor's own .stale verdict at PurgeJanitor.swift:145-156) → but if she deletes C the ordinary way before the next sweep, the intent is still live and now names a genuinely tombstoned row: PoolAndTray.swift:107-109 fences it out of the tray (`pi.deleted_at IS NULL`), familyVerdict no longer reads .stale, and the janitor physically removes C at the horizon. C never appears in the Trash and never gets the 30-day window the ordinary delete promises.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The asymmetry is exactly as stated. voidPurgeIntents has five callers (Operations+UndoInverses.swift:63 revertDeleteBlock, :87 revertDeleteVariant; Operations+Placement.swift:129 restoreBlock; Operations+Deletion.swift:116 restoreVariant; Operations+Container.swift:468 restoreContainerRows; plus Operations+Reading.swift:156) — every road that flips a tombstone back, each with the 13j ladder B (B1) reason written at the site. reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) performs the identical block.deletedAt = nil + flipBlockCascadeTombstones transition and does not call it. The other two re-applies are safe by delegation (reapplyMintedContainer → restoreContainer, reapplyImportedBlocks → revertDeleteBlock), so this loop is the single hole. The consequence chain checks out: the fence predicates are stamp-aware and a LIVE intent (pi.deleted_at IS NULL) hides the row unconditionally (PoolAndTray.swift:107-109, Trash.swift:169 — whose own comment states the intended rule, "A VOIDED intent from before a re-delete never hides the fresh tombstone's row"), and PurgeJanitor.familyVerdict (:442-449) returns .stale only while the row is LIVE, so an ordinary re-delete before the next sweep flips the verdict to eligible and the janitor removes the bytes with no Trash listing and no Put back. Correctly rated MINOR: the janitor's .stale second net (PurgeJanitor.swift:151-156) closes it on the next sweep, so the hole is a redo→re-delete window of minutes-to-an-hour, and reaching it needs a tray/Trash Delete Now on an undone structural mint.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P28.

#### P30. The bridge's daily-book shelving failure is a one-shot ephemeral note, and its own comment promises a retry the advanced cursor makes impossible

**DISSOLVED 2026-09-04 — the Fragments bridge was RETIRED (pre-13x batch 0b; `notes/archive/fragments-bridge.md`); the file this item names no longer exists on `main`.** Kept below as the record of what was found; if the bridge ever returns as shared rows it returns without this engine.

`Sources/VariorumCore/Bridge/BridgeEngine.swift:240` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.85

pullAndLand commits the day agreement AND advances the pull cursor at :220-229, then calls ensureDailyBookMembership at :240-247. When shelving fails (store read failure, bookFinished, bookAtCapacity, wrongKind, refused — :334-357) it returns a note appended to report.landing.notes. That note is the ONLY record, and it is doubly unreliable. (a) It never recurs: the cursor is already past that Fragments row so transport.pull(after:) never serves it again, and even if it did, recordDay wrote the day's hash in the same transaction, so land() returns .skipped at :400-402, outcome.wroteToTheDay is false (:292-299), and ensureDailyBookMembership is never called again. The only other callers of Operations.shelveInDailyJournalBook are ⌘J (BookStructureModel.swift:657) and the phone's Today door — both need the author to open that exact day; nothing sweeps. So the comment's "the next bridge round retries it" is false. (b) It is discarded outright by any failure in the same round's push half: BridgeEngine.run() runs push AFTER pullAndLand (:169-170), push throws on transport.fetchLocalUserID() (:869) or transport.push (:909) — an ordinary network hiccup — and BridgeScheduler.runOneRound only publishes status.issueNotes on the success branch (:105), keeping the previous round's values on a throw (:106-118). Concrete run: her Fragments entry for 2026-09-01 lands into an at-capacity daily journal book; shelving returns the 'note cap' note; the push half then hits a 500 or offline. The entry is live in the Pool, permanently outside the Journal book, and nothing anywhere ever says so. Even on a clean round the note lives exactly one round in a hover tooltip (App/Variorum/Shared/BridgeStatusViews.swift:88) — the same posture the 9b round-2 MAJOR rejected for receipt notes ("the producing event is one-shot, so persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation", :1303-1311), which is why unrescuedBodyNotes (:752) and strandedDeletionDays (:845, :854-856) were made durable and recurring. BridgeDailyBookTests only asserts the note appears in the producing round's report (:193-194, :214-216, :261) — nothing pins persistence, so the gap is invisible to the suite.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in Sources/VariorumCore/Bridge/BridgeEngine.swift and BridgeScheduler.swift. The control flow is exactly as described: the day agreement + cursor advance commit in one write (~:220-229), then ensureDailyBookMembership runs (:240-247) and can only return a String appended to LandingReport.notes. The retry promise at :334-336 ("the next bridge round retries it") is FALSE on the path it annotates: the cursor is past that Fragments row, and even a re-served row hits the echo/replay skip at :400-402 (incomingHash == context.state) whose LandOutcome.wroteToTheDay is false (:292-299), so shelving is not re-attempted. I grep-verified there is no sweep: shelveInDailyJournalBook has exactly three production callers (BookStructureModel.swift:657 ⌘J, MobileTodayDoor.swift:45, and the bridge), none of which sweeps past days. The durability contrast is real and is the project's OWN doctrine, written 40 lines above the shelving code (BridgeEngine.swift:745-752: "the producing receipt was one-shot, so the persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation") — unrescuedBodyNotes re-reads from the store every round; the shelving note does not. Claim (b) also holds: BridgeScheduler.runOneRound assigns status.issueNotes only on the success branch (:105); a push-half throw discards the whole RoundReport including the landing's completed notes, and the catch branch's own comment ("a failed round learned nothing about them") is inaccurate for a round whose landing half succeeded. WHAT I DISCOUNTED, and why the severity drops: (1) no data is at risk — the entry is committed to the store before shelving is even attempted, and its bookless state is durably visible on the Pool surface (AppSpec: "Pool = bookless posts (R29)"); (2) the land-and-speak-on-the-round-note-surface posture is documented and ladder-adjudicated (phase-13c plan, A1 rule 1, naming LandingReport.notes → Status.issueNotes → the status row's "needs attention" as the surface); (3) bookFinished/bookAtCapacity/wrongKind are the author's own deliberate book states, which AppSpec explicitly forbids the bridge to override, and ⌘J speaks the same refusals; (4) "it never recurs" is overstated — any later WRITING landing on that day re-runs shelving and re-emits the note, so the gap is only for days Fragments stops touching. What survives is a real notification-durability gap plus a demonstrably false in-code retry promise — narrow, not user-facing loss.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P30.

#### P31. A permanently stalled pull cursor is reported as a clean, successful sync round forever — PullReport.stalled has no production reader

`Sources/VariorumCore/Sync/SyncScheduler.swift:196` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.85

SyncEngine.pull() truncates the batch at the first row whose FK closure is unsatisfiable (the straggler guard). When that is the FIRST row, stopIndex == 0, so `newCursor = since` — the cursor does not move, no row is applied — and pull() RETURNS NORMALLY with `report.stalled = true` (SyncEngine.swift:371-374). SyncScheduler.runOneRound discards the report (`_ = try await engine.pull()`) and then unconditionally executes `status.lastError = nil` / `status.lastErrorIsOffline = false` / `status.lastSuccessAt = date.now`. Concrete outcome: with one permanently unresolvable row in the changefeed (see the purge-orphan finding for one way to create one), every subsequent round integrates ZERO server rows while the status surface reports "last success: just now" indefinitely. Pushes are unaffected, so local writes keep flowing to the mirror and the two stores diverge one-way, silently, under a green light. `grep -rn 'stalled' Sources/ App/` finds no production consumer — only Tests/VariorumCoreTests/SyncPullTests.swift:162,326. PushReport.deferred (rows left enqueued because their referents never arrived) is discarded the same way. The pattern exists and was deliberately applied in the sibling subsystem: BridgeScheduler.swift:104 does `status.stalled = report.landing.stalled`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. SyncEngine.swift:371-374 sets `report.stalled = stopIndex < batch.count` and holds the cursor at `since` when stopIndex == 0. The ONLY two production callers of pull() are SyncScheduler.swift:196 and VaultBootstrap.swift:167, both `_ = try await engine.pull()`; grep over Sources/ + App/ finds no other reader of PullReport at all, and `stalled` appears only in SyncPullTests. runOneRound then executes lastError=nil / lastErrorIsOffline=false / lastSuccessAt=date.now unconditionally, and SyncStatusViews.swift:335 renders that as "Synced <time>". PushReport is discarded the same way, and BridgeScheduler.swift:104 does surface its twin signal, so the pattern is a deliberate one applied next door and not here. TWO MITIGATIONS THE FINDING MISSED, which is why I cut the severity: (a) the field is documented in-code as "the last round that COMPLETED WITHOUT ERROR" — under a stall that is literally true, no exception was thrown; (b) the stall is NOT wholly invisible — DataSafetyModel/SyncSafetyWords.cursorDetail renders "Received everything your account had through change #<cursor>", so a frozen cursor is on a user-facing surface, and that sentence stays honest under a stall (the headline "Everything written on this Mac has reached your account" is about the push half and is also unaffected). The harm therefore needs a PERMANENT poison row, and the permanent-jam class is already an owned KnownIssues row ("Poison-row isolation / park-and-heal", owner 12) whose remedy is to be assessed against soak evidence — soak evidence read from cursors and row counts, not from this in-memory flag, so "unmeasurable by the soak" is overstated. Real, cheap to fix (one line, the BridgeScheduler precedent), narrow in consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P31.

---

### CLOSED 2026-09-22 — the dispositions (RUN B; the record is `notes/plans/run-b-sync-correctness.md`)

**P8 CONFIRMED then FIXED — the entry's own rule discharged both ways:** B1 REPRODUCED it in BOTH
constructions (held-push + the A5 visibility band; "reproducing it IS the pin"), and B2 built the
ruled fix (Shape A: the ledger-verified orphan heal through EXISTING RPCs — zero server lines —
with the tombstone-only narrowing; hardened at the ladder: F-R4 scoped the completion set to the
stall's present referents' FK-connected family, F-R5 reordered the guards). The permanent one-way
jam clears in bounded rounds; the mirror stops hosting a purged note's ciphertext. **P9 FIXED**
(the live-root family-complete expansion; the Put-back-races-the-sweep road pinned). **P28
FIXED** (the redo road voids purge intents like its six siblings). **P31 FIXED** (`PullReport.stalled`
+ `PushReport.deferred` gained production readers; a stalled round STOPS reporting "Synced" —
the honest `.stalled` face, clean-branch only). P30 stood DISSOLVED (2026-09-04, the bridge's
retirement). Every fix red-on-old by behavioural revert, commit-first. **THE LIVE-ROUND
ACCEPTANCE LEG: PASSED — her 2026-09-22 morning round** (convergence both directions on the
real mirror, no stall warning — "yep it worked"; the evidence record is the run plan's LIVE
ROUND slot). 17d's acceptance is complete.

## 17e — Correctness & honesty singles

**Status: CLOSED 2026-09-30 — both halves ran.** 18k's C5 closed the concurrency five (2026-09-25, the dispositions below); **18o closed the remainder (2026-09-30 — the record is `notes/plans/phase-18o-correctness-singles.md`; a two-round Fable ladder, zero BLOCKER/MAJOR, zero disputes)**. The 18o dispositions are copied below. *(Original ruling R-18k-1 at the 18k kickoff sitting, 2026-09-25 — "plan a single extra session, split items appropriately between them, give it an 18 name".)* 18k's C5 takes the stale-fact / in-flight concurrency five — **KnownIssues row 59 (Canvas focused-block fact) · P26 · P27 · P33 · P38**; **18o** (correctness & honesty singles, right after 18k) takes **P23 · P29 · P32 · P34 · P35 · P37 · item (12) · KnownIssues row 66** (her #138(f) ruling R-18k-5: *honor the tombstone at launch*) **· KnownIssues row 64** (RECORD-ONLY — her #136(b) ruling R-18k-4: *leave it for now*). **Item (11) is partly DISCHARGED already** (18d wired `forgetCurrentBlock` into the Mac's Delete Now, `RecoveryView.swift:489`; the remainder is ACCEPTED at its arithmetic on KnownIssues' per-note-view-state row, owner 12) — 18o records it. The records are `notes/plans/phase-18k-runtime-hygiene.md` and (when authored) `notes/plans/phase-18o-correctness-singles.md`; dispositions are copied HERE at each run's close.

*(Original status line: open, unstarted — 10 items, no pins.)*

**Added 2026-09-02 (the Act 10 correction round's ladder, round 1 — RECORDED with this owner; the mechanisms in `notes/plans/act10-correction-round.md` `## LADDER ROUND 1` R1-15 and R1-18):** **(11)** the per-note `UserDefaults` families `currentBlock.<id>` · `postMode.<id>` · `readFace.<id>` are never reaped — deletion, the purge and Delete Now leave the keys (`CommandRouter.forgetCurrentBlock` exists with no production caller); a sweep at note purge is the fix. **(12)** `.toggleSidebar` is declared `availability: always` while its menu item greys on `activeWindowKind != .full` — a gate the registry walk cannot see; a `windowKind` field on `CapabilityContext` makes the grey a registry fact (P-1).

Ten unrelated defects, each small, each traced. No shared mechanism — this is the catch-all, and it
is the entry most likely to be split when it is actually run.

Worth pulling out of the pile: **P23** (a CRLF file imports as ONE block — `SegmentationRules` splits
on `\n` only) is the kind of thing that will look like data loss to a user importing from Windows or
from an email; **P26** is a genuine liveness race that ends with two editors `isLive` at once, which
is a P3 violation and the exact thing `PaneTextAuthority` exists to make impossible; **P27** and
**P29** are both cases of a *document* — a code comment, a door's own doc — describing behaviour the
code does not have, which is the class that costs the next session the most time.

### Items

### 18k's C5 — the dispositions (2026-09-25; the record is `notes/plans/phase-18k-runtime-hygiene.md`'s UNIT C5 RECORD + its ORCHESTRATOR ADJUDICATION)

### 18o — the dispositions (2026-09-30; the record is `notes/plans/phase-18o-correctness-singles.md`, per-unit RECORDS + ADJUDICATIONS)

- **P23 — FIXED at 18o U2** (`12d61080`): `bulkSegments` reads CRLF/CR as LF at its entry (normalise-at-entry, NOT `isNewline` — the M-isNewline mutation proves the rejected design breaks the typed Control-Return guards); `crystallizedBoundary` untouched; pins `SegmentationLineEndingTests` (core, red-on-old 29) · `CRLFImportDoorTests` (Mac, 6) · `MobileCRLFCaptureTests` (phone, 3); walk W1 both voices. The phone's capture inherits through the shared op.
- **P29 — FIXED at 18o U1 (doc-only)** (`e2a6ecf0`): `MobileUndoDoor.redo()`'s doc states the truth (redo overwrites a since-edited buffer behind a quiet insurance savepoint); no behaviour change owed (A12 named undo alone); no pin possible.
- **P32 — FIXED (doc) + RECORDED at 18o U1** (`a1479bba`): the false persisted-picks premise corrected at `danglingPick`; the UX gap NAMED with options at QUESTIONS **#160** (OPEN, hers; (i) extend-the-notice recommended). Nothing built, per R-18k-1's letter.
- **P34 — FIXED (doc) + PINNED at 18o U1** (`9068f624`/`54f91c72`): the "always wins" parenthetical corrected; the strong-boundary-at-exactly-settlePull configuration pinned as documented behaviour (proven able to fail — M-exact 3 issues); the exact-wins alternative is QUESTIONS **#161** (hers; behaviour stands).
- **P35 — FIXED at 18o U1** (`915e8124`, pins `0ae75e59` red-on-old 4): `setShelfPinned` self-heals like `starred` — pin needs a live book, unpin never does, every write persists the live list; walked (W2: delete-then-pin heals the dead id; Put back returns the book UNPINNED — `starred`'s own documented shape, in her bundle).
- **P37 — FIXED at 18o U1** (`6c61d562`, pins `74d4c45a` red-on-old 1): the tray's ARCHIVED arm windowed with its truncation marker, its siblings' shape.
- **17e (11) — RECORDED at 18o U1:** partly discharged at 18d (`RecoveryView.swift:489` wires `forgetCurrentBlock` into Delete Now, evicting `currentBlock.<id>` + persisted surface sizes); the remainder ACCEPTED at its arithmetic on KnownIssues' per-note-view-state row (owner 12). **Correction found at the code:** `postMode.<id>`, `readFace.<id>` and `takesViewMemory.<id>` are evicted by NO production road, Delete Now included — that row's text amended at the 18o closeout; same accepted arithmetic.
- **17e (12) — FIXED at 18o U1** (`e724032f`, pins `b24d801a` red-on-old 3; the revert reds all four sidebar pins, 8): `CapabilityContext.windowKind`; `.toggleSidebar`'s grey is a registry fact (P-1); walked (W1). The same-class sweep found ONE more silently-gated family (the creation/restore seven) — a KnownIssues row, owner 12's registry-walk family.
- **KnownIssues row 64 — RECORD-ONLY (R-18k-4, *leave it for now*):** the documented-behaviour pin re-verified green at 18o U1 (5/5, and by the orchestrator 47/4); the row CLOSED as ruled at the 18o closeout; a note-scoped undo is a future design at her word (QUESTIONS #136(b)).
- **KnownIssues row 66 — FIXED at 18o U2** (`14822213`, R-18k-5 *honour the tombstone at launch*): ONE predicate (`SampleLibrarySeeder.readerDeletedTheBook`) read by the ensure AND the launch at both deciding reads, the decision recorded in the mark; pins Mac 15 · mobile 2 red-on-old; walks W2/W3 (explicit restore still mints). **The #146 neighbour BUILT PROVISIONAL at 18o U6** (the Fable seat, `Sync/` — the signed-out-first retirement; her ratify bundled).

- **KnownIssues row 59 (Canvas focused-block fact) — FIXED** (`bc5e8cf9`; pin `CanvasFocusedBlockFactTests`, `4eb91dad` — red-on-old 5 issues, behavioural revert identical).
- **P26 (the phone's liveness grant) — ALREADY FIXED by `6bc4f187` (2026-08-30); the missing pin ADDED** (`ebd690e6`: `MobileLivenessTests.aGrantSuspendedInsideItsFlushNeverResumesIntoThePen` — green on HEAD; deleting only the post-suspension guards turns it red, 2 issues). No product code changed.
- **P27 (⌘⇧M read the frozen `slots`) — FIXED** (`dee61938`; pin `FannedDefaultsTests.aFanArrivingWhileSheIsTypingIsCarriedByTheMerge`, `98880463` — red-on-old 2 issues, revert identical). The ceremony branch's sibling residue → KnownIssues, owner 18o.
- **P33 (⌥⌘Z had no in-flight latch) — FIXED, and ⇧⌥⌘Z shared the shape** (`65aa05fa`; pins in `DestructiveUndoWarningTests`, `8a172f7a` — red-on-old 9 issues, revert identical; the undo-only mutation reds the redo pin alone). One session latch for both doors; the refusal is the phone's sentence, now `StructuralUndoCopy.anotherIsLanding` (the phone forwards byte-identically).
- **P38 (`StoreBackup.run` had no single-flight latch) — FIXED** (`3f480486`; `BackupSingleFlightTests`, `824dfebf` — red-on-old 3, revert 3, each mutation its own pin). The double run reproduced 80/80 on old; the false "failed" consequence P38 describes was NOT reproducible (0/80) — recorded plainly, the latch closes the race regardless.

#### P23. SegmentationRules splits on "\n" only, so a CRLF file imports as ONE block instead of one block per paragraph

`Sources/VariorumCore/Domain/SegmentationRules.swift:67` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.95

`"\r\n"` is a SINGLE Swift Character and is not equal to Character("\n"), so `text.split(separator: "\n")` finds no separator in CRLF text. VERIFIED by running Swift: `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` == 1; `Character("\r\n").isNewline` == true; `.trimmingCharacters(in: .whitespaces)` leaves it unchanged. Traced path with no normalisation anywhere: ImportModel.readFiles (App/Variorum/Variorum/Features/Import/ImportModel.swift:164-170) does `Data(contentsOf: url)` -> `String(data:encoding:.utf8)` -> Operations.importPost (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `bulkSegments(text, mode:)` -> returns `[wholeFile]` -> `mintSegments` mints ONE block. INPUT: drop a Windows-authored `.md`/`.txt` on the library. OUTPUT: a note whose entire body is one block — no per-paragraph blocks, takes, lineage or reordering, and a document-sized single variant; silent, nothing refuses. Same door serves quick note (13f W5 `undoLabel:`) and mobile capture. The rest of the family disagrees with this file: BoundarySnapping.paragraphBoundaries:280, MarkdownSyntax.spans:183, MarkdownEditing.lineRanges:365 and MarkdownRendering.render:166 all key on `Character.isNewline`, which is TRUE for "\r\n", "\r", U+0085, U+2028, U+2029 — MarkdownRendering.swift:190 even says "a \r\n is one Character and stays one." Only the segmenter uses a literal "\n". No CRLF fixture exists anywhere in the suite (grep over Tests/ and both app test targets).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end and re-measured independently. (1) The Swift fact holds: I ran `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` and got 1, with `Character("\r\n").isNewline == true`. (2) The road is real and unguarded: `ImportModel.readFiles` (App/Variorum/Variorum/Features/Import/ImportModel.swift:157-172) does `Data(contentsOf:)` -> `String(data:encoding:.utf8)` with NO line-ending normalisation, hands the raw text to `Operations.importPost` (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `SegmentationRules.bulkSegments(text, mode:)`. (3) In `.paragraph` mode (the schema seed `('default_segmentation','paragraph')`, resolved by `globalSegmentation` at Operations+Import.swift:88-92) the single un-split 'line' is not blank, so `trimmedPiece` returns the whole file and ONE segment comes back; `mintSegments` (Operations+Import.swift:98-111) mints exactly one block per segment, so the whole document becomes one block/one variant. Nothing refuses, nothing warns. (4) I searched for any normalisation or prior decision: `grep -rn 'CRLF|line ending' notes/` returns exactly ONE hit, notes/plans/phase-13d-refusal-ergonomics-floor.md:3016, and it is about a DIFFERENT function — `seamTrimmedHalves`' `count(where: \.isNewline)` — where it correctly reasons that grapheme clustering makes `\r\n` safe. So the class was reasoned about and this call site was missed; it is NOT an owned tradeoff. (5) The finding's family claim checks out: BoundarySnapping's paragraph/word scanners, MarkdownSyntax, MarkdownEditing and MarkdownRendering all key on `Character.isNewline` (true for `\r\n`); only the segmenter uses a literal `"\n"` Character comparison, which grapheme clustering makes false for CRLF. Severity kept at MAJOR: silent, deterministic, on a shipped user-facing door, and it defeats the block-as-atomic-unit for the entire imported note (no fan/reorder/divide/lineage granularity, one document-sized variant). Held BELOW blocker deliberately — no text is lost or corrupted, the paragraphs still render as content under I4, and recovery is re-import after conversion. Sentence mode degrades less (its scanner keys on `isWhitespace`, which is true for `\r\n`), so paragraph mode — the default — is the exposed one.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P23.

#### P26. MobileLivenessAuthority.takeLiveness grants the pen from a stale continuation — two editors end up isLive at once

`App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift:107` · **MAJOR** · CONFIRMED · concurrency · finder confidence 0.75

`takeLiveness` writes `live = editor` (:112) BEFORE two suspension points (`await editor.autosave.flushNow()` :113, `await editor.refreshTakesFromStore()` :115) and hands the pen over AFTER them (`editor.noteLivenessGranted()` :117), with no check that `live` is still this editor. The caller fires an unstructured, unlatched Task per tab tap (MobileShellView.swift:303 `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }`), so two taps interleave. Trace: (1) tap tab B — Task1 stands down editorA, sets `live = editorB`, suspends inside editorB's flush (a real GRDB write through OperationsRunner); (2) tap tab A before that write returns — Task2's loop calls `editorB.standDown()` (isLive=false, endEditing(true), isEditable=false), sets `live = editorA`, flushes, refreshes, grants A; (3) Task1 resumes and calls `editorB.noteLivenessGranted()`, which sets `isLive = true` and `textView?.isEditable = true` (MobileEditorViewModel.swift:296-301). End state: `live === editorA` while editorB is also isLive and editable.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified line by line. MobileLivenessAuthority.swift:107-118: `takeLiveness` stands down siblings synchronously, sets `live = editor`, then awaits `editor.autosave.flushNow()` (AutosaveCoordinator.swift:142 — a real suspension, `try await runner.run { ops.autosave(...) }` per pending variant) and `editor.refreshTakesFromStore()`, and finally calls `editor.noteLivenessGranted()` with NO re-check that `live === editor`. `@MainActor` does not serialize across suspensions, so this is a textbook check-then-act-across-await. Confirmed the entrant: MobileShellView.swift:296-306 fires an unstructured, unlatched `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }` per tab tap with only `guard tab != target`, so a second tap enters concurrently; MobileWriteView.swift:168 `await router.editors.register(model, tab: tab)` is a second unlatched entrant. noteLivenessGranted (MobileEditorViewModel.swift:296-301, file is at Features/Write/, not Features/Editor/ as cited) and the gate belt (:1200-1205) are exactly as quoted. TWO partial refutations, both stated honestly by the finding's own end state: the hidden stack is `.allowsHitTesting(tab == .shelf/.library)` (MobileShellView.swift:126,138) and standDown already resigned first responder, so the wrongly-granted hidden editor has no keystroke road, and the next tabDidBecomeVisible heals it. BUT I traced a strictly worse ordering of the same defect that the finding did not: if Task1 suspends in `fileOnLeaving()` (a non-empty quick note mints — MobileQuickNote.swift:809) and Task2 runs takeLiveness(A) to completion first, Task1 then resumes into takeLiveness(B), STANDS DOWN A, and grants B — leaving the VISIBLE note uneditable and refusing with 'This note is live in your other tab.' until the user navigates away and back. That is user-visible wrong behavior from the same missing re-check, so MAJOR stands.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P26.

#### P27. The ⌘⇧M merge threshold reads the deliberately-frozen `slots` projection, so a fanned merge silently falls through to the un-carrying instant merge — and the receipt naming the lineage road is suppressed with it

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:277` · **MINOR** · CONFIRMED · invariant-violation · finder confidence 0.85

`applyStructural`'s `.merge` arm decides carry-all vs instant from `model.slots[i].activeVariantCount`, an array `EditorProjectionPolicy` deliberately freezes while the editor is busy. Trace: (1) she is typing ⇒ `autosave.isDirty == true`; (2) a take arrives on block B from the phone or a sync-applied conflict variant, `observeSlots` delivers, `EditorProjectionPolicy.decide(busy: autosave.isDirty || mintInFlight || structuralInFlight, …)` returns `.deferUntilClean` (EditorViewModel.swift:638-663) so `slots` is not updated and B's activeVariantCount stays 1; (3) ⌘⇧M on the A|B seam reads trailingArity == 1 and takes the `else` arm ⇒ `runInstantMerge`; (4) `runInstantMerge` never re-reads the store and computes `otherTakes = mergedAwayTakes([...])` from the SAME stale slots ⇒ 0; (5) `runStructural` flushes successfully, `ops.merge(A,B)` runs — merge accepts fanned blocks by design — and B is released to lineage with its real fan behind it; (6) `speakAboutMergedFans(0)` returns at its `guard otherTakes > 0` so nothing is said. `applyPendingIfClean` cannot rescue it: `runStructural` sets structuralInFlight = true before flushing and that method guards on `!structuralInFlight` (EditorViewModel.swift:795). The false-positive direction IS guarded (`runCarryAllMerge` re-reads via `liveActiveFans` and falls back), and the divide twin guards both directions (`runDuplicatingDivide` reads the store; a stale-unfanned divide is caught downstream because `ops.divide` throws `.fannedBlock`). `ops.merge` throws nothing on a fanned block, so this path has no backstop at all.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified in full, severity corrected down. EditorSurfaceController.swift:276-297: `leadingArity`/`trailingArity` come from `model.slots[...].activeVariantCount`, and the `else` arm calls `runInstantMerge` with no store read. EditorProjectionEngine.swift:148-156 pins the precedence `not-loaded ▸ busy ▸ forced ▸ echo ▸ …`, so `busy` (autosave.isDirty || mintInFlight || structuralInFlight — EditorViewModel.swift:646) wins over the echo arm and `.deferUntilClean` sets `pendingProjection` WITHOUT touching `slots` (EditorViewModel.swift:661-662). `runInstantMerge` (:357-374) reads `mergedAwayTakes` from the same stale slots, so `speakAboutMergedFans` returns at its `guard otherTakes > 0` (:340) and nothing is said. `applyStructural` does not flush before the arity read (the flush happens inside `runStructural`, after the fork). The asymmetry claim is exact: `ops.divide` throws `.fannedBlock` (Operations+Structural.swift:198-202) so a stale-unfanned divide is caught downstream, while `ops.merge` (:659-674) guards only adjacency — no fan check at all. Both sibling roads read truth: `openMergeCeremony` (:1045) and `runSeamMerge` (:1705) call `liveActiveFans`, whose own doc comment (:1748-1753) states "From the store — never `model.slots`, which is deliberately stale while the editor is busy", and `planSeamMerge`'s doc (:1668-1676) says a plan-time projection read "is an enablement hint, never an authorization" and that a fan arriving mid-burst stops the merge (pinned). The ⌘⇧M door alone lacks that authorization read in the false-negative direction; the inline comment at :266-268 documents only the false-POSITIVE fallback. Severity corrected MAJOR→MINOR: reaching it needs an external take to land on one of the two blocks inside the dirty/flight window AND an immediate ⌘⇧M; the outcome is the pre-2026-08-09 shipped default (takes stay on the released sources), fully recoverable via lineage and ⌥⌘Z, with no invariant (I1–I10) violated. Worth noting it is a sibling of a class already owned by 13u1 item 8 (`BlockRangeIndex.wholeBlockDeletion`'s frozen-projection fan fence), at a road that row does not name.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P27.

#### P29. The phone's redo door documents a mechanism the code does not have — reapplyStructural DOES overwrite a buffer edited since the undo, silently

`App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift:225` · **MINOR** · CONFIRMED · drift · finder confidence 0.85

reapplyStructural's restoringTexts loop overwrites working_text with postOpText and carries its own insurance commit for precisely the case the comment says cannot occur. Trace: divide(A) at a cut → ⌥⌘Z restores A's buffer to the full pre-cut text → she types a new sentence into A → ⇧⌥⌘Z → at Operations+UndoInverses.swift:431-437 `variant.workingText != preImage.postOpText` is true, `variant.workingText != preImage.text && isDirty` is true so a quiet auto-commit is inserted, then `variant.workingText = preImage.postOpText` drops her new sentence off the surface with nothing said. The doc comment asserts redo 'discards nothing she typed'; reapplyStructural's own doc two files over states the opposite ('a buffer the author edited since the UNDO is about to be overwritten by the post-op text').

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The comment and the code do contradict each other. MobileUndoDoor.swift:224-226 asserts redo "discards nothing she typed"; reapplyStructural (Operations+UndoInverses.swift:426-438) skips only when workingText already equals postOpText, otherwise takes a quiet auto-commit when the buffer diverged and is dirty (:432-434) and then assigns variant.workingText = preImage.postOpText (:435) — and its own doc at :344-348 says plainly "a buffer the author edited since the UNDO is about to be overwritten by the post-op text." The divide/extract registrations (Operations+Structural.swift:246-249, :153-156) do pass restoringTexts, so the branch is live on the everyday road (undo a divide, keep typing in the rejoined block, redo). Note the substance split: the BEHAVIOUR is not a defect — A12 named undo alone and no pendingRedoWarning exists on either platform, which is deliberate — so what stands is the false door comment, and it is false even in the door family's own vocabulary (the undo road also insures first yet is still called "discarding", per StructuralUndoCopy.discardingUndoQuestion and MobileUndoDoor.discardingUndoDetail's "that writing is set aside"). Held at MINOR rather than NIT: it is not cosmetic — it asserts the opposite of a text-discarding behaviour, the class this codebase has corrected as real findings before (the LR2-1 doc correction inside restoreNoteVersion's own comment). No behaviour change is owed; the comment is.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P29.

#### P32. Scratch-column picks ARE persisted to UserDefaults, so the dangling-pick notice is scoped out of them on a false premise

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1196` · **MINOR** · CONFIRMED · spec-conflict · finder confidence 0.90

`danglingPick` restricts the J5 archived-pick notice ('say loudly if that take was archived and this is a fallback WITH a button for quick restore') to lens columns, justifying the exclusion with 'a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session'. That premise is false: `TakesColumn.picks` is a stored `Codable` property (TakesModels.swift:33), `TakesViewMemory` wraps `columns` and JSON-encodes them into UserDefaults (TakesModels.swift:59-73), and every scratch pick write calls `saveMemory()` (TakesViewModel.swift:852-854 → :683). Path: pick take T in a scratch column → archive T (TakesViewModel.swift:1171) → quit → relaunch. The column reloads from UserDefaults still naming T; `resolvedTake` (TakesViewModel.swift:487-499) silently falls through to the block's chosen take; `danglingPick` returns nil, so no notice and no Restore button ever render — permanently, not for one session. The model's own docstring contradicts the comment: 'A view-local profile: sparse picks over chosen, persisted only via VIEW MEMORY' (TakesModels.swift:21-23). This is also what makes the promotePicks defect above silent and long-lived rather than a same-minute slip.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The comment's factual premise is false, verified directly. TakesModels.swift:28-34: `struct TakesColumn: Identifiable, Equatable, Codable` with `var picks: [String: String] = [:]`; TakesViewMemory (:58-73) wraps `columns` and JSON-encodes them into UserDefaults under `takesViewMemory.<postID>`; TakesViewModel.saveMemory (:683-686) writes it, the init (:49-52) reads it back, and every scratch pick write calls saveMemory (:751-752, :850-854). So a scratch pick DOES survive a relaunch, contradicting TakesViewModel.swift:1196-1198 ("a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session") — the model's own docstring at TakesModels.swift:21-23 says "persisted only via VIEW MEMORY". Consequence traced: nothing prunes picks on archive/delete (checked every `picks` site; applyProjection at :433-447 prunes only dead-lens columns and the merge selection), resolvedTake falls through silently (:487-499), and danglingPick returns nil for non-lens columns (:1199-1204) — the notice is rendered only at LensesBoardView.swift:586, so a scratch column shows an unpicked take with nothing saying so, indefinitely. Two corrections to the finding's framing, neither refuting it: (a) the 13j J5 ruling as recorded in the master plan is scoped to a SAVED LENS's pick ("when a saved lens's pick dangles at an archived/deleted take (the core's read-time fallback, `effectiveLensSelection`)"), so scoping the notice to lens columns is not itself a spec violation — what is wrong is the REASON given for it; (b) the surviving defect is therefore a false code comment plus a real but unruled UX gap. MINOR is the right weight; it is not cosmetic, because the same persisted stale pick is the input to the promotePicks defect above.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P32.

#### P33. The Mac's ⌥⌘Z has no in-flight guard, so the A12 destructive-undo confirm can describe a different entry than the one actually undone

`App/Variorum/Variorum/Registry/ShellActions.swift:111` · **MINOR** · CONFIRMED · concurrency · finder confidence 0.70

structuralUndo spawns a Task with no re-entrancy latch and reads the stack twice across two separate runner submissions: pendingUndoWarning (which reads entries.last) and then undo (which reads entries.last again). Two ⌥⌘Z presses landing inside the runner round-trip queue as T1.warn, T2.warn, T1.undo, T2.undo — both warnings are computed against entry E, but T2 undoes E-1. If E is not in the insurance class and E-1 IS, T2 shows no confirm and the discarding undo runs anyway; if the reverse, she is asked about a discard that is not happening. The phone's twin door guards this exactly (MobileUndoDoor.beginUndo: `guard !inFlight else { model.report(Self.anotherIsLanding); return }`), so the Mac is also the drifted copy of a shared rule.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Read both doors. ShellActions.structuralUndo (App/Variorum/Variorum/Registry/ShellActions.swift:111-137) spawns Task { @MainActor } with no latch and makes two separate awaited runner submissions — pendingUndoWarning then undo — each of which reads entries.last independently (UndoStack.swift:250, :266). MobileUndoDoor.beginUndo (:144-149) guards the identical sequence with `guard !inFlight` and its comment gives this exact reason ("a second press inside the first's suspension would pop a second entry she never asked for"), and confirmPendingUndo re-takes the latch at :181 — so the Mac is the drifted copy of a rule the phone states. The only Mac gate is stack-depth enablement (EditorCommands.swift:331 `.disabled(session?.undoMenuState.topLabel == nil)` and CapabilityRegistry.swift:924 `ctx.undoAvailable`), neither of which changes during the flight. The reachable shape is the no-warning one (E silent, E-1 in the insurance class): both tasks compute nil warnings against E, no modal blocks the MainActor, and the second undo discards E-1's buffer without the A12 confirm. The reverse shape self-limits because confirmDiscardingUndo runs a modal NSAlert. MINOR is right — revertStructural's own insurance commit (:284) still rides inside the undo transaction, so the cost is the ruling being skipped, not the bytes.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P33.

#### P34. BoundarySnapping.settle overrides a deliberate EXACT cut placement when a sentence end sits exactly settlePull units earlier, contradicting its own documented contract

`Sources/VariorumCore/Domain/BoundarySnapping.swift:147` · **NIT** · CONFIRMED · spec-conflict · finder confidence 0.95

`effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, and the comparator breaks an effective-distance tie toward the EARLIER position. A strong boundary exactly `settlePull` (=2) units before an exact placement therefore also scores 0 and wins the tie. VERIFIED by running the verbatim function: text "Yes. I went home." has word boundaries [0,5,7,12,17] and strong (sentence) boundaries [0,5,17]; `settle(7, in: text, among: [5,7,12])` returns 5 — 7 is an exact word edge and loses. Second sample "Hi. A word here.": `settle(6)` returns 4. Reachable whenever a one-letter word ("I", "A", "O") follows a sentence end, which is constant in English prose. INPUT: the author drags the divide cut to sit exactly before "went". StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) — the ONE snapper for plain divide, the W ceremony's per-take cuts, CutPropagation's seeding and extract's span edges — moves it two units left. OUTPUT: the divide yields "Yes." + "I went home." where she placed "Yes. I" + "went home.", silently. The suite's own comment at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-144 asserts "Cut 9 is exact: the deliberate placement always wins", but its fixture's strong/plain gap is 4, so effectiveDistance(5)=2 and the exact cut wins for a reason that evaporates at gap <= 2 — no test stands at the boundary the invariant lives on.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by COMPILING AND RUNNING the real BoundarySnapping.swift (not a replica): for "Yes. I went home." the scanners give word boundaries [0,5,7,12,17] and strong (sentence) [0,5,17], and `settle(7, among: [5,7,12])` returns 5 — the exact word edge at 7 loses. Second sample "Hi. A word here.": `settle(6, among: [4,6,11])` returns 4. Mechanism confirmed at BoundarySnapping.swift:145-152 — `effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, so a strong boundary exactly 2 units earlier also scores 0 and takes the tie via `da == db ? a < b`. Production-reachable: StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) is the only snapper for divideAtCursor, the W ceremony's per-take cuts and CutPropagation, and it passes the raw cut with the full interior word set. The test-comment claim at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-146 is also as described — its fixture's strong/plain gap is 4, so the exact cut wins there for a reason that evaporates at gap <= 2, and no test stands at the boundary. SEVERITY CORRECTED DOWN to NIT, and this is the part the finding over-reads: the pull is the deliberate S4-22 gentle-settle feature, and the tie-to-earlier rule is stated explicitly in the SAME doc comment (line 138-139) and exercised deliberately by the neighbouring test's cut-8 case. What is actually wrong is the absolutist parenthetical at line 130-131 plus a missing boundary pin; the behavioural consequence is a 2-unit shift confined to the one-character-word-after-a-sentence-end configuration (". I ", ". A "), where relocating the cut to the sentence end is arguably the settle doing its job. Not a user-facing correctness defect of the kind MINOR implies.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P34.

#### P35. `shelf_pins` never self-heals and a deleted book's pin can never be removed, unlike its self-healing sibling `starred` in the same file

`Sources/VariorumCore/Operations/Operations+Appearance.swift:117` · **NIT** · CONFIRMED · drift · finder confidence 0.90

setShelfPinned's public door runs `_ = try liveReading(db, readingID)` first, so once a pinned book is deleted every unpin attempt throws readingNotFound; the internal writer (Operations+Appearance.swift:129-141) only appends or removes the single id it is handed and never prunes; Queries.shelfPins (AppearanceQueries.swift:70-75) returns the raw decoded array with no liveness filter; and the only other writers of the key (insertDailyJournalBook, ensureQuicknotesBook) pin, never unpin. So: pin book R, delete R — R's id is stuck in the stored JSON permanently, and because `setting` is a synced table the growing array is pushed on every subsequent pin change. No wrong render results (ShelfViewModel.ordered orders live `bookshelf` rows by pin order, so dead ids match nothing), which is why this is a NIT.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and it holds exactly as written. Operations+Appearance.swift:117-122 — the public setShelfPinned runs `_ = try liveReading(db, readingID)` first, and Operations.swift:85-90 shows liveReading throws readingNotFound for any row with deletedAt != nil, so once a pinned book is deleted every unpin attempt throws. The internal writer (129-141) only appends/removes the one id handed to it and never prunes. Queries.shelfPins (AppearanceQueries.swift:70-75) decodes the raw array with no liveness filter ('pins are presentation, never truth' — fail-open on malformed JSON only). I grepped every writer of the key: only setShelfPinned itself plus insertDailyJournalBook (Operations+Container.swift:228) and the quicknote book ensure (Operations+Quicknote.swift:121), both of which PIN — no path unpins on delete, and deleteReading is not among the callers. The contrast with `starred` is exactly as quoted (Operations+Appearance.swift:164-167, 'EVERY WRITE SELF-HEALS… live targets only'). NIT is the right rating and the finding says so honestly: ShelfViewModel.ordered (lines 81-96) walks pins and keeps only ids matching a live `bookshelf` row, and the mobile shelf reads the same way, so a dead id renders nothing. Corroborating evidence the class is already known but unfixed at the op: MobileTutorialSeeder.swift:179 unpins doomed books BEFORE deleting them, and notes/plans/mobile-parity-round.md:2321 pins that workaround with 'Cleanup unpins doomed books so shelf_pins never accrues dead ids across restores' — a caller-side workaround for exactly this hole, which is the drift the finding names rather than a documented acceptance of it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P35.

#### P37. The tray's ARCHIVED listing is silently truncated at 500 while its two sibling listings render truncation markers

`App/Variorum/Variorum/Features/Tray/TrayPanel.swift:400` · **NIT** · CONFIRMED · drift · finder confidence 0.85

`TrayViewModel.start` fetches all three listings with the standing probe row (`limit: Self.window + 1`, window = 500 at :224). `adopt` then flags two of them and not the third: `deletedTruncated = snapshot.deleted.count > Self.window` (:398) and `(takes, takesTruncated) = TrashListing.windowed(snapshot.takes, window: Self.window)` (:402) both survive into the view as `truncation("deleted")` at :777 and :818 — but `archived = Array(snapshot.archived.prefix(Self.window))` (:400) discards the probe row and everything past it with no flag and no marker anywhere in the view. A note holding more than 500 archived blocks therefore shows exactly 500 with nothing saying more exist, on a recovery surface whose entire job is to audit what a note has set aside. The probe row is fetched and thrown away, which is what marks this as an omission rather than a decision.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified in TrayPanel.swift. All four arms fetch with the probe row (`limit: Self.window + 1` at :363, :365, :367, :377; window = 500 at :224). `adopt` (:396-403) sets `deletedTruncated = snapshot.deleted.count > Self.window` and `(takes, takesTruncated) = TrashListing.windowed(...)`, but `archived = Array(snapshot.archived.prefix(Self.window))` with no flag — the probe row is fetched and discarded. `grep -n 'truncation('` yields only :777 (deleted) and :818 (takes) plus the builder at :872; the ARCHIVED section (:724-739) renders `ForEach(model.archived)` and an empty-state line, nothing more. No note in the repo records the omission as deliberate (the only nearby record, the A6 ladder comment at :359-362, is about bounding both listings in SQL, which was done). So it is a real drift from the standing rule quoted in KnownIssuesAndTechDebt.md's "Bounded view windows show markers, not more". NIT is correct: 500 archived blocks in one note is remote, and nothing is lost — only unlisted.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P37.

#### P38. StoreBackup.run has no single-flight latch — two forced runs in the same second write and prune the same backup file

`App/Variorum/Shared/StoreBackup.swift:143` · **MINOR** · CONFIRMED · concurrency · finder confidence 0.70

`run(force:)` spawns `Task.detached { performRun(...) }` with no in-flight guard, and two independent trigger sources reach it: the hourly `start()` loop → `backupIfDue()` (:112-120), which is outside any UI state, and the UI, whose `busy` latch does not cover every door — `DataSafetyModel.setInsurance` calls `backup.backUpNow()` with no `busy` guard (DataSafetyModel.swift:125-136) and its Toggle is not `.disabled(model.busy)` (DataSafetyPane.swift:159-160), unlike the Back Up Now button (:87). The destination filename stamp is second-granular (`"yyyy-MM-dd-HHmmss"`, :478), so two parallel runs in the same second compute the SAME path. Each then (a) opens its own DatabaseQueue at that path and runs sqlite3_backup into it (AppDatabase.swift:189-196); (b) runs `integrityCheck`, which executes `PRAGMA journal_mode = DELETE` and deletes `url + "-wal"` / `url + "-shm"` (:401-406) while the other run may still be writing that file; (c) runs `prune(directory:keep:)` (:440, :446-452) — both list, both compute the same doomed set, both `removeItem(at:)`, and the loser throws NSCocoaErrorDomain 4 out of `performBackupIfDue`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every quoted fact checks out. StoreBackup.swift:143-162: `run(force:)` captures `let stamp = now()` and spawns a bare `Task.detached { performRun(...) }` with no in-flight guard anywhere in the file (grepped for latch/in-flight/reentrancy language — none). The filename is second-granular (`"yyyy-MM-dd-HHmmss"`, :477-478) and is built from that entry-time stamp (:437-438), so two runs entering in the same UTC second compute the SAME path, then each opens its own `DatabaseQueue` at it and runs `writer.backup(to:)` (Sources/VariorumCore/Persistence/AppDatabase.swift:189-196). `prune` (:446-452) is unguarded oldest-first `removeItem`, and `keep = 14` (:47), so on any install older than two weeks both runs compute the same doomed set and the loser's `removeItem` throws out of `performBackupIfDue` into the `catch` at :516-ish, setting `primary.outcome = .failed` and `lastError` (:159-161) for a run whose snapshot succeeded. The un-latched door is real: DataSafetyModel.swift:125-136 `setInsurance` calls `backup.backUpNow()` with neither `guard !busy` nor `busy = true` (contrast :219, :239, :249), and its Toggle (DataSafetyPane.swift:158-160) carries only `.disabled(model.destination == .unset && ...)`, so 'Back Up Now' (:87 `.disabled(model.busy)`) stays live while the toggle's forced run is in flight. `integrityCheck`'s sidecar deletion (:395-402) is as described. MINOR is right: it needs two forced acts inside one second, and the worst outcomes are a false 'failed' receipt on the freshness face and a possibly-bad concurrent snapshot beside good ones.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P38.

---

## 17f — Dead code, canon corrections & test pins that cannot fail

**Status: CLOSED 2026-08-31 — the pre-13u round's Act 5 (Opus implementer,
commits `8bb0185…6ee0451` on `main`).** Eight items **FIXED**, one
**DISMISSED AS HOLLOW**. The batch record — counts, the drills' numbers, the
paired latency adjudication — is the **ACT 5 BATCH RECORD** section of
`notes/plans/pre-13u-round.md`.

### Dispositions (per item)

| item | verdict | evidence class | notes |
|---|---|---|---|
| **P42** | **FIXED** | hoist (architectural): grep 5 → 0 duplications; 4 new pins | `CrystallizationPlanner.kindForTailEdit(mode:bulkPending:)` + `kindForDurabilityMint(mode:)` in `Shared/`, called from all five sites (Mac ×3, phone ×2). Both switch EXHAUSTIVELY, so a fourth segmentation mode is a build failure at the one place that decides. No behaviour change; the pins cover both occasions across every mode **and the one way they deliberately differ** (outside `one_block`: tail edit crystallizes as you type, durability mint takes the whole tail with the trailing run preserved). |
| **P43** | **FIXED** | grep-verified dead code (the finding's own standard) | `fanAction` + `enum FanAction` + `loadFan`'s `Queries.blockFan` read + `FanPanelState.variants`/`.chosenVariantID` removed; `openFan` is synchronous now. `FanPanelState` KEPT (the sheet's `item:` binding — the verifier's correction). `refusalsSurfaceAsMessages` **re-pointed onto a live door** (⌘⇧A `archiveCaretTake` on a last active take — I10 refuses, the status line must say so), and the two tests reading `.variants` now read arity from the STORE. |
| **P44** | **FIXED (documented)** | traced mechanism + documented decision | `removeAll()` is NOT dead — it has four test call sites; what was missing was the statement that it has **no production caller and deliberately none** (no app road clears undo history), which it now carries at the declaration. The ceiling-less retention is recorded at `entries` with its bound (per act ∝ the edit ⇒ P1's letter holds; session-scoped, never persisted). **No cap invented** — a retention ceiling is a product call (how far back can she undo?) and a stack that silently forgets is the surprise the pointer religion exists to avoid. **Architect note, not a KnownIssues row:** if a ceiling is ever wanted it is the author's, and nothing measured says it is needed. |
| **P45** | **FIXED** | grep-verified dead code + doc correction | `BoundarySnapping.snap` had ZERO production callers on either platform, kept green by its own four tests, while `divide`'s op doc named it as the boundary contract — a rule no door enforces (the shipping one is `settle`, and the two disagree within `settlePull`). Function + its four tests removed; `Operations+Structural`'s divide doc and `StructuralGesturePlanner`'s header now name `settle`. The UTF-16-across-emoji pin survives, re-pointed at `settle` (same answer, 16). |
| **P46** | **FIXED** | canon aligned to an already-ruled value | AppSpec §7's seed comment **and** §9's `idleAutoCommit` entry both corrected 24 → 2, each citing 13j's J11 savepoint-cadence ruling and `v1_13_savepoint_backstop`. The verifier's widening (TWO stale places, not one) was the correct read. Nothing else in canon touched. |
| **P47** | **FIXED** | **red-on-old drilled**, both platforms | New `VariorumTests/ProtectionSurfaceRenderTests` (4 pins) + `VariorumMobileTests/MobileProtectionSurfaceTests` (3 pins). **Drill:** deleting `Text(ProtectionCopy.openAppIsReadable)` from the pane and the dead-end `Text` from each lobby fails 3 of 4 Mac pins and 2 of 3 phone pins; the roads-exist complement correctly still passes in both. **Two roads measured and rejected first, recorded in the file** so nobody repeats them: the hosted view's accessibility tree is EMPTY (zero subviews, zero a11y children) and `dataWithPDF` captures nothing (layer-backed). Reflection over the real `body` works, and an untaken `_ConditionalContent` branch is verifiably absent — which is what makes it a composition pin rather than a source grep. |
| **P48** | **FIXED** | **red-on-old drilled** | Budget DERIVED (2 ms → 1 ms: above the cheapest measured large median, 0.32–0.40 ms, below the dearest, ~1.27 ms, so at least one pin is always ratio-bound); every run prints the ratio AND which term bound; the failure message names it; the five query pins renamed flat-**or-under-budget**; the docstring stops claiming "ratios are the assertion". **Drill:** a synthetic 4.38× library-page regression PASSES under the old floor (logged "bound by BUDGET 2.0ms") and FAILS under the new one. See the batch record for what binds per benchmark. |
| **P49** | **FIXED** | **red-on-old drilled**; ZERO `Sync/` edits | New `TriggerCoverageTests` (3 pins) **reads the registry** rather than re-listing it: for all 19 registered tables, both outbox triggers exist, each enqueues its own PK, each writes `sync_outbox`, each carries the `_sync_applying` echo suppression — plus the reverse direction (no outbox trigger for an unregistered table) and the cascade set as an exact named list. **Drill:** skipping one table's trigger pair fires the pin naming the table and the consequence ("its rows would never leave this device and nothing anywhere would say so"). |
| **P50** | **DISMISSED AS HOLLOW** | measurement | The premise — `lock()` closes the last connection, so the WAL is checkpointed away before the scan — is FALSE on this tree. Probed: the WAL measures **1,100,072 / 1,153,632 bytes before `lock()` and the identical byte counts after**, frames intact, so the scan has always read real WAL content. Not fixed. What WAS real is the silent skip (`if let … try?`), so the read is now hard and the frames asserted present: if a future change ever does checkpoint the WAL away here, it says so instead of quietly becoming the dead belt the finding described. |

*(The original 9-item briefs below are kept verbatim as the entry's record —
the finder claims, the verifier traces, and the provenance note.)*

**Status when written: open, unstarted.** 9 items, no pins.

The cheapest entry, and the one with the best ratio of effort to future time saved.

**The four test findings (P47–P50) matter more than their severity suggests.** This project's entire
review doctrine rests on the red-on-old pin: a finding is not fixed until a test fails on the pre-fix
code. A pin that *cannot* fail is therefore not a weak test — it is a hole in the mechanism that every
future review depends on. P48 is the sharpest instance: five of six P1 benchmarks are gated by an
absolute 2 ms floor rather than the flatness ratio their own names claim, so they would not go red if
P1 were violated — which is what they exist to catch, and which several findings in this very sweep
allege is already happening.

**P46 is a canon correction**, not code: AppSpec §7's seed comment still says `idle_commit_hours = 24`
where the shipped seed is 2 (the 13j savepoint-cadence ruling dropped it). Correcting canon costs
minutes and prevents a future session from designing against a number that has not been true since
August.

### Items

#### P42. The segmentation-mode → crystallization-kind rule is written out five times across the two platforms with nothing pinning them together

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1343` · **NIT** · CONFIRMED · drift · finder confidence 0.80

`CrystallizationPlanner` owns the planning but not the kind selection, so the mapping is duplicated at EditorViewModel.swift:559-560 (`finalizeWork`), :1295 (`idleMintTail`), :1343-1344 (`crystallizeIfNeeded`), and MobileEditorViewModel.swift:1619 and :1662-1663. All five are byte-identical today. A rule change (a new segmentation mode, or a ruling that the idle mint behaves differently under `one_block`) landing in `crystallizeIfNeeded`'s default arm leaves the teardown and idle-mint sites — and both phone sites — on the old rule, and the platforms crystallize differently with nothing announcing it.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> All five sites verified verbatim: EditorViewModel.swift:559-560 (`mode == .oneBlock ? .oneBlock : .idle(.paragraph)` in the teardown mint), :1295 (`crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))` in the idle-mint tick), :1342-1344 (`forcedKind ?? (bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing))`), and the phone's byte-identical twins at MobileEditorViewModel.swift:1619 and :1661-1663. `CrystallizationPlanner` owns the planning; the kind SELECTION is duplicated. Byte-identical today, so there is no wrong behavior to point at — this is a genuine drift risk in exactly the class KnownIssues tracks ("Mac app-local brains are forked against mobile siblings") and is absent from that row's eight-item enumeration, so no scheduled sweep would find it. NIT is the correct rating: real, zero present consequence, and the standing remedy (hoist to Shared/) is cheap.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P42.

#### P43. `EditorViewModel.fanAction` and two `FanPanelState` fields are dead production code, reached only by a test, and every fan-panel open pays a pointless store read

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:2447` · **MINOR** · CONFIRMED · dead-code · finder confidence 0.95

Sitting 9 (R87) retired the FanPanel: the only presenter is EditorView.swift:108-112, `.sheet(item: $model.fanPanel) { panel in WriteTakesPanel(session: session, postID: postID, blockID: panel.blockID) }`, which reads ONLY `panel.blockID` and drives every act through its own `TakesViewModel`. But `loadFan` still performs an async `Queries.blockFan` read and an index walk purely to populate `FanPanelState.variants` and `.chosenVariantID` (EditorViewModel.swift:2338-2347) — `grep -rn "FanPanelState" App/Variorum` returns exactly three hits (the property :106, the struct :217, this construction :2346) and neither field is ever read. `fanAction` (:2447) plus `enum FanAction` (:2480) — roughly 45 lines dispatching eight distinct operations, each `Task { await autosave.flushNow(); ... }` — has one caller in the entire tree: VariorumTests/EditorSessionTests.swift:721 (`refusalsSurfaceAsMessages`), which must hand-construct `h.model.fanPanel = .init(blockID:..., variants: [], chosenVariantID: ...)` first precisely because no UI path can produce it. So the suite guards a door that cannot be opened from the app, and the live delete-take refusal wording is actually produced by a different road (`WriteTakesPanel` → `TakesViewModel.deleteTake` → `OpsRefusalCopy.message`).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over the whole app tree. `fanAction` (EditorViewModel:2447) and `enum FanAction` (:2480) have exactly one caller in the repo: VariorumTests/EditorSessionTests.swift:721, which must hand-construct `h.model.fanPanel = .init(blockID:…, variants: [], chosenVariantID: …)` first. The only presenter is EditorView.swift:108-112, whose comment says "Sitting 9 (R87): the FanPanel is retired" and which passes only `panel.blockID` to `WriteTakesPanel`. `FanPanelState.variants` and `.chosenVariantID` are written at :2346 and read nowhere in production (`chosenVariantID` grep returns only the struct field, the construction, and unrelated Compare/mobile symbols; `variants` is read only in FocusHandoffTests:206). `openFan` IS a live road (button at EditorView.swift:667 plus the routed command at :2331), so `loadFan`'s async `Queries.blockFan` read does run on a real gesture purely to fill unread fields. One correction to the finding's framing, which does not change the verdict: `FanPanelState` itself is not dead — the sheet's `item:` binding uses it, and `blockID`/`id` are live; only the two fields and `fanAction` are. Severity MINOR is right: no user-visible consequence, but ~45 lines of ops-calling code no UI can reach, guarded by a test that reads as coverage of a refusal path the live road (WriteTakesPanel → TakesViewModel.deleteTake) actually produces.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P43.

#### P44. UndoStack grows unbounded for the app session's life and its removeAll() has no production caller

`Sources/VariorumCore/Operations/UndoStack.swift:304` · **NIT** · CONFIRMED · dead-code · finder confidence 0.90

One UndoStack is constructed per AppSession (AppSession.swift:494) and nothing ever trims it: entries has no cap, no age-out and no clear door. `removeAll()` is public but its only callers are UndoStackTests.swift:419 and :498 — dead in production. Entries retain full text: TextPreImage holds both `text` and `postOpText` for each touched variant, and MintedPreImage.birthTexts holds the whole working_text of every minted variant, which for divideDuplicating on a fanned block is every take duplicated onto BOTH successors. A long writing session therefore accumulates two copies of every structurally-touched buffer with no ceiling and no way for the user or the app to release them.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Both halves verified. One UndoStack per AppSession (App/Variorum/Shared/AppSession.swift:494), `entries` has no cap, no age-out and no production clear door; the sole non-register clear is the redo-side removeAll inside undo (:276). `public func removeAll()` (:304-310) is called only from Tests/VariorumCoreTests/UndoStackTests.swift:419,498, RedoStackTests.swift:567 and PoolDragCopyTests.swift:163 — a grep for removeAll() across all of Sources/ and App/ returns no other UndoStack caller, so the public API is unreachable from either app. Retention is as described: TextPreImage carries both text and postOpText (:162-166) and MintedPreImage.birthTexts carries every minted variant's whole working_text (:213-217). Confirming at NIT as filed: per-act cost stays bounded by the edit so P1's letter holds, the stack is session-scoped and never persisted by design, and blocks are paragraph-sized — the accumulation is a real ceiling-less retention plus a genuinely dead public entry point, not a defect a user meets.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P44.

#### P45. BoundarySnapping.snap has zero production callers, yet divide's op doc names it as the boundary contract instead of the settle rule that actually ships

`Sources/VariorumCore/Domain/BoundarySnapping.swift:116` · **NIT** · CONFIRMED · dead-code · finder confidence 0.90

`grep -rn --include="*.swift" "BoundarySnapping.snap\|\.snap(" Sources App` returns exactly two hits and BOTH are comments (Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). The only executable callers are BoundarySnappingTests.swift:178-195. Every shipped door snaps through `settle` instead (StructuralGesturePlanner.swift:200-204, 295-303, 335-338), and the two functions genuinely disagree: `snap` is plain nearest over a Granularity with no pull, `settle` takes an explicit candidate list and applies settlePull, so they return different offsets at every cut where a strong boundary is within 2 units (finding 2's class). INPUT: a session reads `divide`'s doc to learn what a legal cut is. OUTPUT: it learns a rule no door enforces, and `snap` stays permanently green because its own tests are its only users — a public API kept alive solely by its test.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over Sources, App (both Variorum and VariorumMobile) and Tests: `snap(` matches exactly ONE definition (BoundarySnapping.swift:116) and thirteen call sites, ALL of them in Tests/VariorumCoreTests/BoundarySnappingTests.swift:180-213. Zero production callers, on either platform. The only other repo mentions of the symbol are two doc comments (Sources/VariorumCore/Operations/Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). I read the divide doc in full: line 180-183 says boundary discipline is 'deliberately the editor's contract (`BoundarySnapping.snap`)' — and the editor's actual contract is `settle`, per the planner's own three call sites (StructuralGesturePlanner.swift:204, 295-303, 336-338) and BoundarySnapping's own class doc at line 72-73 ('`settle(_:in:among:)` is the one snap brain'). The two functions genuinely differ: `snap` is plain nearest over a Granularity with no pull, `settle` takes a candidate list and applies settlePull, so they disagree at exactly finding 2's class. Real doc drift left by the S4-22 cut redesign, with a public function whose only exercisers are its own tests. NIT is the right severity — no runtime consequence, only a stale contract name a future session would trust.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P45.

#### P46. AppSpec §7's setting-seed comment still says idle_commit_hours = 24; the shipped seed is 2

`Sources/VariorumCore/Persistence/Migrations.swift:790` · **NIT** · CONFIRMED · drift · finder confidence 0.95

seedV1Settings inserts ('idle_commit_hours', '2'), and v1_13_savepoint_backstop moves existing stores off '24'. notes/AppSpec.md §7's setting DDL block still carries `-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','24')`. The 24 -> 2 ruling (13j, J11) is recorded in OverallModel.md §3 and in the v1_13 migration comment, so this is a stale line rather than an open question. A reader cross-checking the DDL against §7 — which CLAUDE.md names as the single source of design truth, and which is exactly what a schema review is instructed to do — reads a default value the store has not had since 13j.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified both sides. Migrations.swift:780-792 seeds `('idle_commit_hours', '2')` and its own comment names §7 as stale, citing the 13j J11 ruling and v1_13_savepoint_backstop for existing stores; MigrationTests.settingsAreSeeded carries an annotated pin at the 2 h value. notes/AppSpec.md:359 still reads `('idle_commit_hours','24')`, and the drift is in fact WIDER than the finding says — AppSpec §9's idleAutoCommit entry (line 419) also still reads "(setting, default 24)", while OverallModel.md:34 correctly records the 24 h → 2 h drop. So the 13j closeout updated OverallModel and left AppSpec stale in two places. No behavioral consequence; purely canon-vs-code drift, which this project does treat as a first-class defect but which costs nothing until a reader trusts §7 over the migration. NIT is correct.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P46.

#### P47. The Mac's whole protection surface has no rendering pin; the ruled 13p disclosures are pinned as string constants only

`App/Variorum/VariorumTests/Phase13pCopySweepTests.swift:86` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.95

Grep over the entire test tree returns zero references to `ProtectionPane`, `StoreLockView`, and `MobileStoreLockView` (only `MobileProtectionSheet` appears, in `MobileTutorialWalkTests`). `Phase13pCopySweepTests.theOpenAppIsReadableLineStatesTheDecline` reads `ProtectionCopy.openAppIsReadable` and asserts its words, and its doc comment claims "the sentence is rendered where a mode is chosen" — but nothing pins the rendering. Delete `ProtectionPane.swift:277` (`Text(ProtectionCopy.openAppIsReadable)`) and the entire repo's tests still pass while the Mac ships its privacy pane without the R13p-16 non-goal disclosure. Identical shape for `ProtectionCopy.deadEnd(_:)`: lines 98-118 pin the per-demand lobby sentence (the acceptance walk's own catch — an impossible-cause line), but its only renderers are `StoreLockView.swift:126` and `MobileStoreLockView.swift:182`, neither hosted in a test, so removing that view from the locked lobby is silent. Not an infeasibility: the Mac suite hosts SwiftUI routinely (NSHostingView in BookOrderConversionTests.swift:330-345, BookViewTests, TakePaneDurabilityTests).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over both Mac and mobile test targets: zero references to `ProtectionPane`, `StoreLockView`, or `MobileStoreLockView` anywhere in App/Variorum/VariorumTests, App/Variorum/VariorumMobileTests, or Tests/. The only `MobileProtectionSheet` reference is MobileTutorialWalkTests.swift:1299, and it asserts the static `doorTitle` string appears in tutorial prose — not a rendering pin either. Phase13pCopySweepTests.swift:86-95 reads `ProtectionCopy.openAppIsReadable` and asserts its words while its doc comment claims 'the sentence is rendered where a mode is chosen'; the sole Mac renderer is ProtectionPane.swift:277, unhosted. Same shape for `ProtectionCopy.deadEnd(_:)` (Phase13pCopySweepTests.swift:104-121), whose only renderers are StoreLockView.swift:126 and MobileStoreLockView.swift:182 — the acceptance walk's own catch is pinned at the constant, not at the lobby. The infeasibility defence does not hold: the Mac suite hosts SwiftUI routinely (NSHostingView in BookViewTests, BookOrderConversionTests:332, BookHistoryPaneTests, BookAscentTests). This is a coverage absence rather than a live defect, which keeps it MINOR rather than MAJOR — but MINOR is right, not NIT, because 13p's own claim is that this surface says what is actually so, and the pins fail only when the constant changes, never when the surface stops showing it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P47.

#### P48. Five of six P1 benchmarks are gated by an absolute 2 ms floor, not the flatness ratio their names claim

`Tests/VariorumCoreTests/PerfBenchmarkTests.swift:57` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.92

`expectFlat` asserts `l <= max(s * factor, floor)` with `factor: 3.0, floor: .milliseconds(2)`. I ran `swift test --filter PerfBenchmarkTests` on this tree (2026-08-30, exit 0, 6/6 green) and read the medians the helper prints. In five of six pins `s * 3` is BELOW the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part: postRender s=0.655 (s*3=1.965), assembleReading s=0.584 (1.752), timelinePage s=0.618 (1.854), library s=0.310 (0.930), tagSubtree s=0.651 (1.953) — all under floor=2.000. Only `autosaveIsFlatInPostLength` (floor overridden to 1 ms, s=1.359 → 4.077) is ratio-bound. Concretely: `libraryPageIsFlatInCorpusTextSize:111` compares a 100x10 corpus with a 100x100 corpus (10x the text) and passes at ANY large-corpus timing up to 2.000 ms against a measured 0.310 ms — a 6.45x tolerated regression, i.e. a query whose cost grows as ~N^0.81 in corpus text ships green under a test named 'IsFlat'. This is the project's only automated P1 guarantee at the query layer and the baseline Phase 12 re-verifies against.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and re-measured. `expectFlat` (PerfBenchmarkTests.swift:48-61) asserts `l <= max(s * factor, floor)` with factor 3.0 / floor 2 ms. I ran `swift test --filter PerfBenchmarkTests` on this tree (6/6 green): renderPost s=0.639 (s*3=1.917), assembleReading s=0.579 (1.737), timelinePage s=0.574 (1.722), library s=0.320 (0.960) — all below the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part. One correction to the finding's arithmetic: tagSubtree measured s=0.703 on my run (s*3=2.109 > 2 ms), so it flips run-to-run — it is FOUR pins clearly floor-bound plus one marginal, not a stable five. autosave (floor overridden to 1 ms, s=1.343) is genuinely ratio-bound. The consequence stands: `libraryPageIsFlatInCorpusTextSize` tolerates any big-corpus median up to 2.000 ms against a measured 0.320 ms — a ~6x scaling regression passes under a name asserting flatness. Not refutable as a documented tradeoff: the suite docstring claims the opposite of what happens ('absolute timings are machine noise, ratios are the assertion'), and notes/plans/phase-04-read-layer.md:83 likewise reports these as ratio assertions. The project itself already ruled this exact class a defect on the phone — MobilePerfWalkTests.swift's bounds comment, verbatim, 'a pin named "flat" whose floor is the only binding bound is the record-claim class' — and renamed the mobile pins to say which term binds; the core suite never got that pass. Severity MINOR is right: no shipped behavior is wrong, but these six are the only automated P1 guard at the query layer and the baseline Phase 12 re-verifies against.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P48.

#### P49. Nothing pins that a synced table actually has its outbox-capture triggers, so a future table can join the registry and silently never sync

`Sources/VariorumCore/Sync/SyncSchema.swift:8` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.90

SyncSchema.swift's header promises that a table added to the schema 'is added HERE or it silently never syncs (the introspection test in SyncSchemaTests fails the build instead)'. The test that exists, SyncSchemaTests.registryMatchesLiveSchemaExactly:14-33, compares the registry only against the set of sync_version-carrying tables — it never looks at triggers. I searched the whole test tree: `grep -rn "outbox_" Tests/` returns nothing and `grep -rn "type = 'trigger'" Tests/ Sources/` returns nothing; no test introspects sqlite_master for triggers. Concretely, a v1_15 migration that creates `CREATE TABLE foo (... sync_version INTEGER NOT NULL DEFAULT 0 ...)`, adds `SyncTable("foo", ...)` to the registry and "foo" to MigrationTests.expectedTables, but omits `try createOutboxCaptureTriggers(db, table: "foo", pk: "id")`, passes registryMatchesLiveSchemaExactly, everySyncedTableCarriesSyncVersionDefaultZero, everyColumnOfEverySyncedTableIsClassifiedExactlyOnce, mirrorDDLCoversEverySyncedColumn and allTablesExist. Every ordinary write to foo then fails to enqueue, so device A's rows never reach device B and no error is raised anywhere; AccountLifecycleTests:267-273 would not catch it either, because resyncReinitialize enqueues by explicit `INSERT OR REPLACE INTO sync_outbox ... SELECT` (SyncEngine.swift:408-413), not by trigger. The identical gap covers tombstone cascades: nothing asserts a new child table gained its cascade_* trigger.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The gap is real. I grepped the whole test tree: the only sqlite_master introspections are for TABLES and INDEXES (SyncSchemaTests.swift:19, MigrationTests.swift:66/75/93/105, BlockCommentTests.swift:26/32, ReadingSectionTests.swift:42, BridgeStateTests.swift:76) — `type = 'trigger'` appears nowhere in Tests/, and `outbox_` (the trigger-name prefix minted at Triggers.swift:135) appears in no test. registryMatchesLiveSchemaExactly (SyncSchemaTests.swift:16-31) compares the registry only against the set of sync_version-carrying tables, exactly as the finding says. TriggerTests' outbox suite exercises three tables by hand (container, setting, and a block cascade) — never the registry, so a 20th registered table with no trigger pair passes every existing pin. Trigger creation is by hand-maintained list (Triggers.swift:107-125, 13 tables) plus six later per-migration calls (Migrations.swift:168, 256, 257, 299, 362, 465), never driven off SyncSchema.tables, so nothing structurally couples them. Two corrections to the finding's framing, neither fatal: (a) the SyncSchema header's promise is accurately about REGISTRY drift, which registryMatchesLiveSchemaExactly does enforce — the finding reads it as covering triggers, which it does not claim to; (b) today's correspondence is exact (19 registered tables, 19 trigger pairs), so this is a preventive pin, not a live defect. MINOR is the right rating — real, narrow, and future-facing, but the failure mode (a table whose writes never leave the device, silent on both machines) is precisely the class this codebase pins by introspection elsewhere.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P49.

#### P50. The keyed-store WAL plaintext scan cannot fail — the WAL is checkpointed away before the test reads it

`Tests/VariorumCoreTests/KeyedStoreConvergenceTests.swift:87` · **NIT** · CONFIRMED · test-gap · finder confidence 0.85

Lines 80-81 call `binding.lock()` on both stores, which runs `outgoing.close()` on the DatabasePool (StoreBinding.swift:97). Closing the last WAL-mode connection checkpoints and then deletes or truncates the `-wal`. Line 87 then reads that file with `try?`. Both outcomes are unfalsifiable: if the file is deleted, `try?` yields nil and the `#expect` at line 88 never executes; if it is truncated (the branch I reproduced on this machine — `sqlite3 t.sqlite "PRAGMA journal_mode=WAL; CREATE TABLE x(a); INSERT INTO x VALUES('prose');"` leaves a 0-byte `t.sqlite-wal`), `walBytes` is empty and `range(of:)` is trivially nil. So if SQLCipher ever wrote cleartext into the WAL during operation, this scan stays green, because it only ever looks after the checkpoint. Reading the `-wal` before `lock()` would be the falsifiable order. The store-file scan at line 84-85 is real and unaffected.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified. SyncTestHarness.swift:71 opens the client via `AppDatabase.openStore(at:custody:)`, i.e. `.direct` storage, so `a.db.asRebindable()` (AppDatabase.swift:69-76) mints a fresh StoreBinding over that same writer and `lock()` (StoreBinding.swift:88-102) calls `outgoing.close()` on the pool — the last connection. SQLite then checkpoints and deletes-or-truncates the `-wal`; I reproduced the truncate branch on this machine (sqlite3 WAL write, clean exit, `t.sqlite-wal` left at 0 bytes). KeyedStoreConvergenceTests.swift:86-89 reads that file only AFTER lock(), with `try?`, so either the file is gone (nil, the #expect never runs) or empty (`range(of:)` trivially nil). The scan is unfalsifiable as ordered. Two corrections that lower the stakes: (a) the store-file scan at :83-85 is real and unaffected, as the finding says; (b) contrary to 'the suite claims coverage of a leak path it never inspects', the WAL leak class IS inspected live elsewhere in the same target — StoreEncryptionTests.swift:99-103 scans the `-wal` while the pool is still OPEN, with frames present ('WAL pages encrypt too'). So this is a redundant dead belt beside a live pin, not an uncovered guarantee. Downgraded to NIT accordingly; the honest fix is one line of reordering (scan before lock()).

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P50.

---

## 17i — Sync across devices: the reconciliation probes, the scenario sweep, the harness-realism fix

**Status: open, unstarted — RUNS AS ITS OWN ENTRY AFTER `pre-13x` (author, 2026-09-01 evening at the Act 10 correction round's sitting, R-cor-13: *"Agree that pre 13x doesn't need 17i to be done within it"* — superseding the morning's pull-in); still on the settled key path, so after pre-13x lands, never before. Earlier wording: PULLED INTO `pre-13x` (author, 2026-09-01 morning: *"I would like to pull 17i into this in between phase"*; it was to run as that phase's LAST batch, on the settled key path — `notes/plans/pre-13x-postures-design.md` §15.6)** (opened 2026-08-31 at the author's word; brief =
`notes/plans/pre-13u-memo-sync-disagreements.md`).

**What it is.** Not a bug list — a HUNT: the memo's four probes run first (each answer recorded in
the memo whether it confirms canon or not), then the scenario table's ✔ rows are re-run under
production's round shape (pull → push, 200-row chunks, interleavings), then every discrepancy found
becomes an item here with the standard trace + red-on-old pin. The structural deliverable is the
harness change: production's round shape becomes the convergence suites' default (a
`productionRound` helper; chunk splits at registry boundaries as a sweep) — the pre-13u ladder's
lesson (R2-1/R2-2 passed in the harness's order and failed in production's).

**First fix item (promoted from the memo's P5(a) at the pre-13u ladder's round 3, 2026-09-01):** the general `tag.path` repair's loss of applications that arrive after the duplicate died — the KnownIssues row carries the mechanism and the pin. **Second structural item (R3-2):** the seed-shape guard invokes the real classifier instead of mirroring its SQL.

**Cast:** Fable (all `Sync/`; the standing rider). **Standing rules:** pin before fix; canon (SyncSpec
§§5–7, §12) outranks the implementation — a probe that falsifies a canon sentence is a finding
against the CODE unless the author rules the sentence wrong. **Related, kept separate:** the
daily-Journal identity memo (13y) and the dedupe's late-registry residual (KnownIssues, 13y).


### CLOSED 2026-09-22 — the dispositions (RUN B, all five batches + the two-round ladder; the record is `notes/plans/run-b-sync-correctness.md`)

**The hunt ran exactly as designed and everything it caught is FIXED in-run.** B1: probes P1–P3 +
P5(b)/(c) + P8's run + the P4 round-shape sweep, every answer recorded in the memo's (now
ANSWERED) section with pins — P1/P2(a)/P3 CONFIRMED canon; P4 swept 0 findings; P2(b)'s returner
corner RULED at QUESTIONS #141 (shipped (a) stands; the (b) rescue is entry 17s at her word).
**Fix item 1 (the tag.path arrival-order loss, KnownIssues row 34) FIXED** (B2 row 7,
`repointApplicationUnderDeadDuplicateTag`, red-on-old both directions; the recreated-tag catch
PROVISIONAL #142) — **and its REJECT-PATH face, found by B4's own sweep (F-3), FIXED too** (B5
row 17: the shape-scoped fingerprint defer — the CAS-reject door yields to §9's feed authority;
the Journal-family face closed BY EVIDENCE, its probe green). **R3-2 DONE** (one public
classifier body; the guard invokes it). **The structural deliverable DONE** (B4:
`productionRound` is the convergence suites' DEFAULT — 37 converted / 3 already-production / 33
exempt with reasons at the lines; 3 new registry-boundary arms + the stress pass's tenth
attacker arm; the beyond-scope residue named in the run record). **Hunt finding F-1 (the dedupe
double-retirement race, edit bytes lost) FIXED** (B2 row 15: ride-the-row #143(a) + the
kill-time defense; hardened at the ladder — F-R1's text-sole-divergence narrowing, F-R2's
bounded meeting, F-R3's persisted verdict). The ladder: TWO rounds (4 MAJOR · 3 MINOR · 4 NIT,
zero disputes, every finding dispositioned; round 2 re-proved round 1's red-on-olds
independently). Her ratify rows: **#141 (ruled) · #142 · #143 (amended to shipped behavior)**.
**THE LIVE-ROUND ACCEPTANCE LEG: PASSED — her 2026-09-22 morning round** (convergence both
directions on the real mirror, no stall warning — "yep it worked"; the evidence record is the
run plan's LIVE ROUND slot). 17i's acceptance is complete.

## 17j — PARKED: the "open your library without Variorum" recipe (may or may not happen)

**Status: parked, unstarted** (author, 2026-09-01: *"I'm not going to worry about a decrypting
script… I'd park them as 17 items or something. they may or may not happen."*). **What it is:** a
published, tested recipe that opens a Variorum library with no Variorum app — the key envelope's
format (`variorum-keys.json`: Argon2id descriptor → RFC 3394 unwrap → the raw 256-bit key) and the
`sqlcipher` CLI's raw-key pragma — plus a ~30-line reference script. **Why it would matter:** it makes
"you own your files" true even if the app vanishes; the plaintext SQLite export (pre-13x, ruling 9)
covers the everyday need, so this is the belt. **Owner if it runs:** its own 17 entry, after pre-13x
(the envelope format is that phase's). Record: `notes/plans/pre-13x-postures-design.md` §4 / §18.

## 17k — PARKED: a plain "Pause sync" switch (may or may not happen) — **JOINS 18a (author, 2026-09-01 evening, R-cor-13: "ask to sync, pause sync button, etc." are 18a's sync considerations); this entry stays as the pointer**

**Status: parked, unstarted — re-homed to 18a's design sitting** (same ruling, same day). **What it is:** a convenience switch on the
sync row that stops rounds until flipped back — NO posture semantics, NO security claim (deletion
damage is already bounded by tombstones, the 30-day Trash on every device, the purge horizon, and
local backups; Castle enrollment needs the passphrase). Cheap: the scheduler's stop + one honest
line on the sync row. Record: `notes/plans/pre-13x-postures-design.md` §14 item 22 / §16(d).

## Not slotted — needs the author's call

### P39. Feature modules call each other directly — 20 mutual pairs, including a hard Library↔Pool view-model cycle and a sibling view model constructed inline

`App/Variorum/Variorum/Features/Pool/PoolPostsView.swift:240` · **MINOR** · CONFIRMED · architecture · finder confidence 0.90

CLAUDE.md binds: 'One feature = one self-contained module... Cross-feature interactions route through parent composition, never feature-to-feature calls.' Measured over Features/*/ with comment lines blanked and generic type names excluded: 20 mutually dependent feature pairs. Confirmed violations: (a) Editor/WriteTakesPanel.swift:51 CONSTRUCTS a sibling feature's view model inline — `TakesViewModel(session:postID:)` — so Editor owns Takes' model lifecycle; (b) Pool/PoolPostsView.swift:240,246 calls methods directly on LibraryViewModel; (c) a hard type cycle — Library/SidebarView.swift:105 holds `let pool: PoolViewModel` while Pool/PoolPostsView.swift:127 holds `let library: LibraryViewModel`; (d) NoteDeletion, an app-wide act, is homed at Features/Library/NoteDeletion.swift:90 and reached from four features (Takes/TakesBottomBar.swift:406,411; Pool/PoolPostsView.swift:179,253; Editor/CommitBar.swift:301,311). Consequence: no feature can be changed, tested, or reviewed in isolation — a lifecycle change to PoolViewModel lands at a Library call site a Pool-scoped reviewer never opens, and the reverse. For (d) specifically, the next door needing note deletion must either import a feature or copy the act.

**MEASURED 2026-08-30, and the finder's headline was WRONG.** The finding claims "20 mutual pairs";
a direct measurement over `Features/*/` (uniquely-owned type names >5 chars, comments stripped) gives
**57 directed cross-feature edges across 8 mutual pairs**, not 20. The verifier had already tempered
the finding on three other counts: **(a)** parent composition IS honoured — `RootView.swift:133,557`
are the only construction sites, so what is violated is the *"never feature-to-feature calls"* half,
not the composition half; **(b)** the class is already enumerated in
`notes/plans/phase-13b-stage0-architecture-survey.md` §8.1, including `WriteTakesPanel`'s
`TakesViewModel` ownership by name — so it was never unknown, only unowned; **(c)** the `NoteDeletion`
limb is REFUTED on merits — the App target is a single Swift module, so there is no import cost and
the objection reduces to folder placement.

**What the 8 mutual pairs actually are** — and they are three different things wearing one label:

| Pair | What crosses |
|---|---|
| `Library` ↔ `Pool` | **VIEW MODELS, both directions** — `PoolViewModel` ← Library, `LibraryViewModel` ← Pool, plus Pool calling `library.duplicateAsVersion` / `library.archive` directly |
| `Editor` ↔ `Takes` | Editor **CONSTRUCTS** `TakesViewModel` inline (`WriteTakesPanel.swift:51`); the rest is shared components (`LensNameSheet`, `TakeClipboard`, `CalloutMenu`, `CommitBar`) |
| `BookView`↔`Takes` · `Canvas`↔`Pool` · `Canvas`↔`Takes` · `Editor`↔`Tray` · `Library`↔`Takes` · `TOC`↔`Takes` | A view rendering a sibling's view, or a small shared type homed in a feature folder (`TakeEditCost`, `TagChips`, `MembershipChip`, `NoteDeleteConfirm`, `BlockTOCView`) |

**So the real defect is TWO items, not fifty-seven:** the `Library` ↔ `Pool` view-model cycle, and
Editor owning `TakesViewModel`'s lifecycle. Everything else in the tail is **a shared component living
in a feature folder instead of a shared home** — placement, not architecture, and in a single-module
target it costs nothing at runtime.

**A rule violated 57 times is usually a wrong rule.** This project's own doctrine says an operation
tortured to express means the schema is wrong, not the operation (OverallModel §9). The same logic
applies here: CLAUDE.md's *"never feature-to-feature calls"* is, as literally written, violated by
ordinary SwiftUI composition — one view rendering another. The rule almost certainly MEANS *view
models and business logic never cross features*, which is a rule the code nearly keeps.

**Why it is NOT an entry.** Everything else in this file is a bounded fix with a settled shape.
This one needs a **decision before it needs work** — specifically, whether the canon rule it cites
means what it literally says. Scoping an entry against a rule that is about to be refined would build
the wrong thing. Once the rule question is answered the *work* is small (the two real items), and it
should become an ordinary lettered entry at that point.

**The options, hers to choose** (recommendation: C+B):

- **(A) Full untangle as its own post-launch phase** — all 57 edges, every shared component moved to a
  shared home, both view-model cycles broken. High file churn, zero user-visible benefit, real
  regression risk in a tree whose editor seam is the project's #1 stated risk. Only defensible
  post-launch, and probably never worth it on its own.
- **(B) Fix the two real ones as an ordinary entry; record the tail.** Break `Library`↔`Pool` (Pool
  stops holding `LibraryViewModel`; its two calls become closures passed by `RootView`) and stop
  Editor constructing `TakesViewModel`. Small and contained. The component tail becomes a KnownIssues
  row, fixed opportunistically as phases touch each one.
- **(C) Refine the rule to what it means, and record the rest as deliberate.** Amend CLAUDE.md so the
  prohibition binds **view models, business logic and lifecycle ownership** — never a view rendering a
  sibling's view, and never a shared component in a single-module target. Then the tail is not debt at
  all; it is the rule, correctly stated, and the next sweep stops re-reporting it.
- **(D) Do nothing, unrecorded.** The one bad option — a blank owner is what this project's rules
  forbid, and 13b's §8.1 survey already proves this class comes back when it is merely written down
  somewhere that closes.

**C first, then B:** the rule refinement costs minutes and shrinks the problem from 57 to 2; the two
survivors are then a small entry against a rule that is actually true.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every cited line is real. WriteTakesPanel.swift:51 does `_model = State(initialValue: TakesViewModel(session:postID:))` — Editor constructing Takes' VM. PoolPostsView.swift:127 holds `let library: LibraryViewModel` and calls `library.duplicateAsVersion` (:240) and `library.archive` (:246); SidebarView.swift:105 holds `let pool: PoolViewModel` — the type cycle is real. CLAUDE.md/AppSpec §2's rule is quoted correctly. THREE CORRECTIONS. (a) Both cycle halves ARE wired by parent composition — RootView.swift:133 and :557 are the only construction sites — so what is violated is the 'never feature-to-feature calls' half, not the composition half. (b) The class is already documented: notes/plans/phase-13b-stage0-architecture-survey.md §8.1 'Cross-feature coupling' enumerates it including WriteTakesPanel's TakesViewModel ownership by name, and 13b acted on one instance (the plan's Canvas row said 'stop calling TakesViewModel.message(for:) cross-feature' — grep confirms CanvasView no longer does). So already_known is wrong. (c) Item (d) is REFUTED on its merits: NoteDeletion is a static act namespace whose own header documents 'Four doors reach this act' and why it is one file; the App target is a single Swift module, so no import cost exists and the objection reduces to folder placement. Severity down to MINOR: no invariant (I/P/S) is violated and no user-visible behaviour is wrong; this is maintainability, and the claim 'no feature can be changed, tested, or reviewed in isolation' is overstated.

*No red-on-old pin.* Full evidence: review doc, P39.



---

## 17g — The macOS data-protection keychain asymmetry (the 13p-fix session)

**Status: CLOSED 2026-08-30**, three review rounds, all-Opus cast at her
instruction. **The full record is `notes/plans/phase-13p-fix-dp-keychain.md`**
— the FINDING with its measurement, the fix design, the ledger, the batch
record, and all three ladder rounds. This entry is the summary and the
hand-offs.

### What she hit

Minutes after 13p's signing gap closed, she ticked *"Require Touch ID to
unlock sync"*, it silently reverted, and then: *"i tried opening variorum
and the touchid didn't work, even though i enrolled it, and then i
entered my passphrase, and then i had to enter it again to get sync to
start working."*

### The mechanism, measured

On macOS a keychain write carrying an access-control (biometry) ACL or
`kSecAttrSynchronizable` is routed to the **data-protection** keychain,
while a read without `kSecUseDataProtectionKeychain` searches the
**file-based** one. That flag appeared **nowhere** in the codebase.
Measured in the signed test host: `add 0` · `read-without -25300`
(itemNotFound) · `read-with -25308` (present, needs auth).

**Latent until that afternoon.** Before the signing gap closed, every
ACL'd write died at `-34018`, so the gated paths never once succeeded and
the asymmetry could not bite. Closing the gap did not break something
that worked — it made a latent defect reachable. **iOS was never
affected** (it has only the data-protection keychain).

**Why it cost her custody rather than just failing.** Both gated
transitions delete the surviving plain item immediately after a
"successful" gated write. So her Biometric-mode switch wrote an
unreadable gated store key and deleted the Auto item, and the sync toggle
did the same to her E2EE custody. Both recovered by passphrase; no
writing was ever at risk.

### What shipped

- **The flag on the three query builders** that own every DP-resident
  site, behind one named constant (`KeychainPartition.dataProtection`)
  rather than a comment pasted three times.
- **`CustodyHandover`** — the rule the incident actually demanded: write,
  **verify it reads back through the production read path**, only then
  delete the outgoing item; typed outcomes so the arm where something
  *did* land somewhere unreadable stops claiming "nothing was altered".
  Both custody transitions and both surfaces now speak it.
- **Pins:** the platform fact; a production round trip (write → find →
  delete → confirm gone); three direct outcome tests; two E2EE transition
  pins; a structural guard covering all three families. Every bug-class
  fix red-on-old by **behavioural revert**, not assertion.
- **Counts: Mac 1854 / 314 — ALL PASSED** on the final tree, canvas
  flake included (baseline 1843/312; +11 tests, +2 suites, arithmetic
  checked). Zero `Sources/VariorumCore/Sync/` lines, zero schema, no
  lockstep — marker stays 7.
- **`/Applications` refreshed** behind the A1 rail (ciphertext backup
  first, hash-matched install, keychain identity and the new refusal copy
  both confirmed in the shipped binary), so her E2EE re-enrollment lands
  on the guarded build.

### The three rounds, in one line each

**Round 1 (14 findings)** — the phase had fixed the CAUSE and left the
FAILURE MODE: both transitions still deleted the plain item on a write's
word alone. Also falsified two of the phase's own claims (the escrow leg
of the diagnosis was simply wrong; the batch record asserted facts about
her live custody it had just proved unobservable).

**Round 2 (1 MAJOR)** — round 1's revert drill proved the *store-key*
guard and the record claimed "both proven". The **E2EE** guard had no pin
of any kind — and that is the half whose item actually went missing.

**Round 3 (3 MAJOR)** — and the sharpest finding of the phase was against
the phase itself: see below.

### ⚠️ The phase broke its own trap — recorded because that is the point

Round 3 caught that the round-2 revert drill **removed the injected
seam's use**, so the "fake-driven" E2EE pins fell through to the real
`E2EEKeychainStorage` at its fixed account and **overwrote her live E2EE
custody with test material**. Verified from the live Keychain: the item
was created inside the drill window, and a read of its key *identifiers*
(never its bytes) returned the drill's sentinel exactly.

Consequence: **sync refuses until she re-enrolls with her passphrase** —
the designed road, walked once already that evening, nothing at risk
because the vault is server-side. An attempt to clean it up was correctly
**blocked by the permission classifier** (deleting a keychain item via
the test runner is a non-test action), and routing around it would have
been the wrong move, so it was left to her with both roads written up.

**The rule taken, now in the plan's ENVIRONMENT TRAPS in bold: a revert
that removes an injected seam is never a valid drill.** Revert the
outcome check instead — same red, zero real-world traffic.

### Handed off, every item owned

| item | owner |
|---|---|
| Should the store key be BOUND to this device? (its protection class is inert on macOS, so the key rides Migration Assistant to other hardware — two production comments claimed otherwise until now) | **QUESTIONS #82**, hers; KnownIssues at **13x** |
| Deletes discard their status; `E2EECustodyStorage.live`'s wiring untested; `setMode`'s synchronous `SecItem*` on the MainActor; the test's global cache write | **17a** |
| The escrow round trip has never been verified on any machine | **13x** |
| A Developer ID build must carry the same `keychain-access-groups` | **13r** |
| `saveGated`'s forced delete-then-add window (pre-existing since 14b) | **17a** |
| `CanvasDragTrackingTests` load flake (found, not caused; both its tests) | **12** |
| The `wroteButUnreadable` wording | **13s** voice pass |

### Owed to the author

1. **Re-enroll E2EE with your passphrase** (my drill's damage — see above).
2. **The two-step clean-up** if the biometric-gate orphan is still there:
   unlock FIRST, then toggle off. The one-step version refuses.
3. **QUESTIONS #82.**
4. **The install refresh — DONE at the CLOSE (`8490ac3`):** `/Applications` was refreshed behind the
   A1 rail, hash-matched, the guard confirmed in the shipped binary. *(This item predated the CLOSE
   and stood uncorrected beside it — struck at the pre-13u round's Act 1 cold review, finding F3.)*

---

## 17h — The custody riders 17a never listed (R2-7 · R3-5 + riders)

**Status: CLOSED 2026-08-31 — the pre-13u round's small fresh Fable session,
commits `73763c2` (R3-5 + R3-4) · `bc48315` (R3-6) · `98813d4` (R2-7) + the
records commit on `main`.** Both items FIXED; every bug-class pin red-on-old
by a faithful **behavioral revert** (the R3-1 rule — the outcome check
reverted, never the seam; each drill red reproduced the traced end state
verbatim). Zero `Sources/VariorumCore/Sync/` lines, zero schema. The two
`KnownIssuesAndTechDebt.md` rows that named this entry are REMOVED per that
file's rule; this entry is the resolution record.

### Dispositions (per item)

| item | verdict | pin(s) | notes |
|---|---|---|---|
| **R3-5** (the delete-status-discarded family) | **FIXED** | `CustodyHandoverTests.aRefusedOutgoingReleaseBacksTheTransitionOut` · `.aRefusedPlainReleaseBacksTheGateOnTransitionOut` · `CustodyReleaseTests` (all three shapes) | Every delete seam answers RELEASED (deleted, or never there): `StoreKeyGuard.deleteAuto`/`deleteGated`, `E2EEKeychainStorage.deletePlainItem`/`deleteGatedItem`, core's `StoreKeyKeychain.delete` (both keychains, both legs). `CustodyHandover` consults its delete leg — the new `.outgoingNotReleased` outcome rolls the incoming item back best-effort and refuses whole; `setMode`'s `.passphrase` arm verifies BOTH releases (gated first, so a refusal leaves a coherent state from either direction); both surfaces word the arm (`ProtectionCopy.outgoingCustodyNotReleased` / `syncKeysOutgoingNotReleased`, the F6 own-sentence precedent). The `deletesSucceed` knob (the `savesSucceed` pattern) drives the pins. Drill red: every transition COMPLETED with the dial flipped over an unreleased item — the row's three shapes verbatim. **Scope note:** `deleteEscrow` deliberately not widened — the row named `deleteAuto`/`deleteGated` and all three reachable shapes; the escrow item's consistency has its own verified-landed observable (R-pre13u-4), and its delete's failure mode (a lingering RECOVERY copy) is the opposite polarity of custody loss. |
| **R3-4** (rider: `E2EECustodyStorage.live`'s wiring covered by nothing) | **FIXED** | `CustodyHandoverTests`' five wiring pins (`gateOnReleasesThePlainItemAndOnlyThePlainItem` &c.) · `KeychainTripwireTests.theLiveLeavesReachTheStaticFunctionsTheirNamesClaim` | The composition is seamed: `E2EECustodyLeaves` (the fixed-account leaves as closures) + `E2EECustodyStorage.wired(leaves:)` with `.live = wired(leaves: .live)`. The handover ROLES are pinned with recording leaves — transposing `deleteOutgoing`/`rollBackIncoming` in `wired` reds on names; the NAME→FUNCTION mapping is pinned through the tripwire's new `refusedLeafNames` observable with zero Keychain traffic (containment over per-call deltas, race-safe by construction). `KeychainTripwireTests` is `.serialized` now — its exact `+5` count and the new tripper must not interleave. |
| **R3-6** (rider: `setMode`'s synchronous `SecItem*` on the MainActor) | **FIXED** | `ProtectionSetModeOffMainTests.everyTransitionArmsGuardSeamWorkArrivesOffMain` | The transition's custody choreography extracted verbatim into the nonisolated `transitionCustody`, run in ONE hop on a SERIAL custody queue (the `DeviceKeyStore.custodyQueue` pattern — the pre-fix MainActor body had no suspension point across its custody work, so transitions never interleaved; the serial queue keeps exactly that, where a detached task per call would not). Custody semantics byte-preserved — the existing transition pins rode unmodified. Drill red: all three arms' calls landed main-thread while every call-order assertion stayed green. |
| **R3-NIT** (rider: `CustodyHandoverTests` cache save/restore) | **ALREADY DISCHARGED** — Act 9 group 1 (`270bf4f`); not redone | — | Verified present in the test (`E2EELaunchKeyCache` save/restore around `theE2EEGateTurnsOffOnlyWhenThePlainItemReadsBack`). |
| **R2-7** (the `saveGated` delete-before-add window) | **FIXED — probe-first narrowing; the residual window RECORDED, not claimed fixed** | `GatedSaveChoreographyTests` (4 pins) · `Phase13pKeychainFactTests.aGatedReSaveOverAnExistingItemLandsAndLeavesNoProbeLitter` (real DP keychain, signed host, throwaway scope) | **The traced mechanism:** both `saveGated`s ran delete→add (FORCED — updating an ACL'd item demands interactive auth; a write must never prompt), so an add failing after the delete left ZERO gated custody. The reachable harm road is E2EE's `DeviceKeyStore.save` under gate-ON (a passphrase re-unwrap's re-save); the store-key family reaches `saveGated` only from `setMode(.biometric)`, where the custody law keeps the gated item absent — unless an earlier delete failed silently, which is R3-5's third shape, now closed. **Why not the row's swap remedy:** renaming an ACL'd item (`SecItemUpdate` of its account) is an update too and demands interactive auth under the same platform rule that forced delete-then-add — the swap is unsound, and would additionally need crash-heal state machinery in the most safety-critical file. **The fix:** `GatedSaveChoreography` (ONE brain, both families): sweep probe litter → add a PROBE item (sibling account, same service/ACL/DP partition, dummy bytes) proving the keychain accepts an identical ACL'd add RIGHT NOW — identity/access group, DP admission, ACL acceptance, biometry state, disk, securityd — → sweep it → VERIFIED release (R3-5's semantics) → real add. Drill red: the pre-fix body (delete-then-add through the seam) left `existing == nil`, the traced zero-custody end state. **What survives, pinned as documented behavior** (`aFailureBetweenTheTwoAddsStillStrandsAndThatIsRecorded`, green on both trees BY DESIGN): a transient failing between two identical adds milliseconds apart, and the crash-between-syscalls window that always existed — in both, the material is in hand at the caller, the surfaces already word the refusal, and the vault re-derives custody by passphrase (a re-enrollment prompt, never lost writing). No further remedy exists under the never-prompt rule; not deferred work, so no KnownIssues row remains. |

### Verification at close

Core `swift test`: **1457/154 GREEN — exact baseline.** Full Mac suite (run
ONCE, at close): **1887 tests in 320 suites — count arithmetic EXACT**
(baseline 1871/317 + this entry's 16 pins across 3 new suites), green
except the ONE known intermittent latency pin
(`EditorWindowSmokeTests.rewriteStrategyLatencies(paragraphs: 250)` at
54.87 ms in-suite; re-run ISOLATED per the standing rule three times:
51.54 / 53.20 / 51.07 ms — the exact band its KnownIssues row records
across three prior phases' loaded boxes). **Adjudicated PRE-EXISTING on
the diff fact:** this entry's whole diff is 13 keychain/custody files +
test pins, zero editor-path lines (diff-verified), and the row's 13p-close
covariate — the author's LIVE real-store app running beside the test
host — was active throughout; the row stays at its owner (12,
perf-budget calibration). `CanvasDragTrackingTests` (the other known
flake) passed inside the full run. Tutorial spine: **all 10 tutorial
suites GREEN inside the full run.** iOS target **BUILDS**
(`generic/platform=iOS Simulator`; the scheme's default destination
resolves to "My Mac" and fails on provisioning — a destination artifact,
not a compile failure). Zero `Sync/` lines, zero schema (diff-verified:
no file under `Sources/VariorumCore/Sync/` in any commit). The author's
real-store app was RUNNING throughout — never touched, no Release
builds, no `/Applications` refresh.

## 17l — pre-13x residuals (opened 2026-09-07 at the pre-13x closeout; the record `notes/plans/pre-13x-postures-design.md` — THE LADDER section and §16; QUESTIONS #90)

Small, independently pinnable items the phase closed WITHOUT so its ladder could end at a clean seam; each is verdicted FIXED-with-a-pin, DISMISSED-as-hollow, or re-owned when this entry runs (the 17-entry review rule binds: an Opus cold review always; a Fable one because item 2 touches custody code).
1. **The seeder's discover-then-mint latch** (F2's question 6; F3's question 2): a tutorial open inside the launch seed's window can mint *Encryption Explained* twice (pre-existing for Help ▸ Restore); and after a PURGE a non-seeding device's silent ensure re-mints a book the reader deleted (the tombstone is the reader's word only while the Trash keeps it). A latch over `SampleLibrarySeeder`'s discover-then-mint (one in-flight seed per book per store) and a purged-ids consult (`purged_row` — 13j's ledger) for the ensure. Pins: a concurrent open + launch seed ⇒ one book; a purged book + the tutorial door ⇒ none.
2. **The migration drill's escrow leg under a throwaway scope** (the final drills, leg 1 — red on one expectation): batch 2c.0 (corner 47) made every non-real scope's escrow leg inert, and `ProtectionMigrationDrillTests` runs under `drill-<uuid>` by the tripwire's law, so its "legacy escrow item removed" expectation can no longer fire in the drill (the REAL scope's live road is pinned by `SessionTokenBindingTests.theLegacyLegsAreInertForADevScopeAndLiveForTheRealScopeOnly`). Fix the DRILL: override the escrow pair for the throwaway scope as it already overrides the plain-item leaves, then re-run under `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1`. Also: confirm from her Mac (the unified log rotated past 2026-09-05 by the closeout; the Keychain inventory shows it) that her window migration removed the legacy escrow item.
3. **Her #90 rulings' wording changes** (each a copy constant + its pin on both platforms; 13s re-voices later): 54 — the follow door's label when it asks nothing: **RULED *Pick Up New Keys*** (her word, 2026-09-07 ~02:05: *"Pick Up New Keys is fine as a choice"*) — the constant + the copy pin on both platforms; 61/67 — the conflict-follow's Done gains the WHY (the account's words are the ones the OTHER device showed when it entered Castle — "look at what you just put into Castle"); 46 — the Castle-born-into-Standard consent sentence directs: cancel · put the Standard account in Castle · rejoin, if you don't want to leave Castle; MINOR-6 — the book's Chapter 7 and the FAQ name the website's sign-in road for changing the account password (a button to the right page is her future-round candidate).
4. **THE DEAD REPLACE-ALL-KEYS DOOR FROM THE MAIN WINDOW (found by the author at the acceptance walk, 2026-09-07 ~02:00 — *"it was just a standalone button … no checkbox … no opportunity to type my existing words"*; traced by the orchestrator in ten minutes):** the Account sheet's Encryption tab (reached from the bottom bar's *Account…*) calls `replaceKeysDoor` → `openSwitch(.replaceKeys)` sets `ProtectionController.activeSwitch` — but the ONLY presenter of `activeSwitch` on the Mac is `ProtectionPane` (Settings ▸ Protection, `.sheet(item:)` at ~190/521 + the `.task(id:)` that starts the model); from the main window nothing presents the ceremony, and the `activeSwitch == nil` guard then makes a second click a no-op. The 3b record's "the main window's bar presents it" was untrue on the Mac (the phone's `MobileProtectionSheet` does present it). Nothing was written (the vault untouched — verified live: revision 3, no rotation). FIX: present `activeSwitch` from the root (the main window — `RootView` / the notice bar's host), so every road to the door presents the ceremony; pin: the door invoked with no Protection pane mounted ⇒ the ceremony presented (red today). Until then the road is Settings ▸ Protection (the pane presents the pending model on appearance).
5. **THE DOUBLE PASSPHRASE ASK AT A FOLLOW AFTER A ROTATION (her find at the acceptance walk, 2026-09-07 08:19Z — *"I used my passphrase to sign in on my phone but then I was asked to enter my passphrase again … a little annoying"*):** ledger 54's no-second-entry follow reuses the lobby's DERIVED key only when its KDF descriptor equals the vault's — but `RotationSecrets.init(passphrase:…)` (`CorpusRotation.swift:71`) re-wraps the master under a FRESH random salt at every rotation, so after Replace All Keys / entering Castle the vault's descriptor differs and the follow asks again. FIX (`Sync/` — the rider): when the passphrase is UNCHANGED at a rotation, re-wrap under the EXISTING descriptor (the same salt; the same passphrase → the same derived key; the wrapped payload is the new master — cryptographically sound), so a device that typed the word to unlock follows with no second entry; a CHANGED passphrase keeps the fresh salt. **SCOPE (her instruction 2026-09-07): the reuse applies to the PASSPHRASE wrap ONLY — the recovery-words wrap keeps its own descriptor and its fresh salt at every act, and a pin asserts the two descriptors stay independent.** Pin: a sibling that opened by the passphrase follows a Replace All Keys with `resumes`-style zero prompts (red today: the field asks).
6. **The ceremony's *(0 of 0)* before the first window** (her observation): the re-encryption count renders `0 of 0` for the seconds between the vault write and the first pulled window; render *preparing…* (copy) until the first window lands. Copy + a face pin.
7. **The ladder's NIT-N8 face and MINOR-N4 (2)'s copy** once she rules #90's items 10–14 (the orphaned Apple-held copy's recovery door is a DESIGN item, not this entry's).

### CLOSED 2026-09-21 — the dispositions (RUN A batch A2 + the run's ladder; the record is `notes/plans/run-a-custody-text-loss.md` — the BATCH A2 RECORD + its ORCHESTRATOR ADJUDICATION)

**Items 1–4 and 6–7 dispositioned; item 5 DEFERRED → RUN B (the run's standing fence — `Sync/`,
`CorpusRotation.swift`; KnownIssues row 41 re-owned to RUN B; `notes/plans/pre-beta-standing-fix-runs.md`
carries it on RUN B's roster). The phrase-transit rider (KnownIssues row 32) rode here and is
RESOLVED. Nothing dismissed as hollow.**
- **Item 1 FIXED, with ONE DEVIATION FROM THE ENTRY'S LETTER, stated plainly:** the latch landed
  (`SampleLibrarySeeder.withSeedLatch` — one discover-then-mint per book per store, the waiter
  re-discovering inside it; `EncryptionBookDoorTests` +3, red twice on the true pre-fix tree), but
  **the named `purged_row` consult CANNOT BE BUILT** — 13j's ledger is content-free BY DESIGN (ids
  only, never names; `10_phase13j_purge.sql` §3, verified independently by the implementer and the
  orchestrator), so nothing surviving a purge can answer *"was a book called this deleted?"*. The
  honest equivalent shipped instead: the roads RECORD THE READER'S DECISION WHILE THE EVIDENCE
  STANDS (the ensure marks when it declines on the tombstone; restore marks when it mints or finds
  whole) — MINOR-N3's ruled principle in its own terms. Residuals recorded: the mark is
  `UserDefaults` (the seeder's header carries the limit and the store-`setting` road that would
  close it), and **the launch seeder's cross-device deletion blindness is a NEW KnownIssues row,
  owner 17e, the product call hers at #138(f)**.
- **Item 2 FIXED** — the drill's escrow pair overridden for its throwaway scope; the leg FIRED
  under `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` (*"legacy iCloud escrow item removed → true"*,
  quoted; re-run by the orchestrator's own hands). Her-Mac read-only confirmation: the flagless
  `security` search finds no legacy escrow item (exit 44) — recorded as CORROBORATION (it cannot
  see a synchronizable item) with the strong answer being her real store's `migrated2a = 1`
  marker, also read.
- **Item 3 FIXED** — her four ruled #90 wordings as constants + pins on BOTH platforms; ledger 54
  built as a RULE (one label brain over `ProtectionController.followAsksNothing`, six render sites
  + the Encryption tab); two shipped verbatim pins re-based as the ruled-change class.
- **Item 4 FIXED** — the ceremony's ROOT presenter on `ProtectionNoticeBar` (already the follow's
  presenter); the host decided ONCE at `openSwitch`, double presentation impossible; revert R1
  discriminated (6 issues, all in the new pin).
- **Item 6 FIXED** — the gate is the FIRST WINDOW (`total == 0`), the four byte-identical
  running-line switches collapsed to ONE brain, a grep pin banning a fifth copy.
- **Item 7 VERIFIED + FIXED** — NIT-N8's face STANDS post-13u4 (its pin re-run, extended to the
  pane mounted at 720×552); MINOR-N4 (2)'s `.failed`-after-`regenerated` copy landed PROVISIONAL
  in the ruled ledger-61 sentence family (#138(a)); `WordsCeremony.regenerated` set AFTER the
  generate so the flag means what its readers assume.
- **The phrase-transit rider VERIFIED, and the one world it found FIXED** — `VaultTie.make` traced
  arm by arm (after 3a no production road makes a wrap-free vault; arms 1–2 green either side,
  the row's own success criterion); the survivor `.newerFormat` (where `hasRecoveryWrap: false`
  means "I cannot tell") was minting a second secret — RED on old, fixed in the one door that
  starts at the phrase half. KnownIssues row 32 RESOLVED.

**This letter's ratify rows: #138 (seven items). The re-seed consequence (Lesson 2 / Chapters
2 · 7) rides her ONE bundled press — see the run's checkpoint report.**

**ITEM 5 RESOLVED 2026-09-22 — RUN B batch B3 (the deferred row comes home):** FIXED as the entry
wrote it — `RotationSecrets.derive(forRotationOf:)` reuses the vault's KDF descriptor when the
typed word is UNCHANGED, **proven by opening the vault's own passphrase-wrapped master** (never
guessed from UI state); a changed word keeps the fresh salt byte-unchanged; **her scope line held
STRUCTURALLY** (the recovery wrap derives fresh from the act's words in both arms, its
independence pinned). Three pins revert-verified at BOTH layers (her double ask reproduced in
core — `unwrapFailed` on the held key — and at the door — `.askPassphrase`); the nine attacker
arms byte-untouched; ledger 54's no-second-entry follow now holds ACROSS Replace All Keys /
entering Castle. KnownIssues row 37 resolved. The record: the run plan's BATCH B3 sections.

## 17m — THE RE-LINK-YOUR-APPLE-ACCOUNT DOOR (her ruling 2026-09-07 ~02:05 on QUESTIONS #90's item 10 — *"I think we do need a re-link your apple account door. I'd maybe make it a 17 item and I'll have to run that before release, so it should go on the plan for before release"*; PRE-RELEASE — on the running order before 🚀)

**What it closes:** in Standard, the vault's Apple-held copy of the master is wrapped under the iCloud key `A`; if `A` vanishes from iCloud Keychain (an iCloud Keychain reset; the establishing Mac switching Apple IDs) a device holding the master mints a fresh key for its own file but the vault's copy stays under the vanished one (the ladder's MINOR-N1, option A — the heal keys on a READ of a different id, never a mint), so new devices on that Apple ID lose Standard's nothing-typed enroll until the vault's copy is re-landed — and the only road today is Castle → Standard. **The door:** Settings ▸ Account & Encryption (Standard only) — *Re-link your Apple account…*: a CONSENT sentence naming which Apple account will hold the key from now on (copy — 13s re-voices), the passphrase (a key act), then one proof-authorized vault write re-landing the master's Apple-held copy under this device's readable `A` (the `relandAppleHeldCopy` road F2 built for the heal — the same shape, behind consent). Refuses when `A` is unreadable here (the waiting face). Pins: the orphaned state → the door → a new device enrolls with nothing typed; a different-Apple-ID device's door names ITS account in the sentence. The book's Chapter 2 / the FAQ gain the door's sentence. Review: an Opus cold review always; a Fable one (custody code).

### CLOSED 2026-09-21 — the disposition (RUN A batch A3 + the run's Fable ladder; the record is `notes/plans/run-a-custody-text-loss.md` — the BATCH A3 RECORD + its ORCHESTRATOR ADJUDICATION)

**FIXED — built to this entry's spec through the F2 heal road behind consent.** The brain is
shared (`Shared/AppleRelinkModel`): refuses BEFORE any screen (Castle · a follow owed · no
readable `A` — the waiting face's existing vocabulary, MINOR-N4 (1)'s door pattern), one consent
screen naming the Apple account the only honest way the client can, the passphrase as the key act
through `KeyActPassphrase` (the ceremony's verification rule hoisted VERBATIM — one rule, not
two), then ONE proof-authorized re-land — **reading the iCloud key, never minting it** (decision
30; discrimination-revert-verified both ways: the read-never-mint arm and the consented-id
guard). Pins `AppleRelinkDoorTests` (8): the orphaned state end-to-end (a new device enrolls with
nothing typed), the consent naming THIS device's account, and every refusal arm leaving the
vault's revision exactly where it was. The face: a *Your Apple account* section on Settings ▸
**Protection** (the entry's "Account & Encryption" predates 13u4's nine-pane split — placement
PROVISIONAL, #139(a)), rendered only where the door can act (P-2). The book's Chapter 2 + the FAQ
brief carry the door's sentences (the re-seed bundle). Live iCloud is not agent-exercisable: the
acceptance is the DRILL kind (harness worlds over the real proof/CAS-enforcing emulation) plus
the walk's honest ABSENCE capture (Castle renders no door). **MOBILE PARITY row PL-37** (the
phone owes a face only — the brain is shared; whether at all is hers at #139(f)). **This letter's
ratify rows: #139 (seven items).**

## 17n — THE ENCRYPTION PASSPHRASE'S 12-CHARACTER FLOOR (her ruling 2026-09-07 ~02:30: *"we can make the encryption passphrase requirement 12 characters as well — maybe make that another 17 item"*)

The 12-character floor shipped at pre-13x 3b is the ACCOUNT password's (decision 25); the ENCRYPTION passphrase — the secret that wraps the library key and the master, and the one an offline attacker with a stolen backup + key file can guess against at the shipped KDF floor (Argon2id 19,456 KiB · t = 2) — has no length floor. Build: a 12-character minimum at every door that SETS the encryption passphrase (sync setup's first device, change passphrase, the migration's confirm where a new word is set, Replace All Keys' new-passphrase checkbox), refused with one sentence (copy — 13s re-voices), never applied to an EXISTING passphrase at unlock (an old shorter word still opens; the change door then asks for a longer one). Pins on both platforms; the tutorial chapter's Lesson 2 and the book's Chapter 2 say the floor once. Review: an Opus cold review; a Fable one (custody code).

### CLOSED 2026-09-21 — the disposition (RUN A batch A2; the record is `notes/plans/run-a-custody-text-loss.md` — the BATCH A2 RECORD's row-14 section)

**FIXED — the floor NAMED ONCE (`ProtectionCopy.passphraseFloor`) with the sweep table door ×
platform × pin in the run's record.** Two real gaps closed: `PassphraseSetModel.commit` (FOUR door
sites — two Mac, two phone — with no length rule at all) and sync setup's *no-wrap-after-all* arm;
the five pre-existing literal `12`s now read the one constant. NEVER at unlock, pinned as
negatives (the primitive has no floor by design; an existing shorter word still opens; the
migration's confirm re-wraps rather than refusing at the one moment she must not be refused).
Revert R2 measured: a six-character word was accepted AND landed on the old code, the negatives
green. Walked by hand: a six-character word refused live on the Protection pane (capture
`a2/03`). The tutorial's Lesson 2 and the book's Chapter 2 say the floor once — the re-seed
consequence rides her ONE bundled press. **This letter's ratify row: #138(d).**

## 17o — THE 2026-09-06 USE-REPORT ROUND'S DEFECTS (opened 2026-09-07 at her word; the record is `notes/plans/use-report-round-2026-09-06.md`)

The fixes half of the use-report round — the product half is 18c · 18d · 18e · 18f on the master plan's Phase 18 row. Four one-surface batches (b the landing family · c the Takes faces · d the chrome singles · e the Snippets area), each run by an `opus-implementer` session under the round's Fable orchestrator, each walked by its implementer on the dev-store Debug build before its record closes; the cold review per batch is `fable-reviewer` on b (seam-adjacent) and `opus-reviewer` on c/d/e. Every row carries a traced mechanism with file:line in the round's ledger (rows 6–21 · 27 · 38–42) and lands red-on-old, or is dismissed as hollow, or is deferred with an owner. **The dispositions block is copied here at the entry's close** (the 17g precedent: the session that owns the letter writes its own entry; the round's plan stays the ONE running record).


### CLOSED 2026-09-08 — the dispositions (copied from the round's plan, `### 17o — LETTER CLOSEOUT`)

**Dispositions (the ledger rows 17o owns — every row FIXED with its named pin unless stated):**
- **b — the landing family** (`35c11948..4dd54c54` + its three-round Fable ladder to `f9f26eeb`): **row 7 FIXED** (`CurrentBlockContinuityTests.theCurrentBlockFollowsHerWriteTakesReadBlocksWrite` red-on-old 59 ≠ 65; `LandingOffsetTests` ×3) · **row 8 FIXED** (`TakesLandingTests` ×3, model-level — the rig cannot mount the whole board; walked) · **row 20 FIXED** (`LandingOffsetTests.aSeededCaretFarDownALongNoteArrivesInsideTheVisibleRect`, caret line 6930 vs the viewport 0…719 → exact) · **row 42 FIXED with row 7** (U-20 answered in use: no layout disturbed; the page moves only when the caret is off screen) · **row 47 FIXED in batch d** (`LandingOffsetTests.aRememberedCaretAtTheNotesStartIsOnScreenUnderAFarAnchor`).
- **c — the Takes faces** (`3c6bcbb6..995108ca`): **row 6 FIXED** (`PaneSurfaceTests.theLivePanesDecorationFollowsTheIndicatorPreference` + 3 arms; R22's ring preserved as the `.outline` case) · **row 14 FIXED** (`TakesCardHeightTests.theChosenBarRunsTheWholeCardOnTheRealStackBoard`, 1220.5 → 1246.0 of 1246.0) · **row 15 FIXED** (`TakesEmptyStateTests` — the door on Takes AND Lenses; the minted pane takes the ring) · **row 16 FIXED** (`TakePaneMeasureTests.aPaneThatLosesMostOfItsTextShrinksWithinOneTurn` — the macOS 26 usage-bounds high-water mark; the brain reads the fragments' bottom) · **row 32** stays 13u2's (the general trace; the measured class handed over).
- **d — the chrome singles** (`0f9496cd..2e8478c1`): **row 9 FIXED** (`ShellChromeTests.theSeamsGripIsWideCentredAndReachesIntoBothSides`; `.pointerStyle`) · **row 10 FIXED, the hypothesis REFUTED** (the popover is content-agnostic on macOS 26; the app-wide opt-out `NSAutoFillRequiresTextContentTypeForOneTimeCodeOnMac` via a partial `Info.plist` — `OneTimeCodeAutoFillTests` ×2; HER walk item: a fresh SMS code) · **row 11 FIXED** (U-8 — `theTitleLeadsWithRowTwoAndReachesPastTheOldCenteredMeasure`, 28 issues red; the Act 10 rows-4/19 pin RETIRED as a deletion) · **row 12 FIXED** (`bothTitleFacesShareOneBoxSoNothingShiftsOnClick`) · **row 13 FIXED** (`theSidebarHeadersSitOnTheirRowsEdgeWithAirBeforeTheWash`) · **row 17 FIXED** (U-19 (1) — core `9e75ded9`: `aBlocklessPostGainsAnEmptyAnchorBlockAndTheLinkLands`; the anchor consumes `firstLivePlacedBlock` since the ladder's NIT-2, pinned `58341998`) · **row 18 FIXED** (`renamingANoteMovesTheOpenStripsNameWithNoClick` — a held observation; core `e2413e0b` `Queries.tagPaths`) · **row 19 FIXED** (`aDateChangeMovesTheMastheadsDerivedTitleWithNoReopen`) · **row 21 FIXED** (`theChapterCountAndTheRowMenuEndInOneTrailingColumn`) · **row 27 FIXED** (`theVersionsDoorSpeaksInWordsAndLinksABlocklessNote`) · **row 40 FIXED** (`theFieldCollapsesOnFocusLossOnceTheNoteCarriesATag`) · **row 41 FIXED** (capture-diff, both voices) · **row 43 FIXED** (`aSeedParkedAtItsStartDoesNotGetTheSplitAcrossBothReceipt`) · **row 44 FIXED** (`theDeletingChaptersDivideLessonTeachesKeepOnTop` — the field guide's deleting chapter; her restore act is safe) · **row 45 FIXED** (`theBoardsStructuralGroupRendersEveryStructuralAct`) · **row 46 FIXED** (`theBoardBarsStructuralHelpsTellTheKeepOnTopTruth`).
- **e — the Snippets area** (`ac821f69..fb7a94cc`): **row 38 FIXED** (`SnippetOpenTargetTests.aCardsDoorNamesItsOwnGroupAndTheSnippetClicked` + `SnippetsLandingTests.openingAGroupAtANamedSnippetLandsTheCaretInIt`) · **row 39 FIXED in two halves** (the `#path` chip IS the tag door — walked, both voices; the tag filter's empty case names the door — `theTagFilterNamesTheDoorWhenNothingIsTagged`; **her tag was the FILTER, not a seeded tag** — the tutorial seeds no block tags) · the ladder's MAJOR-2 (the parked block landing never expiring) FIXED on `ShellRouter` — spent when it lands, cleared by a navigation, the order folded into `adopt(_:in:landing:)` (`ShellLandingRuleTests` · `ShellLandingMountTests` · `ShellLandingDoorTests`).
- **Nothing DISMISSED AS HOLLOW among the rows; nothing DEFERRED.** The ladders' hollow dismissals (b's R1-6, c/d/e's MAJOR-1) are findings, not rows.

**The ladders:** **batch b (Fable, three rounds):** round 1 (1 BLOCKER · 4 MAJOR · 2 MINOR · 4 NIT; 11 agreed · 0 disputed; the BLOCKER, the MAJORs and the NITs fixed by the reviewer, R1-6 hollow by measurement, R1-7 a KnownIssues row; the sanity pass's two raises fixed — the first click into a not-live pane reported, `PaneCaretLanding` keeping the shipped END on hosts the trace did not cover) → round 2 (1 MAJOR new — the note's END never counted visible — + 3 NIT fixed; the sanity pass's raise fixed — the cold-mount scroll-anchor restore parked for the settle hop, J21) → round 3 (the cap: 1 MINOR → ledger row 47, fixed in batch d; 2 NIT). **c/d/e (Opus, three rounds):** round 1 (2 MAJOR · 3 MINOR · 3 NIT — MAJOR-1 DISMISSED AS HOLLOW by the deciding pin (J30: the usage-bounds property resets when the document empties), MAJOR-2 fixed with the park moved onto `ShellRouter` (J31), the rest fixed; ⌘A recorded) → round 2 (1 MAJOR new — the park re-landing on every re-mount — fixed by spending it on landing; 3 MINOR (the order pinned via the one door; the liveness JOIN pinned; the 27-site `fixedSize` class → KnownIssues, J32) · 2 NIT fixed) → round 3 (the cap): 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT (`830caafd`); no fix pass owed. **The residue, routed at this close:** the MINOR (round 2's `adopt(_:in:landing:)` fold is right for the road it fenced, but `ShellRouter.park(_:)` is module-visible, so "park, then navigate" is still expressible by a door that bypasses `adopt` — the two mount pins park that way themselves; the doc overclaims) + NIT-2 (`ShellRouter.blockNamingDoor`, the DEBUG process-global published by every `RootView` mount and cleared by one of eight test mount sites — measured green in the adverse order, latent) + NIT-3 (`TakeCardGeometry` the round's only append-only DEBUG oracle — accumulates for the dev-store process's life) → ONE KnownIssues row, owner 13u2 (the shell/window family + the oracle hygiene); NIT-1 (the `.onAppear`/`.id` comment stating its instruction inverted against the source order) FIXED by the orchestrator in this closeout commit (comment only). Cleared with traces by the reviewer, so the closeout does not re-raise them: the new seal refusal on `markPostsAsVersions` derives from AppSpec §9's `lockPost` letter (no QUESTIONS row, no AppSpec delta); the pool road's spend cannot outrun its own async landing; `openBeside` bypasses `adopt` but can no longer meet a standing park. Nothing needed Fable in c/d/e (the seam question answered first each round).

**Finals:** core `swift test` **1498/162** (batch d's round-2 run at `273b22b9`; core untouched since) · the FULL Mac suite over the letter's final tree `941380a2`: **`✔ Test run with 2406 tests in 415 suites passed after 603.302 seconds`** (the orchestrator's own run, 2026-09-08; zero failures — the two known load-flakes passed in-run; the only `skipped:` lines are the opt-in Keychain drills) · iOS `generic/platform=iOS` build **SUCCEEDED** (batch d's round-2 run). Baseline before the letter: Mac 2338/406 at `50d47d85` → +68 tests, +9 suites. **Canon deltas** applied at the close: the Act 10 rows-4/19 supersession (U-8), the KnownIssues versions-anchor amendment + three 13u2-owned rows (the `fixedSize` class; the unvoiced tag sheet; ⌘A in a take pane), the TEXTKIT2_NOTES §3 usage-bounds finding. QUESTIONS #97 · #98 are hers.

## 17p — THE 2026-09-12 USE-REPORT ROUND'S DEFECTS (opened 2026-09-12 at her word; the record is `notes/plans/use-report-round-2026-09-12.md`)

The fixes half of the second use-report round — the product half is 18g · 18h · 18i · 18j on the master plan's Phase 18 row. Two one-surface batches (a the Takes board · b the chrome singles), each run by an `opus-implementer` session under the round's Fable orchestrator, each walked by its implementer on the dev-store Debug build before its record closes; both cold reviews `fable-reviewer` (a: the landing family; b: the decoration lane reached the editor seam). Run UNATTENDED overnight at her R-Q14.

### CLOSED 2026-09-12 — the dispositions (copied from the round's plan, `### 17p — LETTER CLOSEOUT`)

**Dispositions (the ledger rows 17p owns — every row FIXED with its named pin; nothing DISMISSED AS HOLLOW, nothing DEFERRED; row 7 RETIRED to the mobile session at her word):**
- **a — the Takes board** (`ee1f1f5a..066e2588` + the adjudication `da75fd47` + its three-round Fable ladder to `e78bc896`): **row 1 FIXED** (`TakesArticleScrollTests.aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop` red-on-old 86.0 where 0 is owed · `…aBoardLeftScrolledComesBackWhereSheLeftIt` the remount at 0 where 120 was left · `…aBoardLeftAtTheTopComesBackAtTheTop` 18.0 → 0 · `…aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` offset 0 and the row never realized → revealed at the foot · the her-hand set `herBoardGesturesEndAPendingLanding` + the six mounted face pins, 65 → 97 / 65 → 75 / 65 → 93 → unchanged) · **row 2 FIXED** (`TakesEmptyBlockFaceTests.anEmptyBlockShowsNoPlaceholderWords` red-on-old `["empty take — line kept"]` where `[]` is owed · `…theNewBlockDoorsEdgeSitsOnTheProsesEdge` 210.0 vs 218.0). Walked: captures `05`–`11` in `…-screens/17p-a/`.
- **b — the chrome singles** (`52c9e891..b84336bf` + its Fable ladder to `c3918e48`): **row 3 FIXED** (`TrayFilterTests.theLeavingBlockRowDrawsBothVerbsAndTheOtherRowsDrawOne` red-on-old `["Put back"]` where both verbs are owed · `TrayPanelMoveTests.aLeavingBlockRowsDeleteNowConfirmsThenPurgesForGood` `pendingPurge → nil`) · **row 4 FIXED** (`CalloutEmojiPickerTests.theEmojiFieldHasRoomToTypeIn` red-on-old `field.frame.width → 0.0`) · **rows 5 and 6 FIXED** (`BlockDecorLaneTests.aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither` red-on-old the badge `(2,10,32,16)` and the glyph `(6,10,18,17)` both ∩ the prose `(8,10,604,34)` · the three-host sweep table `…everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther` · the loop-driven effect pins through the real coordinators, 448 vs 516 / 448 vs 499 · the parity pin `…writesMarginCardAndPlainCalloutAreWhereTheyShipped`). Walked: captures `01`–`14` in `…-screens/17p-b/` (`06` the before).
- **row 7 — RETIRED** to the mobile session (her R-Q9; the `mobile` branch's handoff §12.2 + §12.2a; PL-22).

**The ladders:** **batch a (Fable, three rounds — the cap):** round 1 (0 BLOCKER · 3 MAJOR · 3 MINOR · 3 NIT; 9 agreed · 0 disputed; all fixed by the reviewer; the sanity pass's slot-height drag fixed; the her-hand rule written) → round 2 (1 MAJOR new — three bare-runner doors outside the rule, "by construction" falsified by a full road table; fixed) → round 3 (1 MAJOR new — the ⌘-click pick's banner shrinking the article's VIEWPORT, a third seam; 1 NIT; both fixed; every sanity pass CLEAR). **batch b (Fable, two rounds — no round 3 owed):** round 1 (0 BLOCKER · 1 MAJOR · 5 MINOR · 4 NIT; 10 agreed · 0 disputed; nine fixed by the reviewer, NIT-4 dismissed as the implementer's trade, R1-6 → QUESTIONS #102; the sanity pass CLEAR, its two observations taken — a one-writer precondition and a byte-identity pin) → round 2 (0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT; 3 agreed · 0 disputed; R2-1 and R2-2 fixed by the reviewer, R2-3 DISMISSED on the reviewer's own re-check as hollow and a net loss for F-3; the implementer's sanity pass on three nits WAIVED by the orchestrator, recorded).

**Finals over the letter's last code tree (`c3918e48`):** batch a's 38-suite closing set 266/38; batch b's closing set 432/58 (round 1) → `✔ Test run with 432 tests in 58 suites passed after 109.450 seconds` on `c3918e48` (round 2). Core 1503/163 and the iOS build UNCHANGED (`Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`, `PaneTextAuthority` diff-empty across the letter); the FULL Mac suite runs at the round's close. No commit trailers.

**Canon deltas APPLIED in this commit:** `notes/AppSpec.md` §12's takes-presentations line — R-Q2 supersedes the FACE of R103 (an empty block in Takes is an empty line); `notes/plans/phase-13-ui-design.md` R103 — the dated supersession sentence; `notes/KnownIssuesAndTechDebt.md` — the R1-7 row AMENDED (the tutorial spine's `takesViewMemory` instance; the two suites on their own defaults) and TWO rows owned by 13u2 (the kept-alive landing's enumerated her-hand set with option (b)'s three-seam arm as the design and the reflow discriminator beside it; the decoration lane's two residuals — Write at `minGutter`, the multi-glyph clip); `notes/QUESTIONS.md` #102 (the lane on every Read page, PROVISIONAL). **Her morning items from this letter (the handoff carries them):** J3 (restore-then-reveal on a long note — one condition if she wants it), J5 (the 64 pt lane and its two levers), #102, the multi-glyph clip (what "a leading glyph" means), the recurrence signal on the landing family (six surfacings — option (b) at the 13u2 split).

**The 17 register row flips to CLOSED with this block copied into `notes/plans/phase-17-standing-fixes.md`.**

---

## 17q — THE 2026-09-12 USE-REPORT ROUND'S MORNING BUILDS + THE 18h CAP'S RESIDUE (opened 2026-09-13 at her word; the record is `notes/plans/use-report-round-2026-09-12.md`, `### R-8 · 17q`)

Her two 2026-09-13 morning rulings built (R-Q20 the landing wins; R-Q17 the card shows both where there is room) plus the 18h ladder's residue at its cap (R3-1; R3-2 riding #103; R3-4…R3-10). One `opus-implementer` session under the round's successor Fable orchestrator, walked on the dev-store Debug build; the cold review `fable-reviewer` (the landing family). **CLOSED 2026-09-13.**

### CLOSED 2026-09-13 — the dispositions (copied from the round's plan, `### 17q — ENTRY CLOSEOUT`)

**What shipped (six pieces + a three-round Fable ladder, `9488542c..03dd8a7d`):** her two 2026-09-13 morning rulings built — **R-Q20/R-Q21:** the Takes entry landing OUTRANKS the remembered page when the note's current block changed while she was away (one pure predicate `TakesBoardLayout.landingOutranks` keyed on `EditorRouter.takesArticleCurrentRows`, consulted at the two sites the two mount orders reach; a non-outranking entry landing STANDS DOWN so a plain round trip restores exactly; the fan-panel bloom is never weighed — `ArticleLandingKind`), and, found only by the ladder's walks, **the restore had never run in the app before this entry** (the first geometry report preceded `.onAppear`'s `landingEnabled` — now a construction-time fact), the memory was one scroll step stale (row-frame arrivals AND departures re-derive it, deferred and coalesced, `teardown()` closing the door), the memory is sub-row (`ArticlePlace.into`/`rowHeight`, an anchored absolute aim, a negative anchor for a short straddler, the fold for a tall one — built to measurement), and the settle now HOLDS against SwiftUI's later re-resolution (`ArticleRestore.holding`, ended by her hand, a landing's spend or the aim budget); **R-Q17/#103:** the Library's Notes card shows the stated day AND the sort's stamp where the row has room and ONE click-flipping stamp where it does not (`ViewThatFits`; ONE rule `LibrarySortFace.rowStamps` serving both renderers, `CatalogCardStamps` in `LibraryTimeFace.swift`), the List row's beside-the-title day through the one brain and standing down under the `date` sort (R3-2); **R3-1** the synchronous selection clear on a mode change (`modeChanged() -> Bool`); **R3-4…R3-10** all seven NITs swept (R3-10 in the half with no trade). Her R-Q22 ruled #105 (a). No product invention beyond the PROVISIONALs recorded on #103.

**Dispositions (every item FIXED with its named pin; nothing DISMISSED AS HOLLOW; nothing DEFERRED except the owned residue):**
- **R-Q20 + R-Q21 FIXED** — `TakesArticleScrollTests`: `theLandingOutranksAMoveToAnotherBlockButNotAPlainRoundTrip` (pure; red on old `.scrollToRow("left")` where `.remember(.top)`, `articleRestoreAims → 1` where 0) · `aLandingOnAnotherBlockWinsOverTheRememberedPlace` (mounted, 60 blocks; red on old `articleRestoreAims → 3` where 0 — J3's double move in a number) · `aPlainRoundTripComesBackExactlyWhereSheLeftIt` (red on the as-built rule: nine blocks away, aims 0 where > 0) · `theEntryRingsOwnRoadAlsoComesBackWhereSheLeftIt` (the premise established at the round-1 raise) · the ladder's: `theBloomDoorStillGoesToTheBlockTheRingWasLastIn` · `aBloomLandingRidesThroughTheRestoreInBothOrders` · `theRestoreRemembersWhereTheRowSatAndPutsItBackThere` · `aPlainRoundTripComesBackToTheSameLineNotOnlyTheSameRow` (571 → 618 pt) · `theTakesBoardIsTheTakesBoardFromConstruction` (W-1, red by revert) · `aRowFramesArrivalReDerivesTheMemoryTheScrollHookWroteOneStepStale` · `theSessionsMemoryFollowsTheRowsFrameReports` · `theTopStandDownHoldsInTheAppsOrderToo` · `aPageLeftAtRestComesBackAtRestOnTheAppsOrder` (56 aims, offset 1205 where at rest) · `theMemoryFollowsTheRowsWhenTheRememberedRowLeaves` · `tearingTheBoardDownLeavesTheMemoryWhereTheLastGeometryPutIt` · `aShortRowStraddlingTheFoldComesBackAboveIt` · `aLongRowAtTheFoldComesBackWhereItSatNotAFractionOfIt` (9.0 where ≤ 2) · `aTallStraddlerComesBackAboveTheFoldAndStaysThere` (15.0) · `theRestoreHoldsThePlaceUntilHerHandOrALanding`. Walked: captures `01`–`07`, `17`–`19`, `20`–`30`, `31`–`40`, `41`–`48`, `49`–`57` in `…-screens/17q/` — the plain round trip on the 262-block note byte-identical on every shape the three rounds found.
- **R-Q17 FIXED** — `LibraryCardStampsTests` ×5 (`theTwoFactsARowShowsAreTheStatedDayAndTheSortsOwnStamp` · `aWideCardShowsTheStatedDayAndTheSortsStamp` · `aSmallCardShowsOneStampAndAClickFlipsIt` · `aNoteWithNoStatedDayShowsItsOneStampAndNoFlipDoor` · `theListRowSpeaksTheOneBrainAndNeverPrintsOneDayTwice` — R3-2's red on old by behavioral revert: `"2026-01-15"` beside `"dated Jan 15"`). Walked: `08`–`11`, `14`–`15`. **R-Q22:** #105 RULED (a), nothing built.
- **R3-1 FIXED** — `LibraryDayFilterTests.theModeChangeClearsThePickInItsOwnUpdate` (a compile red — the fix IS the signature; measured by revert). Walked: `12`–`13`.
- **R3-4 · R3-5 · R3-6 · R3-7 · R3-8 · R3-9 · R3-10 FIXED** (each labelled byte-identical or doc-only in the record; R3-10's two-window edge LEFT with its reason → the 13u2 row).
- **KnownIssues row "The 18h ladder's residue at the cap" (owner 17q) — RESOLVED, removed in this commit.**

**The ladder (Fable, three rounds — the cap; the cross-model flow):** round 1 — 0 BLOCKER · 2 MAJOR · 2 MINOR · 4 NIT (8 agreed · 0 disputed; 8 confirmed; the reviewer's mandatory re-walk found W-1 and W-2; the sanity pass 10 CLEAR · 1 RAISED, upheld) → round 2 (fresh) — 0 · 3 MAJOR · 0 · 3 NIT inside round 1's fixes (6 agreed · 0 disputed; 6 confirmed, one rider falsified by measurement, one measured red and shaping the fix; the sanity pass 6 CLEAR) → round 3 (fresh, the cap) — 0 · 1 MAJOR · 0 · 1 NIT (2 agreed; 2 confirmed; the sanity pass 9 CLEAR · 1 RAISED, upheld by the orchestrator at the close). **Nineteen fix commits across the three rounds, every one with its measured red; the entry's code diff `634a57c4..03dd8a7d` touches fourteen app/core files + three test files.**

**Finals over the entry's last code tree (`03dd8a7d`):** Mac — the 34-type closing set `✔ Test run with 261 tests in 34 suites passed after 159.341 seconds.` (zero skipped); core `✔ Test run with 46 tests in 5 suites passed` (piece 4's run — `Sources/` moved only at R3-5/R3-7, both rounds' fix passes left it untouched, verified diff-empty `9c57f977..HEAD`); iOS `** BUILD SUCCEEDED **` (piece 4; `Shared/` untouched since). `Sync/`, `Server/`, `PaneTextAuthority`, `PaneSurface`, `BlockRangeIndex`, `EditorTextView` diff-empty across the entry; zero schema, zero `setting`, marker 8. No commit trailers on any of the entry's commits. The FULL Mac suite runs at the round's close.

**Canon deltas APPLIED in this commit:** `notes/AppSpec.md` §12 — the takes-presentations line gains the memory + landing rule (R-Q1 → R-Q20/R-Q21 and the ladder's clauses) and the Library line gains R-Q17's card and the #103/#104/#105 statuses; `notes/KnownIssuesAndTechDebt.md` — the 17q-owned row REMOVED (resolved), row 54's residue clause gains the page-tall-shape sentence (the J23 raise) and ONE new 13u2 row (the `FlippingStamp` hoist named at R-8; R3-10's two-window oracle edge; R1-4's `onDisappear` ordering note); `notes/plans/phase-17-standing-fixes.md` — the 17q register row CLOSED and this block copied into the entry; `notes/MobileSoul.md` PL-22 — 17q's parity note (nothing owed by construction; the phone's picker words byte-identical; the landing rule owed only if the phone's Takes ever gains a scroll memory); `notes/QUESTIONS.md` #103 BUILT + #105 RULED were landed inside the entry. **Her items from this entry:** J14/J17 ruled at the sitting (R-Q21, R-Q22); the three PROVISIONAL calls on #103; the machinery lesson for the handoff's §6 — a mounted harness whose `.onAppear` precedes its first geometry cannot reproduce the app's mount order, and twice a green mounted pin masked a wrong app: the landing family's acceptance evidence is USE, walked on more than one note shape.


## 17t — THE TWO UNWIRED PROTECTION DOORS (minted 2026-09-25 at the 18k kickoff sitting, R-18k-2 — her words: *"17t and add that to an 18"*; RIDES 18o)

**Status: CLOSED 2026-09-30 at 18o U5** (the record's UNIT U5 RECORD + ADJUDICATION; the
custody Fable rider fired — the phase's two-round Fable ladder covered the diff, zero
BLOCKER/MAJOR). The two items' fates:
1. **DISMISSED AS HOLLOW, her call bundled (QUESTIONS #164):** the typed near-empty
   confirmation's premise is GONE — the rebuilt Replace All Keys pulls to head first, then
   re-encrypts the server's own rows in place (`sync_reencrypt`); no local row ever overwrites
   a server row. `RekeyRecencyProbe`'s zero consumers is BY DESIGN (its UI caller deliberately
   retired at pre-13x 2b — the design's §13 sweep table, verified at the source); rows 54/this
   item mis-read the ruled retirement as an omission. Evidence pin
   `PostureSwitchTests.aNearEmptyCopysReplaceAllKeysLosesNothingTheFullerServerHolds` GREEN on
   today's tree (M-noPull reds it 15). Her #86(c) ruling is closed only at HER word — #164,
   (a) close-as-answered recommended.
2. **FIXED for the Mac (`ccf6eefc`):** COPY ALL on all five Mac words screens through ONE
   `WordsCopyDoor` (the pane's 60 s clear hoisted verbatim, no second timer); the shared
   enrollment page's dead "Copied" branch reachable; pins red-on-old 4. QUESTIONS **#165**
   (Universal Clipboard reach — OPEN, hers). The phone's word screens stay the mobile app
   project row's.
**Items (the two KnownIssues rows are the brief; both found at 13u2 UNIT D's roster-item-8 verification, 2026-09-15; orphaned when 17l closed 2026-09-21; interim-owned by 18k 2026-09-22):**
1. **The typed NEAR-EMPTY sync confirmation (#86(c)) was never wired** — `Sources/VariorumCore/Sync/RekeyRecencyProbe.swift` has ZERO app consumers; #86(c)'s ruled home is "with the rebuilt Replace Keys" (#87). Note: the probe lives in `Sync/` — the standing rider.
2. **COPY ALL on the recovery phrase exists in ONE place** (the Mac's `ProtectionPane`, with the 60 s clipboard clear); three models declare `markWordsCopied()` with one call site, so the SHARED `SyncEnrollmentView`'s "Copied" caption can never show. The Mac wiring + the shared page's dead branch are 17t's; **the phone's three word-screen doors stay the mobile app project row's** (beside PL-23).

## 17r — THE STAMP FACES' MIDNIGHT ROLLOVER TICK (minted 2026-09-21 at the 13u4 closeout — KnownIssues row 51's surviving remainder, given its lettered owner per that file's own rule; OPENS AT HER WORD)

Every stamp face takes `now = Date()` at render with no day-rollover tick, so a window left open across midnight reads *"today …"* for yesterday until any interaction. The brain (`TimeStampFace`, core `Domain`) is correct and pinned; 13u4 UNIT S2's hoist verified a tick is NOT free (no clock lives in the shared `Core/Views/FlippingStamp` component, and building one would tick every stamp in every list — a deliberate-cost decision, never a patch). The remedy when she opens this door: ONE shared midnight tick republishing `now` (a single scheduled publisher the stamp faces observe), plus a pin. Cosmetic — no data is ever wrong, only the word "today" one day stale on an untouched window. Pin-before-fix binds as everywhere in this file.

## 17s — THE DROP-OUT RETURNER'S RESCUE (minted 2026-09-21 at the RUN B kickoff sitting — QUESTIONS #141 RULED the same day it was filed; OPENS AT HER WORD)

**Her ruling, verbatim (2026-09-21, on #141's options): *"hmm yeah maybe make it a 17 issue for
later that i want to switch to b eventually but i don't see why i'd need to do that now."*** So:
**the destination is option (b)** — before the ledger pre-pass drops a purged family from a
60-day drop-out returner, the family's locally-DIRTY texts and never-pushed takes are RESCUED
into a fresh local note (the conflict-as-variant instinct applied at the purge boundary); the
rows still drop, so the purge-wins convergence — no refusal, no mirror orphan, the
`aReturnersUnpushedChildNeverLandsAsAMirrorOrphan` guarantee — is untouched; only the WORDS
survive, locally. **Until this entry runs, shipped option (a) — the silent family-complete drop —
stands as the pinned contract** (`SyncReconciliationProbeTests.p2bTheSixtyDayDropoutReturnerDropsItsEditsWithThePurgedFamily`,
green on (a); RUN B batch B1's probe P2(b) is the trace — the full mechanism is that batch's
record and the memo's ANSWERED block).

**What the entry settles when it runs:** the rescue note's shape (one note per dropped family vs
one per session; its title/wording — 13s may re-voice), whether the rescue speaks a line ((b)
carries (c)'s honesty nearly for free), and the rescue's own sync posture (the fresh note is
ordinary local rows that push normally). **The pre-pass is `PurgeJanitor` — `Sync/`, the standing
Fable rider.** Pin-before-fix binds: the build RE-BASES the (a) pin to (b)'s expectation, which
is red-on-old by construction (today's code drops; the new expectation rescues).

## 17u — THE LOCKED LOBBY'S BACKDROP (her 2026-09-25 between-rounds ask; built the same day in the author-attended Fable session)

**Her words, verbatim:** *"I don't like the art that's on the Variorum locked screen — the tesselating
tiles of the art with the humanoid figures and the book. make sure that doesn't appear anywhere
anymore and replace the lock screen decoration with code that animates a view of top down lines of
code, kind of a matrix style decoration of letters and numbers flickering … it should be in black
and white on the lock screen and shouldn't be distracting from the central pane … you have some
artistic liberty here."*

**What shipped:**
1. **The tile is gone from the app.** `App/Variorum/Variorum/Resources/lobby-endpaper.svg` (the
   `girl-and-the-fan` endpaper, placed by pre-13u Act 10 item 7) is removed from the repo and so
   from the bundle; `StoreLockView`'s loader, its bundle-locator class and the tiled `Image` are
   gone with it. It was the ONLY consumer on either platform (the phone's lobby never carried it).
   The brand ORIGINAL at `notes/brand/concept-art/girl-and-the-fan.svg` is untouched — brand
   archive, not the app, and hers to keep or cut. **Pin:** `GlyphRainTests.theTessellatingEndpaperTileIsGoneFromTheApp`
   walks `App/Variorum` for the asset name and both names in every Swift source.
2. **`GlyphRainBackdrop`** (`App/Variorum/Variorum/GlyphRainBackdrop.swift`): columns of
   monospaced glyphs — digits, letters, a little code punctuation — falling top-down at unequal
   speeds, each a head with a trail fading to nothing, trail glyphs flickering ~1.4 Hz, the head
   ~5 Hz, at ~14 frames a second (the stepped cadence is the look). **Monochrome by construction:**
   the one ink is the voice's `ink` token over the voice's `room` — black on paper in light, white
   on the black room in dark (R51) — no literal colour, so the 18j pin stands. **Not distracting
   by construction:** the head never exceeds 30 % (light) / 42 % (dark) of the ink, the trail
   decays quadratically, and a radial wash of the room rises behind the card (centred on the
   upper third where the card sits) so the pane stays the loudest thing. Reduce Motion pauses the
   timeline on one populated still frame. The backdrop is hit-test-transparent and hidden from
   accessibility. **The brain is pure** (`GlyphRain.cells(at:)` — a function of grid, time and
   seed, the travelling-dots idiom): five pins cover the alphabet, determinism, on-grid sparse
   frames, one falling head per column, and slow flicker.

**Schema: zero. `Sync/`: zero. Copy: zero strings changed** (the lobby's sentences are still
`ProtectionCopy`'s). Evidence: the focused Mac suites (`GlyphRainTests`,
`ProtectionSurfaceRenderTests`, `NoLiteralColourTests`, `CopyRegisterPinTests`,
`TravellingDotsIndicatorTests`) and her look at the refreshed install — the acceptance evidence
for a decoration is USE. **Owed:** the standing Opus cold review for a 17-entry (no editor seam,
no custody, no `Sync/` — Opus suffices), unless she waives it for a decoration.

**THE INSTALL REFRESH — DONE 2026-09-26T05:4xZ** (her quit's window; zero instances checked before
the copy and before the install): A1 safety copy `Backups/safety-copies/17u-refresh-20260926T054253Z`
in the app's container (6 files — the store, its `-wal`/`-shm`, three key files — each `cmp`-identical
to the live file) · Release built from `92615e6b` · the product bundle carries NO endpaper resource ·
`/Applications` binary `79c7688b…` (18k's) → **`7f7ff281b4a566ef…`** · `codesign --verify --deep
--strict` OK on the product AND the installed copy · both keychain access groups present
*[removed for publication]*

**HER VERDICT + THE ONE TWEAK (2026-09-26):** *"I really like it. and yeah, we don't need an Opus cold
review on this purely cosmetic change. Can you make it just a little bit darker for me + reinstall?"*
— the review is WAIVED (her call, a cosmetic surface; the owed line above is discharged), and
`GlyphRainBackdrop.peakOpacity` moved 0.30 → 0.38 (light) / 0.42 → 0.50 (dark) — one constant, no
behaviour, no re-run of the suites at her word. **Second refresh:** A1 safety copy
`Backups/safety-copies/17u-refresh2-20260926T055347Z` (6 files, `cmp`-identical) · `/Applications`
`7f7ff281…` → **`c09f81be9eab5a6e…`** · codesign OK on product and install · both access groups present.
**17u CLOSED.**

## 17y — THE KICKOFF MESSAGE (written 2026-10-04 at the author's ask; SHE launches this with a FRESH Fable orchestrator AFTER 13r closes — her sequencing: "a brief pause and complete 13r, then run this phase")

You are the Fable orchestrator for **17y, THE 13i FAMILY FIX PASS** — a standing-fixes entry, not a master-plan phase. **The binding item list is this file's 17y table row (items a–q — m–q appended at her 2026-10-04 evening planning sitting, (o)'s shape ruled at the question tool there)**, every item carrying the author's words and rulings from the 2026-10-03/04 family-close sitting and that evening sitting; the dispositions behind them live in QUESTIONS #169/#173–#176/#178/#179. **FIRST ACTS, before any 17y batch: run 19e and 19g from `notes/plans/phase-19-standing-fixes.md` (their per-entry reviews WAIVED at her word, the evening sitting — each pin going green is its whole verification), so this pass's finals read fully green instead of "green modulo two named reds."** Nothing here invents product behavior: each item is a defect against a ruled contract, or a behavior she ruled at that sitting. 17z (the duplicate/version-of exploration) is NOT yours — it opens separately at her word.

**PREFLIGHT (mandatory, complete, never delegated):** CLAUDE.md + its auto-loaded canon · the master plan (expect the post-13r pointer — this pass runs on the POST-13r TREE; re-verify the 17y items' surfaces against any 13r drift, expected none) · `KnownIssuesAndTechDebt.md` · `QUESTIONS.md` · this file's 17y row end to end · `notes/SessionResiliencyProtocol.md` · `notes/TEXTKIT2_NOTES.md` (item (j) reaches the read tier) · per-item binding records: `notes/plans/phase-13i-d-bookcase.md` (U1/U2 RECORDs for (a)(b)(e); U5/U5b + the ruled QUESTIONS #174 refinement for (f)), `notes/plans/phase-13i-b-gatherings.md` + `phase-13i-e-daily-journal.md` (for (h)), 13i-c U3's rule-editor record (for (g)). For the m–q additions: (q) reads the seeder's records (13i-d's seed work — `ensureWelcomeShelf`, `SampleLibraryDedupeFacts`; Sync-adjacent, so the Fable review rule binds that diff); (n)'s capture is `notes/plans/17y-screens/title-chrome-shift.png`; (o)'s ruled shape is in the row; (m) and (p) trace from their surfaces.

**CAST (the standing default):** you orchestrate; `opus-implementer` per batch, ONE at a time, fresh per batch; cold review per batch — **Fable (`fable-reviewer`, or you per the standing rule) is MANDATORY on any diff touching the read tier/editor seam (item (j))**; `opus-reviewer` eligible where a batch has none. **No `Sync/`, custody or schema is expected ANYWHERE in this pass — if an item turns out to need one, STOP: that is a §12/author event, never a fix-pass act.**

**PROPOSED BATCHES (finalize at your judgment; strictly sequential; one batch = one acceptance unit):**
**THE EXECUTION ORDER (planned at her 2026-10-05 ask — "make sure that it's thoroughly planned now"): B0 → B-SEED → B2 → B3 → B1.** One pass, one entry; a FRESH implementer per batch and a cold review per batch (the sizing rule: one acceptance unit per session). This pass runs ON MAIN — the last main-direct run; branch discipline begins with the second Mac's parallel work (issue #7). B0 and B-SEED and B2 run tonight/overnight unattended; B3 runs Monday and ends at HER ONE SITTING (the bundled picks); B1 runs last (Monday night → Tuesday) because its close is use-shaped — her live scroll walk and her feel, which no overnight can produce.

- **B0 — the ledger clears (minutes):** 19e + 19g from `notes/plans/phase-19-standing-fixes.md`, reviews WAIVED at her word — each pin going green is its whole verification; every later batch's finals then read fully green.
- **B-SEED — the tutorial-seed trace, FIRST REAL BATCH, TONIGHT (time-sensitive):** (q) alone — the mechanism must be in hand before her Monday fresh-install + sign-in on the new MacBook, which is the verification bed. The seeder is Sync-adjacent (`ensureWelcomeShelf`, `SampleLibraryDedupeFacts`): FABLE cold review, per the standing rider.
- **B1 — the two performance items.** (j) the in-note Index scroll: TRACE FIRST — the quick-scroll-to-top symptom points at the height-estimate/jump-correction family; check whether the book Index shares the mechanism. (k) the Library infinite scroll: the located mechanism is `LibraryCatalogModel.pageSize = 40` with no load-more; build keyset `(stamp, id)` pagination, never a raised cap; plus the All-screen's books region capped at ~half the vertical area with internal scroll. **(k) is a LAUNCH BLOCKER and carries HER SMOOTHNESS BAR verbatim (the row above): both Library views, zero felt degradation, use-shaped evidence required — a live scroll walk on a large fixture, and her feel at the close. Pins alone cannot close B1.**
- **B2 — the drag mechanics:** (a) unshelved→shelf drop dead, (b) my-order reorder absent beyond Send to Top/Bottom (+ the affordance — her drag-bars ask), (e) the Book Panel's handles that don't drag (trace the sort gate and the silent finished-refusal candidate) — PLUS the small defects from the m–q appendix: (m) the quick-note double cursor (exactly one cursor blinks at a time), (n) the title chrome shift (find the PRIOR landing first — her "still"; the capture is `17y-screens/title-chrome-shift.png`), (p) Canvas debug-only (Release loses the mode, Debug keeps it; the ⌘-number derivation shortens; enumerate Canvas's other doors). Two trace families + three singles; pin-before-fix each.
- **B3 — faces, vocabulary, ruled behaviors:** (c) Duplicate as Version carries tags (Diverge STAYS tag-less), (d) the cards view → "Cards", (g) tag pickers: create-in-place + searchable (scope whether every picker adopts the control — propose, she picks), (o) the add-to-book picker: the SAME control idiom — type-to-filter search + the INLINE-MINT create door (her question-tool ruling, in the row: a 'New book "X"' row mints a plain book in the current wing and adds the note as an ORDINARY membership — the ownership consult and capacity gate run exactly as on every other add road), (h) the Arrivals door: MOCK BOTH placements (the mode-row icon beside the gear — her lead and the architect's — vs. the navigator's bottom) for HER pick; calm-when-empty/presence-when-waiting; rows OPEN the waiting note (opening never seats); the ONE WORD across dial/line/chip/receipts, (i) unfiled vs. No Chapter — one word, (f) the cross-wing follow — SHAPE RULED, build detail only: switch on OPEN with the quiet "Now in X" receipt; split panes follow the FOCUSED pane's note on focus; one app-wide wing stays the truth; editors never close; the wing indicator on cross-wing Open rows, (l) the book-row context menus beyond the Bookcase (enumerate the surfaces; Star at minimum; positional items omitted where meaningless).

**RULES THAT BIND:** pin before fix, red-on-old verified by revert, per item; no fix without a self-traced mechanism; a pin green on both sides is a hollow finding — record it, don't fix it. The ladder per CLAUDE.md, fresh reviewer per round, findings and dispositions repo-first. Her pending picks ((h)'s placement; (g)'s scope) bundle into ONE sitting at B3's close — do not drip questions. LIVE STATUS from the first commit; commit and push per piece; synchronous foreground waits only. The entry CLOSES only on B1's use-shaped evidence and the author's word; dispositions land in this entry per item at close. Hard stop after; 13r's successor ordering is hers.

## 17y RUN RECORD — LIVE STATUS (the orchestrator's running record; born 2026-10-05 00:58 with the first commit)

**THE TREE:** this pass runs in the worktree `~/dev/variorum-17y` (branch `main`, commits land on
main directly and push to `origin/main` — "runs on main" satisfied). Reason, decided at kickoff
preflight: the primary checkout `~/dev/variorum` is HELD LIVE by the strings-workbook session
(`variorum-65`, busy, committing minutes apart on `tools/strings-workbook` with an uncommitted
test-iteration diff at 00:50) — two writers on one tree is the one way the checkpoint protocol
loses work, so 17y took its own worktree instead of touching that checkout. Successor rule: work
in `~/dev/variorum-17y`; never commit, stash or checkout in `~/dev/variorum` while that session
lives; the worktree is removed at the pass's close (after its last push).
DerivedData for this pass: `App/Variorum/DerivedData/17y/` (in the worktree; swept at close).

**EXECUTION ORDER (hers, 2026-10-05, amended at her R-17y-5: B0 → B-SEED → B2 → B3 → B-DEDUPE →
B1 → close + 0.9.2).** One pass, one entry; fresh implementer per batch; cold review per batch.
HER STANDING FRAME (verbatim, 2026-10-05 ~02:55): "quality is always paramount, dates are always
provisional" — Monday is the goal, never a gate; the quality bar never bends to it. Her
pre-answered rulings R-17y-1…6: `notes/plans/17y-sitting-rulings-2026-10-05.md` (binding).

- **B0 — the ledger clears: DONE** (this commit). 19e: the one-word runbook sync; the standing
  red `DataSafetyRunbookTests.theShippedRunbookAndTheRepoCopyAreOneDocument` green (5/5 suite).
  19g: `.lineLimit(1)` at the four named sites; `ChromeLineLimitTests` green. Both reviews
  waived at her word; the documented pre-existing reds at the 19f finals are the red-on-old.
  Both 19-ledger rows flipped CLOSED. Full-Mac finals now read fully green (no named reds).
- **B-SEED — (q) the tutorial-seed trace: CLOSED 2026-10-05 ~02:55.** The mechanism (in the
  record before the fix): nothing on the launch path ever seeded the field guide — door-only
  since 13b; U7 shelved it by name at birth but never minted it. The fix: `TutorialSeeder.
  seedAtBirth` on the Welcome arrangement's arrange-now road (silent, latch-honoring, no
  retrofit, her deletion stands, residue never silently replaced). Pins red-on-old (2 issues)
  + two announced revert rounds (2 and 8 issues, restored); suites 103/12 + the spine 98/13
  green; walked both voices. THE LADDER: ONE round, Fable cold review — **0/0/0/2 NIT, both
  record-only** (`notes/plans/17y-bseed-ladder-round1.md`, bd324f15); ORCHESTRATOR'S
  DISPOSITIONS: NIT-1 (the birth-window door swallow) stands dispositioned at P-17y-BSEED-4 /
  #183(e) — hers, none gating; NIT-2 (the refused-then-done corner) record-only by the
  reviewer's own honest no-pin label. No fix round owed; the ladder closes at round 1.
  Residuals: the two-guides-after-sign-in class re-owned to B-DEDUPE (R-17y-5); her Monday
  install is the live bed (the public 0.9.1 build predates the fix — 0.9.2 carries it).
- **B2 — drag mechanics + three singles ((a)(b)(e)(m)(n)(p)): CLOSED 2026-10-05 ~06:10.** All
  six fixed with red-on-old pins and walked (the B2 RECORD below; the shared mechanism: the
  three in-app drag types were never declared in the Info.plist — 13i-d's "harness artifact"
  verdicts were this defect). Union 335/62 + spine 98/13 green; phone + Release compile green;
  fences EMPTY across the batch AND the fix round. THE LADDER: round 1 (opus, cold) **0/2/2/6**
  (`17y-b2-ladder-round1.md`, 7b3ab4e2) → the FRESH fix-round session fixed MAJOR-1 + MINOR-1 +
  all six NITs with revert-proven pins (18 commits, 873fed6b; END 236/42) → round 2 (fresh
  opus) **0/0/0/3, every round-1 fix CONFIRMED by independent probes, no round 3**
  (`17y-b2-ladder-round2.md`, 4313a5bc; the three new comment/record NITs fixed at the
  adjudication seam, F-FR-1/2 dispositioned record-only). THE ORCHESTRATOR'S SPOT-WALK
  (1b3ae986): MAJOR-1's "reopen it first" live on the finished Journal, the grips + a row drop
  landing on the final tree, NIT-3's kept slot, (n) in passing. RE-OWNS OUT: MAJOR-2 → B-DEDUPE
  (the guide's Canvas teaching); F-B2-7 → B3 item 11 (the book view's own silent gate). HER
  MONDAY SPOT-CHECK list: the Bookcase drags, the Book Panel drags, AND the Open strip's row
  reorder (F-B2-2 — the same undeclared-type class, declared in the same commit, never
  human-walked).
- **B-DEDUPE — the whole-set seed-duplicate fold (R-17y-5, trimmed at R-17y-8): CLOSED 2026-10-05 ~14:30.** THE LADDER: round 1 (fresh fable-reviewer on the orchestrator's own diff) **1 BLOCKER · 3 MAJOR · 2 MINOR · 2 NIT** — the BLOCKER was the review system working exactly as designed: the SHIPPED guide's word target/seed comment/sealed lesson read ENGAGED and the headline object never folded while the record overclaimed; the orchestrator's fix round moved seed-authored state into the PAIRWISE IDENTITY with TWO real-shape pins (the shipped-shape core fold + the Mac REAL-SEED drift guard over two true `TutorialSeeder` mints), revert-proven → round 2 CLEAN (no round 3; its 1 MINOR + 3 NITs landed same-seam, the comment tuple's real placement index pinned). Records: `17y-bdedupe-ladder-round1.md` (both rounds + fixes). Suite 17/17 · Mac guard 1/1 · core whole 2195/246 · phone green. QUESTIONS #186 (a)–(h) incl. the honest in-place correction; the crossing-race residual (g) is HERS to escalate. The KnownIssues duplicate-class row closes at the entry close with the acceptance now held AGAINST THE REAL SEED. (Original state line follows for the record:) NOT-STARTED
  (between B3 and B1). Scope as amended: the FIELD GUIDE's dedupe-facts entry; the Sync/ keeper
  for the seeded gatherings + quicknote (the Welcome keeper's adopt-by-identity pattern; rules
  judged by tag PATH; engagement keeps both; convergence suites mandatory); JEKYLL LEAVES THE
  DEFAULT SEED (R-17y-8 — the fold leg dropped, nothing retrofitted, Help ▸ Restore keeps
  minting) with her intake's ONE lesson sentence; **plus the B2 ladder's MAJOR-2 re-own: the
  guide's mode-row sentence derives from the (p) seam and its Canvas lesson gates on
  `buildKeepsCanvas`** (the helper's own precedent; the re-seed consequence rides the lesson
  sentence's, already recorded). The Sync/ halves are the ORCHESTRATOR'S OWN seat (the standing
  rider), behind a full SyncSpec + `notes/sync-postmortem-fragments.md` RE-READ (the
  pre-compaction reading is lost) and the design memo `notes/plans/17y-bdedupe-design-memo.md`
  written BEFORE building; a FRESH fable-reviewer cold round after. Zero schema — the marker
  stays 12; SyncSpec §7 gains the keeper's paragraph as the canon delta at close.
  **~07:00: the PRECONDITION READS are DONE (this orchestrator session, post-compaction) and
  THE DESIGN MEMO IS COMMITTED (3d11348f)** — the build follows B3's close, to the memo: the
  reserved-object PAIRWISE fold (fold only unengaged content-identical pairs; any doubt keeps
  both), chosen over a guide manifest classifier because the guide's seeded richness (fans, a
  callout, the twin, the scraps pool, per-build content after MAJOR-2's fix) breaks the
  Sherlock classifier's contract — the deviation from R-17y-5's sketch is the memo's
  PROVISIONAL (i), hers to overturn. **~10:45: BUILDING (the orchestrator's own hands; the
  B-DEDUPE RECORD below carries LIVE STATUS).** Scope additions folded at the ladders:
  MAJOR-2 (the guide's mode-row sentence + Canvas lesson gate) and F-B3-1 (lesson 4's
  "at the door" prose + its withKnownIssue wrapper) — three seed-content touches, ONE re-seed
  consequence, executed once at the close ritual.
- **B3 — faces, vocabulary, ruled behaviors ((c)(d)(g)(o)(h)(i)(f)(l)(r)(s) + the F-B2-7
  rider): CLOSED 2026-10-05 ~10:40.** THE LADDER CLOSED CLEAN: round 1 (FABLE, re-cast on the
  honest seam flag) 0/0/2/3 → the cross-model exchange (the implementer AGREED on all four,
  disputing none) → the reviewer's final calls implemented in its own session (MINOR-1 the
  resolved-name guard, red pin efd9aa95 verified → b1fe70ff; NIT-2 the table aligned; NIT-3
  the comment; NIT-1 HELD TO NEXT-TOUCH on the implementer's accepted pin-semantics argument,
  the safe fold scope recorded) → the implementer's sanity pass: ALL SOUND, 66/5 green at
  894c6ccf, "from my side the ladder can close." MINOR-2 = 19h minted (VR-112). Round record
  + fixes: `17y-b3-ladder-round1.md`. All eleven items built with
  red-on-old pins, walked in use (59 captures, both voices); whole-Mac END 3887/638 green
  (+ three post-END commits covered by their targeted suites — B-DEDUPE's END run covers the
  whole-target gap); phone build green; one transient 529 death mid-run, resumed in place, no
  work lost. The orchestrator's spot-walk: the starred shelf, the census overlay (zero push),
  the Arrivals icon + "arrivals · 1 waiting" popover, open-never-seats ("in no book" after).
  THE LADDER: round 1 re-cast to FABLE on the implementer's seam flag ((f)'s default's-meaning
  change + the (c) core touch) — **0/0/2/3, a clean batch** (`17y-b3-ladder-round1.md`,
  4781904a). MINOR-2 done at the seam (19h minted, VR-112); F-B3-1 → B-DEDUPE (lesson 4's
  prose + its withKnownIssue wrapper); MINOR-1 + the three NITs in the cross-model exchange
  (findings to the implementer verbatim; the reviewer finalizes and implements its confirmed
  fixes). QUESTIONS #185 (a)–(j) carries the PROVISIONALs. Residue, deliberate: three Trash
  items from its walk (listed in the B3 RECORD), recoverable 30 days.
- **B1 — the two performance items ((j)(k)): NOT-STARTED.** Runs LAST (Monday night → Tuesday);
  (j) trace-first (the height-estimate/jump-correction family; TEXTKIT2_NOTES read); (k) keyset
  pagination on `(stamp, id)`, never a raised cap + the All-screen books region cap; the close
  is USE-SHAPED — her live scroll walk on a large fixture + her feel. FABLE review mandatory
  ((j) reaches the read tier). The entry CLOSES only on B1's evidence and her word.

**CANON DELTAS OWED AT THE ENTRY'S CLOSE (accumulating; landed exactly as ruled, contract line
+ pointer):** AppSpec §12 — Canvas is Debug-only ((p), her "debug-only ratified"): the Release
note mode row is six modes ⌘1–⌘6 and the Snippets area's Canvas face is off in Release
(P-17y-B2-7/#184(g)); pointer to the B2 RECORD. AppSpec §12, from B3 (the Fable round's note
(b)): the Arrivals door is the book masthead's ICON with the ONE word "Arrivals" (R-17y-1/2 —
the content-top line's idiom retires from §12's text); the Library cards view is "Cards"; the
chapterless word is "unfiled" (R-17y-4); the Bookcase strip carries the VIRTUAL starred shelf
(R-17y-9); the app's one wing FOLLOWS the focused pane's note on open and focus (her (f)
ruling) — each a contract line + a pointer to the B3 RECORD/rulings file. SyncSpec §7 — the
seeded-furniture fold's paragraph (B-DEDUPE's, at its close).

**Standing facts for a successor:** preflight done in full 2026-10-05 (CLAUDE.md canon · master
plan post-13r pointer · KnownIssues · QUESTIONS #166–#182 · the 17y row a–q end to end · the
resiliency protocol · TEXTKIT2_NOTES owed before B1's brief · per-item records read per batch).
No `Sync/`, custody or schema expected anywhere in this pass — if an item needs one, STOP (§12 /
author event). Her pending picks bundle into ONE sitting at B3's close — no dripped questions.

## 17y B-SEED BRIEF — item (q), the tutorial-seed trace (written by the orchestrator 2026-10-05; the implementer's ONE acceptance unit)

**THE DEFECT (her report, the 2026-10-04 evening planning sitting — the full intake is
`notes/plans/phase-13s-onboarding-intake-2026-10-04.md`):** on her onboarding pass the field
guide was the ONLY element that did not appear — it had to be restored via Help ▸ Restore
Tutorial… while everything else (Sherlock, Jekyll, *Encryption Explained*, the Welcome shelf,
the classics gathering, the quicknote) "was just there". Routed here at her word: *"we can trace
the bug before i install on the new mac tomorrow"*. **Her Monday fresh-install + SIGN-IN on the
new MacBook is the live verification bed — the mechanism must be in hand tonight.**

**THE TASK, in order:**
1. **TRACE FIRST — no fix without a self-traced concrete mechanism.** Establish by reading and
   by a driven reproduction WHY a fresh store's first open lacks the field guide. The
   orchestrator's reconnaissance (verify, don't adopt): the launch task in
   `App/Variorum/Variorum/VariorumApp.swift` (~lines 180–250) seeds every sample book
   (`SampleLibrarySeeder.Book.all` behind its `SyncGate`), the starred gathering, and runs
   `SampleLibraryWelcome.arrangeAtLaunch` at a fresh store's birth — but NOTHING on the launch
   path seeds the TUTORIAL: `TutorialSeeder.findOrSeed` runs only from doors (`ShellActions.
   openTutorial`, Help ▸ Restore Tutorial…). If that is the mechanism, a fresh signed-OUT store
   is born with Welcome listing a guide that does not exist (`SampleLibraryWelcome.
   seededBookNames(guideName:)` names it; the §19 ruling says Welcome HOLDS it). Confirm, and
   also answer the SIGNED-IN road end-to-end (the Monday bed): the books' gate defers seeding
   until a clean first sync and discovery-by-reserved-name then skips what the corpus brought —
   state exactly what the guide's story is on that road (her corpus holds a live field guide).
   State both roads' mechanisms in the B-SEED RECORD before writing the fix.
2. **PROPOSE BEFORE BUILDING (the in-batch fork rule — the implementer proposes, the architect
   rules):** if the fix is anything OTHER than a minimal app-side launch occasion for the guide
   (same shape as the books: the fresh-store-birth fact + the SyncGate + the seeder's own
   `discover` idempotence, silent, honoring a reader's deletion), message the orchestrator with
   the proposal and WAIT. In particular: a tutorial DEDUPE FAMILY would live in
   `Sources/VariorumCore/Sync/` — that is a HARD STOP (report it; Sync/ is Fable work and this
   pass expects none). The Jekyll precedent (18l-c U6: seeded everywhere, judged nowhere — the
   two-fresh-devices-offline residual recorded, not repaired) is the recorded road for leaving
   the guide OUT of the dedupe; name the residual in the record if the fix takes it.
3. **THE FIX + PINS:** pin-before-fix, red-on-old verified by revert. The pin: the fresh-store
   birth road leaves a live field guide present (and on Welcome, per §19) — RED on the old tree.
   Keep the fix MINIMAL: 13s reshapes the whole seed set later (the intake's "way too many
   books" — deliberately sequenced BEHIND this trace); build nothing of that here. The tutorial
   spine (`TutorialWalkTests`) and the Welcome/seeder suites ride green; a changed seeding
   occasion must not retrofit EXISTING stores (the `declined` mark's contract) and must not ask
   anything at first open (R-13r-11: no popup — the seed is silent furniture).
4. **EVIDENCE:** the pins; the affected suites at the unit's end (never the full suite at the
   start); a scripted fresh-DEV-STORE launch walk showing the guide present on Welcome at first
   open (captures under `notes/plans/17y-screens/b-seed/`, gitignored dir pattern); the signed-in
   road's story stated in the record (her Monday install is its live bed).

**FENCES:** zero `Sources/VariorumCore/Sync/` lines (STOP + report instead) · zero schema · zero
custody · zero mobile (the phone's guide is its own seeder's — `MobileTutorialSeeder` untouched)
· no seed-CONTENT edits (13s owns content) · no new settings, no new dependencies.

**REQUIRED READING (never delegated):** this file's 17y row item (q) + this brief + the RUN
RECORD above · `notes/plans/phase-13s-onboarding-intake-2026-10-04.md` · the 13i-d U7 RECORD +
its F-U7-1 continuation in `notes/plans/phase-13i-d-bookcase.md` · QUESTIONS #177 ·
`App/Variorum/Shared/SampleLibrary/SampleLibraryWelcome.swift` + `SampleLibrarySeeder.swift`
(the SyncGate/Outcome grammar) · `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift`
· `App/Variorum/Variorum/Registry/ShellActions.swift` (the door family) · the launch task in
`VariorumApp.swift`. CLAUDE.md and its auto-loaded canon bind as everywhere.

**ENVIRONMENT (binding):** work in the WORKTREE `~/dev/variorum-17y` ONLY (branch `main`; push
`origin main` after every commit) — NEVER touch `~/dev/variorum` (a live session holds it).
DerivedData: `App/Variorum/DerivedData/17y/`. Mac tests from `App/Variorum/` with suite-level
`-only-testing`; confirm the "Test run with N tests" line; NEVER add a build configuration;
instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated BY PATH; the
author's real-store app is NEVER quit or killed; no /Applications refresh in this batch.
`notes/SessionResiliencyProtocol.md` binds: LIVE STATUS (the B-SEED RECORD section you append
below this brief) from the FIRST commit; commit per piece, push after each; synchronous
foreground waits only (poll, never `tail -f | grep`); no subagents. Commits carry NO
Co-Authored-By / Claude-Session trailer. The cold review after your close is FABLE's
(Sync-adjacent subject), spawned by the orchestrator — leave the diff clean and the record
self-contained.

## 17y B-SEED RECORD — item (q), the tutorial-seed trace (`opus-implementer`, 2026-10-05; LIVE STATUS from the first commit)

**NOT DONE (first line, per the contract):** (1) **the SIGNED-OUT fresh-store road was not walked
end to end on this machine** — the dev scope carries a signed-in dev session (sync OFF), so every
fresh dev store takes Road 2; signing it out is a credential act, hers (F-BSEED-4). The guide's own
road WAS walked live (walk B: the `pending` resume of a birth on a fresh dev store — the hook,
`seedAtBirth`, the arrangement shelving it), with the books still gated; the signed-out road's
whole composition is pinned headless through the production function. Her Monday first launch is
the live signed-out bed **only if the build she installs carries this fix** (this batch refreshes
nothing and publishes nothing). (2) **No dark-appearance captures** (both voices walked in light;
the appearance is a local preference and nothing here is appearance-dependent). (3) **The Monday
duplicates (F-BSEED-3) are recorded and owned, not fixed** — the guide's half is the brief's named
residual; the rest predates this batch. (4) Zero `Sync/`, schema, custody, mobile behaviour or seed
content — the fences held (`git diff 7344c11f -- Sources Server App/Variorum/VariorumMobile*` is
EMPTY).

**BATCH STATUS: CLOSED 2026-10-05 (implementer side) — the row FIXED with its pin; Mac 103/12 +
the tutorial spine 98/13 green at the END; the phone build green; red-on-old by two revert rounds;
the walk (A: Road 2 live; B: the guide on Welcome at first open, Terminal + Study) captured. FABLE
cold review next (the orchestrator's).**

Preflight read in this session's own context: CLAUDE.md + its auto-loaded canon; this file's 17y
row item (q), the RUN RECORD and the B-SEED brief; `notes/SessionResiliencyProtocol.md` whole;
`notes/plans/phase-13s-onboarding-intake-2026-10-04.md`; the 13i-d U7 RECORD, its CONTINUATION,
both adjudications after it and the U7 BRIEF (`phase-13i-d-bookcase.md`); QUESTIONS #177/#178 (next
free number **#183**); `notes/SyncSpec.md` whole (the signed-in road's story is a sync story — read,
nothing of `Sync/` touched); `SampleLibraryWelcome.swift`, `SampleLibrarySeeder.swift`,
`SeededBookRestore.swift`, `StarredGatheringSeeder.swift`, `TutorialSeeder.swift` (the doors, the
discovery, the seed's skeleton), `ShellActions.swift` (the door family), the launch task in
`VariorumApp.swift`, `AuthSession.swift` (where a session lives), `AppServices.start()` / the
sign-in road, `SampleLibraryWelcomeTests.swift`. No subagents. Worktree `~/dev/variorum-17y`
only; DerivedData `App/Variorum/DerivedData/17y/`.

### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 1 | This record + THE MECHANISM, both roads, stated before any fix | DONE (this commit) |
| 2 | The launch's furniture made CALLABLE — `LaunchFurniture.seed` (a verbatim move out of `VariorumApp`'s window task; marks + first-round wait injectable, production defaults) — + the pins, the birth pin RED on purpose | DONE (this commit — RED ON PURPOSE) — NEW `App/Variorum/Variorum/LaunchFurniture.swift` (the books → the starred gathering → `arrangeAtLaunch`, byte-for-byte the window task's order and arguments; one gate value where the task built two identical ones; `VariorumApp` now calls it and nothing else); NEW `VariorumTests/LaunchFurnitureTests.swift` (5 pins through the production composition). **THE DRIVEN REPRODUCTION, `scratchpad/17y-bseed/p2-red.log`: `aFreshStoresFirstLaunchPutsTheFieldGuideOnWelcome` RED with exactly the predicted 2 issues** (`facts.guides.count == 1` → 0; `#require(facts.guides.first)` → nil: a fresh store's first launch, signed out, left NO field guide), the four guards green as designed on this side (`anExistingStoreGrowsNoGuideAtLaunch`, `theSignedInRoadMintsNoGuideAheadOfItsCorpus`, `aResumedBirthHonoursHerDeletionAndLeavesResidueAlone`, `aTutorialDoorInFlightIsNeverRacedByTheLaunch` — they fence what the fix must NOT do, so green-on-old is their point, not hollowness) — "Test run with 5 tests in 1 suite failed … with 2 issues" |
| 3 | THE FIX — the guide's birth seed (`TutorialSeeder.seedAtBirth`) on the arrangement's arrange-now road (`arrangeAtLaunch`'s new `beforeArranging`, default nil) | DONE (this commit) — `Shared/SampleLibrary/SampleLibraryWelcome.swift`: `arrangeAtLaunch` gains `beforeArranging: (@MainActor () async -> Void)? = nil`, awaited after the decision and before `arrange` (the header says so; the phone never calls `arrangeAtLaunch`); `Features/Tutorial/TutorialSeeder.swift`: `BirthSeed` + `seedAtBirth(session:)` (the doors' latch → `.doorInFlight`; ONE read — `discover` + `Queries.readingTombstoneExists` — a live guide → `.alreadyPresent`, a tombstone → `.deletedByTheReader`, residue → `.residue`, else the quiet restore road → `.seeded`; errors → `.refused`; one `tutorial`-category log line); `LaunchFurniture.swift` passes it as the hook; `SampleLibraryWelcomeTests`' stale comment ("the guide is seeded when she first opens it") rewritten to point here (comment-only). **GREEN, `p3-green.log`: "Test run with 17 tests in 2 suites passed"** (`LaunchFurnitureTests` 5/5 incl. the birth pin; `SampleLibraryWelcomeTests` 12/12 unmodified in behaviour) |
| 4 | Red-on-old by behavioural revert of piece 3 | DONE (this commit) — the pins sharpened first (`a5a8696c`: the resumed-birth deletion arm SPLIT — the WHOLE guide deleted, so the tombstone alone decides; the book alone, whose tagged lessons are residue — and a sixth pin `theBirthSeedNamesWhatItFound` driving `seedAtBirth`'s decision table branch by branch; 6/6 green, `p3b-green.log`). **ROUND A — RV1, the hook's argument removed from `LaunchFurniture` (`rv-a.log`): exactly the predicted RED — `aFreshStoresFirstLaunchPutsTheFieldGuideOnWelcome` with its 2 issues (no guide), the other 5 green — "6 tests … failed … with 2 issues".** **ROUND B — RV2 the tombstone guard · RV3 the residue guard · RV4 the doors' latch removed from `performBirthSeed`, the wire intact (`rv-b.log`): RED with 8 issues across exactly the three guarded tests** — `aResumedBirthHonoursHerDeletionAndLeavesResidueAlone` 4 (the whole-guide deletion re-made; the book-only deletion re-made; residue REPLACED — a guide minted AND her tagged note destroyed by the replace's cleanup), `aTutorialDoorInFlightIsNeverRacedByTheLaunch` 1 (the launch minted beside a held door), `theBirthSeedNamesWhatItFound` 3 (`.deletedByTheReader` / `.residue` / `.doorInFlight` each answered as a seed or `.alreadyPresent`) — while the birth pin, the no-retrofit pin and the signed-in pin stayed green, as predicted. Both rounds restored clean |
| 5 | Suites at the END (the pins, the seeder/Welcome suites, the tutorial spine; the phone build — `Shared/` gains one defaulted parameter) | DONE — Mac on the fixed tree (HEAD `30a2e6ac`'s code, `DerivedData/17y`, zero Variorum instances): **batch 1 `end-seeders.log` — "Test run with 103 tests in 12 suites passed"** (`LaunchFurnitureTests` · `SampleLibraryWelcomeTests` · `SampleLibraryTests` · `EncryptionExplainedSeedTests` · `LaunchSeedTombstoneTests` · `StarredGatheringSeederTests` · `EncryptionBookDoorTests` · `JekyllTakemaniaSeedTests` · `CalmAsksTests` (the seed is not her writing — the guide included) · `ShellConfirmTests` · `DeadVocabularyTests` · `SampleLibraryDedupeFactsTests`); **batch 2, THE TUTORIAL SPINE, `end-spine.log` — "Test run with 98 tests in 13 suites passed"** (the eleven `TutorialWalkTests.swift` suites `TutorialBookShapeTests` … `TutorialFannedMatrixTests` + `TutorialBooksLessonTests` + `TutorialBooksRitualTests`); no skips in either. **Phone: `VariorumMobile` generic iOS Simulator BUILD SUCCEEDED** (`phone-build.log`, `DerivedData/17y-mobile` — `Shared/`'s one defaulted parameter compiles there; the phone calls nothing of it) |
| 6 | The walk — a FRESH dev store, both voices, into `notes/plans/17y-screens/b-seed/` (gitignored) | DONE (this commit) — **the dev store is BACK in place** (its own store id `4077e8a5…`, key file `…54909c07…json`), the five marks re-written to their originals and read back, the walk's fresh store DELETED, NO Variorum instance running; the debug domain diffed before/after: nothing added or removed, only `IdleCommitSweepMark.Variorum-dev` (a launch timestamp) and `variorum.backup.log` (launch entries, all `upToDate`, no backup file written for the fresh store) changed. **Walk residue removed:** the fresh store's key-file copy `~/Documents/Variorum/variorum-keys-60c37cb981721228.json` (written 01:45 by walk A's first launch, store id `5b69ccb4…`) — that one file only. **Residue that stays:** the fresh store's per-store custody item in the data-protection keychain (unreachable — per-store custody never deletes; not removable without the app). Sequence: walk A at 01:45 (log only; its capture stopped by the guard, then the coordinator's HOLD — the instance quit by identity at once, the dev store swapped back), the hold released ~02:08, her real-store app open and in use 02:09–~02:26 (walk WAITED; never touched), then at an author-free window (her app closed, idle ≥ 120 s, guard before every act): **A1** `A1-road2-fresh-dev-store-terminal-light.png` — the fresh store's first launch on Road 2: the log `awaitingFirstSync` ×3 + the starred gathering, `welcome arrangement: undecided`, NO guide line; the Bookcase "no books yet", every census count 0 · then the Welcome mark staged `pending` on the same fresh store and relaunched — the log: the three books `awaitingFirstSync` (still gated), then **`[tutorial] field guide at a fresh store's birth: seeded(bookID: "C1B1C564-…")` 02:31:50.882 → `welcome arrangement: arranged` 02:31:50.915** (the guide's seed ≈1.4 s on this Debug build), the mark read `done` · **B1** `B1-guide-on-welcome-at-first-open-terminal-light.png` — ALL: Unshelved holds ★ quicknotes (gathering); **Welcome holds "the field guide · 41 notes · 10 ch"**; the census 1 book · 1 gathering; nothing spoken in the status line · **B2** `B2-the-guide-opens-whole-terminal-light.png` — the guide opened: "book · 10 chapters · 41 notes", welcome/writing/takes/structure/deleting/where things go… in plan order · the voice flipped to Study through Settings ▸ General ▸ Design voice (AX; the FRESH store's own setting — nothing of hers changed) · **B3** `B3-the-guide-opens-whole-study-light.png` · **B4** `B4-guide-on-welcome-study-light.png` — Bookcase · Home: Unshelved ★ Quicknotes #quicknote; **Welcome: the field guide #tutorial · 41 notes · 10 ch** |
| 7 | Record close + QUESTIONS #183 (the PROVISIONALs) | DONE (this commit) — the first line, EVIDENCE, FINDINGS, PROVISIONALS; QUESTIONS #183 (a)–(e); KnownIssues row (owner 13s) |

**REVERT STATE: NO REVERT IN FLIGHT** (rounds A and B both ran from committed HEADs and were restored by `git checkout HEAD --`, `git diff --quiet` verified each time).

### THE MECHANISM (traced by reading before any fix; the driven reproduction is piece 2's red pin + piece 6's old-build capture)

**Nothing on the launch path seeds the field guide — the guide has only ever been a DOOR.** The
Mac's launch furniture is the window `.task` in `VariorumApp.swift:185–249`, run after
`AppServices.start()`: (1) `SampleLibrarySeeder.seedIfNeeded` for each of `Book.all` (Sherlock,
*Encryption Explained*, Jekyll) behind the `SyncGate`; (2) `StarredGatheringSeeder.seedIfNeeded`;
(3) when Sherlock's outcome says a FRESH store was born (`.seeded` with every story minted —
`SampleLibraryWelcome.decide`, `SampleLibraryWelcome.swift:356–390`), `arrangeAtLaunch(...,
guideName: TutorialSeeder.bookName)` arranges Welcome. The arrangement's shelving step
(`SampleLibraryWelcome.swift:241–253`) walks `seededBookNames(guideName:)` (`:82–88`) and shelves
every LIVE Home reading of each name — the guide's name is on the list, but no reading of that name
exists, so the step shelves nothing for it and the mark goes `done` (never again on this device).
`TutorialSeeder` is reached ONLY from `ShellActions.openTutorial` (`ShellActions.swift:507–545` —
Help ▸ Open the Tutorial `EditorCommands.swift:835`, the ⌘K row `RootView.swift:1082`) and
`ShellActions.restoreTutorial` (`:352–379` — Help ▸ Restore Tutorial…). History, so the class is
clear: 13b Stage 2 built the tutorial door-only ("SEEDING IS A PRODUCT DOOR", `7c081110`); the
13i-d U7 BRIEF then required that "fresh stores get it at birth" with Welcome holding "the field
guide, Sherlock, Jekyll, Encryption Explained" (`phase-13i-d-bookcase.md:3544–3549`; the sitting
record §19.3 "Welcome = the field guide + the classics trio"), and U7 built the arrangement's
shelving of the guide BY NAME but never a birth seed of the guide — its own fresh-birth pin says so
in a comment ("the guide is seeded when she first opens it", `SampleLibraryWelcomeTests.swift:165–
166`), and that pin composes a REPLICA of the launch (`launchSeeds`, `:69–79`) rather than the
production composition, so no test ever exercised what a real first launch does.

**ROAD 1 — a SIGNED-OUT fresh store** (every new user's first launch; and EVERY fresh install,
because the session is DEVICE-BOUND — `AuthSession.swift:116–130`: the data-protection keychain,
`WhenUnlockedThisDeviceOnly`, "a migrated Mac signs in again"): `start()` finds no persisted
session (`AppServices.swift:271–276`), so the gate's `belongsToAnAccount` (`sync.isConfigured ||
account.variorum != nil`) is false and nothing waits: all three books seed whole, the starred-notes
gathering mints, Sherlock's full mint decides FRESH, Welcome is arranged — Sherlock, Jekyll,
*Encryption Explained*, the classics gathering on it, the quicknote in the Pool — **and no field
guide anywhere**. That is exactly her report ("everything else was just there"; the guide had to
come from Help ▸ Restore Tutorial…).

**ROAD 2 — a SIGNED-IN fresh store** (a store whose launch finds a persisted session for its
variant — e.g. this machine's dev scope, which carries a dev-scoped session with dev sync OFF): the
gate's `belongsToAnAccount` is true, so each book waits up to `firstRoundWait` (20 s,
`SampleLibrarySeeder.swift:816`) for `sync.status.lastSuccessAt`; a store that has not synced
cleanly (a new device not yet enrolled — the engine refuses a round without keys, SyncSpec §3) gets
`.awaitingFirstSync`, NOTHING marked, and Welcome reads `.undecided` (nothing marked) — the next
launch asks again. Once a clean round has landed, the corpus's Sherlock is found
(`.alreadyPresent`, or `.deletedByTheReader` on her tombstone) → Welcome `declined` → no
arrangement. **The guide's story on this road: her corpus's live field guide arrives by sync like
any book; nothing seeds one** (today, and — by design below — after the fix, which keys the guide on
the same fresh-birth decision). The one corner: an account whose corpus holds no Sherlock at all
reads FRESH after its first clean round, and the guide seed's discovery then finds the guide the
round already brought, and seeds nothing.

**HER MONDAY BED RUNS BOTH ROADS, IN THAT ORDER.** A fresh install on the new MacBook is signed
OUT at its first launch (the device-bound session above) — so Road 1 runs first: on today's tree
Welcome has no guide; with the fix the guide is on Welcome at first open. Then she signs in and
enrolls, and ordinary sync MERGES her corpus with the fresh seeds (sign-in is `connectSyncIfAllowed`
— owner adoption + rounds, `AppServices.swift:382–414`; never a replace). By reading (SyncSpec §7 +
`Sync/` grepped for any repair keyed on these objects): Sherlock and *Encryption Explained* FOLD by
the pristine-copy dedupe (both pristine → the smaller id keeps; an edited copy is kept), the Welcome
shelf folds (the R5 keeper), the reserved/`classics`/`tutorial` tags fold (`tag.path`); what stands
TWICE because no keeper exists for it — on TODAY's tree already — is Jekyll (18l-c U6's recorded
residual: seeded everywhere, judged nowhere), the starred-notes gathering, the classics gathering
(the loser's rule then names the folded tag and matches nothing) and "a first quick note"; **and,
with the fix, the field guide joins that class** (THE RESIDUAL below).

### THE FIX'S DESIGN (settled before building — the brief's pre-authorized shape; no fork raised)

- **One occasion, the books' own:** the guide seeds on the Welcome arrangement's ARRANGE-NOW road
  only — a fresh store's birth (Sherlock's full mint under the SyncGate) or the `pending` resume of
  one — through a new defaulted parameter `beforeArranging` on `SampleLibraryWelcome.arrangeAtLaunch`
  (Shared; the phone never calls `arrangeAtLaunch`, so it passes nothing and nothing changes there),
  run after the decision and before `arrange`, so the arrangement's existing shelving step puts the
  guide on Welcome. It therefore inherits every guarantee of that decision: the SyncGate (Road 2
  never reaches it), and **never a retrofit** — an existing store is `declined`/`done` and the hook
  is never called (stores born on U7–13r builds without a guide keep the doors as their road).
- **The seed itself (`TutorialSeeder.seedAtBirth`, Mac):** silent (no receipt, no navigation, no ask
  — R-13r-11; one log line), on the quiet facade (the restore road's `Operations(undoStack: nil)`),
  under the tutorial doors' latch (a door in flight → the birth seed yields; it seeds and arranges
  itself), deciding from ONE read: a live guide present → nothing; a tombstoned reading of the
  guide's name → her deletion, honoured; any tutorial RESIDUE (tagged lessons, the scraps pool, no
  book) → nothing (replacing residue is the doors' confirmed road, never silent furniture's); else
  the pristine seed (the restore road over an empty discovery — no cleanup, the one shape).
- **No new mark, no setting:** the Welcome mark (`pending` → `done`) already records that this
  device handled the birth; a later deletion of the guide is final on this device (the launch reads
  `alreadySettled`).
- **The pin drives the PRODUCTION composition:** the launch's furniture moves verbatim into
  `LaunchFurniture.seed` (Mac) so `VariorumApp` and the pins call the same function.
- Zero `Sources/VariorumCore/Sync/`, zero schema, zero custody, zero mobile behaviour, zero seed
  content.

### THE RESIDUAL (named, the brief's Jekyll precedent — PROVISIONAL P-17y-BSEED-3)

The field guide stays OUT of the sync dedupe (a tutorial dedupe family would be `Sync/` — the hard
stop). So **a fresh signed-OUT store that later signs into an account already holding a field guide
shows TWO field guides** — both live, nothing lost, either deletable (Help ▸ Restore Tutorial…
re-makes one any time). This is the Monday bed's exact sequence, and it is the same class Jekyll,
the starred-notes gathering, the classics gathering and the seeded quicknote already stand in on
today's tree.

### EVIDENCE (all run at the END unless named; logs in the gitignored `scratchpad/17y-bseed/`)

- **The driven reproduction (piece 2, `p2-red.log`):** on the refactored, unfixed tree the birth pin
  `aFreshStoresFirstLaunchPutsTheFieldGuideOnWelcome` RED with exactly 2 issues (no guide minted;
  `#require(facts.guides.first)` nil) — "5 tests in 1 suite failed … with 2 issues".
- **Red-on-old by revert (piece 4):** round A (`rv-a.log`, the hook's argument removed) → the birth pin
  RED, 2 issues, the other 5 green; round B (`rv-b.log`, the tombstone + residue + latch guards removed,
  the wire intact) → 8 issues across exactly the three guarded pins (her tagged note DESTROYED by a
  silent replace among them), the birth / no-retrofit / signed-in pins green. Both restored by
  `git checkout HEAD --`, `git diff --quiet` verified.
- **`LaunchFurnitureTests` — 6/6 green** (`p3b-green.log`; in the END batch too).
- **Mac at the END** (`DerivedData/17y`, zero instances): **"Test run with 103 tests in 12 suites
  passed"** (`end-seeders.log`) and **the tutorial spine "Test run with 98 tests in 13 suites passed"**
  (`end-spine.log`); no skips. `SampleLibraryWelcomeTests` 12/12 unmodified in behaviour (one comment).
- **Phone:** `VariorumMobile` generic iOS Simulator **BUILD SUCCEEDED** (`phone-build.log`).
- **The walk:** LIVE STATUS row 6 — A1 (Road 2 live) and B1–B4 (the guide on Welcome at first open,
  whole, silent, both voices), with the unified-log lines that name each outcome.
- **Fences:** `git diff 7344c11f -- Sources Server App/Variorum/VariorumMobile App/Variorum/VariorumMobileTests`
  EMPTY (zero `Sync/`, schema, custody, mobile); no seed-content edit; no new setting, mark or
  dependency; no `/Applications` refresh; her real-store app never touched (it ran 02:09–~02:26 and
  the walk waited).

### FINDINGS

- **F-BSEED-1 — FIXED (the row): a fresh store was born without its field guide.** Mechanism above;
  pinned red-on-old (piece 2's driven reproduction, piece 4's round A); fixed (piece 3).
- **F-BSEED-2 — the U7 fresh-birth pin composed a REPLICA of the launch** (`launchSeeds` in
  `SampleLibraryWelcomeTests`), which is how the gap stayed invisible; its comment described the
  defect as design ("the guide is seeded when she first opens it"). FIXED structurally: the launch's
  furniture is ONE function (`LaunchFurniture.seed`) that `VariorumApp` and `LaunchFurnitureTests`
  both call; the stale comment rewritten (comment-only).
- **F-BSEED-3 — RECORDED + OWNED (KnownIssues, owner 13s; QUESTIONS #183(c)): her Monday bed will
  show the unjudged seeded objects TWICE after sign-in** — Jekyll, the starred-notes gathering,
  Quicknotes, the classics gathering (one of the two then matches nothing), "a first quick note" on
  TODAY's tree already, and the field guide now too (THE RESIDUAL above). Traced by reading (SyncSpec
  §7; `Sync/` grepped — no keeper keys on any of them), not run two-client. The orchestrator may want
  to tell her before Monday: nothing is lost, delete the extras.
- **F-BSEED-4 — the signed-OUT fresh-store road cannot be WALKED on this machine without the
  author.** The dev scope holds a signed-in dev session with dev sync OFF, so every fresh dev store
  takes Road 2 (walk A proved it live). Signing that session out is a credential act — hers. Walk B
  therefore stages the `pending` resume of a birth (the guide's real road, books gated); the live
  signed-out bed is her Monday first launch — **which carries this fix only if the build she installs
  carries it** (this batch refreshes nothing and publishes nothing; release runs are hers to approve).
- **F-BSEED-5 — walk-harness fact (for WalkKit):** in the zsh tool shell, `log` is zsh's builtin
  (`log: too many arguments`, or silently nothing) — the unified log is `/usr/bin/log show`.
- **Cost note (no finding):** the birth seed is the restore road's one runner turn (~45 notes),
  awaited after the three books on the furniture path — first paint long done, nothing awaits it;
  the same cost every Restore Tutorial press already pays.


### PROVISIONALS (QUESTIONS #183 carries them, in her words)

- **P-17y-BSEED-1 — the occasion:** the arrangement's arrange-now road only (a birth under the sync
  gate, or its `pending` resume); never an existing store — including stores born on U7–13r builds
  without a guide (their road stays the doors). (a) BUILT · (b) a one-time add-if-missing pass on
  existing stores (breaks the no-retrofit contract) · (c) key the guide on "the account holds no guide"
  after a first clean round instead of on the birth.
- **P-17y-BSEED-2 — any tutorial trace means do nothing:** a live guide, a tombstoned one (her
  deletion), or residue (tagged lessons / the scraps pool, no book) — the residue's replace is the
  doors' CONFIRMED road. (a) BUILT · (b) replace residue silently (could tombstone her own
  `tutorial`-tagged note — round B's red shows it would) · (c) seed beside residue (MINOR-D5's
  doubled-pool class).
- **P-17y-BSEED-3 — out of the sync dedupe** (the brief's Jekyll precedent) → THE RESIDUAL. (a) BUILT ·
  (b) a tutorial keeper in `Sync/` (Fable work; its own entry) · (c) the 13s seed-set reshape.
- **P-17y-BSEED-4 — the latch:** a door in flight → the birth seed yields; a door pressed during the
  birth seed is a silent no-op (the doors' existing double-press rule). (a) BUILT · (b) the door waits
  for the birth seed and then opens the guide.
- **P-17y-BSEED-5 — silent:** no receipt, no navigation, one `tutorial`-category log line. (a) BUILT ·
  (b) a quiet receipt naming the guide.

## 17y B2 BRIEF — the drag mechanics + three singles: items (a)(b)(e)(m)(n)(p) (written by the orchestrator 2026-10-05; ONE acceptance unit)

**THE ITEMS (the binding text is this file's 17y row — read each item's cell end to end; this
brief adds the machinery map and the fences, never a substitute for the row):**

1. **(a) Unshelved → shelf drag is dead.** Her walk: dragging a book from the Bookcase's
   UNSHELVED group onto a shelf does not work; the U1 contract promised "drop targets + drag
   reorder + Move to Start/End". Machinery (13i-d U1 RECORD): `Features/Shelf/BookcaseStrip.swift`
   (`BookcaseDragToken` + the `bookcaseDropSite` modifier on the strip's shelf chips),
   `ShelfView.swift` (the section labels are drop targets), `Operations+Shelf.swift`
   (`setReadingShelf`, `placeReading`), `Domain/BookcaseOrdering.placementWrites`. Her walk-note:
   few shelves existed, so the strip's targets were sparse — THE TRACE DECIDES built-and-broken
   vs never-built, and the fix follows the mechanism. Walk the real gesture afterwards (a dev-store
   capture of a book dragged from Unshelved onto a shelf chip AND onto a section label).
2. **(b) My-order reorder is absent beyond Send to Top/Bottom.** P-13id-U1-13 promised "a book
   dropped on a row lands right above it"; her ask adds the AFFORDANCE — drag bars (or an
   equivalent) visible when `order ▾ = my order` is active. Trace whether the row-drop road was
   built; build the affordance; the drop lands exactly where aimed (the U1 arithmetic's own
   promise, `placementWrites`).
3. **(e) The Book Panel's drag handles render but drag does nothing.** Her capture: the Jekyll
   seeded book, four rows, handles drawn, no drag. Machinery (13i-d U2 RECORD):
   `Features/BookView/BookPanelView.swift` + `BookPanelModel.swift` (`BookPanelDragToken`, a
   PRIVATE Transferable; `BookPanelBrain.dropPlan` → `BookStructureModel.postDropPlan` /
   `chapterDropTarget` → `assignPostToSection` / `reorderReadingPost` / `reorderSection`). The
   row names the two trace candidates: does `sort_field ≠ manual` gate it (the seeded Jekyll
   book's sort?), and is a finished-book refusal staying SILENT against U2-8's "moves refuse
   WITH the road"? Her stance binds either way: **a handle that cannot drag must not render** —
   so the fix is drag-works where legal, and where the order is not manual (or the book is
   frozen) either the handle goes or the gesture refuses with the road, per the traced mechanism
   and U2-8's contract.
4. **(m) The quick-note box blinks TWO cursors.** Her rule verbatim: "if the terminal cursor is
   blinking open at the end, your cursor shouldn't be blinking as well" — exactly ONE cursor
   blinks at a time, the Terminal voice's decorative block cursor winning while it is shown. The
   trace decides the suppression's mechanism and owner (the quick-capture surface; find where the
   decorative cursor is drawn and where the field's insertion point blinks).
5. **(n) The title's chrome shift, STILL.** Her capture is
   `notes/plans/17y-screens/title-chrome-shift.png`; her words "the chrome is still shifted up
   when you click on the title". Her "still" marks a survivor or regression of an earlier
   landing: **FIND THE PRIOR FIX FIRST** (search the plans/commits for the title-focus chrome
   work — 13u2's title item and the masthead family are the first places to look), then pin
   red-on-old against the MECHANISM, never the symptom.
6. **(p) Canvas goes DEBUG-only.** Ruled at the evening sitting ("let's just do that now…",
   debug-only ratified): Canvas leaves the note mode row in RELEASE builds (Debug keeps it — her
   tinkering surface); the ⌘1–⌘7 derivation shortens to the remaining modes (her explicit ok on
   ⌘7 no longer being Canvas); ENUMERATE Canvas's other doors (the ⌘K palette, any settings face,
   the registry's declarations) and gate them the same way. The gate is a compile-time/runtime
   DEBUG condition in the ONE place the mode order is derived — never per-view ifs (P-1).

**RULES (the standing ones, applied):** pin before fix, red-on-old verified by revert, PER ITEM;
no fix without a self-traced mechanism; a pin green on both sides is a hollow finding — record
it, don't fix it. A trace that finds a SILENT refusal fixes it to refuse WITH the road (the
registry's refusal copy), per P-2. Items are independent — commit per item, push after each, so
a death loses at most one. Tests at each item's end (its suites + any registry walk the diff
touches); the tutorial spine (`TutorialWalkTests`) once at the batch's end.

**FENCES:** zero `Sources/VariorumCore/Sync/` · zero schema · zero custody · zero mobile code
(the phone's Canvas/panel are its own; if an item's rule SHOULD reach the phone, record it as a
MOBILE PARITY note in your record, build nothing there) · no seed-content edits · no new
dependencies · (p) touches Release behavior — NO /Applications refresh in this batch (the
pass-end window owns it).

**REQUIRED READING:** this file's 17y row items (a)(b)(e)(m)(n)(p) end to end + the RUN RECORD +
this brief · `notes/plans/phase-13i-d-bookcase.md` — the U1 RECORD and U2 RECORD whole (the
machinery maps + P-13id-U1-13, U2-8) · QUESTIONS #170/#171 (the standing PROVISIONALs those
surfaces carry — do not overturn any) · her capture `notes/plans/17y-screens/title-chrome-shift.png`
· CLAUDE.md + its auto-loaded canon.

**ENVIRONMENT (binding, same as B-SEED's):** work ONLY in the worktree `~/dev/variorum-17y`
(branch `main`, push `origin main` after every commit); NEVER touch `~/dev/variorum` (a live
session holds it). DerivedData `App/Variorum/DerivedData/17y/`. Mac tests from `App/Variorum/`,
suite-level `-only-testing`, confirm the "Test run with N tests" line; never add a build
configuration (a non-"Debug" configuration strips the DEBUG oracles — and (p)'s Release gate is
tested by a compile-condition pin or a runtime seam, NEVER by adding a Release test
configuration). Instance checks by PATH; her real-store app is never touched. The resiliency
protocol binds: LIVE STATUS (append a "17y B2 RECORD" section after this brief) from the first
commit; synchronous foreground waits only; no subagents; no attribution trailers. The cold
review after your close is the orchestrator's to cast (no editor seam, no Sync/, no custody
expected in this diff ⇒ `opus-reviewer`; if your trace reaches the editor seam — (n) might —
SAY SO in your record so the review re-casts to Fable).

**WALK EVIDENCE:** dev-store Debug captures per item under `notes/plans/17y-screens/b2/`
(gitignored): the unshelved→shelf drag landing; a my-order row drop landing right above the row
+ the affordance visible; the Book Panel drag landing (and the refusal road where gated); ONE
cursor in the quick-note box (Terminal voice); the title click with the chrome still; the mode
row without Canvas (a Release-conditioned evidence road per the pin's seam — a Debug capture
shows Canvas kept).

## 17y B2 RECORD — the drag mechanics + three singles, items (a)(b)(e)(m)(n)(p) (`opus-implementer`, 2026-10-05; LIVE STATUS from the first commit)

**NOT DONE (first line, per the contract):** (1) **No human hand on the drags** — (a), (b) and (e) were
walked with SYNTHETIC drags (`cliclick`), which now commit (the pre-fix build's identical drags did not);
her own spot-check (planned for Monday) is the human confirmation. (2) **The RELEASE side of (p) is
pinned, compiled and symbol-checked, never walked** — a Release build carries the real-store bundle id
and is never launched by a session. (3) **The field guide still teaches Canvas** in its prose (lesson
"blocks · canvas", the mode-row sentence) — seed CONTENT, fenced to 13s (F-B2-6). (4) **The book view's
OWN same-chapter drop under a stamp order is still silent** (the sibling surface of (e)'s gate — F-B2-7,
not this batch's surface). (5) No dark-appearance captures (light only, both voices where the surface
has a face; (m) is Terminal-only by design — Study draws no block cursor). (6) No `/Applications` refresh
(the pass-end window owns it). (7) Dev-store residue: my-order hand positions written by the walk's row
drops (`shelf_position` keys on unshelved books) — invisible outside my order; everything else restored
(shelves, Jekyll's chapter order, the voice, the order, details). Zero `Sync/`, schema, custody, mobile
code or seed content (`git diff 8ff566e1 -- Sources Server App/Variorum/VariorumMobile` EMPTY).

Preflight read in this session's own context: CLAUDE.md + its auto-loaded canon; this file's 17y
row items (a)(b)(e)(m)(n)(p) end to end, the RUN RECORD and the B2 BRIEF; `notes/plans/17y-sitting-
rulings-2026-10-05.md` (none of the six items is changed by it); `notes/SessionResiliencyProtocol.md`
whole; the 13i-d U1 RECORD + its adjudication and the U2 RECORD + its adjudication
(`phase-13i-d-bookcase.md`); QUESTIONS #170/#171 (next free number **#184**); her capture
`17y-screens/title-chrome-shift.png`; `Tools/WalkKit/README.md` + the guard/click/keys scripts.
Worktree `~/dev/variorum-17y` only; DerivedData `App/Variorum/DerivedData/17y/`; no subagents.

### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 1 | This record + the b2 captures dir gitignored | DONE (dfd15204) |
| 2 | (a)(b)(e) THE SHARED DRAG MECHANISM — trace, driven reproduction on the pre-fix build, pin red-on-old, fix, revert-verify | DONE (5a9fcbd1 red · 34bbdefe fix) — the fix: `App/Variorum/VariorumInfo.plist` gains `UTExportedTypeDeclarations` for the three identifiers, each conforming to `public.data`. Pin RED on the pre-fix tree (5a9fcbd1, 10 issues) → **GREEN "Test run with 3 tests in 1 suite passed"** (`p2-green.log`); the fixed instance's log carries ZERO declaration faults (473 lines, pid-filtered); **the same synthetic drag now LANDS** — the hairline lights on "research" mid-drag and "field notes" moves with the receipt *Moved “field notes” to research.*; a second drag lands "u4 third" on the "correspondence" SECTION LABEL (*Moved “u4 third” to correspondence.*) — (a)'s two drop sites walked (`b2/new/a3`, `a2`, `a5`). Red-on-old is the PRE-FIX TREE itself (pin + drag), not a synthetic revert |
| 3 | (b) the my-order AFFORDANCE (her drag-bars ask) | DONE (034c28ad · e51857ed; walked — row 9): `BookcaseBoard.placesByHand` (Shared — the ONE value the row drop, the new ⠿ grip and Send to Top/Bottom read) + the grip in the row's leading gutter in my order only (`ShelfView.shelfRow`; `BookcaseCopy.gripGlyph/gripHelp`); pin `BookcasePlacingGripTests` (2) green with the Bookcase suites — **"19 tests in 5 suites passed"** (`p3-green.log`); **behavioural revert (the gate `true` for every order) → RED "2 tests … failed … with 2 issues"** (`p3-rv.log`), restored by checkout, `git diff --quiet`. The walk (grip visible + a row drop landing right above) rides piece 9 — HELD at 03:2x: the guard read HID idle 0 s (someone at the machine) |
| 3b | (b) the grip moved INSIDE the row (F-B2-5's first, partial answer) | DONE (0dd108e1) — kept: a grip drawn inside its row is the sounder face, though NOT the freeze's cure (3c) — `ShelfView.shelfRow`: an `HStack` of a fixed grip column (`BookcaseCopy.gripColumn` 16 pt, the glyph drawn by OPACITY from `placing`, help only while placing) + the row's `Button`; the composite pulled `-gripColumn` into the 28-pt gutter (names unmoved between orders); `.draggable`/the note `.onDrop`/`.contextMenu` now on the composite (the grip drags too); the hairline stays on the button. `BookcasePlacingGripTests` gains the column-fits-the-gutter assertion. **"47 tests in 6 suites passed"** (`p3b-green.log`: the grip pins, Bookcase VM + brain, the Move to Shelf gate, the drag-type pins, the registry walk). The re-walk of the exposing sequence is piece 9's |
| 3c | (b) F-B2-5 — the PRE-EXISTING row freeze (the walk's catch, the real mechanism) | DONE (883eaeb4 fix · 31dce99a hollow-round record · bc49e069 the real pin; walked — row 9): the fix is the SECTION-qualified row identity. The pin `BookcaseRowFreezeTests` was HOLLOW as first written (its revert round green, `p3c-rv.log`). The oracle `BookcaseRowOracle` now also records each row's FRAME (`onGeometryChange(.global)` — what a row reports of itself); with it, **the identity line's revert is RED 3 of 3** (the committed test, bc49e069's: "2 tests in 1 suite failed … with 2 issues" at `BookcaseRowFreezeTests.swift:119`/`:128` — the moved row's record stuck at `placing == true` after A–Z and `details == true` after details off; the unmoved control live. *Citation corrected at the fix round (the ladder's MINOR-1): the "4 issues" first cited here, from `p3c-diag.log`/`p3c-diag-rv1/2.log`, came from a DIAGNOSTIC version of the test — two of its issue lines were DIAG prints past the committed file's end; the committed test was re-measured at 2 issues by the fix round, and the reviewer re-ran it red 3/3)* **and the fixed tree GREEN 3 of 3** (`p3c-green1/2/3.log`). Why the frame record makes the old freeze reproducible in-process is NOT explained (recorded, not claimed); the walk's before/after (`f1` frozen · `f2`–`f4` live) is the use-shaped half. A scratch pixel scan was tried on the way and removed (frames alone were too coarse) |
| 4 | (e) the Book Panel's handle rule + any silent drop gate → refusal WITH the road | DONE (2e07a4d4 red · 78f4c824 fix · 6bb6c70e revert round; walked — row 9): `BookPanelBrain.dropOutcome` (`.plan` · `.nothing` · `.needsManualOrder`, over the unchanged `dropPlan`); `BookPanelModel.drop` speaks `BookPanelCopy.needsManualOrder` — *“X” is sorted by Entry date ↓, so a note can’t be placed by hand — set the book’s order ▾ to Manual order and save it.* (PROVISIONAL words); `chapterGripDrawn` = more than one chapter. Pins RED on the pre-fix behaviour (4 issues) → GREEN "48 tests in 5 suites" (`p4-green.log`) → **behavioural revert (the gate off, the grip always) RED "5 tests … with 4 issues"** (`p4-rv.log`) on the corrected fixture, restored, `git diff --quiet`. The walk (a panel drag landing; the refusal road) rides piece 9 |
| 5 | (m) the quick-note box's double cursor | DONE (2c60f3be red · 95f615eb fix · 188b2ce4 revert round; walked — row 9): `CaptureNSTextView.onCaretChange` from `becomeFirstResponder`/`resignFirstResponder`, wired to the host's `onFocusChange` (the Coordinator's begin/end-EDITING reports retired); `QuickEntryBar`'s gate untouched. Pin RED on the pre-fix tree (1 issue — the arrival) → GREEN (17/4 + 21/5) → **behavioural revert (the wire removed) RED "1 test … with 2 issues"** (`p5-rv.log`), restored, `git diff --quiet`. The walk (ONE cursor, Terminal) rides piece 9. **Seam note for the review cast:** the diff touches `CaptureNSTextView` — a TK2 `NSTextView`, but OUTSIDE the editor seam by its own header (no identity attributes, no `BlockRangeIndex`, no `PaneTextAuthority`, no router claim); only first-responder overrides, no TK1 API |
| 6 | (n) the title's chrome shift — the PRIOR landing first | DONE (c4dd3231 red · 7b77fdf8 fix; walked — row 9): the open rename field carries NO prompt of its own (`TextField("", …)` + an accessibility label of the shown words); while the draft is empty the date is drawn by a SwiftUI `Text` with the resting face's own font/frame/alignment (in `tokens.faint`, the voice's placeholder ink) BEHIND the field — the row-10 pointer's API-free shape. Pin RED on the pre-fix code (3 issues) → **GREEN "37 tests in 4 suites passed"** (`p6-green.log`: `MastheadLayoutTests` whole incl. the new pin and the prior row-12 pin, `OneTimeCodeAutoFillTests`, `DebugOracleOwnershipTests`, `MastheadTagDoorTests`). Red-on-old is the pre-fix code itself (the pin ran red before a line of the fix existed). The walk (Study + Terminal: click a date-named note's title, the words still) rides piece 9 |
| 7 | (p) Canvas DEBUG-only — the gate in the ONE mode-order derivation | DONE (c430c0aa red · 09f5e985 fix; the Release compile — row 8; the Debug capture — row 9): `PostMode.buildKeepsCanvas` (the compile condition, read by nothing but the seam) · `order(keepingCanvas:)` · **`allCases` RETURNS the build's order** (so the mode row, ⌘1–⌘n, the rail and the masthead menu shorten in Release with no renderer touched) · `fromStored` decodes a mode the build lacks to nil (→ the caller's default, Write — PROVISIONAL) · `keyLabel`/`keySpan`/`modeList` feed the registry's `.switchMode` verb + label, the helper's row and the masthead menu's help · the helper's "canvas" dictionary entry filtered by the seam · `PoolDetailView.Mode.allCases` = `faces(keepingCanvas:)` and its picker drawn only with more than one face. Red-on-old: the seam in its pre-fix shape (Canvas kept whatever the flag) → "5 tests … with 6 issues" (`p7-red.log`); **GREEN with the mode/registry/canvas suites — "61 tests in 8 suites passed"** (`p7-green.log`: CanvasDebugOnly, NewModes (Debug's seven, unedited), the registry walk, OpenStripMenu, SidebarLayout, PostDetail mode memory, Canvas & full pool, CanvasArrival) |
| 8 | Suites at the END + the tutorial spine | DONE (Mac, HEAD bc49e069's code, `DerivedData/17y`, zero Variorum instances): **batch 1 `end-b2.log` — "Test run with 335 tests in 62 suites passed"** (7 skipped, all `DebugOracleSingletonWindowTests` — its standing opt-in env gate): the drag-type pins · the Bookcase family (grip, row freeze, VM, brain, Move to Shelf gate, ShelfModel, BindDoor + MembershipChoice — the two `ShelfView` mounts) · the Book Panel family (gates, brain, declarations, acts) · the capture family (focus report, keys, surface, hand-off, the bar, the four quick-note suites) · the masthead/title family (`MastheadLayoutTests` whole, one-time-code, oracle ownership + singleton windows, the tag door) · the mode/canvas family (CanvasDebugOnly, NewModes, OpenStripMenu, SidebarLayout, ShellChrome, PostDetail mode memory + routing, Canvas & pool, CanvasArrival, CanvasDragTracking, the three CanvasBank suites, StarredScroll ×2) · **the registry walk** (`CapabilityRegistryTests`) · every suite that reads the helper's rows (MarkdownActs, ContextBarDoors/TagChipFit/ForwardDestination, the five WalkBuildRound suites, the seven Savepoint* suites, the three SystemHotKey suites); **batch 2 THE TUTORIAL SPINE `end-spine.log` — "Test run with 98 tests in 13 suites passed"**, no skips. **The phone: `VariorumMobile` generic iOS Simulator BUILD SUCCEEDED** (`phone-build.log`, `DerivedData/17y-mobile` — `Shared/BookcaseBoard.swift` gained `placesByHand`; the phone calls nothing of it). **The Release COMPILE: BUILD SUCCEEDED** (`release-build.log`, the existing Release configuration — nothing added — into a scratch `DerivedData/17y-release`, NEVER launched (its bundle is the real-store `io.lduarte.Variorum`), then deleted): (p)'s `#else` side compiles; `nm` finds 0 `BookcaseRowOracle` symbols in the Release binary vs 63 in Debug's (the DEBUG fence holds); the Release plist carries the three type declarations |
| 9 | The walk → `notes/plans/17y-screens/b2/` (gitignored) | DONE — author-free windows 03:00–04:50, guards green per act, her real-store app never running. **(a)** `old/a1`,`a2`,`a3` (pre-fix: the session runs, nothing lights, nothing lands) · `new/a3` (fixed: the hairline on "research"), `new/a2` (*Moved “field notes” to research.*), `new/a5` (a section label: *Moved “u4 third” to correspondence.*). **(b)** `b1` (my order — every row's ⠿) · `b2` (a drag started FROM the grip; the hairline) · `b3-after-drop` (landed right above) · `b4`/`b5` (moved rows carry grips) · `f1` (THE PRE-EXISTING FREEZE: details off, the two moved rows keep their meta) · `f2`–`f4` (fixed: a moved row follows details, carries its grip in my order, none anywhere in A–Z) · `b9` (the FINAL build: a grip drop lands) · `b10` (Study: the grips). **(e)** `e1` (her capture's state: Jekyll's four chapter grips) · `e2`/`e3` (a chapter dragged by its grip lands right above "story of the door") · `e4`/`e5` (the Journal, entry-date order: a same-chapter re-place refuses — *“Journal” is sorted by Entry date ↓, so a note can’t be placed by hand — set the book’s order ▾ to Manual order and save it.*) · `e6` (Study: the panel). The chapter order restored through the panel's own Move Chapter Down twin (walked, ×2). **(m)** `m1-focused-frame1…4` (the Bookcase box holds the caret — AX: the text area — caret only), `m2-unfocused-frame1…4` (the Library's box, focus on the window — the block cursor only), `m3-clicked-in-frame1…4` (clicked in — caret only). **(n)** `n1`/`n2` (Terminal, a date-named note: resting / open — the date stays on its line) · `n3`/`n4` (Study — her capture's voice: no shift, no clip). **(p)** `p1-debug-rail-keeps-canvas` (Debug keeps Canvas — the rail's seven). The walk's harness facts: F-B2-4 |
| 10 | Record close (first line, findings, PROVISIONALs → QUESTIONS #184) | DONE (this commit) |

**REVERT STATE: NO REVERT IN FLIGHT** (every round — (b), (e), (m), F-B2-5's hollow round and its later 3-of-3 rounds — ran from committed HEADs and was restored, `git diff --quiet`).

### THE TRACE — (a)(b)(e), the shared drag mechanism (CONFIRMED by the driven reproduction below)

The lead, from reading (no fix yet): every drag in (a), (b) and (e) rides a `Transferable` token
whose `CodableRepresentation` names a CUSTOM exported type — `BookcaseDragToken`
(`io.lduarte.variorum.bookcase-item`, `BookcaseStrip.swift:75`) for (a)/(b), `BookPanelDragToken`
(`io.lduarte.variorum.book-panel-item`, `BookPanelModel.swift:137`) for (e) — and **neither type
(nor the Open strip's `io.lduarte.variorum.open-note-row`, `SidebarView.swift:669`, the "proven
road" both were modelled on) is declared in the app's Info.plist** (`App/Variorum/VariorumInfo.plist`
carries no `UTExportedTypeDeclarations`; the generated plist adds none). Measured from a scratch
script: `UTType(exportedAs:)` on an undeclared identifier yields a type with NO supertypes that does
NOT conform to `public.data` (the system-declared plain text does). The records' own evidence
discriminates: 13b N20's String drag (a declared system type) LIT its drop indicator under synthetic
drags and committed by her hand; 13i-d U1's custom-type drag started a session but NO target ever
lit (F-U1-4), and the Open strip's custom-type reorder was never human-verified (pre-13u Act 10).
F-U1-4/F-U2-4 recorded the failure as a synthetic-harness artifact; her real hand failing on (a)
and (e) says it was not.

**THE DRIVEN REPRODUCTION (pre-fix Debug build of HEAD dfd15204, `DerivedData/17y`, dev store,
author-free, guards green per act; captures `17y-screens/b2/old/`):** (1) the launch's unified log
(`/usr/bin/log show`) carries the system's own FAULT, repeated, from `UniformTypeIdentifiers`
[`com.apple.runtime-issues:Type Declaration Issues`]: *Type "io.lduarte.variorum.bookcase-item" was
expected to be declared and exported in the Info.plist of Variorum.app, but it was not found.*
(2) A `cliclick` drag (`dd` · stepped `dm` · `du`) of "field notes" from UNSHELVED onto the strip's
"research": the full-screen mid-drag capture `a3-middrag-fullscreen.png` shows the drag SESSION
running (the row's "field notes" image rides the pointer onto "research") with NO hairline on the
name (`a1-middrag-over-research.png`); after `du` the book is still unshelved and nothing spoke
(`a2-after-drop.png`). That is F-U1-4's shape exactly — on a build whose own log names the cause.
(3) The pin, RED on this tree with 10 issues across its 3 tests (the three tokens' types undeclared;
none conforms to `public.data` at runtime; the source scan finds three undeclared identifiers).

**THE MECHANISM, CONFIRMED (both sides driven):** an exported `UTType` the bundle does not declare is
not a data type, so the drag's payload is never offered to a drop destination as the
`Transferable`'s content type — the session starts and no `dropDestination(for:)` ever targets.
**Built-and-broken, all three surfaces** — the drop handlers were built and pinned (13i-d U1/U2) and
the types were simply never declared. Declaring them (no code change) brings back: (a) every Bookcase
drop site (strip names, the ⋯ panel's rows, All's section labels), (b) the my-order ROW drop
(`ShelfView.swift` — `bookcaseDropSite(enabled: placing)`, `dropBook(_:before:)`), (e) every Book
Panel drop (`PanelDropSite`), plus the strip's shelf-name reorder and the sidebar Open strip's row
reorder (the same class; declared in the same commit — the pin's source scan names all three).
F-U1-4 and F-U2-4's "synthetic drags never commit a SwiftUI drop here" was this defect, not the
harness: on the fixed build the same `cliclick` drag commits.

**DEV-STORE ACTS TO RESTORE AT THE WALK'S END:** "field notes" (was Unshelved → research) and
"u4 third" (was Unshelved → correspondence) — both back to Unshelved via Move to Shelf ▸ Unshelved.

### THE TRACE — (e), after the shared mechanism

Her capture's book (the seeded *Jekyll*): created with the default `sortField: .manual`
(`Operations+Reading.swift:13`), never finished, four chapters — so NEITHER of the row's two gate
candidates applies to it: every panel drop died on the undeclared type (piece 2). With that fixed,
the panel's roads, each traced to its op:
- **Chapter rows (the only rows that draw a grip, ⠿ — `BookPanelView.chapterRow`):** chapter order
  is the book's own regardless of `sort_field`; a drop resolves through `chapterDropTarget` →
  `reorderSection`. On a FINISHED/SEALED book the op throws `lockedReading` and `BookPanelModel.run`
  speaks `BookStateCopy.refusal` — *"“X” is finished — reopen it first."* (sealed: "unseal it
  first") — **refuses WITH the road; U2-8 holds, nothing silent** (pinned since U2,
  `aFinishedBookRefusesInWordsAndNothingMoves`). **But a LONE chapter's grip can never act**: every
  drop of it resolves to nil (`dropPlan` — onto itself, onto "unfiled" when already last, onto an
  unfiled note → the end when already last) — her stance: a handle that cannot drag must not render.
- **Note rows (no grip; the row drags):** a note onto ANOTHER chapter's row/heading files it there
  in any order (the book view's ruling — "the chapter half of the drop always happens"). **The
  silent gate — `sort_field ≠ manual`:** a note dropped to RE-PLACE it inside its OWN chapter (onto
  a sibling, or onto its own chapter's heading) resolves through `BookStructureModel.postDropPlan(…,
  reposition: false)` to `.file(post, itsOwnChapter, before: nil)` — `assignPostToSection` to the
  chapter it is already in: a write that changes nothing, under a hairline whose own comment says "a
  dropped row lands right above this one", and nothing speaks. That is the brief's P-2 class (a
  silent refusal) → it must refuse WITH the road: the book's order control is the book view
  navigator's "order · … ▾" → Manual order → Save as This Book's Order (`BookView.orderControl`).

### THE TRACE — (p), Canvas's doors (enumerated before the gate)

**The order is derived in ONE place: `PostMode.allCases`** (`Registry/PostMode.swift` — its own doc:
"The ⌘1–⌘7 keys derive from THIS order (EditorCommands' ForEach), as do the sidebar rail and the
masthead menu — one order, three renderers"). Its readers: the masthead mode menu
(`PostDetailView.swift:311`), ⌘1–⌘n (`EditorCommands.swift:766`), the sidebar rail and its counts
(`SidebarView.swift:230/236/593/614/623/631`). Gating `allCases` itself gates all of them with no
renderer touched. **Canvas's OTHER doors, every one:** (1) the per-note mode MEMORY's decode
(`PostMode.fromStored` ← `PostDetailView.rememberedMode`, also the pane line's `heldMode`) — a note
she left in Canvas on a Release build would reopen in a mode the build no longer renders; (2) the
hand-written ⌘ span — the registry's `.switchMode` verb "Switch Mode (⌘1–⌘7)" + label "⌘1–7"
(`CapabilityRegistry.swift:1312`), the helper's "⌘1–7 · note modes: … · Canvas" row
(`HelperView.swift:168`, tied to the label by `everyDeclaredShortcutIsFindableInTheHelper`), the
masthead menu's help "… · Blocks · Canvas (⌘1–⌘7)" (`PostDetailView.swift:320`); (3) the helper's
"canvas" DICTIONARY entry (`HelperView.swift:390`); (4) **the Snippets area's second face** — the
"Scraps | Canvas" segmented picker (`PoolDetailView.Mode`, `CanvasView.swift:1052`, mounted at
`RootView.swift:940`; AppSpec §12: "Canvas = a VIEW on a post or the scraps area"); (5) the
canvas-only acts `.toggleCanvasBank` / `.returnCardToBank` are `.surface` doors rendered only INSIDE
`CanvasView` — unreachable once (1)–(4) are gated; their declarations stay (the registry walk is
Debug's). The ⌘K palette carries NO mode rows (no `requestMode` caller beyond ⌘-keys, the rail and
in-mode hops to Takes/Write), and no Settings pane names Canvas. **Not gated — the fence:** the field
guide's prose teaches Canvas (lesson "blocks · canvas", the mode-row sentence at
`TutorialSeeder.swift:456`) — seed CONTENT, 13s's (finding F-B2 below).

### THE TRACE — (m), the two cursors

**The surface is the quick-ENTRY box** (`Features/Shelf/QuickEntryBar.swift` — the Bookcase's and the
Library's "new note — just start typing" capture; the dev-store capture `b2/old/w0.png` shows its █
at the placeholder's end). The floating quick-note pad composes the same `CaptureTextView` but
draws NO block cursor; the Snippets area's entry draws one gated on `@FocusState` (correct). **The
mechanism:** the bar draws the Terminal voice's blinking block cursor while `tokens.showsBlockCursor
&& !entryFocused` (empty box), and `entryFocused` is fed by `CaptureTextView.onFocusChange` — whose
own doc says what it is for ("the Terminal voice's blinking block cursor stands down when [the caret
is in this box]") — but which the Coordinator raised from `textDidBeginEditing` /
`textDidEndEditing`. AppKit posts begin-editing on the first EDIT, never when the view becomes first
responder. The Bookcase AUTOFOCUSES the box (R102 — `focusRequest` → `wantsInitialFocus` →
`makeFirstResponder`), so on every Bookcase visit the caret blinks at the box's start while the host
believes it is elsewhere, and the block cursor blinks at the placeholder's end: two cursors, until
she types (then the placeholder — and the block cursor with it — goes). **Built-and-broken, a
13u3 REGRESSION:** before 13u3 UNIT C (a0b1957d) the gate read `@FocusState` (`.focused($entryFocused)`
— the first-responder truth) and stood down correctly; UNIT C swapped the SwiftUI field for the AppKit
capture box and fed the same gate from editing notifications. The owner of the suppression is the
box's focus REPORT, not the bar's gate (which was right).

### THE TRACE — (n), the title's shift, STILL

**THE PRIOR LANDING (found first, per the brief):** the 2026-09-06 use-report round's ledger row 12
— punchlist 2, *"When you click on the title the placeholder text shifts upwards"* — FIXED at 17o
batch d, `5ce18072` (2026-09-08), with the pin `MastheadLayoutTests.bothTitleFacesShareOneBoxSoNothing
ShiftsOnClick`. Its mechanism then: the two faces (`Text` / `TextField(prompt)`) shared a max WIDTH and
nothing else, so the field's intrinsic height moved the row; its fix: ONE BOX — a hidden `Text` at the
title font defines it and the live face is an overlay that fills it.

**WHY IT SURVIVED — the pin went hollow at its own fix:** the editing face's oracle
(`recordTitleField`) is attached AFTER `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment:
.leading)` (`PostDetailView.swift:811–827`), so it reads the frame WRAPPER, which after 5ce18072 IS
the box by construction; the pin compares two rects that cannot differ, and nothing measured where the
WORDS land inside the field.

**THE MECHANISM (measured, a scratch diagnostic on the shipped test harness — never committed; the real
`NSTextField`, its field editor, and a pixel scan of the drawn words):** on a note named by its DAY
(her capture: "2026-10-04"), the title is stored "" and the draft is the stored name (13g R6-3), so the
open field is EMPTY and shows its PROMPT — the date — and that prompt is drawn by SwiftUI's own field
editor (`_SystemTextFieldFieldEditor`, TK2) laid against the field's TOP rather than on the label's
baseline. Box = field = field editor = 29 pt in Study, 22–23 pt in Terminal (the frames agree — the
prior fix holds); but the words: **Study (Iowan Old Style Bold 21, ascender 21.76 > its 21-pt size) —
the label's glyph tops at y 18.5, the open prompt's at y 12.0 = the field's own top edge: 6.5 pt up and
CLIPPED there** (exactly her capture's cut-off tops); Terminal (SF Mono Semibold 19, ascender 18.37) —
0.5 pt. **TYPED text is not affected** (Study: tops 16.0 typed vs 16.5 at rest; the TK2 line fragment
29 pt tall, baseline 22) — only the PROMPT moves. Her "still": the prior fix aligned the BOXES; the
words inside one of them were never measured. No editor-seam code is involved (the masthead title is a
SwiftUI `TextField`; the measurement read SwiftUI's field editor, never `EditorTextView`).

### THE WALK CAUGHT ONE DEFECT IN THIS BATCH'S OWN (b) FACE (F-B2-5 — fixed in piece 3b below)

The (b) grip (034c28ad) drew at `.offset(x: -16)` in an `.overlay` — OUTSIDE the row's bounds, in the
board's 28-pt gutter. Walked live after the acceptance captures (`b2/` x1–x5 working frames, scratch):
rows that had MOVED between sections kept the wrong grip state — "u4 third" and "field notes",
re-shelved by their menus with my order on, still drew ⠿ after the order went A–Z and then "last
edited" (the mark scrolled WITH its row — a live view, not stale screen paint); "u4 other",
re-shelved under last edited, drew NO grip once my order was back; "u4 owned copy", re-shelved by DRAG
with my order on, drew none either (so not the context menu, and not "frozen at the move"). The
discriminating act: a book dropped onto that grip-less row LANDED right above it (*"u1 context mint"*
→ correspondence) — the row's `placing` (which also gates its drop site) was LIVE; only the
out-of-bounds grip failed to draw. Mechanism: content drawn outside a lazily-hosted row's bounds is
not reliably repainted when that row is re-inserted elsewhere. The fix keeps the grip INSIDE the row:
a fixed grip column every row carries (opacity by `placing`), the row pulled into the gutter by the
column's width so the name column still never moves between orders.

**F-B2-5, CORRECTED BY THE NEXT WALK (the record above stood one round too early):** the in-bounds grip
(0dd108e1) did NOT cure it — after re-shelving two rows with my order on, A–Z still drew their grips.
Re-reading the "decisive" drop honestly: it happened with NO order change after the move, so it never
tested re-evaluation. A later change — reading `placing` once in the board's body and handing it to
every row — did not cure it either (reverted, never committed). The DECISIVE act was a control no B2
code touches: **with "details" turned OFF, every row hid its meta EXCEPT the two rows that had moved
between sections** (`b2/f1-moved-rows-frozen-details-off-terminal-light.png`) — so it is PRE-EXISTING
(U1's board) and whole-row: a book moved between sections (by its menu OR by a drop — both tried)
keeps a `LazyVStack` row view that never re-renders until the board is rebuilt; its meta, its
`placing` (the grip, the hairline, the row drop's enablement) all freeze with the state it moved in.
It breaks (b)'s own contract (a drop onto a row moved under A–Z is dead in my order until a rebuild),
so (b) owns it. The fix: a SECTION-qualified row identity. Re-walked live on the fixed build:
`f2` (a menu-moved row follows details ON), `f3` (my order: every row's grip, the moved one included),
`f4` (a second row moved INSIDE my order, then A–Z: no grip anywhere) — both displaced rows ended back
in Unshelved, their original state.

### EVIDENCE SUMMARY (logs in the gitignored session scratchpad `17y-b2/`; captures in `17y-screens/b2/`)

- **(a)(b)(e) shared mechanism** — the pre-fix build's launch log FAULTS on the undeclared type; the
  pre-fix synthetic drag runs its session and lands nothing; `DragTypeDeclarationTests` RED on the
  pre-fix tree (3 tests, 10 issues) → GREEN 3/3; the same drag LANDS on the fixed build (strip name +
  section label), the fixed instance logs zero declaration faults.
- **(b)** `BookcasePlacingGripTests` (gate red by revert, 2 issues) · `BookcaseRowFreezeTests` (the
  pre-existing freeze: red 3/3 with the identity line reverted, green 3/3 fixed; its first form HOLLOW
  and recorded as such) · walked: grips, a grip-started drop landing right above, the freeze before
  (`f1`) and after (`f2`–`f4`), the final build (`b9`), Study (`b10`).
- **(e)** `BookPanelDragGateTests` RED on the pre-fix behaviour (4 issues) → GREEN; revert RED (4) ·
  walked: her capture's chapters drag and land; the stamp-order refusal with its road.
- **(m)** `CaptureFocusReportTests` RED on the pre-fix tree (1 issue — the arrival) → GREEN; revert
  RED (2) · walked: one cursor in both states, AX-confirmed.
- **(n)** `MastheadLayoutTests.theOpenFieldsWordsStayWhereTheTitleRested` RED on the pre-fix code (3
  issues — the prompt in both voices; Study 6.5 pt) → GREEN · walked both voices.
- **(p)** `CanvasDebugOnlyTests` RED against the seam's pre-fix shape (6 issues) → GREEN · Release
  COMPILE green + `nm` (0 oracle symbols in Release) · the Debug capture (`p1`).
- **END:** the B2 union **335 tests / 62 suites** (7 standing opt-in skips) · the tutorial spine **98 /
  13** · the phone BUILD SUCCEEDED · the Release compile BUILD SUCCEEDED.

### FINDINGS (for the orchestrator)

- **F-B2-1 — FIXED: the three in-app drag types were never declared** (items (a)(b)(e)). 13i-d's F-U1-4
  / F-U2-4 ("synthetic drags never commit a SwiftUI drop here") recorded THIS defect as a harness
  artifact; on the fixed build the same synthetic drags commit. The combined-walk list's "drags by hand"
  items were never going to pass by hand.
- **F-B2-2 — FIXED, class extension: the sidebar Open strip's row reorder** (pre-13u Act 10,
  `OpenNoteDragToken`) carried the same undeclared type and was never walked; declared in the same
  commit (the pin's source scan names it). Not one of her six items — it joins her Monday drag
  spot-check (a row of the Open strip dragged to reorder).
- **F-B2-3 — the prior (n) pin went HOLLOW at its own fix** (`bothTitleFacesShareOneBoxSoNothingShifts
  OnClick` reads frame WRAPPERS that equal the box by construction). Kept — still true, still cheap —
  beside the new pin that measures the drawn words. The reviewer may prefer it retired.
- **F-B2-4 — WalkKit fact:** a synthetic mouse-up can be MISSED by AppKit's drag loop (a fast `du`
  after the `dm`s): the session stays open (`sample <pid> | grep _dragUntilMouseUp`), the app answers no
  AppleEvent (a quit TIMES OUT) and the next real or synthetic mouse-up ends it — post a second `du`
  after checking. The orchestrator may fold it into `Tools/WalkKit/README.md` (not edited here).
- **F-B2-5 — FIXED, PRE-EXISTING (U1's board): a book moved between sections froze its row** — meta,
  grip, hairline, row-drop enablement — until the board was rebuilt (proven with U1's own details
  toggle). The record above keeps both wrong turns (the out-of-bounds theory; the parent-read theory)
  and the hollow first pin, in order.
- **F-B2-6 — the field guide teaches Canvas in Release** (lesson "blocks · canvas" + the mode-row
  sentence at `TutorialSeeder.swift:456` — "Read · Lenses · Compare · Blocks · Canvas, and …"). Seed
  content: 13s's (fenced here). The tutorial spine is Debug and stays green.
- **F-B2-7 — (e)'s gate has a sibling on the book view's OWN surfaces:** the navigator/Outline drop
  (`BookStructureModel.acceptDrop` → `filePost(…, reposition: false)`) re-places a note inside its own
  chapter of a stamp-ordered book as the same silent no-op. Not this batch's surface (the brief named the
  Book Panel); the same `needsManualOrder` words would serve it. Owner: the orchestrator's call (a
  standing-fixes item, or B3's touch of the book view).
- **F-B2-8 — no regression risk noted in the type declarations:** the three identifiers are private
  (no extension, no MIME); the Release plist carries them; nothing outside the app reads them.

### PROVISIONALS (QUESTIONS #184 carries them, in her words)

- **P-17y-B2-1 (b) the handle:** the app's one grip glyph ⠿ in each row's leading gutter, ALWAYS visible
  while my order is on (never on hover), none in A–Z / last edited. (a) BUILT · (b) "≡" drag bars · (c)
  shown on hover only.
- **P-17y-B2-2 (e) a lone chapter shows no grip** (it cannot move anywhere — her "a handle that cannot
  drag must not render", read literally). (a) BUILT · (b) keep the grip for the navigator's consistency.
- **P-17y-B2-3 (e) the stamp-order refusal** speaks only for a re-place INSIDE the note's own chapter;
  filing into ANOTHER chapter in a date-ordered book still files (at its date place, silently — the book
  view's own ruling). Words: *“Journal” is sorted by Entry date ↓, so a note can’t be placed by hand —
  set the book’s order ▾ to Manual order and save it.* (a) BUILT · (b) refuse every note drop in a stamp
  order · (c) offer to switch the book to Manual order on the spot.
- **P-17y-B2-4 (m) which cursor:** the Terminal block cursor yields the moment the caret is in the box
  (the 13u3 contract, restored — her rule's "one at a time"). (a) BUILT · (b) the block cursor WINS
  while the box is empty and the system caret is hidden until she types.
- **P-17y-B2-5 (n) the open field's date** is drawn in the voice's placeholder ink (`faint`) where the
  system placeholder grey drew it before. (a) BUILT · (b) the resting colour (`muted`) — no visible
  change at all when the field opens.
- **P-17y-B2-6 (p) a note left in Canvas** reopens in Write on a Release build (your real store ran
  Canvas before this). (a) BUILT · (b) reopen in Blocks (Canvas's "managing" sibling).
- **P-17y-B2-7 (p) the Snippets area's Canvas face goes too** (AppSpec §12: "Canvas = a VIEW on a post
  or the scraps area"); its Scraps | Canvas picker is not drawn in Release. (a) BUILT · (b) keep the
  Snippets canvas in Release.

### MOBILE PARITY (record only — nothing built)

Nothing mobile-visible. The phone has no Bookcase drags (U1's parity facts stand), no Book Panel (U2's
F-U2-5 stands), no Terminal block cursor on its capture, no rename-field prompt of this shape, and no
Canvas (her 2026-08-03 exceptions: "the sticky-note style of editing" is not replicated). The one
Shared/ addition (`BookcaseBoard.placesByHand`) is unused there; the phone built green.

### SEAM NOTE (for the review cast)

No `Sources/VariorumCore/Sync/`, no schema, no custody, no editor seam in the strict sense
(`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier untouched). Two text surfaces ARE in
the diff: **(m)** `CaptureNSTextView` — a TK2 `NSTextView`, OUTSIDE the editor seam by its own header
(no identity attributes, no `BlockRangeIndex`, no `PaneTextAuthority`, no router claim), the change only
first-responder overrides and no TK1 API; **(n)** the masthead title — a SwiftUI `TextField` (the
measurement read SwiftUI's own field editor). The orchestrator decides whether that re-casts to Fable.

### 17y B2 FIX ROUND (round 1 → 2) — `opus-implementer`, a FRESH session, 2026-10-05; the binding findings are `notes/plans/17y-b2-ladder-round1.md`

**NOT DONE (first line, per the contract):** (1) **No walk this round** — the round's brief set the evidence (MAJOR-1: pin
red-on-old + revert; the rest: suites green), so MAJOR-1's face (the panel's "reopen it first" / "unseal it first" toast on
a frozen, date-ordered book), NIT-3's steady chapter names and NIT-6's new tooltip are pinned and suite-green but UNWALKED
on the dev-store Debug build — the orchestrator's call (round 2's walk or her Monday spot-check). (2) **F-FR-1 is recorded,
not fixed** — a capture-box focus request raised before the box is in a window is dropped (below); the NIT-1 pin drives
the windowed re-raise road instead of the `.task`-at-birth road the ladder named. (3) MAJOR-2 (the guide's Canvas teaching)
is B-DEDUPE's and MINOR-2 the orchestrator's — not touched here. (4) The tutorial spine was not run (no seed or spine
surface in this diff, per the brief). Fences as B2's: zero `Sync/`, schema, custody, mobile code, seed content; no
/Applications refresh; no Release launch.

Preflight read in this session's own context: CLAUDE.md + its auto-loaded canon; the ladder record
`17y-b2-ladder-round1.md` whole; the B2 BRIEF and the B2 RECORD whole; QUESTIONS #184;
`notes/SessionResiliencyProtocol.md` whole. Worktree `~/dev/variorum-17y` only; DerivedData
`App/Variorum/DerivedData/17y/`; no subagents.

#### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | finding | status |
|---|---|---|
| 0 | This record | DONE (this commit) |
| 1 | MAJOR-1 — the frozen book's drop speaks the op's reopen/unseal refusal, never `needsManualOrder` | DONE (d083a464 red · 03a0513e fix): `BookPanelBrain.dropOutcome` gains `frozen` (the HELD row's `locked` — sealing finishes too), consulted BEFORE the sort gate — a frozen book's plan runs so `assignPostToSection`'s own lock guard refuses through `run` (one refusal source); `drop` reads the held row once (`snapshot(for:)?.reading ?? book`) for the lock consult, the manual-order words AND `run`'s sealed/finished wording. Pin `aFrozenStampOrderedBookSpeaksItsOwnRefusalNotManualOrder(sealed:)` (finished → "reopen", sealed → "unseal", never "Manual order", nothing moves): **RED on the pre-fix tree** (`m1-red.log`, "6 tests in 1 suite failed … with 4 issues", lines 205/207 both arms) → **GREEN with the Book Panel family "21 tests in 4 suites passed"** (`m1-green.log`) → **REVERT (the `if frozen` line removed from 03a0513e) RED "6 tests … with 4 issues"**, the same four (`m1-rv.log`), restored by checkout, `git diff --quiet` |
| 2 | MINOR-1 — the row-freeze pin's frame-recorder coupling said at both sites; the pin REQUIRES a frame record for both rows; the B2 RECORD's row 3c citation corrected to the committed test's real lines/issues | DONE (3181a953 hardening · this commit the record): MEASURED FIRST — the COMMITTED pin (bc49e069's) with the identity line reverted: RED "2 tests in 1 suite failed … with 2 issues" at lines 119/128 (`n1-committed-pin-rv.log`). The hardening: the ⚠ LOAD-BEARING comment at `ShelfView`'s `.onGeometryChange` recorder (the why unexplained, said) + `BookcaseRowOracle.frame(_:)`'s doc corrected (no pin reads the value) + the pin's header; the pin's first settle waits for both rows' frames and `#require`s them. **The hardened pin GREEN** ("2 tests in 1 suite passed", `n1-green.log`); **the identity revert RED "… with 2 issues" at 137/146** (`n1-rv-identity.log`); **the reviewer's HOLLOW configuration (identity reverted AND the recorder removed — green before) now RED at the `#require`, "… with 1 issue" at 120** (`n1-rv-hollowconfig.log`) — the coupling can no longer be cleaned up into hollowness; both restored by checkout, `git diff --quiet`. **The B2 RECORD's row 3c citation corrected** (the one edit inside that section): the committed test's 2 issues at 119/128, the diagnostic version's "4 issues" named as such |
| 3 | NIT-1 — `onCaretChange` delivered async; the pin host's raise moved onto the real `updateNSView → takeFocus` road; the header's red count corrected (1 issue on the pre-fix tree) | DONE (4ac49745 · this commit): `CaptureTextView` delivers the caret report through `DispatchQueue.main.async` (FIFO); the pin's host writes `@State` from the report as `QuickEntryBar` does and RAISES its request once the box is up (the bar's padding-tap / title-chip road — `updateNSView → takeFocus → makeFirstResponder`, inside the update). **The class, measured on that road:** the async hop reverted (sync delivery) → the pin still passes but the run logs SwiftUI's own `[SwiftUI] Modifying state during view update, this will cause undefined behavior.` (`nit1-rv-sync.log`); with the async hop: zero such lines (`nit1-pin-async.log`, `nit1-capture.log`). **The header's counts re-measured on the new host:** the PRE-FIX `CaptureTextView` (95f615eb^) → "1 test … failed … with 1 issue" (the arrival, line 132; `nit1-prefix.log`); the wire removed → "… with 2 issues" (132/139; `nit1-rv-wire.log`); both restored by checkout, `git diff --quiet`. **The capture family GREEN: "Test run with 41 tests in 10 suites passed"** (`nit1-capture.log` — focus report, keys ×2, hand-off, the bar, ShelfModel, the four quick-note suites). The one-cursor behaviour's suites hold; no STOP owed on the async delivery. **The `.task` raise could NOT be the pin's road** — F-FR-1 below (recorded, not widened) |
| 4 | NIT-2 — four stale comments (`BookcaseStrip` 51–54, `BookPanelModel` 121–124, `PostDetailView` 891, the row-12 masthead pin's doc) | DONE (this commit; comments only — `git diff` carries no non-comment line): `BookcaseStrip`'s walk note now says `Transferable` did NOT cure the dead drops — the undeclared type did (F-B2-1), every in-app drag type exported in `VariorumInfo.plist`, pinned by `DragTypeDeclarationTests`; `BookPanelDragToken`'s doc the same (no "proven road"); `beginEditing`'s comment names the date drawn BEHIND the prompt-less field (B2 (n)); the row-12 pin's doc retitled "share ONE BOX" and says it guards the BOX only (F-B2-3), pointing at `theOpenFieldsWordsStayWhereTheTitleRested` for the words. Evidence: the END compile + suites (row 9) |
| 5 | NIT-3 — the Book Panel's lone-chapter grip drawn by OPACITY in a fixed slot | DONE (this commit): `BookPanelView.chapterRow` keeps the ⠿ `Text` in every chapter row, `.opacity(gripDrawn ? 1 : 0)` + `.accessibilityHidden(!gripDrawn)` — the `if`-removal (a ~12 pt name shift across 1↔2 chapters) gone; #184(b)'s decision unchanged (`chapterGripDrawn` the same value). Evidence: compiled and GREEN with the Book Panel family + the drag-type pins, "25 tests in 5 suites passed" (`nit4-green.log`) |
| 6 | NIT-4 — `dropOutcome` returns `.nothing` for an already-satisfied stamp-order drop (onto the note's immediate shown successor) | DONE (ce4a9626 red · 6ee95cba fix): inside the sort gate, a manual-plan `before` equal to the note's immediate successor in its SHOWN group (`BookPanelBrain.successor(of:in:)`) → `.nothing` (nothing written, nothing said, `drop` returns false — manual order's same gesture is silent too); a frozen book still answers first (MAJOR-1). Pin `aStampOrderedDropOntoItsOwnSuccessorAsksForNothing`: RED on the pre-NIT-4 tree (2 issues, `nit4-red.log`) → GREEN with the Book Panel family + the drag-type pins **"25 tests in 5 suites passed"** (`nit4-green.log` — this run also compiles NIT-3) → **REVERT (the one line removed from 6ee95cba) RED "7 tests … with 2 issues"** (`nit4-rv.log`), restored, `git diff --quiet`. **One B2 pin moved, said plainly:** `aStampOrderedReplaceRefusesWithTheRoad` dropped n2 onto n1 — in this world's stamp order n1 is n2's immediate shown successor, so B2's own refusal pin exercised EXACTLY the already-satisfied case this NIT rules a nothing (it went red on the fix, 1 issue). It now drops the note shown LAST onto the one shown FIRST (a real re-place) and still guards the refusal with its road |
| 7 | NIT-5 — the completeness pin: every `PostMode` case (an exhaustive-switch helper) in `order(keepingCanvas: true)` | DONE (c33a3d0d · this commit the record): `CanvasDebugOnlyTests.everyCaseSitsInTheDebugRow` walks every case WITHOUT `allCases`, through `ring(after:)` — an exhaustive switch whose arms each name the next case (a new case fails to compile until its arm joins the ring) — and requires each reached case in Debug's full row, each once; `declaredOrder`'s doc points at it. **Bite check** (not a bug-class pin — hardening): `.lenses` dropped from `declaredOrder` → the pin RED at 76/79 (`nit5-bite.log`), restored, `git diff --quiet`. Green with the mode/canvas family at the END (row 9). *The ring's one honest gap, said:* an arm written for a new case that nothing else NAMES (`case .x: .write` with no arm returning `.x`) would escape — the doc forbids it; Swift offers no case enumeration once `allCases` is overridden |
| 8 | NIT-6 — `gripHelp` softened to §20's truth; the edge appended to QUESTIONS #184 as (h) in her words | DONE (this commit): `BookcaseCopy.gripHelp` now reads *"Drag to place this book by hand, on any shelf. Dropped on a book, it lands right above it — except across the starred line: starred books always stay first."* (PROVISIONAL, 13s re-voices) — traced first: the board draws starred-then-unstarred, each in hand order (`BookcaseBoard` — `sorted(starred) + sorted(unstarred)`), and `placeReading(.before(target))` writes a star-agnostic position, so a cross-half drop settles in its OWN half where that position falls (often the top of the unstarred run). The placement behaviour is untouched. `BookcasePlacingGripTests.theGripSaysWhatADropDoes` now requires the landing rule AND the starred-line clause. **QUESTIONS #184(h)** appended in her words with the ladder's alternatives (refuse a cross-line drop with a short reason; or keep as built and let her walk decide). Evidence: the Bookcase family at the END (row 9) |
| 9 | END suites — the Book Panel family, the Bookcase family, the capture family, the mode/canvas family incl. the registry walk (+ the masthead family, whose test file this round edited) | DONE — **"✔ Test run with 236 tests in 42 suites passed"** (`end-fix.log`, HEAD e00120a8's code, `DerivedData/17y`, zero Variorum instances by path; no skip lines). The 42: Book Panel (DragGate, Brain, Declaration, Acting) + `DragTypeDeclarationTests` · Bookcase (PlacingGrip, RowFreeze, ViewModel, BoardBrain, MoveToShelfGate, ShelfModel, BindDoor, MembershipChoice) · capture (FocusReport, Keys, TextViewKey, HandOff, QuickEntryBar, the four QuickNote suites) · mode/canvas (CanvasDebugOnly, NewModes, OpenStripMenu, SidebarLayout, ShellChrome, PostDetail mode memory + routing, CanvasAndPool, CanvasArrival, the three CanvasBank suites, CanvasDragTracking, StarredScroll ×2, **`CapabilityRegistryTests` — the registry walk**) · masthead (MastheadLayout, OneTimeCodeAutoFill, DebugOracleOwnership, MastheadTagDoor). The run's SwiftUI "Modifying state during view update" lines (103) are PRE-EXISTING — B2's own END log carries 108 from the same Canvas-arrival/bank/drag, masthead and routing suites; none from the capture or Book Panel families (F-FR-2) |

**REVERT STATE: NO REVERT IN FLIGHT** (the (j) synthetic revert round ran and was restored — `git diff --quiet` verified).

#### FINDINGS (for the orchestrator)

- **F-FR-1 — a focus request raised before the capture box is in a window is DROPPED (found by NIT-1's host
  change; NOT fixed — untraced in the real app).** With the pin's host raising `focusRequest` from `.task` (the
  Bookcase's own autofocus shape, `QuickEntryBar`'s `.task { if autofocus { focusRequest += 1 } }`), the hosted
  pin went RED 3 issues: no caret, no report. Scratch diagnostics (never committed, `nit1-diag-task.log`): the
  raise reached `updateNSView` while the box's `window` was still nil — `lastFocusRequest` is bumped, then
  `Coordinator.takeFocus()` returns at its `guard … view.window`, and nothing retries (the view's later
  `viewDidMoveToWindow` only honours `wantsInitialFocus`, set at make from a request already > 0). So a request
  that lands before the box is windowed is consumed and lost. Whether the REAL Bookcase meets that order is
  untraced: B2's walk (`b2/m1-focused-frame1…4`) shows its caret arriving — by this road or by another (AppKit's
  or SwiftUI's own first-key-view choice) is unknown. A candidate fix (when `takeFocus` finds no window, set
  `wantsInitialFocus` so the arrival takes it — the pad's existing road) is a focus-behaviour change to both
  capture doors on an untraced trigger: a bug-class item needing its own trace on the real app, so it was NOT
  folded into this hardening round. **Owner: the orchestrator's call** (a 17y/19 standing-fixes item, or B3's
  touch if it reaches the Bookcase). The NIT-1 pin drives the same `updateNSView → takeFocus` road with the box
  windowed (the re-raise road), which is where the state-during-update class was measured.
- **F-FR-2 — pre-existing SwiftUI "Modifying state during view update" warnings in OTHER suites (record only).** The END
  run logs 103 such lines, B2's own END run 108 — attributed (roughly, by the suite each falls under) to "Canvas arrives
  fitted…" (~85), the masthead title suite (~12), the Canvas bank/drag and PostDetail routing suites (~2 each). None is in
  this round's diff or in the capture family (whose pin's road now logs zero). Not owned here; the orchestrator's call
  whether the class gets a sweep.

#### DISPOSITIONS (round 1 → 2, one line each)

- **MAJOR-1 — FIXED with its pin** (d083a464 red · 03a0513e fix · revert RED 4 issues): the lock answers before the sort gate.
- **MINOR-1 — FIXED (hardening + honest record)** (3181a953 · e48df72a): the coupling said at both sites and REQUIRED by the
  pin; the reviewer's hollow configuration now RED; the B2 RECORD's row 3c citation corrected (2 issues at 119/128).
- **NIT-1 — FIXED (hardening)** (4ac49745 · 367f1552): async delivery (the SwiftUI warning measured on sync, absent on
  async); the header's counts re-measured; the `.task` road NOT pinnable without a product change → F-FR-1.
- **NIT-2 — FIXED** (ed3b08e9): four comments corrected.
- **NIT-3 — FIXED** (90fe3ecb): opacity in a fixed slot.
- **NIT-4 — FIXED with its pin** (ce4a9626 red · 6ee95cba fix · revert RED 2 issues); B2's own refusal pin moved onto a
  real re-place (its gesture was the satisfied case).
- **NIT-5 — FIXED** (the ring pin; its bite checked).
- **NIT-6 — FIXED** (e00120a8): the help softened; #184(h) in her words.

#### SEAM NOTE (for the round-2 cast)

No `Sources/VariorumCore/Sync/`, schema, custody, mobile code, `Shared/`, or seed content (`git diff 205009ad -- Sources
Server App/Variorum/VariorumMobile App/Variorum/Shared` EMPTY). No editor seam in the strict sense. One text surface IS in
the diff: `CaptureTextView` (NIT-1) — a TK2 `NSTextView` OUTSIDE the editor seam by its own header; the change is only
WHEN the caret report reaches the host (a main-queue hop), no TK1 API, no identity attributes. The rest is the Book
Panel's drop brain (MAJOR-1, NIT-4), chrome (NIT-3), copy (NIT-6) and comments/pins.


#### THE ORCHESTRATOR'S SPOT-WALK (post-fix-round, pre-round-2 — the faces no round had seen; dev-store Debug build at 873fed6b, author-free ~05:20–05:45, zero other instances; captures `notes/plans/17y-screens/b2fix/`, gitignored)

- **MAJOR-1's refusal, LIVE (`frozen-refusal.png`):** the Journal (entry-date ↓, chapterless)
  FINISHED through Book Settings (no arrivals existed; no dismissal line in the sheet — correct),
  a member note opened, the Book Panel's "2026-09-26" dragged onto "2026-10-02" (a real
  re-place): the toast speaks **"“Journal” is finished — reopen it first."** — the op's own
  refusal with its real road, never the Manual-order advice. Nothing moved. The Journal then
  REOPENED through the same sheet (`journal-restored.png`, the "Reopened “Journal”." receipt);
  while finished it opened as pure text (the Finished contract's face, seen in passing).
- **(b) on the FINAL tree (`my-order-grips.png`, `after-drop-3.png`):** my order → every row's
  ⠿ in the gutter, names unmoved vs a–z; "u4 other" dragged onto "refresh walk" LANDS right
  above it; a–z → no grip anywhere. A–Z then restored.
- **NIT-3 LIVE (`book-panel-lone.png`):** "the door"'s panel (1 chapter) draws NO grip on
  "part one" while the name keeps the slot's indent — no hug, no shift.
- **(n) in passing (`panel-try2.png`):** a stray click opened the title's rename field on
  "door one" — the open field's words sat exactly where the resting title rested.
- **Walk facts:** (1) two drags STARTED ON THE GRIP COLUMN's left edge (gutter x≈248pt) never
  engaged a session; the same gesture from the row name committed — the implementer's b2/b9
  frames show grip-started drops landing, so this reads as a hit-area coordinate miss in this
  walk, not a defect; recorded for the next walker (aim the grip's center, or drag the name).
  (2) NIT-6's tooltip did not render under a 3 s synthetic hover + capture — the help string
  is pin-guarded (both clauses required), so the words are verified headless; the live tooltip
  render is macOS's own.
- **Residue (accepted class, the B2 walk's own):** one my-order hand position ("u4 other"
  above "refresh walk" in Home's unshelved sequence) — invisible outside my order. The Journal
  finish/reopen round-trips to flag-off (no arrivals existed to dismiss; no buffers were dirty).
  The Debug instance quit clean by identity; zero instances after.

## 17y B3 RECORD — faces, vocabulary, ruled behaviors: items (c)(d)(g)(o)(h)(i)(f)(l)(r)(s) + the F-B2-7 rider (`opus-implementer`, 2026-10-05; LIVE STATUS from the first commit)

**NOT DONE (first line, per the contract):** (1) NO DARK-MODE captures — the walk ran in LIGHT, in both voices (Study for r·s·d·l·h·g·o·f; (c), (i) and item 11 in Terminal only — word/behaviour rows whose Study face was not captured); (2) the Release side not walked and /Applications not refreshed (fenced); (3) F-B3-1 — lesson 4's "at the door" prose is SEED CONTENT (fenced), carried as a `withKnownIssue` and routed to B-DEDUPE; (4) the F-B3-3 latent test-host class is NOT fixed (B3's trigger is) — routed to the orchestrator; (5) the tag-picker ADOPTION LIST beyond the ruled three is enumerated, not built (R-17y-3 by design); (6) the WHOLE Mac target was NOT re-run after the two walk fixes (9be3f9ba + the close commit) — the END's 3887/638 is a453d458's code; the walk fixes re-ran their touched suites (73/7, then 38/3 incl. the registry walk); the phone build was not re-run (no Shared change since); (7) the note-only window does not follow the wing (P-f5); (8) F-B3-2 / F-B3-4 / F-B3-11 / F-B3-12 are recorded, not acted on (no ruling makes them).

Preflight read in this session's own context (never delegated): CLAUDE.md + its auto-loaded canon;
the B3 brief `notes/plans/17y-b3-brief.md` whole; `notes/plans/17y-sitting-rulings-2026-10-05.md`
whole (R-17y-1…9 + both R-17y-9 addenda + the overnight mandate); this file's 17y row end to end,
the kickoff, the RUN RECORD, the B2 BRIEF + B2 RECORD + its fix round + the orchestrator's
spot-walk; QUESTIONS #169/#170/#171/#174/#176/#183/#184 (next free number **#185**);
`notes/SessionResiliencyProtocol.md` whole; 13i-c U3 BRIEF + RECORD; 13i-b §3 + U2 RECORD;
13i-e U2 RECORD; 13i-d U1/U2 RECORDs + adjudications, U5 RECORD (design, book-move proposal,
findings, provisionals) + adjudication, U5b RECORD (design). Worktree `~/dev/variorum-17y` only;
DerivedData `App/Variorum/DerivedData/17y/`; no subagents.

### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 0 | This record + the b3 captures dir gitignored | DONE (5c1401fb) |
| 1 | (d) the cards view → "Cards" | DONE (cad446f4 red · bb586925 fix) — `LibraryCatalogModel.Mode.label` (List · **Cards** · Timeline — the `Scope.label` precedent; the case keeps its model name), the picker renders `ForEach(Mode.allCases)` from it. Pin `LibraryCardsWordTests` (a source scan: no mode word inline + the words) RED on the pre-fix tree (`m1-red.log`: 2 issues — three inline mode words, the "Notes" segment) → GREEN in the batch below. Word PROVISIONAL-for-13s (hers, F-U6-5) |
| 2 | (i) "unfiled" wins everywhere the chapterless state shows | DONE (893d160c red · 2b6f82fb fix) — `BookPanelCopy.noChapter` aliases the headers' `unfiled` (the three move menus — Book Panel, Index column, the navigator/Outline rows — render it); the Add receipt says "…added at the end of the book, unfiled." Pin `UnfiledWordTests` (grep-form over every Mac/Shared code line + the constant + the receipt) RED on the pre-fix tree (4 issues) → GREEN below. Two JUSTIFIED pin edits (`BookCollectingDoorsTests` constant, `BookArrivalsTests` receipt — subjects unchanged). The tutorial prose never named "No Chapter" (scanned) |
| 3 | (c) Duplicate as Version carries post tags (Diverge stays tag-less) | DONE (a93fbf6d red · cbc0d86b fix) — `duplicateAsVersion` copies the source's live post-tag applications through the ceremony copy's `copyLiveTags` (made internal), in its OWN transaction (Diverge + promoteLens compose `copyPost` and stay tag-less); a ROW copy, no intake (P-17y-B3-c1). Pin `DuplicateCarriesTagsTests` RED on the pre-fix tree (`c-red.log`: "5 tests … failed … with 4 issues" — the copy's paths + row count, the undo test's do + redo arms; the three controls green) → GREEN with every duplicate-touching core suite "143 tests in 14 suites passed" (`c-green.log`). The tutorial seeder's twin apply tolerates `alreadyTagged` ONLY (the twin is now born wearing the guide tag) — the spine runs at the END. Doors (Library/Takes/chip/seeder) unchanged: no receipt changed |
| 4 | item 11 — F-B2-7: the book view's own navigator/Outline drop gate (lock first; satisfied = nothing) | DONE (bd0b3c22 red · f267ede6 fix) — `BookStructureModel.postDropOutcome` (`.plan` · `.nothing` · `.needsManualOrder`, over the unchanged `postDropPlan`), the lock consulted FIRST and the satisfied drop a nothing (B2's MAJOR-1 / NIT-4 orderings); `filePost` speaks `BookPanelCopy.needsManualOrder` on the book view's own error face (`lastError` — where the frozen refusal already speaks), naming the order she is looking through (`viewOrder`, else the stored one). Pin `BookViewDropGateTests` RED on the pre-fix tree (`m1-red.log`: 2 issues — the re-place and the dispatcher; the successor, frozen×2 and cross-chapter controls green) → **GREEN: "121 tests in 15 suites passed"** (`m1-green.log` — the three B3 pins + BindDoor, BookArrivals, BookCollectingDoors, BookDrop, the four BookPanel suites, BookStructureModel, LibraryCardName, MembershipChoice, VocabularySweep) |
| 5 | (r) the № census panel as a true overlay dropdown | DONE (0c640d61 red · c93864f4 fix) — TRACE: 13i-d U1 drew `BookcaseCensusPanel` IN FLOW, a VStack sibling between the strip and the board's ScrollView (P-13id-U1-6's "opens IN FLOW under the strip (mockup v5)" — superseded by her report), so opening it pushed every row down by its height and, in a window whose height was spoken for, the shrunken scroll region clipped the first row at its top (her capture). FIX: the panel hangs from the strip as an `.overlay(alignment: .bottomTrailing)` with its top aligned to the strip's bottom (`alignmentGuide`), right-aligned under the № at the same 28-pt inset, the strip `zIndex(1)` so it floats over the board; contents, solos, remembered-open untouched. Pin `BookcaseCensusOverlayTests` (the rows' own `.global` frames, closed → open → closed) RED on the pre-fix tree (`r-red.log`: 2 issues — **both rows moved 148.0 pt**) → GREEN with the Bookcase family **"22 tests in 7 suites passed"** (`r-green.log`). **THE WALK CAUGHT THE FIRST BUILD'S FACE WRONG (F-B3-8):** hung from the STRIP with a custom `.alignmentGuide(.bottom) { $0[.top] }` under `.overlay(alignment: .bottomTrailing)`, the panel drew ABOVE the strip (SwiftUI ignored the guide — measured: panel y −26…116, strip 76…116), over the masthead; the pin was green because it only measured the push. The pin now ALSO measures the face — the panel's top at the strip's bottom, right-aligned at the 28-pt inset (DEBUG frame records `BookcaseRowOracle.stripKey`/`censusPanelKey`): RED on that build (`r2-red.log`, 2 issues — off by 142 pt and 28 pt) → the fix hangs the panel from the BOARD's top edge (`.overlay(alignment: .topTrailing)` on the ScrollView, `zIndex(1)`) → GREEN **"29 tests in 9 suites passed"** (`r2-green.log`) |
| 6 | (s) the starred shelf (virtual, books only, drop-to-star) | DONE (this commit) — `BookcaseScope.starred` (Shared — a SCOPE, no stored row: undeletable/unrenamable/zero schema/zero sync structurally; the Home-wing precedent) + `Section.Kind.starred`; `booksInScope`/`sections` read the UNION star (`ShelfBook.starred` — books AND gatherings, never notes); `mintShelf` nil (P-s4); `placesByHand(_:in:)` off on starred (P-s3 — a hand position belongs to a real shelf); the strip's bare lowercase word right after All, always shown (P-s1/s2), a drop target that STARS a dropped book (`ShelfViewModel.starBook` — `setStarred(.reading)`, the cap's refusal in the star doors' words, silent on success, one-way — P-s5); the empty one-liner only in the solo'd board. No menu on the word. Pins `BookcaseStarredShelfBrainTests` (5) + `BookcaseStarredShelfDropTests` (2) — a ruled BUILD (no red-on-old owed) — GREEN with the Bookcase family + StarredScroll **"33 tests in 11 suites passed"** (`s-green.log`). Face: the walk |
| 7 | (l) book-row context menus beyond the Bookcase | DONE (this commit) — ONE table + ONE renderer in the shared home (`Core/Views/BookRowMenu.swift`: `BookRowMenuTable` · `BookRowMenu` · the `BookRowDoors` brain — facts read once per listing ∝ the rows, the surface's `BookStateDoors`, the settings sheet with W-1's Edit… hand-back — and the `.bookRowDoors` host). THE SURFACES (enumerated: every book/gathering ROW outside the Bookcase, pickers aside — the ⌘K palette, the chip's Add list, the Book Panel switcher, the Pool's add picker, Manage Notes are pickers; the Pool renders no gathering row, only its count; the Library's info panel and the Timeline render no book row): **(1) the Library's List mode, Books section** · **(2) the sidebar's Starred section, book rows** (note rows keep Star/Unstar) · **(3) the Archived surface's BOOKS group** (its row buttons' twins + star + settings; its state doors are the surface's own, confirmed once). THE MENU TABLE (P-17y-B3-l1): Open · Star/Unstar · Book/Gathering Settings… · Export Markdown… · Export PDF… · Archive (Archive… on an owned book) or Unarchive · Delete Book… (never on the daily Journal) — the SAME on all three. Dropped (`BookRowMenuTable.bookcaseOnly`): Move to Shelf ▸, Send to Top/Bottom (her carve-out — position), Move to Wing ▸, Duplicate Book…, Manage Notes…, Bind / Make a Book, Edit Rule… (inside Settings via Edit…), Rename… / Length & Extent… (inside Settings), Use as Daily Journal. Registry: `.unarchiveBook` gains `.contextMenu`; the walk's union gains the renderer (JUSTIFIED EDIT) + one justified edit in `BookArchiveDeclarationTests`. Pins `BookRowMenuTests` (6) GREEN with the registry walk + archive/star/sidebar suites **"71 tests in 12 suites passed"** (`l-green.log`). Face: the walk |
| 8 | (h) the Arrivals door on the mode-row icon; the one word "Arrivals"; rows open the note | DONE (this commit) — `BookArrivalsDoor` in the book masthead beside the gear (BOOKS only — a gathering has no door, P-2): CALM = a faint `tray.and.arrow.down`, no count; PRESENCE = the accent icon + the count; it HOSTS the door's observation (`.task(id: listingLimit)`) and opens a POPOVER (header "Arrivals · N waiting", or the calm "Nothing is waiting…" sentence) whose content is `BookArrivalsList` — the old line's rows, each NAME a link that OPENS the note through the ordinary `.variorumOpenPost` road (read-normal, writes nothing — never seats), the arms unchanged. The content-top line is GONE from Index, Outline and the Book spread (the archived line stays — F-B3-2). The model gains `doorOpen`/`setDoorOpen` (opens on an empty door too). THE ONE WORD (R-17y-2): `ArrivalsCopy.word`; the finish confirm's §24 line + the wing move's "N waiting at Arrivals will be dismissed." (P-h3), the judged refusal "…isn't waiting at Arrivals any more…", the membership sheet's note "…judge it at the book's Arrivals.", the registry note. Pins `ArrivalsDoorPlacementTests` (4 — the hosts scan, a row's name opens/never seats, the retired sentences, a gathering has no door, mounted). JUSTIFIED EDITS (subjects kept, said in place): `BookArrivalsTests` (the mounted half rewritten to the door + the rows mounted on their own — a popover does not render under the test host), `ArrivalArmsTests`/`BookArchivedLineTests` (rows mounted directly), `BookStateDoorsTests`/`WingBookMoveDoorTests` (the one word), the registry walk (the renderer renamed `BookArrivalsList`), `TutorialBooksChapterTests.lessonFourArrivals` (the lesson's "at the door" line is SEED CONTENT — fenced — wrapped in `withKnownIssue`, re-owned to B-DEDUPE: F-B3-1). GREEN **"126 tests in 10 suites passed"** (`h-green.log`). Face: the walk |
| 9 | (g) the one searchable tag picker with create-in-place (rule terms + outflow) | DONE (this commit) — ONE control in the shared home, `Core/Views/SearchPicker.swift`: the BRAIN `SearchPickerBrain` (filter — contains, case/diacritic-insensitive, a leading "#" read as the tag reads; the CREATE offer — only for what does not already exist by the host's identity key; Return = the first match else the create row) + the FACE `SearchPicker` (the quiet word opens a popover: a focused search field, the matches, a 'New tag "#x"' row; Escape closes). The rule builder's "+ tag" and the outflow chooser's "+ tag" render it; making a tag in place is `RuleEditorModel.createTag` — the typed-path grammar (`TypedTagPath`: "/" makes a hierarchy) in the BOOK's wing (the mint sheet's wing when minting), made AT ONCE (P-g2), the term/outflow entry added to the DRAFT only Save writes; a quiet "Made the tag #x." receipt. Pins `SearchPickerBrainTests` (3) + `RuleEditorMakeTagTests` (3) GREEN with RuleEditor, OutflowChooser, GatheringRuleGate, SpawnAndBindLimb **"34 tests in 6 suites passed"** (`g-green.log`). THE ADOPTION LIST (R-17y-3 — each adopts the shared control at its next touch): see § THE TAG-PICKER ADOPTION LIST below. Face: the walk |
| 10 | (o) the add-to-book picker: the same idiom + the inline mint | DONE (this commit) — ONE road in the shared membership brain: `MembershipDoors.mintAndAdd` (the E13 store-wide name guard + `createReading(kind: .book)` in the NOTE's wing — P-o2 — then THE one add road `add` → `addPostToReading`, so the consult and the capacity gate are the add's own; an ownership refusal opens the choice sheet for the NEW book; the made book stands if the add is refused/cancelled — P-o3; the quiet receipt "Made the book “X” and added this note."). THE FACES (enumerated — every add-to-book picker): **(1) the membership chip's Add list** (the primary) — its flat `Menu("Add to Book")` retired for `SearchPicker` (the books, an archived one marked; the gatherings "by tagging"; the 'New book "X"' row), ALWAYS drawn now (she can make a first book); **(2) the Pool row's Add to Book sheet** (`NotePickerSheet`) — gains the same brain's create row (atop the matches; ⏎ takes it when nothing matches). Not add-to-book pickers (recorded): the Bookcase row's note DROP, Manage Notes… (the book side picks notes), the Book Panel switcher. Pins `AddToBookMintTests` (6 — the member + receipt; the consult opening copy-only for the new book; a taken name refusing with nothing made; the note's wing; the create row's offer; both faces carry the mint) GREEN with SearchPickerBrain, MembershipChoice, ArchivedMark, BookArchiveDeclaration and the registry walk **"62 tests in 6 suites passed"** (`o-green.log`). The capacity gate, said plainly: a fresh plain book has no cap — the gate passes by construction; the pin proves the road. Face: the walk |
| 11 | (f) the cross-wing follow (open + focus switch the wing; receipt; Open-row wing indicator) | DONE (this commit) — ONE rule for open AND focus: `WorkspaceModel.onFocusedSubjectChanged` (the `onNotesLeft` precedent — the fact's own type raises it, testable without SwiftUI) fires on every `select` (an OPEN — a re-open of the shown note included) and on every focus MOVE (`focus`, `openBeside`'s focus-existing, `closeSplit`); `Workspace/WingFollow.swift` follows: the subject's wing as surfaces read it (`effectiveWing` — dangling = Home), and when it is ANOTHER wing the app's one `WingState` switches with the quiet receipt "Now in “X”." / "Now in Home." (P-f1 words); a stale read (focus moved on mid-read) is not followed; wired per window in `RootView.wireWorkspace` (the `SavepointOnLeave.wire` shape). Notes AND books follow (P-f3); Snippets/Bookcase/Library never (no wing). A SWITCHER choice stands until a fresh open or focus move (nothing re-pulls from a standing pane). Editors never close (pinned: both panes keep their notes through three switches). THE INDICATOR: a cross-wing Open row names its wing, faint, after the title, hover "In the wing “X” — opening it takes you there" (P-f4), read once per (rows, current wing) ∝ the Open list. Pins `WingFollowDecisionTests` (1) + `WingFollowTests` (5 — open switches + receipt; same-wing silent; split focus follows both ways with editors surviving; the switcher's choice stands until an open; the indicator's names) GREEN with the pane/sidebar/wing/ascent neighbours **"51 tests in 15 suites passed"** (`f-green.log`). Face: the walk |
| 12 | END suites + the tutorial spine + the phone build | DONE — **core FULL "✔ Test run with 2179 tests in 245 suites passed"** (`end-core.log`; 1 standing env-gated skip). **Mac — the WHOLE `VariorumTests` target, the tutorial spine inside: "Test run with 3887 tests in 638 suites passed after 1485.553 seconds with 6 known issues", `** TEST SUCCEEDED **`** (`end-mac2.log`, HEAD a453d458's code; 12 skips — the standing opt-in env gates (two-window oracles, sample-library seeding, keychain/13p store writers); the 6 known issues: 4 pre-existing `IndexTierMetricsTests` arms, 1 pre-existing `TakesFindBoardTests`, and B3's own `lessonFourArrivals` (F-B3-1); the 15 `Tutorial*` suites green; zero dependency issues). The FIRST full run (`end-mac.log`) crashed its test host — F-B3-3, reproduced, bisected, B3's trigger fixed at 58bdeb0d before this run. **The phone: `VariorumMobile` generic iOS Simulator BUILD SUCCEEDED** (`phone-build.log`, `DerivedData/17y-mobile` — `Shared/BookcaseBoard.swift` changed; the phone calls none of it) |
| 13 | The walk → `notes/plans/17y-screens/b3/` (gitignored) | DONE — DEV-STORE Debug build (`io.lduarte.Variorum.debug`, DerivedData/17y; guards before every act; only my instance quit, by identity; the author's real-store app never touched), 1440×1000, LIGHT, **both voices** (Terminal first, then Study; Terminal restored). Every row USED, not mounted. **(r)** r1 the № panel open under the strip, right-aligned, no row moved · r2 a census solo · r3 Study. **(s)** s1 the starred solo · s2 All · s3 mid-drag hairline + after a drop on the word (the book starred) · s4 Study (the census reads the starred scope). **(l)** l1 the Starred section's book menu · l2 Unstar from it · l3/l4/l5 the Library row menu → Delete Book… confirm → gone · l6 Study menu · l7 Archive from the Library row → the book LEAVES the listing at once (W-2 fixed live) · l8 the Archived row menu (Unarchive in Archive's place) · l9 Unarchive from it. **(h)** h1 presence (accent + count) · h2 the popover rows · h3 a row's name OPENED the note (nothing seated) · h4 a gathering has no door · h5 calm (faint, no count) · h6 the popover at 600 pt, every arm whole (W-1 fixed live) · h7/h8/h9 Study presence, popover, calm. **(o)** o1 the chip popover · o2 the add picker · o3 the typed 'New book' row · o4 made + added, the receipt · o5 Study. **(g)** g0–g4 the rule builder's "+ tag" picker → filtered → the 'New tag' row → ⏎ made "#b3walk" (receipt "Made the tag #b3walk.", the term in the draft) · g5 the OUTFLOW chooser's "+ tag" (same control) · g6 Cancel (the rule unchanged; the tag stays — P-g2) · g7 Study. **(f)** f0–f2 a wing made via the switcher · f3 the Home notes' Open rows wear "Home" · f4 a note made in the wing · f5 its Open row clicked → "Now in Home." (Home's starred back) · f6 back → "Now in “b3 walk wing”." · f7 Open Beside a Home note → "Now in Home.", both panes open · f8 focus the other pane → "Now in “b3 walk wing”." (editors never closed) · f9 Study indicator. **(c)** c1 Duplicate as Version → c2 the copy wears #u4ring. **(d)** d1 List · Cards · Timeline · d2 Study. **(i)** i0/i1 "the door"'s outline + the "unfiled" group · i2 a move menu's "unfiled". **item 11** 11-0 the Journal (entry-date order) · 11-1 a sibling drop REFUSES, naming the order. THE WALK'S FACE DEFECTS, all FIXED in-batch: **F-B3-8** (r)'s first build drew the panel ABOVE the strip (9c71d582, the pin now measures the face); **W-1 = F-B3-9** the Arrivals popover truncated "Copy In" → "copy…" at 460 pt (9be3f9ba — 600 pt + fixed-size arms; a face row, its oracle the captures h6/h8); **W-2 = F-B3-10** a book deleted/archived from the Library row menu stayed listed (9be3f9ba — `BookRowDoors.onLanded` re-asks the one-shot catalog; pin `aBookArchivedFromTheLibraryRowLeavesTheListing` RED by a SYNTHETIC revert of the catalog's wiring (`w2-red.log`: 1 issue, the listing arm) → GREEN restored (`w2-green.log`, "38 tests in 3 suites passed" with the registry walk); the first form of the pin (9be3f9ba) asked the catalog by hand — hollow on its catalog arm, replaced). DEV-STORE STATE AFTER THE WALK (restored except the Trash): live state as found — voice Terminal, appearance follow-system, the census open as at the start, "the door"'s rule unchanged, "dream journal" starred→unstarred, "field notes" archived→unarchived, both walk wings deleted (empty), #b3walk deleted; IN THE TRASH (30-day, recoverable, deliberately not purged): the minted "b3 mint walk" book, the wing walk note, the Duplicate copy "u4 delta". On screen and left alone: the macOS "quit unexpectedly — OK / Reopen" dialog from F-B3-3's test-host crash |
| 14 | Record close (first line, findings, PROVISIONALs → QUESTIONS #185) | DONE (this commit) — the NOT-DONE first line; findings F-B3-1…12; the PROVISIONALs unchanged since #185 landed (dc371169) — the walk fixes made no product decision |

**REVERT STATE: NO REVERT IN FLIGHT.**

**Red-on-old method (every bug-class row):** each pin is committed AHEAD of its fix and run on that
pre-fix committed tree (the natural red, the B2 precedent); the fix commit follows; no synthetic
revert is in flight at any time.

### THE TAG-PICKER ADOPTION LIST (R-17y-3 — enumerated, not built; each adopts `SearchPicker` at its next touch)

The ruled three adopted it in B3: the rule builder's "+ tag" (incl. the Create Gathering mint sheet,
which shares `RuleTreeEditor`), the outflow chooser's "+ tag", and (o)'s add-to-book door. Every
other picker that lists tags today, located:
1. the rule builder's **"+ group ▸ all of… / any of…" seed submenus** (`RuleEditor.swift`
   `RuleTreeEditor.seeds`) — every term again, flat;
2. the **spawn sheet's outflow chooser** (`BookOrderAndConversion.swift` `SpawnBookSheet` → the
   shared `OutflowChooser`) — SEARCHABLE already (it is the same view), create-in-place withheld
   (`onCreate` nil — its `SpawnOffer` holds a fixed tag list);
3. the Library's bulk **"Tag N notes ▸" / "Untag N notes ▸"** menus (`LibraryCatalogView.swift`);
4. the Blocks workbench's bulk **"tag ▾"** (`BlocksWorkbenchView.swift`);
5. the Canvas **tag filter** menu (`CanvasView.swift`);
6. the Snippets **block-tag menu** (`BlockTagViews.swift`) and the Snippets group menus
   (`BlocksAreaView.swift`);
7. the book Index's **filter bar "by tag ▾"** (`BookFilterBar`) and its **"group ▾"** tag families
   (`BookIndexGrouping.swift`);
8. the note's own tag doors — the **masthead tag cluster** (`MastheadTagCluster.swift`, typed path +
   list) and the **tag sheet / chips** (`TagViews.swift`, `NoteTagChips.swift`) — already typed-path
   capable, not yet the shared control;
9. Settings ▸ Tags (`AppSettingsView.swift`) is a MANAGEMENT list, not a picker — listed for
   completeness, no adoption owed;
10. **the phone's** tag pickers — MOBILE PARITY (record only).

### THE TRACE — item 11 (F-B2-7), before the fix

`BookView`'s navigator rows and Outline's post rows both drop through ONE dispatcher,
`BookStructureModel.acceptDrop` → `.post(postID)` → `filePost(…, reposition:
repositionsOnDrop(viewOrder:))`. `repositionsOnDrop` is false whenever the order she is looking
through (the view-local `viewOrder`, else the stored `sort_field`) is not Manual, and
`postDropPlan` then drops the `before` anchor (its own doc: "silently rewriting it from a drop would
edit an order she cannot see"). A note dropped onto a SIBLING in its own chapter (or onto its own
chapter's heading) therefore resolves to `.file(the chapter it is already in, before: nil)` →
`assignPostToSection` to that same chapter: no row changes, `run` clears `lastError`, nothing
speaks — under a hairline that promised "a dropped row lands right above this one". The Book
Panel's identical gate was B2's (e) (`BookPanelBrain.dropOutcome`); its two orderings (lock first,
satisfied = nothing) were settled by B2's ladder. Measured by the red pin on the pre-fix tree:
`lastError == nil` for a real re-place under Created ↓.


### THE TRACE — (r), before the fix

`ShelfView`'s body is one VStack: masthead · strip · `if model.censusOpen { HStack { Spacer;
BookcaseCensusPanel } }` · the board's ScrollView (`maxHeight: listContentHeight`) · the entry bar ·
the hint bar. 13i-d U1 put the panel IN FLOW there (P-13id-U1-6 — "opens IN FLOW under the strip
(mockup v5)"). Opening it inserts its whole height between the strip and the board: every row moves
down (measured by the red pin: **148.0 pt**), and in a window whose height is already spoken for the
ScrollView shrinks under it and clips its first row at the top edge — her capture's half-drawn
"u4 owned". The fix changes only the layout mechanism (an overlay hung from the strip); the
supersession of U1-6's "in flow" letter is her (r) report's.

### F-B3-3 — THE FIRST END RUN'S TEST-HOST CRASH (found, reproduced, bisected; this batch's trigger removed; the latent class is the orchestrator's)

**What happened:** the first full Mac run (`end-mac.log`) CRASHED the test host mid-run — `Fatal error:
Could not open the Variorum database … io.lduarte.Variorum.debug/…/variorum.sqlite … SQLite error 26:
file is not a database` — i.e. the test process tried to OPEN THE DEV STORE through
`AppDatabase.liveValue` (the decrypt failed without the key, so nothing was read or written; the
dev store is verified to open on the walk). xcodebuild restarted the host and finished: "3587 tests in
590 suites passed … with 6 known issues", `** TEST FAILED **` naming
`AscentDoorTests.theFoldIsOneDeclaredActWithOneKey()` (the issue landed in its window).
**The backtrace** (`~/Library/Logs/DiagnosticReports/Variorum-2026-10-05-081254.ips`, faulting
thread): `SavepointOnLeave.wire(workspace:session:)`'s closure → `AppSession.savepointOnLeaving` →
`Operations.closeAutoCommit` → `Operations.database` → `@Dependency(\.database)` with no override in
the CURRENT task-local context → `liveValue`. **Bisected** (54-suite population = every test file up
to `BookAscentTests.swift`): the current tree CRASHES deterministically; without the mint suite it
still crashes; without B3's two new suites it does NOT; the PRE-B3 tree (`0dafa1b1`, a `git archive`
snapshot in the gitignored scratchpad, its own DerivedData) does NOT ("303 tests in 51 suites
passed"). **The trigger was B3's own pin** `ArrivalsDoorPlacementTests.aRowsNameOpensTheNoteAndNever
SeatsIt`, which POSTED the app-wide `.variorumOpenPost` broadcast: a shell standing in the test host
adopted the note, and the later `AscentDoorTests` broadcast (`.variorumOpenBookAtPost`, pre-existing)
made that shell's pane LEAVE the note — the leaving signal ran `closeAutoCommit` in the posting test's
dependency-less context. **Fixed (58bdeb0d):** the open road's broadcast is captured at a seam
(`BookArrivalsList.openNote(_:post:)`), the books-only condition pinned at `BookArrivalsDoor.isDrawn`
(no whole book views mounted); the population re-ran **313 tests / 53 suites, zero crash**.
**INFERRED, not proven — the standing shell:** only `AscentRoutingTests` mounts a RootView in that
population and it had not yet started, so the receiving shell is most likely the test host app's
OWN window over a session a bootstrap pin published (`AppBootstrapOffMainTests` builds
`AppBootstrap(testOpener: { .success(database) })`, whose `AppSession` is created inside the
bootstrap off any test's dependency scope). **The latent class (owner: the orchestrator — a 19-ledger
item):** any pin that posts an app-wide navigation broadcast (`AscentDoorTests` does today) can drive
that standing shell, and any note departure there reaches `@Dependency(\.database)`'s LIVE value —
the test host attempting to open the developer's dev store. Candidate shapes: the test host never
shows a shell over a bootstrap pin's session; or `AppDatabase`'s `testValue` fails loudly WITHOUT
opening any file; or the broadcast pins capture at a seam as B3's now does.

### FINDINGS (for the orchestrator)

- **F-B3-1 — lesson 4 still names the retired "at the door" line** (`TutorialSeeder` — "waits at
  Arrivals — the book's “at the door” line —"). Seed CONTENT, fenced from B3; the spine pin
  `TutorialBooksChapterTests.lessonFourArrivals` carries it as a `withKnownIssue` that FAILS the
  moment the prose is re-worded (so the fix must remove the wrapper). **Suggested owner: B-DEDUPE**
  (the same seeder file and reviewer; its R-17y-8 lesson sentence and MAJOR-2's Canvas lesson ride the
  same re-seed consequence).
- **F-B3-2 — the ARCHIVED line still stands atop the book's content** (13i-d U4: "N archived" on
  Index/Outline/Book, the Arrivals line's old idiom, directly under where the door's line was). (h)'s
  ruling moved the ARRIVALS door only; whether the archived line follows it into the masthead is hers
  (13s, or a later 17/19 item).
- **F-B3-3 — the test-host crash** (the section above): B3's trigger fixed; the latent class routed.
- **F-B3-4 — the move menus still offer "unfiled" to a note already unfiled** (a silent no-op — the
  other half of her (i) confusion). (i) ruled the WORD; omitting the current destination (the
  Bookcase's Move to Shelf ▸ precedent) is a behaviour no ruling makes — hers if wanted.
- **F-B3-5 — the Arrivals door's observation now runs whenever a book is open** (every mode — the
  door is the masthead's), where the line's ran only on Index/Outline/Book; it is bounded by the
  book's pair rows (13i-b F-U2-5's P1 statement, unchanged) and re-fetches at autosave rate while the
  book view shows (the same class).
- **F-B3-6 — the Open-row wing indicator is a one-shot read** keyed on (rows, current wing): a note
  MOVED to another wing while open shows its new wing at the next key change (a switch, a row
  opened/closed), not at the move itself.
- **F-B3-7 — the note-only window does not follow** (its workspace is not wired — `showOnly`, no
  history); recorded as P-f5.
- **F-B3-8 — FIXED (9c71d582)** (r)'s first build drew the panel above the strip; the push-only pin
  was green while the face was wrong — the pin now measures the face (row 5).
- **F-B3-9 (walk W-1) — FIXED (9be3f9ba)** the Arrivals popover truncated an owned book's "Copy In".
- **F-B3-10 (walk W-2) — FIXED (9be3f9ba + the close commit's honest pin)** the Library listing kept a
  book removed from its own row menu.
- **F-B3-11 — the add picker is a popover opened FROM the chip's popover**; macOS anchors it left of
  the "Add to Book" word, so it overlaps the chip popover's footer sentence while open (o2/o5).
  Legible and dismissable; a face call for 13s (e.g. swap the chip popover's content for the picker
  in place).
- **F-B3-12 — the open № panel floats over the entry bar's right end in an EMPTY wing** (f-walk,
  Study) — P-r1's float-over-content letter, met where the board has no rows; recorded.

### PROVISIONALS (QUESTIONS #185 carries them, in her words)

- **P-17y-B3-c1** a duplicate's riding tags are a ROW copy — no living book hears the duplicate (the
  copy family's letter). (a) BUILT · (b) an applying act: books whose rule names the tag take the
  duplicate in (or bell it at Arrivals).
- **P-17y-B3-i1** "unfiled" is lowercase in the move menus too (the headers' case). (a) BUILT · (b)
  "Unfiled" in menus.
- **P-17y-B3-11a** the book view's sort refusal speaks on the book view's own error line (where its
  finished/sealed refusals already speak), naming the order she is LOOKING through. (a) BUILT · (b)
  the toast, like the Book Panel's.
- **P-17y-B3-r1** the open № panel floats OVER the first rows' right ends (their meta hidden while it
  is open). (a) BUILT · (b) a popover arrowed at the №.
- **P-17y-B3-s1/s2** (the ruling's own provisionals) the starred row sits right after All, always
  shown, the bare lowercase word "starred"; its hover "Every starred book, wherever it's shelved —
  drop a book here to star it". **s3** no hand placing on the starred shelf (no ⠿, no row drop, no
  Send to Top/Bottom — a hand position belongs to a real shelf). **s4** + New Book while looking at
  starred lands unshelved and UNstarred. **s5** a drop is one-way and silent (already starred:
  nothing; the cap's refusal speaks); a shelf name dropped there does nothing; the word has no
  right-click menu. **s6** gatherings join books there (the union star covers both).
- **P-17y-B3-l1** the menu beyond the Bookcase (Library book rows · Starred book rows · Archived book
  rows): Open · Star/Unstar · Book/Gathering Settings… · Export Markdown… · Export PDF… · Archive
  (Archive… on an owned book) or Unarchive · Delete Book… (never the daily Journal). (a) BUILT · (b)
  the full Bookcase menu minus the positional doors · (c) Star alone.
- **P-17y-B3-h1** the door: a tray icon beside the gear — faint with no count when calm, the accent
  and the count when something waits; BOOKS only (a gathering has none). **h2** it rides every book
  mode, Read included. **h3** the finish confirm's and the wing move's sentence: "N waiting at
  Arrivals will be dismissed." **h4** the popover's words ("Arrivals · 3 waiting"; "Nothing is
  waiting. When this book's rule brings in a note and its dial says “wait at Arrivals,” the note
  waits here for you."). **h5** a row's name opens the note in the pane she is in (the popover
  closes).
- **P-17y-B3-g1** the picker: a popover — search field, matches, a 'New tag "#x"' row; ⏎ takes the
  first match, else makes the tag. **g2** a tag made in the rule editor is made AT ONCE (Cancel keeps
  the tag, like a tag typed on a note) — (b) make it only on Save. **g3** the create row offers only
  a path no tag of the book's wing wears (case aside); "/" makes a hierarchy. **g4** the spawn
  sheet's chooser searches but does not make tags yet; the "+ group" seed menus stay flat (the
  adoption list).
- **P-17y-B3-o1** the note's Add to Book door is ALWAYS drawn (with no other book, it makes one).
  **o2** the made book is born in the NOTE's wing. **o3** a made book STANDS if the add then asks
  copy-in/move-in and she cancels — (b) undo the mint on cancel. **o4** the receipt "Made the book
  “X” and added this note." **o5** the Pool's Add to Book sheet gains the same create row, atop the
  matches.
- **P-17y-B3-f1** the receipt: "Now in “X”." / "Now in Home." **f2** re-opening the note already
  shown (an Open row click) is followed — an open is an open. **f3** BOOKS follow too (a book
  reached in another wing — back/forward — switches the wing like a note) — (b) notes only. **f4**
  the indicator: the wing's name, faint, after the Open row's title, hover "In the wing “X” —
  opening it takes you there". **f5** the note-only window does not move the wing.

### MOBILE PARITY (record only — nothing built)

- (c) is core — the phone's duplicate door (none today) would carry tags for free.
- (f) the phone stands in Home with no wing face (U5's parity facts) — the follow and the indicator
  are the mobile catch-up's, once it has a wing switcher.
- (o)/(g) the phone's add-to-book and tag pickers adopt the one idiom at its catch-up (`SearchPicker`
  is Mac chrome; its BRAIN `SearchPickerBrain` is the shareable half — hoist at that touch).
- (h) the phone has no Arrivals face yet (13i-b's mobile row stands); the ONE word "Arrivals" binds
  it when it lands.
- (s)/(l)/(r)/(i)/(d)/item 11 — Mac surfaces; the phone has no Bookcase strip, no book-row menus off
  a Bookcase, no census panel, no Cards view; "unfiled" binds any phone chapter face.
- The one Shared/ change: `BookcaseBoard` (the `.starred` scope + section kind + the scope-aware
  `placesByHand`) — the phone compiles it and calls none of it (the phone build, row 12).

### SEAM NOTE (for the review cast)

No `Sources/VariorumCore/Sync/`, no schema, no custody, no editor seam (`EditorTextView`,
`BlockRangeIndex`, `PaneSurface`, the read tier untouched — the book view's MASTHEAD and its
structure model's drop brain are chrome/model, not the text seam). Core touched ONCE, for (c):
`Operations+Versions.swift` (`duplicateAsVersion` rides `copyLiveTags`) and the helper's visibility in
`Operations+Ownership.swift` — an operation's row transition, pinned in core. One DEFAULT's meaning
moved under her rulings: (f) the app's current wing now follows the focused pane (R-17y-…/#174's
ruled shape). Expected cast: `opus-reviewer`; the orchestrator may re-cast to Fable for (f)'s
default-meaning change.

## 17y B-DEDUPE RECORD — the whole-set seed-duplicate fold (THE ORCHESTRATOR'S OWN IMPLEMENTATION, 2026-10-05; LIVE STATUS from the first commit; the binding design is `notes/plans/17y-bdedupe-design-memo.md`)

**Preflight (this session, post-compaction, all read whole):** SyncSpec · the postmortem ·
`SampleLibraryDedupe.swift` · the Welcome/daily keepers in `Repairs.swift` · the seeder's
Book/facts grammar · the three gatherings' + quicknote's + guide's mint shapes ·
`LaunchFurniture` · `TouchedRows` + `runPostApplyRepairs`'s order. The memo binds; R-17y-5/8
+ the B2 ladder's MAJOR-2 re-own + the B3 ladder's F-B3-1 re-own are the scope.

### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 1 | This record + the RUN RECORD flips (B3 closed; B-DEDUPE building) | DONE (this commit) |
| 2 | R-17y-8 — Jekyll leaves the default seed: `Book.launchSet` + `LaunchFurniture` iterates it; pins red-on-old (a fresh launch seeds no Jekyll; Restore still mints; existing stores untouched) | DONE (20439eaa red · d8aa90e0 fix) — **both platforms**: the phone's first-write Jekyll seed removed too (the zero-mobile fence's RECORDED EXCEPTION — her ruling names people's libraries, and a phone-seeded Jekyll re-arrives everywhere by sync; the mobile pin flipped to the new contract as a justified edit). Mac pin RED 1 issue → green; REVERT ROUND: the loop back to `Book.all` → RED the same 1 issue → restored, `git diff --quiet`. Mac seeder family 104/12 · mobile 12/1 (a fresh iOS-26.2 simulator device minted for the run — none existed on this Mac) |
| 3 | The guide's seed-content trio (ONE re-seed consequence): the mode-row sentence derives from the (p) seam + the Canvas lesson gates on `buildKeepsCanvas` (B2 MAJOR-2) · lesson 4's "at the door" → the Arrivals word + the `withKnownIssue` wrapper removed (B3 F-B3-1) · the books-chapter Jekyll-restorable sentence (R-17y-8); pins red-on-old per leg | DONE (9c0da7d6) — ONE pure pair (`modeRowSentence` + `lookingLessonContent`) read by the mint AND the plan, both flavors pinned (`TutorialBuildFlavorTests` 5; the keySpan arm red against the old literal's "⌘1 through ⌘7"); the classics walk teaches with what stands (the GUIDE is the plain-book example) + her intake's Jekyll-restorable sentence naming the Restore door; lesson-suite justified edits EXECUTE the new claims (guide-holds-members; restored-Jekyll-joins-the-gathering); spine 98/13 green |
| 4 | `Sync/` — `SeededFurnitureDedupe.swift` (the facts + the pairwise-identity classifier + the four-grain pass + the one-shot marker) + `TouchedRows.containerIDs` + the `runPostApplyRepairs` wiring (after the Welcome keeper) + explicit outbox rows | DONE (5addd5cf core · 8fbb322e the F2 arms) — the suite's build caught TWO gaps the first cut lacked and the pass GAINED them: the F2 quiescence arms (an arrived-this-batch copy defers its grain; a never-seen shelf row defers the gathering grain) and the empty-window re-fire reading the furniture marker (SyncEngine). The near-loss recorded honestly: a `git checkout HEAD` restore after revert round A destroyed the uncommitted F2 edits (the protocol's own never-checkout-over-uncommitted warning, relearned); re-applied from context, committed at once |
| 5 | The facts wiring at the ONE shared site (+ the Mac's guide half; the phone wires the shared half only — the pocket guide is the MOBILE PARITY row) | DONE (5addd5cf) — `SampleLibrarySeeder.furnitureDedupeFacts` (the shared half reading the mints' own constants) · `TutorialSeeder.furnitureFactsHalf` + the `twinTitle` constant (the Mac's) · `AppServices`/`SyncSession.configure` plumb · the posture DRAIN engine's F2-parity shared half (a guide pair met during a ceremony drain folds at the regular engine's next book-touching pull — the recorded corner) |
| 6 | Convergence suites (two-client fake server, the memo §4 matrix) + idempotence + inert-arm | DONE (8fbb322e) — `SeededFurnitureDedupeTests` 9/9: the trio fold (keeper rules resolve LIVE by path on both devices; the designation converged), the staged rule re-point + designation re-point with outbox rows, engagement-per-axis keeps both, the quicknote/guide/pool folds under the F2 cadence (defer → marker → the empty window decides; outbox asserted PRE-push), the edited-UNCHOSEN-take keeps both (the skeleton's load-bearing arm), idempotence (an extra pull: 0 applied 0 repairs), nil-inert. REVERT ROUNDS: A (take texts off the skeleton) → `anEditedLessonKeepsBothGuides` RED both arms — the forbidden retire caught; B (the guide F2 arm off) → the deferral pin RED (an arrival-batch fold); both restored, `git diff --quiet`. **CORRECTED AT THE LADDER'S ROUND 1 (honest record):** this row's original "engagement-per-axis" overclaimed — the round-1 suite covered 2 of ~10 gathering axes and a SYNTHETIC guide that concealed the BLOCKER (the shipped guide's word target/comment/seal read ENGAGED and never folded). The FIX ROUND's suite is 16 tests incl. the SHIPPED-shape fold, the real-seed Mac drift guard, and the comment/savepoint/rename/removed-member/straggler/designation arms — the ladder record carries the full list |
| 7 | END: the touched families + the whole-Mac run (covers B3's post-END gap) + the tutorial spine + the phone build | DONE — core WHOLE **2188/246 passed** (`swift test`, the 9 new convergence tests included); the WHOLE-MAC run **3896 tests in 639 suites** with 5 standing knowns (4 IndexTierMetrics + 1 TakesFind; F-B3-1's withKnownIssue correctly OFF) and ONE real red — `DeadVocabularyTests` caught the retired phrase "shelf row" in the NEW Sync file's own comments (a database-row sense, but the scan is spelling-level): reworded to "`shelf` record", the scan re-run green 2/2, the convergence suite re-run green 9/9 (comment-only; the whole-Mac is green-with-that-fix, not re-run whole for a comment); the tutorial spine 98/13 (piece 3); the phone: BUILD SUCCEEDED + `MobileFirstWriteFurnitureTests` 12/1 at END |
| 8 | Record close; PROVISIONALs → QUESTIONS; the fresh fable-reviewer cold round follows | DONE (this commit) — QUESTIONS **#186 (a)–(f)** in her words (the pairwise road; stale-meets-fresh; engagement axes; the designation's re-point-only; the drain corner; the phone fence exception). MOBILE PARITY (for the close's line): the pocket guide's own facts entry is ONE wiring line on the phone once its engine road exists — recorded, never built here. The FABLE cold round on this diff is next (zero framing; the orchestrator never hand-reviews its own Sync/ work) |

## 17y B1 RECORD — the two performance items: (j) the in-note Index scroll · (k) the Library infinite scroll + the All-screen books cap (`opus-implementer`, 2026-10-05; LIVE STATUS from the first commit; the brief is `notes/plans/17y-b1-brief.md`)

**NOT DONE (first line, per the contract — kept current):** EVERYTHING below is in flight; HER live scroll walk on the large fixture + her word is the batch's (and the 17y entry's) close gate and is NOT this session's to run; the Fable cold review follows this record's close (the orchestrator spawns it).

Preflight read in this session's own context (never delegated): CLAUDE.md + its auto-loaded canon;
the B1 brief whole; this file's 17y row end to end (items (j)/(k) verbatim, her smoothness bar), the
kickoff, the RUN RECORD, the B3 RECORD whole (the (d)/(l) notes: "Cards", `BookRowMenu` on the
Library's List-mode book rows); `notes/plans/17y-sitting-rulings-2026-10-05.md` whole;
`notes/SessionResiliencyProtocol.md` whole; `notes/TEXTKIT2_NOTES.md` whole (§2–§3 and every
macOS-27 measured finding); KnownIssues rows 22/49/61/87/90; AppSpec §7 (the three container stamp
indexes + the ordering conventions); `LibraryCatalogModel` + `LibraryCatalogView` +
`LibraryListingReads.swift` + `LibraryCatalogTagActs.swift`; `Queries.searchCatalog` /
`catalogPostsSQL` / `LibrarySort` / `timelinePage` / `library`; `ReadModeView`, `ReadEditPane`,
`NoteIndexColumn`, `ReadNoteLanding`, `LandingAuthority`, the book Index pane (`BookIndexView`'s
F3 shape). Worktree `~/dev/variorum-17y` only; DerivedData `App/Variorum/DerivedData/17y/`; no
subagents. QUESTIONS' next free number at preflight: **#187**.

### LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 0 | This record + the b1 captures dir gitignored | DONE (this commit) |
| 1 | (j) TRACE — measured, mechanism stated HERE before any fix; the book Index checked | DONE (this commit) — § THE TRACE below: M1 (the column: a whole-note lookup per realized row + three AppKit controls per row) is her lag; M2 (the pane's 4.7× lazy estimate) recorded; re-query storm and landing re-aims ruled OUT. The temporary instrumentation is REMOVED from the tree in this commit (kept as the gitignored `b1trace.patch` for the after-measurement) |
| 2 | (j) pin red-on-old → fix → green | DONE (20433ebd red · 15b081d2 fix · f8977039 refined) — § THE FIX below. Pins `NoteIndexColumnScrollCostTests` (5) RED on the pre-fix tree (`j-red.log`) → GREEN; SYNTHETIC REVERT ROUND (announced c1043df3): A — the wake rule forced live → the resting-rows pin RED "213 of 426" + the wake pin RED; B — a whole-note lookup back in the row builder → the lookup pin RED "realizing 426 rows built 416 whole-note lookups"; restored, `git diff --quiet`. Paired before/after measured (below). The pre-fix worktree `<scratchpad>/wt-before` (90eb3416 + probes) is KEPT for (k)'s before-measurement — removed at the close |
| 3 | (k) the large-fixture road (dev store, staged + restored) | DONE (90eb3416) — `ScaleFixture.swift` (DEBUG + `VARIORUM_SCALE_FIXTURE`) + `Tools/ScaleFixture/stage.sh` / `restore.sh`. **THE DEV STORE IS STAGED NOW** — prestage copy `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261005T190622Z` (cmp-verified); a successor RESTORES it (`Tools/ScaleFixture/restore.sh <that dir>`, the DEV app quit first) before closing. ALSO STAGED: the dev app's local `readFace.<id>` defaults — six notes flipped `read`→`edit` for the trace; the originals are listed in this row's restore note: 4A5B8D9A…, 4EBE2134…, CDFD73E1…, D39B34A7…, D42DDB29…, D5AA052C… were `read` (67DB6BCA…, 6D00EAC7… were already `edit`) |
| 4 | (k) core: the keyset page read per sort + pins | DONE (2a203573) — `Queries.catalogNotesPage` (`Sources/VariorumCore/Queries/LibraryPaging.swift`): each sort's own `(key, id)`, never OFFSET, one statement + a probe row; EDITED seeks `idx_container_touched` in two arms (`INDEXED BY` — this store never runs ANALYZE; measured 22,729 → 4,409 VM steps for one page over 600 notes); created/date/title one bounded top-N pass per page (flat in depth, ∝ notes; no index holds their keys — § THE (k) NUMBERS). `searchCatalog`'s book/block arms factored out byte-for-byte (`catalogBooks`/`catalogBlocks`) + one LIKE-escape. Pins `LibraryPagingTests` (8) incl. the held facts' region blind to a keystroke; the catalog-adjacent core suites 115/16 green |
| 5 | (k) the model: pages, refresh-in-place, bounded held observation + pins | DONE (837edc3a WIP · 5729584a) — `LibraryCatalogModel` (books · paged notes · capped blocks; `search` = a first page, `refresh` = in place at depth for every row act) + `LibraryCatalogPaging.swift` (row appear/disappear → the next page within 30 rows of the end; the NEAR WINDOW = the pages around what is on screen, quantized to page boundaries, the only part whose extras load and whose ownership facts the MODEL holds; window checks coalesce to one per turn AFTER the layout — a window the views READ fed back into the Cards' lazy layout). Pins `LibraryPagingModelTests` (6, build pins — the pre-fix tree had no paging); three cap pins in `LibraryDayFilterTests` flipped as JUSTIFIED EDITS (the cap became a page) |
| 6 | (k) the views: List + Cards infinite scroll; the All-screen books region cap + pins | DONE (837edc3a · 5729584a · 511c1df8) — both views page by their rows' appear/disappear with a quiet sentinel row ("loading more notes…" only while a page is in flight); under All, books past half the listing's height split into their own List capped at half (`LibraryBooksRegion`, the List's measured row pitch). Mounted pins `LibraryInfiniteScrollTests` (3) RED on the pre-fix worktree (`k-red2.log`: List + Cards "listed 40 of 130"; no note row beside forty books) → GREEN. THE WALK FOUND (fixed, pinned): the Cards view's quiet tag row pegged 100% CPU under a resting pointer (PRE-EXISTING since 13e E8) — `NoteTagsRowHoverTests` |
| 7 | Measurements (before/after, quiet machine) + the walk → `notes/plans/17y-screens/b1/` | IN-PROGRESS — (j) paired before/after DONE (§ THE FIX); (k) the core scale table DONE and the in-app page-landing measurements started (§ THE (k) NUMBERS); 2f26fff2 landed the one-update page + the isolated paged view; **HELD at 15:40 MDT: the machine went ACTIVE (HID idle 0 for minutes — the guard's exit 4: someone is at the machine) — no GUI act and no window-mounting test run until it is quiet**; the prefetch-margin experiment (does an earlier append avoid the stall) is next |
| 8 | END suites + record close (findings, PROVISIONALs → QUESTIONS #187) | NOT-STARTED |

**REVERT STATE: NO REVERT IN FLIGHT.**

### THE TRACE — (j), MEASURED, BEFORE ANY FIX (the mechanism; the book Index checked)

**The bed.** The DEV-store Debug build (`DerivedData/17y`), the fixture's long note (2,000 blocks ·
13,713 words — a long-paragraph opening, then mostly one-line dialogue, a `# Part N` heading every
100 blocks) and *A Scandal in Bohemia* (262 blocks); Read ▸ `edit` (the editable index surface) with
the `▸ 01` column beside it. Driven by a phased TRACKPAD fling (`fling.swift`: began · changed×N ·
ended · a decaying momentum tail, posted at the HID tap), the WalkKit line-wheel, and real scroller-
thumb drags (`cliclick`). Measured by TEMPORARY in-process instrumentation (never committed; kept as
`notes/plans/17y-screens/b1/b1trace.patch`, gitignored): every `onScrollGeometryChange` of both
scroll views, every row/body evaluation, every `observeBlockTOC` delivery, the landing's LAND/AIM,
each whole-note lookup's duration, and a DISPLAY-LINK FRAME PROBE on the window (the main thread's
true frame cadence + every NSScrollView's clip offset per frame). Debug numbers; the SHAPE is what
binds.

**What she scrolls is the COLUMN.** The app's own words call it the note's index (the `outline`
toggle's help: "The note's index beside the page"); the pane beside it is smooth. Measured on the
2,000-block note, a cold trackpad fling:

| surface | frames during the fling | mean frame gap | max | notes |
|---|---|---|---|---|
| the `edit` PANE (LazyVStack of blocks) | 110 | 8.0 ms | 17 ms | smooth — zero DB reads, zero body re-evaluations; only the realized rows' bodies |
| the `▸ 01` COLUMN (LazyVStack of index rows) — shipped | **5** | **184–217 ms** (3 cold runs) | **391 ms** | ~5 fps; distance LOST under the stall (six identical slow flings travelled 8,523 pt shipped vs 19,588 pt with the cost removed); single-frame leaps of 4,000+ pt |

**M1 — THE LAG (ruled IN; the column).** During a column fling there are ZERO column body
re-evaluations, ZERO pane row bodies, ZERO `observeBlockTOC` deliveries (counted) — the whole cost
is per REALIZED ROW, and it has two parts, isolated by A/B arms in the same build (env-switched,
cold relaunch per run, alternated):
1. **A whole-note lookup per realized row — P1's letter.** `NoteIndexColumn.rowsByID` is a COMPUTED
   `Dictionary` over EVERY row of the note, and the row builders call it (`blockRow`, `sectionRow`,
   and the row's `⋯` menu content) — measured 698 builds in one fling, **626 µs each at 2,000
   blocks (437 ms of the fling)**: per-frame cost ∝ (rows realized) × (note size).
2. **Three AppKit-backed controls on EVERY row** (`↑` `↓` buttons + the `⋯` `Menu`), built for every
   realized row though each rests at 25 % opacity until hovered — P3's shape broken (only the
   focused thing is heavy).

| arm (cold fling, 2,000 blocks) | mean frame gap |
|---|---|
| A — shipped | 184 · 217 · 217 ms |
| B — the lookup built once (cached) | 113 · 125 · 127 ms |
| D — B + no `Menu` (buttons kept) | 70 · 84 ms |
| C — B + no row controls | **10.9 · 11.3 ms (smooth, 80 frames)** |

**"A quick scroll sends you straight to the top" — NOT reproduced literally; the measured mechanism
is the same stall.** At 5 fps a flick's whole momentum lands in one or two frames (measured: an
upward flick from 33,499 pt reached the top in three frames: 33,499 → 16,399 → 1,999 → 0), and
under the stall scroll distance is dropped or coalesced unpredictably — the page moves in leaps the
hand cannot steer. Removing M1's cost removes the stall the leaps ride.

**M2 — the PANE's estimate (ruled IN as the F3 class; NOT her lag; recorded, not fixed here).** The
pane's `LazyVStack` gives SwiftUI no row heights, so unrealized rows stand at the average of the
realized ones: on the 2,000-block note the content height starts at **334,824 pt for a 71,389-pt
note (4.7×)** and collapses as rows realize (334,824 → 83,917 inside one fling). Trackpad scrolling
stays smooth (above), but the scroller THUMB rides the estimate: a quick thumb drag throws the page
far past the hand (measured: a 192-pt upward drag, ~23 % of the track, moved 102,154 → 33,408 pt as
the estimate collapsed 159,979 → 74,406), and the first big jump hitches 248–837 ms. Its remedy is
the F3 shape (heights known before the aim — `ReadNoteHeights` already derives them), a read-tier
build of its own; filed as a finding with an owner (below), never "also done".

**Ruled OUT by measurement:** a scroll-driven re-QUERY storm (zero `observeBlockTOC` deliveries and
zero body re-evaluations during every fling; deliveries arrive only at autosave cadence); the
landing's jump-correction re-aiming against her scroll (every fling, wheel scroll and thumb drag
reported `phase=interacting` first, which ends any landing — `landing=0` on every frame of every
scroll; zero AIMs during scrolls).

**The book Index — shares HALF of M1.** Its navigator (`BookIndexView.column` → `BookIndexNoteRow`)
builds ONE AppKit `Menu("⋯")` per realized row (no `↑ ↓`, no whole-book lookup), over at most the
300-note window — the control half's class at one third of the per-row weight (arm D − C ≈ the two
buttons; B − D ≈ the menu). Its pane is the F3-fixed shape (13u4 UNIT F3). Recorded as a finding;
not this batch's surface.


### THE FIX — (j) (15b081d2 + f8977039; `NoteIndexColumn.swift` only)

1. **Each flattened column row CARRIES its TOC row** (`ColumnRow.toc`): the whole-note lookup is
   built ONCE per body (in `columnRows`, beside the ONE outline walk the header and rows now share)
   and never by a row builder — a realized row costs what it shows (P1).
2. **Only an AWAKE row builds the live `↑ ↓ ⋯`** — the SELECTED row always; the HOVERED row only
   while the column is still (`NoteIndexRowWake.isLive`, the column's observed scroll phase
   `NoteIndexScrollPhase`, read by the rows, never by the column's body). Every other row draws the
   resting hint as ONE cached image per ink (`RestingRowControls.hint` — drawn once with
   `ImageRenderer`, keyed by the ink's sRGB components) at the live set's MEASURED footprint, 79 × 13
   pt; the live set draws at its own size inside that footprint, so waking a row never moves it and
   every title truncates exactly where it did (captures `j-before-*` / `j-after-*` — the titles
   truncate at the same glyph; the resting bezels a shade lighter: PROVISIONAL P-17y-B1-j1).
3. **Why the refinement (f8977039) — measured, not assumed:** the first fix (15b081d2) removed the
   lookup and drew the hint as views, and the after-measurement still read ~45–50 ms a frame. Arms
   on that tree isolated two more per-frame costs: the hint drawn as SwiftUI views (~20 ms — an image
   is ~free) and rows WAKING as the scroll carried them under a resting pointer (~20 ms — the live
   controls built and torn down per passing row). Both are gone in the shipped shape.

**THE NUMBERS (paired, INTERLEAVED, the dev-store Debug build, the 2,000-block note, a cold trackpad
fling of the column with the pointer resting over it; machine load 2.7–5.6 on 12 cores, her app
not running).** BEFORE = the pre-fix tree (90eb3416) + the same measurement probes, built in a
worktree; AFTER = f8977039 + the probes. Logs `BEFORE*.frames` / `AFTER*.frames`.

| run | frames | mean frame gap | max gap | distance the same fling travelled |
|---|---|---|---|---|
| BEFORE 1 · 2 · 3 | 2 · 5 · 5 | 208 · 178 · 189 ms | 316 · 392 · 354 ms | 2,400 · 7,450 · 8,029 pt |
| AFTER 1 · 2 · 3 | 79 · 68 · 82 | **11.3 · 13.7 · 11.1 ms** | 25 · 30 · 25 ms | 13,699 · 15,317 · 14,218 pt |

The fling is now at display cadence (the same 11 ms as the column with NO controls at all — arm H)
and travels its whole distance: the stall the "quick scroll" leaps rode is gone. The row under the
pointer wakes the moment the scroll stops (`j-after-wake-after-scroll.png`).

### THE (k) DESIGN (4–7; the binding item text is the 17y row's (k) cell — her launch blocker + her smoothness bar)

- **The page read** (`Queries.catalogNotesPage`, core): keyset on each sort's own `(key, id)` — never
  OFFSET, never a raised cap; one statement per page with a probe row (another page follows, never a
  count). The EDITED sort (the default) seeks the timeline's own `idx_container_touched` in two arms
  (touched notes from the cursor; never-touched notes — no block ever written, NULL stamp — by their
  birth), with `INDEXED BY` because this store never runs ANALYZE. CREATED · DATE · TITLE have no
  index on their keys (the three stamp indexes are `entry_date`, `last_touched_at`,
  `last_major_revision_at`; `date` is `COALESCE(entry_date, created_at)`): each page is ONE bounded
  top-N pass over the wing's live notes — flat in depth, ∝ notes; **measured fast enough that no new
  index is NEEDED** (below), so no schema event (an index for them stays the author's §12 call —
  QUESTIONS #187(f)).
- **The listing** (`LibraryCatalogModel` + `LibraryCatalogPaging.swift`): every book of the wing
  (books are never a page — the Bookcase's own class), the notes paged (80 a page, the next asked
  for 30 rows before the end), the block hits of a typed query still capped at 40 and said so. A NEW
  question (query · scope · sort · direction · day · wing) starts over; an ACT on a row re-reads IN
  PLACE at the depth she scrolled to (one statement ∝ what is listed, once per act). The day filter's
  answer stays the whole set (unchanged).
- **P1 — the near window**: only the pages around what is on screen (page-quantized) load their
  extras (tag chips, card words) and have their ownership facts HELD (the model owns the one
  observation, re-aimed only when the window's ids change); the window is unobserved by the views
  and its checks coalesce to one per turn AFTER the layout (a window the views read fed back into
  the Cards' lazy layout — the first build looped). A page lands as ONE update: the page and its
  extras read together, merged in one assignment per dictionary; the paged rows live in their own
  view (`LibraryPagedNotes`) with `Equatable` row hosts, so a landing page never re-evaluates the
  whole catalog.
- **The rider** (`LibraryBooksRegion`): the surface her words name is the Library's List mode under
  the "All" scope (the one screen listing books ABOVE notes). Past half the listing's height (the
  List's own measured row pitch × the count), the books move into their own List capped at half,
  scrolling inside it; fewer books stay in the one list exactly as before; the Books scope (nothing
  below to make room for) keeps one list.
- **The walk found (fixed, pinned):** the Cards view's quiet tag row pegged 100 % CPU forever with
  the pointer resting on an untagged card's chip row — PRE-EXISTING since 13e E8 (measured 99.7 /
  100.0 % on the pre-fix Debug build): revealing the narrow `＋` moved the pointer out of the hovered
  view and back. One frame + one hit shape for both states (`NoteTagsRowHoverTests`); after: 0.4–1.5 %.

### THE (k) NUMBERS (measured; Debug unless said; her app not running; load 2.7–5.6 on 12 cores)

**The page read at corpus scale** (the core read alone, `swift test` debug build, an in-memory store
of N notes, 20 consecutive pages of 80, wing-scoped as the app asks; the "shipped" column is the
pre-fix catalog read of its 41 rows for comparison):

| N | sort | page 1 | median page | max page | shipped 41-row read | a typed query's page |
|---|---|---|---|---|---|---|
| 5,000 | edited | 5.8 ms | 1.7 ms | 5.8 ms | 1.7 ms | 1.3 ms |
| 5,000 | created | 4.3 | 3.9 | 4.3 | 2.9 | 1.5 |
| 5,000 | date | 1.5 | 1.8 | 4.0 | 1.3 | 1.4 |
| 5,000 | title | 2.0 | 2.2 | 2.3 | 1.5 | 1.5 |
| 20,000 | edited | 2.2 | 1.8 | 2.2 | 3.6 | 1.4 |
| 20,000 | created | 12.8 | 12.8 | 13.2 | 8.8 | 4.1 |
| 20,000 | date | 3.5 | 4.1 | 4.2 | 3.3 | 3.7 |
| 20,000 | title | 4.4 | 5.4 | 5.5 | 3.8 | 3.7 |

Off-main, asked for a page before it is needed: none of these is felt. VM steps (pinned): the edited
page is FLAT in the corpus (300 → 1,200 notes: within 1.5×); every sort's deep page costs what page
one costs (500 notes deep: within 1.5×).

**In the app** (the fixture: 600 notes + the dev store's own, 822 listed; a trackpad fling of the
notes region, the pointer resting over it, a display-link frame probe):
- BEFORE (the pre-fix worktree): the List and the Cards stop at 40 notes; scrolling those 40 runs
  smooth (List 11.1 ms mean frame gap; Cards 9.2 ms).
- AFTER, first cut (5729584a): the whole corpus scrolls (822 listed), but each page LANDING stalled a
  frame 100–250 ms (List) / 120–160 ms (Cards): the catalog's whole body re-evaluated per page and
  the page's extras landed as a second full re-draw.
- AFTER 2f26fff2 (one update per page; the isolated paged view): the catalog body no longer
  re-evaluates on a landing (counted: zero catalog bodies at page landings, where every landing had
  one); the landing still drops 70–137 ms (List) — sampled: AppKit's automatic row heights measure
  the INSERTED rows that fall inside the table's prepared region (`_doAutomaticRowHeightsForInserted
  AndVisibleRows` → a SwiftUI row view per inserted row), and the stall barely moves with the page
  size (20 · 40 · 80 rows: 73 · 70 · 84 ms mean at a landing) — so the next experiment is WHEN the
  page lands (earlier, outside the prepared region), not how big it is. PENDING (the machine went
  active).
