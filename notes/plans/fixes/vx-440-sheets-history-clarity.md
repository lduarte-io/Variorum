# VX-440 — Sheets & history clarity: books, Block History, versions

**STATUS: OPEN — kicked off 2026-10-28 (overnight, `/architect-phase`).**
Ticket: **VX-440** (Umbrella) · Project: v1 release readiness · Branch: `vx-440-sheets-history-clarity` ·
Worktree: `~/dev/variorum-vx-440` (the Pro) · PR: `VX-440: …` (merge commit only).
Orchestrator: Fable (session name `VX-440`). Stage: via **oct27coordinator** — REQUEST → READY → GO protocol
(its 2026-10-28 message, §ENVIRONMENT below); **no session in this run ever claims the stage itself.**
No release without her word.

**MEMBERS — BY THE SUB-ISSUE LISTING at kickoff (her rule, the VX-548 lesson), 7 + 3 riders seated at the sitting:**

| # | Ticket | What | Batch |
|---|---|---|---|
| 1 | VX-130 (Feature) | Compare preloaded with a previous version beside the note, no promoting | 1 |
| 2 | VX-437 (Bug, Suspected) | Saved versions DO show in Compare; unmarking one PROMOTES after a confirm (redirected 2026-10-28; live-check the scout's finding first) | 1 |
| 3 | VX-432 (Improvement, High) | Open a saved version full-size without promoting | 1 |
| 4 | VX-431 (Improvement) | Block History clarity: read a whole commit · restore highlights where it landed · bring back as a take | 2 |
| 5 | VX-331 (Bug, Confirmed) — RIDER, her sitting word | restoreCost's deleted-takes count has no 30-day window while Block History's listing does | 2 |
| 6 | VX-244 (Bug, Confirmed) — RIDER, her sitting word | "Show take ▸" renders on cells whose column can never pick | 2 |
| 7 | VX-611 (Bug, Wording) | A gathering's kind word: row menu "Delete Book…" + the Trash row's "book" | 3 |
| 8 | VX-616 (Improvement) | Remove the gathering navigator's "+ new chapter" button (RULED) | 3 |
| 9 | VX-189 (Feature, MCP) | A gathering's own "Shared with" doors (Book Settings row + row menu Share with AI…) | 3 |
| 10 | VX-356 (Improvement, Suspected) — RIDER, her sitting word | Book Panel in Study: collapsed chapter row shows no open-note marker | 3 |

**NOT a member:** VX-216 (book & gathering menus/settings clarity pass) — hers, under VX-551; read for design
context only. **VX-315 offered and NOT taken** (stays open, unowned by this run).

**Parallel:** VX-648 (launch week) overlaps on Book Settings + book/gathering row menus (its VX-641 Private row,
VX-645/646 navigator); vx-601 on Takes & editor. **Closeouts serialize; the second merger merges main IN
(never rewrites a pushed branch) and re-runs the overlapping suites before its merge ask.**

---

## HER KICKOFF (2026-10-28, verbatim-faithful)

"Taste-heavy: bring me the design calls at a sitting before building them. My rulings are on the tickets."
Suggested batches (taken as the batch plan): (1) versions & Compare as ONE design — VX-130 + VX-437 ("live-check
the scout's finding first") + VX-432; (2) Block History — VX-431; (3) gathering faces — VX-611, VX-616, VX-189
("MCPSpec in full first"). "VX-648 runs in parallel and also touches the book navigator and Book Settings …
closeouts serialize, the second merger merges main in and re-runs the overlap. Stage, merges and any walk per
the standing rules and whichever coordinator is live; no release without my word. contact oct27coordinator for
your walk / testing needs. Rule provisionally overnight on what you are able to - I'm around for the start of
your run if you have any messages off the start and then will send a goodnight message."

## THE BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — adopted verbatim per the architect-phase skill)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope, per-mode
  availability rule, its doors, and its refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered
  door is declared.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly — or delivers the operations layer's real refusal. A door that can never act in its
  context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component that every pane composes;
  "what text does this pane show, and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Exactly one live pane; the live pane is buffer-authoritative;
  read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** No listener derives business state or availability from a
  broadcast; no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature:
  write the design memo, get her rulings, build to the memo.
- **P-6 — The tutorial is the executable spec (R113).** Any change that breaks a tutorial step is a regression
  by definition.
- **P-7 — Find bugs before she does.** Proactive harnesses per layer; red-on-old stays absolute.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer; overlays, never
  rendering attributes; chrome `fixedSize` texts carry a `lineLimit`; `Theme/VoiceControls.swift` is THE chrome
  vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing concerns splits by concern.

(The skill's application notes bind too: the registry's scope is the ROUTED vocabulary grown incrementally,
inline-only doors declare `.surface`; the full-document editor and the pane surface stay two deliberate kinds
consulting the one authority; storage-coupled code stays feature-side; equality-gated sinks deliver at wire
time and overlay refreshes trigger on every input axis.)

## THE SITTING RECORD (2026-10-28, kickoff — she was present at the start; answers via the question tool)

- **R-440-1 (Compare doors — VX-130/437's one design):** "Rows + one-press door" (the recommended option).
  Each row in Note ▸ Versions gets a **"Compare with now"** act seating THAT version beside the live note, AND
  the note menus/⌘K get **"Compare with Latest Version"** — one press seats the newest version. Versions appear
  in Compare's auto-fill (ruled on VX-437: "never filtered out of auto-fill"); unmarking a saved version there
  promotes it after a confirm.
- **R-440-2 (the version's full-size face — VX-432):** "Back + Promote" (recommended). The full-size version
  opens read-only in the note surface on Read's calm page with an identity band — "A saved version of ‹title› ·
  ‹date›" — carrying **"Back to the note"** and **"Promote to a regular note…"** (same confirm as Compare's
  unmark). The mode row and version-minting (⌘⇧S) are suppressed on it.
- **R-440-3 (reading a whole commit — VX-431):** "Row expands + full-text sheet" (recommended). Pressing a
  commit row expands a longer preview in the pane; a "read in full" door opens a sheet with the whole text
  (scrollable, selectable) with **Restore** and **"Bring back as a take"** at its foot.
- **R-440-4 (riders):** VX-331, VX-244 and VX-356 seated; VX-315 offered and not taken.

## HER RULINGS ALREADY ON THE TICKETS (verbatim, gathered at kickoff)

- **VX-437 (2026-10-28, the redirect + her confirmation "i like it. sounds good on both."):** "doesn't it seem
  wrong for the older version of a note to NOT show up in compare?? that seems like exactly what you would want
  from compare. i also think that you should be allowed to stop counting it as a version but i think that should
  mean that it is automatically promoted." → (1) saved versions DO appear in Compare — never filtered out of
  auto-fill; (2) the mark/unmark button on a saved version stays, but unmarking PROMOTES the version — the
  existing `promoteNoteVersion` ("unarchive, unseal, the original's tags applied, ends as Duplicate with Tags
  does") — with a confirm saying it becomes a regular note. **The live check the scout asked for still comes
  first** (scout 2026-10-18: `Queries.versionPeerPosts` follows `version_of` edges without filtering version
  history or archived containers, so auto-fill may already seat a saved version wearing "unmark"; unmark deletes
  the edge, which DECLASSIFIES — it leaks onto Archived and Restore/Promote throw `notVersionHistory`).
- **VX-432 (the 2026-10-18 pricing scout, on the ticket):** the bare door is `router.adopt(.post(versionID),
  mode: .read)` (ShellRouter's VX-303 ModeLanding; archived notes open this way already); the honest version
  adds (1) the identity band (a version keeps the live note's title — V6), with the mode switcher/inspector
  doors suppressed (⌘⇧S works on sealed notes, so she could otherwise mint versions of a version), and (2) a
  per-note-memory answer (postMode.‹id›, the Read face key, CurrentBlockMemory, back/forward — nothing cleans
  them when the version dies).
- **VX-431 (her 2026-10-18 + 2026-10-27):** the screen is cluttered and wordy "in the same way that the books
  and gathering menus are"; a long commit can't be read in full; restoring a long one — "it's unclear which part
  came back (briefly highlight at least where it starts)"; offer "bring back as a take" so a commit can be read
  *[removed for publication]*
  history button - I like having no words at the top and I want it to stay that way."
- **VX-616 (RULED 2026-10-28):** "agree with removing the button." Remove the gathering navigator foot's
  "+ new chapter" (BookView ~:942–975 — the door ACTS today via `openBindOffer(followUp: .createChapter)`, but
  she finds it misleading); "Bind into a Book…" stays in the row menu (`.bindIntoBook`); the hand-drag teaching
  offer stays; the foot keeps "+ new note" (VX-217).
- **VX-611 (confirmed in code 2026-10-28, on the ticket):** `BookRowMenu.swift:211` draws the `.deleteBook`
  verb "Delete Book…" for books AND gatherings while the confirm already says Delete Gathering; the VX-620
  walker added the context-menu sighting (W-4). Fix: a gathering's row says "Delete Gathering…" — **keep P-1:
  one capability, its verb chosen by the reading's kind** — and the Trash names a deleted gathering's kind
  "gathering". Text-only.
- **VX-189 (REPURPOSED 2026-10-28 at her word):** "gatherings should have shared with doors — you can file a
  ticket for this or repurpose VX-189 for it." The reach rule itself shipped at VX-549; what remains is the
  gathering's OWN doors: Book Settings' "Shared with" row + the row menu's "Share with AI…" (the grant sheet
  opened ON the gathering, through the P-1 registry's `.mcpShareBook` family), plus whatever Change…/Revoke the
  book's row carries. This is VX-548's MB-18 offer. **The VX-184 gathering provisionals P-VX185-2 (a gathering's
  Book Settings shows no sharing line) — ratified-for-now "until gatherings get their own changes" — is the line
  this build supersedes**; P-VX196-2's refusal-sentence split stays as is. MCPSpec delta at closeout.

## THE DESIGN

### Batch 1 — versions & Compare as ONE design (VX-130 · VX-437 · VX-432)

**First act — the live check (VX-437):** trace and PIN what Compare's auto-fill does with a saved version
today (`CompareBoardView.swift:409-413`, `Lineage.swift:206-229`, `versionPeerPosts`) and what unmark does to
one (`CompareBoardView.swift:1354-1358`). Expected per the scout: versions already seat, unmark declassifies.
Whatever the finding, the new contract below is built; the pin documents the old hole red-on-old where the
defect is real (the declassify leak), or the finding is recorded hollow if it is not reachable.

**The contract:**
1. **Auto-fill:** saved versions are peers in Compare's auto-fill — never filtered out. Version columns show
   the version's DATE via derived display (V6 — no title mutation) and arrive sealed → read-only.
2. **Unmark on a version-history peer = PROMOTE with a confirm** ("this stops counting it as a version — it
   becomes a regular note", exact copy PROVISIONAL P-440-5): runs `promoteNoteVersion`, never a bare edge
   delete. Unmark on an ordinary `version_of` peer is unchanged. The declassify road (edge deleted, version
   leaks onto Archived, Restore/Promote throw `notVersionHistory`) becomes unreachable — pinned.
3. **The doors (R-440-1):** Note ▸ Versions rows gain "Compare with now" — the existing landing road
   (`pendingCompareLanding = CompareLanding(postID: live, peerIDs: [versionID])` + `requestMode(.compare)`,
   MCPNavigator's own); the note ▾ menu, File-menu family and ⌘K gain "Compare with Latest Version" (newest
   version seated; the act renders only while the note HAS a saved version — P-2). Declared in the capability
   registry (P-1).
4. **Full-size (R-440-2, VX-432):** a Versions row's "Open full size" opens the version in the note detail,
   Read's calm page, with the identity band ("A saved version of ‹title› · ‹date›" · "Back to the note" ·
   "Promote to a regular note…" with the same confirm as unmark). Mode row suppressed; ⌘⇧S refuses/absent on a
   version; the band is the one navigation.
5. **Wire parity:** `show_in_app` keeps refusing version ids (the scout's "keep that refusal unless she rules
   otherwise" — kept; noted for the closeout bundle). No MCP change in this batch.

**PROVISIONALs (batch 1):**
- **P-440-1:** a version's full-size open writes NO per-note memories (no postMode, no Read face key, no place
  memory — it always opens at the start, read-only), answering the scout's memory-pollution point by writing
  nothing rather than cleaning later; back/forward may carry the visit.
- **P-440-2:** auto-fill peer order — saved versions newest-first AFTER ordinary `version_of` peers (the live
  pair is the comparison she asked for; versions are the extra columns). Cheap to re-order at her word.
- **P-440-5:** the promote confirm's copy (sentence case, no shouty caps): title "Stop counting this as a
  version?", body "It becomes a regular note — unarchived, unsealed, wearing the note's current tags.", confirm
  "Promote". The band's door and Compare's unmark share it.

### Batch 2 — Block History (VX-431 · VX-331 · VX-244)

**The clarity pass** (her complaint: "cluttered and wordy"), keeping her ruled structure (all takes sectioned,
the focused take expanded; the four regions; Restore per row; no purge door):
1. **Rows calm at rest:** a commit row's rest state is one line — clock · name (when named) · kind glyph —
   with the current multi-line lead gone from rest; pressing the row expands a longer capped preview in place.
2. **Read in full (R-440-3):** the expanded row carries "read in full" opening a SHEET: the commit's whole text,
   scrollable and selectable (read-cheap `Text`, never an editor — P3), titled by the commit's name else
   "Commit · ‹date›", with **Restore** and **Bring back as a take** at its foot.
3. **Explainers behind (i):** the region meaning lines (the savepoints explainer and siblings) adopt the
   `ExplainerLine` idiom (one line, whole text behind an (i)) — the MCP pane's precedent; region headers carry
   counts; empty regions stay hidden as today.
4. **Restore says where it landed:** after a confirmed Restore (pane or sheet), the writing surface lands at
   the restored take's block and briefly washes it — at least its start (her words). Mechanism: the existing
   landing/jump road plus a short-lived overlay wash (the changing-block wash family), an OVERLAY and never a
   rendering attribute (P-8). If this would require new TextKit machinery, the fallback is landing + selecting
   the block's first words (the search-landing road) — the implementer proposes before building that half if
   the fork is real (the architect rules).
5. **Bring back as a take:** mints a new take on the block — text = the commit's text, parent = the commit's
   variant, at the fan's end, never chosen, never locked; refuses under a seal; mirrors `branchVariant`'s
   touch/churn and undo posture exactly (verify in code and mirror). **P-440-3 (PROVISIONAL):** the new take's
   label is the commit's message when it has one, else none. **P-440-4 (PROVISIONAL):** a quiet receipt names
   the act ("Brought back as a take"); no structural-undo entry if `branchVariant` has none (delete the take by
   hand is the road back).
6. **VX-331:** `restoreCost`'s deleted-takes count gains the 30-day window the listing already has — red-on-old
   pin.
7. **VX-244:** trace first. Lenses' Chosen column's "Show take ▸" always refuses → not rendered there (P-2).
   The Takes article arm "acts silently" → make the act visible or not render, per the trace. Pin per the
   mechanism found; hollow halves recorded, not fixed.

**Screenshots of the pane + sheet land in her morning bundle** (the declutter's final verdict is hers; the pass
is built provisionally per the above).

### Batch 3 — gathering faces (VX-611 · VX-616 · VX-189 · VX-356)

1. **VX-611:** the `.deleteBook` verb chosen by the reading's kind — "Delete Gathering…" on a gathering's row
   menu and context menu; the Trash row's kind word reads "gathering". One capability (P-1); text-only;
   red-on-old pins on the rendered words.
2. **VX-616:** the gathering navigator foot drops "+ new chapter" (and its hover copy); books keep theirs;
   "+ new note" stays; "Bind into a Book…" stays in the row menu; the hand-drag teaching offer stays. Registry
   declaration updated so the registry walk stays green.
3. **VX-189:** the gathering's own place doors, built to BOOK PARITY: Book Settings gains the "Shared with"
   row on a gathering (superseding P-VX185-2's no-sharing-line); the gathering's row menu gains "Share with
   AI…"; both open THE one grant sheet ON the gathering (the `.mcpShareBook` family — nothing replaced, the
   WHERE pre-picked); every Shared-with row's Change…/Revoke behavior carries unchanged (they already handle
   gatherings as places since VX-549). No wire change, no new grant semantics, no new reach — faces only.
   `MCPShareFacesTests`' "place doors unbuilt" messages flip to assertions. The shared-icon popover stays.
4. **VX-356:** verify first (Suspected): Terminal shows "›" on the open note's collapsed chapter row in the
   Book Panel, Study shows nothing. If real: one voice-tokened marker, pinned; if hollow: record, don't fix.

## CAST · LADDER · EVIDENCE

- **Cast:** the standing default — Fable orchestrates and cold-reviews, `opus-implementer` (xhigh) per batch,
  ONE at a time, fresh per batch. Reviewer: **`fable-reviewer`** (the diff carries MCP-door faces (batch 3) and
  possibly editor-adjacent landing work (batch 2.4) — default's-meaning + the cautious read).
- **Ladder:** ONE ladder over the run's whole combined diff after batch 3; `notes/REVIEW_PROMPT.md` VERBATIM,
  zero framing; findings repo-first in this file before any fix session; cross-model flow per CLAUDE.md (the
  reviewer makes the final call; the implementer applies confirmed fixes red-on-old; hard cap three rounds).
- **Pin-before-fix PER MEMBER** (bug-class: VX-437's declassify leak, VX-611's words, VX-331, VX-244, VX-356 if
  real); features land with state-transition/registry tests. A pin green on both sides exposes a hollow finding
  — record it, don't fix it.
- **Acceptance is use-shaped:** the orchestrator walks the built faces at the end-of-run stage window
  (screenshots for her morning bundle); Mac pins compile per batch (`build-for-testing`) and RUN at
  coordinator-granted stage windows (the vx-548 pattern: records mark suite runs PENDING until then).

## ENVIRONMENT (carried verbatim into every brief)

- **The stage is coordinator-gated (oct27coordinator, 2026-10-28): REQUEST → READY → GO.** No session in this
  run claims the stage itself; a FREE stage is never an invitation. Every `xcodebuild test` needs a stage GO
  (the orchestrator schedules them); headless `swift build` / `swift test` / `xcodebuild build-for-testing`
  never do. Release: `Tools/stage release --who <claim>` + one result line with EXECUTED tests/suites per run,
  dev-store posture, instance/sim state, stage.log times. Ask the coordinator BEFORE any `stage renew`.
- **Implementers run HEADLESS ONLY:** `swift build`, `swift test [--filter]` on the core package, and
  `xcodebuild build-for-testing` into `App/Variorum/DerivedData/vx440-<batch>/`. Mac suite RUNS are the
  orchestrator's, at stage windows. No GUI, no walks, no Debug launches, no dev-store writes.
- **`-only-testing` traps (the coordinator's, learned 2026-10-28):** it SILENTLY DROPS names that aren't suite
  TYPE names — verify the names; build the list as a zsh ARRAY (`args=(-only-testing:VariorumTests/A …);
  xcodebuild … "${args[@]}"`) — a single quoted string ran 0 tests twice today; a run's verdict needs the
  "Executed N tests" line compared with expected counts (0 ran = no verdict).
- Instance guards (strict forms): `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`; booted sims via
  `xcrun simctl list devices booted`. Real-store instances are treated by STORE, never quit/killed; no Release
  builds or `/Applications` refreshes while one lives (and none this run without her word).
- NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and
  strips the DEBUG oracles). Mac tests from `App/Variorum/`, suite-level `-only-testing` only. zsh `pipestatus`.
- Never `git checkout` over uncommitted work; commit per coherent piece; **push after every commit**; LIVE
  STATUS section in this file from the first commit (the resiliency protocol binds: synchronous foreground
  waits only — poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never end a turn awaiting a
  background run; never spawn subagents).
- The dev store is NOT this run's to touch until the walk window (coordinator rules then: record as-found at
  leg 0, restore exactly, never press Resume, mint walk content through product doors and remove it all).
- Ledger/record commits from this worktree go pathspec-limited to `notes/` when implementer edits are in flight.

## LIVE STATUS (flip per piece, same commit)

- Kickoff: DONE — members listed from Linear sub-issues, canon read (MCPSpec + SurfaceContracts in full),
  worktree seated, in-flight row pushed, coordinator announced, sitting held, rulings recorded above.
- Batch 1 (versions & Compare): IN-PROGRESS — implementer (Opus) seated 2026-10-28; UNIT RECORD below.

### Batch 1 — UNIT RECORD (versions & Compare: VX-130 · VX-437 · VX-432)

**Not done by this unit (first line, per the contract):** nothing run on the stage — every Mac-suite pin below
is WRITTEN AND COMPILED (`build-for-testing` into `App/Variorum/DerivedData/vx440-b1`) with its RUN, and every
red-on-old Mac verification, PENDING for the orchestrator's stage window; no walk captures (headless brief).

Pieces (flipped per commit):
- B1-0 record skeleton: DONE (this commit).
- B1-1 VX-437 live check (trace + pins): VERDICT — the scout's finding is REAL. Traced:
  `CompareViewModel.read` → `Queries.versionPeerSplit(…).sameWing` → `versionPeerPosts` (live `version_of`
  edges between live placements, NO version-history/archive fence) ⇒ a saved version (minted by `copyPost`
  with exactly such an edge, in the source's wing) IS a same-wing peer; `adopt` auto-fills
  `versionPeers.first` (order `c.id` — a UUID coin flip when an ordinary peer exists too) and the offer band
  lists it; its card wears "unmark" (`isVersionPeer`); the button runs `unmarkPostsAsVersions(anchor,
  version)`, tombstoning every cross edge on a fresh stamp no endpoint block shares ⇒ the classifier's edge
  fence drops it ⇒ it leaves Note ▸ Versions, rows onto Archived (`archivedPosts`), and Restore/Promote
  throw `notVersionHistory`. The Library's "Unmark Versions with…" picker can NOT reach a version
  (`notePickerNotes(ids:)` fences `archived_at IS NULL`), so Compare's card is the one door. Pins: core
  `VersionsInCompareTests.aSavedVersionIsASameWingVersionPeerSoCompareSeatsIt` (the auto-fill input, green
  both sides — a contract pin, not a bug pin; RUN GREEN headless); Mac red-on-old
  `CompareVersionsTests.unmarkOnASavedVersionNeverDeclassifiesIt` — COMMITTED ON THE PRE-FIX TREE in this
  commit (pre-fix API only) and compiled (`build-for-testing` ✓); its RED run on this SHA and GREEN run on
  the B1-3 fix commit are PENDING (stage window). DONE (this commit) for the trace + pins.
- B1-2 core: saved-version stamps query (newest-first, the one classifier) + its pins: NOT-STARTED.
- B1-3 Compare: auto-fill order (P-440-2) · version columns show the DATE · unmark on a saved version = the
  promote confirm (P-440-5): NOT-STARTED.
- B1-4 doors: Versions row "Compare with now" + the registry act "Compare with Latest Version" (File ·
  note ▾ · ⌘K, rendered only while the note has a saved version): NOT-STARTED.
- B1-5 full size: a Versions row's "Open full size" → the version on Read's calm page with the identity band
  (Back to the note · Promote to a regular note…), no mode row, ⌘⇧S grey, no per-note memories (P-440-1):
  NOT-STARTED.
- B1-6 Mac pins compiled (`build-for-testing`), core suite green: NOT-STARTED.
- Batch 2 (Block History): NOT STARTED.
- Batch 3 (gathering faces): NOT STARTED.
- Ladder: NOT STARTED.
- Stage windows: EARLY request sent to oct27coordinator (suite runs + end-of-run walk); none READY yet.

## BATCH BRIEFS (each self-contained; the implementer reads ONLY what its brief names)

### BATCH 1 BRIEF — versions & Compare as one design (VX-130 · VX-437 · VX-432)

Read in your own context before any code: `CLAUDE.md` + its auto-loaded canon (loads with your session),
THIS FILE in full (especially HER RULINGS, THE SITTING RECORD, THE DESIGN §Batch 1, ENVIRONMENT),
`notes/SurfaceContracts.md` (The app · The Library · The note), `notes/SessionResiliencyProtocol.md`, and the
code anchors: `App/Variorum/Variorum/Features/Versions/NoteVersionsPane.swift`,
`App/Variorum/Variorum/Features/Takes/CompareBoardView.swift` (:409-413 auto-fill, :1354-1358 unmark),
`Sources/VariorumCore/Queries/NoteVersions.swift`, `Sources/VariorumCore/Queries/Lineage.swift` (:206-229),
`Operations`' `promoteNoteVersion` / `saveNoteVersion` / `restoreNoteVersion` (AppSpec §9's versions family),
the ShellRouter ModeLanding (`ShellRouter.swift` ~:280-293), `MCPNavigator.swift` (:78-89, the CompareLanding
road you reuse), the capability registry (`Registry/`), and `App/Variorum/VariorumTests/NoteVersionsPaneTests.swift`
+ the Compare tests. Scope: EXACTLY the Batch 1 contract (items 1–5) + its PROVISIONALs. One acceptance unit.
NO MCP wire changes; no `Sync/`; no schema; no editor-seam (`EditorTextView`/`BlockRangeIndex`) changes.
First act: the VX-437 live check (trace + red-on-old pin on the declassify leak if reachable). Tests: core
state-transition tests headless; Mac pins written + COMPILED (`xcodebuild build-for-testing` into
`DerivedData/vx440-b1`), runs marked PENDING. Checkpoint protocol per ENVIRONMENT. Commit messages: `Part of
VX-130/VX-437/VX-432 (VX-440)`. Write your UNIT RECORD under LIVE STATUS → Batch 1 in this file.

### BATCH 2 BRIEF — Block History clarity (VX-431 · VX-331 · VX-244)

Read: `CLAUDE.md` + canon, THIS FILE in full, `notes/SurfaceContracts.md` (The note · The app),
`notes/TEXTKIT2_NOTES.md` **if and only if** your restore-wash implementation touches the editor seam
(`EditorTextView`, `PaneSurface`, `BlockRangeIndex` — prefer the landing road + overlay so it doesn't),
`notes/SessionResiliencyProtocol.md`, and the code anchors:
`App/Variorum/Variorum/Features/Tray/BlockHistoryPane.swift` (the four-region pane; her ruled structure stays),
`Shared/BlockHistoryFace.swift`, `Core/Views/ExplainerLine` (the idiom you adopt), `Core/Views/SavepointNameField.swift`
(the rename door stays), the changing-block wash + landing/jump roads (`TakesViewModel`, the LandingTarget
family), `Operations` `restoreCommit` / `branchVariant` (+ `restoreCost` for VX-331), the Takes article's and
Lenses board's "Show take ▸" arms (VX-244: `TakesShowFaces.swift` / `LensesBoardView.swift` — trace first).
Scope: THE DESIGN §Batch 2 items 1–7 + P-440-3/-4. One acceptance unit. The bring-back operation mirrors
`branchVariant` exactly (verify its touch/churn/undo posture in code first). No schema; no `Sync/`. Tests:
headless core tests for the new operation + `restoreCost`'s window pin (red-on-old); Mac pins compiled into
`DerivedData/vx440-b2`, runs PENDING. Checkpoint protocol per ENVIRONMENT. Commits: `Part of VX-431/VX-331/
VX-244 (VX-440)`. UNIT RECORD under LIVE STATUS → Batch 2.

### BATCH 3 BRIEF — gathering faces (VX-611 · VX-616 · VX-189 · VX-356)

Read: `CLAUDE.md` + canon, THIS FILE in full, **`notes/MCPSpec.md` IN FULL** (VX-189 touches the door's faces),
`notes/SurfaceContracts.md` (The Bookcase and books · Doors to the outside · The app),
`notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md` (MB-18, MB-19's PROVISIONAL copy, BATCH 3 RECORD — the
gathering-as-place build you extend), `notes/SessionResiliencyProtocol.md`, and the code anchors:
`App/Variorum/Variorum/Core/Views/BookRowMenu.swift` (:211 — the kind-worded verb), the Trash surface's kind
word, `App/Variorum/Variorum/Features/Books/BookView.swift` (~:942-975 — the "+ new chapter" foot you remove),
the Book Settings sheet (the book's "Shared with" row you extend to gatherings), the capability registry's
`.mcpShareBook` family + `.deleteBook` + the chapter-foot declaration, `Queries/MCPShareQueries.swift`,
`App/Variorum/VariorumTests/MCPShareFacesTests.swift` (the "place doors unbuilt" messages flip), the Book Panel
chapter row (VX-356 — Terminal vs Study marker; verify before fixing). Scope: THE DESIGN §Batch 3 items 1–4.
One acceptance unit. **NO wire-tool changes, no grant-semantics changes, no new reach** — faces only; Private,
Seal, Own untouched. No schema; no `Sync/`. Tests: registry-walk stays green; red-on-old pins on VX-611's
words and VX-356 (if real); face pins for the two new doors; compiled into `DerivedData/vx440-b3`, runs
PENDING. Checkpoint protocol per ENVIRONMENT. Commits: `Part of VX-611/VX-616/VX-189/VX-356 (VX-440)`.
UNIT RECORD under LIVE STATUS → Batch 3.

## FOR THE CLOSEOUT (owed; do not improvise past it)

- Canon deltas in the two-file shape: SurfaceContracts (The note — the Versions/Compare doors, the full-size
  band, Block History's read/bring-back; The Bookcase — the gathering's kind word, the foot, the Shared-with
  doors), MCPSpec (the gathering place-doors line superseding P-VX185-2's as-built note), AppSpec §9 only if
  the bring-back lands as a new named operation; the dated entry + narratives to `notes/AppSpecRecord.md`;
  `Tools/canon-size` run, its line in the handoff.
- The QUESTIONS bundle (PROVISIONALs P-440-1…5 + the kept `show_in_app` version refusal + anything the ladder
  disputes) — lands at the merge moment, on latest main, by the merging session.
- Tickets: members Done as their fixes land; **every ticket this run FILES triaged** to the labeling rule;
  VX-315 stays open and unowned (offered, not taken).
- MOBILE PARITY line (likely rows: the phone's Block History face and versions — the bring-back take and the
  promote-on-unmark are shared operations; Compare is Mac-only by her named exception).
- Serialize with VX-648/vx-601: merge main in, re-run the overlapping suites, coordinator's merge GO.
- The handoff `notes/handoffs/vx-440-handoff.md` (her checklist at top: the declutter screenshots verdict, the
  promote-confirm copy, P-440-1/-2 ratifications, the show_in_app version question); in-flight row retired;
  worktree removed; branch deleted after merge; build debris + walk evidence deleted post-merge.
