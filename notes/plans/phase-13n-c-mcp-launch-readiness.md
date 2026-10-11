# Phase 13n-c — MCP launch readiness

**STATUS: IN PROGRESS — kicked off 2026-10-11 ~03:25 MDT on the Pro, overnight, under her
kickoff mandate (`notes/plans/13n-c-kickoff-prompt.md`, her text verbatim below).** Run ticket
**VX-165** (child of VX-25, project "13n — The MCP door"); members as sub-issues: VX-163 · VX-164
· VX-157 · VX-158 · VX-160 · VX-159 · VX-162 (VX-156, the design prep, is Done — its designed
round is this phase's build). VX-161 EXCLUDED at her word. Branch `vx-165-13n-c` · worktree
`~/dev/variorum-vx-165` (the Pro). Shape: `/architect-phase`. **Cast, redirected at this
kickoff by her: OPUS ORCHESTRATES** (her Opus-week protocol — her Fable budget is nearly out);
`opus-implementer` builds, one fresh session per unit; `fable-reviewer` on the highest-risk
diff first (U1's round 1) until the budget runs out, then `opus-reviewer` with FABLE-OWED rows.
This file is the ONE running record; it supersedes `phase-13n-c-mcp-launch-readiness-DRAFT.md`
(kept as the pre-sitting draft).

## ⇄ THE FABLE SWITCHOVER (2026-10-11 ~13:45 MDT, her word — prepared by the Opus orchestrator for the incoming Fable one)

**Her words (relayed in the orchestrator session):** "I also have more Fable tokens. I am planning to switch the model on
this current conversation now to Fable - we can continue forward with Fable reviews & do the current owed ones, you
yourself (this convo) will switch to Fable for handling the switchover."

**The cast from here:** the standing default is restored. **FABLE orchestrates and cold-reviews (`fable-reviewer`), OPUS
implements.** Under the CROSS-MODEL flow (CLAUDE.md):
1. findings go to the implementer verbatim;
2. its agree/dispute returns to the reviewer;
3. the reviewer makes the final call and implements its confirmed fixes itself;
4. then the suite runs green, followed by one implementer sanity pass.

Her refresh condition still names an **OPUS UX-reviewer walk**, so that leg stays Opus by her word.

**State at the switch (tip `f04c14ef` + whatever the walker has pushed since):**
- **Built and verified by the orchestrator:** U1–U5. Stage A was closed at R2 (Fable R1, Opus R2). Stage B was closed at
  R2 (Opus R1 + R2), plus the close-out fix pass `6f7fc38f..3e8ccd83`, which has NOT been cold-reviewed.
- **IN FLIGHT:** the walker (`opus-implementer`, agent id `a043d487dbcb54418`, RESUMED ~13:40 at her word after her
  pause). It runs the HELD-WALKS BRIEF: fix D-W1/D-W2 with red-on-old pins, re-walk the picker, finish W-4 and
  W-6…W-10 plus live rounds (3)–(6), then clean up the machine and report a WALKS CLOSED banner. **Do not spawn a twin.
  The cast is strictly sequential, so no reviewer runs until it reports.**
- **NOT STARTED:** U6 (the wing on the wire + gatherings; the advice has ~500 characters of room under her ruled 2,000
  bound), U7 (VX-159), U8 (the secret). U7 and U8 may fall out (§4). Then the Opus UX walk, then closeout.

**THE OWED FABLE REVIEWS — proposed order (Fable's to adjust):**
1. **After the walker reports: ONE `fable-reviewer` cold review over the whole Opus-reviewed span.** That is
   `33bd8772..<walk tip>`: U1's R1 fix and R2 onward, U2–U5, both Stage B fix passes, and the walk's fixes. This
   discharges F-5…F-22's "reviewed by" column in one pass. REVIEW_PROMPT verbatim with PHASE = 13n-c and a
   mechanics-only note naming the range; the FABLE-OWED rows are NOT framing to hand it (it finds them in the plan
   itself). A ladder: R1 → the cross-model flow → R2.
2. **U6 (and U7, if attempted): a `fable-reviewer` ladder as Stage C** (§5 already named Fable for any budget left).
3. **U8, if attempted:** Fable, since her protocol names the secret's accept path.
4. **Rows remaining unreviewed at the closeout stay on VX-166** (the post-phase Fable sweep). The ledger's "Reviewed by"
   column is filled as each review lands, so VX-166 shrinks to what is left.

**A NAMING RULE, hers (2026-10-11 ~14:15: "why is it called R-AIR-14?? it should have a VX number … we started
using linear so that everything would actually be consistently organized"):** an R- number names a RULING in a sitting
record and keeps it (canon cites them); **the WORK a ruling mandates always carries a VX ticket from the moment it is
scoped — never only the ruling's number.** U8 rode "R-AIR-14" with no ticket from the kickoff until now; fixed at her
word: **VX-168** (Pre-launch label, 13n project). Standing rule for every future plan.

**THE FABLE ORCHESTRATOR'S SCHEDULE (adopted at the takeover, 2026-10-11 ~14:00 MDT — Fable 5, this section
supersedes the proposed order above where they differ):**
1. **The walker finishes** (in flight — D-W1/D-W2 fixes, the picker re-walk, W-4's remainder, W-6…W-10, live rounds
   (3)–(6), the machine cleanup). Nothing else runs beside it (the cast is strictly sequential).
2. **U6 builds** (`opus-implementer`): the wing on the wire + gatherings under a wing grant, the advice's gatherings
   clause (~500 characters of room under her ruled 2,000 bound), the guide's withheld wing sentence (the U5 record
   names it), O-4's posture kept.
3. **ONE combined `fable-reviewer` ladder over `33bd8772..<U6 tip>`** — the owed Opus-reviewed span (discharging
   F-5…F-22's "Reviewed by" column) AND Stage C (U6) in the same ladder, R1 → the cross-model flow → R2.
   *Why one ladder, not two (the adjustment):* the sequential cast means they could never overlap anyway; the owed
   span has already survived two full Opus ladders, so Fable's pass over it is a verification sweep that rides the
   same read; and one ladder returns ~1.5 h to her release goal. The cross-model flow holds for the U6 half
   (findings verbatim to the U6 implementer, its agree/dispute back, the reviewer finalizes and implements its
   confirmed fixes itself, suite green, one implementer sanity pass); for the owed half the original implementers
   are gone, so the reviewer implements its confirmed fixes directly with the orchestrator's dispositions.
4. **U7 and U8 FALL OUT — decided now, not at midnight.** §4 named this exit at plan time. Her takeover message
   weighs release-readiness (the refresh + the handoff) over more surface tonight; each would cost an implementer
   session plus its own Fable ladder. U7 stays VX-159 (already on the board); U8 becomes a named ticket at the
   closeout (the Linear MCP is disconnected until her re-auth — if it stays down, the handoff carries the mint).
5. **The Opus UX-reviewer walk** over the whole built surface (her named refresh condition; stays Opus at her word),
   fed T-1…T-8 + whatever the walker's close adds; then its dispositions and one fix pass if earned.
6. **Closeout:** merge latest main into the branch; results; master plan + in-flight retirement + closeout
   paragraph; canon deltas per the checklist; MOBILE PARITY line; QUESTIONS #211; the handoff with her checklist at
   top (the fence probes, the Help ▸ Restore Tutorial… decision — it is HERS, it trashes the current guide's notes);
   tickets closed or re-owned; PR; merge commit; push; **the A1 /Applications refresh at a zero-instance window**
   (never quitting a running real-store instance — if one is live, hold and say so); hard stop. 13s-a stays next.

**Environment facts for the incoming orchestrator:**
- **The Linear MCP disconnected at her `/login`.** Ticket operations need `mcp__linear-server__authenticate` (her OAuth)
  or the key road. Board facts are in `notes/TICKETS.md` on main. Tickets born this run: VX-167; VX-132 gained a
  comment.
- **`git pull` in this worktree** must name the branch (`git pull --rebase origin vx-165-13n-c`); the bare form errors
  with "Cannot rebase onto multiple branches".
- **Her Pro is unlocked** for all foreseeable needs (her word, 11:31). Walks are legal under a held stage claim.
- **The running memory record** is `~/.claude/projects/-<home>-dev-variorum/memory/13n-c-run-state.md`
  (shared repo; commit + push after writes).

**The design record this phase builds to (read whole, in this order):**
`notes/plans/vx-156-grant-ux-design-kickoff.md` (THE SITTING RECORD — R-AIR-1…15 + round 5; her
word, authoritative over everything below) · `notes/plans/vx-156-grant-ux-brief.md` (options +
picks, the chord sweep) · `notes/plans/vx-156-grant-ux-mockups.html` (the approved drawn states;
the sitting record's overrides win where they differ) · `notes/plans/phase-13n-b-mcp-door.md`
(the door being extended — R-13nb-1…28, AF-1…AF-11, its four unit records).

## LIVE STATUS (orchestrator — flipped in the same commit as each piece)

| # | Piece | Status |
|---|---|---|
| K0 | Bout start (pulls, board snapshot `ac32a780`), full preflight, ticket VX-165 + sub-issues, worktree, in-flight row (`fbfbf1a9` on main) | DONE |
| K1 | This plan finalized | DONE (this commit) |
| U1 | The fence re-key (VX-163) | IMPLEMENTER CLOSED (`UNIT CLOSED` banner in the U1 record) — owed: the orchestrator's verification + REAL Claude Code live round; the pre-flight walk HELD (locked session); Stage A |
| U2 | The grant sheet rebuilt | IMPLEMENTER CLOSED (`UNIT CLOSED` banner in the U2 record) — owed: the orchestrator's verification; the walk HELD (locked session) — offscreen captures stand in, NOT a walk; Stage B |
| U3 | Grant from where you are + the one icon + the in-note indicator | BUILT + VERIFIED by the orchestrator at `c6d5d23a` (7 commits `4dc0202c..c6d5d23a`: fence diff empty — no Sync/ · Persistence/ · migrations · editor seam; zero trailers; 22 captures read — popover, Bookcase icon, two-door receipt) — icon pick: A `point.3.connected.trianglepath.dotted` KEPT (orchestrator, PROVISIONAL P-13nc-U3-5 — hers at the copy pass); the walk HELD (locked session); Stage B |
| U4 | Asks wait quietly + the keyboard | BUILT + VERIFIED by the orchestrator at `f1ab4725` (5 commits `a41efc1b..f1ab4725`: fence diff empty — zero `Sources/` lines; zero trailers; captures read — Waiting, ⌘L typed, Bookcase glyphs) — the walk HELD (locked); Stage B |
| U5 | The guide, the AI's advice, the setup menu | BUILT + VERIFIED by the orchestrator at `065526ce` (8 commits `58b81ec8..065526ce`: fence diff empty — zero `VariorumCore/` lines; zero trailers; captures read — lesson 4, the any-client JSON; the advice read whole) — the walk + the scratch `claude mcp add` HELD (locked); Stage B |
| U6 | The wing on the wire (+ gatherings under a wing grant) | BRIEFED — implementer spawning |
| U7 | VX-159 — the ceremonies on the wire | FALLS OUT of 13n-c AND of the launch (her word; VX-159 carries no launch label) |
| U8 | **VX-168** — the per-setup secret (the work R-AIR-14 ruled) | FALLS OUT of 13n-c — **a PRE-LAUNCH GATE, her word 2026-10-11 ~14:15: "U8 done before launch but not before this applications refresh"**; ticket minted with the Pre-launch label; kickoff `notes/plans/vx-168-kickoff-prompt.md` |
| W | The whole-phase walk + the OPUS UX-REVIEWER WALK (a ladder round) | NOT-STARTED |
| C | Closeout (+ the /Applications refresh iff her four conditions hold) | NOT-STARTED |

## HER KICKOFF TEXT (verbatim — the mandate this phase answers)

> Hellooooo Opus! Exciting day today, we're going to be building the follow up on
> the mcp connection that was already built, so that I can fully see and explore
> the use of the mcp and where we're at with it tomorrow morning. Focus on making
> the UI and UX of the mcp grant experience CLEAR - keep in mind a user might have
> hundreds of books and notes. perhaps a sort by shelf would also be helpful,
> ability to see favorites, etc. it needs to be and feel nice or no one will want
> to use it at all. make sure the keyboard shortcuts pane is updated and perhaps
> the field guide can grow an MCP chapter, or we can make an MCP explanation book
> that shows up in your library when you first connect an MCP server. either way,
> notes / documentation for the user need to be made clear (especially since
> that's what a user's AI might need as advice too). It's also important that you
> note down your adjuncation decisions for a Fable review that will follow this
> phse's completion, as well as having parts of the code that would deserve a
> fable review noted clearly. I still have 4% of my weekly usage, so run fable
> reviews on what you need to until you can't anymore. you'll be running this
> overnight. also, I want you to finish if phases are complete and everything is
> passing, has been walked and specifically had an opus UX reviewer walk it to
> flag problematic flows, hard to find buttons, weird spacing or looks, etc., then
> you can refresh my application install.

**Her closing condition, as this record reads it (binding):** the `/Applications` refresh runs
IF AND ONLY IF (1) the phase's units are complete — the units §4 commits to, with any fall-out
named there plainly; (2) the suites pass; (3) the phase has been WALKED; (4) an Opus UX-reviewer
walk has run to flag problematic flows, hard-to-find buttons, weird spacing or looks, and its
findings are fixed or dispositioned as a ladder round. Then the A1 ritual at a zero-instance
window — never quitting or killing a running real-store instance; if one is live, the refresh is
HELD and the handoff says so.

## THE RULINGS THIS PHASE BUILDS (pointer + one line each — the sitting record is the text)

- **R-AIR-1** — journal-TRAIT books may hold standing grants; the never-always fence keys on the
  **'daily'-marker Journal** (its entries per-ask only) and the **Private mark**. (U1)
- **R-AIR-2 / R-AIR-9** — the per-item cross-wing NOTE move ships on the wire; R1 (edit at the
  source + write new at the destination wing) recommended, R1/R2 both legal. (U6)
- **R-AIR-3** — the grant confirm on EVERY book grant: *"Grant read in “dream journal” always,
  including to future entries."* (U1 words, U2 sheet)
- **R-AIR-4** — ⌥⌘A's confirmation carries a door: a panel pre-filled on what was just shared,
  to change its details fast. (U3)
- **R-AIR-5 / R-AIR-15** — the wing switcher: ⌘L opens it, typing filters, holding ⌘ and tapping
  L cycles (the ⌘-tab idiom), release/return commits; the masthead switcher clicked without
  typing also cycles; fast to click. (U4)
- **R-AIR-6** — ONE consistent AI-shared ICON, not text, everywhere (hover names it, click shows
  the permission); icon language matches the sidebar set; a pending-ask icon in the same family.
  (U3, U4)
- **R-AIR-7 (VX-164)** — the in-note indicator, upper right, with MCP on: shared icon (click → the
  permission AND the why — "readable through the Home wing grant"), lock when Private (click to
  change), pending-ask. "Never surprised, from within a note." (U3, pending-ask leg U4)
- **R-AIR-8** — no "AI" in settings-class wording (lean "grant MCP permissions"-class copy; final
  words hers at the copy pass); every share/grant face renders ONLY when ≥1 approved client
  exists; any zero-state face routes to Settings ▸ MCP — never a dead button. (U2–U4)
- **R-AIR-10** — VX-159 presets: brief §10/§11's shape, PROVISIONAL on her "I think it's fine" —
  presets on the existing tools, id + text addressing. (U7)
- **R-AIR-11** — everything discussed builds EXCEPT VX-161.
- **R-AIR-12** — a wing grant covers the whole wing: notes, books AND gatherings (readable as
  facts), minus anything fenced; gatherings do NOT become grant targets. (U6)
- **R-AIR-13** — the setup command grows a per-client menu: Claude Code · Codex · a generic
  path/JSON shape (the pane says the door is a standard MCP stdio server at one binary path). (U5)
- **R-AIR-14** — the per-setup secret BUILDS inside 13n-c, scheduled so launch never blocks on
  it; the honest pane sentence ships regardless. (U8 — LAST; L1's sentence ships in U2)
- **Also VX-156's scope (round 2):** last-edited joins the picker context line's fixed order; a
  "recently edited" quick section in grant pickers; "while connected"'s wording gets copy OPTIONS
  at the build. (U2, U4)
- **Round 5:** the wing switcher reachable from the LIBRARY masthead too (⌘L app-wide) (U4);
  **snippets stay OUT of the door at launch AND the docs say so clearly** — **RATIFIED at round 6**
  (her close, after this phase launched — `vx-156-grant-ux-design-kickoff.md` §ROUND 6, on main
  `63a19f81`); the wing-isolation UI makes clear Snippets is
  the one room shared across wings (U4 switcher line + U5 guide).
- **Round 6 (her close, 2026-10-11):** snippets-out RATIFIED; **the decisive fence tests are HERS in
  the morning** — the Home-wing read grant with the journal probe ("crat attack") and Private-BOOK
  grant behavior; the handoff checklist carries both (the build's own pins and live round do not
  replace hers).
- **Her kickoff adds (verbatim above):** sort by shelf and favorites (starred) in the grant
  pickers (U2); the keyboard shortcuts pane updated (U4 — `HelperView.groups` is the ONE source
  both Settings ▸ Shortcuts and ⌘/ render); clear user docs that double as the AI's advice (U5).
- **The brief's picks taken as the build's defaults** (each nodded through at the sitting by her
  approval of the mockups, overridden where the record says otherwise): §1 A (the ONE picker,
  `SearchPicker`) · §2 A (context always + the collision ladder) · §3 A (every place-door opens
  THE grant sheet pre-filled) · §4 ⌥⌘A + D1 · §5 face A + arrival X — **the face A "asks" CHIP
  is superseded by R-AIR-6's pending-ask ICON**; arrival X stands (the badge + Waiting list
  REPLACE the self-popping sheet) · §6 ⌥⌘, · §7 superseded by R-AIR-15 (⌘L) · §8 A (a `wing`
  target on `show_in_app`) · §9's six sentences + the ⌘J edge (see U1) · §10 R1 · T1 · U1 ·
  §11 P1 + presets on the existing tools · §12 L1 now, K2 for the secret.

## ORCHESTRATOR DECISIONS AT KICKOFF (each logged for the FABLE-OWED walk and #211)

- **D-1 — the ⌘J edge (brief §9 item 3): KEEP the note's own `profile='journal'` leg.**
  Traced: the ONLY door stamping a note's own `profile='journal'` is `createOrOpenJournalEntry`
  (`Operations+Container.swift:80` — the ⌘J/daily door; phone capture rides it). So the leg means
  exactly "entries the daily door makes", which is R-AIR-1's "(a) … its entries per-ask only" read
  literally, and R-13nb-1's posture (more asks, never fewer). A journal-trait book's OTHER notes
  carry no own profile and become grantable as ruled. PROVISIONAL P-13nc-1 (the alternative —
  only membership in the daily book fences — is one SQL line).
- **D-2 — the user docs: the field guide grows an MCP CHAPTER, and the server's `instructions`
  grow into the AI's advice — both, one set of facts.** Why this over a first-connect book: (a)
  the field guide is the app's established, test-pinned home for teaching (P-6, `TutorialSeeder`'s
  plan + `TutorialWalkTests`), and 13s-a's plan already names "the field guide's MCP chapter" — a
  second teaching object would fork the curriculum; (b) a book that appears by itself on first
  connect is spontaneous content minting, against the calm-asks line (§12: "No popup greets a
  first open; the app's own asks … wait"); (c) her "that's what a user's AI might need as advice
  too" is best served where EVERY client reads it with no grant needed — the MCP `initialize`
  `instructions` field (`MCPSession.instructions`, today four sentences) — while the guide stays
  readable to an AI she grants it. PROVISIONAL P-13nc-2, logged #211; her override (the
  first-connect book) is a U5 rebuild of the delivery, not of the content.
- **D-3 — R-AIR-3's clause on wing and open-book doors:** her sentence is ruled for EVERY BOOK
  grant. A wing grant's membership is equally live; the build gives the wing confirm the parallel
  clause ("…always, including notes added later") — PROVISIONAL P-13nc-3; the open book's switch
  keeps its own line (the six-sentence set).
- **D-4 — sizing said plainly (§4) and the ladder shape (§5):** stages, not one ladder per unit,
  for the chrome units — recorded with reasons.
- **D-5 — the Sync/ fold classifiers are UNTOUCHED by VX-163.** Traced: `SeededFurnitureDedupe` /
  `SampleLibraryDedupe` read the Private mark as ENGAGEMENT (the U2 ladder's F1 fix); neither reads
  the journal fence. R-AIR-1 changes only the MCP fence's derivation (`MCPGrantQueries`), so U1 is
  ZERO `Sync/` lines — the implementer re-verifies and the record says so.

**ORCHESTRATOR FINDING O-1 (U3+U4 captures, 2026-10-11 09:10) — routed to the Stage B fix pass.** At row size U4's
pending-ask glyph (U3's icon FILLED) and U3's shared icon read as near-twins side by side (`u4-bookcase-study.png`:
"the lightning thief" wears both and they are hard to tell apart). Her mandate is that the grant UX be CLEAR, so a
waiting ask must read as different from "shared" at a glance. The fix pass picks a pending glyph whose difference is
its silhouette, not its fill (candidates for the fixer: a badge dot on the shared icon, `questionmark.circle`,
`hand.raised`), PROVISIONAL and hers at the copy pass. Not a red-on-old class (taste), so no pin is owed beyond the
existing glyph pins. FABLE-OWED: no (chrome).

**ORCHESTRATOR FINDINGS O-2 / O-3 (U5 read, 2026-10-11 10:15) — routed to the Stage B fix pass (held back from the cold
reviewer: REVIEW_PROMPT forbids framing).**
- **O-2:** `MCPSession.instructions` calls the author "she"/"her" throughout. Variorum ships to anyone; the advice an AI
  reads must not assume the user's pronouns. Fix: "the author" / "they" (neutral), within the 1,500 bound, and pin that the
  advice carries no gendered pronoun. (The guide speaks in "you", which is fine.)
- **O-3:** the ⌘/ helper's MCP row (U4's) describes the pending glyph by shape ("the filled icon…"); it moves with O-1's
  glyph change and describes the mark by role instead (U5's own carry note).

**ORCHESTRATOR FINDING O-4 (her ask, 2026-10-11 ~12:05: "make sure that outside of the provider setup, claude / claude
code isn't hardwired anywhere since people may use different providers") — the sweep and its routing.**
- **Swept:** every non-comment line in `Sources/`, `App/Variorum/Variorum`, `Shared/` and `VariorumMobile/` matching
  claude/anthropic.
- **The server and the wire are clean:** zero non-comment lines in `Sources/`. The advice and tool descriptions name no
  provider. Grants, asks, receipts and the client-named undo all use the client's own self-declared name.
- **Hardwired outside the setup menu, to fix:**
  - (a) `MCPPaneCopy.swift:34`, the pane description: "so clients like Claude Code can read…". Make it neutral or
    multi-provider.
  - (b) `HelperView.swift:119`, the ⌘/ row, quotes "Undo claude-code's take". Use a placeholder form (the client's
    name), not one provider's.
  - (c) `TutorialSeeder.swift:2618`, the guide's undo example "Undo claude-code's take", and `:2518`'s "(claude-code, …"
    name example. Same placeholder treatment, or a neutral example set.
  - (d) `TutorialSeeder.swift:2483` and `SettingsShape.swift:115/300`: "such as Claude Code or Codex". These are
    examples, but they lean two providers. Make them neutral ("any MCP client — Claude Code, Codex, Cursor and others"),
    wording PROVISIONAL for her copy pass.
  - (e) `SettingsShape.swift:302`, the search keywords. Keep "claude" and add other providers' and clients' names
    (codex, chatgpt, openai, cursor, gemini…) so search finds the pane whatever she or a user calls their AI.
- **Legitimately Claude-specific (the setup menu, which her ask excludes):** `MCPSetupClient.claudeCode`, its command,
  sentence and receipt (`MCPPaneCopy.swift:241-256, 595-635`), and the menu's default selection (`MCPPane.swift:38`).
- **Routing:** the Stage B R2 fix pass if R2 earns one, else U6's first commit. Pin: a source sweep asserting no
  provider name in app copy outside `MCPSetupClient`'s cases and the keyword list.

## ✅ BLOCKER CLEARED 11:31 MDT. She unlocked the Pro ("pro should be unlocked for all your forseeable needs"). The orchestrator's dev-store check at 11:37: the tip's Debug build opens the dev store normally. Her screenshot of "database could not be opened… key is not available" was the `xcodebuild test` HOST window (Mac suites host on the Debug app, which cannot reach the dev store's key under test), not a defect. The held walks now run after Stage B R2.

## (history) STANDING BLOCKER — THE SESSION WAS LOCKED (found 04:00, confirmed 04:14 MDT)

The Pro's login session is LOCKED (`CGSSessionScreenIsLocked = 1`; the display was asleep at
04:00). Unlocking is hers. **Consequences, stated plainly:** every GUI walk (each unit's pre-flight
walk, the orchestrator's walks), the GUI legs of the live rounds (approving a client and minting a
grant in the pane, watching faces), and the OPUS UX-REVIEWER WALK cannot run until she unlocks —
so her refresh condition (3)+(4) cannot be met tonight, and **the /Applications refresh is HELD**
unless she unlocks before the closeout. What still runs: headless suites, the Mac `xcodebuild test`
suites (they ran green under the lock at U1), offscreen render harnesses (U1's
`MCPGrantSheetCaptureTests` precedent — real views rendered to PNG, NOT a walk and never called
one), the cold code ladders. Each unit's record says which of its walk legs are held; the handoff
carries the held walks as her first morning items.

## ORCHESTRATOR ADJUDICATIONS ON U1 (2026-10-11 ~04:20, Opus — each a FABLE-OWED row)

- **T-2 CONCURRED (F-9):** canon outranks a plan clause — AppSpec §12's "everything unreachable
  answers ONE uniform not-shared shape — no fenced-vs-unshared oracle anywhere" and the 13n-b
  handoff's promise to her both say what U1 built; AF-6's "`fenced` gains the said sentence" was
  the outlier (CLAUDE.md: if code conflicts with the spec, align to the spec). The ask still
  reaches HER.
- **F-7 RULED (a) and built by the orchestrator (`df704250`):** a fenced BOOK answers the same one
  answer (the same canon letter; (b)'s premise — only a client that once read the book knows its
  id — does not survive a Private mark set after the read, which is exactly the case to protect).
- **F-8 left UNBUILT on purpose:** the `rungTooLow` edge lives inside `MCPGrantRule.decide`, the
  security rule itself — Fable's eye first.
- **The perf-benchmark sighting:** `PerfBenchmarkTests.timelinePageIsFlatOrUnderBudgetInCorpusSize`
  red once in the whole-package run at `df704250` (load-sensitive wall-clock bound), green alone —
  not this diff; recorded here as a watch item (VX-34's harness-calibration family).

## 1. What this phase is

The launch-readiness round for the MCP door — *a real user, with hundreds of books and notes, can
find, grant, watch and undo the door without reading a manual, and their AI is told how the door
works.* Five threads, one theme: the fence made right (R-AIR-1); the grant road made clear (the
sheet, grant-in-place, the icon, the in-note indicator); quiet signals and the keyboard (asks
wait, chords, the wing switcher); the docs (the guide chapter + the AI's advice + the setup menu);
the wing on the wire (VX-160/158, gatherings under a wing grant), then VX-159 and the secret.

## 2. Binding principles — the 13b constitution (copied VERBATIM per the architect-phase skill)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**Applications specific to 13n-c:** every new door (Share with AI…/its R-AIR-8 re-wording, ⌥⌘A,
⌥⌘, ⌘L, Waiting's Answer…, the icon's click, the setup menu) is declared ONCE in the capability
registry and walk-covered (P-1); a face that cannot act is not rendered — no approved client ⇒ no
share face, zero-states route to Settings ▸ MCP (P-2 + R-AIR-8); the badge/indicator read ONE
observable projection, never a broadcast (P-4); the fence stays ONE derivation site
(`Queries.mcpNoteFacts`/`mcpBookFacts`) consumed by the ONE pure rule — no parallel SQL fence
anywhere (the 13n-b discipline); the guide chapter is executable spec (P-6 — `TutorialWalkTests`
green, every sentence true of the build).

## 3. The units (acceptance units — `notes/PhaseSizingGuidance.md`)

Every unit: a fresh `opus-implementer`, briefed by its section below + the environment traps;
LIVE STATUS in its UNIT RECORD from its first commit; tests at the unit's END (the 13n-b closeout
is the baseline: core 2,580/295 · VariorumMCPTests 65/8 · workbook 40/6 headless; Mac whole
target 4,212/687 with the standing reds VX-115 and VX-149); the orchestrator verifies claims by
its own hands and WALKS (or live-rounds) before the record closes.

### U1 — The fence re-key (VX-163 · R-AIR-1 · R-AIR-3's words) — FIRST; the riskiest

**Builds:**
1. **The derivation (`Queries/MCPGrantQueries.swift`, the ONE site):** `mcpNoteFacts`' member leg
   narrows from `r.profile IN ('journal','daily')` to `r.profile = 'daily'`; `mcpBookFacts`'
   journal leg likewise; `mcpGrantableBooks`' exclusion likewise (a trait book is OFFERED). The
   note's OWN `profile='journal'` leg STAYS (D-1). Doc comments rewritten to say exactly this.
   Every downstream reader (the grant op's `mcpGrantScopeFenced` refusal, `mcpNoteSharing`,
   `mcpReachableBookIDs`, Allow-AI-here, the server tools) follows by construction — VERIFY each,
   change none unless it re-derives (it must not).
2. **The pins (ruled behavior + the byte-identity ritual):** a trait book is grantable (the op
   lands; it was `mcpGrantScopeFenced`); a trait book's member note is readable under a book
   grant, a wing grant on its wing, and the open book; the daily Journal's member entries stay
   fenced under every standing grant and the open book; a ⌘J entry (own profile) filed into a
   TRAIT book stays fenced (D-1); Private still wins ties (a Private trait book; a Private note in
   a trait book); **byte-identity EXTENDED:** under a Home-wing READ grant, a daily-Journal entry's
   `read_note`, a Private note's, and a nonexistent id's answers are BYTE-IDENTICAL, and `search`
   for a word only a daily-Journal entry holds returns zero passages exactly as a word nowhere does
   (her Air-round caveat: "the decisive fence-vs-scope proof re-runs under a Home-wing read
   grant"). The pre-existing pins asserting the OLD trait leg are updated as the ritual, each named
   in the record. **Mutation-check** (13n-b's discipline): widen the narrowed leg back → the new
   pins red; drop the own-profile leg → the ⌘J pin red; restore from the committed tree.
3. **Copy truth (J8 — sentences R-AIR-1 makes false):** the six sentences the brief §9 lists
   (`SettingsCatalog` row `mcpOpenBook`, `MCPPaneCopy.wingDetail`, `openBookDetail`, `noBooks`,
   the `.mcpGrantScopeFenced` refusal, `MCPAskCopy.lead`'s journal case) to the brief's
   recommended words ("…your daily Journal and anything Private…"); AND an app-wide grep for every
   OTHER shipped sentence asserting journals are never shared (the field guide's privacy chapter,
   the Private mark's captions, the handoff-era helper rows) — each fixed or listed SAFE in the
   record. **R-AIR-3:** the grant confirm on every BOOK grant reads her sentence shape — "Grant
   <rung> in “<book>” <duration>, including to future entries." (her verbatim example: "Grant read
   in “dream journal” always, including to future entries."); the wing confirm gets the parallel
   clause per D-3. (Duration words other than "always" keep the clause — membership is live for
   any duration; PROVISIONAL inside P-13nc-3.)
4. **Zero `Sync/`** (D-5 — re-verified), zero schema, zero editor seam, zero custody.

**Evidence (use-shaped):** headless pins + mutation checks; Mac `MCPPaneTests` /
`MCPAskAndReceiptTests` / `MCPEditFacesTests` / `SettingsShapeTests` under a held stage claim;
then the orchestrator's **REAL Claude Code live round** on the dev-store Debug build: a trait book
granted (the confirm's words on screen), its notes read; a Home-wing read grant — the daily
Journal entry's unique word searched → zero passages, its id read → the one not-shared answer
byte-equal to a made-up id's; a Private note likewise.
**Cold review:** `fable-reviewer` round 1 (her budget's FIRST spend — this is the security
boundary). Round 2 per the ladder.

### U2 — The grant sheet rebuilt (VX-156 items 1 · 6 · her sort/favorites/recent · L1)

**Builds:**
1. **Core, pure:** `PlaceLabels` (Domain) — the context line in its fixed order (shelf · N notes ·
   state marks · last edited) and `disambiguate` (the collision ladder over the OFFERED rows:
   wing → shelf → note count → state → made day → made time; case- and diacritic-insensitive
   sameness; never an invented ordinal). Swift Testing, exhaustive collision sets.
2. **Core, the picker's read:** the grantable-places query grows what the sheet shows at scale —
   per book: shelf (id, name, position), starred, member count, state marks, last-edited (derived
   as the Bookcase's "last edited" is), made-at; per note (the "A note" feed): the bounded
   `NotePickerSource.corpusNotes` road (wing-scoped, snippet + day), plus a **recently edited**
   section (the N most recently edited notes/books — N a constant, PROVISIONAL). P1: ∝ the page /
   the books (author-scale), never the corpus of notes.
3. **The sheet (`MCPGrantSheet`):** WHERE as "A note · A book · A wing" with `SearchPicker` (the
   ONE picker control, R-17y-3; `createLabel: nil`); the book list **grouped by shelf in the
   Bookcase's strip order with the starred books first** (her "sort by shelf … favorites"; an
   in-picker toggle between "by shelf" and "a–z" if it fits the idiom — PROVISIONAL), each row's
   context line + the disambiguator on collision; the **recently edited** quick section at the top
   before typing (her "that's often what I want"); **WHO** row (`SearchPicker` over approved
   clients, most recently granted first) whenever the opener is not a client row; durations
   shrunk to what EVERY picked target can take, with the one-line why; the confirm names the place
   WITH its disambiguator and carries R-AIR-3's clause (U1's words).
4. **R-AIR-8 in the sheet and the pane:** settings-class wording without "AI" (the brief's
   "grant MCP permissions"-class; final words hers — build the most neutral, PROVISIONAL); **L1**
   — the pane's A-4 sentence under Clients, the brief §12's words.
5. **The ask sheet and the pane's shared rows** wear the same disambiguated labels (one rule).

**Evidence:** the walk, both voices, on a dev store seeded to scale (≥150 books across ≥8 shelves,
some starred, two same-named books, ≥500 notes — the implementer seeds via ops in the DEV store
only): find a book by typing, find it by shelf, pick a starred one, tell two same-named books
apart and grant the right one, grant a note from "recently edited", a fenced note offers only
once/while connected with the why. Mac suites for the sheet/pane/registry.
**Review:** stage B's combined opus ladder (§5).

### U3 — Grant from where you are + the one icon + the in-note indicator (VX-156 item 2 · ⌥⌘A · R-AIR-4/6/7 · VX-164)

**Builds:**
1. **Core:** a bulk grant op — N note grants in ONE transaction on ONE stamp (refusals are the
   existing ones; a fenced note never takes "always"; a missing note refuses the WHOLE act —
   PROVISIONAL), state-transition tests; the pane's Shared list groups rows minted on one stamp
   (the exact-stamp doctrine; no schema).
2. **The doors, each opening THE grant sheet pre-filled** (registry-declared, R-AIR-8-worded,
   rendered only with an approved client): the Library bulk bar ("Share N notes…"-class),
   `postRowMenu`, `BookRowMenuTable` (Bookcase + Library book rows), the Book Settings grant row.
3. **⌥⌘A — share the note you're in** (D1: the newest grant's client + rung; while connected if
   connected, else once; never always by a key; no history ⇒ the sheet with WHERE = this note;
   already reaching ⇒ the refusal). **R-AIR-4:** the receipt carries a door that opens the sheet
   PRE-FILLED on what was just shared (to change rung/duration fast) beside Revoke. Edit menu,
   beside ⌥⌘Z/⌥⌘O; chord sweep re-run at the tip, recorded beside the binding.
4. **R-AIR-6 — the ONE AI-shared icon:** an SF Symbol in the sidebar set's language (the
   implementer proposes 2–3 candidates with captures; the orchestrator picks; PROVISIONAL —
   hers), replacing the Bookcase's "shared with AI" TEXT chip everywhere it renders; hover names
   who reaches it and how far; click shows the permission (a small popover: client · rung ·
   duration · the WHY when the reach comes from a wider grant · Change… · Revoke).
5. **VX-164 — the in-note indicator** (R-AIR-7): with MCP on and ≥1 approved client, the note's
   upper right shows the shared icon (the same popover, with "readable through the Home wing
   grant"-class why), a LOCK when Private (click → the Private toggle), and an empty state that
   says nothing (calm). Chrome only — NOT the editor seam (if any piece would need
   `EditorTextView`/`BlockRangeIndex`/`PaneSurface`, STOP and fork). The pending-ask leg is U4's.
6. **The "why":** a pure core function (grant rows + note facts → the reaching grant's scope:
   note / book "X" / wing "Y" / the open book) beside `mcpNoteSharing`, consulting the ONE rule.

**Evidence:** walk, both voices: three notes shared from the Library in one act → ONE pane row →
revoked in one; a book shared from its row menu and from Book Settings; ⌥⌘A with and without
history and when already reaching; the receipt's adjust door; the icon on the Bookcase and in a
note, its hover and its popover's why; a Private note's lock; with NO approved client none of
these faces render. **Review:** stage B.

### U4 — Asks wait quietly + the keyboard (VX-156 items 4 · 5 · VX-157 · the shortcuts pane)

**Builds:**
1. **The ask projection:** an observable map from `MCPDoor`'s queue keyed by target (note · book
   · wing); the pending-ask ICON (R-AIR-6's family) on: Library/Pool rows, the book TOC rows, the
   bottom bars' note ▾, Bookcase rows, the wing switcher rows, the in-note indicator (U3's), the
   masthead; hover names the client(s); her press opens THAT ask's sheet (her press — etiquette
   intact). Never raises, never scrolls, never toasts.
2. **Arrival X:** the WindowGroup-level `.sheet(item:)` that self-presents `presentedAsk`
   (`VariorumApp.swift`) RETIRES; Settings ▸ MCP gains **Waiting** (Answer… per row, the "all N ›"
   road, newest first). The wire is unchanged. P-13nb-U2-9's arrival is superseded (record it).
3. **⌥⌘, — MCP Settings…** (the Variorum app menu, under Settings…): opens Settings at MCP,
   scrolled to Waiting when an ask waits.
4. **⌘L — the wing switcher (R-AIR-15):** ⌘L opens the switcher as a type-to-filter picker;
   holding ⌘ and tapping L again cycles the highlight (⌘-tab idiom), releasing ⌘ commits; return
   commits; Esc closes; the masthead switcher clicked without typing CYCLES to the next wing;
   present on the Bookcase AND the **Library** masthead (round 5); the "Now in …" receipt speaks.
   The switcher carries one quiet line that Snippets is the one room shared by every wing (round
   5). Bare ⌘L re-verified free across the registry ritual at the tip (record the sweep).
5. **The shortcuts pane + ⌘/:** `HelperView.groups` gains every chord this phase adds (⌥⌘A,
   ⌥⌘, ⌘L) and an MCP group carrying ⌥⌘O/⌥⌘Z's AI rows; the Settings search reaches them.
6. **"While connected" copy options** (her ask): 2–3 options in the record, build the most
   neutral (PROVISIONAL, her pick at the copy pass).

**Evidence:** walk, both voices: a real client's ask arriving while she types (nothing appears;
the icon does), answered from the icon and again from Waiting; ⌥⌘, landing at Waiting; ⌘L
filtered, cycled by held-⌘ L, committed; the masthead click cycling on both mastheads; the
shortcuts pane and ⌘/ listing the new chords. The ask leg with a REAL Claude Code client.
**Review:** stage B.

### U5 — The guide, the AI's advice, the setup menu (her docs ask · D-2 · R-AIR-13 · round 5)

**Builds:**
1. **The field guide's MCP chapter** (`TutorialSeeder.plan` — after the privacy chapter, or
   inside it if the plan reads better; record why): what the door is; turning it on; setup (the
   per-client menu); the four rungs; scopes (note · book · wing, gatherings ride wing grants once
   U6 lands — written TRUE OF THE BUILD AT THE MERGE); durations; the fence (the daily Journal and
   anything Private ask every time); **snippets are not reachable through the door at launch**
   (said plainly); wings are separate libraries and Snippets is the one shared room; every AI act
   undoes with ⌥⌘Z naming the client; receipts, Open ›, ⌥⌘O; where to see what an AI can reach
   (the icon, the in-note indicator, Settings ▸ MCP); asks wait at their icon and in Waiting. Each
   lesson sentence TRUE of the shipped build; `TutorialWalkTests` + the chapter's own truth pins.
2. **The AI's advice — `MCPSession.instructions`:** the same facts, terse and imperative for a
   model (what the rungs allow; ids are live, re-read after structural acts; ask the author rather
   than retrying a refusal; nothing is shown in the app unless she asks; snippets are out; the
   document format v2's marker). Bounded length (state it); pinned so it never drifts silently
   from the catalog.
3. **R-AIR-13 — the setup menu:** "Copy setup command" grows a per-client menu — Claude Code
   (today's `claude mcp add -s user …`), Codex (its MCP config shape — the ONE Sonnet subagent
   fetches the current Codex CLI syntax as an external fact, read-only), and a generic
   "path / JSON" (the binary path + a standard `mcpServers` JSON stanza); the pane says the door
   is a standard MCP stdio server at one binary path. Debug keeps `variorum-dev` (P-13nb-U1-10).
4. **The real store's guide:** the closeout re-seeds the field guide via the product door behind
   the A1 rail (the skill's rule) — U5 records the door it will use.

**Evidence:** the chapter walked on the dev store (both voices) and every sentence checked against
the build; a REAL Claude Code client connects and its first turn states the advice back (the
instructions arrived); each setup menu item's copied text verified by running the Claude Code one
(throwaway `-s local` registration, removed after) and parsing the JSON one. **Review:** stage B.

### U6 — The wing on the wire (VX-160 · VX-158 · R-AIR-12)

**Builds** (the DRAFT's U3, ruled shapes): `move_note_to_wing` over her `moveNoteToWing` —
R1 (source decided at EDIT through the ordinary rule; destination through `decideWing` at WRITE
NEW on that wing; both re-decided INSIDE the act's transaction; once grants spent atomically);
T1 (tag adoption mirrors her door); U1 (ONE client-named undo entry with an exact-row inverse —
wing back for the note and its versions, severed memberships revived on their exact stamp,
applications re-pointed back; minted tags stay as vocabulary — plus its exact-row redo); her
refusals byte-for-byte; `move_block`'s cross-wing refusal stays. `show_in_app` gains the `wing`
target (`MCPShowRule` unchanged; decided at read with `decideWing`; never spends a once grant;
"Now in …" names the client). **R-AIR-12:** a wing grant's reach includes the wing's GATHERINGS
as read facts — `list_books` lists them (kind gathering), their assembly readable with every
member filtered through the per-note fence (a fenced member never lists, never counts — the
honest-count rule); gatherings stay NON-targets (no grant names one; a book/note grant does not
reach a gathering). Rung proofs grown as the ritual (read/suggest/write-new cannot move a note
across wings; a book grant cannot name a destination; a fenced note moves only under a per-ask
note grant), mutation-checked.
**Evidence:** `VariorumMCPTests` + core state-transition pins headless; a REAL Claude Code live
round in her sweep's shape (two wing grants; several notes moved Home → a second wing; one ⌥⌘Z
walks one move back with memberships and tags; a finished book's member refused in her words;
`show_in_app` to a wing frontmost and refused behind; a gathering read under a wing grant with a
fenced member absent). **Review:** stage C (opus ladder) + FABLE-OWED rows (grant boundary, a new
inverse over a cross-library move, the gathering reach).

### U7 — VX-159: the ceremonies on the wire (R-AIR-10, PROVISIONAL shape)

`divide_block` / `merge_blocks` gain `preset` (keep_on_top · keep_below · copy_to_both ·
choose_per_take; bring_every_take · only_the_two_shown · pair_by_hand) and the per-take payloads
of brief §11 P1 (`takes: [{take_id, second_half_starts_with} | {take_id, rides}]`, `pairings`,
`carry`); every phrase exactly-once inside the act's transaction; the U3-ladder F2 composition
guard binds every per-take phrase; the default call stays today's byte-for-byte. Live round:
divide a fanned block per take, pair a merge, ⌥⌘Z each. **Review:** stage C + FABLE-OWED.

### U8 — R-AIR-14: the per-setup secret (K2) — LAST; launch never blocks on it

A LOCAL-ONLY migration (own commit, the v1_24 family's registration road; zero lockstep, marker
13 untouched); the setup command carries a fresh secret; the shim sends a one-line preamble
before the first frame (A-2's "protocol-blind" becomes "MCP-blind" — said in the record); the
server binds the first name that presents it at approval and refuses a name arriving without its
secret; the pane's boundary line (L1) stays TRUE and is not reworded to promise more. Its evidence
is a DRILL (a fresh client set up end to end; two tools under one name told apart; a bare shim
refused). **Review:** opus ladder + FABLE-OWED (the secret's accept path is named in her protocol).

## 4. Sizing — said plainly (guidance to raise, R-cor-13)

- **Eight acceptance units; NONE phase-sized** (no new mode/board, no token pass, no lockstep
  event, no posture — U8's column is LOCAL-ONLY). So the phase sits inside the
  two-phase-sized-units line — but **eight implementer sessions plus walks, live rounds and
  ladders is more than one night holds.** This record says so rather than trimming silently.
- **The order is the launch-critical order:** U1 (her fence ruling, the riskiest — maximum soak
  before launch, per her protocol) → U2 → U3 → U4 (the grant UX she asked to be CLEAR) → U5 (the
  docs she asked for, written against the built UX) → U6 (R-AIR-2's ratified sweep) → U7 → U8.
- **What may fall out tonight, named now:** U7 (VX-159) and U8 (the secret) — each has its
  detailed design already in-phase (brief §11 / §12 and §3 above), satisfying S4-16's deferral
  condition; if they do not land they become named follow-on tickets on the board at closeout,
  never vagueness. U6 is attempted before them. **The closing condition reads "complete" against
  the units that landed AND the fall-out stated here** — the handoff says exactly which.
- **Her morning:** whatever lands is walked and live-rounded; the handoff carries the exact state.

## 5. The ladders and the FABLE budget (D-4)

- **Stage A = U1 alone:** `fable-reviewer` round 1 (her ~4% Fable — spent HERE FIRST); fixes;
  round 2 (`fable-reviewer` if the budget holds, else `opus-reviewer` + a FABLE-OWED row).
- **Stage B = U2 + U3 + U4 + U5 — ONE combined `opus-reviewer` ladder** over the stage's diff
  (chrome, composition and faces — no editor seam, custody, `Sync/` or default's-meaning content;
  the skill's "one ladder per stage over the combined diff"), round 1 → fixes → round 2. Any
  default's-meaning content found inside (the bulk grant op's refusal set, the ask arrival) gets a
  FABLE-OWED row.
- **Stage C = U6 (+ U7) — `opus-reviewer` ladder + FABLE-OWED rows**; any remaining Fable budget
  goes to ONE targeted cold review of the riskiest diff left (her protocol: the fence classifier +
  the secret's accept path).
- **U8 — its own `opus-reviewer` round + a FABLE-OWED row.**
- **THE OPUS UX-REVIEWER WALK (her condition 4):** a fresh Opus session walks the dev-store
  Debug build hands-on, both voices, with a brief to FLAG problematic flows, hard-to-find buttons,
  weird spacing or looks (not code) — its findings are a ladder round: each fixed (in a fresh
  session) or dispositioned in writing, repo-first.
- **Model labels lie (the memory record):** every reviewer states its own model id at the top of
  its record; the orchestrator records which model ACTUALLY reviewed.

## 6. THE FABLE-OWED LEDGER (her protocol — written AT THE MOMENT, never reconstructed)

**VX-166** (born at her Air session) is the post-phase Fable verification sweep: at her credit reset a Fable session walks this table and runs cold reviews in sensible ladders. One row
per adjudication decision or diff that would ordinarily earn a Fable review.

| # | Commit | Diff scope | Why owed | Reviewed by (actual model) |
|---|---|---|---|---|
| F-1 | `9b1ec3dd` | D-1 — the ⌘J edge kept (the note's own `profile='journal'` leg) — R2-2: no shipped door clears a note's own day shape, so a ⌘J entry stays per-ask forever wherever filed (#211 options) | default's-meaning: what the fence covers | — |
| F-2 | `9b1ec3dd` | D-2 — docs delivery (guide chapter + `instructions`) | product-shaped call made by Opus | — |
| F-3 | `9b1ec3dd` | D-3 — R-AIR-3's clause extended to wing confirms and every duration | wording of a disclosure confirm | — |
| F-4 | `9b1ec3dd` | D-5 — the Sync/ fold classifiers judged untouched by R-AIR-1 | a Sync/-adjacent trace judged by Opus | — |
| F-5 | `63e70d67` | U1 — the fence classifier itself: the journal legs re-keyed on `'daily'` (`dailyJournalLegForBook`, three sites) + the ⌘J own-profile leg kept — R2-4: 'Use as Daily Journal' (Mac + phone, synced marker) now MOVES the fence; the outgoing book's hand-filed notes un-fence (pinned) | her protocol names the fence classifier; default's-meaning (written by the U1 implementer, Opus) | — |
| F-6 | `1a311c8e` | U1 T-2 — a fenced NOTE answers the ONE `notShared` answer on every tool, never the asked sentence (REVERSES 13n-b AF-6's "`fenced` gains the said sentence" for notes; aligns with AppSpec §12's no-oracle line and the brief's byte-identity) | refusal uniformity at the security boundary — a ruled clause reversed on an Opus reading (written by the U1 implementer) | — |
| F-7 | `df704250` | U1 fork RULED (a) by the orchestrator (Opus) and BUILT by its own hands: a fenced BOOK answers the one `notShared` answer too, byte-equal to a book id naming nothing (pins red-on-old, 4 issues) | refusal uniformity at the security boundary, ruled AND written by Opus | — |
| F-8 | — (recorded, NOT built) | U1 edge: a client holding a per-ask READ grant on a fenced note that asks to SUGGEST hears `notShared` though it can read the note; the honest answer is `rungTooLow` + the asked sentence — a three-line change inside `MCPGrantRule.decide` | the security rule itself — left for Fable's eye, deliberately unbuilt | — |
| F-9 | (the U1 adjudication commit) | T-2 CONCURRED by the orchestrator (Opus): AppSpec §12's no-oracle contract line outranks 13n-b AF-6's fenced clause (a plan ruling); the visible cost — a client that read a note hears the one answer once she marks it Private — accepted | an Opus concurrence reversing a Fable-ruled clause | — |
| F-10 | `c1047097` | U1 ladder R1 F1 — `MCPGrantRule.decide` answers `rungTooLow` before the fence when a LIVE grant reaches the note (the security rule itself) | written by Fable (the round-1 reviewer, cross-model flow) but NOT re-reviewed by Fable — her budget died right after; round 2 is Opus | — |
| F-11 | `c356871a` | U3 — the BULK grant op `grantMCPAccess(_:notes:…)`: its refusal set (missing/non-note/version target → `mcpGrantScopeNotFound`; a fenced note under always → `mcpGrantScopeFenced`) and ANY refusal refusing the WHOLE act (P-13nc-U3-1); every note through the one `insertMCPGrant` | the grant op's refusal set is default's-meaning content (the plan §5 names it) — written by the U3 implementer (Opus) | — |
| F-12 | `c356871a` | U3 — Change… as REPLACE (`grantMCPAccess(_:_:replacing:)` + the bulk form): the named grants revoked and the new minted on ONE stamp; a grant not this client's refuses `mcpGrantNotFound`; a refused new grant leaves the old standing (P-13nc-U3-3, T-U3-8) | a new revoke road beside the grant op — who may change what — written by Opus | — |
| F-13 | `c356871a` | U3 — `MCPGrantRule.reach` added INSIDE the rule file (the faces' WHY = `decide`'s own `.allow(grantID:)`, non-consuming probe; `decide` untouched) + `Queries.mcpNoteReach`/`mcpBookReach(es)` (the wider place named) | a new function in the security rule's file; the in-note indicator's "never surprised" promise rests on it — written by Opus | — |
| F-14 | `e41a9328` | U3 — the permission popover's Revoke on a WIDER grant (a book's popover revoking the Home wing grant that reaches it; P-13nc-U3-6), and the share doors' render gate (R-AIR-8: an approved client; P-2: never on a gathering, THE daily Journal or a Private book — `Queries.mcpFencedBookIDs`, the fence's own fragments) | what a face offers to revoke and where a grant door may appear — Opus | — |
| F-15 | `6f39cd18` | U4 — ARRIVAL X: the self-presenting ask sheet retired (supersedes P-13nb-U2-9, a 13n-b Fable-reviewed provisional); the queue's cap now protects the asks SHE opened; `answer` acts only on an ask still waiting (T-U4-5 — one ask, one grant, pinned red-on-old); a denied client's asks forgotten (T-U4-4, pinned red-on-old); the wire untouched | "the ask arrival" is named in §5 as default's-meaning content, and the answer road MINTS GRANTS — written by the U4 implementer (Opus) | — |
| F-16 | `6f39cd18` | U4 — "while connected" → "until it disconnects" in every grant face, the confirm and the ask's button (P-13nc-U4-1) | wording of a disclosure confirm (F-3's class) — chosen by Opus among recorded options | — |
| F-17 | `75945f33` · `a6e2f484` · `49c7f589` | U5 — the user's and the model's STATEMENTS of the fence and the one answer: the guide's "what always asks" lesson (no book grant, wing grant or open book reaches the daily Journal's entries or anything Private; one note at a time, never always; a ⌘J entry keeps asking wherever filed — P-13nc-4 (a); snippets unreachable; "something it can't reach looks exactly like something that isn't there") and `MCPSession.instructions`' fence/refusal sentences ("Anything you can't reach answers exactly as if it did not exist"; "If a call is refused, don't retry around it") — each pinned against the rule's own reads (`TutorialMCPChapterTests`, `MCPAdviceServerTests`) | disclosure accuracy at the security boundary (the privacy chapter's own warning: a lesson that lies about a security feature is the worst stale copy) — written by Opus | — |
| F-18 | `cbdef1fc` · `c356871a` | U3 — ⌥⌘A's MINT ROAD (`MCPShareChord` + `mcpNewestGrant` + `MCPDoor.shareThisNote`): one keystroke grants at a rung and duration taken from history, with revoked rows counting (an Opus reading of the brief's "the last grant she made") | what a key grants is default's-meaning content (F-11/F-12's class) — written by Opus; raised by Stage B R1 B12 | — |
| F-19 | `0a5fd108` | Stage B B2 (extends F-15) — the ask's ANSWER ROAD reads CURRENT facts: her open re-reads the target through `MCPDoor.askStanding` (`mcpNoteFacts`/`mcpBookFacts`), a client's re-raise refreshes the waiting payload (stamp kept), a gone target FORGETS its ask, and a book fenced since offers NO grant (`durations` empty; the lead says why) — the answer road mints grants | the ask arrival/answer is named default's-meaning content (§5); written by the Stage B fix implementer (Opus) | — |
| F-20 | `e3e50161` | Stage B B1 (MAJOR, F-17's class) — lesson 1's privacy sentence: only the GRANTS stay on this Mac; "What a client reads goes wherever that client sends its work: for most clients, the company that runs its model." (P-13nc-SB-1) | disclosure accuracy at the privacy boundary — the words a user trusts about where her text goes, written by Opus | — |
| F-21 | `0a5fd108` | Stage B B4 (F-14's class) — Book Settings' grant row gated on the fence's own facts (`BookSettingsModel.isGrantable` = `mcpBookFacts(...).fence == nil`), held with the reach; parity-pinned to `mcpFencedBookIDs` | where a grant door may appear (F-14's class) — Opus | — |
| F-22 | `4014da37` · `e955a86e` | Stage B close-out R2-1 (extends F-19) — THE ASK WATCH forgets waiting asks without her press: one observation while an ask waits, named on `reading` + `wing` through the new `AppDatabase.observe(tracking:_:)` (constant-region tracking), re-validating every waiting ask through `askStanding` in one read, plus Waiting's render; a gone target's ask leaves silently, and her press on one says so (`MCPAskCopy.gone`); the measured limit (a note's death is indistinguishable from an autosave) pinned in `RegionObservationTests` | the ask arrival/answer road is named default's-meaning content (§5) and this decides when an ask stops waiting; a new Persistence-layer observation API — written by the close-out implementer (Opus) | — |
| F-23 | `9f42f076` | U6 — `MCPGrantRule.decideGathering` added INSIDE the security rule's file (R-AIR-12: a gathering reached only by wing-level reach on its wing at READ — `decideWing`'s read, the open book included (P-13nc-U6-5) — never consuming, a fenced one the `.fenced` decision) + `Queries.mcpGatheringFacts` (one statement with `mcpBookFacts`, the same two fence fragments) | the grant boundary + a new reach (the plan §3 U6 names "the gathering reach") — written by the U6 implementer (Opus) | — |
| F-24 | `9f42f076` | U6 — the NEW INVERSE over a cross-library move (`revertMCPWingMove` / `reapplyMCPWingMove`): the exact rows read before/after her act inside its transaction; revival rules (finished yes, sealed only for a sealed note, one wing, no live pair, purge intents voided, the ownership revival pass); the divergence REFUSAL (P-13nc-U6-3) and the OBSOLETE buckets; her `moveNoteToWing` body extracted into an in-transaction twin | "a new inverse over a cross-library move" (the plan §3 U6) — exactly the undo doctrine's hardest class; written by Opus | — |
| F-25 | `254bd26f` | U6 — `move_note_to_wing`'s GRANT BOUNDARY: R1's two decisions (the note at EDIT through `decide`; the destination wing at WRITE NEW through `decideWing` — a book grant can never name a destination), the snapshot's one ask (source first), `guardWingMove` re-deciding both inside the act's transaction on one standing read with the once grants of both sides spent as ONE union (both or neither); the answer's names-with-grants rule (P-13nc-U6-2) and the frozen sentence's readability gate (P-13nc-U6-4) | the grant boundary (the plan §3 U6 names it) — a two-sided act across two libraries; written by the U6 implementer (Opus) | — |

**⚠️ HER FABLE BUDGET IS SPENT (04:52 MDT, HTTP 429 at the U1 round-1 reviewer's tail).** Fable
reviewed exactly ONE diff this phase: U1 at `9b1ec3dd..33bd8772` (round 1, `13nc-u1-ladder-round1.md`
— every adjudication T-2/F-5/F-6/F-7/F-9/D-1/D-3/D-5 CONCURRED there; F-1…F-9's "Reviewed by" column
for those rows reads that round). Everything after is Opus-reviewed with rows here.

## 7. Constraints (standing, restated)

- **`Sync/`: zero lines** (D-5). **Schema:** none in U1–U7; U8's LOCAL-ONLY column alone, its own
  commit first. Marker 13 untouched; no lockstep event.
- **Editor seam: none** — the in-note indicator and the bottom-bar icons are chrome; any piece
  needing `EditorTextView`/`BlockRangeIndex`/`PaneSurface` STOPS and forks to the orchestrator.
- **Etiquette is law (R-13nb-23/26g):** nothing an agent does raises a window, steals focus,
  queues UI or self-presents — arrival X makes the ask road comply fully.
- **The rung is the only read dial (R-13nb-17)** — no new read knobs; R-AIR-12 is reach of an
  existing scope, not a dial.
- **Copy:** the pane and its sheets direct and technical (R-13n-5) but without "AI" in
  settings-class wording (R-AIR-8); app-wide faces in the app's voice (P-13n-1); SENTENCE CASE,
  never capitals for emphasis (her standing rule); every new string 13s-a-sweepable.
- **Scale (her "hundreds of books and notes"):** every picker and list is searchable or capped
  with an "all N ›" road; P1 binds every query (∝ the page or the books, never the note corpus).
- **Stage:** walks, Mac suites, live rounds and any Debug-app launch under a held `Tools/stage`
  claim on the Pro; headless core work runs free. A live round's Claude Code client points ONLY at
  the dev-store Debug app (throwaway `-s local` registration in a scratch folder, removed after) —
  NEVER her real store or the /Applications build.
- **MOBILE PARITY:** nothing mobile-visible expected — grants never sync, the phone has no door,
  R-AIR-1 changes no synced row; the field guide chapter IS seeded content (check whether the
  phone seeds the guide; if so, the parity line says what the phone shows). Said at closeout.

## 8. Environment traps (carried VERBATIM from 13n-b — every brief carries them)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH; treat real-store instances by STORE, not path —
NEVER quit/kill one; no Release builds or /Applications refreshes while
one lives. Mac tests run from `App/Variorum/` with suite-level
`-only-testing` ONLY, and EVERY `xcodebuild test` run (and any walk,
Debug-app launch, or dev-store reset) requires a HELD `Tools/stage` claim;
headless `swift build`/`swift test` on the core package is free. NEVER add
a custom build configuration (anything not named exactly "Debug" builds
the packages Release and strips the DEBUG oracles). Swift Testing's
"passed" count INCLUDES skipped tests — read the `skipped:` lines before
claiming a gated suite ran. zsh `pipestatus`. Walks: `cliclick` +
`Tools/WalkKit/` on the DEV-STORE Debug build only
(`io.lduarte.Variorum.debug`), under the held stage claim; screenshots in
gitignored dirs. Never `git checkout` over uncommitted work; push after
every commit; never force-push. Backups of any real store are WAL-safe
with UTC names into `Backups/safety-copies/` (the A1 rail).
**This phase's own:** a connected MCP client is pointed ONLY at the
dev-store Debug app during build and walk — NEVER at her real store or
the /Applications build; the live-round Claude Code session runs under
the SAME stage claim as the app leg it drives. The MCP SDK pin is EXACT
(0.x churn — R-13n-2); `swift package update` must never move it. The
shim probe and any TCC prompt answered on this machine is recorded in the
unit record (TCC state is machine-state the next session inherits).

## CLOSEOUT CANON-DELTA CHECKLIST (running — every item lands at the merge as a contract line + pointer)

- AppSpec §12 THE MCP DOOR line: "journal-class notes AND anything wearing the Private mark answer
  only a per-ask note grant" → R-AIR-1's keys (the daily Journal's entries + ⌘J entries (D-1) +
  anything Private); the no-oracle letter now true for books too (F-7); VX-162 — the durations
  "once · while connected · always" (always never on the daily Journal/Private, while connected
  only to a connected client).
- AppSpec §7 v1_25 bullet "journal-class fence" — wording REVIEWED (true of the Private mark's
  behaviour; keep or reword to "per-ask fence").
- AF-6's fenced clause superseded (T-2/F-7) — recorded as a pointer to this plan's U1 adjudications.
- R-AIR-1/-3/-6/-7/-8/-12/-13/-15 and round 5 as built — the new contract lines (the grant road,
  the icon + in-note indicator, asks wait, ⌘L, the setup menu, gatherings under a wing grant).
- AF-6's line also names U1 R1-F1's refinement: a LIVE per-ask grant holder asking past its rung hears `rungTooLow` + the asked sentence (R2-6).
- U5 (R-AIR-13, D-2) — AppSpec §12's MCP DOOR line: "setup is 'Copy setup command' (R-13nb-5)" → the per-client
  setup menu (Claude Code · Codex · any MCP client's JSON; "a standard MCP stdio server at one binary path" said in the
  pane); the field guide's MCP chapter (the guide is executable spec — P-6) and the server's `instructions` as the AI's
  advice (one set of facts, bounded and pinned). The 13s-a plan's item 6 then RE-VOICES the chapter rather than writing it.
- R-AIR-14 (if U8 lands) — A-2's "protocol-blind" → "MCP-blind".

## 9. THE LEDGER (running; every row owned)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Kickoff (ticket, worktree, in-flight row, this plan) | orchestrator | DONE |
| 2 | U1 — the fence re-key | U1 implementer + orchestrator | BUILT + VERIFIED; F-7 ruled (a) and built `df704250`; walk HELD (locked session) |
| 3 | Stage A ladder | orchestrator | **CLOSED at R2** — R1 fable (`4140860f`: 1M/2m/3n; F1 FIXED `c1047097`) → R2 opus (`6ec3d98c`: 0B/0M/4m/5n; R2-1/R2-4 pinned, R2-5 fixed; the rest routed) |
| 3b | **Stage A routed findings** — R1: F2 (R-AIR-3 on the ask road → U2/U4; a ticket if they fall out) · F3 + R2-6 (closeout checklist) · F4 (U2) · F5 + R2-8 (U5) · F6 + R2-7 (her copy pass) · R2: R2-2 + R2-4 (#211, hers) · R2-3 (U2) | U2/U4/U5 + closeout | OPEN — each closes where routed |
| 4 | U2 — the grant sheet | U2 implementer | BUILT + VERIFIED `49c964ea` — walk HELD |
| 5 | U3 — grant in place, the icon, the in-note indicator | U3 implementer | BUILT + VERIFIED `c6d5d23a` — walk HELD (locked); icon A kept PROVISIONAL (orchestrator); UX-walk watch: the icon reads small beside a Terminal-voice book name (capture `u3-bookcase-terminal.png`) — the UX reviewer is asked to judge it |
| 6 | U4 — asks wait, the keyboard, the wing switcher | U4 implementer | BUILT + VERIFIED `f1ab4725` — walk HELD; two order-dependent Mac reds predating U4 ticketed **VX-167** (red identically on U3's tree; green alone) |
| 7 | U5 — the guide, the advice, the setup menu | U5 implementer | BUILT + VERIFIED `065526ce` — walk HELD; the one cap-test red ("Unable to parse empty data") folded into **VX-132** by comment (Stage B R1 B14) |
| 8 | Stage B ladder (opus) | orchestrator | **CLOSED at R2** — R1 → fix pass `c6d8509c..9c049c6a` → R2 (0B/0M/1m/4n) → the CLOSE-OUT FIX PASS `6f7fc38f..3e8ccd83` VERIFIED by the orchestrator (zero trailers; the one `Persistence/` line is the purely additive `AppDatabase.observe(tracking:_:)` — no schema, no caller changed, F-22; core 2,623/300 · MCP 82/12 · Mac 537/76 green). The close-out range is not cold-reviewed after R2 (no new B/M earned R3), so **it joins Stage C's review range** and is named there. |
| 9 | U6 — the wing on the wire | U6 implementer | BRIEFED — spawned |
| 10 | U7 — VX-159 | — | FALLS OUT of the phase and the launch (her word 2026-10-11 ~14:15) — stays VX-159, unlabeled |
| 11 | Stage C ladder | orchestrator | FOLDED into the one combined fable ladder (the takeover schedule item 3) |
| 12 | U8 — the secret | — | FALLS OUT → **VX-168** (Pre-launch label; her gate: before launch, not before this refresh); kickoff prompt committed |
| 13 | The whole-phase walk + the Opus UX-reviewer walk | orchestrator + walker + UX reviewer | **Leg 1 DONE** — WALKS CLOSED at `82ad7478`, VERIFIED by the orchestrator (span `092f0472..82ad7478`: only the four fix surfaces + tests + notes, zero `Sources/`, zero trailers; the fixed pickers read on screen — rows render, the twice-sectioned book draws twice, the note leg's Private/Journal badges show; stage free, dev store restored, no instance). Live rounds (1)–(6) proven on a real client; D-W1…D-W4 fixed red-on-old; taste T-1…T-17 carried to leg 2. **Leg 2 (the Opus UX walk) runs after U6.** NOTE for leg 2: T-17 (a book popover's Revoke taking back the WIDER wing grant) is P-13nc-U3-6/F-14's DESIGNED behavior — the UX reviewer judges the FACE, the combined fable ladder judges the DESIGN; neither re-rules the other. |
| 14 | Closeout + the conditional refresh | orchestrator | NOT-STARTED |
| 15 | QUESTIONS #211 — this phase's PROVISIONALs (minted at the merge) | orchestrator | OPEN |

## PROVISIONALs (running — logged at the merge as #211)

- **P-13nc-1** — D-1 (the ⌘J edge kept).
- **P-13nc-2** — D-2 (docs: the guide chapter + the server's instructions; her alternative the
  first-connect book).
- **P-13nc-3** — D-3 (R-AIR-3's clause on wing confirms and on every duration).
- **P-13nc-4 (R2-2, hers)** — D-1's consequence: a ⌘J entry stays per-ask wherever filed; options (a) keep + say it · (b) membership only · (c) a later lift door.
- **P-13nc-5 (R2-4, hers)** — 'Use as Daily Journal' moves the fence: say what it un-fences at the door, or keep a demoted book fencing?
- ~~The snippets call~~ — RATIFIED at round 6 (out at launch, said in the docs).
- **P-13nc-U1-1** (U1) — R-AIR-3's confirm is a BUTTON label, so it carries no closing period (her sentence
  has one; no button in the app does). Alternative: the period, verbatim.
- **P-13nc-U2-1** (U2) — the grant pickers' "Recently edited" shows 5 books.
- **P-13nc-U2-2** (U2, R-AIR-8) — the pane's "Shared with AI" reads "Shared places" (alternatives: "Shared
  with clients" · "Permissions"); final words hers at the copy pass.
- **P-13nc-U2-3** (U2) — the book picker's layouts: "by shelf" (default) + an "a–z" toggle; Unshelved LAST per
  the brief (the Bookcase's All shows it first); the quick sections ride both layouts.
- **P-13nc-U2-4** (U2, F2) — the ask's reach line: "Any answer below grants it in “X”, including to future
  entries." (a wing's twin: "…, including notes added later.").
- **P-13nc-U2-5** (U2) — the virtual Home wing never joins a wing-name collision set (no made stamp).
- **P-13nc-U3-1** (U3) — the bulk share refuses the WHOLE act on any refusal (a missing/non-note target; a fenced
  note under always) — nothing written. Alternative: grant the grantable notes and report the rest.
- **P-13nc-U3-2** (U3, R-AIR-8) — the share faces' words: APP voice where the face is app-wide (P-13n-1 — the row
  menus "Share with AI…", the bulk bar "Share N notes with AI…", the Edit menu "Share This Note with AI", the
  receipts); SETTINGS-class faces carry no "AI" (Book Settings' "Shared with claude-code (read) · Share…" / "No
  client reaches this book.", the permission popover, the lock's help). Every string listed in the U3 record; her
  copy pass.
- **P-13nc-U3-3** (U3, T-U3-8) — a grant-specific Change… (the receipt's, the popovers') REPLACES the grant it names
  (revoked and re-minted on one stamp, one act; never another client's grant); the client row's Change… stays
  additive. Alternative: additive everywhere (a lowered rung would not land).
- **P-13nc-U3-4** (U3) — a grouped Shared places row names its first 3 members, then "and N more".
- **P-13nc-U3-5** (U3, R-AIR-6 — the orchestrator picks, hers at the copy pass) — the ONE icon:
  `point.3.connected.trianglepath.dotted` (Settings ▸ MCP's own pane glyph; outline, the sidebar set's language)
  at the row's small size; candidates B `eye`, C `antenna.radiowaves.left.and.right` (captured); U4's pending-ask
  sibling its filled twin `point.3.filled.connected.trianglepath.dotted` — **superseded at the Stage B fix pass (O-1):
  the pending mark is `questionmark.bubble`, P-13nc-SB-3.**
- **P-13nc-U3-6** (U3) — the popover's Revoke on a WIDER grant revokes THAT grant (the why line names it — e.g. "through
  the Home wing grant"); an open-book reach offers no Change…/Revoke (it is a switch — the row says where it lives).
- **P-13nc-U3-7** (U3, R-AIR-7) — the in-note indicator lives at the pane's ContextBar TRAILING end (every note
  mode, both window kinds) and renders only with the server switch ON + an approved client; the Bookcase icon keeps
  the retired chip's gate (an approved client reaches the book — P-13nb-U2-11), so with the server OFF the Bookcase
  still shows standing reach while the indicator hides. Alternative: the Bookcase icon also hides with the server off.
- **P-13nc-U3-8** (U3) — ⌥⌘A's Edit-menu item is HIDDEN (not grey) with no approved client (R-AIR-8's "renders ONLY
  when"); the share doors ride the Library's note rows (`postRowMenu`) and every book row menu — not yet the Pool's,
  the sidebar Open strip's or Starred's NOTE rows (not briefed; a follow-on if wanted).
- **P-13nc-U4-1** (U4, her round-2 ask) — "while connected" → **"until it disconnects"** everywhere the duration
  is said (options (b) "for this connection", (c) "this session" — the U4 record); her pick at the copy pass.
- **P-13nc-U4-2** (U4) — a pending glyph's press answers the ask that waited longest on its target; several are
  named together in the hover. Alternative: a small menu of the target's asks.
- **P-13nc-U4-3** (U4) — the masthead's wing word wears every waiting WING ask's glyph (not only the current
  wing's); the menu's wing rows wear it as a mark. Alternative: the current wing's only.
- **P-13nc-U4-4** (U4, R-AIR-15's room) — ⌘L opens on the current wing; ⌘'s release commits only after a held-⌘
  L tap (a plain ⌘L press-release leaves the field for typing). Alternative: the exact ⌘-tab.
- **P-13nc-U4-5** (U4, R-AIR-5) — the masthead word cycles only with two or more wings (the ▾ is the menu); the
  cycle and ⌘L's commit speak "Now in …"; the menu's own pick stays silent (13i-d). Alternative: the pick speaks.
- **P-13nc-U4-6** (U4) — Waiting renders only while an ask waits (the requests idiom); 3 rows + "all N ›".
- **P-13nc-U4-7** (U4) — the ⌘L switcher is a sheet (⌘K's idiom) with no per-wing counts (P1).
- **P-13nc-U5-1** (U5) — the MCP chapter's seat: LAST, after the privacy chapter, as the opt-in appendix (her R-13s-30
  "safety after the workflow and the workflow together" held whole). Alternative: between books and privacy.
- **P-13nc-U5-2** (U5) — the chapter's name "AI & the MCP door" + its six lesson titles; 13s-a re-voices.
- **P-13nc-U5-3** (U5, R-AIR-13) — the setup menu as a segmented row, all three in sight. Alternatives: a pop-up; a
  "Copy setup command ▾" menu button.
- **P-13nc-U5-4** (U5) — "Any MCP client", and the one button keeping "Copy setup command" when it copies JSON.
- **P-13nc-U5-5** (U5, D-2) — the advice's register (provisional). **The BOUND is RULED: 2,000 characters** — her word, 2026-10-11 ~12:00 MDT, relayed in the orchestrator session: "yeah let's do 2,000 because then we'll have a bit of wiggle room for future updates as well". The constant `MCPSession.instructionsBound` moves 1,500 → 2,000 in U6 (U6 edits the advice anyway; changing it now would shift the tree under the running Stage B R2 reviewer). The pin keeps its form.
- **P-13nc-SB-1** (Stage B B1, F-20) — lesson 1: "Your grants stay on this Mac — they never sync to your other devices. What
  a client reads goes wherever that client sends its work: for most clients, the company that runs its model."
- **P-13nc-SB-2** (Stage B B6) — ⌘L "Switch Wing…" grey with ONE wing; its note "There is only one wing so far — New Wing… in
  the masthead's ▾ menu makes another, and then ⌘L switches between them." Alternative: hide the item.
- **P-13nc-SB-3** (Stage B O-1) — the pending-ask mark `questionmark.bubble` (A — "a question is waiting for you"); B
  `hand.raised` (Apple's privacy surfaces wear it — near the Private lock), C the shared icon + an accent dot (the near-twin
  again at row size); captured `sb-pending-candidates-*`. Supersedes P-13nc-U3-5's "filled twin" tail.
- **P-13nc-SB-4** (Stage B B2) — a book ask fenced since offers no grant and says "This book is marked Private now, which no
  grant reaches — its notes are shared one ask at a time. Don't allow lets this ask go." (and the daily-Journal twin); B7's
  "…and how to set up Claude Code, Codex or any MCP client." and B9's "Allowing grants it in “X”, …" ride her copy pass.
- **P-13nc-SB-5** (Stage B close-out R2-1) — a press on an ask whose place is gone says "“X” is gone, so claude-code's ask
  was let go." (a wing: "The X wing is gone, …") as a refusal — on the window's status line, or the pane's caption when
  pressed in Settings; a forget by the ask watch or by Waiting's re-validation (a press she never made) is SILENT, and an
  open sheet closes as when its ask is answered elsewhere. Alternative: speak on every forget.
- **P-13nc-SB-6** (Stage B close-out O-4, her ask) — app copy names no provider outside the setup menu: the toggle sentence
  "so MCP clients can read…", lesson 1's "a standard way for AI apps to use another app's tools", lesson 2's limit card
  without "(claude-code, say)", the two Settings blurbs "any MCP client", and the client-named undo in PLACEHOLDER form —
  "Undo ‹name›'s take" (the ⌘/ helper and lesson 6); the search keywords add anthropic · openai · chatgpt · gpt · cursor ·
  gemini · copilot · windsurf · ollama. Alternative (O-4's own suggestion): a multi-provider example list ("any MCP client
  — Claude Code, Codex, Cursor and others"), which would need the source pin to admit example lists.
- **P-13nc-SB-7** (Stage B close-out R2-5) — the empty Activity line: "Nothing yet — the calls clients made recently are
  listed here." (lesson 6's own words).
- **P-13nc-U4-8** (U4, a QUESTION for #211) — the ask's sheet keeps 13n-b's answers; closing it without granting
  is Don't allow (Esc), which drops the ask until the client re-asks. Options: keep · add "Not now" · Esc keeps it
  waiting.

## UNIT BRIEFS AND RECORDS (written just-in-time below, one per unit)

---

## THE U1 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U1 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on
branch `vx-165-13n-c` (NEVER the main checkout `~/dev/variorum`). Commits say `Part of VX-163`
(and `Part of VX-165`), NO attribution trailer of any kind, push after every commit.
`notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in the "U1 UNIT RECORD" section below
from your FIRST commit, foreground waits only (poll a log with a `grep -q … && break; sleep 5`
loop, never `tail -f | grep -m1`), no subagents.

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM (the rulings, D-1…D-5, §3
U1, §7 constraints, §8 environment traps); `notes/plans/vx-156-grant-ux-design-kickoff.md` (the
sitting record — R-AIR-1, R-AIR-3); `notes/plans/vx-156-grant-ux-brief.md` §9 (the six
sentences and their recommended words); the 13n-b plan's SITTING RECORD R-13nb-1/-4 and the U1/U2
unit records' fence sections (`notes/plans/phase-13n-b-mcp-door.md`). Code:
`Sources/VariorumCore/Queries/MCPGrantQueries.swift` (THE ONE derivation site),
`Sources/VariorumCore/Domain/MCPGrantRule.swift`, `Operations/Operations+MCPGrants.swift`,
`Sources/VariorumMCP/MCPGrantAuthority.swift`, `App/Variorum/Variorum/Features/MCP/`
(`MCPPaneCopy`, `MCPGrantSheet`, `MCPAskSheet`), the Settings catalog row `mcpOpenBook`, and the
existing fence pins (grep `VariorumCoreTests`/`VariorumMCPTests` for `journal` + `fence`).

**What U1 builds:** §3 U1 items 1–4, exactly. In one line: the trait book stops being fenced, the
daily Journal and the ⌘J entry and Private stay fenced, the byte-identity of fenced = unshared =
nonexistent is pinned under a Home-wing read grant, every sentence that became false is fixed,
and her R-AIR-3 sentence is the confirm on every book grant.

**Must NOT touch:** `Sources/VariorumCore/Sync/` (D-5 — if you believe a line is needed there,
STOP and message the orchestrator with the exact lines), custody/keychain, the editor seam,
migrations, `lockstepVersion`, the real store, `/Applications`. No new parallel SQL fence — the
ONE derivation site only.

**Acceptance:** the §3 U1 pins + mutation checks headless; `swift build` + the whole headless
package at the end (core, `VariorumMCPTests`, workbook — VX-132: a `VariorumMCPTests` run stalled
far past normal is killed, noted, rerun, never chased); the Mac suites `MCPPaneTests`,
`MCPAskAndReceiptTests`, `MCPEditFacesTests`, `SettingsShapeTests`, `CapabilityRegistryTests` +
any suite exercising a source file you changed, under a HELD `Tools/stage` claim
(`Tools/stage claim <minutes> "<why>"`; release when done), suite-level `-only-testing`, read the
`skipped:` lines. A short pre-flight walk on the dev-store Debug build (stage held, Study and
Terminal): the sheet's trait book offered and its confirm's words; the new sentences on screen.
Screenshots into a gitignored dir (`notes/plans/13n-c-screens/u1/`). The orchestrator runs the
REAL Claude Code live round after your close.

**Forks:** anything beyond the recorded rulings returns to the orchestrator with a proposal BEFORE
that half is built; PROVISIONAL-and-log for non-gating ambiguity; STOP for anything gating.

**Close:** a "UNIT CLOSED" banner atop your record naming what is NOT done, your PROVISIONALs,
where a cold reviewer should look first, and a self-assessment.

## U1 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11. Worktree `~/dev/variorum-vx-165`,
branch `vx-165-13n-c`. No revert is in flight unless a line below says so.

### UNIT CLOSED (2026-10-11 ~04:25 MDT — the U1 implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the pre-flight WALK is HELD** — the Mac's session is LOCKED with the
display asleep (U1-9); offscreen renders of the REAL sheet and pane in both voices stand in and are
NOT a walk; the dev-store walk and the REAL Claude Code live round are the orchestrator's (the live
round needs an unlocked screen only for its GUI legs — the wire legs do not). (2) **The fork, not
built:** a fenced BOOK still names itself on the wire (T-2's options a/b/c; (a) recommended) — FABLE-OWED
F-7. (3) **Recorded, not built:** a client holding a per-ask READ grant on a fenced note that asks to
SUGGEST now hears the one `notShared` answer though it can read the note (honest: `rungTooLow` — a
three-line change inside `MCPGrantRule.decide`, the security rule itself, left for the cold review).
(4) **The ask sheet** answers a BOOK ask with Once/While connected/Always buttons and no confirm
sentence — R-AIR-3's clause is not on that road (U2/U4 rebuild the ask road; recorded for them).
(5) No `notes/QUESTIONS.md` edit (merge-time, #211 — CLAUDE.md's shared-ledger rule); no canon edit
(T-2 brings the code TO AppSpec §12's line; the 13n-b plan's AF-6 fenced clause is superseded for
notes — the closeout's delta to record). Zero `Sync/`, schema, custody, editor seam, `/Applications`.

**Commits (branch `vx-165-13n-c`):** `176ea840` record opens · `38900d67` pins RED-first · `63e70d67`
the re-key + ritual · `1a311c8e` the one answer (T-2) + ritual · `6f573596` copy truth · `e1a9e52a`
R-AIR-3 · `c3cacc72`/`bc3001de` mutations · `7d64cde3` headless finals · `5fc17dc7`/`216972c7` Mac
· `23ee0f24` screens ignored · `2ca5cfbb` the clause kept whole (U1-5b) · `4ee62dd2` walk held +
captures · this commit.

**Finals:** core **2,585 / 296** green (baseline 2,580/295 + 5/1) · `VariorumMCPTests` **68 / 9** green, 0
skipped (65/8 + 3/1) · workbook **40 / 6** green · Mac (stage `vx165-u1`, closing tree `4ee62dd2`)
**109 tests / 10 suites, `** TEST SUCCEEDED **`** — 107 ran green, the 2 skips the gated capture harness
by design (`MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`, `SettingsShapeTests`,
`CapabilityRegistryTests`, `CalmAsksTests`, `CommitVocabularyTests`, `OwnershipBadgeTests`,
`DiagnosticsPaneTests`, `MCPGrantSheetCaptureTests`).

**PROVISIONALs:** P-13nc-1 (D-1, built — the ⌘J own-profile leg); P-13nc-3 (D-3, built — the wing's
"…, including notes added later" and the clause on every duration); **P-13nc-U1-1** (no period on the
confirm button). Implementation decision (not product): the grant sheet 520 → 600 wide + only the
place compresses (U1-5b's oracle) — U2 owns the row's final design.

**Where a cold reviewer should look first:** (1) `Sources/VariorumMCP/MCPGrantAuthority.swift`
`MCPRefusalCopy.words` / `words(_:_:asked:)` — T-2's reversal of AF-6 for notes (every tool's refusal
flows through it; is ANY other road still distinguishing a fenced note? the edit guard's `Refused`,
`MCPShowTool`, the search note scope were traced to it); (2) `Sources/VariorumCore/Queries/MCPGrantQueries.swift`
`dailyJournalLegForBook` and its three uses (NULL-safety; the `NOT (…)` in `mcpGrantableBooks`); (3)
`Tests/VariorumMCPTests/MCPFenceRekeyServerTests.swift` — whether the byte-identity pin covers the tools
that matter; (4) `MCPGrantSheet.ConfirmLabel` (layout priorities under a one-line voiced button).

**Self-assessment:** the fence change is small, at the one site, and every reader follows by
construction — traced, pinned red-first, and mutation-checked five ways. The judgment calls are T-2
(built because the brief orders byte-identity and AppSpec §12 says "anywhere"; it reverses a ruled
13n-b clause, so it is flagged F-6 rather than presented as settled) and U1-5b (a real defect in my
own U1-5 — the clause truncated away in Terminal — found by measurement because the walk could not
run; fixed and rendered). Least certain: whether the orchestrator wants fenced BOOKS uniform too
(F-7), and how the confirm row should finally look once U2's disambiguators lengthen the place.

### Pieces

| # | Piece | Status |
|---|---|---|
| U1-0 | Preflight read whole (this plan, the sitting record, brief §9, mockup §8, 13n-b R-13nb-1/-4 + the U1/U2 fence records + AF-6) + the traces below | DONE (this commit) |
| U1-1 | The pins, written FIRST and watched RED on the pre-fix tree (core `MCPFenceRekeyTests` + server `MCPFenceRekeyServerTests`) | DONE (this commit — pins RED by design until U1-2/U1-3) — RED-ON-OLD seen (`swift test --filter MCPFenceRekey` on `176ea840`'s sources): core 3 of 5 tests red / 10 issues (the trait book fenced, not offered, its grant refused `mcpGrantScopeFenced`; its member unreached by a book grant, a wing grant and the open book; the trait book's other note unreached); server 2 of 2 red / 14 issues (the trait book's grant refused; read_note + export_note on the four fenced notes ≠ the made-up id's answer ×8; search(note_id) ×2; set_entry_date ×1; the trait book unlisted ×2). GREEN ON BOTH SIDES BY DESIGN (guards of what must NOT move, proven by U1-6's mutations): `theDailyJournalsMembersStayFencedUnderEveryStandingGrant`, `privacyStillWinsInsideATraitBook`, and the zero-passage search lines (a fenced word searched answers `{"passages":[],"truncated":false}` exactly as a word nowhere — true today because `passes` filters per note) |
| U1-2 | The derivation narrowed (`MCPGrantQueries` — the ONE site: member leg, book leg, grantable-books filter → `'daily'` only; own-profile leg KEPT, D-1) + doc comments; the old-leg pins updated as the ritual | DONE (this commit) — ONE fragment `dailyJournalLegForBook` (`(r.profile IS NOT NULL AND r.profile = '\(dailyJournalBookProfile)')` — the daily mint's own constant, NULL-safe) now feeds all three sites, so they cannot drift; doc comments rewritten in `MCPGrantQueries`, `MCPGrantRule` (the `Fence` doc + the grammar header) and `grantMCPAccess`. **The ritual (justified edits, each annotated in place):** `MCPGrantOperationsTests.scopeValidation…` (the refused book fixture trait → 'daily'); `.theJournalLegsFenceExactlyAsRuled` (trait member → `nil`; trait book facts → `nil`; the archived/deleted fixtures → 'daily' bearers, the deleted one a written tombstone since the door refuses it); `.theGrantSheetOffersExactlyTheBooksAGrantMayName` (the trait book joins the offer); `MCPGrantInContextTests.aBookChipsExactly…` ("never a journal" → the daily Journal); `MCPCarriageServerTests.setEntryDateLands…` (the filing fixture → the daily Journal). Run: the six fence suites 45/6 green core-side; server-side the trait test green, the byte-identity pin still RED (U1-3's) |
| U1-3 | The wire's one answer for a fenced NOTE (`MCPRefusalCopy.words`) — see TRACE T-2; the old fenced-words pins updated as the ritual | DONE (this commit) — `words(.fenced(_), target)` returns `words(.notShared, target)` for every non-book target (the ONE words site every tool's refusal flows through — read/export/search/show and the write tools' `MCPAsking` + the edit guard's `Refused`); `words(_:_:asked:)` appends the asked sentence for `rungTooLow` only; `MCPAsking` still QUEUES the ask for a fenced note (her side hears it). A fenced BOOK still names itself (the fork). The byte-identity pin GREEN; the whole `VariorumMCPTests` target 67/9 green, 0 skipped. **The ritual (justified edits, annotated in place):** `MCPServerTests.journalsNeverRideAStandingGrantOrTheOpenBook` ("journal entry" → equals a made-up id's answer); `MCPWriteServerTests.asksRaiseOnlyForTargetsTheClientKnows…` (asked-sentence suffix → equals `missingWords`; the ask still asserted); `.markingPrivateFencesTheVeryNextCallOfAConnectedClient` ("marked Private" → the one answer); `MCPEditServerTests.aFenceLandingAfterTheDecision…` (the guard's "marked Private" → the one answer); `MCPCarriageServerTests.setEntryDateLands…` (prefix → the one answer); `.filingAFencedMemberRaisesTheAskAndSaysSo` RENAMED `…RaisesTheAskAndTheWireStaysOneAnswer` (the ask still lands; the asked sentence asserted ABSENT). **The visible consequence, said plainly for the reviewer:** a client that read a note one call ago and then finds it marked Private now hears "That note isn't shared with this client, or doesn't exist…" rather than "…is marked Private…" — the price of the no-oracle letter |
| U1-4 | Copy truth (J8): the six sentences (mockup §8's words verbatim) + the wire's own journal sentences + the app-wide grep record | DONE (this commit; the Mac pin's run PENDING U1-8) — the six, in the VX-156 mockup §8's recommended words verbatim: `SettingsCatalog` `mcpOpenBook` blurb; `MCPPaneCopy.wingDetail`; `.openBookDetail`; `.noBooks` (the mockup's own variant, "…your daily Journal and Private books are shared…"); `.refusal(.mcpGrantScopeFenced)` ("Your daily Journal and Private notes are shared…"); `MCPAskCopy.lead(.journal)`. The WIRE's three: `list_books`' description ("The daily Journal and Private books are never listed."), `list_notes`' ("Daily Journal entries and Private notes appear only when shared one ask at a time."), and the fenced BOOK refusal ("That book is the daily Journal. Its entries…"). Pins: headless `MCPFenceRekeyServerTests.theWiresSentencesNameTheDailyJournalNotEveryJournal` (green, `VariorumMCPTests` 68/9); Mac `MCPAskAndReceiptTests.theFenceSentencesNameTheDailyJournalNotEveryJournal` (PENDING the stage run); the ask-lead pin's old words updated as the ritual (`.theAsksWordsAreTheMockupsAndTheFencesSayWhy`, annotated). **The app-wide grep (every other shipped sentence about journals and sharing):** the field guide's "the journal & the pool" lesson (⌘J filing; no sharing claim) SAFE · the "keeping it private" chapter (`PostureCopy.privacyLesson*`, encryption only) SAFE · `PrivateMarkCopy` (Private-only claims, still true) SAFE · `SharedWithAICopy.chipHelp` SAFE · `HelperView` rows (⌥⌘O, ⌘J — no fence claim) SAFE · `TourScript` / `BookArchiveCopy` (⌘J and archive only) SAFE · the mobile target and `Shared/` (no sharing sentence at all) SAFE · `MCPSession.instructions` ("Every refusal says why." — still true: the one answer IS a why, "isn't shared with this client"; U5 rewrites the instructions anyway) SAFE · the 13n-b handoff's "journal-class notes … answer only a per-ask NOTE grant" (a handoff, not shipped copy; true of the daily Journal) — no edit |
| U1-5 | R-AIR-3 — the confirm's clause on every book grant + D-3's wing twin | DONE (this commit; the Mac pins' run PENDING U1-8; the label's fit at the sheet's width PENDING the walk) — `MCPPaneCopy.confirm` gains a REQUIRED `scope:` (no grant door can forget the clause) and `liveReachClause`: book → ", including to future entries" (her sentence), wing → ", including notes added later" (D-3), note → nothing; every duration keeps it (P-13nc-3). `MCPGrantSheet` passes its place's scope. No closing period on the button label (PROVISIONAL **P-13nc-U1-1** — her sentence carries one; a button never does in this app). Pins: Mac `MCPAskAndReceiptTests.theConfirmSaysABookOrWingGrantReachesWhatArrivesLater` (new) + `.theGrantSheetOffersTheServedRungsWithTheMockupsSentences`' confirm line updated as the ritual (annotated). The ask sheet's answer buttons (Once · While connected · Always) carry no confirm sentence — the clause is NOT added there (recorded as an open item for U2/U4, which rebuild the ask road) |
| U1-5b | **The confirm's clause, kept WHOLE on screen** (found by a geometry oracle when the walk could not run — see U1-9) | DONE (this commit; the Mac re-run + the offscreen captures PENDING) — the TRACE: a voiced button is one line and tail-truncates (`VoicedButtonStyle` `.lineLimit(1)`, P-8's chrome rule); measured headless with AppKit at the sheet's 520 (room 393 pt Terminal / 398 Study for the confirm's text beside Cancel), her own example "Grant read in “dream journal” always, including to future entries" is 462 pt in Terminal's 11.5 mono — TRUNCATED, the clause cut first; over every rung × duration × scope, 10 of 24 combinations cut the clause in Terminal by their fixed words alone. **Fix:** the sheet 520 → 600 wide (inside Settings' 720-wide window) + the confirm drawn in three parts (`MCPPaneCopy.confirmParts` → `ConfirmLabel`) where ONLY the place compresses (middle-truncated; it shows whole in WHERE just above): at 600, 0 of 24 cut the clause in either voice, her example fits whole in both (11 pt spare Terminal, 132 Study); the tightest Terminal case (write new · while connected · a book) leaves the place 4 pt — an ellipsis. Pin: the parts join to exactly `confirm` (Mac). **U2 OWNS the row's final design** (its disambiguators lengthen the place; this record's numbers are its starting facts). The capture harness `MCPGrantSheetCaptureTests` (gated OFF — `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u1`, the VX-144 precedent) renders the REAL sheet offscreen |
| U1-6 | Mutation checks (widen the leg back; drop the own-profile leg; un-uniform the wire) | DONE (this commit; every mutation restored by `git checkout --` from `e1a9e52a`, `git diff Sources/` empty after each — NO revert in flight) — over the fence suites (core `MCPFenceRekey`/`MCPGrantOperations`/`MCPGrantInContext`/`MCPPrivateMark` + server `MCPServerTests`/`MCPWriteServer`/`MCPCarriageServer`/`MCPEditServer`): **M1 widen the daily leg back to `IN ('journal','daily')`** → 19 issues, the new trait pins red (core `aJournalTraitBookIsOffered…` 4, `aTraitBooksMemberIsReached…` 5, `aDayEntry…` 1; server `aJournalTraitBookIsListed…` 1, the byte-identity pin 2) + the ritual-updated old pins; **M2 drop the ⌘J own-profile leg** → 29 issues, the D-1 pin `aDayEntryFiledInATraitBookStaysFenced…` red (3) and the byte-identity pin (5); **M3 drop the daily leg** → 23 issues, the guard `theDailyJournalsMembersStayFenced…` red (5) and the byte-identity pin (6) — INCLUDING its zero-passage search line for the member-only word (`quillwort`, :165), so the search guard bites; **M4 un-uniform the wire** (a fenced note says "That note is fenced.") → 21 issues, the byte-identity pin red (11) + the wire copy pin + every ritual-updated wire pin; **M5 drop the Private note leg** → 19 issues, the guard `privacyStillWinsInsideATraitBook` red (2), the byte-identity pin (6, incl. `sphagnum`) + the 13n-b Private pins |
| U1-7 | Headless finals: `swift build` + core + `VariorumMCPTests` + workbook | DONE (on `bc3001de`'s sources) — `swift build` + `--build-tests` clean; **core 2,585 tests / 296 suites green** (the 13n-b baseline 2,580/295 + `MCPFenceRekeyTests` 5/1; the skips are the standing gated suites — 13o fork measurements, the Supabase integration, the drill-fixture mint, the probes — none of them this unit's); **`VariorumMCPTests` 68/9 green, 0 skipped** (65/8 + `MCPFenceRekeyServerTests` 3/1); **workbook 40/6 green** (its one standing skip line) |
| U1-8 | Mac suites under a held stage claim (`MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`, `SettingsShapeTests`, `CapabilityRegistryTests` + any suite over a changed file) | DONE — stage `vx165-u1` (03:56); `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx165-u1 test` with `-only-testing:` the five + every suite reading a changed app file (`CalmAsksTests`, `CommitVocabularyTests`, `OwnershipBadgeTests`, `DiagnosticsPaneTests`): **107 tests / 9 suites green, 0 skipped** (`** TEST SUCCEEDED **`, 03:56→03:59), the new `theFenceSentencesNameTheDailyJournalNotEveryJournal` + `theConfirmSaysABookOrWingGrantReachesWhatArrivesLater` and the two ritual-updated pins among them |
| U1-9 | The pre-flight walk (dev-store Debug, Study + Terminal) → `notes/plans/13n-c-screens/u1/` | **HELD — the session is LOCKED** (04:00 MDT: `CGSessionCopyCurrentDictionary` → `CGSSessionScreenIsLocked 1`, `CGDisplayIsAsleep 1`; `screencapture -l` → "could not create image from window" on the launched dev instance, pid 73703; Accessibility + Screen Recording themselves are GRANTED to this host). Unlocking is hers, never a session's; the dev instance was quit by bundle id, `pgrep` clean, the stage released 04:1x. **What stands in its place (NOT a walk — a render of the real views, said plainly):** (1) the geometry ORACLE (U1-5b) — AppKit-measured widths of every confirm at the sheet's room, both voices; (2) the gated capture harness `MCPGrantSheetCaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=13nc-u1`, suite-level) rendering the REAL `MCPGrantSheet` and `MCPPane` offscreen over an in-memory store, 2 tests green: `u1-sheet-{study,terminal}-dream.png` — a journal-TRAIT book OFFERED and selected, the confirm "Grant read in “dream journal” always, including to future entries" WHOLE in both voices; `u1-sheet-{study,terminal}-long.png` — Study whole, Terminal "…“the adv…holmes” always, including to future entries" (only the place compresses); `u1-pane-{study,terminal}.png` — the trait book under Shared with AI ("dream journal · book · claude-code · read · always") and the open book's "your daily Journal and anything Private still ask every time". Harness limit, recorded: an `NSSwitch` draws OFF under `cacheDisplay` (the snapshot asserted ON). **OWED to the orchestrator's live round / the next unlocked walk:** the sheet and pane on the dev store in both voices; the wing confirm ("…, including notes added later"); the ask sheet's daily-Journal lead (needs a real ask) |
| U1-10 | UNIT CLOSED banner | DONE (this commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-1 — R-AIR-1's mechanism (the bug-class shape of "trait books fenced"):** `mcpNoteFacts`
  (`MCPGrantQueries.swift:290-292`) sets `member_journal` for a live member of ANY live reading with
  `profile IN ('journal','daily')`; `mcpBookFacts` (`:334`) sets the book's `journal` fact on the
  same pair; `mcpGrantableBooks` (`:366`) excludes the pair. A trait book (`profile='journal'`,
  `setJournalTrait`'s toggle) therefore reads `fence = .journal` → `MCPGrantRule.reaches` matches no
  standing grant for its members (`:278-281`) and nothing for the book (`:288`) →
  `insertMCPGrant` refuses `mcpGrantScopeFenced` (`Operations+MCPGrants.swift:167`), the sheet never
  offers it, and a wing grant / the open book skip its members. Narrowing the three sites to
  `'daily'` is the whole fix; every reader (`insertMCPGrant`, `mcpNoteSharing`,
  `mcpReachableBookIDs`, Allow-AI-here via `NotePrivacyState.read` → `mcpNoteSharing`, every
  server tool via `MCPGrantAuthority`) consumes those facts and follows by construction — verified
  by reading each; none re-derives.
- **D-1 re-verified:** the only shipped door minting a note with its own `profile='journal'` is
  `createOrOpenJournalEntry` (`Operations+Container.swift:80`); `createPost`/`newPostInReading`
  accept a profile but no shipped caller passes `.journal` (BookStructureModel's in-book day
  entry mints `.generic` on purpose, its `:664` comment); `importPost`/`importDocument` mint
  `profile: nil`. The copy roads (versions `Operations+Versions.swift:655`, the ownership family
  copy `Operations+Ownership.swift:90`, the wing copy `Operations+WingMove.swift:196`) carry the
  source's profile — so a COPY of a ⌘J entry stays fenced (the "more asks, never fewer" direction).
- **The marker, not the keeper:** the narrowed leg fences EVERY live book wearing `'daily'` (a
  not-yet-converged stale bearer included), not only `Queries.dailyJournalBookID`'s pick —
  the conservative direction; `setDailyJournalBook` demotes stale bearers to the trait anyway.
- **D-5 re-verified:** `Sources/VariorumCore/Sync/` reads `ai_private_at` only, as engagement
  (`SeededFurnitureDedupe` :229/:354/:528/:544/:713/:722, `SampleLibraryDedupe` :805/:819/:882/:893);
  no `Sync/` file reads `MCPGrantQueries`, the fence, or a journal profile predicate. U1 is ZERO
  `Sync/` lines.
- **T-2 — THE BYTE-IDENTITY DISCREPANCY (found before building; the brief's pin is red on old
  for a reason the brief does not name):** under a Home-wing read grant, `read_note` on a
  daily-Journal entry is decided `.ask(.fenced(.journal), offersAlways: false)`
  (`MCPGrantRule.swift:222-223`), routed through `MCPAsking.refusal` (`MCPReadTools.swift:113`) to
  `MCPRefusalCopy.words(.fenced(.journal), .note, asked: true)` (`MCPGrantAuthority.swift:118-126,
  141-149`) = *"That's a journal entry. Journal entries are shared one ask at a time, never by a
  standing grant; the author hasn't shared this one with this client. Variorum has asked the
  author — call again once she answers."*; a Private note says *"That note is marked Private —
  never shared with AI unless the author shares it for one ask. Variorum has asked…"*; a made-up
  id says the ONE `notShared` answer. **Three different answers — a fenced-vs-unshared oracle.**
  This contradicts AppSpec §12's contract line ("everything unreachable answers ONE uniform
  not-shared shape — no fenced-vs-unshared oracle anywhere") and the 13n-b handoff's promise to
  her ("a fenced note and a merely-unshared note answer byte-identically — no oracle"), and it is
  exactly what 13n-b's AF-6 ruled ("`rungTooLow` and `fenced` (targets the client legitimately
  knows exist) gain the said sentence") and four shipped pins assert
  (`MCPServerTests.journalsNeverRideAStandingGrantOrTheOpenBook` "journal entry";
  `MCPWriteServerTests.asksRaiseOnlyForTargetsTheClientKnows…` asked-sentence suffix;
  `MCPCarriageServerTests.setEntryDateLands…` and `.filingAFencedMemberRaisesTheAskAndSaysSo`
  "That's a journal entry" prefix). Canon and the brief agree; AF-6's fenced clause is the outlier.
  **DISPOSITION (U1-3 builds it; flagged for the cold review and the FABLE-OWED ledger):** for a NOTE
  target, `fenced` speaks the ONE `notShared` answer byte-for-byte on every tool (the one words
  site), and never the asked sentence — the just-in-time ask is STILL queued to her (AF-6's own
  ask-on-unshared-existing-target posture: "an ask IS queued while the wire stays silent"). This is
  the brief's order and canon's letter; it reverses AF-6's fenced clause for notes only.
  **FORKED, NOT BUILT (beyond the brief):** a fenced BOOK still names itself on the wire ("That
  book is the daily Journal…" / "…marked Private…") — the same oracle class for a book id the
  client holds; the brief names only notes. Proposal for the orchestrator: (a) uniform for books
  too (one more case in the same function; the U2 pin `privateRefusal == "That book is marked
  Private…"` flips) — the canon-letter option; (b) keep (a fenced book id is only ever known to a
  client that could once read the book or minted it — AF-6's premise); (c) uniform only for the
  daily Journal. Recommended (a). One more edge, recorded not built: a client holding a per-ask
  READ grant on a fenced note that asks to SUGGEST gets `notShared` words (before: the fenced
  words) though it can read the note — honest would be `rungTooLow` + the asked sentence, a
  three-line change in `MCPGrantRule.decide` (the security rule itself — Fable-owed, so not
  touched here).

---

## THE U2 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U2 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on
branch `vx-165-13n-c` (NEVER the main checkout). Commits say `Part of VX-165`, NO attribution
trailer, push after every commit. `notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in
the "U2 UNIT RECORD" section below from your FIRST commit, foreground waits only (a
`grep -q … && break; sleep 5` poll loop, never `tail -f | grep -m1`), no subagents.

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM (rulings, D-1…D-5, §3 U2,
§7, §8, the U1 record — U1 changed the fence and the confirm's words; build on them); the sitting
record `notes/plans/vx-156-grant-ux-design-kickoff.md`; the brief
`notes/plans/vx-156-grant-ux-brief.md` §1, §2, §12; the mockups
`notes/plans/vx-156-grant-ux-mockups.html` §1, §1b, §11 (read the source or render it locally —
never publish it). The 13n-b plan's pane rulings (R-13n-5 direct-and-technical register, R-13n-10
"all N ›" roads, P-13nb-U1-8/-11, U1's W-4 durations rule). Code:
`App/Variorum/Variorum/Features/MCP/MCPGrantSheet.swift`, `MCPPane.swift`, `MCPPaneCopy.swift`,
`MCPAskSheet.swift`; `App/Variorum/Variorum/Core/Views/SearchPicker.swift` (THE ONE picker,
R-17y-3 — brain + face; it has NO sections today) and `NotePicker.swift`
(`NotePickerSource.corpusNotes`); `Sources/VariorumCore/Queries/MCPGrantQueries.swift`
(`mcpGrantableBooks`); the Bookcase's own reads for shelf order, starred, counts and the derived
"last edited" (grep `BookcaseQueries`/`shelf`/`starred` under `Sources/VariorumCore/Queries`).

**What U2 builds — §3 U2 items 1–5, with these concretions:**
1. **`PlaceLabels` (core Domain, pure):** the context line (fixed order: shelf · N notes · state
   marks · last edited) and `disambiguate` over the OFFERED rows (ladder wing → shelf → note
   count → state → made day → made time; sameness = case- and diacritic-insensitive equality, the
   picker brain's own; never an ordinal). Exhaustive Swift Testing collision sets.
2. **The grantable-places read** grows: shelf (id, name, position — Bookcase strip order), starred,
   live member count, state marks (finished · owned · sealed · archived), made-at, last-edited (the
   Bookcase's own derivation — reuse, never re-derive). ∝ the books, never the note corpus.
3. **`SearchPicker` gains optional SECTIONS** (a pure brain extension, pinned; existing hosts
   unchanged — zero test edits for them is the parity proof): the book picker before typing shows
   **Recently edited** (a constant N — PROVISIONAL, log it) → **Starred** → one section per shelf
   in strip order → **Unshelved**; typing filters across all sections (a match shows once, under
   its home section). If a by-shelf/a–z toggle fits the idiom, build it PROVISIONAL; else record
   why not.
4. **The sheet:** WHERE "A note · A book · A wing" (the note leg via `corpusNotes`, wing-scoped
   with a wing chooser if the feed is wing-bound — record your call; a fenced note offers only
   once/while connected with the one-line why); the WING row a `SearchPicker` too; **WHO** row
   (approved clients, most recently granted first) when the sheet's opener supplies no client — add
   the opener API U3 will call (`MCPGrantSheet` pre-filled with WHERE and optional WHO); durations
   shrunk to what every picked target can take with the why; the confirm names the place WITH its
   disambiguator and carries U1's R-AIR-3 words.
5. **R-AIR-8 + L1:** settings-class strings in the pane and sheets lose the word "AI" where they
   can (the brief's "grant MCP permissions"-class; the menu-bar Title Case items and app-wide
   receipts are NOT settings-class — leave them; list every string you changed and every one you
   judged out of scope in the record). L1: the A-4 sentence under Clients, the brief §12's words.
6. **The ask sheet's title and the pane's shared rows** wear the disambiguated label (one rule).

**Dev-store scale seed (for your walk and the orchestrator's):** a small DEBUG-only or test-tool
road that mints, in the DEV store only (`io.lduarte.Variorum.debug`), ≥150 books across ≥8
shelves (some starred, two with the same name), ≥500 short notes — through the operations layer
only. Put it where it cannot reach a Release build (a `#if DEBUG` Diagnostics action or a
`Tools/` script that drives the dev store headlessly — your call, record it). Never the real store.

**Ladder carry (U1 round 1, F4):** the confirm's scope in `MCPGrantSheet` (a `place == .book ? .book : .wing` ternary) becomes an exhaustive switch when you add "A note" — a note grant must never wear the wing clause. **And F2:** the ask sheet's durations carry R-AIR-3's clause on a BOOK ask's Always (and the other durations, D-3) — every book grant says it.

**Ladder carry (U1 round 2, R2-3):** a Shared-with-MCP row whose grant reaches nothing now (its target fenced since — e.g. a trait book made the daily Journal, or a book marked Private) must read as inert, never as shared (P-13nb-U2-3: "the faces must not call such a grant shared while it is inert") — derive it through the one rule, pin it.

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the
real store, `/Applications`. The fence derivation is U1's — consume it, never re-derive it.

**Acceptance:** core pins (PlaceLabels, the sectioned brain, the read) headless + the whole headless
package at the end; Mac suites `MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`,
`SettingsShapeTests`, `CapabilityRegistryTests`, every `SearchPicker` host's suite (grep the tests
for `SearchPicker`) + any suite exercising a changed source file, under a HELD `Tools/stage` claim,
suite-level `-only-testing`, `skipped:` lines read. Your pre-flight WALK on the dev-store Debug
build, Study AND Terminal, light (dark if time), on the scaled seed: find a book by typing, by
shelf, a starred one, two same-named books told apart and the right one granted, a note from
Recently edited, a fenced note's honest durations, the WHO row, L1 on screen. Captures in
`notes/plans/13n-c-screens/u2/` (gitignored — verify). Fix what the walk finds; record it.

**Forks:** propose before building any half beyond the recorded rulings; PROVISIONAL-and-log for
non-gating ambiguity; STOP for anything gating. **Close:** the UNIT CLOSED banner (not-done list,
PROVISIONALs, where to look first, self-assessment).

## U2 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~06:00 MDT). Worktree
`~/dev/variorum-vx-165`, branch `vx-165-13n-c`. No revert is in flight unless a line below says so.
The session is LOCKED at start (06:06 MDT: `CGSSessionScreenIsLocked 1`, display asleep) — the walk
is re-checked at U2-9; offscreen renders stand in only if it is still locked, and are NOT a walk.

### UNIT CLOSED (2026-10-11 ~07:00 MDT — the U2 implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the WALK is HELD** — the session stayed LOCKED (06:06, 06:49 MDT); the
offscreen renders of the REAL views (U2-9) stand in and are NOT a walk; the brief's walk list, the grant
LANDING from the picker, and dark appearance are owed to the next unlocked session (U2-9 names them).
(2) **Not built, recorded:** arrow-key navigation inside the picker (the ONE picker never had it — Return
takes the first visible row); distinguishers for NOTES (notes are told apart by snippet + day, the note
picker's own answer; the ladder is ruled for places); a shared row whose book is fenced now carries no
distinguisher (the ladder runs over the OFFERED rows — it reads inert instead). (3) **Left for U3/U4 by
the plan:** the ask sheet still self-presents (U4's arrival X); the Book Settings / row-menu / bulk-bar
doors that will call `MCPGrantOpening` (U3) and their "Shared with AI" lines (`PrivateMarkCopy.sharedLine`,
`allowHere`) re-worded under R-AIR-8 if her copy pass says so. (4) No `notes/QUESTIONS.md` edit
(merge-time, #211); no canon edit. Zero `Sync/`, schema, custody, editor seam, `/Applications`; no
Variorum instance ever ran (headless suites + `xcodebuild test` only).

**Commits (branch `vx-165-13n-c`):** `94ce6b64` record opens · `fc316f73` PlaceLabels · `ebc03707` the read
+ R2-3 RED-first · `7818d72f` R2-3 derived · `59d1f154` the picker + sheet + pane + ask (compiling) ·
`6536770a` the pins + harness + capture fixes · `edcb09ca` the scale seed · `82772389` derived rows once per
load · `7f5b04b8` the a–z header · this commit.

**Finals:** core **2,605 / 298** · `VariorumMCPTests` **69 / 9** · workbook **40 / 6** — all green headless ·
Mac **219 tests / 29 suites `** TEST SUCCEEDED **`** (216 ran, 3 skipped = the two gated harnesses) +
the post-fix **53 / 5** green.

**The routed findings, closed here:** **R2-3** FIXED with its pin (RED on the nil stub `ebc03707`, green
`7818d72f`) — an inert grant reads inert, never shared, on the row AND the client count. **F4** built (the
exhaustive `scope` switch over note · book · wing). **F2** built (the ask's reach line — R-AIR-3 on every
book grant the ask road mints, D-3's twin for a wing).

**PROVISIONALs (for #211 at the merge):** **P-13nc-U2-1** "Recently edited" shows 5. **P-13nc-U2-2** "Shared
with AI" → "Shared places" (alternatives "Shared with clients" · "Permissions"). **P-13nc-U2-3** the picker's
layouts: "by shelf" (default) and an "a–z" toggle; Unshelved LAST per the brief (the Bookcase's All shows
it first — options: last (built) · first, the Bookcase's way); the quick sections ride both layouts.
**P-13nc-U2-4** the ask's reach-line words ("Any answer below grants it in “X”, including to future
entries."). **P-13nc-U2-5** the virtual Home never joins a wing collision set (it has no made stamp).
**Implementation decisions (not product):** the note leg searches one wing at a time with a wing row only
when more than one wing exists (T-U2-4); the sheet's default book is the most recently edited; the confirm
takes two lines when one cannot hold it (the geometry oracle in U2-4); a note grant's confirm reads "on"
(the approved mockup §1's word — U1's "in" predated the note leg).

**Where a cold reviewer should look first:** (1) `Queries.mcpGrantInertFence`
(`Sources/VariorumCore/Queries/MCPGrantQueries.swift`) — the R2-3 derivation and its COST GUARD (asked of
the rule on a fenced twin, so only an "always" note grant reads note facts) and what it adds to the pane's
HELD snapshot (`MCPDoor.read` → `clientRow`/`mcpSharedRows` now read `reading`, and `container` +
`reading_post` only for always note grants) — is any wake new at autosave rate? (2) `MCPGrantSheet.spec` /
`offeredDurations` / the clamp — can the sheet ever submit a duration the target can't take (the op refuses
`always` on a fenced note regardless)? and `MCPGrantOpening`'s shape for U3 (bulk notes are U3's to add).
(3) `SearchPicker` — the flat path must be byte-identical (the trigger now sits in a `Group`; the hosts'
suites ran unedited and green). (4) `Queries.mcpGrantableBooksSQL` — the correlated per-book aggregates
(the plan pin asserts `SEARCH rp`, no scan of `reading_post`/`container`) and the shelf resolution to the
book's own wing. (5) `ConfirmLabel`'s `ViewThatFits` two-line form. (6) `ScaleFixture`'s books part — still
`#if DEBUG` and env-gated, dev store only.

**Self-assessment:** the core is small and pinned (the ladder 10 pins, the read 8 incl. a plan pin, R2-3
red-first), and the faces are one pure brain (`MCPGrantPicker`) under 13 Mac pins plus a capture harness
that looked at every face in both voices — which caught four real defects the pins could not (day words, the
reach line, the a–z header, the harness seam). The judgment calls are the R-AIR-8 word ("Shared places"),
the two-line confirm (forced by measurement in Terminal), and where Unshelved sits. Least certain: how the
picker FEELS at 160 books under a real pointer (the popover's scroll, the toggle's discoverability) — only
the held walk can say; and whether the held snapshot's added reads for inert grants are worth a one-shot
instead (recorded in (1) for the reviewer).

### Pieces

| # | Piece | Status |
|---|---|---|
| U2-0 | Preflight read whole (this plan top to bottom incl. the STANDING BLOCKER + U1 record; the sitting record; the brief §1/§2/§12 (+§3/§4 for the opener/WHO shape); mockups §1/§1b/§2/§11; the 13n-b pane rulings R-13n-5/10, P-13nb-U1-8/-10/-11, the U1 walk's while-connected rule, P-13nb-U2-3/-13; the code named in the brief) + the traces below | DONE (this commit) |
| U2-1 | Core `PlaceLabels` (Domain, pure): the context line (fixed order) + `disambiguate` (the ladder over the OFFERED rows) + exhaustive Swift Testing collision sets | DONE (this commit) — `Domain/PlaceLabels.swift`: context = (a non-Home book's wing) · shelf · N notes · state marks (the Bookcase's order + archived) · `TimeStampFace`'s "edited …"; the ladder wing → shelf → note count → state → made day → made time, applied PER PLACE (each takes the first rung whose value is its OWN within its collision set — the brief's "first fact that differs" made exact for sets past two: every label in a set is unique); a rung a place has no value for is skipped for it; a same-minute pair grows the made SECONDS (still a fact); a same-second pair says the same honest fact — never an ordinal (pinned by regex). Sameness = trimmed, case- and diacritic-folded (the picker brain's own). `TimeStampFace.time(_:seconds:)` added (the cached formatter, `jmm`/`jmmss`). **Implementation decision (not product):** "living" rides the marks — the approved mockup §1b draws it and the Bookcase row says it. Pins: `PlaceLabelsTests` 10/1 green (headless) |
| U2-2 | Core read: `mcpGrantableBooks` grows shelf · starred · member count · marks · made · last edited (the Bookcase's own fragments, reused) + the shelves/wings it groups by + `mcpClientsByRecentGrant` (WHO) + the shared rows' REACH (R2-3, through `MCPGrantRule.reaches`) — pins incl. a P1 plan pin | DONE (`ebc03707` red-first + this commit) — **reuse, not re-derivation:** the Bookcase's member-stamp statement was split into `memberLastEditedSQL` + `shownMemberNoteJoinSQL` + `liveMemberRowSQL` + `bookLastEdited` (the created_at fallback) and `wingMemberStampsSQL`/`bookcaseAggregates` now read the SAME fragments the grant read does (the Bookcase's plan pin green over them); "N notes" = live un-archived members (the Bookcase's honest count); the star = `starredReadingIDs` (the union); "living" = `livingBookSQL` (the facet's one SQL home); a shelf pointer resolves only to a live shelf OF THE BOOK'S OWN WING (else unshelved, §19). `MCPGrantPlaces` (pure, core): `place(_:)` → `PlaceLabels.Place`, `bookDistinguishers`, `recentlyEdited(limit:)` (N = `mcpRecentlyEditedCount` = 5, **PROVISIONAL P-13nc-U2-1**), `wingChoices`, `wingDistinguishers` (the virtual Home has no made stamp and never joins a collision set — **P-13nc-U2-5**, an edge). WHO = `mcpClientsByRecentGrant` (approved only; newest grant row first, revoked rows counting — brief §4's "the last grant she made"). **R2-3 (bug-class, pinned red-first):** `MCPSharedRow.inertFence` = `mcpGrantInertFence` — the fence of a target `MCPGrantRule.reaches` refuses the grant, on `mcpNoteFacts`/`mcpBookFacts` (the one rule, the one facts); `mcpGrantReachCounts` for the client row. RED on the nil stub (`ebc03707`: 2 issues — the inert set, the counts), GREEN derived. Pins `MCPGrantPlacesTests` 8/1 (incl. the P1 plan pin: `SEARCH rp`, never a scan of `reading_post` or `container`); the neighbours (`MCPGrantOperations`, `MCPPrivateMark`, `MCPFenceRekey`, `BookcaseShelf`, `PlaceLabels`, `TimeStampFace`) 76/9 green together |
| U2-3 | `SearchPicker` gains optional SECTIONS (quick sections vanish on typing; a match shows once under its home section), an async source (the note feed), a second-line detail, a field-style trigger — the brain pure and pinned; existing hosts untouched (zero edits to their tests = the parity proof) | DONE (`59d1f154` + this commit) — brain: `SearchPickerSection` (`isQuick`), `SearchPickerArrangement`, `SearchPickerBrain.visible(_:query:)` (before typing every non-empty section; typing ⇒ home sections only, each filtered by the ONE `filter`, so a match shows once) + `returnChoice(sections:query:)`; `SearchPickerOption` gains `detail` (a second line) and `emphasized` (the distinguisher in accent); the face gains `arrangements` (a quiet "by shelf · a–z" toggle when more than one — **PROVISIONAL P-13nc-U2-3**, built because it fit the popover's header line), `source` (async, latest query wins — the note feed), `field` (the trigger as a bordered field: value · annotation · ▾) and `panelWidth`. The sectioned panel is its own view, `SearchPickerPanel` (so the locked-session harness can draw the OPEN picker — a popover is another window). Every addition defaults off: the flat path's code is unchanged. **Parity proof:** the hosts' suites ran UNEDITED and green (`SearchPickerBrainTests`, `RuleEditorMakeTagTests`, `AddToBookMintTests`, `OutflowChooserTests`, `RuleEditorTests`, `MembershipChoiceTests`). Pins: `MCPGrantSheetTests.quickSectionsShowOnlyBeforeTyping…`, `.returnTakesTheFirstVisibleRow` |
| U2-4 | The sheet rebuilt: WHERE note · book · wing (all `SearchPicker`), WHO row + the opener API U3 calls, durations shrunk to what the target can take with the why, the confirm with the disambiguator + R-AIR-3 (F4's exhaustive switch) | DONE (`59d1f154` + this commit) — **the opener U3 calls:** `MCPGrantOpening(client: MCPClient?, approving: Bool, place: MCPGrantSheet.Prefill?)` (`.note(id)` · `.book(id)` · `.wing(id)`; nil client ⇒ WHO shown; `MCPPane.GrantTarget` retired into it; "connected" is read from the door LIVE for the chosen client, never snapshotted at open). The pure brain `MCPGrantPicker` (`Features/MCP/MCPGrantPicker.swift`): the book layouts — **by shelf** = Recently edited (quick, N=5) → Starred (quick) → each shelf in the Bookcase's strip order PER WING (Home first; another wing names itself: "variorum · worksheets") → that wing's Unshelved; **a–z** = the quick sections then one list; inside a section the Bookcase's digit-aware a–z; each row = name · distinguisher (accent, only on collision) / the context line. WING rows (Home first, distinguished on collision); WHO rows (most recently granted first, "connected now"). **Brief vs Bookcase, recorded:** the Bookcase's All puts Unshelved at the TOP; the brief orders shelves → Unshelved, and the brief is built (P-13nc-U2-3's family). **The note leg (T-U2-4's call):** `corpusNotes` gains an additive `inWing:` (nil = byte-identical); the leg searches one wing (the window's current one by default) and a "Notes in ▾" wing row appears only when the library has more than one wing; rows fence-marked through ONE batched `mcpNoteFacts` per page; a fenced note stays pickable and the sheet offers once (+ while connected when connected) with mockup §1's why; a pre-filled note brings its own wing. **The default book** is the most recently edited one (a–z's first was arbitrary at scale). **Durations:** `MCPGrantPicker.durations(connected:noteFence:)` = U1's while-connected rule ∩ the fence's never-always; a duration that leaves the offer clamps to the first offered. **F4:** `scope` is an exhaustive switch over `Place` (note · book · wing). **The confirm (T-U2-6 — the row's final design, the geometry ORACLE):** measured with AppKit at the sheet's room (489 pt Terminal / 495 pt Study beside Cancel at 600): in Terminal's mono the confirm's FIXED words alone reach 632 pt ("Grant write new in “…” (made Oct 10, 9:14 PM) while connected, including to future entries") and her own example with a day distinguisher is 554 pt — so one line cannot hold it; two lines hold the worst whole sentence (867 pt < 978). `ConfirmLabel` is now `ViewThatFits`: one line whole when it fits, else TWO lines (trailing-aligned) with only the place middle-shortened past `confirmPlaceLimit` = 40 characters (`MCPPaneCopy.shortPlace` — the place shows whole in WHERE above); the distinguisher rides the TAIL so it never compresses away; accessibility reads the whole sentence. The sheet stays 600 wide (inside Settings' window). A NOTE grant reads "on" (mockup §1: "Grant read on “morning pages — oct 9” once"). Pins: `MCPGrantSheetTests` (the layouts, the distinguisher + context, durations + whys, the confirm, `shortPlace`, the door's reads) |
| U2-5 | R-AIR-8 strings (list below) + L1 under Clients + the pane's shared rows and the ask sheet's title disambiguated + R2-3's inert rows + F2 (the ask sheet's clause) | DONE (`59d1f154` + this commit) — **R-AIR-8, CHANGED (settings-class, the pane and its sheets):** `MCPPaneCopy.sharedSection` "Shared with AI" → **"Shared places"** (PROVISIONAL **P-13nc-U2-2** — options: "Shared places" (built: the client row's "N shared places" and Revoke's note already say it) · "Shared with clients" · "Permissions"); `enableBlurb` "AI work lands as takes…" → "a client's work lands as takes…". Swept and found clean (no "AI"): every other `MCPPaneCopy` string the pane/sheets render, `MCPAskCopy`, the two `SettingsCatalog` MCP blurbs (their search KEYWORDS keep "ai" — a search word, not wording). **Judged OUT of scope (not settings-class, or ruled):** `PrivateMarkCopy.rowWords` "Private — never shared with AI" (her ruled word, R-13nb-4 (iv) — never re-opened); `PrivateMarkCopy.sharedLine` "Shared with AI: …" and `allowHere` "Allow AI here" (the note ▾ menu / Book Settings — app-wide faces; U3 builds the Book Settings grant row and re-words under R-AIR-8 there if her copy pass says so); `SharedWithAICopy` (the Bookcase chip — U3 replaces it with the ONE icon); the ⌥⌘O menu title "Show the AI's Last Change" (menu-bar Title Case, P-13nb-U4-15); receipts (app voice). **L1** `MCPPaneCopy.clientBoundary` — the brief §12's words verbatim — under Clients, always. **Shared rows** wear the ONE rule's distinguisher (`door.placeDistinguishers()` — a one-shot read per change of the shared set, never in the held snapshot; over the OFFERED books, so a row whose book is fenced now carries none — it reads inert instead); a note row wears none (its picker tells notes apart by snippet + day). **R2-3's faces:** an inert row is muted with an italic why (`inertDetail`: "inert — the book is marked Private, which always asks" / "inert — it's your daily Journal now, which always asks" / a note's twin); the client row says "2 shared places · 1 inert" (`reads(_:inert:)`). The held snapshot's added cost, said: book grants read `reading` only; a note grant's facts are read only when it is an "always" grant (the cost guard is ASKED OF THE RULE — `reaches` on a fenced twin — so no second fence exists). **The ask sheet:** its title wears the distinguisher (mockup §1b) and **F2:** a BOOK or WING ask says R-AIR-3's reach above the answers (`MCPAskCopy.reachLine` — "Any answer below grants it in “X” (made Oct 11), including to future entries." — every duration, D-3; PROVISIONAL wording **P-13nc-U2-4**). Ritual updates (justified, annotated in place): `MCPAskAndReceiptTests` — the note confirm's "in" → "on" (two pins) and the blurb's "AI work" → "a client's work" |
| U2-6 | The dev-store scale seed (DEBUG-only, dev store only, ops only) | DONE (this commit) — **the call (recorded):** EXTEND the shipped 17y `ScaleFixture` rather than mint a second road — it is already `#if DEBUG` AND env-gated (`VARIORUM_SCALE_FIXTURE`), the Debug build opens only the fenced DEV store, and `Tools/ScaleFixture/stage.sh` takes the A1 prestage copy (cmp-verified) before the seeding launch with `restore.sh` to put it back. New request keys `books=N,shelves=M` (default `books=0` — the shipped fixture byte-unchanged): M shelves in Home, N books (every 13th unshelved), the fixture's notes filed round-robin, a few starred (`try?` — the 15-star cap tolerated), every 17th finished, every 23rd owned, one archived, one journal-TRAIT ("dream journal"), one Private book, one Private note, TWO "the adventures of sherlock holmes" on the first shelf made three days apart (her screenshot), and a "notes toward a chapter" pair on two shelves (the shelf rung); its own marker book so a relaunch mints nothing. Ops only, a quiet `Operations` (no undo), inside the session's runner. **The walk's command:** `Tools/ScaleFixture/stage.sh notes=520,long=40,books=160,shelves=9 <derived-data>` (≥150 books, ≥8 shelves, ≥500 notes — the brief's floor), then `restore.sh <the printed dir>`. Pin: `MCPGrantSheetTests.theScaleSeedMintsTheGrantRoadsLibraryOnce` (45 books / 4 shelves on an in-memory store: 44 offered (the Private one never), the pair distinguished by the made day, unshelved/finished/archived present, notes filed, the relaunch a no-op) — green |
| U2-7 | Headless finals: `swift build` + core + `VariorumMCPTests` + workbook | DONE (on `82772389`'s sources; the later commit `7f5b04b8` is app-only) — `swift build` + `--build-tests` clean; the whole package `swift test`: **core 2,605 / 298 green** (Stage A's tree + `PlaceLabelsTests` 10/1 + `MCPGrantPlacesTests` 8/1), **`VariorumMCPTests` 69 / 9 green**, **workbook 40 / 6 green**; 0 failures; the only skips are the standing gated measurement suites (13o's two) |
| U2-8 | Mac suites under a held stage claim (the brief's list + every `SearchPicker` host suite + every suite over a changed file) | DONE — stage `vx165-u2` (claimed/renewed/released; no Variorum instance ran at any point); `-only-testing` over **29 suites: 219 tests, `** TEST SUCCEEDED **`** on `82772389` — 216 ran green, the 3 skips the two GATED capture harnesses by design (`MCPGrantSheetCaptureTests`, `MCPGrantSheetU2CaptureTests`). The suites: `MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`, `MCPNavigationTests`, `MCPGrantSheetTests` (new), `SettingsShapeTests`, `CapabilityRegistryTests`, `DiagnosticsPaneTests`, the `SearchPicker` hosts UNEDITED (`SearchPickerBrainTests`, `RuleEditorMakeTagTests`, `AddToBookMintTests`, `OutflowChooserTests`, `RuleEditorTests`, `MembershipChoiceTests`), `corpusNotes`' (`NotePickerRankingTests`, `NotePickerSourceTests`, the seven `BookArchiveFaces` suites), and U1's neighbours (`CalmAsksTests`, `CommitVocabularyTests`, `VocabularySweepTests`, `OwnershipBadgeTests`). After `7f5b04b8` (the a–z header): `MCPGrantSheetTests` + the U2 harness + `MCPPaneTests` + `MCPAskAndReceiptTests` + `VocabularySweepTests` **53/5 green** |
| U2-9 | The walk (dev-store Debug, Study + Terminal, on the scaled seed) → `notes/plans/13n-c-screens/u2/` — or, if still locked, offscreen captures of the real views (NOT a walk) | **WALK HELD — the session is LOCKED** (06:06 and again 06:49 MDT: `CGSSessionScreenIsLocked 1`, display asleep). Unlocking is hers. **What stands in its place — NOT a walk, said plainly:** the gated harness `MCPGrantSheetU2CaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=13nc-u2`) renders the REAL views offscreen over a seeded in-memory library, light, both voices, shot on the closing tree (`7f5b04b8`) into `notes/plans/13n-c-screens/u2/` (gitignored — verified by `git check-ignore`): `u2-sheet-{study,terminal}-who-book.png` (opened from a place: WHO "claude-code · connected now", the second sherlock pre-filled wearing "0 notes" in WHERE and in the confirm, which takes two lines in both voices); `u2-picker-{…}-books-resting.png` (Recently edited · Starred · ✦ Welcome …, every row's context line), `-books-typed.png` ("sherl": the two sherlocks under Welcome told apart "0 notes" / "2 notes", the third match under research — quick sections gone), `-books-az.png`; `u2-sheet-{…}-fenced-note.png` (a Private note: Once · While connected only, mockup §1's why; "Notes in Home ▾" because a second wing exists); `u2-picker-{…}-notes.png` (the note feed, fence-marked rows, day words); `u2-pane-{…}.png` (L1 under Clients; "Shared places"; the inert row muted with its why; "2 shared places · 1 inert"); `u2-ask-{…}.png` (the distinguished title + R-AIR-3's reach line). **What the captures caught and was fixed:** the note rows' raw day keys ("2026-09-30") beside the books' "edited Sep 30" → the sheet's day words; the reach line not naming the distinguished book its title named; the a–z list reading as Starred's continuation → "All books"; the harness's connected seam cleared by the door's own reconcile (a harness fix). **Observed, left for her eye:** Terminal lowercases the rows' annotations ("daily journal entry", "private") — the voice's chrome idiom (`chromeLabel`), as everywhere else. **OWED to the next unlocked session (the orchestrator's walk):** the brief's walk list on the dev store with the scaled seed (`Tools/ScaleFixture/stage.sh notes=520,long=40,books=160,shelves=9 …` then `restore.sh`) in both voices — find a book by typing, by shelf, a starred one, the two sherlocks told apart AND the right one granted (the grant landing in Shared places), a note from Recently edited, a fenced note's honest durations, the WHO row, L1 on screen; dark appearance (not captured) |
| U2-10 | UNIT CLOSED banner | DONE (this commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-U2-1 — the flat picker (VX-156 item 1):** `MCPGrantSheet` (`:87-108` at `99d739e9`) offers WHERE as a
  radio pair (book · wing) and a native `Picker` over `door.choices().books` = `Queries.mcpGrantableBooks`
  (`MCPGrantQueries.swift:370`) — every live unfenced book in EVERY wing, `ORDER BY r.name COLLATE NOCASE`,
  carrying only id/name/wing. Nothing filters it; at hundreds of books it is one long native menu.
- **T-U2-2 — the duplicate blindness (VX-156 item 6):** `bookLabel` (`:177`) appends only a non-Home
  wing's name, so two same-named books in one wing render two identical rows; the confirm
  (`MCPPaneCopy.confirmParts`), the ask sheet's title (`MCPAskCopy.title` — `ask.title` alone) and the
  pane's shared rows (`MCPSharedRowView` — `row.targetTitle` alone) carry the same blindness.
- **T-U2-3 — R2-3, the inert row (bug-class; pinned red-first):** `Queries.mcpSharedRows` lists every grant
  with `revoked_at IS NULL` and not a spent once grant (`:166-185`) — it never consults the fence. A book
  grant made while the book was open, then the book marked Private (or a trait book made THE daily Journal
  — R2-4's road), stays listed, and `MCPSharedRowView` renders "<book> · book / claude-code · read · always ·
  Revoke" — calling it shared — while `MCPGrantRule.reaches` answers false for a fenced book (`MCPGrantRule
  .swift:300`, `guard book.fence == nil`) and false for a fenced note under an `always` grant (`:288-291`).
  The client row's "N shared places" (`MCPDoor.liveGrantCount` — `isLive` only) counts it too. P-13nb-U2-3:
  "The faces must not call such a grant 'shared' while it is inert." Fix: the row's reach derived through
  `MCPGrantRule.reaches` over `mcpNoteFacts`/`mcpBookFacts` (the ONE rule + the ONE derivation site);
  the face says inert and why; the client count counts reaching grants.
- **T-U2-4 — the note leg's feed is wing-bound:** `NotePickerSource.corpusNotes(session:excluding:)` with no
  subject reads `session.wing.currentID` (`NotePicker.swift:108`), and `Queries.notePickerNotes` filters by
  that wing — so a note leg in Settings would see only the window's current wing. **Call (recorded):** the
  note leg searches ONE wing at a time — the session's current wing by default — and the sheet shows a
  wing chooser beside it only when more than one wing exists (single-wing libraries never see it);
  `corpusNotes` gains an additive `inWing:` override (existing callers byte-unchanged).
- **T-U2-5 — the ask road's clause (F2):** `MCPAskSheet` answers with Once · While connected · Always and no
  sentence names the place's live reach; a BOOK ask's answer mints a book grant (`MCPDoor.answer` →
  `grantMCPAccess` with `ask.scopeKind`) — so R-AIR-3's "every book grant" is unsaid on that road.
- **T-U2-6 — the confirm's room (U1-5b's numbers are the start):** at 600 wide, Terminal's tightest case left
  the place 4 pt; a disambiguator (" (made Oct 9)", ~14 mono chars ≈ 97 pt) on the tail would cut the
  clause again in Terminal. U2 owns the row's design (U1's hand-off) — re-measured at U2-4 and recorded.
- **T-U2-7 — scale:** every new read is ∝ the books (author-scale) or the page (≤30 notes per keystroke —
  `notePickerNotes`' bound); nothing reads the note corpus. The member count and last-edited per book
  reuse the Bookcase's own derivation (`wingMemberStampsSQL`'s join + `MAX(COALESCE(last_touched_at,
  created_at))`, the `created_at` fallback of `bookcaseAggregates`), entered per book through
  `reading_post`'s `reading_id` index (pinned by plan).
- **D-U2 — no Sync/, no schema, no custody, no editor seam** (re-verified at close). The fence derivation is
  U1's and is consumed, never re-derived: offered books stay `mcpGrantableBooks`' filter; a note's fence is
  `mcpNoteFacts`'; reach is `MCPGrantRule.reaches`.

---

## THE U3 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U3 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on
branch `vx-165-13n-c` (NEVER the main checkout). Commits say `Part of VX-165` (and
`Part of VX-164` for the in-note indicator), NO attribution trailer, push after every commit.
`notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in the "U3 UNIT RECORD" section below
from your FIRST commit, foreground waits only (a `grep -q … && break; sleep 5` poll loop), no
subagents.

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM (rulings, D-1…D-5, §3 U3,
§7, §8, the U1 and U2 records — U2 built the sheet's opener API, `PlaceLabels` and the WHO row
you call); the sitting record `notes/plans/vx-156-grant-ux-design-kickoff.md` (R-AIR-4, -6, -7,
-8); the brief `notes/plans/vx-156-grant-ux-brief.md` §3, §4; the mockups §2, §3 (read the source
or render locally — never publish). The 13n-b plan's U2/U3 records on the chip (P-13nb-U2-11),
Allow-AI-here (P-13nb-U3-15), receipts (P-13nb-U2-10, U4-13) and ⌥⌘O's sweep record. Code:
`Features/Library/LibraryCatalogView.swift` (the bulk bar ~l.673, `postRowMenu` ~l.1178),
`Core/Views/BookRowMenu.swift` (`BookRowMenuTable` — the ONE book-row menu table),
`Features/BookView/BookSettingsSheet.swift` (the Private row's neighbour), `Features/Shelf/
ShelfView.swift` (~l.679 the "shared with AI" text chip) + `ShelfViewModel` (`mcpReachableBookIDs`),
`Core/Views/PrivateMark.swift` (the Private faces and `SharedWithAICopy`), `Features/MCP/
MCPDoor.swift` (receipts, `speak`, the session state), `EditorCommands.swift` (the chord table and
its sweep records), the capability registry under `App/Variorum/Shared/` (grep `Registry`),
`Sources/VariorumCore/Operations/Operations+MCPGrants.swift` + `Queries/MCPGrantQueries.swift`.

**What U3 builds — §3 U3 items 1–6, with these concretions:**
1. **Core:** `grantMCPAccess` for N notes in ONE transaction on ONE stamp (one op call; a missing
   or non-note target refuses the whole act — PROVISIONAL; a fenced note never takes "always"),
   exact state-transition tests; the pane's Shared list groups grants sharing client + rung +
   duration + `created_at` into ONE row ("3 notes · claude-code · read · while connected", the
   members listed under it, Revoke covering all) — exact-stamp grouping, no schema.
2. **The doors** — each registry-declared, rendered ONLY when ≥1 approved client exists (R-AIR-8;
   with none, no door — the zero-state lives in Settings ▸ MCP), each opening U2's sheet
   pre-filled: the Library bulk bar, `postRowMenu`, `BookRowMenuTable`, the Book Settings grant row
   (who reaches this book now + Share…). Their words: app-wide faces keep the app's voice
   (P-13n-1), but R-AIR-8 asks for no "AI" in settings-class wording — the Book Settings row IS a
   settings face; menus are the app's voice. Pick consistently, list every string, PROVISIONAL.
3. **⌥⌘A** (D1 as §3 U3 item 3 says) — the registry act, the Edit menu beside ⌥⌘Z/⌥⌘O, the chord
   sweep re-run at the tip and recorded beside the binding (the ⌥⌘O precedent); the receipt says
   what was granted and carries TWO doors: **Change…** (R-AIR-4 — U2's sheet pre-filled on exactly
   that grant to change rung/duration fast) and **Revoke ›**.
4. **R-AIR-6 — the ONE icon:** propose 2–3 SF Symbols in the sidebar set's language (look at the
   sidebar's Bookcase/Library/Pool/Snippets glyphs first) with captures in your record, build your
   lead as PROVISIONAL; it REPLACES the "shared with AI" text chip on every surface that renders it;
   hover names who reaches it and how far; click opens a small permission popover (client · rung ·
   duration · the WHY · Change… · Revoke). The pending-ask sibling glyph is U4's — leave a slot.
5. **VX-164 — the in-note indicator:** find the note's top-right chrome on the Write surface (and
   the other note modes' mastheads that share it — record which), render the indicator there ONLY
   while the server is ON and ≥1 approved client exists: the shared icon when reachable (popover
   with the why), a LOCK when the note is Private (own mark or a Private book — click → the Private
   toggle, or the book's name when the mark is the book's), nothing at all when neither (calm).
   CHROME ONLY — if anything would need `EditorTextView` / `BlockRangeIndex` / `PaneSurface`,
   STOP and fork to the orchestrator.
6. **The why (core, pure):** grant rows + note facts + open-book → the reaching standing (note
   grant / book "X" / wing "Y" / the open book), consulting `MCPGrantRule` — never a parallel SQL
   fence. Pinned.

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the
real store, `/Applications`, the fence derivation (U1's).

**Acceptance:** core pins + the whole headless package; Mac suites for every surface you touched
(`MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`, `CapabilityRegistryTests`,
`ChordLegibilityTests`, the Library selection/bulk-bar suites, `BookRowMenu`'s, Book Settings',
the Shelf/Bookcase row suites, `HelperCurrencyTests` if ⌥⌘A must appear in ⌘/ — grep the tests
for each changed type) under a HELD stage claim, `skipped:` read. Pre-flight WALK, dev-store Debug,
Study AND Terminal: three notes shared from the Library in one act → one pane row → one Revoke;
a book shared from its row menu and from Book Settings; ⌥⌘A with history, without, already
reaching; the receipt's Change… and Revoke; the icon on the Bookcase with hover and popover; the
in-note indicator's shared icon with its why and a Private note's lock; with ZERO approved
clients none of the faces render. Captures in `notes/plans/13n-c-screens/u3/`.

**Forks / close:** as U1/U2's briefs — propose before building any half beyond the rulings;
PROVISIONAL-and-log; STOP for gating; the UNIT CLOSED banner with not-done, PROVISIONALs, where
to look first, self-assessment.

## U3 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~07:00 MDT). Worktree
`~/dev/variorum-vx-165`, branch `vx-165-13n-c`. No revert is in flight unless a line below says so.
The session is LOCKED at start (07:03 MDT: `CGSSessionScreenIsLocked 1`, `CGDisplayIsAsleep 1`) — the
walk is re-checked at U3-10; offscreen renders stand in only if it is still locked, and are NOT a walk.

### UNIT CLOSED (2026-10-11 ~07:58 MDT — the U3 implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the WALK is HELD** — the session stayed LOCKED (07:03, 07:39, 07:54 MDT); the
offscreen renders of the REAL views (U3-10) stand in and are NOT a walk; every press the brief's walk lists, the
popovers' presentation (only their content was drawn), the zero-client absence of every face on screen, and dark
appearance are owed to the next unlocked session. (2) **The icon is PROPOSED, not picked** — A built, B/C captured
(P-13nc-U3-5); the orchestrator picks, hers at the copy pass. (3) **Not built, recorded:** the share doors on the
Pool's / the sidebar Open strip's / Starred's NOTE rows (only the Library's `postRowMenu` was briefed — P-13nc-U3-8);
the pending-ask glyph (U4's — its slot is `MCPSharedIcon.pendingSymbol`); a "Share…" door inside the permission
popover itself. (4) No `notes/QUESTIONS.md` edit (merge-time, #211); no canon edit. Zero `Sync/`, schema, custody,
editor seam (`git diff --name-only c6ae7999..HEAD` checked), `/Applications`; no Variorum instance ever ran (headless
suites, `xcodebuild test` and one throwaway probe only — the probe file deleted, never committed).

**Commits (branch `vx-165-13n-c`):** `4dc0202c` record opens · `c356871a` core (+ six mutation checks) · `cbdef1fc` the
road + door + sheet (compiling) · `e41a9328` doors, ⌥⌘A, icon, indicator, groups (compiling) · `d985a426` the quiet
slot's second door, the pins, the capture harness · `363b273d` the fixes the suites and captures found · this commit.

**Finals:** core **2,619 / 299** · `VariorumMCPTests` **69 / 9** · workbook **40 / 6** — all green headless · Mac **88
suites / 536 tests**, the one red VX-115's standing pin (not this unit's), 0 skipped · the capture harness green
(22 images).

**PROVISIONALs (for #211 at the merge):** P-13nc-U3-1 (the bulk act refuses whole) · P-13nc-U3-2 (the words) ·
P-13nc-U3-3 (Change… replaces) · P-13nc-U3-4 (3 member titles) · P-13nc-U3-5 (the glyph) · P-13nc-U3-6 (Revoke on a
wider grant; the open book's row) · P-13nc-U3-7 (the indicator's home and gate vs the Bookcase icon's) · P-13nc-U3-8
(⌥⌘A hidden with no client; the unbriefed note rows). **FABLE-OWED rows written at the moment:** F-11…F-14 (§6).
**Implementation decisions (not product):** the road is composed per WINDOW and is Equatable on its two gates; the
icons and the Book Settings row read HELD observations of `reading` + the grants store (never `container`); the
indicator's observation runs only while its gate is open; `MCPGrantOpening`/`MCPGrantPrefill` moved to the road's
shared home (`MCPGrantSheet.Prefill` a typealias — U2's code unchanged); `MCPClient`/`MCPGrantRow` gained public
inits (pins only).

**Where a cold reviewer should look first:** (1) `Operations+MCPGrants.swift` — the bulk act and `replacing:`
(atomicity; `revokeReplacedMCPGrants`' ownership check; that a refused new grant rolls the revoke back — pinned;
`revokeMCPGrant` now rides `revokeMCPGrants` — its clock read kept after validation). (2) `MCPGrantRule.reach` —
read off `decide` at each rung from the top; is any reach shown that `decide` would refuse, or any authorizing grant
misnamed (a once grant shown when a standing one covers the call)? (3) `Queries.mcpSharedActs` — the grouping key
(note grants only; client · rung · duration · `created_at`), `rowid` order, and the frozen-clock edge (two separate
single-note grants in one millisecond group — the exact-stamp doctrine's own edge). (4) The road: `RootView.mcpRoad` /
`NoteWindowView.mcpRoad`, its Equatable-on-gates (is any reader stale because a closure changed and the gates did
not?), and the window sheet road via `ShellRouter.mcpGrantRequest` (⌥⌘A's key-window choice). (5)
`MCPGrantSheet.submit` — which door call each opening takes (approve · bulk · Change… · the pane's plain grant) and
that a pane sheet still speaks only in its caption. (6) R-AIR-8's gates at each door (`canShare`, `fencedBooks`,
`BookSettingsFace.showsGrantRow`, the Edit menu's `if`) and P-2 (a door the op would refuse is never drawn).

**Self-assessment:** the core is small and pinned red-capable (14 pins, six mutations each biting — atomicity, one
stamp, replace, grouping, the why off `decide`, the inert count through the rule), and the faces sit on one road
built by composition, so no feature holds the door. The two judgment calls are Change… = REPLACE (forced by tracing
what an additive Change… does to a lowered rung) and the icon (proposed, not decided). Least certain: how the faces
FEEL under a real pointer — the nested icon's click was proven by a synthetic-event probe, but the popovers'
placement, the Library bulk bar's crowding with a fourth door, and the context bar's trailing icon beside the tray
badge are only seen in offscreen renders; the held walk is where that is settled.

### Pieces

| # | Piece | Status |
|---|---|---|
| U3-0 | Preflight read whole (this plan top to bottom incl. the STANDING BLOCKER + the U1/U2 records; the sitting record R-AIR-4/6/7/8; the brief §3/§4 (+§5/§13); mockups §2/§3 (+§4 for the pending-ask slot); 13n-b P-13nb-U2-10/-11, U3-15, U4-13/-14/-15 + ⌥⌘O's sweep record; `SessionResiliencyProtocol`) + the code the brief names + the traces below | DONE (this commit) |
| U3-1 | Core: the bulk grant (N notes, ONE transaction, ONE stamp) + `replacing:` (Change… = replace, one transaction) + the pane's exact-stamp GROUPS + the WHY (`MCPGrantRule.reach`, the one `decide`) + the reach reads (note · book) + the chord's derivation (newest grant → client + rung) — state-transition pins headless | DONE (`c356871a`) — **ops** (`Operations+MCPGrants.swift`): `grantMCPAccess(_:notes:rung:duration:replacing:)` (deduped, ordered, ONE `date.now`, every note through the one `insertMCPGrant` — a missing/non-note/version target refuses `mcpGrantScopeNotFound`, a fenced note under always `mcpGrantScopeFenced`, ANY refusal rolls the whole act back, empty refuses — PROVISIONAL **P-13nc-U3-1**); `grantMCPAccess(_:_:replacing:)` (Change… — the named grants revoked and the new one minted on ONE stamp; a replaced grant must be this client's, else `mcpGrantNotFound`; a refused new grant leaves the old standing — **P-13nc-U3-3**); `revokeMCPGrants([…])` (one act; `revokeMCPGrant` now rides it — its single-id behaviour byte-equal, the clock read after validation as before). **Domain:** `MCPGrantRule.reach` (the highest rung + `Standing` — `.grant` / `.openBook` — read OFF `decide`'s own `.allow(grantID:)`, never a parallel rule); `Domain/MCPShareChord` (⌥⌘A's pure outcome: grant · openSheet · alreadyReaching; never always). **Queries** (`Queries/MCPShareQueries.swift`): `mcpSharedGroups` / `mcpSharedGroupCount` (acts = live NOTE grants sharing client · rung · duration · `created_at`, in insertion order; book/wing grants never group; titles read for ≤`mcpSharedMemberTitles`=3 members — **P-13nc-U3-4**; an always act's inert count through the rule in one batched facts read); `MCPPlaceReach` + `mcpNoteReach` / `mcpBookReach` / `mcpBookReaches` (the why's WIDER place named — the book's name, the wing's ("Home"); nil for the place's own grant and the open book); `mcpNewestGrant` (revoked rows count, denied clients skipped). **Pins** `MCPShareTests` **13/1 green** headless. **Mutation checks** (each on the committed tree, restored by `git checkout --`, `git diff Sources` empty after each): M1 a stamp per note → 13 issues (the one-stamp pin, every group pin); M2 the bulk act non-atomic (`try?` per note) → 4 (the whole-act refusal pin); M3 Change… without the revoke → 3 (incl. "the lowered rung LANDS"); M4 book grants grouped → 2 (the frozen-clock pin); M5 a why not read off `decide` (max live reaching grant + an open-book fallback) → 4 (a standing grant before a once grant; a fenced note on the open book; a Private book's reach); M6 the inert count without the rule → 1 (a per-ask act is never inert) |
| U3-2 | The road: `MCPShareRoad` (Core/Views — `canShare` ≥1 approved client · `indicatorOn` server ON + approved · `open` · `sheet` · `revoke`) built by each WINDOW (RootView, NoteWindowView) from the door's narrow observables; `MCPGrantOpening` grows `.notes([ids])`, rung/duration prefill, `replacing`, `origin`; the window-level grant sheet | DONE (`cbdef1fc` + `363b273d`: the road EQUATABLE on its two gates — a window rebuilds it every body pass, and an incomparable environment value would re-render every reader; `revoke` awaitable) — `Core/Views/MCPShareRoad.swift` (the road, `MCPGrantOpening` + `MCPGrantPrefill` moved here from the sheet — `MCPGrantSheet.Prefill` is a typealias, U2's code unchanged — and `MCPShareCopy`); the door's NARROW gates `hasApprovedClient` / `serverOn` (written only on a change, from the snapshot's new `approvedCount` and the switch); the snapshot's Shared places is `sharedGroups` (acts) with `shared` the flattened rows (the pane pins' shape) and `sharedCount` = acts; `MCPDoor+Share.swift` (the place-door grant / bulk grant, ⌥⌘A, the receipt with Revoke › + Change…, `revokeFromReceipt`); the sheet: `.notes` WHERE said not chosen (mockup §2), the fenced-among why, the notes confirm, Change… title + rung/duration pre-fill, a place-door sheet speaking on the window's seam; `ShellRouter.mcpGrantRequest`; RootView + NoteWindowView compose the road and host the sheet; Change… says "Confirming replaces the grant you opened this from." under its title |
| U3-3 | The four place-doors (registry-declared, rendered only with an approved client): the Library bulk bar, `postRowMenu`, `BookRowMenuTable` + the Bookcase's own book menu, the Book Settings grant row (nested sheet); every string listed | DONE (`e41a9328`, `363b273d`) — **registry:** `mcpShareHere` (.contextMenu) · `mcpShareNotes` (.surface) · `mcpShareBook` (.surface, takesAccess .native — the R118 walk caught a nil) · `mcpShareThisNote` (.menuBar ⌥⌘A) · `mcpShowSharing` · `mcpChangeGrant` (.surface); `markNotePrivate` gains `.surface` (the lock popover). **The doors:** the Library bulk bar "Share N notes with AI…" (`.notes` in listing order) and `postRowMenu` "Share with AI…" (after Tags…, mockup §2); `BookRowMenuTable.doors(for:shareable:)` (`.share` after the exports — books only; `BookRowDoors.fencedBooks` from the new `Queries.mcpFencedBookIDs`, the fence's own two fragments, the exact complement of the sheet's offer — pinned) rendered by every `BookRowMenu` (the Library's book rows, Starred, Archived); the Bookcase's own `bookMenu` (after Book Settings…; `fencedBooks` held with the icons); Book Settings' GRANT ROW under the Private row ("Shared with claude-code (read and suggest), codex (read)" / "No client reaches this book." · Share…), drawn only on a book, not Private, not THE daily Journal, with an approved client (`BookSettingsFace.showsGrantRow`, pinned), its reach HELD while the sheet is up, its grant sheet presented OVER it (T-U3-7 — `road.sheet`). **Every string (P-13nc-U3-2):** app voice — "Share with AI…" · "Share N notes with AI…" · "Share This Note with AI" (+ its refusal "…acts on the note you have open — open one first.") · the receipts "Shared “X” with claude-code — read and suggest, while connected." / "Changed “X” for … — …" / "claude-code already reaches this note (read and suggest)." / "Revoke ›" · "Change…" · "Revoked."; settings-class, no "AI" — "Shared with …" · "No client reaches this book." · "Share…" · the popover's "Shared with", "<rung> · <duration>", "through the Home wing grant" / "through “X”" / "through the open book", "The open book is switched in Settings ▸ MCP.", "Change…", "Revoke" · the icon's hover "Shared with claude-code (read and suggest) — click for details" · the lock's "Private — click to change" + "A book's Private mark is changed in its Book Settings." · the zero-state "Sharing starts in Settings ▸ MCP, once a client is approved." (a registry note); the sheet — "Change access — claude-code" · "Confirming replaces the grant you opened this from." · "These 3 notes" + "a · b · c and N more" · "Always isn't offered: 1 of these notes is a daily Journal entry, which is only ever shared one ask at a time." (mockup §2 verbatim; its Private / mixed / plural twins) · "Grant read on 3 notes while connected"; the pane — "3 notes" + chip "notes" + the members line + "N inert — a note fenced since (Private or your daily Journal), which always asks". **Retired:** the Bookcase's "shared with AI" chip and its help (`SharedWithAICopy` — no renderer left). **Kept, ruled:** "Private — never shared with AI" in the lock popover (her R-13nb-4 (iv) word) |
| U3-4 | ⌥⌘A — share the note you're in (D1), the Edit menu beside ⌥⌘Z/⌥⌘O, the sweep at the tip recorded at the binding, the helper row; the receipt's two doors (Change… R-AIR-4 · Revoke ›) — `QuietReceiptLine` learns the second door | DONE (`e41a9328`, `d985a426`, `363b273d`) — `MCPDoor.shareThisNote` (the mounted detail's `activePostID`; `Queries.mcpNewestGrant` → `MCPShareChord.decide` → the grant (while connected iff connected, else once; never always), THE sheet with WHERE = this note when there is no history (through `ShellRouter.mcpGrantRequest` — the key window), or the refusal when that client already reaches the note at the rung); the Edit menu item beside ⌥⌘O, HIDDEN with no approved client (P-13nc-U3-8); **THE SWEEP, re-run at the tip (`cbdef1fc`) and recorded at `EditorCommands.keyEquivalent`:** the table's only `a` chord ⇧⌘A; every `.keyboardShortcut(` — only that ⇧⌘A; no `NSMenuItem` keyEquivalent; the one `performKeyEquivalent` (⌘S + the ⌘Z/⇧⌘Z hint arm); the local monitors (PageTurnKeys, CommentsPanel, DivideWSheet, CalmAsks); the system hot key table ([.quickNote] ⇧⌘N); not platform-reserved — ⌥⌘A FREE. The helper row (`HelperView` Writing, beside ⌥⌘O — U4 regroups). The receipt carries `action` Revoke › + `secondary` Change… (`StatusCenter`'s two doors); `QuietReceiptLine` now draws the second door before the first (the toast's order), spaced (the capture showed Terminal running them together) — idle it still asks for zero width. Under receipt_style OFF the doors drop with the line; the same Change…/Revoke live in the in-note indicator's popover |
| U3-5 | R-AIR-6 — the ONE icon (2–3 SF Symbol candidates captured; the lead built PROVISIONAL) replacing the Bookcase's text chip; hover names who + how far; the permission popover (client · rung · duration · why · Change… · Revoke) | DONE (`e41a9328`) — `Core/Views/MCPSharedIcon.swift` (`MCPSharedIcon` + `MCPReachPopover` + the pure `changeOpening`); the Bookcase row draws it where `ShelfViewModel.aiReach` (`Queries.mcpBookReaches` — a HELD observation now, reading `reading` + the grants store only, so a grant made from the row's own menu shows at once and nothing wakes at autosave rate) has the book — the SAME set the retired chip drew (core parity pin under book, wing and open-book shapes). **Candidates (captured — `u3-icon-candidates-{study,terminal}.png`):** A `point.3.connected.trianglepath.dotted` (BUILT — Settings ▸ MCP's own glyph; reads "the MCP door reaches here", points at where the permission lives) · B `eye` (clearest at small size; says "visible", not "editable") · C `antenna.radiowaves.left.and.right` (reach, but radio/wifi connotation) · A's filled twin = U4's pending slot. **The nested click verified:** the icon is a Button inside the row's open Button — a throwaway synthetic-event probe (never committed) on this macOS: a click on the icon fires ONLY the icon (outer 0 / inner 1), a click on the name ONLY the open |
| U3-6 | VX-164 — the in-note indicator at the ContextBar's trailing end (every note mode, both window kinds): shared icon + popover with the why; LOCK when Private (own toggle / the book's name); nothing when neither; only with the server ON and an approved client | DONE (`e41a9328`) — `Core/Views/MCPNoteIndicator.swift` (`MCPNoteIndicatorState` read in ONE observed read — own mark, Private books, `mcpNoteReach`; `matching` keeps a stale read from drawing); `ContextBar` gains `trailing:` (nil ⇒ the bar exactly as before) and `PaneHost` composes the indicator for a NOTE pane only. Its observation runs only while the road says the server is ON with an approved client. The lock popover: the Private toggle (`NotePrivacyAct`) and, through a Private book, "Private through “diary”" + where it is changed. CHROME ONLY — `EditorTextView` / `BlockRangeIndex` / `PaneSurface` untouched (verified by `git diff --name-only`) |
| U3-7 | The pane's Shared places renders the exact-stamp groups ("3 notes · claude-code · read · while connected", the members under it, Revoke covering all) | DONE (`e41a9328`) — `MCPDoor.Snapshot.sharedGroups` (acts; `shared` is now their flattened rows — the 13n-b pins read it unchanged) and `sharedCount` = ACTS; `MCPSharedGroupView` (title "3 notes" + chip, the client · rung · duration line, the members, the inert line) with ONE Revoke (`door.revoke(grantIDs:)` → `revokeMCPGrants`); a group of one is the 13n-b row unchanged; the "all N ›" sheet lists acts too |
| U3-8 | Headless finals: `swift build` + core + `VariorumMCPTests` + workbook | DONE (on `363b273d`) — `swift build --build-tests` clean; the whole package `swift test`: **core 2,619 / 299 green** (2,605/298 + `MCPShareTests` 14/1), **`VariorumMCPTests` 69 / 9 green**, **workbook 40 / 6 green**; 0 failures |
| U3-9 | Mac suites under a held stage claim (the brief's list + every suite over a changed file) | DONE — stage `vx165-u3` (07:34 → released 07:54; no Variorum instance at any point). Final run on `363b273d`'s tree: **88 suites / 536 tests, ONE red = VX-115's standing `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (`BookView.surfaceCapabilities == [.openBookSettings]`, red on main since 13o U3 — the baseline's named standing red, not this unit's)**, 0 skipped. The suites: `MCPShareFacesTests` (new, 14), `MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPEditFacesTests`, `MCPGrantSheetTests`, `MCPNavigationTests`, `CapabilityRegistryTests`, `ChordLegibilityTests`, `HelperCurrencyTests`, `SettingsShapeTests`, the system hot key three, the Library's (`LibraryPreviewBrainTests`, `LibraryPanelHostTests`, `LibraryListFaceTests`, `LibraryInfiniteScrollTests`, the four note-deletion suites, `LibrarySortMenuTests`, `LibraryViewScopeSwitchTests`, `LibraryCardsWordTests`, `IAAndTrashShapeTests`), `BookRowMenuTests`, the seven book-archive suites, `BookCollectingDoorsTests`, `BookStateDoorsTests`, `BookSettingsSheetTests`, the Bookcase's (board brain, move-to-shelf gate, view model, row freeze, census overlay/menu, starred shelf ×2, masthead popover, drag face, placing grip, quick-entry placement, shelf model, promote/palette, the star three, wing book move, duplicate-name, bind), the context bar's (`ContextBarDoorsTests`, `TagChipFitTests`, `ForwardDestinationTests`, `ContextBarTests`), `NoteWindowFirstPassTests`, `NoteTrayTests`, the ascent suites, `TakePaneMeasureTests`, `ConfirmationsSettingTests`, `StatusCenterTests`, `CommandRouterTests`, `TakesLandingTests`, `SealDoorTests`, `ShellChromeTests`, the seven window suites, the five workspace-navigation suites, `VocabularySweepTests`, `TutorialCurrencyTests`. **Found and fixed by the runs:** `mcpShareBook` declared no takes access (R118 walk); the Private-row pin updated as the ritual (A JUSTIFIED EDIT — the lock popover is `.markNotePrivate`'s new `.surface` renderer); the walk's `.surface` union gains `MCPNoteIndicator.surfaceCapabilities` (a new renderer is a new line) |
| U3-10 | The walk (dev-store Debug, Study + Terminal) → `notes/plans/13n-c-screens/u3/` — or, if still locked, offscreen captures of the real views (NOT a walk) | **WALK HELD — the session is LOCKED** (07:03, 07:39 and 07:54 MDT: `CGSSessionScreenIsLocked 1`, display asleep). Unlocking is hers. **What stands in its place — NOT a walk, said plainly:** the gated harness `MCPShareFacesCaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=13nc-u3`) renders the REAL views offscreen over a seeded in-memory library, light, both voices, shot on the closing tree into `notes/plans/13n-c-screens/u3/` (gitignored — verified): `u3-bookcase-*` (the real ShelfView — the icon on the three reached rows, none on the Private "diary"), `u3-icon-candidates-*` (A/B/C + A's pending twin), `u3-popover-*` (a book: claude-code's own grant, codex "through the Home wing grant", cursor "through the open book" with no Change/Revoke), `u3-indicator-shared-*` / `u3-indicator-private-*` (the context bar's trailing icon / lock), `u3-indicator-popover-*` ("through “the lightning thief”", "through the Home wing grant"), `u3-sheet-bulk-*` (These 3 notes, a Private one among them → Once only, mockup §2's why, "Grant read on 3 notes once"), `u3-sheet-change-*` ("Change access — claude-code", the replaces line, suggest · always pre-filled), `u3-pane-*` (Shared places: "3 notes" one row + the wing + the book), `u3-book-settings-*` (the grant row under Private), `u3-receipt-*` (the quiet line with Change… · Revoke ›). **What the captures caught and was fixed:** Terminal ran the receipt's two doors together (spaced); Change… gave no sign it replaces (the line added). **Popovers are another window** — their CONTENT is drawn directly (`MCPReachPopover`), not the presentation. **OWED to the next unlocked session (the orchestrator's walk):** the brief's list on the dev store, both voices — three notes shared from the Library in one act → one pane row → one Revoke; a book shared from its row menu and from Book Settings; ⌥⌘A with history, without, and already reaching; the receipt's Change… and Revoke; the icon's hover + popover on the Bookcase; the in-note indicator's icon + why and a Private note's lock; with ZERO approved clients none of the faces (menus, bulk bar, Book Settings row, ⌥⌘A, icons, indicator) render; dark appearance |
| U3-11 | UNIT CLOSED banner | DONE (this commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-U3-1 — no place-door exists, and the main window cannot reach the door.** The grant sheet opens
  only from the pane (`MCPPane.granting` → `MCPGrantSheet`); U2's `MCPGrantOpening.place` names ONE note,
  book or wing. The Library bulk bar (`LibraryCatalogView` :673–711) carries Tag / Untag / Delete N notes;
  `postRowMenu` (:1178) has no share row; `BookRowMenuTable.doors` (`Core/Views/BookRowMenu.swift`) and the
  Bookcase's own `bookMenu` (`ShelfView` :787) none; `BookSettingsSheet.state` carries only the Private row.
  `RootView` and `NoteWindowView` take no MCP door — `appDelegate.mcp` reaches only `EditorCommands`, the
  Settings scene and the ask sheet's `WindowGroup` modifier. So every door needs a road built by the WINDOW
  (composition — the `checkForUpdatesDoor` / `.environment(wings)` precedent), never a feature holding
  `MCPDoor`.
- **T-U3-2 — one grant per call, one row per grant.** `grantMCPAccess` → `insertMCPGrant` writes one row on
  its own `date.now` in its own transaction; N calls = N stamps = N rows in Shared places (`mcpSharedRows`
  lists every live grant). The exact-stamp doctrine (`restoreContainer`'s stamp-matched revival, AppSpec §9)
  is the no-schema road: ONE transaction, ONE clock read, N rows on one `created_at` — grouped on read.
- **T-U3-3 — the chip says neither who nor how far, and has no click.** `ShelfView` :678–687 draws
  `SharedWithAICopy.chip` ("shared with AI") from `model.aiShared` (`Queries.mcpReachableBookIDs`, one-shot
  in `refreshAggregates`); its help is "An MCP client can read this book now — see Settings ▸ MCP." The set
  is honest under every grant shape (P-13nb-U2-11) but carries ids only.
- **T-U3-4 — the WHY is already decided, and thrown away.** `MCPGrantRule.decide` returns
  `.allow(grantID:consumesOnce:)` — the grant that authorizes the call, nil for the open book.
  `Queries.mcpNoteSharing` keeps only the highest allowed rung per client. The why = that authorizing grant's
  scope (this note / book "X" / wing "Y" / the open book) — read off `decide` itself, so no parallel rule can
  exist.
- **T-U3-5 — the in-note face today is the note ▾ menu's line only** (`PrivateMarkCopy.sharedLine` —
  "Shared with AI: claude-code (read)"), two clicks deep, no why. The note's upper right: the pane's
  `ContextBar` (`Workspace/ContextBar.swift`, composed by `PaneHost` for every pane of BOTH window kinds and
  every note mode) draws ← · book · → · the tray badge and then a `Spacer` — its trailing end is empty. That is
  chrome (`PaneHost`/`ContextBar`), not the editor seam (`EditorTextView` / `BlockRangeIndex` / `PaneSurface`
  untouched).
- **T-U3-6 — a receipt carries ONE door on the quiet slot.** `StatusCenter.deliver` takes `action` +
  `secondary`, and `StatusToast` draws both; `QuietReceiptLine` draws only `item.action`. R-AIR-4's Change…
  beside Revoke › needs the quiet slot to draw the second door too (receipt_style's default is quiet).
- **T-U3-7 — a sheet over a sheet.** `BookSettingsSheet` is itself a sheet (from the Bookcase row, the book
  masthead and `BookRowDoors`); a grant sheet presented from the WINDOW root while it is up is not a road
  SwiftUI promises on macOS, so its Share… presents the grant sheet NESTED from the settings sheet's own
  content (the road builds the view; the feature never names `MCPGrantSheet` or `MCPDoor`).
- **T-U3-8 — "Change…" must REPLACE, or a lowered rung never lands.** The sheet only ever ADDS a grant
  (`MCPDoor.grant`; the client row's Change… is additive by design — "a grant is taken away with its own
  Revoke"). Pre-filled on a grant and confirmed lower (⌥⌘A minted edit · while connected; she changes it to
  read · once), an additive sheet leaves the edit grant live — her change silently does not take. R-AIR-4 is
  "to change its details": the grant-specific Change… doors (the receipt's, the popovers') revoke what they
  name and mint the new grant in ONE transaction; the client row's Change… stays additive (it names no grant).
  PROVISIONAL (P-13nc-U3-3) + a FABLE-OWED row.
- **D-U3 — no `Sync/`, no schema, no custody, no editor seam, no fence derivation** (consumed through
  `mcpNoteFacts` / `mcpBookFacts` / `MCPGrantRule` only — re-verified at close).

---

## THE U4 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U4 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on
branch `vx-165-13n-c` (NEVER the main checkout). Commits say `Part of VX-165` (and
`Part of VX-157` for the wing switcher), NO attribution trailer, push after every commit.
`notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in the "U4 UNIT RECORD" section below
from your FIRST commit, foreground waits only (a `grep -q … && break; sleep 5` poll loop), no
subagents.

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM (rulings, D-1…D-5, §3 U4,
§7, §8, the U1–U3 records — U3 built the icon family with a slot for the pending-ask glyph and the
in-note indicator you extend); the sitting record `notes/plans/vx-156-grant-ux-design-kickoff.md`
(R-AIR-5, -6, -8, -15, round 5); the brief `notes/plans/vx-156-grant-ux-brief.md` §5, §6, §7,
§13 (the chord sweep); the mockups §4, §5, §6. The 13n-b plan's AF-6 (the ask never blocks; the
queue's shape), P-13nb-U2-9 (the arrival you are superseding), R-13nb-23/26g (etiquette is law).
Code: `Features/MCP/MCPDoor.swift` (the ask queue, `presentedAsk`), `VariorumApp.swift` (~l.86–95
the WindowGroup `.sheet(item:)` that self-presents asks), `Features/MCP/MCPAskSheet.swift`,
`MCPPane.swift`, `Features/Shelf/WingSwitcherMenu.swift` + `ShelfView.swift` (~l.504) and the
Library's masthead (`Features/Library/`), `EditorCommands.swift` (the chord table + its sweep
records), the registry under `App/Variorum/Shared/`, `Features/Help/` (`HelperView.groups` — the
ONE source both Settings ▸ Shortcuts and ⌘/ render), `Features/Settings/SettingsShape.swift`,
`Features/CalmAsks/`.

**What U4 builds — §3 U4 items 1–6, with these concretions:**
1. **The ask projection:** one observable, keyed by target (note id · book id · wing id), read by
   every face — never a broadcast (P-4). The pending-ask glyph (U3's icon family) on: Library and
   Pool note rows, the book TOC rows, the bottom bars' note ▾, Bookcase rows, the wing switcher's
   rows, the masthead's wing word, and U3's in-note indicator. Hover names the client(s) and what
   they ask; HER press opens THAT ask's sheet. Never raises, scrolls, toasts or self-presents.
   Clears on answer, on the queue's cap forgetting it, and on store detach.
2. **Arrival X:** retire the self-presenting `.sheet(item:)` (asks NEVER appear by themselves);
   Settings ▸ MCP gains **Waiting** above Connection requests (each row "<client> asks to <rung>
   <in place>" with the U2 disambiguated label, age, Answer…; capped with its "all N ›" road).
   The wire is unchanged. Update every sentence that described the old arrival (the 13n-b handoff
   is history — do not edit it; the guide/help/settings copy you find, yes).
3. **⌥⌘, — "MCP Settings…"** in the Variorum app menu under Settings…: opens Settings at MCP,
   scrolled to Waiting when an ask waits. Registry act; chord sweep at the tip, recorded.
4. **⌘L — the wing switcher (R-AIR-15, her ratified chord):** an app-wide command; ⌘L opens the
   switcher as a type-to-filter picker (SearchPicker's idiom or its own popover — your call, keep
   it FAST); while the switcher is open, holding ⌘ and tapping L again moves the highlight to the
   next wing (wrapping), releasing ⌘ commits the highlighted wing (the ⌘-tab idiom), return
   commits, Esc closes; the masthead switcher CLICKED WITHOUT TYPING cycles to the next wing (her
   "click-without-typing CYCLES … fast to click"); keep New/Rename/Move/Delete reachable (a menu
   affordance beside the cycling click — record how). Present on the Bookcase masthead AND the
   **Library** masthead (round 5). The existing "Now in …" receipt speaks. One quiet line in the
   switcher: Snippets is the one room every wing shares. Bare ⌘L re-verified free at the tip across
   all seven places of brief §13 — record the sweep beside the binding.
5. **The shortcuts pane + ⌘/:** `HelperView.groups` gains every chord added this phase (⌥⌘A from
   U3, ⌥⌘, and ⌘L here) and an MCP group holding them with ⌥⌘O (Show the AI's Last Change) and
   ⌥⌘Z's client-named undo; the Settings search reaches them; `HelperCurrencyTests` (or its kin)
   green and extended.
6. **"While connected":** write 2–3 copy options in your record (her ask: she finds it vague),
   build the most neutral PROVISIONAL, everywhere the duration is said (sheet, ask, pane, receipts).

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the
real store, `/Applications`, the fence derivation.

**Acceptance:** pins for the projection (pure keying, clearing) + the whole headless package; Mac
suites for every changed surface (`MCPPaneTests`, `MCPAskAndReceiptTests`, `CapabilityRegistryTests`,
`ChordLegibilityTests`, `HelperCurrencyTests`, `SettingsShapeTests`, the Shelf/Library masthead
and wing suites — grep for `WingSwitcher`, `wing`), HELD stage claim, `skipped:` read. Pre-flight
WALK, dev-store Debug, Study AND Terminal: a scripted client's ask arriving while you type in a
note (nothing appears; the glyph does), answered from the glyph and another from Waiting; ⌥⌘,
landing at Waiting; ⌘L typed-filter commit, held-⌘ L cycling commit, the masthead click cycling
on BOTH mastheads; the shortcuts pane and ⌘/ listing the new chords. Captures in
`notes/plans/13n-c-screens/u4/`. (The REAL-client ask leg is the orchestrator's live round.)

**Locked-session note (standing):** if the Mac's session is locked (check `/usr/bin/swift -e 'import CoreGraphics; print((CGSessionCopyCurrentDictionary() as? [String:Any])?["CGSSessionScreenIsLocked"] ?? "nil")'`), HOLD the walk; a gated offscreen render harness of the real views stands in, said plainly to be NOT a walk (U2/U3's precedent). The ⌘L held-⌘ cycling and the never-self-present promise get state-transition pins since they cannot be walked.

**Ladder carry (U1 round 1, F2 — the ask road half):** the ask sheet's Always on a BOOK ask carries R-AIR-3's clause; verify U2 built it and pin it if not.

**Forks / close:** as the earlier briefs.

## U4 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~07:57 MDT). Worktree
`~/dev/variorum-vx-165`, branch `vx-165-13n-c`. No revert is in flight unless a line below says so.
The session is LOCKED at start (07:57 MDT: `CGSSessionScreenIsLocked 1`) — the walk is re-checked at
U4-10; offscreen renders stand in only if it is still locked, and are NOT a walk.

### UNIT CLOSED (2026-10-11 ~09:20 MDT — the U4 implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the WALK is HELD** — the session stayed LOCKED (07:57, 08:57 MDT); the offscreen
renders of the REAL views (U4-10) stand in and are NOT a walk — no press, hover, held key, menu, sheet presentation
or Settings scroll was exercised; the held-⌘ L cycling and ⌥⌘,'s landing are pinned as state transitions only. The
brief's walk list and the REAL-client ask leg are owed (U4-10 names every item). (2) **Not built, recorded:** the
pending glyph on the Library's Timeline rows, its search answer sheet's passages, the sidebar's Open strip and
Starred note rows (the brief named the Library and Pool note rows, the book TOC, the bars, the Bookcase, the
switcher, the masthead and the indicator — all built); a "Not now" on the ask's sheet (product — P-13nc-U4-8, a
#211 question); per-wing counts in ⌘L (P1). (3) **Two pre-existing order-dependent reds** surfaced by the wider
246-suite run (`LibraryInfiniteScrollTests.aPageLandingReDrawsNoRowAlreadyBuilt`,
`DestructiveUndoWarningTests.redoNeverAsks`) — reproduced IDENTICALLY on U3's built tree, green alone; for the
orchestrator to ticket (U4-9). (4) No `notes/QUESTIONS.md` edit (merge-time, #211); no canon edit (P-13nb-U2-9's
arrival superseded — the closeout's delta: AppSpec §12's MCP line gains "asks wait at their icon and in Waiting").
Zero `Sync/`, schema, custody, editor seam, `Sources/` (not one package line), `/Applications`; no Variorum
instance ever ran.

**Commits (branch `vx-165-13n-c`):** `a41efc1b` record opens · `6f39cd18` the build (compiling) · `9b8b5cf2` the pins
+ harness · `246d528a` the ritual the runs found, red-on-old by revert, the calls, F-15/F-16 · this commit (U4-6b,
the finals, the banner).

**Finals:** headless core **2,619 / 299** · `VariorumMCPTests` **69 / 9** · workbook **40 / 6** — all green ·
Mac **246 suites / 1,498 tests**, 17 skipped (standing gates), the only reds VX-115's standing pin and the two
pre-existing order-dependent reds (provenance measured on U3's tree) · after U4-6b the touched suites **68 / 5**
green · the capture harness green (18 images).

**PROVISIONALs (for #211 at the merge):** P-13nc-U4-1 ("until it disconnects") · -2 (a press answers the oldest)
· -3 (the masthead wears every wing ask) · -4 (⌘L's release commits only after a held tap) · -5 (the word cycles
with ≥2 wings; the menu's pick stays silent) · -6 (Waiting only while an ask waits; 3 + all N) · -7 (⌘L is a
sheet, no counts) · -8 (a QUESTION: no "Not now" on the ask's sheet). **FABLE-OWED rows written at the moment:**
F-15 (the ask arrival + the answer-once guard + deny-forgets — the answer road mints grants), F-16 (the duration
word in every grant confirm).

**Where a cold reviewer should look first:** (1) `MCPDoor`'s ask road — `enqueue` / `answer` (the guard: only an
ask still waiting is answered, T-U4-5) / `deny` (forgetting AFTER the op lands — the async gap: an ask arriving
for that client in between is not possible by the wire's own rule, MCPAsk is never raised for an unapproved
client, but confirm) / `detach` / `beginAnswering`–`endAnswering` (the cap's protection: does any path leave an
id in `answering` forever? the sheet's `onDisappear` and `answer` clear it). (2) The two hosts of an ask's sheet —
`mcpAskSheet(door:askID:)` in `RootView`, `NoteWindowView` and `MCPPane`, plus the nested road
(`MCPShareRoad.askSheet` / `answeringAsks`) used by ⌘L's switcher: can one ask be on screen twice, and does every
host close when it is answered elsewhere (the getter reads the queue)? (3) `WingSwitcherKeyCatcher` (U4-6b's
rebuild) — the window scoping (`event.window === window`) for flagsChanged, the consumption rule, and that the
menu's ⌘L request path (`RootView`'s `onChange` → `tapL`) and the monitor never BOTH act on one press. (4)
`WingSwitcherMenu`'s two faces (≥2 wings: the cycling word + ▾; one wing: the whole label) and that every act
13i-d drew is still reachable. (5) `AppSettingsView.adoptMCPRequest` + `MCPPane.landAtWaiting` — the two "seen"
marks on the door (a request adopted by one window and never scrolled? a fresh Settings window vs one already
up). (6) R-13nb-23/26g: grep that nothing but `answerAsk` sets `mcpAskRequest` (pinned) and that no new code
path raises a window, toasts or presents on an arrival.

**Self-assessment:** the arrival change is small at its core (one host deleted, one guard, one projection) and
pinned both as state and as source, with the two real defects the trace found proven red-on-old by revert. The
face work is wide (nine hosts) but every host draws one shared glyph whose calm state is no view, so the shipped
layouts are unchanged at rest (the 246-suite run includes the alignment and layout pins). ⌘L's held-key machine
is pure and exhaustively pinned; its AppKit edge — the key monitor — is the least-proven piece: it can only be
truly checked under a real keyboard, and reading it after the runs found a defect (U4-6b) the pins could not have
caught. Least certain: how the held-⌘ cycle FEELS (the sheet's open animation against a quick ⌘L-L-release), and
whether the filled pending twin is distinguishable enough from the outline shared icon beside it — both the
UX walk's to judge.

### Pieces

| # | Piece | Status |
|---|---|---|
| U4-0 | Preflight read whole (this plan top to bottom incl. the STANDING BLOCKER + the U1–U3 records; the sitting record R-AIR-5/6/8/15 + round 5; the brief §5/§6/§7/§13; mockups §4/§5/§6; 13n-b AF-6, P-13nb-U2-9, R-13nb-23/26; `SessionResiliencyProtocol`) + the code the brief names + the traces and the chord sweep below | DONE (this commit) |
| U4-1 | The ask QUEUE + PROJECTION (pure): `MCPAskQueue` (dedupe per client · target · rung, the cap forgetting the oldest NOT being answered, the arrival stamp, forget-a-client) and `MCPAskBoard` (keyed by note · book · wing; the hover words) — Mac pins | DONE (`6f39cd18` code, `9b8b5cf2` pins) — `MCPAsksWaitTests` (queue dedupe + first stamp, the cap protecting the asks she opened, forget-a-client, the board keyed by target in arrival order, the glyph's words) green |
| U4-2 | ARRIVAL X: the WindowGroup's self-presenting `.sheet(item:)` RETIRED; the window road opens THAT ask's sheet on her press (`MCPShareRoad.answerAsk`); `answer` ignores an ask no longer waiting; a denied client's asks clear; the never-self-present pin | DONE (`6f39cd18`, `9b8b5cf2`) — the never-self-present promise pinned as STATE (`anArrivalOnlyWaits`: an arrival changes the queue and its board, nothing else — no Settings request, no toast/receipt) and as SOURCE (`noSceneHostsTheAskSheet`: `VariorumApp` names no `MCPAskSheet`/`presentedAsk`; every `mcpAskRequest =` in the app is a road's `answerAsk` or a clear). **THE TWO BUG-CLASS ROWS, RED-ON-OLD BY REVERT** (the pre-fix `answer` — remove then grant unconditionally — and the pre-fix `deny` — the asks kept — restored in `MCPDoor.swift`, the suite run, then `git checkout --` from `9b8b5cf2`, `git diff` empty): `MCPAsksWaitTests` **12 green / 2 RED, 3 issues** — `oneAskAnsweredTwiceMintsOneGrant` (grants.count ≠ 1, T-U4-5) and `denyingAClientForgetsItsAsks` (2 issues, T-U4-4) — exactly the two; GREEN on the restored tree |
| U4-3 | The pending-ask GLYPH (`MCPAskGlyph`, U3's family's filled twin) on Library + Pool note rows, the Book Panel's rows, both bars' `note ▾`, Bookcase rows, the wing switcher's rows + masthead word, the in-note indicator | DONE (`6f39cd18`) — `.mcpOpenAsk` declared, walked (each host appends `MCPAskGlyph.surfaceCapabilities`; the bars' glyph rides the `.surface` door, never their `renderedCapabilities` — the bottom-bar walk unchanged); captured (U4-10) on the Bookcase row + masthead, the Library row + masthead, the indicator, ⌘L's rows. **Observed for the UX walk:** at row size the FILLED pending twin and U3's OUTLINE shared icon read very alike side by side (`u4-bookcase-*`, `u4-indicator-*`) — P-13nc-U3-5's family pick, not re-opened here |
| U4-4 | Settings ▸ MCP ▸ WAITING (above Connection requests; capped 3 + "all N ›"; Answer… opens the sheet in the pane) + its catalog row + every sentence describing the old arrival | DONE (`6f39cd18`) — pinned (`waitingIsCappedSaidAndFindable`); captured (`u4-pane-*`: three rows newest first with ages, "all 4 ›"). **The sentences that described the old arrival:** the registry's `.mcpAnswerAsk` note ("…on the sheet it arrives on" → "…open it from the ask's icon, or from Settings ▸ MCP ▸ Waiting"), the Settings pane blurb (+ "the asks waiting for your answer"), and the app's comments (`MCPDoor`, `MCPAskSheet`, `VariorumApp`, `MCPNoteIndicator`); SAFE as found: the wire's `askedSentence` ("Variorum has asked the author — call again once she answers." — still true: the ask waits for her) and the field guide/help (no arrival sentence anywhere); the 13n-b handoff is history, untouched |
| U4-5 | ⌥⌘, — MCP Settings… (app menu, under Settings…): Settings opened at MCP, scrolled to Waiting when an ask waits; registry act; the sweep at the binding | DONE (`6f39cd18`) — pinned (`theMCPSettingsChordLandsOnceAtWaiting`; the chord's collision pin in `WingSwitcherChordTests`); the sweep recorded at `EditorCommands.keyEquivalent`. The window's opening and scroll are NOT walked (locked) |
| U4-6 | ⌘L — the wing switcher (R-AIR-15): a pure brain (`WingSwitcherBrain` — filter, held-⌘ L cycling, release/return commits, Esc) + the sheet (the ⌘K idiom) + the masthead word's CYCLING click with the ▾ menu beside it, on the Bookcase AND the Library masthead (the switcher moves to `Core/Views`); "Now in …" speaks; the Snippets line; the sweep at the binding | DONE (`6f39cd18`, `9b8b5cf2`) — `WingSwitcherChordTests` 12/1 green: every brain transition (opens on the current wing; held-⌘ L cycles + wraps + release commits; a plain press-release stays for typing; typing filters case- and diacritic-insensitively; return commits / closes on the current; arrows never arm the release; a typed change ends a cycle; a row click), the monitor's key classes (⌘L only — ⇧⌘L / ⌃⌘L / a typed l are not; ⌘'s release; Esc), the spoken switch ("Now in “variorum”." / "Now in Home.", silence on the current) and the cycle, the chord declared/wired/collision-free across every `CapabilityID`, the one view in `Core/Views` on BOTH mastheads with the Snippets line. Captured (`u4-switcher-{open,cycled,typed}-*`, both mastheads). The held-⌘ cycling under a real keyboard is NOT walked (locked) |
| U4-7 | The shortcuts pane + ⌘/: `HelperView.groups` gains an MCP group (⌥⌘, · ⌥⌘A · ⌥⌘O · ⌥⌘Z's client-named undo) and ⌘L | DONE (`6f39cd18`) — the MCP group (⌥⌘, · ⌥⌘A · ⌥⌘O · ⌥⌘Z quoting the Edit menu's real "Undo claude-code's take" — `MCPWriteAct.undoLabel`) + the ask icon's row; ⌥⌘O/⌥⌘A moved out of Writing (not doubled); ⌘L in Navigation. Pinned (`theHelpersMCPGroupHoldsEveryMCPChord`); the registry's discoverability guard (`everyDeclaredShortcutIsFindableInTheHelper`) and `SettingsShapeTests`' one-list pin green — Settings ▸ Shortcuts and its search read the same list. Captured (`u4-helper-*`) |
| U4-8 | "While connected" — copy options recorded; the most neutral built PROVISIONAL everywhere the duration is said | DONE (`6f39cd18`, `9b8b5cf2`) — the options in "The calls made in the build" below (P-13nc-U4-1); pinned (`theBoundedDurationSaysWhenItEnds`); four pins updated as the ritual (annotated in place) |
| U4-6b | **Found by reading my own monitor after the runs (not walked — the session is locked): the ⌘L monitor ate the Esc of an ask's sheet opened OVER the switcher**, and answered keys of ANY window. The trace: `WingSwitcherKeys.start`'s monitor returned `nil` (consumed) for every ⌘L/Esc it classified, even when the sheet's handler declined (`nestedAsk != nil`), so Esc never reached the nested ask sheet's Don't allow; and the local monitor was app-wide, not scoped to the switcher's window | DONE (the closing commit) — rebuilt in the `PageTurnKeys` / `CommentsPanel` shape: `WingSwitcherKeyCatcher`, a hit-test-transparent view whose monitor answers ONLY its own window's events (the switcher's sheet — a nested ask sheet is another window, so its keys pass through), consuming only what the handler ACTED on and never ⌘'s release; the rule extracted pure and pinned (`WingSwitcherKeys.consumes`). Design-class (no red-on-old possible headlessly — the scoping is AppKit's `event.window`); `WingSwitcherChordTests` + the four neighbours 68/5 green |
| U4-9 | Headless finals (`swift build` + core + `VariorumMCPTests` + workbook) + Mac suites under a held stage claim | DONE — **headless** (on `246d528a`, zero `Sources/` lines in the unit — `git diff --name-only c6d5d23a..HEAD -- Sources Package.swift Tests` empty): `swift build --build-tests` clean; **core 2,619 / 299 · `VariorumMCPTests` 69 / 9 · workbook 40 / 6 — all green** (U3's finals exactly). **Mac** (stage `vx165-u4`, 08:2x→09:1x MDT; no Variorum instance at any point — `pgrep` clean): every suite whose file names a changed type, derived by script — **246 suites / 1,498 tests**, 17 skipped (the standing opt-in/gated tests: the four capture harnesses incl. U4's own, the opt-in oracle and list-face suites), **6 issues in 3 tests, none U4's:** (1) VX-115's standing `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; (2) `LibraryInfiniteScrollTests.aPageLandingReDrawsNoRowAlreadyBuilt` ("re-drew 18 / 12 rows"); (3) `DestructiveUndoWarningTests.redoNeverAsks` (3 issues; green in this set's first run). **PROVENANCE, measured:** the IDENTICAL set (minus U4's three new suites, 243 suites / 1,471 tests) run on U3's BUILT tree (`DerivedData/vx165-u3`, `test-without-building` — no U4 code) fails the SAME three tests with the same counts (18 / 12; the redo's 3) — pre-existing, order/parallel-dependent: both read process-global state that parallel suites write (`LibraryPagedNotesProbe.rowBodies` is a static counter; the opt-in oracle suite's own skip note names that class), and both are GREEN ALONE on the U4 tree (12 tests / 2 suites) and the scroll suite green beside the four other catalog-mounting suites (21/5). U3's narrower 88-suite set never hit them. **For the orchestrator to ticket** (implementers don't touch the board): the two order-dependent reds, owner the VX-34 harness-calibration family. The ritual pins the runs found (`BookPanelTests`' declared set, `MCPPaneTests`' catalog rows) updated and annotated (`246d528a`); after U4-6b, `WingSwitcherChordTests`, `MCPAsksWaitTests`, `CapabilityRegistryTests`, `WingSwitcherTests`, `HelperCurrencyTests` re-run 68/5 green |
| U4-10 | The walk (dev-store Debug, Study + Terminal) → `notes/plans/13n-c-screens/u4/` — or, if still locked, offscreen captures of the real views (NOT a walk) | **WALK HELD — the session is LOCKED** (07:57 and 08:57 MDT: `CGSSessionScreenIsLocked 1`). Unlocking is hers. **What stands in its place — NOT a walk, said plainly:** the gated harness `MCPAsksWaitCaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=13nc-u4`) rendered the REAL views offscreen over a seeded in-memory library with four asks waiting (a note ask from two clients, a book ask, a wing ask), light, both voices, into `notes/plans/13n-c-screens/u4/` (gitignored — `git check-ignore` verified; decoded from the log by a scratchpad script): `u4-bookcase-*` (the masthead's CYCLING word "· Home" with the wing ask's glyph and its ▾; the book ask's glyph on "the lightning thief" beside U3's shared icon), `u4-library-*` ("Library · Home ◆ ▾ everything — sortable, searchable" — round 5; the asked note's row glyph), `u4-indicator-*` (the shared icon + the pending glyph at the context bar's trailing end), `u4-pane-*` (Waiting: three rows newest first with ages, Answer…, "all 4 ›", above Clients), `u4-ask-sheet-*` (her press's sheet: the book ask with R-AIR-3's reach line — the F2 carry on screen), `u4-switcher-{open,cycled,typed}-*` (⌘L: the current wing marked, the highlight after one held-⌘ L, "vari" filtered; the foot and the Snippets line), `u4-helper-*` (⌘/: the MCP group + ⌘L). **What the captures showed, for the UX walk:** the FILLED pending twin and the OUTLINE shared icon read very alike side by side at row size (P-13nc-U3-5's family — not re-opened here); Terminal lowercases the foot's key name ("tap l") as it lowercases every chrome key ("⌘k", "⌘j") — the voice's idiom; the helper lowercases every group title ("mcp") — its idiom. **No press, hover, held key, menu, sheet presentation or Settings scroll was exercised.** **OWED to the next unlocked session (the orchestrator's walk + its REAL-client ask leg):** a client's ask arriving while she types in a note (nothing appears; the glyph does — on the note's Library/Pool row, the Book Panel, the bar's note ▾, the indicator), answered from a glyph and another from Waiting; ⌥⌘, landing at Waiting (fresh Settings window and one already open); ⌘L typed-filter commit, held-⌘ L cycling commit, Esc, and an ask answered from a switcher row (its Esc must reach the ask's sheet — U4-6b); the masthead word cycling on BOTH mastheads and the ▾ menu's acts; a denied client's glyphs leaving; the shortcuts pane and ⌘/; both voices, dark appearance |
| U4-11 | UNIT CLOSED banner | DONE (the closing commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-U4-1 — the self-presenting arrival (VX-156 item 4; brief §5).** `VariorumApp.swift:86–95` hosts
  `.sheet(item: Binding(get: { appDelegate.mcp.presentedAsk }, set: { _ in }))` on the MAIN `WindowGroup`;
  `MCPDoor.presentedAsk = asks.first` (`MCPDoor.swift:135`) and `enqueue` (`:414`) appends — so the moment a
  client's call is refused past its grant (AF-6's `onAsk` hook, `:308`), a sheet presents on every main
  window, mid-sentence (P-13nb-U2-9's provisional arrival). No other face shows an ask; the pane has no
  waiting list (AF-6's optional rows, unbuilt at 13n-b). Arrival X = remove the host; the queue stays.
- **T-U4-2 — the cap's protection names "the one on screen".** `enqueue` removes index 1 past `askCap`
  (`:417`) because index 0 is the presented sheet. Under arrival X nothing is on screen by itself; the
  protected asks become exactly those whose sheet she OPENED (a set — several windows and the pane can each
  hold one).
- **T-U4-3 — an ask has no age.** `MCPAsk` (`Sources/VariorumMCP/MCPWriteSupport.swift:39`) carries
  client · scope · title · rung · fence — no time. Waiting's "2 minutes ago" (mockup §4) needs the APP's
  queue to stamp arrival (the first raise; a deduped re-raise keeps it). The wire is unchanged.
- **T-U4-4 — a denied client's ask is a dead door.** `answer` grants through `grantMCPAccess`, which
  refuses `mcpClientNotApproved` once `deny` (`:376`, also the client row's Revoke) has run; an ask left
  waiting from that client would be a glyph whose press can only refuse (P-2). Cleared on deny.
- **T-U4-5 — answering twice mints twice.** `answer` (`:437`) removes by id and then grants
  unconditionally; with sheets opened by HER press from several places (two windows, the pane), the second
  answer of the same ask would mint a second grant. `answer` must act only on an ask still waiting.
- **T-U4-6 — Settings opens where it was.** `AppSettingsView.pane` is local `@State` (default `.general`,
  `:75`); nothing outside selects a pane. `openSettings` (the SwiftUI action) opens the window; the MCP
  pane is a `Form` with no anchor to scroll to.
- **T-U4-7 — the wing switcher today.** `WingSwitcherMenu` (`Features/Shelf/`) is rendered by ONE
  feature, the Bookcase masthead (`ShelfView.swift:513`); its WHOLE label is a `Menu`, so a click always
  opens the list (no cycle); no chord reaches it; the Library masthead (`LibraryCatalogView.swift:562`)
  carries no wing face though the Library lists one wing; `WingsModel.switchTo` speaks nothing (13i-d's
  "the surfaces changing IS the answer"). The Library rendering it too makes it a two-feature view →
  `Core/Views/` at this touch (CLAUDE.md).
- **T-U4-8 — the F2 carry (the ask road's R-AIR-3):** VERIFIED — U2 built `MCPAskCopy.reachLine`
  (rendered by `MCPAskSheet`) and pinned it (`MCPGrantSheetTests` 251–259: a book ask's "Any answer below
  grants it in “…”, including to future entries.", the distinguished form, the wing twin, nil for a note).
  Nothing to build; the carry closes here.
- **THE CHORD SWEEP (2026-10-11, on `fa7a2937` — re-run at the binding commit):** (1) the table
  (`EditorCommands.keyEquivalent`): the only `l` chord is ⇧⌘L (Save Choices as Lens); no `,` chord;
  (2) every `.keyboardShortcut(` in `Variorum/` + `Shared/`: `l` only as ⇧⌘L and ⌃⌘L (Lock Library Now);
  `,` nowhere (⌘, is SwiftUI's Settings item); (3) `NSMenuItem` keyEquivalents: none set; (4) the
  overrides: `EditorTextView.performKeyEquivalent` (⌘S + the non-consuming ⌘Z/⇧⌘Z hint arm), the
  `keyDown` trio (⇧⏎ soft newline; the capture box's ⏎/⇧⏎; the flight's deferral) — no `l`, no `,`;
  (5) the local monitors: `PageTurnKeys` (unmodified ←/→), `CommentsPanel` (⌘⏎, ⎋), `DivideWSheet` (passes
  every ⌘/⌃ event), `CalmAsks` and `ProtectionController` (observe, never consume), `PressReporter` /
  `PaneFocusCatcher` (mouse only); (6) the system hot keys: `[.quickNote]` (⌃⌥⌘N); (7) the registry's
  labels: `⌘⇧L` only. Not platform-reserved (brief §13's list). **Bare ⌘L and ⌥⌘, are FREE.**

### The calls made in the build (each a PROVISIONAL or an implementation decision — said plainly)

- **P-13nc-U4-1 — "while connected" → "until it disconnects"** (her round-2 ask: "she finds it vague but has
  no replacement yet" — copy OPTIONS at the build). **The options:** (a) **"until it disconnects"** — BUILT: it
  says when the grant ENDS, which is the thing "while connected" left vague, in plain words, and reads in
  every face it reaches ("Grant read in “X” until it disconnects, including to future entries" · "claude-code ·
  read · until it disconnects" · the ask's button "Until it disconnects" · "Shared “X” with claude-code — read,
  until it disconnects."); (b) "for this connection" — shorter, names the scope rather than the end, but
  "connection" is the technical word the pane already leans on; (c) "this session" — the friendliest, but
  "session" collides twice (the app's own session; a client's chat session, which is NOT the connection's
  lifetime — a new Claude Code conversation can reuse a connection). Built (a) as the most neutral: it states a
  fact about the grant without introducing a concept. ONE word site (`MCPPaneCopy.untilDisconnects`) feeds
  `durationWord`, the ask's button and the sheet's why — her pick at the copy pass is a one-line change.
- **P-13nc-U4-2 — a glyph's press answers the ask that has WAITED LONGEST on that target**; several asks on one
  target are said together in its hover ("claude-code asks to suggest here · cursor asks to read here — press
  to answer the first."); the next press, the next. Alternative: a small menu listing each ask.
- **P-13nc-U4-3 — the masthead's wing word wears EVERY waiting wing ask's glyph** (not only the current
  wing's — the word is the door to every wing; mockup §4's wing ask is on a NON-current wing, and the brief
  puts the badge on the masthead), its hover naming each wing. The menu's wing rows wear the glyph as a mark
  only (a menu row's press switches the wing, as it always has); the press roads are the word's glyph, ⌘L's
  row glyph and Waiting. Alternative: the masthead shows only the current wing's asks.
- **P-13nc-U4-4 — ⌘L's state machine where her words leave room:** opening highlights the CURRENT wing (the
  press that opens is not a cycle, so typing can follow); releasing ⌘ commits ONLY after a held-⌘ L tap — a
  plain ⌘L press-and-release leaves the field open for typing (the reading that keeps "typing filters"
  possible at all; ⌘-tab's exact semantics would commit the next wing on every quick ⌘L). ↑/↓ step without
  arming the release; a typed change ends a held cycle; committing the current wing closes. Alternative: the
  exact ⌘-tab (first press already on the next wing).
- **P-13nc-U4-5 — the masthead word CYCLES only with two or more wings;** the ▾ beside it is the menu (the list
  + New/Rename/Move Everything/Delete — nothing stopped being reachable). With one wing the whole "· Home ▾"
  is the menu exactly as before (nothing to cycle to — P-2). The cycle and ⌘L's commit SPEAK the existing
  "Now in …" receipt (`WingFollow.nowIn`); the menu's own picker keeps 13i-d's silence (she reads the name she
  picked). Alternative: the menu's pick speaks too.
- **P-13nc-U4-6 — Waiting renders only while an ask waits** (the Connection requests idiom beside it — mockup
  §5 draws "None waiting." under requests, but the shipped pane hides an empty requests list, so Waiting
  follows the shipped idiom); three rows then "all N ›" (mockup §4). Its catalog row (`mcpWaiting`) makes
  "ask", "waiting", "pending" find the pane.
- **P-13nc-U4-7 — the ⌘L switcher is a SHEET** (⌘K's idiom — ⌘L is app-wide and must open wherever she is; a
  masthead popover would need the masthead on screen), with NO per-wing counts (mockup §6 drew "3 books · 41
  notes"; a per-wing note count scales with the corpus — P1); the Snippets line rides both the sheet's foot and
  the menu.
- **P-13nc-U4-8 — the ask's sheet keeps 13n-b's answers** (Once · Until it disconnects · Always · Don't
  allow); under arrival X she opens it herself, and the only way to close it without granting is Don't allow
  (Esc), which drops the ask — the client re-asks on its next refused call (AF-6's own "a dropped ask costs the
  client one re-ask"). A "Not now" that closes and keeps it waiting would be new product behavior — NOT built;
  #211 carries it as a question (options: keep · add "Not now" · make Esc keep it waiting).
- **Implementation decisions (not product):** the queue is a pure value (`MCPAskQueue`) the door holds with its
  projection (`MCPAskBoard`) reassigned only on a change; the board rides each window's environment
  (`\.mcpAskBoard`) so only the glyphs re-render on an arrival; the glyph's calm state is NO view (no width,
  no spacing — the hosts' alignment pins measure what they did); a sheet already up hosts the ask's sheet
  itself (`MCPShareRoad.askSheet` + `answeringAsks`, the T-U3-7 precedent) — the ⌘L switcher's rows; the ⌘L
  monitor consumes only the held-⌘ L and Esc while the switcher is up and only OBSERVES ⌘'s release; the
  switcher moved to `Core/Views/` (two features render it); "Switch Wing… ⌘L" is NOT a greyed menu row (it
  read as a dead door) — the word's hover names ⌘L.

---

## THE U5 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U5 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on
branch `vx-165-13n-c` (NEVER the main checkout). Commits say `Part of VX-165`, NO attribution
trailer, push after every commit. `notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in
the "U5 UNIT RECORD" section below from your FIRST commit, foreground waits only, and at most ONE
read-only Sonnet subagent for the ONE external fact this unit needs (the current Codex CLI's MCP
server configuration syntax — its docs, not guesses).

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM — above all D-2 (why the
guide chapter + the server's instructions), round 5 (snippets OUT at launch, said plainly; Snippets
the one room shared by every wing), and the U1–U4 records (THE BUILD YOU ARE DOCUMENTING — every
sentence you write must be true of it); the sitting record (R-AIR-13); her kickoff text at the top
of this file ("notes / documentation for the user need to be made clear (especially since that's
what a user's AI might need as advice too)"); `notes/handoffs/phase-13n-b-handoff.md` §HOW TO TEST
AND RUN (the door's facts in plain words — a good source, re-verified against code). Code:
`App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift` (the `plan` and the lesson
content; the books chapter's truth-pin precedent `TutorialBooksChapterTests`), the field guide's
restore/re-seed door (grep `BirthFurnitureSeeders`, `LaunchFurniture`, "field guide"),
`Sources/VariorumMCP/MCPSession.swift` (`instructions`), `MCPToolCatalog.swift` (the tool
descriptions), `Features/MCP/MCPPane.swift` + `MCPPaneCopy.swift` (Copy setup command).

**What U5 builds — §3 U5 items 1–4, with these concretions:**
1. **The MCP chapter** in the field guide, sentence case, the guide's own card voice, short
   lessons (her standard: clear for a person who has never heard of MCP; honest, not scary):
   what it is and that it is off until you turn it on · connecting a client (the setup menu) ·
   what a client can do — the four rungs in one line each · where (a note, a book, a wing — and
   that a wing grant covers that wing's gatherings ONLY if U6 has landed when you write; otherwise
   leave that sentence out and note it in your record for U6 to add) · how long (once · while
   connected · always) · what always asks (your daily Journal and anything Private) and that
   snippets aren't reachable at launch · seeing what an AI can reach (the icon, the in-note
   indicator, Settings ▸ MCP) · asks wait (the glyph, Waiting, ⌥⌘,) · every AI act undoes with
   ⌥⌘Z naming the client; receipts, Open ›, ⌥⌘O · wings are separate libraries; Snippets is the
   one shared room. Placement: after the privacy chapter (it closes the guide today) unless a
   better reading order shows — record why. Every sentence TRUE of the build; a truth-pin suite in
   the books chapter's form for each checkable claim; `TutorialWalkTests` green.
2. **`MCPSession.instructions`** — the AI's advice: the same facts, terse, for a model (≤ ~1,500
   characters — state the bound and pin it): tools appear only for what the author shared; a
   refusal says why — ask the author rather than retrying around it; the four rungs; ids are live
   (re-read after a divide/merge); `read_note` speaks the Variorum document format (v2's
   `--- next block ---` marker); never call `show_in_app` unless the author asks; the daily Journal
   and Private notes are shared only one ask at a time; snippets are not reachable. Pin that every
   tool name it mentions exists in the catalog.
3. **R-AIR-13 — the setup menu:** the pane's "Copy setup command" grows a per-client menu: Claude
   Code (today's command, unchanged), Codex (the current syntax from your one Sonnet fact-fetch —
   cite the source in the record), and "Any MCP client (path / JSON)" (the shim's absolute path +
   a standard `mcpServers` JSON stanza). Each copies with its receipt; the selected one's text is
   shown verbatim and selectable; one direct line says the door is a standard MCP stdio server at
   one binary path. Debug keeps the `variorum-dev` name (P-13nb-U1-10). Registry-declared.
4. **The re-seed road:** record which door refreshes an EXISTING store's field guide to carry the
   new chapter (the closeout runs it on her real store behind the A1 rail) and whether the phone
   seeds the guide (the MOBILE PARITY line needs the fact).

**Ladder carry (U1 round 1, F5):** the current `instructions` sentence "Every refusal says why." is no longer true for fenced targets (they answer the one not-shared answer by design) — drop or reword it.

**Ladder carry (U1 round 2, R2-8):** the advice says `search` reaches STANDING grants only (a once grant reads by id, never through search — 13n-b P-13nb-U1-2's spirit).

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the
real store, `/Applications`.

**Acceptance:** truth pins + `TutorialWalkTests` + the tour/guide suites that read the plan
(grep `TutorialSeeder.plan`), `MCPPaneTests`, `CapabilityRegistryTests`, `SettingsShapeTests`, the
headless package (an `instructions` pin in `VariorumMCPTests`), under a HELD stage claim for the
Mac runs. Pre-flight WALK, dev-store Debug, Study AND Terminal: the chapter read on screen end to
end (captures of each lesson), the setup menu's three items and their copied text (verify the JSON
parses; run the Claude Code command only with `-s local` in a scratch folder and remove it after).
Captures in `notes/plans/13n-c-screens/u5/`.

**U4's words bind the guide:** the duration is now said "until it disconnects" (P-13nc-U4-1), asks WAIT (no sheet appears by itself — the pending glyph, Settings ▸ MCP ▸ Waiting, ⌥⌘,), ⌘L switches wings. The pending glyph may change in the Stage B fix pass (O-1) — describe it by role ("a small mark beside the place"), never by its shape.

**Locked-session note (standing):** if the Mac's session is locked (the check in U4's brief), HOLD the walk and the scratch-folder `claude mcp add` run; a gated offscreen render harness of each lesson card and the setup menu stands in, said plainly to be NOT a walk. The JSON stanza's parse is pinned headlessly regardless.

**Forks / close:** as the earlier briefs.

## U5 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~09:10 MDT). Worktree
`~/dev/variorum-vx-165`, branch `vx-165-13n-c`. No revert is in flight unless a line below says so.
*(The 09:52 red-on-old revert of `MCPSession.swift` is DONE and RESTORED — `git checkout --`, `git diff` empty; the
result is in U5-2's row.)*
The session is LOCKED at start (09:10 MDT: `CGSSessionScreenIsLocked 1`) — the walk and the scratch
`claude mcp add -s local` run are HELD; offscreen renders stand in only if it is still locked at U5-6,
and are NOT a walk.

### UNIT CLOSED (2026-10-11 ~10:20 MDT — the U5 implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the WALK is HELD** — the session stayed LOCKED (09:10, 09:44 MDT); the gated offscreen
renders (U5-6) stand in and are NOT a walk: no lesson was opened in the guide's own book view, no menu pressed, nothing
copied by a hand. (2) **The scratch `claude mcp add -s local` run is HELD** with it (the brief's lock rule) — so no
setup text has been run by a real CLI; the Claude Code command is 13n-b's byte-unchanged, the Codex command follows the
cited docs but was NEVER run here, and the JSON stanza is pinned by PARSING it back (Mac suite `MCPSetupMenuTests` —
the stanza's home is the app target, so its parse pin runs under `xcodebuild test`, no GUI, never `swift test`). (3)
**The REAL-client advice leg** (a Claude Code client stating the advice back in its first turn) is owed to the
orchestrator's live round; the headless proof is that a real SDK client reads `instructions` verbatim at `initialize`.
(4) **Not built, recorded:** gatherings under a wing grant are NOT in the chapter or the advice (U6 has not landed —
T-U5-7: one sentence + one clause + their pins are U6's, and the advice has ~30 characters of room under its bound);
the helper's MCP row still says "the filled icon on a note, book or wing" (U4's row — it describes the pending glyph
by SHAPE, which O-1's fix pass may change; whoever changes the glyph changes that row — not touched here, one surface);
13s-a's plan item 6 still says to WRITE "the field guide's MCP chapter" — it now exists, so 13s-a re-voices it. (5) No
`notes/QUESTIONS.md` edit (merge-time, #211) and no canon edit (the closeout checklist gains the line). Zero `Sync/`,
schema, custody, editor seam, `/Applications`, real store (`git diff --name-only c9572867..HEAD` checked: app MCP +
tutorial + settings + registry files, `Sources/VariorumMCP/MCPSession.swift`, tests, this record); zero trailers; no
Variorum instance ever ran.

**Commits (branch `vx-165-13n-c`):** `58b81ec8` record opens · `75945f33` the setup menu + the advice (+ pins) ·
`a6e2f484` the chapter + its truth suite + the seat ritual · `e4958142` the harness + the Mac run · `49c7f589` what the
renders caught · `5946d2cd`/`562b8136` the red-on-old revert, named then restored · this commit (finals, U5-7, banner).

**Finals:** headless core **2,619 / 299** · `VariorumMCPTests` **76 / 10** · workbook **40 / 6** — all green (the one
unreproduced cap-test red and the VX-132 stall said in U5-4) · Mac **51 suites / 399 tests `** TEST EXECUTE SUCCEEDED
**`, 0 skipped** + the post-fix **72 / 8** green · the capture harness green (20 images).

**PROVISIONALs (for #211 at the merge):** **P-13nc-U5-1** the chapter's SEAT — last, after the privacy chapter, as the
opt-in appendix (alternative: between the books chapter and privacy — one plan line and two pins) · **P-13nc-U5-2** the
chapter's NAME "AI & the MCP door" and its six lesson titles (13s-a re-voices) · **P-13nc-U5-3** the setup menu as a
SEGMENTED row, all three in sight (alternatives: a pop-up, or a "Copy setup command ▾" menu button) · **P-13nc-U5-4**
"Any MCP client" and the button still reading "Copy setup command" when it copies JSON (her R-13nb-5 verb kept, one act;
alternatives: "Copy setup" / a per-choice verb) · **P-13nc-U5-5** the advice's 1,500-character bound and its register
(terse, imperative, "the author"/"she"). **Dependent, not new:** the guide's "An entry ⌘J made keeps asking even if you
later file it in another book." is option (a) of P-13nc-4 (R2-2, hers) — her pick of (b) or (c) changes that sentence
and its pin. **FABLE-OWED row written at the moment:** F-17 (§6).

**Where a cold reviewer should look first:** (1) **the TRUTH of every sentence** — `TutorialSeeder.swift`'s six MCP
lessons against the build, above all lesson 4 ("what always asks") and lesson 6 (the ask's answers "whichever fit", the
show etiquette) and `MCPSession.instructions` (the once rule is `MCPGrantRule.spends`' F4 amendment; "search covers
standing grants only"; "Anything you can't reach answers exactly as if it did not exist" rests on U1's T-2/F-7); (2)
`MCPSetupClient` + `MCPPaneCopy.setupJSON`/`jsonQuoted` (hand-written JSON — is every path legal, and is the shape what
Claude Desktop/Cursor-class clients read?) and `codexCommand` (the cited syntax; never run here); (3) `MCPSetupMenu` —
the receipt cleared on a new choice, the one declared act, `rowIDsRendered` untouched; (4)
`TutorialMCPChapterTests` — do the truth halves exercise the rule's own reads (`mcpNoteSharing`/`mcpNoteFacts`), or
could a pin pass while a sentence lies?; (5) the seat edits in `TutorialWalkTests`/`TutorialBooksChapterTests` — is
"safety after the workflow" still what her R-13s-30 words say?

**Self-assessment:** the docs are written against the code, not the plan: every door the chapter names is tied to its
own constant, and every claim that can be executed is executed through the rule's own reads — which is why reading the
renders found only prose problems (a repeated phrase, two overclaims), not false facts. The advice is bounded, pinned
to the catalog and the format, proven to arrive, and red on the old text by revert. The setup menu is small and leaves
Claude Code's road byte-unchanged. Least certain: the Codex command (cited, never run on this Mac) and whether a reader
who has never heard of MCP finds lesson 1 enough of a "what is this" — both the held walk's and her copy pass's to judge.

### Pieces

| # | Piece | Status |
|---|---|---|
| U5-0 | Preflight read whole (this plan top to bottom incl. D-2, round 5/6, the U1–U4 records; the sitting record R-AIR-13 + rounds 5/6; her kickoff text; the 13n-b handoff §HOW TO TEST AND RUN; `SessionResiliencyProtocol`) + the code the brief names + the traces below + the ONE external fact (Codex CLI, below) | DONE (this commit) |
| U5-1 | R-AIR-13 — the setup menu: `MCPSetupClient` (Claude Code · Codex · Any MCP client) in `MCPPaneCopy`, each with its text, sentence and receipt; the pane's chooser + the selected text shown verbatim and selectable + the one stdio line; the ONE declared copy act copies the chosen setup; catalog keywords; pins | DONE (code + pins compile — `build-for-testing` clean; the Mac run PENDING U5-5) — **`MCPSetupClient`** (`MCPPaneCopy.swift`, beside the copy enum): `.claudeCode` = 13n-b's `claude mcp add -s user <name> -- "<shim>"` BYTE-UNCHANGED (its sentence and receipt too) · `.codex` = `codex mcp add <name> -- "<shim>"` (the external fact above; the same name rule and shell quoting; its sentence names `~/.codex/config.toml`) · `.anyClient` = the `mcpServers` JSON stanza (hand-written so it reads as the docs print it — two-space indent, the slash never escaped — through `jsonQuoted`, RFC 8259's escapes), each with its own receipt; Debug keeps `variorum-dev` in all three (P-13nb-U1-10). **The pane** (`MCPSetupMenu`, its own view in `MCPPane.swift`): the one direct line `MCPPaneCopy.stdioLine` ("Variorum's door is a standard MCP server that speaks over stdio: one program, at this path inside the app.") with the shim's path under it, selectable; a SEGMENTED row of the three (all in sight — a pop-up would hide two; PROVISIONAL **P-13nc-U5-3**); the chosen sentence; the ONE declared act `.mcpCopySetupCommand` ("Copy setup command", her R-13nb-5 verb, unchanged) copying the CHOSEN text (`MCPDoor.copySetupCommand(for:to:)` — the default stays Claude Code, so 13n-b's callers and pins are untouched); the receipt under it; the text verbatim and selectable. Choosing another client clears a copy receipt (`clearConnectNote` — a "…Claude Code session" caption under Codex's text would lie), never a refusal at the head. **Registry:** no new act — the menu chooses what the one act copies (view state, not an act; the declaration's comment says so). **Catalog:** the `mcpServer` row's blurb names Codex; keywords + codex · setup · json · stdio (no row added, so `rowIDsRendered` is untouched). Pins `MCPSetupMenuTests` (new, Mac): the order; Claude Code byte-unchanged; Codex's command + quoting + Debug name; the stanza PARSED back over four awkward paths × both builds (quotes, backslash, `$`, backtick, non-ASCII, tab/newline) to the exact path, `args` empty; the JSON quoter; the door copying each choice with its own receipt; the receipt cleared by a new choice (a head refusal kept); the stdio line; no "AI" and no shouted word (R-AIR-8); the search finding the pane by codex · json · setup · stdio |
| U5-2 | The AI's advice — `MCPSession.instructions` rewritten (bound ≤ 1,500 characters, pinned; every tool it names exists in the catalog; the format's markers read from `VariorumDocument`; arrives at `initialize` over the wire) + F5 (the false "Every refusal says why." gone) + R2-8 (search serves standing grants only) + the snippets-out server truth pin | DONE (this commit) — the advice (~1,470 characters; `instructionsBound` = 1,500, pinned): what the door is and that it is open only while Variorum runs; a new client is a connection request until approved; tools appear only for what she shared (re-announced on change); the four rungs in order, each including those before; a note · a book · a wing, for once · until you disconnect · always, and the open book; a once grant is ONE act (a read grant's first content read, a higher grant's first write — `MCPGrantRule.spends`, the F4 amendment, read before writing the sentence); **R2-8** "search covers standing grants only; read a once grant's note by id."; ids are live (re-read after a divide or merge); `read_note` speaks the document format and `{v:2}`'s `--- next block ---` marker (interpolated from `VariorumDocument.versionToken`/`.blockMarker` — never retyped); the daily Journal's entries and anything Private one ask at a time, snippets not reachable at all, and the unreachable answering as if it did not exist; refused ⇒ don't retry around it, tell the author (Variorum may already have asked her); never `show_in_app` unless she asks; every change one undo for her, named after the client. **F5:** "Every refusal says why." GONE. Pins `MCPAdviceServerTests` (new, headless) **7/7 green**: the bound; every tool name it says (`read_note`, `show_in_app`, `search`) declared; the format's own markers; the same facts the guide teaches (the rungs IN ORDER, places, durations, the open book, the fence, snippets, the refusal posture, the etiquette, the undo); the two ladder carries; **its arrival** — a real SDK `Client` over the socket reads `instructions` verbatim at `initialize`, before approval, with zero tools listed; **SNIPPETS OUT (T-U5-4's pin)** — under a Home-wing EDIT grant AND the open book, a snippet's word searches byte-identically to a word nowhere, a scraps group's id answers `read_note`/`export_note` byte-identically to an id naming nothing, `list_notes` never lists it, and `add_take` on a snippet's block refuses exactly as a block that doesn't exist (nothing written); a plain note in the same wing is the control, reached whole. **RED-ON-OLD, by revert** (named in the record before it started; the pre-U5 `MCPSession.swift` from `58b81ec8` with ONLY the `instructionsBound` constant added so the suite compiles; restored by `git checkout --`, `git diff` empty): **5 of 7 RED, 20 issues** — the bound's floor, the tool names, the format markers, the twelve facts, and BOTH ladder carries (F5's "Every refusal says why" present; R2-8's sentence absent); the two GREEN ON BOTH SIDES BY DESIGN are the arrival pin (it compares the wire to whatever the advice is) and the snippets pin (a guard of a truth that was already true — T-U5-4: no fix, so no red owed). **Room left for U6:** ~30 characters — U6's gatherings clause will need a trim or the orchestrator's word to raise the bound |
| U5-3 | The field guide's MCP chapter (`TutorialSeeder.plan` + the seed) + the placement pins updated as the ritual + the truth suite `TutorialMCPChapterTests` (prose · doors tied to their own constants · the truth executed) | DONE (code + pins compile — `build-for-testing` clean; the Mac run PENDING U5-5) — **"AI & the MCP door"** (`TutorialSeeder.mcpChapter`, PROVISIONAL **P-13nc-U5-2**), six short lessons (`mcpLessons`), functional words, sentence case, written PLAINLY (the H pattern): **what the door is** (MCP in one line, shut until opened, the Mac only — the phone has no door; Settings ▸ MCP / ⌥⌘, / Enable the MCP server; only while Variorum is open; grants never sync; a client acts through her own acts and ⌥⌘Z) · **connecting a client** (the setup menu's three choices and Copy setup command; the one path, a standard MCP server; the connection request — Approve… / Deny / Change… / Revoke; L1's honest limit) · **how much, where, how long** (Read · Suggest · Write new · Edit, cumulative, the edit's commits before and after; a note · a book with notes added later · a wing; once (one act) · until it disconnects (offered while connected) · always; the open book, off to begin with) · **what always asks** (the daily Journal's entries and anything Private — no book grant, wing grant or open book; one note at a time, never always; the note ▾ Private row and the book's mark in Book Settings; date-stamped books share like any book; a ⌘J entry keeps asking wherever filed (D-1 — P-13nc-4 is hers; this sentence follows option (a) and changes with her pick); snippets unreachable; wings separate, ⌘L, Snippets the one shared room closed to clients; the unreachable looks like nothing) · **sharing from where you are** (Share with AI… on note and book rows; ⌘-click → Share 3 notes with AI…; Book Settings' Share…; ⌥⌘A (Edit ▸ Share This Note with AI), D1's rule, its receipt's Change… / Revoke ›, the sheet with no history; one row and one Revoke per act) · **seeing, answering, undoing** (the Bookcase icon, hover and click with the why; the in-note icon or lock at the context bar's right end; Activity; asks WAIT — "a small mark" by role, never shape (O-1), Waiting, ⌥⌘,, the four answers, Esc lets it go; receipts with Open › unless Confirmations after an act is off; ⌥⌘O; ⌥⌘Z and "Undo claude-code's take"; `show_in_app`'s etiquette). **No gatherings sentence** (T-U5-7 — U6's). **THE SEAT — LAST, after the privacy chapter (PROVISIONAL P-13nc-U5-1):** her R-13s-30 words ("safety after the workflow and the workflow together") hold whole — the workflow runs unbroken and safety follows it; the door is opt-in, so it reads as the guide's appendix (a reader who never opens it stops at the serious chapter), and privacy's own premise (an open library is readable) is the door's starting point. Alternative: between books and privacy (one line). **The ritual (justified edits, annotated in place):** `TutorialPrivacyChapterTests.theChapterIsTwoLessonsInTheRightPlace` (`count - 1` → `count - 2` + the MCP chapter last; `books + 1` UNTOUCHED) and `TutorialBooksLessonTests.theChapterIsEightLessonsLastInTheGuide` (`dropLast()` → `dropLast(2)`; privacy second-to-last). **The truth suite `TutorialMCPChapterTests`** (new, Mac, 7 tests): the chapter's shape + three guards over all six lessons (no "gathering" before U6; no "filled" — the mark by role; no "savepoint"; no shouted word); each lesson's prose + its doors by their own constants (the settings pane and switch titles, the registry's ⌥⌘, / ⌥⌘A / ⌥⌘O / ⌘L labels and verbs, `MCPSetupClient`, the client-row verbs, the rung names in order, the duration words, `PrivateMarkCopy.rowWords`, `CollectingCopy.journalTraitValue`, `MCPShareCopy`'s doors, Waiting/Activity, the ask's answers, `MCPReceiptCopy.openDoor`, `ReceiptStyleCopy.title`, `EditorCommands.undoMenuTitle` over `MCPWriteAct.take.undoLabel`) + THE TRUTH executed through `Queries.mcpNoteSharing` / `mcpNoteFacts` / `mcpBookReach(es)` / the ops: both switches off on a fresh store; the grants family outside the sync registry; a connection request reaches nothing even under the open book, approval reaches; edit includes read; a book grant reaches a note added later; a wing grant reaches its notes and never another wing's; a once read grant spent by a content read only; the open book reaches with no grant; under a Home-wing EDIT grant + the open book a daily-Journal entry, a note filed in the daily Journal, a Private note, a Private book's note and a ⌘J entry filed in a trait book reach nobody while a trait book's note does; always refused on a fenced note, once lands; a scraps group has no facts and refuses a grant; ⌥⌘A's decision (connected → until it disconnects, else once, no history → the sheet); a bulk share is one row and one Revoke; the icon's why "through the Home wing grant"; a client's take is ONE undo entry titled "Undo claude-code's take" |
| U5-4 | Headless finals: `swift build` + core + `VariorumMCPTests` + workbook | DONE (on `562b8136`'s sources) — `swift build --build-tests` clean; the whole package `swift test`: **core 2,619 / 299 green** (unchanged — U5 touched no core line) · **`VariorumMCPTests` 76 / 10 green** (69/9 + `MCPAdviceServerTests` 7/1) · **workbook 40 / 6 green**; the skips are the standing gated ones only (13o's two measurement suites, the drill-fixture mint, the probes, the Supabase integration). **Said plainly — one red and one hang, neither reproduced as this unit's:** (1) the FIRST whole-package run had ONE red, `MCPServerTests.connectionsPastTheCapAreRefusedWithOneHonestErrorAndSlotsFree` — "Unable to parse empty data" (a raw `initialize` read hit EOF before a single byte: the server closed a connection without answering); it was green in 6 isolated runs, 2 whole-`VariorumMCPTests` runs and the second whole-package run. The mechanism is not U5's on the evidence: `MCPShim.readFirstLine` reads byte by byte to the newline under a 1 MB limit (the longer advice makes each answer ~2 KB, nowhere near it), and the over-cap refusal and the freed-slot paths carry no advice at all. **For the orchestrator to ticket or fold into the socket-harness family** (VX-132/VX-134), with this record's capture. (2) VX-132 itself: one `--filter VariorumMCPTests` rerun STALLED (09:58 → killed ~10:08, per the brief), its in-flight tests `aJournalTraitBookIsListedReadAndSearched…`, `filingAFencedMemberRaisesTheAsk…`, `theOperationsRefusalsSpeakToTheClient…`; the next run green in 2.6 s |
| U5-5 | Mac suites under a held stage claim (the tutorial/tour suites that read the plan, `MCPPaneTests`, `CapabilityRegistryTests`, `SettingsShapeTests` + every suite over a changed file) | DONE (first run) — stage `vx165-u5` (claimed 09:38 MDT; no Variorum instance at any point — `pgrep` clean), `test-without-building` on `DerivedData/vx165-u5`, suite-level `-only-testing` over **51 suites: 399 tests, `** TEST EXECUTE SUCCEEDED **`, 0 skipped** (the gated capture harnesses not in the set): every suite that names `TutorialSeeder` (`TutorialBookShapeTests`, the twelve acts/contract suites of `TutorialWalkTests.swift` incl. `TutorialPrivacyChapterTests`, `TutorialBooksLessonTests` + rituals, `TutorialCurrencyTests`, `TutorialBuildFlavorTests`, `TutorialFurnitureFoldTests`, `NewModesTests`, `LaunchFurnitureTests`, the seven `Tour*` suites, `SampleLibraryWelcomeTests`, both encryption-book suites, `CalmAsksTests`, `ShellConfirmTests`, the three snippets suites, `TakeCardDoorTests`), the two new suites (`MCPSetupMenuTests` 10, `TutorialMCPChapterTests` 7), and every suite over a changed type (`MCPPaneTests`, `MCPAskAndReceiptTests`, `MCPAsksWaitTests`, `MCPGrantSheetTests`, `MCPEditFacesTests`, `MCPShareFacesTests`, `MCPNavigationTests`, `CapabilityRegistryTests`, `SettingsShapeTests`, `HelperCurrencyTests`, `DiagnosticsPaneTests`, `OwnershipBadgeTests`, `DeadVocabularyTests`, `VocabularySweepTests`, `CommitVocabularyTests`) — 249 s |
| U5-6 | The walk (dev-store Debug, Study + Terminal) → `notes/plans/13n-c-screens/u5/` — or, if still locked, a gated offscreen render of each lesson card and the setup menu (NOT a walk) | **WALK HELD — the session is LOCKED** (09:10 and 09:44 MDT: `CGSSessionScreenIsLocked 1`); the scratch `claude mcp add -s local` run HELD with it. Unlocking is hers. **What stands in its place — NOT a walk, said plainly:** the gated harness `TutorialMCPChapterCaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=13nc-u5`, stage `vx165-u5`) rendered offscreen, light, both voices, into `notes/plans/13n-c-screens/u5/` (gitignored — `git check-ignore` verified; decoded by a scratchpad script): `u5-lesson-{1…6}-{study,terminal}.png` — each lesson drawn by the READ TIER's own face (`ReadPostView`, what the book's Outline shows at rest) over a freshly seeded guide, under a harness title label; `u5-setup-{claudeCode,codex,anyClient}-{…}.png` — the setup menu in the pane's grouped section with each client chosen; `u5-setup-copied-{…}.png` — after a Codex copy, its receipt under the button. Nothing pressed, scrolled, copied by a hand or opened. **What reading the renders caught and was fixed (re-shot green):** lesson 1 said "way in" three times in two sentences ("Variorum calls its way in the door"); lesson 3's "a whole wing and everything in it" and the open book's "read everything" read as overclaims before the next lesson's exceptions — both now say "except what always asks" (pinned, with "the next lesson" tied to the plan's order). **Observed, left for her copy pass:** on "Any MCP client" the button still reads "Copy setup command" though it copies JSON (her R-13nb-5 verb — kept, one act); the path shows twice on that choice (the line above and inside the JSON). **OWED to the next unlocked session (the orchestrator's walk + live round):** the chapter read on the dev store in both voices (Read and Write, the guide's own book view); the setup menu's three choices pressed and each copy pasted — the Claude Code command run with `-s local` in a scratch folder and removed after, the Codex command NOT run (no Codex on this Mac is assumed — say so if it is), the JSON pasted into a parser; a REAL Claude Code client connecting and stating the advice back in its first turn (the instructions arrived); dark appearance |
| U5-7 | The re-seed road + the phone-seeding facts (for the closeout and the MOBILE PARITY line) | DONE — **THE RE-SEED ROAD (the closeout's):** an EXISTING store's guide gains the chapter only through **Help ▸ Restore Tutorial…** (`ShellActions.restoreTutorial`: `TutorialSeeder.discover` → the spoken confirm `replaceQuestion`/`replaceDetail` → `TutorialSeeder.restore` on the QUIET facade (nothing on ⌥⌘Z) → `arrangeWelcome`). Launch NEVER re-seeds an existing store (`seedAtBirth` runs only on a fresh birth). **What it costs on her real store, to say before it runs:** every note tagged exactly `tutorial`, every pool named "tutorial scraps" and every book named "the field guide" are TOMBSTONED into the Trash (recoverable) and a pristine guide is minted; anything she did inside the old lessons (a starred lesson, a practice note left in a lesson, her own note tagged exactly `tutorial`) goes with the old copies, and the Welcome arrangement re-runs (guide onto Welcome; unshelved seeded books shelved; the classics tag; Sherlock owned if no member lives elsewhere — `replaceDetail` says each). The door is HERS to press in the refreshed app (her GUI, the confirm is spoken to her); a headless closeout road would run the same three calls in that order behind the A1 copy at a zero-instance window (the adding-content-to-her-real-store rail) — the door, not a new road. **THE PHONE (the MOBILE PARITY facts):** the phone NEVER seeds the field guide — `MobileTutorialSeeder` seeds its own "the pocket guide" (tag `pocket guide`, deliberately disjoint), from a DEBUG-only Settings door (PROVISIONAL PB1-1), and U5 adds nothing to it; the phone has no MCP door. BUT the field guide is ordinary SYNCED rows (`SeededFurnitureDedupe` folds a guide arriving from another device), so once the Mac's guide is re-seeded, her phone receives the MCP chapter by sync like any book; its first lesson says "It lives on the Mac; the phone has no door", so it stays true read there. **The parity line, proposed:** "13n-c U5 — the Mac's field guide gains the MCP chapter (synced content: the phone shows it inside the Mac's guide; the pocket guide unchanged; the door is Mac-only)" |
| U5-8 | UNIT CLOSED banner | DONE (this commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-U5-1 — the guide has no MCP chapter, and its last seat is ruled.** `TutorialSeeder.plan` closes on
  "keeping it private" (two lessons, `ProtectionCopy` verbatim). Two pins hold that seat:
  `TutorialPrivacyChapterTests.theChapterIsTwoLessonsInTheRightPlace` (`index == plan.count - 1` and
  `index == books + 1`) and `TutorialBooksLessonTests.theChapterIsEightLessonsLastInTheGuide`
  (`plan.dropLast().last` is the books chapter; `plan.last` is privacy). Her ruling behind the seat
  (R-13s-30, `phase-13s-voice-onboarding.md:171`, verbatim): *"it makes more sense to have the safety
  after the workflow and the workflow together"*; the 13s-b U3 disposition 4 then wrote "Privacy chapter
  lands LAST" when nothing came after it. Any seat for a new chapter moves one of these pins (a ritual
  edit either way).
- **T-U5-2 — the advice is four sentences, one of them false.** `MCPSession.instructions`
  (`Sources/VariorumMCP/MCPSession.swift:28`) says nothing of the rungs, live ids, the format's v2
  marker, `show_in_app`'s etiquette, the fence or snippets, and ends "Every refusal says why." — false
  since U1's T-2 (a fenced note and a fenced book answer the one not-shared answer; the U1 ladder's F5).
  No pin bounds its length or ties the tool names it says to the catalog.
- **T-U5-3 — the setup command speaks to one client.** `MCPPaneCopy.setupCommand` (`:251`) builds
  `claude mcp add -s user <name> -- "<shim>"`; the pane's "Connect a client" says Claude Code only; the
  one declared act `.mcpCopySetupCommand` copies it; nothing tells a Codex or other MCP-client user what
  to do, and nothing says the door is a standard stdio server at one path (R-AIR-13). The `mcpServer`
  catalog row's keywords find "claude" but not "codex", "json" or "setup".
- **T-U5-4 — snippets at the door, the fact from code (round 5's, re-verified):**
  `Queries.mcpNoteFacts` reads only `c.kind = 'post'` (`MCPGrantQueries.swift:~416`), so a scraps group
  has no facts and every tool answers it as an unshared note; `MCPReadTools.passes` drops a passage whose
  home has no facts. True — but NO pin says it on the wire (the carriage suite pins only lineage stubs
  toward a scrap). The docs will say it plainly, so U5 pins it (a server truth pin).
- **T-U5-5 — the re-seed road (for the closeout).** An EXISTING store's guide is refreshed by exactly ONE
  product door: Help ▸ Restore Tutorial… (`ShellActions.restoreTutorial` → `TutorialSeeder.discover` →
  the spoken confirm (`replaceQuestion`/`replaceDetail`) → `TutorialSeeder.restore` (the QUIET facade —
  nothing on ⌥⌘Z) → `arrangeWelcome`). Launch never re-seeds an existing store (`seedAtBirth` runs only on
  a fresh birth's arrange-now road). Its cost on a lived-in store: every note tagged exactly `tutorial`,
  every pool named "tutorial scraps" and every book named "the field guide" are TOMBSTONED (the Trash —
  recoverable) and a pristine guide is seeded; her own marks inside the old lessons (a starred lesson, a
  practice book's membership) go with the old copies.
- **T-U5-6 — the phone.** The phone NEVER seeds the field guide: its own `MobileTutorialSeeder` ("the
  pocket guide", tag `pocket guide` — deliberately disjoint) has a DEBUG-only door (PROVISIONAL PB1-1) and
  gets no MCP chapter; the phone has no MCP door. BUT the field guide is ordinary synced rows (the furniture
  fold `SeededFurnitureDedupe` exists precisely because a guide arrives from another device), so a
  re-seeded guide reaches her phone by sync, MCP chapter included — the chapter says the door lives on the
  Mac so it stays true when read on the phone.
- **T-U5-7 — the U6 gate.** U6 (gatherings under a wing grant, R-AIR-12) has NOT landed at U5 (U6 is
  NOT-STARTED in the LIVE STATUS table), so the chapter and the advice say nothing of gatherings under a
  wing grant — **for U6 to add:** one sentence in the "how much, where, how long" lesson and one clause
  in the advice, with their pins.

### The external fact (the ONE Sonnet lookup — R-AIR-13's Codex syntax; read-only, sources cited)

- **Codex CLI:** `codex mcp add <server-name> [--env VAR=VALUE …] -- <stdio server-command>` — the docs'
  example `codex mcp add context7 -- npx -y @upstash/context7-mcp`
  (https://learn.chatgpt.com/docs/extend/mcp?surface=cli — the redirect target of
  developers.openai.com/codex/mcp). It writes the USER-GLOBAL `~/.codex/config.toml` ("Added global MCP
  server '{name}'.", `codex-rs/cli/src/mcp_cmd.rs` in github.com/openai/codex); the file form is a
  `[mcp_servers.<name>]` table with `command` required, `args`/`env` optional
  (https://learn.chatgpt.com/docs/config-file/config-reference). Server names allow letters, digits and
  `- _ : @ / .` (`validate_server_name`, the same source) — so `variorum-dev` is legal.
- **The generic stanza:** `{"mcpServers": {"<name>": {"command": "<absolute path>", "args": [...]}}}`
  (https://modelcontextprotocol.io/docs/develop/connect-local-servers — "paths … absolute and not
  relative"; Cursor's `~/.cursor/mcp.json` the same shape, https://cursor.com/docs/context/mcp).

---

## THE STAGE B FIX BRIEF (self-contained; the spawn names this section)

You are the Stage B fix implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on branch
`vx-165-13n-c` (never the main checkout). Commits say `Part of VX-165`, carry NO attribution trailer, and are pushed
after every commit. `notes/SessionResiliencyProtocol.md` binds you: keep LIVE STATUS in the "STAGE B FIX RECORD"
section below from your FIRST commit; foreground waits only; no subagents.

**Read first, whole, never delegated:** this plan file top to bottom (the U2–U5 records above all, and the orchestrator
findings O-1…O-3 near the top), then `notes/plans/13nc-stageB-ladder-round1.md` — the findings AND the orchestrator's
dispositions. The dispositions are your work list. Every row marked ACCEPT is yours, with the fix shape the disposition
names; S-1 is a walk item; S-2 is optional per its row; B12 and B14 are already done by the orchestrator.

**The rules:**
- **Bug-class fixes need a red-on-old pin.** Revert the fix, show the pin red, restore it, and record the evidence per
  row. B4 is architectural (a parity pin, green on both sides by design); say so.
- **Never re-derive the fence.** B2 and B4 consume U1's derivation (`mcpNoteFacts` / `mcpBookFacts` /
  `mcpFencedBookIDs`).
- **O-1:** propose 2–3 pending-ask glyphs that differ from the shared icon by SILHOUETTE. Capture them side by side at
  row size in both voices, build your lead PROVISIONAL, and update every place that names the glyph (O-3's helper
  row, U4's record terms).
- **O-2 / B13:** sweep every client-facing string, i.e. everything the server can send. Pin that none carries a
  gendered pronoun. The app's own UI speaks to the user as "you", so leave it alone.
- **Copy:** sentence case; no word capitalized for emphasis.

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the real store,
`/Applications`.

**Acceptance:** the whole headless package, plus the Mac suites over every changed type, run under a HELD `Tools/stage`
claim with suite-level `-only-testing`, reading the `skipped:` lines. Re-shoot U4's and U5's capture harnesses where a
face changed. The session has been locked all night: check it with the command in U4's brief. While it is locked, the
walk stays HELD, and captures stand in that are said plainly not to be a walk. VX-132: if a VariorumMCPTests run
hangs, kill it and rerun.

**Close:** a FIX PASS CLOSED banner — per row: fixed with commit and pin evidence, or why not; PROVISIONALs;
FABLE-OWED rows written at the moment; where round 2 should look first.

## STAGE B FIX RECORD (LIVE STATUS — the fix implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~10:35 MDT). Worktree `~/dev/variorum-vx-165`,
branch `vx-165-13n-c`. No revert is in flight unless a line below says so. *(The B13 red-on-old revert is DONE and RESTORED — `git checkout -- Sources/VariorumMCP`, `git diff Sources` empty; the result is in B13's row.)* *(The Mac red-on-old revert is DONE and RESTORED — eight app files `git checkout --`, each `cmp`-identical to its pre-revert copy, `git status` clean; the result is in SB-R below. The core B3 revert is DONE and RESTORED too — `git checkout --`, `git diff Sources` empty.)* The session is LOCKED at start (10:37 MDT:
`CGSSessionScreenIsLocked 1`) — the walk stays HELD; offscreen captures stand in and are NOT a walk.

### FIX PASS CLOSED (2026-10-11 ~11:50 MDT — the Stage B fix implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **the WALK is HELD** — the session stayed LOCKED all pass (10:37 MDT on); the
re-shot harnesses (68 images in `13n-c-screens/stageB/`) are NOT a walk: no press, hover, menu, popover, sheet
presentation, held key or scroll was exercised. S-1 (a fast ⌘L-L-release before the sheet is key) and S-2 (⌥⌘,'s
scroll to Waiting) stay walk items; S-2 was deliberately left as built (its row says why). (2) **No `notes/QUESTIONS.md`
edit** (merge-time, #211) and no canon edit. (3) **Left, said:** the pane's empty Activity line `MCPPaneCopy.noActivity`
("every call a client makes is listed here") — the same claim B10 fixed in the guide, on the pane while EMPTY; not in
B10's row, a watch item for round 2 / her copy pass. `Queries.mcpSharedRows` kept (three core suites read it as the flat
oracle — B11's row). (4) **The advice now has ~3 characters of room** under its 1,500 bound (B13's neutral words cost ~27):
U6's gatherings clause needs a trim or the orchestrator's word to raise the bound. Zero `Sync/`, persistence,
migration, editor-seam, custody, `lockstepVersion`, real-store or `/Applications` lines (`git diff --name-only
065526ce..HEAD` checked); zero trailers; no Variorum instance ever ran.

**Per row:** B1 FIXED `e3e50161` · B2 FIXED `0a5fd108` · B3 FIXED `0a5fd108` · B4 FIXED (architectural — a parity pin,
green on both sides by design) `0a5fd108` · B5 FIXED `0a5fd108` · B6 FIXED `0a5fd108` + `8fc848a0` · B7 FIXED · B8 FIXED ·
B9 FIXED `0a5fd108` · B10 FIXED `e3e50161` · B11 DONE `0a5fd108` · B13 + O-2 FIXED `d9ace41d` · O-1 + O-3 DONE PROVISIONAL
`0a5fd108` · B12/B14 the orchestrator's (done before this pass) · S-1 walk · S-2 walk (left as built). **Red-on-old
evidence:** B13 headless — 5 tests red / 40 issues on `d9ace41d~1`'s server files; the Mac combined revert (SB-R) — exactly
12 pins red / 34 issues, nothing else; core B3 — 4 issues; every revert restored and verified (`git diff` empty, `cmp`).

**Finals:** headless core 2,620 / 299 · `VariorumMCPTests` 80 / 11 · workbook 40 / 6 — green · Mac 1,539 tests / 239
suites, the only reds VX-115's and VX-167's baseline pins (the first run's tour focus red did not reproduce; green alone).

**PROVISIONALs (for #211 at the merge — also added to the running list):** **P-13nc-SB-1** lesson 1's privacy words ·
**P-13nc-SB-2** ⌘L grey with one wing + its note · **P-13nc-SB-3** the pending mark `questionmark.bubble` (A; B
`hand.raised`, C the shared icon + a dot — captured) · **P-13nc-SB-4** the now-fenced book ask's lead (and the B7/B9
words inside her copy pass). **FABLE-OWED rows written at the moment:** F-19 (B2 — the ask's answer road, extends F-15),
F-20 (B1 — lesson 1's privacy sentence), F-21 (B4 — the Book Settings gate).

**Where round 2 should look first:** (1) `MCPDoor.refreshAsk` / `askStanding` and `MCPAskSheet`'s `current` + `checked`
— the read after an `await` (an ask answered or forgotten meanwhile), the forget-on-gone path clearing `answering`, and
whether every host (window, pane, ⌘L's nested road) closes when the read forgets the ask; `MCPAskQueue.enqueue`'s refresh
returning `true` for a re-raise (it now re-assigns the board); (2) `durations(for:)`'s fenced-book `[]` and the lead/reach
pair — is any book ask still able to draw a granting answer the op refuses? (3) `MCPWireNeutralityTests`' source net
(`stringLiterals`) — a literal shape it could miss (a `"""` opening and closing on one line; a string split across
concatenations is still caught per literal); (4) `WingState.wingCount`'s writer — only `WingsModel.adopt`, so a library
whose wings model never loaded reads 1 (⌘L grey until a window's model reads the store — every full window tracks it);
(5) `mcpSharedActMembers`' liveness filter vs `mcpSharedActs`'; (6) `SearchPickerPanel.loaded` never resetting across
queries (a later empty answer says "Nothing matches." — intended).

**Self-assessment:** every accepted row is fixed at its named site with a pin that was watched red on the pre-fix behaviour
(or, for B4 and the taste rows, said plainly to be a guard), and the two Mac runs plus the headless package bracket the
pass. The judgment calls are words (SB-1/-2/-4, B7/B9) and the glyph (SB-3) — all hers at the copy pass — and the B2 shape
(her open re-reads; the sheet draws no granting answer until it has). Least certain: how the ask sheet's first frame FEELS
under a real pointer (the answers appear a beat after the sheet) and whether `questionmark.bubble` reads as "a client asks"
to her rather than "help" — both the held walk's and her copy pass's to judge.

| # | Row | Status |
|---|---|---|
| SB-0 | Preflight read whole (this plan top to bottom, the R1 record + dispositions) + the traces below | DONE (this commit) |
| B1 | Lesson 1's "what you share stays on this Mac" → grants stay local + the honest provider sentence; check the advice + pane | **FIXED** (`e3e50161`; RED-ON-OLD in SB-R, lesson 1's pin 4 issues with B10's; Mac final green) — lesson 1 now says "Your grants stay on this Mac — they never sync to your other devices. What a client reads goes wherever that client sends its work: for most clients, the company that runs its model." (PROVISIONAL **P-13nc-SB-1**, her copy pass). Pin `TutorialMCPChapterTests.lessonOne…`: the grants sentence + the provider sentence present, "share stays"/"shared stays" absent. **Checked SAFE:** `MCPSession.instructions` ("this server is the door to its library, on the author's Mac" — the SERVER's place, true) and the pane (`enableBlurb` "Runs a local MCP server" — true; no sentence says shared content stays local) |
| B2 | A waiting ask answered on CURRENT facts (durations, reach line); a re-raise refreshes the payload, keeps the stamp; a gone target forgotten; a now-fenced book said | **FIXED** (`0a5fd108`; RED-ON-OLD in SB-R — all four pins, 14 issues; Mac final green; captured `sb-ask-fenced-book-*`, and `u4-ask-sheet-*` shows the answers drawn after her open's read) — `MCPAskQueue.enqueue` refreshes a re-raise's payload (stamp + place kept; `refresh(_:)`); `MCPDoor.refreshAsk(_:)` (her open) reads the target again through `askStanding` (`mcpNoteFacts`/`mcpBookFacts`/`mcpScopeTitle` — the one derivation site), refreshes the queue's entry, and FORGETS an ask whose target is gone; `durations(for:)` offers NOTHING on a book a fence covers now (`insertMCPGrant` refuses every duration there — P-2); `MCPAskCopy.reachLine` nil there and `lead` says it honestly ("This book is marked Private now, which no grant reaches — its notes are shared one ask at a time. Don't allow lets this ask go." / the daily-Journal twin — PROVISIONAL **P-13nc-SB-4**); `MCPAskSheet` reads the queue's CURRENT entry (every host — window, pane, ⌘L's nested road — renders this one view) and draws no granting answer until its open's read landed (`checked`). Pins `MCPAsksWaitTests`: `aReRaiseRefreshesThePayloadAndKeepsItsStampAndPlace`, `herOpenReadsTheNoteAgainSoAlwaysIsNeverADeadDoor`, `anAskWhoseTargetIsGoneIsForgotten`, `aBookFencedSinceSaysSoAndOffersNoGrant`. FABLE-OWED: extends **F-15** (row F-19 below) |
| B3 | "and N more ›" opens the act's whole member list (bounded read ∝ the act) | **FIXED** (`0a5fd108`; RED-ON-OLD in SB-R — the Mac pin (1) and the core pin headless (4); finals green; captured `sb-shared-act-*` + `sb-shared-members-*`) — `Queries.mcpSharedActMembers(_:grantIDs:)` (core: the act's LIVE grants in its order, each titled + its inert fence through the one rule; ∝ the act, one row per member, the same liveness `mcpSharedActs` reads); `MCPDoor.sharedMembers`; the grouped row's members line names the first three and then a DOOR, "and N more ›" (`MCPPaneCopy.groupMoreRoad`, `MCPSharedGroupView.unnamedMembers`), opening `MCPSharedMembersSheet` — every member, each with its OWN Revoke (the 13n-b row idiom: a member can be taken back alone; the row's Revoke still covers the act), following the store; hosted by the pane AND over the "all N ›" sheet. Pins: core `MCPShareTests.theActsRoadNamesEveryMemberInItsOrder` (5 named in order; a revoked member leaves; a member fenced since reads inert); Mac `MCPShareFacesTests.aGroupedRowsRoadNamesEveryMember`; `groupMembers`' pin updated as the ritual (the road split from the phrase) |
| B4 | Book Settings' grant-row gate on the fence's own fragments (`mcpFencedBookIDs`), parity pin | **FIXED — architectural** (`0a5fd108`; the parity pin green, as it must be on both sides; Mac final green; `u3-book-settings-*` re-shot: the row still draws on the held facts) — **architectural, no red-on-old possible (said plainly):** the face's old spelling (`!isPrivate && profile != 'daily'`) was equivalent, so any pin is green on both sides. `BookSettingsFace.showsGrantRow(for:grantable:canShare:)`; `BookSettingsModel.grantable` HELD with the reach (one observation: `reading` + the grants store, never `container`) from `BookSettingsModel.isGrantable` = `Queries.mcpBookFacts(...)?.fence == nil` — the read `insertMCPGrant` refuses on. Pins `MCPShareFacesTests`: the face pin updated as the ritual; **the parity pin** `theGrantRowsGateIsTheFencesOwnAnswer` (plain · Private · trait · THE daily Journal · an archived Private book — `isGrantable` == the complement of `mcpFencedBookIDs`; a gathering never grantable) |
| B5 | The Library row's Share with AI… door declared to the registry walk | **FIXED** (`0a5fd108`; the deletion check in SB-R — the door DELETED turns the pin red (1) while the union stays green through the book-row menus; Mac final green) — `LibraryCatalogView.contextMenuCapabilities = [.mcpShareHere]` (the doors only this list draws beyond `SidebarView`'s shared note-row grammar), unioned into `theContextMenusRenderExactlyTheDeclaredContextDoors` (a new renderer is a new line); **the pin** `CapabilityRegistryTests.theLibraryNoteRowMenuRendersItsDeclaredDoors` reads `postRowMenu`'s own body (a context menu cannot be mounted headlessly) for each declared door's `capability(.x).verb` |
| B6 | ⌘L unavailable with one wing (P-2), the note naming New Wing… | **FIXED** (`0a5fd108` + the walk's ritual `8fc848a0`; RED-ON-OLD in SB-R (2); Mac final green) — `CapabilityContext.wingCount` (default 1) ← `CommandRouter.wingCount` ← `WingState.wingCount` (session-level, written on a change by `WingsModel.adopt`: Home + the live wings; wired in `AppSession` beside the undo gates); `.switchWing`'s availability `wingCount > 1 ? .act : .unavailable` with `WingCopy.switchWingUnavailable` ("There is only one wing so far — New Wing… in the masthead’s ▾ menu makes another, and then ⌘L switches between them." — PROVISIONAL **P-13nc-SB-2**); the View menu's item `.disabled(… || !enabled(.switchWing))`. Pin `WingSwitcherChordTests.switchWingIsUnavailableWithOneWing` (the registry both ways + the note; a session's router grey with Home alone, live after a second wing is read) |
| B7 | The MCP pane's searchable description stops saying Claude Code only | **FIXED** (`0a5fd108`; RED-ON-OLD in SB-R (3); Mac final green) — `SettingsPane.mcp.blurb` "…the asks waiting for your answer, and how to set up Claude Code, Codex or any MCP client." (the R1 record carries the reviewer's proposal only as "per the reviewer"; these words name every `MCPSetupClient` label — PROVISIONAL inside her copy pass). Pin `MCPSetupMenuTests.thePanesDescriptionNamesEverySetupTheMenuOffers` |
| B8 | `SearchPicker`'s sourced panel: empty-before-typing vs no-match, a `loaded` flag | **FIXED** (`0a5fd108`; RED-ON-OLD in SB-R (2); Mac final green — the hosts' suites unedited and green) — `SearchPickerBrain.emptyState(query:sourced:loaded:)` (pure: a sourced panel says NOTHING until its first answer lands, then the host's empty sentence before typing and "Nothing matches." after; a flat panel unchanged); `SearchPickerPanel.loaded` set by `runSource`. Pin `SearchPickerBrainTests.anEmptyPanelSaysItsOwnSentenceBeforeTypingAndNoMatchAfter` (a new test in the hosts' suite; no existing pin edited) |
| B9 | "Any answer below grants it…" → true for Don't allow | **FIXED** (`0a5fd108`; RED-ON-OLD in SB-R (5); Mac final green) — `MCPAskCopy.reachLine` "Allowing grants it in “X”, including to future entries." (the wing twin likewise) — the minimal truth fix, the voice hers (P-13nc-U2-4). `MCPGrantSheetTests.theAskWearsItsDistinguisher…` updated as the ritual + the truth guard (no "any answer") |
| B10 | Lesson 6 "every call" / lesson 1 "every act" overclaims | **FIXED** (`e3e50161`; RED-ON-OLD in SB-R — lesson 1's and lesson 6's pins; Mac final green) — lesson 1: "…every act it takes comes back out with ⌥⌘Z for as long as this session is open" (the guide's OWN words for the session-scoped stack — the deleting chapter's "one ⌥⌘Z away for as long as this session is open"); lesson 6: "…under Activity, the calls clients made recently" (the store keeps the newest `mcpActivityCap` = 500). Pins in `TutorialMCPChapterTests` (lesson 1 + lesson 6, "every call" absent, the cap asserted). **Left, said:** the pane's empty-state `MCPPaneCopy.noActivity` ("every call a client makes is listed here") is the same claim on the pane while EMPTY — not in B10's row; a watch item for round 2 / her copy pass |
| B11 | Dead code removed; `mcpReachableBookIDs` kept as the parity oracle, doc corrected | **DONE** (`0a5fd108`; Mac final green) — removed `MCPDoor.allShared()` (no product caller since U3's acts) and `MCPDoor.liveGrantCount` (no caller); `MCPPaneTests`' all-N line moved to `allSharedGroups()` as the ritual. `mcpReachableBookIDs`' doc now says what it is: a PARITY ORACLE no face reads (the icon's `mcpBookReaches` is pinned equal to it). **Kept, said:** `Queries.mcpSharedRows` — no product caller now, but three core suites read it as the flat per-grant oracle beside the grouped read (`MCPGrantOperationsTests`, `MCPGrantPlacesTests`); deleting it would rewrite those pins for no product gain |
| B13 + O-2 | Every client-facing wire string gender-neutral; the sweep pin | **FIXED** (`d9ace41d`) — the advice ("until the author approves it", "what they have shared", "beside their text", "they may also open", "theirs or yours", "The daily Journal's entries", "asked them", "unless the author asks you to show them", "one undo for the author" — ~1,497 of its 1,500 characters: **U6's gatherings clause now needs a trim or the orchestrator's word to raise the bound**); `add_take` "they choose", `edit_take` "one undo for the author", `delete_block` "one undo for them", `save_version` "an edition they can come back to", `show_in_app` "want them to see — ONLY when they ask you to show them"; `MCPRefusalCopy.askedSentence` "…call again once they answer."; `MCPShowRule.notFrontmostWords` "Ask them to switch to it". Swept and found clean: `OpsRefusalTable` (the op refusals the host speaks to a client through `refusalWords`), every other `*Words` constant. *[Corrected at the close-out pass, R2-3: `refusalWords` is `OpsRefusalCopy.message(for:)` — the Mac's `Variorum/Registry/OpsRefusalCopy.swift`, consulted FIRST, which falls through to `OpsRefusalTable`; this row's net read only the latter. The close-out pass widened the net to `OpsRefusalCopy` and every copy file the two tables delegate to, plus the shim — all clean.]* **Pin** `MCPWireNeutralityTests` (new, headless, 4 tests): the advice; every tool AS THE SDK ENCODES IT (title, description, every input-schema string); every refusal/ask sentence (each reason × target, asked and not, the show rule's four, the wire-only op refusals); and a SOURCE net — every string literal in `Sources/VariorumMCP` + `OpsRefusalTable.swift`. The advice suite's two pins updated as the ritual (annotated). **RED-ON-OLD by revert** (the four server files from `d9ace41d~1`, pins kept): **5 tests red, 40 issues** — all four neutrality tests (advice 1 · tools 5 · sentences 15 · literals 17) + the advice ritual pin (2); restored by `git checkout --`, `git diff Sources` empty, 11/11 green |
| O-1 + O-3 | The pending glyph differs by silhouette (2–3 candidates captured, lead built PROVISIONAL); the helper row by role | **DONE, PROVISIONAL** (`0a5fd108`; captured `sb-pending-candidates-*` — A reads apart from the shared icon in both voices where the filled twin did not — and on the real Bookcase row + masthead `u4-bookcase-*`, the helper row `u4-helper-*`; Mac final green) — **the candidates** (each beside the shared icon at the Bookcase row's size, both voices — `sb-pending-candidates-*`): **A `questionmark.bubble` — BUILT** ("a question is waiting for you": the act IS an ask; the outline language of the sidebar set; nothing else in the app wears it) · B `hand.raised` (asking by gesture — but Apple's own privacy surfaces wear it, a near-collision with the Private lock beside it) · C the shared icon + an accent dot (closest family, but the difference is a 5-pt dot — the near-twin problem again at row size). PROVISIONAL **P-13nc-SB-3**, hers at the copy pass. `MCPSharedIcon.pendingSymbol` = `questionmark.bubble`; every comment that named the filled twin updated (`MCPSharedIcon`, `MCPAskGlyph`, `MCPNoteIndicator`, the U3 harness's label). **O-3:** `HelperView`'s MCP row names the mark by ROLE — "a small mark beside a note, book or wing" (the guide's lesson 6 words). Pins: `MCPShareFacesTests.theIconsGlyphIsTheMCPPanesOwnAndThePendingMarkDiffersBySilhouette` (renamed — the base shapes differ, not a fill) and `MCPAsksWaitTests.theHelpersMCPGroupHoldsEveryMCPChord` (+ the role row; no "filled"). Taste rows: guards, not red-on-old |
| S-2 | (optional) Waiting's scroll anchor on a row | **LEFT AS BUILT, said (the row allowed it):** `MCPPane.landAtWaiting` scrolls to the `Section`'s id. Moving the id onto a row means either a `ForEach` row's `.id` (which REPLACES that row's identity — the first row's identity would then change whenever the newest ask changes) or a marker row (a visible empty row in a grouped Form). Neither is clearly safer, and with the session locked neither can be checked — so S-2 stays the held walk's item (⌥⌘, from a fresh Settings window and one already open, an ask waiting), as R1 routed it |
| SB-R | **THE MAC RED-ON-OLD, by revert** (one combined build: the pre-fix behaviour put back behind the new API shapes in seven app files + B5's MUTATION — the Library row's door deleted; `scratchpad/sb_revert.py`) | DONE — on the reverted build, the pin suites (`TutorialMCPChapterTests`, `MCPAsksWaitTests`, `MCPShareFacesTests`, `CapabilityRegistryTests`, `WingSwitcherChordTests`, `MCPSetupMenuTests`, `SearchPickerBrainTests`, `MCPGrantSheetTests` — 111 tests): **exactly 12 RED, 34 issues, every other test green** — B1+B10 `lessonOne…` (4) · B10 `lessonSix…` (2) · B2 `aReRaiseRefreshes…` (2), `herOpenReadsTheNoteAgain…` (3), `anAskWhoseTargetIsGone…` (3), `aBookFencedSince…` (6) · B3 `aGroupedRowsRoadNamesEveryMember` (1) · B5 `theLibraryNoteRowMenuRendersItsDeclaredDoors` (1 — the door DELETED, while the union stayed green through the book-row renderers: the reviewer's point, shown) · B6 `switchWingIsUnavailableWithOneWing` (2) · B7 `thePanesDescriptionNamesEverySetup…` (3) · B8 `anEmptyPanelSaysItsOwnSentence…` (2) · B9 `theAskWearsItsDistinguisher…` (5). Restored (`git checkout --`, `cmp`-identical to the copies, tree clean). **Core B3, headless:** `mcpSharedActMembers` set to the old road (the act's group rows) → `MCPShareTests.theActsRoadNamesEveryMemberInItsOrder` **RED, 4 issues**; restored, `MCPShareTests` 15/15 green. **B4 is architectural (green on both sides by design — said in its row); O-1/O-3 are taste guards** |
| SB-F | Finals: headless package + Mac suites over every changed type (held stage) + the U4/U5 capture re-shoots | **DONE** — stage `vx165-sb` (claimed 11:00, released ~11:45 MDT; no Variorum instance at any point — `pgrep` clean). **Headless (whole package, `swift test`):** core **2,620 / 299** (U5's 2,619/299 + `theActsRoadNamesEveryMemberInItsOrder`) · `VariorumMCPTests` **80 / 11** (76/10 + `MCPWireNeutralityTests` 4/1; no VX-132 stall this time) · workbook **40 / 6** — all green. **Mac (`test-without-building`, 239 suites derived by script — every test file naming a type this pass changed):** first run 1,539 tests, 4 tests red (two baseline; one MINE — `noActIsUnavailableInEveryContext`, fixed as the ritual `8fc848a0`; one tour focus red green alone); **FINAL run on the restored tree: 1,539 tests / 239 suites, the ONLY reds the two baseline ones** — VX-115's standing `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` and VX-167's order-dependent `LibraryInfiniteScrollTests.aPageLandingReDrawsNoRowAlreadyBuilt` (both cards arms); the tour red (`TourEntryTests.helpsDoorStartsTheTour…`, a real-window `firstResponder` assertion) did NOT reproduce in the identical set and is green alone (13/13) — a parallel-window focus flake, no file it mounts changed here (for the orchestrator to fold into VX-167's family if it recurs); 14 skips, all standing gates; 1 known issue (`TakesFindBoardTests`' recorded boundary). **Captures — NOT A WALK (the session stayed LOCKED: 10:37 and through the pass):** the U3, U4 (+ the Stage B shots) and U5 harnesses re-shot, both voices, light, into `notes/plans/13n-c-screens/stageB/` (gitignored — `git check-ignore` verified; 68 images, decoded by a scratchpad script; the units' own folders untouched): `sb-pending-candidates-*`, `sb-shared-act-*`, `sb-shared-members-*`, `sb-ask-fenced-book-*`, and every `u3-*`/`u4-*`/`u5-*` face re-drawn on this tree (read: the new mark on the Bookcase row + masthead, the ask sheet's answers drawn after the read, Book Settings' grant row on the held facts, lesson 1's two sentences, the helper's role row) |
| SB-X | FIX PASS CLOSED banner | DONE (this commit) — atop this record |

---

## THE STAGE B CLOSE-OUT FIX BRIEF (self-contained; the spawn names this section)

You are the Stage B close-out fix implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on branch
`vx-165-13n-c` (never the main checkout). Commits say `Part of VX-165`, carry NO attribution trailer, and are pushed
after every commit. `notes/SessionResiliencyProtocol.md` binds you: keep LIVE STATUS in the "STAGE B CLOSE-OUT FIX
RECORD" section below from your first commit; foreground waits only; no subagents.

**Read first, whole, never delegated:** this plan file top to bottom (the U2–U5 records, the STAGE B FIX RECORD,
the orchestrator findings O-1…O-4, P-13nc-U5-5's ruled bound), `notes/plans/13nc-stageB-ladder-round1.md`, and
`notes/plans/13nc-stageB-ladder-round2.md`. Round 2's dispositions plus O-4 plus the bound are your whole work
list; do nothing beyond them.

**The rules:**
- **Pins:** red-on-old by revert for every bug-class row; R2-3 is a guard widening, said plainly.
- **The fence:** never re-derive it; R2-1's re-validation consumes `mcpNoteFacts` / `mcpBookFacts` /
  `mcpScopeTitle`, ∝ the queue.
- **O-4:** keep the setup menu's Claude Code entry, command, receipt and default exactly as they are (she excluded
  setup). Add the source-sweep pin O-4 names.
- **Copy:** sentence case; every new word PROVISIONAL for her copy pass.

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the real store,
`/Applications`.

**The Mac is unlocked now.** Mac suites run under a HELD `Tools/stage` claim, released at the end. Do NOT launch
the Debug app or walk; the orchestrator runs the walks after you. VX-132: if a VariorumMCPTests run hangs, kill it
and rerun.

**Acceptance:** the whole headless package, plus the Mac suites over every changed type, reading the `skipped:`
lines.

**Close:** a CLOSE-OUT FIX PASS CLOSED banner — per row: commit and pin evidence, PROVISIONALs, FABLE-OWED rows
written at the moment.

## STAGE B CLOSE-OUT FIX RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~12:10 MDT). Worktree `~/dev/variorum-vx-165`,
branch `vx-165-13n-c`. **No revert is in flight unless a line below says so.** *(The R2-3 mutation check is DONE and RESTORED — `cp` + `cmp`-identical, `git status` showed only this pass's edits.)* *(The Mac red-on-old revert (CB-R) is DONE and RESTORED — six files `cp`'d back, each `cmp`-identical to its pre-revert copy, `git status` clean.)* The Mac is unlocked (the brief); no
Debug-app launch and no walk in this pass (the orchestrator walks after it). Work list = round 2's R2-1…R2-5 + O-4 +
her 2,000-character bound — nothing beyond it.

### CLOSE-OUT FIX PASS CLOSED (2026-10-11 ~13:45 MDT — the Stage B close-out fix implementer, Opus `claude-opus-5-5`)

**NOT DONE (said first):** (1) **no walk, no Debug-app launch, no capture re-shoot** — the brief gives the walks to the
orchestrator after this pass; the faces that changed and are owed to its walk: the ask sheet's gone line (a window's
status line; the pane's caption), the members sheet's "1 note" and its close-on-empty, Waiting's rows leaving a dead
place, the masthead's wing mark leaving when its wing dies, the ⌘/ helper's and the guide's "Undo ‹name›'s take", the
Settings ▸ MCP description and toggle sentence, the empty Activity line. (2) **R2-1 (b)'s residue, said:** a note
deleted while Settings ▸ MCP stays on screen keeps its Waiting row until the pane re-renders or she presses it — and
the press then says why it did nothing (a). A note's death cannot wake an autosave-quiet watch (measured — T-CB-2,
`RegionObservationTests`); its mark rides only its own rows elsewhere, which leave with it. (3) **O-4's suggested
multi-provider wording ("any MCP client — Claude Code, Codex, Cursor and others") was NOT used** — it would break the
pin O-4 itself names; the copy names no provider, and the list is the recorded alternative for her copy pass. (4) No
`notes/QUESTIONS.md` edit (merge-time, #211) and no canon edit. **Touched beyond the app, said plainly:** ONE additive
method in `Sources/VariorumCore/Persistence/AppDatabase.swift` (`observe(tracking:_:)` — no schema, no migration, no
existing caller changed) and `Sources/VariorumMCP/MCPSession.swift` (the bound). Zero `Sync/`, migration, custody/
keychain, editor-seam (`EditorTextView`/`BlockRangeIndex`/`PaneSurface`), `lockstepVersion`, real-store or
`/Applications` lines (`git diff --name-only 6f7fc38f..HEAD` checked); zero trailers; no Variorum instance ever ran.

**Per row:** BOUND DONE `af5956dc` (her ruling — no red-on-old owed) · R2-3 DONE `af5956dc` (a guard widening, green both
sides — said; shown real by a planted pronoun: new net red, old net green) · O-4 DONE `cfa2a1f0` (headless pin red-on-old
21 issues at its commit; the Mac ritual + keyword pins red in CB-R) · R2-5 DONE `a399c562` (red in CB-R) · R2-2 DONE
`a399c562` (red in CB-R) · R2-4 DONE `a399c562` (comments; the system buttons re-checked and KEPT) · R2-1 DONE
`4014da37` + `e955a86e` (both pins red in CB-R; the road's own pins `RegionObservationTests`). **The Mac red-on-old
(CB-R):** exactly 8 pins red / 29 issues on the reverted build over the four pin suites, nothing else; restored,
`cmp`-identical.

**Finals:** headless (whole package, `swift test`) **core 2,623 / 300** (2,620/299 + `RegionObservationTests` 3/1) ·
**`VariorumMCPTests` 82 / 12** (80/11 + `MCPProviderNeutralityTests` 2/1; no VX-132 stall) · **workbook 40 / 6** — all
green, the skips the standing gated ones only. **Mac** (stage `vx165-cb`, claimed ~12:45, released ~13:40 MDT;
`test-without-building` on `DerivedData/vx165-cb`, rebuilt on the restored tree): **76 suites / 537 tests
`** TEST EXECUTE SUCCEEDED **`, 0 skipped, 0 known issues** — every suite whose file names a type this pass changed
(the MCP pane, door, ask sheet and copy; `HelperView`; the Settings catalog/search; `TutorialSeeder` — the tour, walk,
privacy, books and MCP chapter suites among them), derived by script; plus the five gated capture harnesses that name
them, **6 tests / 5 suites, all skipped by design** (the capture env unset). No baseline red appeared in this set
(VX-115's and VX-167's pins are outside it).

**PROVISIONALs (for #211 at the merge — also added to the running list):** **P-13nc-SB-5** the gone line and its seam
· **P-13nc-SB-6** O-4's neutral words · **P-13nc-SB-7** the empty Activity line. **FABLE-OWED row written at the
moment:** **F-22** (R2-1 — the ask watch forgets waiting asks; extends F-19).

**Where a cold reviewer should look first:** (1) `MCPDoor.watchAsks` / `adoptStanding` / `revalidateAsks` /
`refreshAsk(_:from:)` — the restart on every id-set change (an `adoptQueue` from inside the watch's own loop cancels
and restarts it), verdicts applied to the queue as it stands NOW, `answering` cleared on a forget, the gone line said
even when the watch forgot the ask mid-read; (2) `AppDatabase.observe(tracking:_:)` — constant-region tracking's
contract (the fetch's own reads untracked) and the measured limit pinned in `RegionObservationTests`
(`thePlacementTableCannotTellATrashFromAnAutosave` documents GRDB + trigger behaviour — if it ever goes quiet, the
watch can name `container_block`); (3) `MCPProviderNeutralityTests`' fences and the `keywords:` exemption (a literal
parser — a provider named in a `keywords: [ … ]` list anywhere is exempt by design); (4) `MCPSharedMembersSheet.load`
(`sharedMembers` now nil on a failed read) and the close on an empty load.

**Self-assessment:** every row is at its named site with a pin watched red on the pre-fix behaviour (or, for R2-3, the
bound and R2-4, said plainly to be a guard, a ruling, or comments). The one real surprise was R2-1 (b): my first trace
claimed GRDB's column-grained regions would keep autosaves out of a watch reading `container`; a probe proved it false
(a full-record container stamp, plus the cascade trigger's compiled program and the FTS shadow writes, wake any
observer of those tables), so the design changed to an autosave-quiet watch on `reading` + `wing` plus Waiting's own
re-validation, and the probe stayed as pins. Least certain: whether she wants a forget she never pressed to stay
silent (built: silent) and the placeholder form "‹name›" in the guide's prose — both her copy pass's.

| # | Row | Status |
|---|---|---|
| CB-0 | Preflight read whole (this plan top to bottom incl. the STAGE B FIX RECORD, O-1…O-4, P-13nc-U5-5's ruled bound; `13nc-stageB-ladder-round1.md`; `13nc-stageB-ladder-round2.md`; `SessionResiliencyProtocol`) + the traces below | DONE (this commit) |
| BOUND | `MCPSession.instructionsBound` 1,500 → 2,000 (her ruling, P-13nc-U5-5); the pin keeps its form | **DONE** (this commit) — `instructionsBound = 2_000` with her words in its doc; `MCPAdviceServerTests.theAdviceIsBoundedAsStated` `== 2_000` (the form kept); a ruling, not a bug-class row (no red-on-old owed). The advice itself is unchanged (~1,497 characters — ~500 of room for U6's gatherings clause). `MCPAdviceServerTests` + `MCPWireNeutralityTests` 11/11 green headless |
| R2-3 | `MCPWireNeutralityTests`' source net widened to `OpsRefusalCopy.swift`, the copy files the two refusal tables delegate to, and `MCPShim.swift`; the B13 row corrected to name `OpsRefusalCopy` | **DONE** (this commit) — **a guard widening, green on both sides by design (said plainly — everything it adds is clean today, T-CB-4).** `MCPWireNeutralityTests.refusalCopyFiles`: `Variorum/Registry/OpsRefusalCopy.swift` (the table the wire consults FIRST — `refusalWords: { OpsRefusalCopy.message(for: $0) }`; `BlockSelectionCopy` inside it), `Shared/OpsRefusalTable.swift`, `Shared/BookNameCopy.swift`, `Shared/BookArchiveCopy.swift`, `Shared/EditorBrain/CrossBlockRefusal.swift`, `Shared/RecoveryCopy.swift`, `Variorum/Features/Stars/StarsModel.swift` (`StarCopy`), `Sources/VariorumMCPSocket/MCPShim.swift` (its stderr) — each asserted to EXIST (a moved file fails, never slips out). **The widening shown real (a mutation, not red-on-old):** a pronoun planted in an `OpsRefusalCopy.swift` literal — the NEW net red (1 issue), the OLD net (the test file from `HEAD`) green, i.e. it missed it; both restored, `cmp`-identical. The parser's blind spots (a one-line `"""`) left unguarded — optional per the row. The B13 row above corrected in place (bracketed) |
| O-4 | Her provider-neutrality sweep: (a) `enableBlurb` · (b) the ⌘/ ⌥⌘Z row · (c) the guide's undo example + name example · (d) the guide's lesson 1 + the two Settings blurbs · (e) the search keywords; the source-sweep pin | **DONE** (this commit; the Mac ritual pins' run PENDING CB-F) — **the copy, every word PROVISIONAL (P-13nc-SB-6, her copy pass):** (a) `MCPPaneCopy.enableBlurb` "so clients like Claude Code can read" → "so MCP clients can read"; (b) `HelperView`'s ⌥⌘Z row "(“Undo claude-code's take”)" → "(“Undo ‹name›'s take”)" — the Edit menu's words in PLACEHOLDER form (the app's own ‹ › placeholder notation); (c) the guide's lesson 6 "the Edit menu names it: Undo claude-code's take." → "the Edit menu names it after the client: Undo ‹name›'s take." and lesson 2's limit card "(claude-code, say)" dropped ("a client names itself when it connects, and Variorum can't check that name" — the pane's L1 twin); (d) lesson 1 "a standard way for AI apps such as Claude Code or Codex to use another app's tools" → "a standard way for AI apps to use another app's tools", the `mcpServer` row's blurb → "A local server for any MCP client.", and `SettingsPane.mcp`'s description (B7's) → "…and how to set up any MCP client."; (e) the `mcpServer` keywords keep claude/claude code/codex and add anthropic · openai · chatgpt · gpt · cursor · gemini · copilot · windsurf · ollama. **The call, said:** O-4's suggested wording for (d) ("any MCP client — Claude Code, Codex, Cursor and others") would itself break the pin O-4 names (no provider name outside the setup and the keywords), so the copy names NO provider; the multi-provider example list is the recorded alternative for her copy pass. **Kept, the provider setup (her exclusion):** `MCPSetupClient`, the pane's "Connect a client" copy (`setupCommand`, `connectSentence`, `copiedReceipt`, `codexCommand`, `copiedCodexReceipt`) and the menu's default, all BYTE-UNCHANGED; the guide's lesson-2 card that teaches the menu by its labels (the H pattern — plain text). **THE PIN** `MCPProviderNeutralityTests` (new, headless — the wire net's precedent; reads the sources from disk): every non-comment string literal under `App/Variorum/Variorum`, `Shared`, `VariorumMobile` and `Sources/` names no provider (claude · anthropic · codex · openai · chatgpt · gemini · copilot · windsurf; "cursor" left out — it is the text cursor everywhere), except inside an `O-4 SETUP COPY BEGIN`/`END` fence or a `keywords: [ … ]` list; a second test guards the fences (only MCPPaneCopy ×2 and TutorialSeeder ×1, balanced, ≤120 lines, each holding a provider — a stale fence fails). **RED-ON-OLD (the pin written first, run on the pre-fix copy):** 2 of 2 RED, 21 issues — the 20 provider literals (T-CB-5's seven sites + the not-yet-fenced setup copy) and the absent fences; GREEN after. **Mac ritual (annotated in place):** `MCPSetupMenuTests.thePanesDescriptionNamesEverySetupTheMenuOffers` → `…SetsUpAnyClientAndNamesNoProvider` (B7's PROVISIONAL words superseded by her ask); `MCPAsksWaitTests.theHelpersMCPGroupHoldsEveryMCPChord` and `TutorialMCPChapterTests.lessonSix…` quote the placeholder composed by the menu's own functions (`undoMenuTitle` over `undoLabel(client: "‹name›")`); lesson 1 asserts no provider; NEW `MCPSetupMenuTests.theSearchFindsThePaneWhateverItsClientIsCalled` (her (e)) |
| R2-5 | `MCPPaneCopy.noActivity` true words ("recently", lesson 6's) + pin | **DONE** (this commit; Mac run + red-on-old PENDING CB-R/CB-F) — "Nothing yet — the calls clients made recently are listed here." (lesson 6's own phrase; PROVISIONAL, her copy pass). Pin in `TutorialMCPChapterTests.lessonSix…` beside B10's ("the pane says the same"; no "every call") |
| R2-2 | The members sheet: "1 note" singular; a `loaded` flag; a load that comes back empty closes the sheet; pin `membersTitle(1)` | **DONE** (this commit; Mac run + red-on-old PENDING CB-R/CB-F) — `MCPPaneCopy.groupTitle(1)` = "1 note" (so `membersTitle(1)` = "1 note shared in one act"); `MCPSharedMembersSheet.loaded` + the pure `shownCount(loaded:rows:memberCount:)` (the act's count until loaded, then exactly the list's) and `closesAfterLoad(_:)` (empty ⇒ `done()`); one `load()` for the open and every store change; `MCPDoor.sharedMembers` now answers nil when the READ fails (nothing learned — never mistaken for nothing left; the B3 pin's call `?.map` as the ritual, annotated). Pin `MCPShareFacesTests.theMembersSheetSaysOneNoteAndClosesWhenNothingIsLeft` (the title words; the count rule; a live act stays, the last member revoked reads empty-and-closes) |
| R2-4 | `MCPAskSheet`'s stale comments (the "While connected" header; the W-3 WindowGroup rationale); the system-button choice re-checked and recorded | **DONE** (this commit) — the header says "in the window or pane she pressed in" and "Until it disconnects (… P-13nc-U4-1's words for 13n-b's 'while connected')"; the buttons' comment carries the RE-CHECK (T-CB-6): the WindowGroup host is retired, but the two window hosts attach `.mcpAskSheet` after their `.environment(theme)`, so the sheet gets no `ThemeStore` there and voiced buttons would fall to the mono face — **SYSTEM BUTTONS KEPT, said**. Comments only; no behaviour, no pin owed |
| R2-1 | (a) her open forgetting a gone target's ask speaks a refusal-kind line naming the place, on the seam of the host she pressed in; (b) the queue's targets re-validated in one batch (∝ the queue) so a dead ask's mark leaves without a press — the trigger recorded; pins red-on-old | **DONE** (`4014da37` the road + this commit; the 4 pin suites 55/55 green on the Mac, 0 skipped; red-on-old PENDING CB-R) — **(a)** `MCPDoor.refreshAsk(_:from:)` — finding the target gone, it forgets the ask AND says `MCPAskCopy.gone` ("“ch 7” is gone, so claude-code's ask was let go." / "The variorum wing is gone, so …" — PROVISIONAL **P-13nc-SB-5**) as a REFUSAL on the seam she pressed in: `AskSeam.window` → the session's status line; `.pane` → the door's caption at the pane's head (Settings has no status seam); said even if the watch forgot the ask during the read (her press is the one that found nothing). `MCPAskSheet.seam` + `mcpAskSheet(door:askID:seam:)` (default `.window`; the pane passes `.pane`). **(b)** the ASK WATCH (`watchAsks`, from `adoptQueue`): alive only while an ask waits, `database.observe(tracking: [reading, wing])` whose fetch is `asksStanding` (every waiting ask through `askStanding` in ONE read — ∝ the queue ≤ 8), restarted (an immediate full re-validation) whenever the set of waiting asks changes, stopped by an empty queue (detach included); `revalidateAsks()` — the same batch one-shot, run by WAITING's render (the pane's section `.task` keyed on the waiting ids, and the all-N sheet's Waiting list); `adoptStanding` applies verdicts to the queue as it stands NOW — gone ⇒ forgotten SILENTLY (an open sheet closes, T-U4-5's idiom), standing ⇒ refreshed. **Pins** (`MCPAsksWaitTests`): `herPressSaysSoWhenThePlaceIsGone` (a note's on the window seam — text + `.refusal` kind; a book's on the pane's caption; the wing words) · `aDeadPlacesMarkLeavesWithoutAPress` (a book's and a wing's death take their marks — the masthead's wing word included — with no press; a living note's stays; the watch SLEEPS through a note's trip to the Trash (the measured limit, at the door) and Waiting's re-validation takes it; silent — no status line, no caption). **Ritual (annotated):** `denyingAClientForgetsItsAsks` asks on a REAL note (an ask on an id naming nothing — which the wire never raises — is now forgotten as gone) |
| CB-R | The red-on-old reverts (named here BEFORE each starts; pre-revert copies in the session scratchpad's `cb-prerevert/`) | **DONE** (named in `6579efed` before it started) — **THE MAC RED-ON-OLD, by revert** (one combined build: the pre-fix behaviour put back behind the new API shapes — `MCPDoor.swift`: no gone line in `refreshAsk`, `adoptQueue` never starts the watch, `revalidateAsks` inert; `MCPPane.swift`: the old title count (`rows == 0 ? memberCount : rows`) and no close; `MCPPaneCopy.swift`: the old `groupTitle`, `noActivity` and `enableBlurb`; `HelperView.swift` / `SettingsShape.swift` / `TutorialSeeder.swift` from `634558cd`, pre-O-4): over the four pin suites (`MCPAsksWaitTests`, `MCPShareFacesTests`, `MCPSetupMenuTests`, `TutorialMCPChapterTests` — 55 tests) **exactly 8 RED, 29 issues, every other test green** — R2-1 (a) `herPressSaysSoWhenThePlaceIsGone` (1 — the line never said) · R2-1 (b) `aDeadPlacesMarkLeavesWithoutAPress` (3 — the book's and wing's marks stay, the note's survives Waiting) · O-4 (b) `theHelpersMCPGroupHoldsEveryMCPChord` (2) · O-4 (d) `thePanesDescriptionSetsUpAnyClientAndNamesNoProvider` (7) · O-4 (e) `theSearchFindsThePaneWhateverItsClientIsCalled` (6 — chatgpt, openai, anthropic, gemini, copilot, cursor found nothing) · R2-2 `theMembersSheetSaysOneNoteAndClosesWhenNothingIsLeft` (3) · O-4 (d) `lessonOneTheDoorIsShutUntilYouOpenIt` (3) · O-4 (c) + R2-5 `lessonSixSeeingAnsweringUndoing` (4). Restored (`cp` + `cmp`, tree clean). **Headless, already shown:** O-4's source pin red-on-old (21 issues, at its commit); R2-3's widening shown real by a planted pronoun. **Guards, said:** R2-3 (green both sides by design); `RegionObservationTests` (the new API's pins — a new road, no old behaviour to be red on); R2-4 (comments only) |
| CB-F | Finals: the whole headless package + the Mac suites over every changed type under a held stage claim | **DONE** — headless core 2,623/300 · `VariorumMCPTests` 82/12 · workbook 40/6, all green (standing gated skips only); Mac 76 suites / 537 tests green, 0 skipped, 0 known issues + the five gated capture harnesses 6/5 skipped by design (stage `vx165-cb`, released). **Machinery, said:** the first set run executed 0 tests (zsh does not word-split an unquoted variable — 76 flags arrived as one argument), and the second ran the STALE reverted build (`test-without-building` after the restore) — it showed exactly CB-R's 8 reds; rebuilt on the restored tree, then green |
| CB-X | CLOSE-OUT FIX PASS CLOSED banner | **DONE** (this commit) — atop this record |

### Traces (made before any code — the hallucination guard)

- **T-CB-1 — R2-1 (a), the silent forget.** `MCPAskSheet`'s `.task` calls `MCPDoor.refreshAsk(_:)`; when
  `askStanding` answers nil (the note/book deleted, a book un-bound to a gathering, a wing deleted) it removes the
  entry and returns nil — every host's `mcpAskSheet` getter then reads nil and the sheet closes, and NOTHING is said
  (`MCPDoor.swift` `refreshAsk`: `queue.remove` + `adoptQueue` + `answering.remove`, no status line). Her press opened
  a door that did nothing, silently — AppSpec §12's "a door that did nothing speaks a refusal". The hosts differ: two
  WINDOWS (`RootView`/`NoteWindowView` — the session's status seam) and the PANE (Settings has no status seam — the
  door's own `note` caption at the pane's head, `MCPDoor.Note(place: .top)`); ⌘L's nested road is a window's.
- **T-CB-2 — R2-1 (b), the mark that outlives its target.** Nothing re-reads a waiting ask until her press: the queue
  changes only on `enqueue`, `answer`, `deny`/`forgetAsks`, `refreshAsk` and `detach`. A note moved to the Trash, a
  book deleted or a wing deleted leaves its ask on `askBoard` until she presses it. **Where a dead mark is VISIBLE:**
  a note's mark rides only that note's own rows (Library/Pool rows, the Book Panel, the open note's bar and
  indicator), which leave with the note — so after a note's death its mark shows only in WAITING; a book's leaves with
  its Bookcase row except when the book is UN-BOUND to a gathering (the row stays); a WING ask's mark rides the
  masthead's wing word, which stays — the reviewer's example. **THE TRIGGER — first drafted wrong, corrected by
  MEASUREMENT (said plainly):** the first draft held a read-tracked observation of `askStanding` and claimed GRDB's
  column-grained regions would keep autosaves out. A headless probe (`RegionObservationTests`, kept as pins) showed
  it false: an autosave stamps `container` with a FULL-RECORD update (`registerTextChange` → `container.update(db)`),
  so any fetch reading `container` re-runs per edit; and even an observation NAMED on `container_block` wakes per
  autosave, because that update compiles `cascade_container_tombstone` (advertising `block`, `container_block`,
  `reading_post`, `post_tag`, `reference`) and writes the FTS index's shadow tables — "unadvertised" events GRDB
  treats as touching every interested observer. **So no table a note's death writes can be told apart from an
  autosave.** `reading` and `wing` lie outside that set (measured: four autosaves, zero wakes; a book's write, a
  book's death and a wing's death each wake it). **Chosen, narrowest:** (1) ONE watch, alive only while an ask waits,
  NAMED on `reading` + `wing` through a new additive `AppDatabase.observe(tracking:_:)` (GRDB's constant-region
  tracking — the fetch's own reads not tracked), whose fetch IS the re-validation: `askStanding` over every waiting ask
  in one read (≤ `MCPAskQueue.cap` = 8 — the one derivation site, never re-derived); it also restarts — one immediate
  re-validation of every ask, notes included — whenever the set of waiting asks changes; (2) WAITING re-validates in
  one batch when it renders (`.task` keyed on the waiting ids) — the one face a note's dead mark can still show;
  (3) her press (`refreshAsk`) re-reads and, finding the target gone, SPEAKS (a). The residue, said: a note deleted
  while Settings ▸ MCP stays on screen keeps its Waiting row until the pane re-renders or she presses it — and the
  press then says why it did nothing. A forget by the watch or by Waiting is SILENT (the mark leaving is the change;
  an open sheet closes exactly as when its ask is answered elsewhere — T-U4-5's idiom).
- **T-CB-3 — R2-2.** `MCPPaneCopy.membersTitle(_:)` = `"\(groupTitle(count)) shared in one act"` and `groupTitle`
  = `"\(count) notes"` — one member reads "1 notes shared in one act". The sheet's title count is
  `rows.isEmpty ? group.memberCount : rows.count` — before the load AND after a load that came back empty (the last
  member revoked here) it shows the act's stale count above an empty list (B8's not-loaded-vs-nothing class).
- **T-CB-4 — R2-3.** The host's `refusalWords` is `{ OpsRefusalCopy.message(for: $0) }` (`MCPDoor.reconcileServer`),
  the Mac's `Variorum/Registry/OpsRefusalCopy.swift` — consulted FIRST, falling to the shared table; the B13 net read
  only `Shared/OpsRefusalTable.swift`. The tables delegate to `BookNameCopy`, `BookArchiveCopy`, `CrossBlockRefusal`
  (shared) and `BlockSelectionCopy` (in `OpsRefusalCopy.swift`), `RecoveryCopy`, `StarCopy` (`StarsModel.swift`);
  the shim (`Sources/VariorumMCPSocket/MCPShim.swift`) writes its own stderr. All clean today (grep) — a guard.
- **T-CB-5 — O-4, re-swept at this tip** (every non-comment string literal naming claude/anthropic/codex/openai/
  chatgpt/gemini/copilot): outside the setup menu — `MCPPaneCopy.enableBlurb` ("clients like Claude Code"),
  `HelperView`'s ⌥⌘Z row ("Undo claude-code's take"), `TutorialSeeder` lesson 1 ("such as Claude Code or Codex"),
  lesson 2's limit card ("(claude-code, say)"), lesson 6 ("Undo claude-code's take"), `SettingsShape` `.mcp`'s
  description (B7's "how to set up Claude Code, Codex or any MCP client") and the `mcpServer` row's blurb ("such as
  Claude Code or Codex"). The setup menu's own words (`MCPSetupClient`, `setupCommand`, `connectSentence`,
  `copiedReceipt`, `codexCommand`, `copiedCodexReceipt`), the guide's lesson-2 card that teaches that menu by its
  labels (the H pattern — never interpolated), and the search keywords are the provider setup her ask excludes.
  Zero hits in `Sources/` (the wire), `Shared/`, `VariorumMobile/`.
- **T-CB-6 — R2-4.** `MCPAskSheet`'s header still says "While connected" (the duration reads "Until it disconnects"
  since U4) and "on the main window"; its buttons' comment gives U2 walk W-3's reason (presented at the WindowGroup
  level, no theme). Re-checked at this tip: the WindowGroup host is retired (U4), but the two WINDOW hosts attach
  `.mcpAskSheet` AFTER their `.environment(theme)` (`RootView`, `NoteWindowView`), so the sheet's content still
  receives no `ThemeStore` there (the palette, What's New and grant sheets each add `.environment(theme)` for exactly
  this reason); only the pane (inside `AppSettingsView`'s `.environment(theme)`) and ⌘L's nested road carry it.

---

## THE HELD-WALKS BRIEF (leg 1 of ledger row 13; self-contained; the spawn names this section)

You are the walk implementer for Variorum phase 13n-c, in `~/dev/variorum-vx-165` on branch `vx-165-13n-c` (never the
main checkout). Every walk the units owed was HELD overnight because the Pro was locked. She unlocked it at 11:31 MDT,
so you run them now.

**The rules:**
- Commits say `Part of VX-165` with NO attribution trailer, pushed after each.
- Keep LIVE STATUS in "HELD-WALKS RECORD" below from your first commit. No subagents.

**Read first, whole, never delegated:** this plan file top to bottom (every unit record's owed-walk list — U1's live
round, U2's and U3's walk lists, U4-10, U5's, the STAGE B FIX RECORD's and the CLOSE-OUT FIX RECORD's "faces your
walk should check", S-1 and S-2), then `Tools/WalkKit/README.md`.

**How you walk:**
- Use the DEV-STORE Debug build only (`io.lduarte.Variorum.debug`), built from the tip with its own DerivedData
  path, driven by `cliclick` + `Tools/WalkKit/` under a HELD `Tools/stage` claim. Renew it; release at the end.
- NEVER touch the real store, `/Applications/Variorum.app`, or a running real-store instance (never quit or kill one).
- She may be at the Mac. If a press lands somewhere unexpected (she moved the mouse or changed focus), STOP that leg,
  record it, and retry once. Never fight her for the pointer.
- Walk Study AND Terminal, in light, with dark on the faces that changed. Use U2's scale seed (≥150 books) for the
  picker legs.
- Captures go to `notes/plans/13n-c-screens/walk/` (gitignored). READ every capture you take.

**The real-client live round (U1's owed round + U4's ask leg + U5's advice leg):**
- Register the Debug build's shim with a REAL Claude Code client, `-s local` only, in a scratch folder under the
  session scratchpad. Never `-s user` (her own registration lives there). Remove it at the end.
- Drive it with `claude -p` turns. Prove each of these on the dev store:
  - (1) the advice arrives (the client can state it);
  - (2) a connection request, approved in the pane;
  - (3) the U1 fence: a daily-Journal entry and a Private note answer exactly like a missing id; a book grant on a
    trait journal reads;
  - (4) an ask arriving while you type in a note: NOTHING appears but the mark, answered from the mark; another
    answered from Waiting;
  - (5) ⌥⌘A and its receipt's Change… and Revoke;
  - (6) a write's undo naming the client.
- Record every client turn's exact text in the record.

**Findings:**
- A walk finding that is a clear defect: fix it with a red-on-old pin if bug-class, re-walk that leg, and record it.
- Anything taste or layout ("hard to find", spacing, looks): record it with its capture, and do NOT redesign. The
  Opus UX-reviewer walk later judges those.
- Never touch `Sync/`, custody, the editor seam, migrations or `lockstepVersion`.
- Mac suites over anything you change, under the claim.

**Close:** a WALKS CLOSED banner with:
- per leg: walked or not, its evidence, what it found and what it fixed;
- the live round's transcript pointers;
- the taste list for the UX reviewer;
- FABLE-OWED rows for any default's-meaning fix.

## HELD-WALKS RECORD (LIVE STATUS — the walk implementer owns this section from its first commit)

Walker: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~12:50 MDT — the machine clock; an earlier line said 13:55 in error). Worktree `~/dev/variorum-vx-165`, branch
`vx-165-13n-c`, from tip `9615e165`. **No revert is in flight unless a line below says so.** Stage claim name
`vx165-walk`. Captures in `notes/plans/13n-c-screens/walk/` (gitignored — `git check-ignore` verified, `.gitignore:66`).

### WALKS CLOSED (2026-10-11 ~16:05 MDT — the walker, Opus `claude-opus-5-5`; resumed after her pause at 13:38)

**NOT DONE / NOT WALKABLE (said first):** (1) **a REAL Claude Code client's connection REQUEST** — the dev store already knew "claude-code" (approved by earlier walks; a denied client stays denied, re-approved from its row), and the harness classifier REFUSED swapping in the pre-13n-b backup; the request FACE was walked with a scripted stdio client ("walk-request"), the real client's approval from its denied row. (2) **Not raisable on this store:** a WING ask (no tool names a wing the client cannot reach) — so an ask answered from a ⌘L switcher row, the masthead word's wing mark, and that mark leaving when its wing dies stay pinned + captured only; a BOOK ask leaving by the watch (a fenced book's `list_notes` raised none). (3) **⌥⌘A without history** (every approval mints a grant — T-3 — so no approved client can lack one). (4) **The empty Activity line** (this store has 158 rows). (5) **The AI write receipt's "Open ›"** — the quiet line faded during the ~20-s turn; ⌥⌘O, its keyboard road, walked. (6) **Codex's command not run** (no `codex` on this Mac); the JSON parsed; the Claude Code command run `-s local`. (7) **Terminal and dark were walked as CAPTURES of the changed faces** (the pane, both pickers, the Bookcase icons + popover, ⌘L, the chapter) — the legs themselves were driven in Study light. (8) No `notes/QUESTIONS.md` and no canon edit; the orchestrator's ledger row 13 left for the orchestrator.

**Per leg:** W-2 WALKED (zero clients: no face renders) · W-3 WALKED (setup menu, request face, live (1) + (2)) · W-4 WALKED (**live (3) PROVEN** — byte-identity of the daily-Journal member, the ⌘J entry, the Private note and a made-up id under a Home-wing READ grant; zero passages; the trait book reads; R-AIR-3's and D-3's confirms on screen) · W-5 WALKED after the fixes (typing, by shelf, starred, the three sherlocks told apart — "made Oct 14/17, 2024", "Welcome" — and the right one granted; a note from Recently edited; the fenced note's honest durations; WHO; L1) · W-6 WALKED (**live (5) PROVEN** — ⌥⌘A with history / already reaching / Change… replacing a lowered rung / Revoke ›; one act → one row → one Revoke; book shares from the row menu and Book Settings; the icon's hover + popover + why) · W-7 WALKED (**live (4) PROVEN** — asks wait while typing, answered from the mark and from Waiting; ⌥⌘, both cases (S-2); ⌘L typed / held / fast (S-1) + both mastheads cycling; a denied client's marks leave; ⌘/ + Settings ▸ Shortcuts) · W-8 WALKED (**live (6) PROVEN** — "Undo claude-code's take" / "Redo claude-code's take") · W-9 WALKED (the re-seed road, the MCP chapter read and checked against the walk, the inert row, the gone line, the members sheet's "1 note" + close) · W-10 WALKED (Terminal + dark captures) · W-11 DONE (final Mac run 200/21 green; every machine-state item restored).

**FOUND AND FIXED — four bug-class defects, each pinned RED on the pre-fix tree, fixed, re-walked live:**
- **D-W1** the grant sheet's NOTE picker never showed its rows (the popover sizes once from an empty first frame) — `SearchPickerPanel` reserves its list's height when sourced; pin `aSourcedPanelsFirstFrameReservesItsList` (red: "the first frame is 50.0 pt tall" ×2 voices). Commits `e0224a68` (pins) · `ae0770cf` (fix).
- **D-W2** a book listed in two picker sections drew BLANK in the later one (duplicate identity in one `LazyVStack`) — `SearchPickerBrain.lines(_:)` names each line by section + option; pins `aRepeatedRowDrawsInEverySection` (red: 8 vs 10 / 5 vs 7 inked bands) + `theLinesAreNamedBySectionAndOption`. Same commits.
- **D-W3** ⌘L opened with the FIRST wing highlighted, not the current one (the field's focus write-back ran `type("")`) — an unchanged query is not typing; pin `theFieldsUnchangedWriteBackIsNotTyping` (red: 4 issues). `7cde8e92` · `97492c9f`.
- **D-W4** holding ⌘ and tapping L stepped, but RELEASING ⌘ never committed — `charactersIgnoringModifiers` raises on a flagsChanged event and the event loop swallowed it; traced by temporary (reverted) instrumentation + a standalone probe; `WingSwitcherKeys.key(for:)` reads characters for keyDown only; pin `theMonitorsRoadReadsARealReleaseAndARealTap` over REAL NSEvents (red by nature: the host faulted on the same exception and wedged). `11e1b19e` · `5f91491b`.
App-only (`SearchPicker.swift`, `WingSwitcherBrain.swift`, `WingSwitcherSheet.swift` + two test files); zero `Sources/`, `Sync/`, custody, editor seam, migration, `lockstepVersion`; zero trailers. **FABLE-OWED rows: none** — all four are chrome/keyboard behaviour restoring RULED behaviour (R-AIR-15, P-13nc-U4-4, U2's picker), no default's meaning. For the cold reviewer: the D-W1 fix makes every SOURCED picker panel open at full height (360 pt) even when its answer is short or empty — a deliberate trade for a popover that cannot grow.

**The taste list for the Opus UX-reviewer walk** (T-1…T-17, each with captures, in "The taste list" subsection below the legs): T-1 the Library selection panel clips + the bulk doors collapse to chevrons · T-2 MCP Settings… above Settings… · T-3 Approve… says "Grant access", no approve-without-sharing · T-4 a fresh sheet pre-picks the most recently edited book, here an ARCHIVED one · T-5 the in-note lock far right, small, faint · T-6 "Choose a note / choose a note" over "Grant read on “” always" · T-7 the window-hosted sheet in system blue · T-8/T-10 same-day untitled notes all "2026-10-11" in sheets, confirms, receipts AND Waiting · T-9 the sidebar's Starred list cuts its last row in half · T-11 a note ask's receipt says "in", the confirm "on" · T-12 the selection line omits Share · T-13 the receipt's Change…/Revoke › fade in seconds · T-14 the popover's see-through material · **T-15 the gone line renders off-screen when the pane sits at Waiting (undercuts SB-5)** · T-16 Terminal truncates the pane description ("…set up any…") · **T-17 one book's popover Revoke takes back the whole wing grant**; plus copy notes (lesson 1's double "way in"; the take card head truncating "claude-code · su…") and the AX observation (the setup text's outer element keeps the Claude Code command). The T-9…T-17 lines live in the leg rows that found them.

**Machine at start (12:50 MDT):** Accessibility + Screen Recording GRANTED to this host (a compiled probe:
`AXIsProcessTrusted() == true`, `CGPreflightScreenCaptureAccess() == true`; the host is the GUI-born tmux server);
the session UNLOCKED (`CGSSessionScreenIsLocked` absent, display awake); HID idle 81 min; NO Variorum instance
running (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty — her real-store app is not open); stage FREE.

**The live round's safety fact, found before it starts:** her `~/.claude.json` carries a USER-scope `variorum`
server pointing at `/Applications/Variorum.app/Contents/MacOS/variorum-mcp` (her real store). Any `claude -p` turn
in the scratch folder would load it beside the scratch `-s local` `variorum-dev`. The shim derives its socket from
its OWN bundle (`MCPDoor.socketDirectory` / `MCPSocketRoad`), so the Debug shim can only ever reach the dev
container — but her registration would reach her real store IF her app were running. **The belts:** (1) every turn
is gated on her app ABSENT immediately before it (`pgrep -f '/Applications/Variorum.app/Contents/MacOS'` — the
guard's own check 0); with her app closed that shim fails to connect at the turn's start (exactly as this
session's own `variorum` server shows `CONNECTION_CLOSED`); (2) every turn passes `--allowedTools
"mcp__variorum-dev"` only, so in `-p` mode any other server's tool call is denied; (3) her registration is NEVER
edited. If her app appears mid-walk, the live round STOPS.

### Legs (LIVE STATUS)

| # | Leg | Status |
|---|---|---|
| W-0 | Preflight: this plan whole (every unit's owed-walk list, U1-9 · U2-9 · U3-10 · U4-10 · U5-6, the STAGE B FIX RECORD's S-1/S-2, the CLOSE-OUT record's faces), `Tools/WalkKit/README.md` + `guard.sh`/`click.sh`/`keys.sh`, `SessionResiliencyProtocol`, the ScaleFixture stage/restore; machine checks above | DONE (this commit) |
| W-1 | Build the tip's Debug app (own DerivedData `App/Variorum/DerivedData/vx165-walk`); the A1 prestage copy + U2's scale seed (`Tools/ScaleFixture/stage.sh notes=520,long=40,books=160,shelves=9`) | **DONE** — `** BUILD SUCCEEDED **` (12:5x); stage `vx165-walk` claimed 12:55 (240 min); the A1 prestage copy taken and cmp-verified: `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261011T185742Z` (**THE END-OF-WALK RESTORE SOURCE** — `Tools/ScaleFixture/restore.sh` on it); the fixture minted (pid 66040, Study voice, 160 Fixture books on 9 shelves seen). **Found at the pane (capture `w2-settings-at-start-w0.png`): the dev store's server is ON with FOUR approved clients from earlier walks — claude-code (3 shared places), u3-walk, u2-walk, u1-walk.** A client's state persists BY NAME (`registerMCPClient` updates an existing row; `denyMCPClient` → `denied`, and a denied client reconnecting stays denied — `MCPGrantAuthority` `.refuse(.clientDenied)` — re-approved only from its row's Approve…), and Claude Code always names itself `claude-code`. **So on this store a real Claude Code client can never raise a CONNECTION REQUEST**, which live leg (2) needs, and the zero-client leg needs every approved client gone. **THE CALL (a walk-setup decision, not product):** the dev store's file is swapped, while no instance runs, for the dev store's OWN backup `Backups/variorum-backup-2026-10-09-105348-b831b428.sqlite` (2026-10-09 04:53 MDT — before 13n-b built the door, so no `mcp_*` rows; SAME key id `b831b428`, its key file `cmp`-IDENTICAL to the live `variorum-keys-b831b428ce0d67b1.json`, which stays untouched — no custody road runs), the fixture re-minted on it, and the walk then runs the TRUE first-run journey (switch off → on, the setup menu, a genuine request). The live `-wal`/`-shm` are removed first (restore.sh's own rule); the backup file itself is COPIED, never moved. At the end `restore.sh` puts the prestage set back byte-for-byte, so the swap leaves no trace. **SUPERSEDED (13:0x): the harness's safety classifier REFUSED the swap command (overwriting the dev store file) — respected, not routed around; nothing ran (the instance and the store files unchanged, re-checked).** **THE CALL, as walked instead:** the CURRENT store, through the product's own doors — the zero-client leg by Revoking every approved client in the pane (each a deny: every grant revoked, `denyMCPClient`); the real Claude Code client then re-approved from its client row's Approve… (the same approve sheet a request opens); and the Connection requests section's face shown by a SCRIPTED stdio client with a fresh self-declared name (one `initialize` line piped to the Debug shim — the Debug shim reaches only the dev container), approved or denied in the pane. Said plainly: on this store the request a REAL Claude Code client raises cannot be walked (its name is known). restore.sh at the end reverts every client and grant change |
| W-2 | ZERO approved clients: none of the share faces render (menus, bulk bar, Book Settings row, ⌥⌘A, icons, indicator) + the empty Activity line (U3-10, CB) | **WALKED (13:00–13:12, Study, light)** — the four approved clients Revoked in the pane (AX presses on each row's Revoke — no confirm; each row then reads "last seen yesterday · denied" with Approve…; Shared places "Nothing is shared."). Then, with the server ON and ZERO approved clients: the Edit menu lists no "Share This Note with AI" (read by AX: Undo · Redo · Undo/Redo Structural Change · Show the AI's Last Change · Cut …) ✓; the Bookcase row's own menu (ladrão) has no Share door (`w2-zero-bookmenu.png`, full screen) ✓ and the ladrão row lost its icon (no reach left) ✓; the Library note row's menu (Open · Open Beside · Star · Open in New Window · Rename… · Tags… · versions · Export · Archive · Delete Note…) has no "Share with AI…" ✓; the bulk bar over three ⌘-clicked notes reads Tag 3 notes · Untag 3 notes · Delete 3 notes… — no Share door (`w2-zero-bulkbar-w0.png`) ✓; Book Settings (ladrão) carries the Private row and NO grant row (`w2-zero-booksettings-w0.png`) ✓; the Private note "Fixture 0000 — on the river at dusk" opened in Write — the context bar holds only ← · book · →, no indicator and no lock (P-13nc-U3-7's gate) (`w2-zero-indicator-private-note-w0.png`) ✓. **NOT walkable on this store:** the empty Activity line (P-13nc-SB-7) — the store holds 136 Activity rows from earlier walks, and nothing clears the log (pinned at the Mac suite only). **Taste T-1 (for the UX reviewer, not redesigned):** with three notes selected at 1380 pt the Library's selection panel runs past the window's right edge — "3 notes selected — the Tag, Untag and Delete d…" and its Open button are clipped — and the bulk bar's three doors collapse to bare chevrons beside an empty segment (`w2-zero-bulkbar-w0.png`); U3's fourth door (Share N notes…) joins that crowded row when a client is approved. **Noted:** the app menu lists "MCP Settings…" ABOVE "Settings…" (U4's brief said under) — taste T-2 |
| W-3 | Live (1)+(2) + U5's setup leg: the setup menu's three choices pressed and copied; the Claude Code command registered `-s local` in a scratch folder; the JSON parsed; Codex not run (no `codex` on this Mac — `which codex` empty); the connection request approved in the pane; the advice stated back | **WALKED (13:12–13:16, Study)** — **the setup menu:** each choice pressed (AX) and "Copy setup command" pressed; the clipboard EQUALS the pane's shown text each time, each with its own receipt ("Copied. Run it in a terminal, then start a new Claude Code session." / "…new Codex session." / "Copied. Paste it into your client's MCP settings, then restart the client.") (`w3-setup-*`); the stdio line + the shim path shown; Debug's `variorum-dev` in all three. The JSON parses (`{"mcpServers": {"variorum-dev": {"command": <path>, "args": []}}}`, the path EXISTS). The Claude Code command with `-s user` → `-s local`, run in `scratchpad/walk/live/client`: "Added stdio MCP server variorum-dev … to local config"; `claude mcp get variorum-dev` → "Scope: Local config · Status: ✔ Connected". Codex NOT run (not installed). **The request face (a SCRIPTED client, the record's call):** one `initialize` line naming `walk-request` piped to the Debug shim → Settings ▸ MCP drew "Connection requests / Connection request — walk-request / First seen now. No access until approved. / Approve… · Deny" (`w3-request-w0.png`); its Approve… opened "Grant access — walk-request" (WHERE note · book · wing, the book pre-picked, Read, Once · Always + "“Until it disconnects” is offered while this client is connected.", the confirm with R-AIR-3's clause) (`w3-approve-sheet-w0.png`); approved with a once read grant (the request row left; Shared places "Fixture book 041 … · walk-request · read · once"). `initialize`'s answer carried the advice, 1,497 characters (`live/scripted-init.json`). **LIVE (1) — the advice arrives:** turn 1 (below) — the REAL Claude Code client quoted the advice VERBATIM while claude-code was still denied, and said it had no tools. **LIVE (2) — approved in the pane:** claude-code re-approved from its denied row's Approve… (said plainly: on this store a real Claude Code client cannot raise a NEW request — its name is known; the request face above is the scripted client's), in the same press the trait book "dream journal" found by typing "dream" in the picker (under its shelf "poetry") and granted; the confirm read her verbatim example "Grant read in “dream journal” always, including to future entries" (`w4-approve-dream-journal-w0.png`); Shared places "dream journal · book · claude-code · read · always". **Accessibility observation (not fixed, not clearly a defect):** for the Codex and JSON choices, the text block's OUTER AX element still reports the Claude Code command (the inner element and the screen are right) — a `.textSelection` backing element whose AX value does not refresh |
| W-4 | U1 + live (3): a journal-TRAIT book granted (R-AIR-3's confirm on screen) and read; a Home-wing READ grant — a daily-Journal entry and a Private note answer byte-equal to a made-up id, their unique words search to zero passages; the wing confirm's clause; the ask sheet's daily-Journal lead | **WALKED (13:2x–13:55, Study; live (3) PROVEN)** — the setup before the pause (W-3's live (2): the trait book "dream journal" granted read always with her verbatim confirm; Today's Entry minted the daily Journal "journal" + a NEW empty ⌘J entry "2026-10-11"; the Private PROBE note "marshlantern probe for the private fence" marked Private — the in-note lock "Private — click to change"; its row's Share with AI… offered Once only with "…is marked Private — it's only ever shared one ask at a time, so always isn't offered.", receipt "Shared “2026-10-11” with claude-code — read, once." + Change… · Revoke ›; the "walk vx143" fence-miss scare traced and dismissed — a dated note in no book). **After the resume, on the D-W1/D-W2-fixed build (pid 76084):** the ⌘J entry shared ONCE from the note picker's Recently edited ("2026-10-11 · daily Journal entry"; the sheet: Once only + "“2026-10-11” is a daily Journal entry — it's only ever shared one ask at a time, so always isn't offered."); a HOME-WING READ grant — **the wing confirm's clause on screen: "Grant read in “Home” always, including notes added later"** over U1's WHERE line "everything in Home except your daily Journal and anything Private, which always ask" (`w4-wing-confirm-*`). **LIVE TURN 2** (`live/turn-2.jsonl`): `list_notes` (limit 10) listed the Private probe `AF9F6FDA…` and the ⌘J entry `806FF3D9…` (their ONCE grants) beside "walk vx143" `EC0E7C0F…`; `search "unhurried"` found walk vx143 (not fenced yet — the CONTROL); `list_books` listed "dream journal" and NOT "journal" (the client said so); a dream-journal note read whole (R-AIR-1: a trait book's book grant reads); `read_note` on the two once-shared fenced notes returned their text ("marshlantern probe…"; the empty entry → no output) — SPENDING both once grants. Then "walk vx143" was filed into the daily Journal (book chip → Add to Book → "journal"; "in journal"), and **its in-note shared icon (shown just before: popover "Shared with / claude-code read · always / through the Home wing grant / Change… · Revoke", `w6-indicator-popover-*` — U3's why) LEFT the context bar at once** (fenced now). **LIVE TURN 3 — U1's byte-identity under a Home-wing READ grant** (`live/turn-3.jsonl`, compared byte-for-byte by script): `read_note` on the daily-Journal MEMBER (`EC0E7C0F…`), the ⌘J entry (`806FF3D9…`, its once spent), the Private note (`AF9F6FDA…`, its once spent) and a MADE-UP id `00000000-0000-4000-8000-000000000000` — **four answers byte-identical**: "That note isn't shared with this client, or doesn't exist. The author can share it from Variorum ▸ Settings ▸ MCP." (is_error); `export_note` on the member == on the made-up id, byte-identical; `search "unhurried"` (the word only the Journal member holds, found by turn 2 before the filing) → `{"passages":[],"truncated":false}`, byte-equal to `search "zzqqxxnowhere"`; `search "marshlantern"` (only the Private note) → the same. **The asks:** turn 3's reads of the three KNOWN fenced notes queued three asks silently (W-7 carries them). Remaining U1 item: the ask sheet's daily-Journal lead (opened at W-7). Observation (not a defect): the walk note's block carries a fan of three takes, so search answers per take and turn 2 listed the same block twice |
| W-5 | U2 on the scaled seed, both voices: a book found by typing, by shelf, a starred one; the two sherlocks told apart and the right one granted (landing in Shared places); a note from Recently edited; a fenced note's honest durations; the WHO row; L1 | **WALKED (Study; the picker legs first seen broken — D-W1/D-W2 — then re-walked on the fixed build, pid 76084)** — **find by typing:** "dream" → "dream journal · poetry · 4 notes · edited Jul 10" under its home shelf (`w5-picker-resting.png` before, typed after); **by shelf / starred:** the book picker opens on "by shelf · a–z", Recently edited (5 — P-13nc-U2-1) → Starred → each shelf in strip order; on the FIXED build Starred draws 010 · 039 · 068 · 097 and essays 001 · 010 · 019 with no blank slot (`w5-fixed-picker-resting.png`); **two (three) same-named books told apart:** "sherl" → "the adventures of sherlock holmes · Welcome" (the shelf rung) and the two on essays "made Oct 14, 2024" / "made Oct 17, 2024" (the made-day rung, never an ordinal) (`w5-sherlocks-typed.png`); **the right one granted:** the Oct 17 one, Once → the confirm "Grant read in “the adventures of sherlock holmes” (made Oct 17, 2024) once, including to future entries" → Shared places "the adventures of sherlock holmes · book · made Oct 17, 2024 — claude-code · read · once" (the WHERE line under the field drops the distinguisher — taste); **a note from Recently edited:** on the FIXED build the note picker lists Recently edited with snippets, days and fence words ("2026-10-11 · Private", "2026-10-11 · daily Journal entry") (`w5-fixed-note-picker.png`), and the daily-Journal entry was picked from it; **a fenced note's honest durations:** Once only + "“2026-10-11” is a daily Journal entry — it's only ever shared one ask at a time, so always isn't offered." (and the Private twin, W-4); **the WHO row:** the window-hosted sheet's "Who: claude-code ▾" (most recently granted first); **L1:** "A client names itself when it connects. Variorum can't verify the name: a grant lets whatever connects under that name do what you granted." under Clients (W-2's dump, every capture of the pane); with two wings the note leg grows "Notes in Home ▾" (U2's call). Terminal + dark of both pickers at W-10 |
| W-6 | U3 + live (5): three notes shared from the Library in one act → one pane row → one Revoke; a book shared from its row menu and from Book Settings; the icon's hover + popover; the in-note indicator's why + a Private note's lock; ⌥⌘A with history, without, already reaching; the receipt's Change… and Revoke | **WALKED (14:45–15:05, Study; live (5) PROVEN)** — **with an approved client the doors render:** the Library row menu carries "Share with AI…" after Tags…; the bulk bar over three ⌘-clicked notes carries "Share 3 notes with AI…" (collapsed to a chevron like its neighbours — T-1) (`w6-bulkbar-with-client-w0.png`); the Bookcase's own book menu carries "Share with AI…" after Book Settings…; Book Settings carries the grant row. **Three notes in ONE act:** the bulk sheet "These 3 notes — a escola · lesson 1 — questions · abertura", WHO claude-code, Suggest · Always → "Grant suggest on 3 notes always" → receipt "Shared 3 notes with claude-code — read and suggest, always." + Change… · Revoke › → Settings ▸ MCP showed **ONE row** "3 notes · notes — claude-code · read and suggest · always — a escola · lesson 1 — questions · abertura" with ONE Revoke (`w6-pane-grouped-row-*`), and that ONE Revoke took the act away whole. **A book from its ROW MENU:** "Fixture book 008" → the sheet pre-filled on the book → "Grant suggest in “Fixture book 008 — the long way home” always, including to future entries" → receipt "Shared “Fixture book 008 — the long way home” with claude-code — read and suggest, always."; **from BOOK SETTINGS:** "Fixture book 021"'s grant row "Shared with claude-code (read) · Share…" (the wing's reach) → Share… opened the grant sheet NESTED over Book Settings (`w6-booksettings-*`) → "Grant read in “Fixture book 021 — an argument with myself” once, including to future entries"; both landed in Shared places. **The Bookcase icon:** hover → tooltip "Shared with claude-code (read and suggest) — click for details" (`w6-bookcase-icon-hover.png`); click → popover "Shared with — claude-code · read and suggest · always — Change… · Revoke" (`w6-bookcase-icon-popover.png`); every Home book wears the icon under the wing grant; "journal" (the daily Journal) and the two gatherings wear none. **The in-note indicator:** "o museu" → popover "Shared with — claude-code read and suggest · once — Change… · Revoke" (its own grant, the highest reach); its Revoke → "Revoked.", the indicator falling back to "(read)" — the wing's reach. **LIVE (5) — ⌥⌘A:** in "o museu" with history (claude-code's newest grant = the suggest act, revoked rows counting — D1), not connected → "Shared “o museu” with claude-code — read and suggest, once." + Change… · Revoke › (`w6-optcmdA-grant-*`); ⌥⌘A again → the refusal "claude-code already reaches this note (read and suggest)." (`w6-optcmdA-already-*`); the receipt's **Change…** (R-AIR-4) → "Change access — claude-code / Confirming replaces the grant you opened this from." pre-filled note "o museu" · Suggest · Once (+ "Notes in Home ▾" — two wings now) (`w6-receipt-change-sheet-*`) → Read → "Grant read on “o museu” once" → "Changed “o museu” for claude-code — read, once." + Change… · Revoke ›, the indicator now "(read)" — the LOWERED rung landed (P-13nc-U3-3's replace); **Revoke ›** on ⌥⌘A's receipt (on the Private note, which the wing cannot reach: "Shared “2026-10-11” with claude-code — read, once." — never always on a fenced note) → "Revoked.". (One Revoke › press missed because the quiet receipt had already FADED — the doors live seconds — taste T-13.) **NOT walkable, said:** ⌥⌘A WITHOUT history — every approval mints a grant (T-3), so no approved client can exist with no grant row; the sheet road (no history ⇒ WHERE = this note) stays pinned (`MCPShareFacesTests`). **Taste:** T-12 — the selection panel's line still says "the Tag, Untag and Delete doors above act on all of them" with Share among them; T-14 — the Bookcase popover's translucent material lets the row text beneath show through behind "Shared with" |
| W-7 | U4 + live (4): an ask arriving while typing in a note (nothing appears but the mark), answered from the mark; another from Waiting; ⌥⌘, landing at Waiting (S-2: fresh Settings window and one already open); ⌘L typed filter, held-⌘ L cycle, Esc (S-1: a fast ⌘L-L-release); an ask answered from a switcher row; the masthead cycling on BOTH mastheads + the ▾ menu's acts; a denied client's marks leaving; the shortcuts pane + ⌘/ | **WALKED (13:55–14:45, Study; live (4) PROVEN; three defects found → D-W3/D-W4 FIXED, D-W1 re-walked)** — **LIVE (4), asks wait:** turn 3 ran while I TYPED into "o museu" in Write (three words landed: "…arte antiga. the guard sat"); afterwards only the main window existed — NO sheet, nothing self-presented (`w7-typing-during-asks-w0.png`); the asks waited quietly. **⌥⌘, from INSIDE the editor** opened Settings at MCP scrolled to **Waiting** — three rows "claude-code asks to read “2026-10-11”" with ages and Answer… (`w7-optcmdcomma-from-editor-w0.png`); **S-2's second case:** Settings already open on General → ⌥⌘, moved it to MCP at Waiting. **Answered from the MARK:** the daily-Journal member's in-note indicator wore the pending mark ("claude-code asks to read here — press to answer.", also beside the bottom bar's note ▾, `w7-indicator-pending-*`); pressing it opened THAT ask's sheet with **U1's daily-Journal lead "A daily Journal entry. Your daily Journal is only ever shared one ask at a time."** and Once · Don't allow (`w7-ask-sheet-journal-w0.png`); Once → receipt "Allowed claude-code: read in “2026-10-11” once.", the mark gone, the shared icon in its place. **Answered from WAITING:** the next row's Answer… opened the Private note's ask ("Marked Private. Private notes are only ever shared one ask at a time.") → Don't allow → it left quietly. **A denied client's marks leave:** the scripted walk-request (a full stdio session: initialize · initialized · `read_note` on the Private probe) heard the one answer and its ask waited; the Private probe's LIBRARY ROW wore "walk-request asks to read here — press to answer." (`w7-library-row-mark-*`); Revoke on walk-request's client row → Waiting gone, the row mark gone, Activity "walk-request was refused read_note on “2026-10-11”". (Observed: a relaunch empties the in-memory ask queue — by design, the wire re-asks.) **⌘L:** with ONE wing "Switch Wing…" is grey (SB-2); the masthead ▾ menu lists "Wings — each a separate library · Home · Snippets is the one room every wing shares. · New Wing…" (`w7-wing-menu-onewing.png`); New Wing… → "studio" (current). With two wings the masthead WORD became the cycling door ("Next wing: “Home” — or ⌘L to choose one") beside its own ▾: **clicked on the Bookcase masthead → "Now in Home."; on the Library masthead → "Now in “studio”."** (`w7-masthead-cycle-*`). ⌘L typed filter "hom" + ⏎ → "Now in Home." (`w7-cmdL-typed-*`); Esc closes. **D-W3 found here** (the switcher opened washing the FIRST wing, not the current one) — FIXED, re-walked: opens on "studio · current", ⏎ closes. **D-W4 found here** (held ⌘ + L stepped but letting go never committed) — FIXED, re-walked: ⌘ down · L · L · ⌘ up → "Now in Home.", closed (`w7-cmdL-held-commit-fixed-*`). **S-1 (a fast ⌘L-L-release before the sheet is key, 30–60 ms apart):** switched to the next wing ("Now in “studio”.") and closed — the ⌘-tab flick works. **⌘/** lists the MCP group — ⌥⌘, "MCP settings — opens at Waiting…", ⌥⌘A "share the note you're in with the client you granted last — until it disconnects if it's connected, else once (never always)", ⌥⌘O, ⌥⌘Z "undo a client's change — the Edit menu names the client (“Undo ‹name›'s take”)", the mark by ROLE "a small mark beside a note, book or wing — a client's ask waits there…" — and ⌘L "switch wing — type a few letters and ⏎, or hold ⌘ and tap L to step, release to go; clicking the wing's name … steps to the next one" (`w7-helper-*`); **Settings ▸ Shortcuts** lists ⌥⌘, · ⌥⌘A · ⌘L (the one source). **NOT walkable, said:** an ask answered from a SWITCHER ROW and the masthead word's wing-ask mark — a WING ask needs a client to name a wing it holds no grant in, and no tool exposes a wing id it cannot reach (U6's `show_in_app` wing target is unbuilt); they stay pinned + captured (U4-10). **Taste:** T-10 — three Waiting rows read identically "claude-code asks to read “2026-10-11”" (T-8's case on the ask road); T-11 — a note ask's receipt says "read in “X”" where the sheet's confirm says "on" |
| W-8 | Live (6): a client's write → the Edit menu's undo names the client | **WALKED (15:05–15:10; live (6) PROVEN)** — **LIVE TURN 4** (`live/turn-4.jsonl`): under the row-menu book grant (suggest · always on "Fixture book 008") the client listed the book's first note "Fixture 0007 — the long way home", read it `with_ids`, and `add_take` on its first block (`9CA26ECA…`) with "The river ran high and brown that evening, and nobody said a word about it." (label "walk") → `{"block_id":"9CA26ECA…","note_id":"6A7C0E74…","take_id":"9F116F46…"}`. **The app:** the Edit menu then read "Undo, Redo, **Undo claude-code's take**, Redo Structural Change, Show the AI's Last Change, Share This Note with AI, …"; **⌥⌘O** opened the note in Takes on that block with the client's card "choose claude-code · su[ggested · walk]" holding the take (`w8-optcmdO-w0.png`); **⌥⌘Z** removed it ("takes · 2" → "takes · 1") and the Edit menu then offered "**Redo claude-code's take**" — the client named on both sides. (The write's quiet receipt with its "Open ›" door had faded during the ~20-s turn — not captured; ⌥⌘O is its keyboard road, walked.) Taste: the take card's head truncates the client's label to "claude-code · su…" at the card's width |
| W-9 | U5's chapter on screen (both voices) + the close-out faces (the gone line, the members sheet's "1 note", Waiting leaving a dead place, the wing mark leaving, the helper's and the guide's "Undo ‹name›'s take", the pane's description + toggle sentence) | **WALKED (15:10–15:35, Study)** — **THE RE-SEED ROAD (the closeout's — U5-7):** Help ▸ Restore Tutorial… → the alert "Restore the tutorial? This replaces the tutorial with a fresh copy: every note tagged exactly “tutorial”, every pool named “tutorial scraps”, and every book named “the field guide” are deleted and re-seeded. It also sets up the Welcome shelf…" (`w9-restore-tutorial-confirm-*`) → Replace → the guide now "48 notes · 11 ch", its LAST chapter "AI & the MCP door" after "keeping it private" (P-13nc-U5-1) with the six lessons in order. **THE CHAPTER ON SCREEN:** each lesson opened in Read (`w9-lesson-{1…6}-study-w0.png`) and its rendered text read back; every checkable sentence matches what this walk did: lesson 1 (SB-1's privacy words; O-4's provider-neutral line), lesson 2 (the three setup choices, the connection request, Approve…/Deny, Change…/Revoke, the honest name limit — W-3), lesson 3 (the four rungs; "until it disconnects … (offered while it's connected)"; the open book), lesson 4 (the daily Journal + Private reached only "through a grant on that one note, once or until it disconnects. Always is never offered for them." — W-4's sheets; "a ⌘J entry keeps asking even if you later file it in another book"; snippets closed; "something it can't reach looks exactly like something that isn't there" — W-4's byte-identity), lesson 5 (Share with AI… on rows, "Share 3 notes with AI…", Book Settings' Share…, ⌥⌘A's rule and its Change… / Revoke ›, one row + one Revoke — W-6), lesson 6 (the icon's hover/click/why, the in-note icon or lock, Activity "the calls clients made recently", asks wait at a small mark and in Waiting, ⌥⌘,, the four answers, "Undo ‹name›'s take", ⌥⌘O — W-7/W-8). Copy note for her pass: lesson 1's first block still says "way in" twice ("The way in is MCP … Variorum calls its way in the door"). **THE CLOSE-OUT FACES:** the pane's description "The local MCP server: which clients may connect, what each may read and change, the asks waiting for your answer, and how to set up any MCP client." and the toggle sentence "…so MCP clients can read and write here…" on screen (W-2's captures); ⌘/'s "Undo ‹name›'s take" (W-7) and lesson 6's; **R2-3's inert row:** "dream journal" marked Private in Book Settings (its grant row disappears — a Private book draws none, F-21) → Settings ▸ MCP: claude-code "6 shared places · 1 inert" and, under "all 7 ›", "dream journal · book · inert — the book is marked Private, which always asks" (`w9-all-shared-inert-*`); a real client's `list_notes` on that book answered "That book isn't shared with this client, or doesn't exist." (F-7's one answer — turn 5); **R2-1 (a) THE GONE LINE:** turn 5's `read_note` on the Private probe queued an ask; with Settings ▸ MCP ON SCREEN showing it under Waiting, the note was deleted in the main window (note ▾ ▸ Delete Note… → "The note goes to the Trash for 30 days…" → Delete) — the Waiting row STAYED (the recorded residue); its Answer… → the row left and the caption said **"“2026-10-11” is gone, so claude-code's ask was let go."** (`w9-gone-line-scrolledup-w0.png`); **R2-2 THE MEMBERS SHEET:** four notes shared in one act → the grouped row named three "and 1 more ›" → the sheet "4 notes shared in one act", each member with its own Revoke → 3 → 2 → **"1 note shared in one act"** → the last revoked → the sheet CLOSED (`w9-members-sheet-*`). **NOT walkable, said:** the empty Activity line (158 rows on this store); the masthead's wing mark leaving when its wing dies (no wing ask raisable — W-7); a BOOK ask leaving by the watch (a client's `list_notes` on a fenced book raised no ask — asks come from the write roads; no book ask could be raised without a write grant on a known fenced book). **Taste T-15 (for the UX reviewer — it undercuts SB-5 on the ⌥⌘, road):** the gone line renders in the server section at the TOP of the pane; when the pane is scrolled down to Waiting (where ⌥⌘, lands it) the line is OFF-SCREEN at the moment of her press — she sees the row vanish with no visible word (`w9-gone-line-w0.png` at the press vs `-scrolledup` after) |
| W-10 | Dark appearance on the changed faces | **WALKED (15:35–15:55) — TERMINAL light, then DARK in Terminal and Study; restored to Study + Follow system** — **Terminal, light:** the MCP pane top + bottom (`w10-terminal-pane-*`), the grant sheet with both FIXED pickers (`w10-terminal-book-picker.png` — Starred draws 010 · 039 · 068 · 097, the repeated 039 drawn; `w10-terminal-note-picker.png` — Recently edited with its rows: D-W1/D-W2 hold in the second voice), the Bookcase's poetry shelf (the icons beside the mono names; the now-Private "dream journal" with none), ⌘L ("› Home · current" — D-W3 holds; the foot lowercased by the voice's idiom). **Dark (Settings ▸ General ▸ Appearance ▸ Dark, a LOCAL preference):** the pane in Terminal and in Study (`w10-dark-*-pane-*` — the black room), both pickers (`w10-dark-book-picker.png`, `w10-dark-note-picker.png` — legible, rows present), the Bookcase icons (the accent reads on black) and the icon's popover with the WHY "claude-code · read · always — through the Home wing grant — Change… · Revoke" (`w10-dark-icon-popover.png`). **Taste:** T-16 — in TERMINAL the pane's two-line description truncates to "…and how to set up any…", losing O-4's "any MCP client" (Study fits; `w10-terminal-pane-top-w0.png`); T-17 — a BOOK's popover offers Revoke on the WIDER grant that reaches it ("through the Home wing grant"), so one press on one book's popover takes back a whole wing's grant (P-13nc-U3-6 — the why line names it, but it is a far-reaching press from a small surface); T-14 seen again in dark (the popover's material shows the rows through it) |
| W-11 | Cleanup: `claude mcp remove -s local`; the dev instance quit by identity; the dev store restored (`restore.sh`); voice/appearance as found; the stage released | **DONE (15:55–16:05)** — the final Mac run on the closing tree FIRST (stage held, the dev instance quit by identity before it): **200 tests / 21 suites `** TEST SUCCEEDED **`**, the 2 skips the gated capture harnesses by design (every suite naming `SearchPicker*`/`WingSwitcher*` + the picker hosts + the MCP face suites: `AddToBookMintTests`, `BookcaseCensusMenuTests`, `CapabilityRegistryTests`, `MCPGrantSheetTests`, `RuleEditorMakeTagTests`, `SearchPickerBrainTests`, `SearchPickerPanelGeometryTests`, `WingBookMoveDoorTests`, `WingSwitcherChordTests`, `WingSwitcherTests`, `OutflowChooserTests`, `RuleEditorTests`, `MembershipChoiceTests`, `NotePickerSourceTests`, `MCPPaneTests`, `MCPShareFacesTests`, `MCPAskAndReceiptTests`, `MCPAsksWaitTests`, `HelperCurrencyTests` + the two harnesses); no `Sources/` line changed, so the headless package is untouched. Then: `claude mcp remove variorum-dev -s local` ("Removed MCP server variorum-dev from local config"; the scratch project's servers `{}`; her USER-scope `variorum` → `/Applications/…/variorum-mcp` and `linear-server` intact, never edited); no Variorum instance (`pgrep` empty); **the dev store restored** by `Tools/ScaleFixture/restore.sh` from `…/safety-copies/scale-prestage-20261011T185742Z` — "Restored (verified)", every file `cmp`-identical, the sizes the start's exactly (8,671,232 · 32,768 · 803,432) — so every client, grant, wing, note and the re-seeded guide this walk made is gone; the dev app's `appearanceChoice` deleted (absent at the start); the voice was set back to Study before the restore (the store's own setting is the prestage's anyway); the clipboard emptied (empty at the start); the stage released ("STAGE FREE"). The live round's transcripts copied from the session scratchpad to `notes/plans/13n-c-screens/walk/live/` (gitignored): `turn-{1…5}.prompt.txt` + `.jsonl`, `scripted-init.json`, `scripted-ask.jsonl`, `setup-*.txt`, the red/final test logs, `flagsprobe.swift` |
| D-W1 | **DEFECT (bug-class, found walking W-4/W-5): the grant sheet's NOTE picker never shows its rows** — in BOTH hosts (Settings ▸ MCP's sheet `w5-note-leg-empty-*`/`w5-note-picker-open*.png`, and the window sheet from the Library row's Share with AI… `w5-note-picker-window-*`): the popover opens to "Find a note" over a 2-pt list (AX: `AXScrollBar (972,593 19x2)`), no Recently edited, no rows, no empty sentence, before AND after typing. **TRACED:** (1) the source DOES answer — Return on the empty query picked "2026-10-11, Private" (the most recently edited note; `submit()` reads `sourced.first`), so the rows exist; (2) the popover sizes ONCE, from its content's FIRST frame, and never follows a later size change — shown on the synchronous BOOK picker: opened at full height, typing "dream" left one row in an unshrunk ~360-pt popover (`w5-bookpicker-dream.png`); (3) the sourced panel's first frame is empty by construction (`SearchPickerPanel`: `sourced = []`, `loaded = false` until `runSource()` lands; the list is `ScrollView { LazyVStack }.frame(maxHeight: 360)`, whose ideal height is its content's — ~0), so the popover sizes to the header + 2 pt and the rows that land after are clipped away. The U2 harness drew `SearchPickerPanel` DIRECTLY (not inside a popover), which is why no capture or pin saw it. (Also seen: "marshlantern" matched nothing — correct: `notePickerNotes` matches titles and day keys only and the probe note is untitled.) **Fix shape:** a sourced panel reserves its list's height from the first frame. Pin: red-on-old by revert. | **FIXED** (pins `e0224a68` RED-first, fix this commit) — `SearchPickerPanel`'s list is `.frame(minHeight: source != nil ? Self.listHeight : nil, maxHeight: Self.listHeight)`: a SOURCED panel takes its full room (360) from the first frame; a panel given its rows up front still sizes to them (the book picker unchanged). **Pin** `SearchPickerPanelGeometryTests.aSourcedPanelsFirstFrameReservesItsList` (the hosted panel's first-frame `fittingSize`, its feed not yet answered, both voices) — **RED on the pre-fix tree** (the pins committed and run BEFORE the fix; the tree differed from the old only by naming the same 360 `listHeight`): "the first frame is 50.0 pt tall" ×2 voices; GREEN after; guard `anArrangedPanelStillSizesToItsRows` green both sides. Re-walked at W-5 |
| D-W2 | **DEFECT (bug-class): a book shown in TWO sections of the book picker renders as a BLANK slot in its later section** — at rest, "Fixture book 039" (Recently edited AND starred) is drawn under Recently edited and leaves an empty 37-pt slot in Starred; "Fixture book 010" (starred, shelf essays) is drawn under Starred and leaves an empty slot in essays (AX: Starred rows at y 550 then 624 — one row missing; essays 894 then 968) (`w5-picker-resting.png`). **TRACED:** `SearchPickerPanel` nests `ForEach(sections)` → `ForEach(section.options)` inside ONE `LazyVStack`, identifying rows by the bare `option.id` (the book id); a book in a quick section AND its home section puts one identity twice in the lazy stack, and the later one renders empty. Her mandate's very case ("sort by shelf … favorites"): every starred book vanishes from its shelf section, every recently-edited starred book from Starred. **Fix shape:** rows identified by section + option. Pin: red-on-old by revert. | **FIXED** (pins `e0224a68` RED-first, fix this commit) — the panel draws ONE flat list, `SearchPickerBrain.lines(_:)` (pure): each section's title then its rows, every line named `section␟row␟option` — a repeated option is a distinct line in each section. **Pins** `SearchPickerPanelGeometryTests.aRepeatedRowDrawsInEverySection` (the panel RENDERED in a window and its inked text bands counted, a book in three sections vs a control of the same shape whose repeats carry distinct ids) — **RED on the pre-fix tree**: "drew 8 bands where … draws 10" (Study) and "5 … 7" (Terminal) — two blank slots for the two repeats, exactly the walked defect; GREEN after; + the pure `theLinesAreNamedBySectionAndOption` (unique ids, 9 lines, the book a line in each of its sections). **The host suites, unedited and green:** 107 tests / 13 suites (`SearchPickerPanelGeometryTests` 4, `SearchPickerBrainTests`, `AddToBookMintTests`, `MCPGrantSheetTests`, `RuleEditorMakeTagTests`, `OutflowChooserTests`, `RuleEditorTests`, `MembershipChoiceTests`, `MCPPaneTests`, `MCPShareFacesTests`, `MCPAskAndReceiptTests`, `NotePickerSourceTests`; the gated U2 capture harness skipped by design). Stage `vx165-walk`; the walk instance quit by identity before the runs. Chrome geometry, no default's meaning — no FABLE-OWED row. Re-walked at W-5 |
| D-W3 | **DEFECT (bug-class, found walking W-7): ⌘L opens with the FIRST wing highlighted, not the current one** — P-13nc-U4-4 (ruled + pinned on the brain): "opening highlights the CURRENT wing … committing the current wing closes". Walked: with "studio" current, the switcher opened (by ⌘L AND by View ▸ Switch Wing… with no keystroke at all — `w7-cmdL-open-*`, `w7-cmdL-viaMenu-studio-*`) washing "Home" (row 1) while marking "studio current"; with Home current it looked right only because Home IS row 1. So Return straight after ⌘L SWITCHES to the first wing instead of closing, and a held-⌘ cycle starts from row 1. **TRACED:** the brain is right (`WingSwitcherBrain.init` highlights `currentID`; `opensWithTheCurrentWingHighlighted` green); the sheet's field is `TextField(text: Binding(get: { model.brain.query }, set: { model.type($0) }))` and `.task { fieldFocused = true }` — as the field takes focus it writes its unchanged empty text back through the binding, and `type("")` sets `highlight = visible.first` (and clears `cycling`). **Fix shape:** an unchanged query is not typing — `type(_:)` ignores it (pure, in the brain). Pin: red-on-old. | **FIXED** (pin `7cde8e92` RED-first, fix `97492c9f`) — `WingSwitcherBrain.type(_:)` ignores an UNCHANGED query. **Pin** `WingSwitcherChordTests.theFieldsUnchangedWriteBackIsNotTyping` — **RED on the pre-fix tree: 4 issues** (the highlight left the current wing; Return switched instead of closing; a write-back mid-cycle disarmed it ×2), the suite's other 13 green; GREEN after (26/3 with `WingSwitcherTests` + the picker geometry suite). **Re-walked live:** with "studio" current, ⌘L opened washing "studio · current" (`w7-cmdL-fixed-open-*`), and Return straight after CLOSED it, switching nothing. No FABLE-OWED row |
| D-W4 | **DEFECT (bug-class, found walking W-7 on the D-W3-fixed build): holding ⌘ and tapping L steps the highlight, but RELEASING ⌘ never commits** — R-AIR-15 ("release/return commits"), the brain's `commandReleased` (pinned green). Walked twice (the release in a separate script, then in the same script): ⌘ down · L (opens on the current wing — D-W3 fixed) · L (the highlight steps to Home — `w7-cmdL-held-cycled-*`) · ⌘ up → the switcher STAYS open, nothing switched. **TRACED by temporary instrumentation (two NSLog lines, uncommitted, REVERTED — `git checkout --`, `git diff` empty):** the monitor RECEIVES ⌘'s release (`type=12 flags=0`, `event.window` === the sheet's window — the scoping is right) but the handler is NEVER called for it (only the tapL reached it: `key=tapL … cycling=0`); the monitor's guard builds `classify(type:characters: event.charactersIgnoringModifiers, …)` for EVERY event, and `-[NSEvent charactersIgnoringModifiers]` RAISES on a flagsChanged event — proven standalone (`scratchpad/walk/flagsprobe.swift`: "NSInternalInconsistencyException … Invalid message sent to event "NSEvent: type=FlagsChanged …""); inside the app the event loop swallows the throw, so the release does nothing, silently. The U4 pins call the pure `classify` with hand-built arguments (`characters: nil` for a release), so no pin ever touched the accessor. (The app's only monitor matching flagsChanged — swept.) **Fix shape:** the event → key mapping moves into ONE function that reads characters only for a keyDown, the monitor calls it. **Pin:** that function fed REAL NSEvents (built from CGEvents, as the probe was); red-on-old by revert is, by nature, the test host DYING on the same throw the app swallowed. | **FIXED** (pin `11e1b19e` RED-first behind the extracted `WingSwitcherKeys.key(for:)`, fix this commit) — `key(for:)` reads characters for a keyDown only; the monitor calls it. **Pin** `WingSwitcherChordTests.theMonitorsRoadReadsARealReleaseAndARealTap` (REAL NSEvents from CGEvents: ⌘'s release → `.commandUp`, ⌘ going down → nil, a real ⌘L → `.tapL`, Esc → `.escape`). **RED-ON-OLD, by nature a host fault** (the pin run on the pre-fix road, committed first): the pin STARTED and never finished — the test host logged `[HIExceptions] FAULT: NSInternalInconsistencyException: Invalid message sent to event "NSEvent: type=FlagsChanged …"` at the pin's `key(for: release)` and wedged (8+ min; the run and its host ended by PID, mine — `test-dw4-red.log`), the suite's other 13 tests green; a second accidental run on the same road (an Edit rejected before the fix landed) wedged identically. **GREEN after:** 62 tests / 5 suites (`WingSwitcherChordTests` 15, `WingSwitcherTests`, `CapabilityRegistryTests`, `HelperCurrencyTests`, `SearchPickerPanelGeometryTests`). Chrome/keyboard, no default's meaning — no FABLE-OWED row. Re-walked below (W-7) |
| W-X | WALKS CLOSED banner | DONE (this commit) — atop this record |

### The taste list for the Opus UX-reviewer walk (recorded with captures; NOT redesigned)

- **T-1** — with three notes selected at 1380 pt, the Library's selection panel runs past the window's right edge
  (its line and Open button clipped) and the bulk bar's three doors collapse to bare chevrons (`w2-zero-bulkbar-w0.png`);
  U3's fourth door joins that row once a client is approved.
- **T-2** — the app menu lists "MCP Settings…" ABOVE "Settings…" (U4's brief said under).
- **T-3** — a request's Approve… opens a sheet titled "Grant access — <client>": the word approve never appears, and there
  is no road to approve without sharing something (`w3-approve-sheet-w0.png`).
- **T-4** — a fresh grant sheet pre-picks the most recently edited book — here an ARCHIVED one ("Fixture book 041 …
  · archived"), where walk-request's once grant then landed; a first approval defaults to a place she never chose.
- **T-5** — the in-note lock sits at the far trailing end of the context bar, small and faint, ~600 pt from the title
  (`w4-private-note-indicator-w0.png`).
- **T-6** — the empty note leg reads "Choose a note" over "choose a note" above a disabled "Grant read on “” always"
  (`w5-note-leg-empty-w0.png`).
- **T-7** — the window-hosted grant sheet draws system-blue radios/segments where the Settings-hosted one draws the
  voice's muted accent (`w5-bookpicker-*.png` vs `w4-approve-dream-journal-w0.png`).
- **T-8** — two untitled same-day notes are both "2026-10-11" in the sheet's WHERE, its confirm and the receipt — nothing
  tells them apart (the note leg's ruled answer is snippet + day, which these faces do not carry).

**ORCHESTRATOR ADDENDUM (the walker's handback at her pause — "pause before your next step for a second"; landed
repo-first by the orchestrator. The walker's W-3/W-4 details and T-3…T-8 were not yet in its record.)**
- **W-3 (partial):**
  - The setup menu's three choices were pressed and copied, each clipboard equal to the pane's text with its own
    receipt.
  - The JSON parses and its command path exists.
  - The Claude Code command (`-s local` in the scratch folder) reports Connected. Codex is not installed, so its command
    was not run.
  - A scripted client "walk-request" raised a real connection request, approved with a once read grant.
  - `initialize` carries the 1,497-character advice.
- **Live turn 1:** a real Claude Code client quoted the advice verbatim while denied and said it had no tools
  (`scratchpad/walk/live/turn-1.jsonl`).
- **Live (2):** claude-code was re-approved from its denied row's Approve…, and the trait book "dream journal" was found
  by typing and granted. The confirm read "Grant read in “dream journal” always, including to future entries".
- **W-4 (partial):**
  - Today's Entry minted the daily Journal and a ⌘J entry.
  - A Private probe note took the in-note lock. Shared from its Library row, it was offered Once only, with the why. The
    receipt carried Change… and Revoke ›.
  - An apparent fence miss on "walk vx143" was traced and dismissed (a dated note in no book, so Always is correct).
  - Paused while filing it into the Journal.
- **DEFECTS found by the walk, not yet fixed:**
  - **D-W1:** the grant sheet's note picker never shows its rows (popover over a 2-pt list). In both hosts, SwiftUI
    sizes the popover from the first frame, and a sourced `SearchPickerPanel`'s first frame is empty. Fix shape: reserve
    the list's height from the first frame. Pin: the first-frame fitting height of a hosted panel, red-on-old.
  - **D-W2:** a book listed in two picker sections renders as a blank slot in the later one. Rows are identified by bare
    `option.id` inside one `LazyVStack`. Fix: identify rows by section plus option, red-on-old pin. This is her "sort by
    shelf … favorites" case.
- **Taste list for the UX reviewer:**
  - **T-1:** the 3-note selection panel is clipped and the bulk doors collapse to chevrons.
  - **T-2:** "MCP Settings…" sits above "Settings…".
  - **T-3:** Approve… opens "Grant access", and there is no way to approve without sharing.
  - **T-4:** a fresh sheet defaults to the most recently edited book, even an archived one.
  - **T-5:** the in-note lock is far right, small and faint.
  - **T-6:** the empty note leg reads "Choose a note / choose a note" over a disabled "Grant read on “” always".
  - **T-7:** the window-hosted sheet uses system blue where the Settings one uses the voice's accent.
  - **T-8:** two untitled same-day notes are both "2026-10-11" in the sheet, the confirm and the receipt.
  - **AX:** the Codex/JSON choices' outer accessibility value still reads the Claude Code command.
- **Not walked yet:** the rest of W-4 (the ⌘J once-grant, the byte-identity and zero-passage probes, the Home-wing grant,
  the ask's daily-Journal lead), W-5 (re-walk after D-W1/D-W2), and W-6…W-10.
- **Machine state left live at the pause:**
  - the stage claim `vx165-walk` (to ~16:55);
  - the dev-store Debug app running;
  - the scratch `-s local` registration present;
  - the dev store not yet restored from `Backups/safety-copies/scale-prestage-20261011T185742Z`.
- Her real store, `/Applications` and her user-scope registration were never touched.

### The live round's turns (a REAL Claude Code 2.1.296 client, `claude -p --model sonnet --allowedTools mcp__variorum-dev`, the scratch `-s local` registration; each gated on her app absent — it was, every turn; full stream-json in `notes/plans/13n-c-screens/walk/live/`)

- **Turn 1** (claude-code DENIED on this store): *"Do not call any tools. The MCP server named variorum-dev sent you instructions when you connected. Quote those instructions back to me as exactly as you can, then in one sentence say whether this server has given you any tools right now."* → it quoted the 1,497-character advice verbatim ("Variorum is a writing app; this server is the door to its library, on the author's Mac, open only while Variorum runs. …") and: "No, variorum-dev has given me no tools right now. None appear in my tool list, and a separate server named "variorum" failed to connect with the error "Variorum must be open: its MCP server is not running."" ($0.058)
- **Turn 2** (approved; read always on the trait book; once read on the Private probe and the ⌘J entry; a Home-wing READ grant): list the newest 10 notes, search "unhurried", list books, read a dream-journal note, read the two once-shared notes, report ids → "IDS marsh=AF9F6FDA-6B8B-4B28-A8F7-7D660AAA0AC0 entry=806FF3D9-69B8-4484-B35E-B7D25F2DFFBE walk=EC0E7C0F-5CE2-4865-B2CB-EFA074B03AF0 dream=6AE3DECD-4C88-495C-B25D-6178915C6C58 / No book named exactly "journal" appeared in list_books." (the dream-journal note read whole; the Private probe's text "marshlantern probe for the private fence"; the empty entry no output) ($0.166)
- **Turn 3** (after "walk vx143" was filed into the daily Journal; both once grants spent), nine calls verbatim: `read_note` × 4 (Journal member, ⌘J entry, Private note, `00000000-0000-4000-8000-000000000000`) and `export_note` × 2 (member, made-up) → every one **"That note isn't shared with this client, or doesn't exist. The author can share it from Variorum ▸ Settings ▸ MCP."** (byte-identical, compared by script); `search` "unhurried" / "marshlantern" / "zzqqxxnowhere" → **`{"passages":[],"truncated":false}`** × 3. Typed in "o museu" while it ran; three asks waited. ($0.068)
- **Turn 4** (suggest · always on "Fixture book 008"): `list_notes` → "Fixture 0007 — the long way home"; `read_note with_ids`; `add_take` on block `9CA26ECA…` "The river ran high and brown that evening, and nobody said a word about it." (label "walk") → `{"block_id":"9CA26ECA-BD32-4BA8-B596-5EC697409032","note_id":"6A7C0E74-F6BA-4CC4-AA3D-4570CF9D5AE8","take_id":"9F116F46-1888-49DF-BA6E-97E48B70FB30"}` → the Edit menu "Undo claude-code's take". ($0.082)
- **Turn 5** ("dream journal" marked Private): `read_note` on the Private probe → the one note answer (an ask queued); `list_notes` on the now-Private book → **"That book isn't shared with this client, or doesn't exist. The author can share it from Variorum ▸ Settings ▸ MCP."** (F-7's one book answer; no ask raised by this read). ($0.063)
- **Scripted stdio client "walk-request"** (one `initialize` line, then a full session): the connection request face; approved with a once grant; later its `read_note` on the Private probe → the one answer + an ask; Revoked → its marks left.

---

## THE U6 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U6 implementer for Variorum phase 13n-c, working in `~/dev/variorum-vx-165` on branch
`vx-165-13n-c` (NEVER the main checkout). Commits say `Part of VX-165` (and `Part of VX-160` /
`Part of VX-158` where they land those tools), NO attribution trailer, push after every commit.
`notes/SessionResiliencyProtocol.md` binds you: LIVE STATUS in the "U6 UNIT RECORD" section below
from your FIRST commit, foreground waits only (a `grep -q … && break; sleep 5` poll loop), no
subagents.

**Read first, whole, never delegated:** this plan file TOP TO BOTTOM — §3 U6 is your scope,
verbatim; the sitting record (R-AIR-2's sweep, R-AIR-12); the U1–U5 records + the Stage B fix
records (the fence derivation, `MCPGrantRule.reach`, the ask road, the neutrality and setup-copy
pins you must keep green); the walker's HELD-WALKS RECORD (whatever it fixed is under you). Code:
`Sources/VariorumMCP/MCPWriteTools.swift`, `MCPToolCatalog.swift`, `MCPSession.swift`
(`instructions` — her RULED bound is 2,000, the constant already moved; ~500 characters of room),
`MCPShowTool.swift` + `MCPShowRule`, `Sources/VariorumCore/Operations/` (the existing cross-wing
move door — grep `moveNoteToWing` / `MoveToWing`; its tag adoption and severed-membership rules are
HERS, R-13ia-1/R-13id-6 — you wrap, never re-derive), `Operations+MCPGrants.swift`,
`Queries/MCPGrantQueries.swift` (`decideWing`, the fence fragments), `Domain/MCPGrantRule.swift`.

**What U6 builds — §3 U6 verbatim, with these concretions:**
1. **`move_note_to_wing`** over her existing door, ONE transaction: source decided at EDIT through
   the ordinary rule; destination through `decideWing` at WRITE NEW on that wing; BOTH re-decided
   INSIDE the act's transaction; once grants spent atomically (both spend, or neither). Tag
   adoption mirrors her door (T1). ONE client-named undo entry with an exact-row inverse (wing
   back for the note and its versions, severed memberships revived on their exact stamp,
   applications re-pointed back; minted tags stay as vocabulary) plus its exact-row redo (U1).
   Refusals byte-for-byte hers; `move_block`'s cross-wing refusal stays. A fenced note moves only
   under a per-ask note grant.
2. **`show_in_app` gains the `wing` target:** `MCPShowRule` unchanged; decided at read with
   `decideWing`; never spends a once grant; "Now in …" names the client; refuses honestly behind
   (R-13nb-23/26g untouched).
3. **R-AIR-12 — gatherings as read facts under a wing grant:** `list_books` lists the wing's
   gatherings (kind gathering); their assembly readable with EVERY member filtered through the
   per-note fence — a fenced member never lists, never counts (the honest-count rule, the one
   uniform answer). Gatherings stay NON-targets: no grant names one; a book/note grant does not
   reach a gathering. Consume the ONE fence derivation — never a parallel SQL fence.
4. **Rung proofs grown as the ritual,** mutation-checked: read/suggest/write-new cannot move a
   note across wings; a book grant cannot name a destination; a fenced note moves only per-ask.
5. **The docs catch up (D-2):** the guide chapter's withheld wing-gatherings sentence lands (the
   U5 record names it) with its truth pin; `MCPSession.instructions` gains the gatherings clause
   (and the move if it fits) under the 2,000 bound; every sentence true of the build; the
   neutrality, setup-copy-fence and O-4 pins stay green.
**FABLE-OWED rows at the moment** (the grant boundary, the new inverse over a cross-library move,
the gathering reach) — the combined fable ladder that follows you is expected to discharge them,
but the ledger discipline holds regardless.

**Must NOT touch:** `Sync/`, custody/keychain, the editor seam, migrations, `lockstepVersion`, the
real store, `/Applications`, the fence derivation (U1's — consume it).

**Acceptance:** `VariorumMCPTests` + core state-transition pins headless, then the whole headless
package; Mac suites over every changed type under a HELD `Tools/stage` claim, `skipped:` read.
**The REAL Claude Code live round in her sweep's shape** (the Pro is unlocked): register the tip's
shim `-s local` in a scratch folder under the session scratchpad ONLY (never `-s user`; remove it
after), dev store only, under the stage claim — two wing grants; several notes moved Home → a
second wing; ONE ⌥⌘Z walks one move back with memberships and tags; a finished book's member
refused in her words; `show_in_app` to a wing frontmost and refused behind; a gathering read under
a wing grant with a fenced member absent. Record every client turn's exact text. VX-132: a hung
MCP test run is killed and rerun. Captures in `notes/plans/13n-c-screens/u6/` (gitignored).

**Forks / close:** as the earlier briefs — propose before building beyond the rulings;
PROVISIONAL-and-log; STOP for gating; the UNIT CLOSED banner (not-done, PROVISIONALs, where a cold
reviewer should look first, self-assessment).

## U6 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

Implementer: Opus (`claude-opus-5-5`), fresh session, 2026-10-11 (~16:20 MDT). Worktree `~/dev/variorum-vx-165`,
branch `vx-165-13n-c`, from tip `9fb0a401`. **No revert is in flight unless a line below says so.** The Mac is
UNLOCKED at start (`CGSSessionScreenIsLocked` absent), no Variorum instance (`pgrep` empty), stage FREE.

### Pieces

| # | Piece | Status |
|---|---|---|
| U6-0 | Preflight read whole (this plan top to bottom incl. every unit record, the Stage B records, the HELD-WALKS RECORD; the sitting record R-AIR-2/-9/-12; the brief §8/§10; mockups §7/§9; the 13n-b AF-6/-7/-9/-10/-11, P-13nb-U2-3/-4/-6/-8, U3-4/-5/-7, R-13nb-23; `SessionResiliencyProtocol`) + the code traces below | DONE (this commit) |
| U6-1 | `move_note_to_wing` — core: the MCP road over her `moveNoteToWing` (R1 decided twice, once grants atomic, T1 mirrored, U1's exact-row inverse + redo, ONE client-named entry) + state-transition pins | DONE (this commit) — her door's body moved VERBATIM into `moveNoteToWing(_ db:_:to:)` (the public door calls it; `date.now` read at the same point — byte-identical: `WingMoveTests`, `BookWingMoveTests`, `WingContentsMoveTests`, `WingUndoRevivalTests`, `WingRevivalTests` + the MCP core neighbours 78/10 green UNEDITED); `Operations+MCPWingMove.swift`: `mcpMoveNoteToWing` (guard first, her act, the exact rows read before/after inside the transaction, ONE entry `.wingMove` = "claude-code's wing move"), `revertMCPWingMove` / `reapplyMCPWingMove` (the stamps each direction matches on held per entry — the act's/redo's forward stamp, the undo's backward stamp), the divergence refusal `OperationError.wingMoveChangedSince` (P-13nc-U6-3), obsolete = quiet. R-AIR-12's core: `MCPGrantRule.decideGathering` (pure, read, never consuming — `decideWing`'s read on the gathering's wing; a fenced one the `.fenced` decision) + `Queries.mcpGatheringFacts` (ONE statement with `mcpBookFacts` — `mcpReadingFacts(kind:)`, the same two fence fragments). Pins `MCPWingMoveActsTests` **10/1 green**: the act = her rows + one entry; undo/redo replay the EXACT rows (same ids, row snapshots equal, zero fresh rows, a minted tag stays, the ping-pong); a guard refusal writes and registers nothing; her four refusals; joined-a-book / took-a-tag since → refused, entry kept, resolved → lands; moved on by her door / trashed → obsolete, quiet; a finished book takes its row back, a sealed one does not; the redo re-runs her frozen refusal; `decideGathering`'s table; the facts never cross kinds and fence on the book's fragment |
| U6-2 | `move_note_to_wing` — the wire: the tool, the catalog, the answer (left books · tags adopted/made · where it landed), the ask on a short side, refusals byte-for-byte hers; `move_block`'s cross-wing refusal kept | DONE (this commit) — `MCPToolCatalog.moveNoteToWing` (edit rung, every scope kind — PROVISIONAL **P-13nc-U6-1**: the mockup's "name provisional" kept; listed under any edit grant so a short destination raises the wing's ask); `MCPWriteTools+WingMove.swift`: the snapshot decides the NOTE at edit then the WING at write new (`decideWing`), ONE ask, source first; the act behind `guardWingMove` (both re-decided on one standing read inside the transaction, the once grants of both sides spent as one union); the answer `{moved, note_id, wing_id, landed: "the Pool of “X”", left_books: [{book_id, name?}], tags: {adopted, made}}` — a left book NAMED only where the client can read it (PROVISIONAL **P-13nc-U6-2**); the receipt targets the DESTINATION wing (a sweep's moves coalesce), `detail` = the note's title, `leftBooks` (a new optional `MCPWriteReceipt` field), "Open ›" = the note; her frozen-book sentence through a new `MCPHostHooks.wingMoveFrozenWords` where the client can read the book, else the op's table words (PROVISIONAL **P-13nc-U6-4**); `move_block`'s cross-wing refusal untouched. Pins `MCPWingMoveServerTests` **7/1 green**: read/suggest/write new on the note's wing refuse at the note (+ its ask at edit); edit on the note with no destination grant, a BOOK grant in the destination, or read there refuse at the wing (+ its ask at write new); a Private note answers byte-equal to a made-up id under a wing edit grant and moves only under a per-ask once note grant (spent; the always grant not); a refused act (a finished book) spends NEITHER once grant, a landed one BOTH; the answer + receipt; her words vs the table's by readability; one undo walks it back with its book and its own tag row; a revocation landing after the snapshot is caught inside the act. **Ritual (justified edits, annotated):** `MCPServerTests.everyDeclaredToolIsHandled…` (the edit set gains the tool) and `MCPWriteServerTests.aSuggestGrantProvablyCannotModify…` (the suggest proof TRIES the new door — refused at the rung). Whole `VariorumMCPTests` **89 / 13 green** (82/12 + 7/1) |
| U6-3 | `show_in_app` gains the `wing` target (decided at read with `decideWing`; never spends; "Now in …" names the client) | IN-PROGRESS — **server half DONE (this commit):** `MCPShowTarget.wing(wingID:name:shownBy:)` (the wing's name and the asking client ride the signal, P-4); `show_in_app`'s parse takes `target: "wing"` + `wing_id` ("" is Home — the one legal empty id); decided at READ through `decideWing` (a wing grant on it at any rung, or the open book), never spending; a wing that is not live answers the one answer after an allowed decision; the catalog's description + enum + `wing_id`. Pin `MCPWingReachServerTests.showInAppSwitchesToAWingOnlyUnderWingLevelReachAndNeverSpends` green beside `MCPShowServerTests` (6/2). **App half NEXT** (with U6's app faces): `MCPNavigator` delivers `.wing` as her switcher does + the receipt naming the client |
| U6-4 | R-AIR-12 — gatherings as read facts under a wing grant (`list_books` kind gathering; the assembly through the per-note fence; non-targets) | NOT-STARTED |
| U6-5 | Rung proofs grown as the ritual + mutation checks | NOT-STARTED |
| U6-6 | The docs catch up (the guide's withheld gatherings sentence + the move; the advice's clause under 2,000) + truth pins | NOT-STARTED |
| U6-7 | Headless finals (`swift build` + core + `VariorumMCPTests` + workbook) | NOT-STARTED |
| U6-8 | Mac suites over every changed type (held stage) | NOT-STARTED |
| U6-9 | THE REAL Claude Code live round in her sweep's shape (dev store, `-s local` scratch registration, removed after) → `notes/plans/13n-c-screens/u6/` | NOT-STARTED |
| U6-10 | UNIT CLOSED banner | NOT-STARTED |

### Traces (made before any code — the hallucination guard)

- **T-U6-1 — her door, traced (`Operations+WingMove.swift`):** `moveNoteToWing` is ONE `database.write`: `livePost`,
  `requireLiveWing` (`wingNotFound`), `sameEffectiveWing` (`postAlreadyInWing`), then the ONE primitive `relocateNote`
  (keeping: []) — every live `reading_post` row of the note in a live reading SEVERED (members AND arrivals; a MEMBER row
  in a sealed/finished book refuses `readingSealed`/`lockedReading` BEFORE any write), every live `post_tag` on the note
  and `block_tag` on its PLACED blocks re-pointed by path (old row tombstoned on the act's stamp, a fresh row on the
  adopted-or-minted destination tag — a row copy, no intake), the note and its versions' `wing_id` := destination. NO undo
  entry. Her DOOR refuses a frozen book BEFORE the act with `WingCopy.frozen(title, book:)` ("“X” is in “B”, which is
  finished — reopen it (or unseal it) before moving the note to another wing." — the mockup §9's sentence); that sentence
  lives in the Mac module, which the server package cannot see; the op's own throw speaks the generic table words.
- **T-U6-2 — the wire today:** no tool moves a note across wings; `move_block` refuses a cross-wing move in the act's
  transaction (`otherWingWords`, P-13nb-U3-5 — KEPT). `show_in_app` has four targets (note · takes · lens · book), no
  wing. `list_books` reads `r.kind = 'book'` only; `list_notes(book_id:)`, `search(book_id:)` and `show_in_app` book go
  through `mcpBookFacts`, which is books-only by design (a grant TARGET's facts), so a gathering id answers the one
  not-shared answer; `search`'s `passes` drops a gathering's own name passage the same way. Gatherings assemble through
  the ONE membership function (`Queries.gatheringMembership`, read by `assembleReading` and the search's `.book(id)`
  scope) — within their wing, living notes only.
- **T-U6-3 — R1's two decisions:** the SOURCE through `decide` on the note at EDIT (any note/book/wing grant reaching it;
  the fence in the rule — a fenced note only by a per-ask note grant); the DESTINATION through `decideWing` at WRITE NEW
  (only a wing grant on THAT wing; a book grant in it can never name where a bookless note lands; the open book is read
  only). Re-decided inside the act's own write transaction by a guard on ONE standing read, the once grants of both sides
  stamped there as a union (`guardBookAndNote`'s shape) — so both spend or neither, and a refused act spends nothing. The
  snapshot decides first and raises ONE ask, source first (the note at edit), else the wing at write new.
- **T-U6-4 — U1's exact-row inverse, and why the act must REPORT its rows:** `relocateNote` returns only the severed
  readings; the inverse needs the exact rows. Wrapped, never re-derived: the act reads the note's live membership rows and
  live applications (the note + its placed blocks) and its versions' wings BEFORE and AFTER her primitive, inside the one
  transaction — severed = live-before-dead-after rows, removed applications = live-before-dead-after, added = live-after
  and not before. Her `moveNoteToWing` body moves verbatim into an in-transaction twin (`moveNoteToWing(_ db:…)`) that the
  public door and the MCP act both call — her door byte-identical. **Undo:** the added rows tombstoned, the removed rows
  revived (their tag live, their block still placed in the note, no live twin), the note + versions back to their stored
  source `wing_id`, the severed rows revived on the stamp that severed them (book live, in the note's wing —
  `membershipRevivalStaysInOneWing`, no live pair row, a sealed book only for a sealed note — `restoreContainer`'s letter;
  a FINISHED book takes its row back, R-13id-3), the purge intents voided, the revival pass (`enforceOwnershipAfterRevival`).
  **Redo:** the mirror on the same rows (the frozen check re-run first — her door's refusal). **Divergence (the edge the
  ruling did not see):** a note that has since joined a book or taken a tag in the wing it would LEAVE cannot be put back
  without splitting a book or a vocabulary across wings — the replay REFUSES as a resolvable refusal that keeps the entry
  (`OperationError.wingMoveChangedSince`, words in the Mac table); a note moved on by her door, trashed, or whose other
  wing has died makes the entry OBSOLETE (quiet — the 13i-d `membershipRevivalStaysInOneWing` letter). PROVISIONAL
  P-13nc-U6-3.
- **T-U6-5 — the frozen refusal in her words:** the server cannot import `WingCopy`; a new `MCPHostHooks.wingMoveFrozenWords`
  the app wires to `WingCopy.frozen` (ONE source), spoken when the op refuses a frozen member AND the client can READ that
  book (names stay with grants — AF-10 (f)); otherwise the op table's own words through `refusalWords`. PROVISIONAL
  P-13nc-U6-4.
- **T-U6-6 — R-AIR-12's reach, decided by the RULE:** a pure `MCPGrantRule.decideGathering` (always READ, never
  consuming): a fenced gathering (a stale 'daily' marker or a Private stamp arriving by sync — no op mints either on one)
  matches nothing; otherwise `decideWing`'s read on the gathering's wing — a live wing grant there, or the open book. A
  note or book grant never reaches one; no ask is ever raised for one (it can be no grant's scope). Facts from
  `Queries.mcpGatheringFacts` on the SAME two fence fragments as `mcpBookFacts`/`mcpFencedBookIDs`. Every member decided
  one by one through `decide` on `mcpNoteFacts` (the honest count: a fenced member never lists, never counts). The read
  tools that take a book id for READING accept a gathering (list_books · list_notes · search · show_in_app's book target);
  every write tool keeps refusing it (`mcpBookFacts` nil — the one answer).
- **T-U6-7 — `show_in_app`'s wing target:** decided at READ through `decideWing` (never spending); a wing that is not live
  answers the one answer after an allowed decision (no oracle — the decision already implies reach). Delivered as her
  switcher's own act (`WingState.switchTo` — wings scope listings, editors never close, 17y (f)) with the receipt naming the
  client (mockup §7: "Now in “variorum” — claude-code showed you this wing."); the target carries the wing's name and the
  client's (a signal, P-4).
- **T-U6-8 — the docs:** the guide's lesson 3 "where" card gains the gatherings clause (U5's T-U5-7 hand-off) and lesson 4's
  wing card the move; the advice gains one clause each under the 2,000 bound; the tool descriptions say gatherings and the
  wing target. The neutrality, setup-fence and O-4 pins stay green.
- **D-U6 — zero `Sync/`, schema, migration, custody, editor seam, `lockstepVersion`.** The fence derivation is consumed
  (`mcpNoteFacts` for every member; `mcpGatheringFacts` reads the same two fragments as `mcpBookFacts`).
