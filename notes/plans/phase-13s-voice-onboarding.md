# Phase 13s — Voice & polish + first-run onboarding

**Ticket: VX-7 · Project: 13s — Voice & onboarding · Branch: `vx-7-13s-voice-onboarding` · Machine: THE AIR (its clone, on the pushed branch)**

*(This file holds the KICKOFF; the execution plan lands here after the kickoff sitting, authored
by this phase's orchestrator. Written 2026-10-06 at the workflow transition.)*

## KICKOFF MESSAGE (the author launches a fresh orchestrator with `/architect-phase 13s` — on the Air)

You are the orchestrator for **Phase 13s — VOICE & POLISH + FIRST-RUN ONBOARDING**, the
author-heaviest phase of the three in flight: her copy lands, the design review runs, the field
guide is rewritten for users.

**The workflow is new — read it first.** PREFLIGHT, complete and never delegated: CLAUDE.md +
its auto-loaded canon · **`notes/plans/workflow-transition-2026-10-06.md`** · the master plan's
IN-FLIGHT table · the board snapshot (`notes/TICKETS.md` — on the Air, your clone's copy after
`git pull`; never run `Tools/vx sync` off main) · `notes/QUESTIONS.md` ·
`notes/SessionResiliencyProtocol.md` · **`notes/plans/phase-13s-onboarding-intake-2026-10-04.md`**
(the intake — this phase's accumulated inputs). Work on THIS branch in the Air's clone; one PR
titled `VX-7: …`, merge commit, at closeout. Linear: VX-7 In Progress → In Review → Done.

**THE SPEC is `notes/FuturePhases.md`'s 13s row, read WHOLE.** The standing bars this kickoff
repeats because they are hers verbatim: the copy §11 re-voicing (~45 rows) **never softens
Standard's limit or Castle's "nobody can help"**; the DESIGN REVIEW is **PROPOSE-ONLY** — her
binding posture since 13b: *"everything it surfaces should be brought to me to consider… it's
all a taste question"* — nothing is built from it autonomously, and it inherits the accumulated
visual-loop item lists (the 13b plan's 4A–4F batch records name the never-inspected surfaces);
first-run onboarding is the first-ten-minutes story (it LEFT the v1-readiness row for this
phase); the field-guide rewrite re-seeds, so lesson-currency pins ride every copy change.
Project ticket **VX-45** (the copy family: the book-only delete receipt, the archived empty
state, the "(M archived)" refinement) lands here; sweep the board for other copy-labeled
hand-ins at kickoff.

**THE AIR'S POSTURE IS A RULE (hers):** this machine runs the headless core loop at most
(`swift build` · `swift test`). EVERY `xcodebuild test` run, walk, seed re-generation check or
Debug launch happens ON THE PRO — ssh over, claim `Tools/stage`
(`ssh <pro> '~/dev/variorum/Tools/stage claim --who 13s --reason … --minutes N'`), run there,
release. The Air is never possessed by suites. Sittings with her carry the phase: bundle
questions, present mockups/copy tables for her ruling, land rulings repo-first. Closeout per
CLAUDE.md: the in-flight row retires, the PR merges, hard stop.

---

## KICKOFF RECORD (2026-10-06 evening — the VX-7 orchestrator; the sitting runs next)

- **Seat:** the PRO, worktree `~/dev/variorum-13s`, branch ff'd to main (a7412d2c) and pushed. The kickoff above expected the Air; she launched with "you are implementing and coding on the mac pro right now" — the in-flight row reflects the move (main b6113a66). She attaches from the Air; the Air views the branch by `git pull && git switch`. Suites, when they come, run HERE under a held `Tools/stage` claim (the "over ssh" line above was written for an Air seat; flagged at the sitting).
- **Scope at launch, her word:** the ONBOARDING half (13s-b) first, not the rewording (13s-a). 13s-a's hand-ins (copy §11, the J-list, the "13s re-voices" family, VX-45, release notes) are swept and WAIT.
- **Preflight complete:** CLAUDE.md canon · workflow transition · master plan in-flight table · TICKETS.md (regenerated, 79 open; copy-labeled sweep found VX-45 only) · QUESTIONS.md (open-item sweep + the #179–#188 tail whole) · the 13s intake (2026-10-04) · FuturePhases 13s row whole · resiliency protocol. SyncSpec/TEXTKIT2 deferred until a batch touches their seams (seed-dedupe work would be Sync-adjacent — noted below).
- **Surfaces declared (overlap check):** first-run/onboarding chrome, tutorial/Help features, seed content. 13o (search surfaces): low overlap. 13x (Sync/custody, portability doors): none NOW — but a later seed-set reshape touching `SampleLibraryDedupeFacts` is a `Sync/` touch, and the Sync slot queue is 13o → 13x (R-13o-1); 13s-b's seed code waits its turn or lands clear of `Sync/`. VM-5 (mobile merge): closeouts serialize; we are early and unaffected.
- **Linear:** VX-7 In Progress. Pro→Air ssh tested: OFF (Connection refused — Remote Login disabled on the Air); not needed for this flow.
- **Execution shape standing from the intake (her 2026-10-04 ruling):** MOCKUP-FIRST — every screen and sentence approved before Swift. Mockups as self-contained local HTML, absolute paths.

## SITTING RECORD — the 13s-b kickoff sitting (2026-10-06 evening, the question tool + her live message; rulings verbatim-faithful)

**R-13s-1 — ONE tour with an optional leg.** Her pick of the recommended shape: one short tour (~2 min) ending in a "keep going?" fork that adds the longer-basics leg; both roads end pointing at the field guide. Two separate tutorials declined with it; the longer-basics content lives in the leg (and the field guide stays the deep reference).

**R-13s-2 — Calm open + the helpful badge.** Her words: *"calm open, there can be a small helpful badge (think clippy showing up in the corner), offering a tutorial. it can be on the main screen without being a popup."* No popup at first open — R-13r-11 holds by design, not exception. **Declined idea, recorded at her word:** *"i thought of even putting a picture of me in there waving to start it but decided that would be too much."*

**R-13s-3 — The quick-entry line returns to the BOTTOM (a build item of this phase).** Her words: *"please make the 'new note, just start typing' default to being at the bottom of the page again (above the bottom bar, but not right up next to books). the tutorial offer can live above that bar on the right side."* So the first-open band reads: quick-entry at the bottom of the content area (air between it and the book rows), the tour badge above the bottom bar at the right.

**R-13s-4 — Coach-marks on the real app, and the tour MAKES a take.** Her words: *"coach-marks on the real app, they should at least make a take in write and then see open take mode too (can be within sherlock)"*. The tour is interactive (real clicks advance), and its centerpiece is creating a second take of a real paragraph in Write, then opening Takes to see the fan — inside Sherlock is legal. (Seed-fold note: Sherlock dedupes by the Sherlock-style rule — your edited copy kept — so a toured Sherlock still folds clean on a later sign-in; #186(a).)

**R-13s-5 — The seed reshape is IN 13s-b's scope.** Her pick of the recommended option. The final set stands as her stated list (*"only starred notes there with 0 items starred, sherlock, and field guide (maybe one standalone note too)"*). Seed code touching `Sync/` dedupe facts sequences behind the Sync slot (13o → 13x, R-13o-1); the mockup shows the final set now.

**Her directive at the sitting's close (verbatim):** *"what I want done right now is the mockups and ideas on how things can be - save all of the results of what you do in the repo and pushed, along with notes, because there's a good chance I'll pick this back up from the air."*

## THE EXECUTION PLAN (drafted at kickoff; mockup-first per her 2026-10-04 ruling — units firm up as mockup screens are approved)

- **U0 — THE MOCKUP ROUND (now, orchestrator-built):** the click-through `notes/plans/13s-mockups/onboarding-tour.html` — every screen and sentence of the tour, the first-open surface with the final seed set, the badge, the keep-going leg, an ideas/variations frame. Evidence: her per-screen approval; iterations land in this file and the mockup until approved. NO Swift before approval.
- **U1 — THE FIRST-OPEN SURFACE:** the seed reshape to the final set (R-13s-5) · the quick-entry line's return to the bottom (R-13s-3) · the tour badge (R-13s-2; lifecycle per the mockup's answered questions) · Study as the fresh-store default voice (ruled 2026-10-05). Partly `Sync/`-adjacent (dedupe facts) — lands after 13o frees the slot, or split so seed-dedupe diffs wait.
- **U2 — THE TOUR ENGINE + STEPS:** coach-mark machinery over the real app (anchor targets, real-click advance, dim+spotlight), the core leg + keep-going leg to the approved mockup, the make-a-take step (R-13s-4), the end card → field guide. The tour is the executable spec (P-6): a TourWalk test rides every step; a step broken by a later phase is a regression by definition.
- **U3 — THE QUICKSTART NOTE + RE-ENTRY DOORS:** the standalone fast-read note (her intake's "1 super simple fast read Quickstart note"), where it lives (open Q), Help ▸ tour re-entry, the badge's dismissal/return story.

Sizing: U1 and U2 are the two phase-sized units (within guidance); U0/U3 are small. Acceptance is USE-shaped: her walk of the real flow on a fresh dev store before any unit's record closes. 13s-a (the rewording) is NOT this effort's scope — it runs at her word as its own letter per the FuturePhases split ruling.

**OPEN QUESTIONS FOR THE NEXT SITTING (bundled; the mockup's ideas frame carries them too):** (1) badge lifecycle — when it disappears (tour completed · "Not now" pressed once · N quiet opens), and whether a dismissed badge leaves a smaller re-entry affordance; (2) where the Quickstart note lives (Pool · pinned atop the Library · the badge's "read the two-minute version instead" twin); (3) the make-a-take gesture the tour teaches (the block's ▾ menu vs a shortcut); (4) tour interruption (quit mid-tour — does the badge return offering to resume); (5) the keep-going leg's exact four stops (proposed: star · tag · add to a book · the snippet → Snippets); (6) whether the tour's Sherlock take persists afterwards (a souvenir of the tour) or cleans up.

## SEAT NOTE — resumed 2026-10-07 ON THE AIR, in a WORKTREE (her word)

She resumed on the Air and ruled a **worktree** for this effort — her words: *"start a worktree for this effort - several items are in flight right now on the pro and will be merging into main."* This deliberately overrides the Air's one-clone-switches rule (the Air's clone of `~/dev/variorum` STAYS on `main` to receive the in-flight merges — 13x, VX-83, VX-92 are all heading there). Seat: **`~/dev/variorum-13s` on the Air**, branch `vx-7-13s-voice-onboarding` (same worktree name as the Pro's — different machines, no collision). First development bout run from the Air; no hiccups at setup (pulls, worktree add, `Tools/vx sync` on main, mockup opened — all clean; the Linear key is present in this Mac's Keychain). The Air's posture is unchanged: headless `swift build`/`swift test` at most; suites/walks stay on the Pro via the stage (scheduler today: the `oct7coordinator` session, per the in-flight table). Nothing in this note changes scope or rulings; the mockup-walk sitting is next.

## SITTING RECORD — THE MOCKUP WALK, ROUND 1 (2026-10-07 on the Air; her markup of mockup v1, verbatim-faithful; rulings R-13s-6…11)

**R-13s-6 — The badge is the ONE-LINER, with calmer words, and it teaches its own way back.** Her words: *"change the language from 'new here' with the emoji to a more calm. Welcome to Variorum. Take the tour? and then a yes or not now. if they choose not now, the same popup should briefly change text to show 'run it at any time from help -> tutorial'"* — and, of the ideas frame: *"I actually like this: B · THE ONE-LINER — New here? the two-minute tour → — a single quiet line above the bar; dismiss ×; no card chrome at all. And briefly show how to get it back if they don't accept the offer."* **Reconciled reading (mine, flagged for her eye):** variant B's chrome wearing her words — one quiet line above the bar, right side: "Welcome to Variorum. Take the tour?  yes · not now  ×"; "not now" swaps the line briefly to "Run it any time from Help ▸ Tutorial." before it fades. v1's card variant A, dot variant C, and the proposed return ladder are OUT.

**R-13s-7 — The tour speaks in HER register; the named words move.** *"you can base some of how the tour sounds based off of how I sound in this one piece of writing. <home>/Desktop/Lillian's Start Here.md"* · *"I'd also replace some of the more flowery language like 'The Rooms' with 'Navigation'"* · *"I don't like 'A real book to poke' either. more like 'sherlock holmes in variorum' or something. don't love that phrase but i don't like what you wrote."* · *"'little names' is bizarrely diminuative for tags. maybe like 'organize with tags - books can automatically collect tagged items' or something."*

**R-13s-8 — Accuracy binds to the field guide; the books line is her scrapbook framing.** *"also, library is more than every note. cross reference the field guide to make sure what you say is accurate. also snippets is more about pieces of text you reuse between different items. go ahead and read all of the post notes / details under the launch screen + look through any refreshers needed about what area is for."* · *"also, a book does 'own' its notes in that it has membership in them. maybe my note on books versus gatherings would help you. 'a note is edited everywhere it is by default' is a fair line, but it's kinda complex for a tutorial that's showing people around."* The guide's "getting around" lesson is the tour's fact sheet (Library: everything, searchable, List/Cards/Timeline; Pool: notes in no book yet; Snippets: re-read per her correction as pieces of text you REUSE between notes); the tour's books sentence uses her Start Here framing ("Think of books as a scrapbook — you put a note in there and it stays there"), and the edited-everywhere line leaves the tour (the guide's "membership, not ownership" lesson keeps the full story).

**R-13s-9 — The tour is NAVIGATION-focused, with two new mandatory moments.** Her words: *"make sure there is a moment in the flow where users are encouraged to scroll to the middle of one sherlock holmes note, then click on the middle of it, then switch modes from write / takes / index so they can see how their cursor follows. I also want you to go into book mode, then show how you can click on the open note button to go into note, then click on the book to get back to the book. focus the tour on NAVIGATION - they'll be pointed to the field guide if they need more help. making a take is good."* (One reading flagged: "index" in her write/takes/index list is read as Read's edit face — the ▸ 01 index surface; Q11 asks.)

**R-13s-10 — The Start Here split.** *"look at my start here text - the first half of it will become the welcome note, the emotional half will become a letter from lillian (no need to mention the letter in the onboarding)."* The split point: everything through "This book is a full guide…" is the welcome note's material; "As you can see, annoyance took me far. Love took me further…" onward is the letter. This also ANSWERS v1's Q2 — the intake's "1 super simple fast read Quickstart note" IS the welcome note, made from her first half.

**R-13s-11 — Mockup v1 is DECLINED whole; redesign from first principles.** Her words: *"I feel like this whole mockup just missed the mark, you know what I'm saying? go back to the drawing board, consider how some of the best UX designers in the world would recommend an onboarding flow (apple in particular tends to have very clear flows), and try again."*

**V2 DIRECTION (built same sitting, same file):** the Apple-tip register — one idea per card, a title plus at most two short sentences, visible step count, always escapable, the user's real click advancing; the spine is pure NAVIGATION (sidebar → book → note → modes → back up the ladder → a note of your own); the two ruled moments built in (mid-note click + cursor-follows-you across modes; the book↔note round trip); all copy re-voiced to her Start Here register; area facts from the guide's "getting around"; her tags line nearly verbatim. Old Q disposition: Q1 superseded by R-13s-6 (residue → Q9), Q2 answered by R-13s-10, Q3 answered ("making a take is good" — the block-menu road stands), Q7 superseded by the rewrite; Q4/Q5/Q6/Q8 carry forward as Q12/Q13/Q14/Q17. New: Q9 (badge return cadence after the transient), Q10 (step 2's sentence pick), Q11 (the "index" reading), Q15 (where the welcome note lives so a stranger finds it), Q16 (where the letter from Lillian lives — seed work, never mentioned in the tour).

## SITTING RECORD — THE MOCKUP WALK, ROUND 2 (2026-10-07 late, on the Air; her markup of v2 + 29 screenshots of the REAL app; rulings R-13s-12…19)

**R-13s-12 — NO DIMMING.** *"ok definitely don't dim the screen to make the take tour highlight button pop up - just mentioning that in case you wanted to do that."* v2's spotlight used a full-screen dark overlay and the end card sat on a dim — both OUT. The highlight is a ring/glow on the target alone; the room stays at full light throughout.

**R-13s-13 — THE OFFER NEVER COMES BACK (closes Q9).** *"i think the tour offer just shouldn't come back - they can find it under help."* "Not now" → the transient "Run it any time from Help ▸ Tutorial." → gone for good. No return ladder, no later-launch reappearance, no dot.

**R-13s-14 — WORK FROM THE REAL APP (the fidelity ruling).** *"i would just note that the mockup doesn't exactly look like the real app."* · *"i feel like this walk approach and recreating it in the web first might be causing more harm than good tbh. you just don't know the layout, where the book thing is, what might be intuitive and what's not. there's a bottom bar with menu options. there's other things."* · *"i tried to take these screenshots at least a little in order, though i went back to showing more book details at the end and different things. maybe work freshly from these screenshots to give you a better idea."* · *"you might just need to walk the app for good results - i'll give permission for you to use the air's screen on this ocassion and i've already installed cliclick for your needs."* The 29 screenshots are the new ground truth; the mockup's chrome rebuilds from them (the sidebar's this-note mode list, the bottom bar's block ▾ · Takes · commit ⌘S · history · note ▾ · comments, the ← 📖 → cluster, the real Bookcase masthead and strip, the book's left column). The Air screen grant is THIS OCCASION only.

**R-13s-15 — "Click into it."** *"also, click it sounds too authorative - maybe 'Click into it'."*

**R-13s-16 — Books open to OUTLINE by default.** *"also, books open to outline by default."* (v2's step 3 showed Index as the landing — wrong.)

**R-13s-17 — The take GLYPH in Write is pointed out.** *"also, the glyph that shows takes in write mode should be pointed out - it's an essential feature."* The screenshots name it: the ψN badge in the block's right margin (fanned blocks only), opening the Takes popover ("Takes — block …", the chosen take, + new take (branch) · + blank take · + blank & choose, Open Takes mode). Her own Start Here teaches exactly this road ("The icon to the right of this block is the take icon - click on it").

**R-13s-18 — Lenses/Compare, said right.** *"lenses is for looking at different takes in the same note. compare is for use with other notes."* (The tour doesn't teach them; wherever they're named, these are the words.)

**R-13s-19 — The flow itself re-derived.** *"I just don't know if this tour seems like it's capturing the right flow that a viewer would go through."* v3 rebuilds the step sequence from the screenshots' own order (Bookcase → book Outline → open a note → Write/bottom bar → the take road → Takes mode → back up the ladder → your own note), not from v2's skeleton.

## SITTING RECORD — THE MOCKUP WALK, ROUND 3 (2026-10-08, on the Air; her markup of v3; rulings R-13s-20…24 + the architect's own changes under R-13s-23's mandate)

**R-13s-20 — A subagent assessment.** *"I want you to run a subagent to assess this flow against the field guide and see what on the screen they think users would be curious or confused about."* One read-only agent, briefed on the mockup, the field guide source, and her screenshots; findings land in this file.

**R-13s-21 — The modes are pointed to.** *"I also do want the different modes pointed to and have at least one quick line about the for lenses and compare and blcoks."* Built as its own small step (one line each), with R-13s-18's words: Lenses shows different takes of this note side by side; Compare sets other notes beside this one; Blocks is the workbench.

**R-13s-22 — The tone ruling.** *"i feel like it just needs a bit more polish - also try to reduce AIisms in your writing like emoji's and em dashes and keep the calm professional tone that I had in my piece of writing."* And the register joke, kept for the record: *"sherlock holmes is also always there as good writing inspo! just kindding (kinda), don't want it being a tutorial from the 1800s."* So: modern plain prose, no emoji in copy, no em dashes, her Start Here register.

**R-13s-23 — The architect's latitude.** *"what do YOU think the flow needs to improve? you can make those changes you believe in before starting the subagent. don't be overly focused on my feedback - it might be too whackamole, focus on what you believe would lead to the best results from this app, from this tour."*

**R-13s-24 — THE LOGO JOINS 13s-b.** *"also, look for the logos and add a logo to the app - the red V that i identified as one of my favorites. that change should come with the onboarding flow."* Resolved against the brand record: the STRIPED V is the ratified logo (TASTE.md's close, her 2026-08-25 "yeah, that's going to be the logo"), and "the red V" is its red edition, `notes/brand/variorum-v-on-red.svg` on `#FC120C`. Scope: a 13s-b build item beside the tour (the macOS app icon from the red edition; any in-app placement is Q19, proposed calm: icon + About, with the mockup's welcome-line mark as a candidate). TASTE.md's icon-execution list (the squircle treatment) is the how.

**ARCHITECT CHANGES (mine, built in v4 under R-13s-23 — each one line to overturn):**
1. **The heart line.** The tour never said why the app exists; the take step now carries one sentence of her pitch ("takes, like takes in film, and they are the heart of Variorum"). Mechanics with a reason land better than mechanics alone.
2. **The deeper modes as their own small step** (R-13s-21's content, step 6) rather than a bloated card: eleven short steps beat ten where one is overloaded.
3. **The end card points at Start Here** ("a short welcome note, waiting in your Library") — my provisional answer to Q15: discoverability by one calm sentence at the exact moment the tour ends, not a badge or a pin.
4. **An explicit way home**: step 10 ends by sending them to Bookcase in the sidebar, so the last hop is navigation they perform, not a teleport.
5. **The de-AI-ism pass**: all card copy and the badge rewritten without em dashes or emoji; UI glyphs (the book icon, ψ) remain chrome, named in words inside sentences.
6. **Q14 recommendation**: the toured take stays afterwards (Sherlock is the sandbox; a trace of your first take is a feature, and the fold is safe either way). Hers to overturn.

**R-13s-25 — The logo EDITION corrected, and Q19 closed (2026-10-08, her next message, verbatim):** *"different red - one with white in it as well. normal version of what ichose. agree w your assesment"*. So: not the one-color-on-red edition but the **faithful two-tone, as generated** — `notes/brand/variorum-v-faithful-red.svg` (the red ground with the black V carrying white between its stripes; the family sheet's "faithful two-tone (as generated)" panel). And "agree w your assessment" closes **Q19 as the architect's lean: the app icon (this edition on the squircle) + About + the welcome-line mark, nothing more.**

## RESUME PROMPTS — the mockup-walk sitting (written 2026-10-06 night at her ask; **SUPERSEDED — the walk ran 2026-10-07 on the Air; the round-1 sitting record above is the live state**)

**State at sleep:** mockup delivered and pushed (b4abda9a); rulings R-13s-1…5 recorded above; open questions Q1–Q8 bundled (the EXECUTION PLAN's list + the mockup's ideas frame); 13s out of the stage queue (13o schedules; nothing needed for a mockup sitting); NO Swift before her per-screen approval.

### If she resumes ON THE PRO (paste-ready)

> /architect-phase vx-7 — resume 13s-b at the MOCKUP WALK, on the Pro. The worktree `~/dev/variorum-13s` exists on branch `vx-7-13s-voice-onboarding` — verify clean (`git status -sb`), `git pull --ff-only`. First steps per CLAUDE.md: `git pull` in `~/dev/variorum` AND the shared memory repo, then `Tools/vx sync` (in `~/dev/variorum`, on main). Read WHOLE: `notes/plans/phase-13s-voice-onboarding.md` (kickoff → KICKOFF RECORD → SITTING RECORD R-13s-1…5 → EXECUTION PLAN → RESUME PROMPTS), the intake `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`, and the memory file `vx-7-13s-run-state`. Then give me the mockup's path — `~/dev/variorum-13s/notes/plans/13s-mockups/onboarding-tour.html` — I'll walk the 17 frames and report; you record my rulings VERBATIM repo-first (numbering continues R-13s-6+), bring me the Q1–Q8 bundle with recommendations, iterate the mockup same-day, commit+push per piece (the memory repo immediately after every write). NO Swift before my per-screen approval. Stage: 13s is out of the queue — when U1/U2 builds near, request an assignment from the "13o" session (ListAgents); never claim without one.

### If she resumes ON THE AIR (paste-ready)

> /architect-phase vx-7 — resume 13s-b at the MOCKUP WALK, on the Air. Seat yourself: `cd ~/dev/variorum && git pull && git switch vx-7-13s-voice-onboarding && git pull` (the Air's one clone switches branches — no worktrees here), and `git pull` the shared memory repo FIRST (`~/.claude/projects/-<home>-dev-variorum/memory`). NEVER run `Tools/vx sync` off main — read `notes/TICKETS.md` as committed. Read WHOLE: `notes/plans/phase-13s-voice-onboarding.md` (kickoff → KICKOFF RECORD → SITTING RECORD R-13s-1…5 → EXECUTION PLAN → RESUME PROMPTS), the intake `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`, and the memory file `vx-7-13s-run-state`. Then give me the mockup's path — `~/dev/variorum/notes/plans/13s-mockups/onboarding-tour.html` — I'll walk the 17 frames and report; you record my rulings VERBATIM repo-first (numbering continues R-13s-6+), bring me the Q1–Q8 bundle with recommendations, iterate the mockup same-day, commit+push per piece (the memory repo immediately after every write). NO Swift before my per-screen approval. The Air's posture is a rule: headless `swift build`/`swift test` at most — EVERY suite/walk runs on the Pro via the stage, and stage scheduling belongs to the 13o session on the Pro (a mockup sitting needs none; defer build-batch stage coordination to a Pro-seated session or ssh per CLAUDE.md).
