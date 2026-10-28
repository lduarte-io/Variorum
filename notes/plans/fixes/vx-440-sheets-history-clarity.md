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
- Batch 1 (versions & Compare): BUILT HEADLESS — implementer (Opus) 2026-10-28; Mac-suite RUNS + red-on-old + walk PENDING the stage window; UNIT RECORD below.

### Batch 1 — UNIT RECORD (versions & Compare: VX-130 · VX-437 · VX-432)

**Not done by this unit (first line, per the contract):** nothing run on the stage — every Mac-suite pin below
is WRITTEN AND COMPILED (`build-for-testing` into `App/Variorum/DerivedData/vx440-b1`) with its RUN, and every
red-on-old Mac verification, PENDING for the orchestrator's stage window; no walk captures (headless brief).

Pieces (flipped per commit):
- B1-0 record skeleton: DONE (ed49145b0).
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
  the B1-3 fix commit are PENDING (stage window). DONE (34c21e938 — the PRE-FIX tree: the red-on-old SHA) for the trace + pins.
- B1-2 core: `Queries.noteVersionStamps(_:of:limit:)` (newest-first, `noteVersions`' exact answer and order,
  the ONE classifier deciding) + `latestNoteVersionID` + `AppDatabase.observeLatestNoteVersion` —
  NOTE-DRIVEN (candidates from the note's own placements → both `version_of` edge arms → the other end's
  live placement; the outer row a seek by id), because it feeds a fact held for every note visit; the summoned
  listing keeps its own shape. Recorded cost note: the classifier's own EXISTS still has SQLite build an
  automatic partial index over `version_of` edges once per execution — only when the note HAS a candidate;
  that is `versionHistoryPredicate`'s shared shape (every consumer pays it), out of this batch's scope —
  a closeout ticket candidate. Pins (core, RUN GREEN headless): `VersionsInCompareTests
  .theStampsAreTheListingsOwnAnswerNewestFirst`, `.theStampsFollowTheListingAcrossTheAnchorsShapes`
  (merge / archiveBlock / deleteBlock on the anchor; unmark, promote, Trash), `.theStampsReadIsDrivenFrom
  TheNotesOwnPlacements` (the plan). DONE (144972474).
- B1-3 Compare (`CompareBoardView.swift`, `Shared/VersionsCopy.swift`): the projection gains `savedVersions`
  (id → saved-at, from `noteVersionStamps` — the classifier's whole set, a moment whose link only the
  tombstone-tolerant read still holds included) and `versionPeers` becomes ordinary same-wing peers first, then
  the moments newest-first (P-440-2 — auto-fill and the offer band read it); a moment's column is titled by
  its DATE (`VersionsPath.momentTitle`, the listing's own format — V6, no title mutation) with the line "a
  saved version of this note" (P-440-6, PROVISIONAL wording); its "unmark" ARMS `pendingVersionPromote` and
  writes nothing — the board's alert (P-440-5's copy, `VersionsPath.stopCounting…`) answers through
  `promoteSavedVersion` → `VersionActs.promote` (its receipt/refusal words); an ordinary peer's unmark is
  byte-unchanged. The column's "open" door is untouched here — it moves to the full-size face in B1-5. Pins
  (Mac `CompareVersionsTests`, compiled ✓, RUNS PENDING): `autoFillSeatsTheOrdinaryPeerFirstThenTheNewestMoment`,
  `aMomentsColumnIsNamedByItsDateAndSaysWhatItIs`, `unmarkOnAMomentAsksAndTheAnswerPromotes`,
  `unmarkOnAnOrdinaryVersionPeerStillUnlinks`, `thePromoteConfirmSaysWhatTheNoteBecomes`; and the B1-1 pin
  `unmarkOnASavedVersionNeverDeclassifiesIt` turns GREEN at this commit (PENDING the run). DONE (773cf2a02 — the fix: the green-on-new SHA for the B1-1 pin).
- B1-4 doors: ONE act (`Core/Views/VersionCompareDoor.swift`) over ONE road (`CommandRouter.requestCompare` —
  `pendingCompareLanding` + `requestMode(.compare)`, the wire's compare road for a note whose detail is
  mounted; a refused switch takes its parcel back). (a) Versions rows: "Compare with now" on a second line
  under the four verbs, DRAWN ONLY while the note's detail is the mounted one (`canCompareHere` — a bar's
  sheet over a book's inline note has no Compare mode: P-2; the row acts stay the listing's own undeclared
  vocabulary, as Read/Restore/Promote/Delete are). (b) The registry act `.compareWithLatestVersion`
  ("Compare with Latest Version", post scope, doors File `.menuBar` · both `note ▾` `.bottomBar` · ⌘K
  `.palette`, no chord; availability `mode != nil && noteHasSavedVersion`): the new context fact
  `CapabilityContext.noteHasSavedVersion` ← `CommandRouter.activeNoteLatestVersionID` (observable; written
  only for the mounted note, cleared on another note's register and on unregister) ← the detail's held
  `observeLatestNoteVersion` task (`PostDetailView`); File greys, `note ▾` hides (`latestDoorShows`), ⌘K's
  per-open listing drops the row (`paletteEntries(listing:noteHasSavedVersion:)`, default true so the walk's
  every-row listing and `WingPaletteDoorsTests`' counts stand). The newest moment is re-read AT THE PRESS
  (`compareWithLatest`); none ⇒ the act's note speaks. Registry walk: ONE justified edit — a sampled context
  `CapabilityContext(mode: .write, noteHasSavedVersion: true)` (the VX-570 line's class). Pins (Mac
  `VersionDoorsTests`, compiled ✓, RUNS PENDING): `theLatestVersionDoorIsDeclaredOnFileTheBarsAndThePalette`,
  `theLatestVersionDoorActsOnlyWhereTheNoteHasAMoment`, `theRoutersLatestVersionFactBelongsToTheMountedNote`,
  `requestCompareParksTheLandingAndSwitchesToCompare`, `thePaletteListsTheLatestDoorOnlyWhileTheNoteHasAMoment`,
  mounted `theMountedDetailReportsItsNotesNewestMomentLive`, mounted
  `compareWithNowLandsTheMomentBesideTheNoteInCompare`; plus the registry walk suite
  (`CapabilityRegistryTests`) — RUN PENDING. DONE (8c409dc75).
- B1-5 full size (R-440-2, VX-432): a NEW destination `SidebarSelection.noteVersion(versionID, of: noteID)`
  rather than `router.adopt(.post(versionID), mode: .read)` (the scout's bare door) — so the clauses hold
  STRUCTURALLY, not by suppression: no `PostDetailView` mounts ⇒ no detail registers ⇒ the sidebar's "this note"
  rail (drawn for `.post` only) is absent, `noteScoped` has nothing ⇒ ⌘⇧S greys in File and its ⌘K row speaks
  its note, the Open list (tracks `.post`) gains no row, and NO per-note memory is written (P-440-1: no
  `postMode.‹id›`, no `readFace.‹id›`, no `CurrentBlockMemory` report — it opens at the start); back/forward
  carry the visit. `Features/Versions/NoteVersionPage.swift`: the identity band ("A saved version of
  “‹title›” · ‹date›" — `VersionsPath.bandLine`; Back to the note; Promote to a regular note… → the P-440-5
  confirm → `VersionActs.promote`, receipt/refusal on the status seam, then the pane shows the promoted note AS
  a note — PROVISIONAL P-440-7) over `ReadPageColumn` (Read's own calm page — made internal in
  `ReadModeView.swift`, its paragraph click-through optional: nil ⇒ no click-to-edit, no help; Read's own
  call sites byte-unchanged in behaviour) fed by a `BlockTOCViewModel` over the moment; a held band read
  (`NoteVersionPageModel.read` — the classifier, the birth stamp, the note's display name) shows "This isn't
  one of the note's saved versions any more." instead of the words once promoted/deleted/unlinked. Doors:
  the Versions row's second line "Open full size" (always) beside "Compare with now" (B1-4's gate), and a
  moment's Compare column's "open" — both through `NoteVersionPage.open` → `.variorumOpenNoteVersion` (a
  navigation signal, `.variorumOpenPost`'s precedent) → `RootView` → `.noteVersion`. Shell arms:
  `RootView` (the detail arm + the listener), `WorkspaceModel` (title key; the back chip's date via
  `readTitles`; `notesDeleted` now also leaves a pane reading one of a deleted note's moments),
  `WorkspaceNaming.label` ("Saved version" fallback), `StarTargeting` (never a star target), `TourPlaces`
  (`.elsewhere`), `SidebarSelection.noteID` (nil). Pins (Mac `VersionDoorsTests`, compiled ✓, RUNS PENDING):
  `aSavedMomentIsItsOwnDestinationNeverANote`, `deletingTheNoteLeavesAMomentsPageToo`,
  `theBandNamesTheMomentAndPromoteMakesItANote`, mounted `theMountedPageWritesNoMemoryAndOffersNoModesOrSave`.
  The notification → destination hop and the band's face are walk-evidence (the orchestrator's stage window).
  DONE (1e8a7b4ba).
- B1-6 verification (headless): `xcodebuild build-for-testing` (scheme Variorum, platform=macOS,
  `DerivedData/vx440-b1`) ✓ TEST BUILD SUCCEEDED at the final tree; core `swift test` (full) — VariorumCoreTests
  3488 tests / 466 suites PASSED (5 known issues, pre-existing), the second target 32/4 PASSED, the MCP target
  431/79 with ONE failure `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`
  (a 15-s wall-clock bound measured 24 s under the full run's ~460% CPU load) — re-run ALONE: 3/3 PASSED in
  2.1 s; a load flake in a suite this batch does not touch (no MCP change). NOT compiled for iOS: the shared
  `VersionsCopy.swift` gained only plain `static let`/`func` members (Foundation `Date.formatted`) — the phone's
  build is the orchestrator's to confirm if wanted. DONE (this commit).

**Batch 1's rows, dispositioned:**
- VX-437 (Bug, Suspected → CONFIRMED by the live check): FIXED — the declassify road is unreachable from
  her doors (Compare's card was the only one; the Library picker fences archived). Pin
  `CompareVersionsTests.unmarkOnASavedVersionNeverDeclassifiesIt` committed on the pre-fix tree (34c21e938),
  the fix at 773cf2a02 — RED/GREEN runs PENDING. The core op `unmarkPostsAsVersions` is deliberately
  UNCHANGED (its documented unlink stays pinned by `NoteVersionsTests.adeliberateUnmarkStillUnlinksAVersion`;
  a core refusal would need a new `OperationError` case, which the MCP wire-refusal sweep enumerates — kept
  out of a no-MCP batch; a belt the ladder may weigh). Contract half (versions DO show, never filtered out of
  auto-fill): built, B1-3.
- VX-130 (Feature): BUILT — B1-3/B1-4 (Compare with now · Compare with Latest Version · moments as columns).
- VX-432 (Improvement): BUILT — B1-5 (the full-size face).

**PROVISIONALs this unit adds (for the closeout's QUESTIONS bundle — batch 2/3 take the next free numbers):**
- **P-440-6 (Compare/Versions wording):** a moment's column line "a saved version of this note"; its unmark
  help "Stop counting this as a version — it becomes a regular note of its own (asks first)"; the row doors
  "Open full size" / "Compare with now" and their helps; the band line «A saved version of “‹title›” ·
  ‹date›» (curly quotes round the title); the gone line "This isn't one of the note's saved versions any
  more."; the back chip's fallback "Saved version". All in `Shared/VersionsCopy.swift` (`VersionsPath`).
- **P-440-7 (after the band's Promote):** the pane shows the promoted note AS a note (`adopt(.post(id))`,
  Write/its remembered mode) — the thing she was reading became hers to write in. Options: (a) as built;
  (b) back to the live note, the receipt naming where the promoted one went; (c) stay on a "promoted — open
  it ›" state. (a) chosen: continuous with what she was looking at, and the receipt already says it left
  Versions.

**For the reviewer / the orchestrator (concerns, not forks — nothing here stopped the build):**
1. The band's Back/Promote and the Versions row's two new doors are UNDECLARED inline doors — the pane's own
   precedent ("the row acts … are the listing's own vocabulary, not app-scope capabilities"); only the
   one-press act with File/bar/⌘K doors is declared. A P-1 purist may ask for `.surface` declarations.
2. Compare's "open" on a moment's column now opens FULL SIZE (not the editor) — R-440-2's "no ⌘⇧S over a
   version" applied to the one other door that reached a moment; flagged as a small scope reach.
3. A promoted moment STAYS in its Compare column as an ordinary version (the `version_of` edge is kept —
   `promoteNoteVersion`'s standing semantics, "ends as Duplicate with Tags does").
4. The classifier's EXISTS makes SQLite build an automatic partial index over `version_of` edges once per
   execution when the note has a candidate (B1-2's note) — shared by every `versionHistoryPredicate`
   consumer; a closeout ticket candidate (Performance, Debt).
5. ⌘K's "Save a Version" row stays LISTED on a moment's page and speaks its note when pressed (the palette's
   standing grammar lists act rows everywhere); File greys it. R-440-2's "⌘⇧S refuses/absent" holds either way.
6. MOBILE PARITY candidates: none built (Compare is Mac-only by her named exception; the phone has no unmark
   door). The phone's Versions face could later take "open full size".

**Stage-window run list (the orchestrator's; suite TYPE names, built as a zsh array; compare "Executed N"):**
- RED-ON-OLD at `34c21e938`: `-only-testing:VariorumTests/CompareVersionsTests` — 1 test, EXPECT 1 FAILURE
  (`unmarkOnASavedVersionNeverDeclassifiesIt`: the moment gone from Versions, listed on Archived).
- GREEN at the batch tip: `CompareVersionsTests` (6) · `VersionDoorsTests` (11) · `CapabilityRegistryTests`
  (the walk + the one justified context edit) · `NoteVersionsPaneTests` · `CompareViewModelTests` ·
  `CompareCompositionTests` · `MCPCompareLandingTests` (the landing road the doors share) ·
  `WingPaletteDoorsTests` (palette counts) · `CommandRouterTests` · `WorkspaceModelTests` ·
  `WorkspaceNamingTests` · `NavigationDoorsTests` (the new destination) · `ModeSwitchCarryTests` ·
  `NoteOpenLandingTests` · `ModeSwitchFeelTests` (Read's page, now internal with an optional click-through).
- Walk rows (both voices where a face): Compare auto-filled with a moment (date-titled column, "a saved version
  of this note"); its unmark → the P-440-5 confirm → promoted; a Versions row's "Compare with now"; File/
  note ▾/⌘K "Compare with Latest Version" present with a moment, absent/grey without; "Open full size" →
  the band over the calm page, no "this note" rail, ⌘⇧S grey; Back; Promote from the band.
- Batch 2 (Block History): IN PROGRESS — implementer (Opus) 2026-10-28; UNIT RECORD below.

### Batch 2 — UNIT RECORD (Block History: VX-431 · riders VX-331 · VX-244)

**Not done by this unit (first line, per the contract):** IN PROGRESS — the final list lands at close.

Pieces (flipped per commit):
- B2-0 record skeleton: DONE (this commit).
- B2-1 VX-331 trace + red-on-old core pin (the `now` plumbing, behaviour unchanged): VERDICT — REAL.
  Traced: Block History's deleted region (and the tray) list a block's deleted takes through
  `Queries.deletedTakes(db, blockID:, now:)`, which keeps only `deleted_at >= TrashWindow.cutoffStamp(now:)`
  (past the clock no door offers Put back); `Queries.restoreCost`'s population-2 arm
  (`RestoreCost.swift`, the `deleted_takes` subselect) counted every tombstoned take on the outgoing
  blocks with the purge fence but NO window — so a take deleted >30 days ago that the janitor has not
  yet removed (`PurgeJanitor.collectRoots`' 30-day variant roots wait for a synced family's horizon;
  `LocalPurge` for its next sweep) was named in the version-restore confirm
  (`VersionsPath.restoreCostLine` — "Going with these paragraphs, and held by no version: N deleted
  takes") as "waiting in Block History" (the field's own doc), a take no surface shows. Plumbing:
  `restoreCost(_:of:now:)` (REQUIRED `now`, `deletedTakes`' reason), `VersionActs.restoreCost` passes
  `session.now`, the existing pins pass `RestoreCostTests.asked` (a day into the harness world). Pin
  `RestoreCostTests.aTakePastTheThirtyDayClockIsNotCountedAsStillRestorable` (one take past the clock,
  one inside; the count equals `deletedTakes`' listing at that moment; the `>=` edge counts) — RUN RED
  headless on this commit: 3 issues (`cost.deletedTakes == 1` read 2; `== listed.count` 2 vs 1; the
  edge ask 2). DONE (this commit — the PRE-FIX tree).
- B2-2 VX-331 fix (the 30-day window in `restoreCost`): the population-2 subselect gains
  `v.deleted_at >= :cutoff` (`TrashWindow.cutoffStamp(now:)`, the listing's `>=`). The B2-1 pin RUN GREEN
  headless (`RestoreCostTests` + `NoteVersionsTests`: 39 tests / 2 suites passed). The Mac face reads
  through `VersionActs.restoreCost` (session clock) — unchanged words. DONE (this commit — the fix).
- B2-3 VX-244 traces (both arms) + red-on-old Mac pins (the cell menu made inspectable, behaviour unchanged):
  BOTH ARMS REAL, traced apart. The cell menu (`TakesCellView.menuSpecs`, `TakesShared.swift`) appended
  "Show take ▸" wherever `projection.fans[blockID].count > 1`, never consulting the cell's COLUMN.
  (a) THE TAKES ARTICLE: its cells carry `TakesColumn(id: "takes-main", kind: .main)`
  (`TakesBoardView.mainColumn`), an id that never lives in the model's `columns` (those are the
  memory's/UUID-minted columns; no `columns.append` or re-point ever writes a literal id) — so each child
  row's `pick(columnID: "takes-main", …)` returned at its first `guard … firstIndex … else { return }`:
  no state, no status — the silent door. (b) THE LENSES CHOSEN COLUMN: a real `.main` column; each child
  reached `pick`'s `.main` arm, which only refuses (`chosenColumnHasNoPickNote`, J38) — a door that can
  never act. Precedent for the fix: the column's ‹ › switcher already renders only for
  `column.kind != .main` (`LensesBoardView.pickSwitcher`), and VX-227 made switcher + "Show take ▸" one
  road. Seam: `menuSpecs(resolved:)` private → internal (visibility only). Pins (Mac
  `ShowTakeDoorTests`, NEW, compiled ✓ `build-for-testing` into `DerivedData/vx440-b2`, RUNS PENDING):
  `theTakesArticleCellOffersNoShowTake` (RED ON OLD — the mechanism asserted green-both-sides: a pick on
  the article's column says nothing and moves nothing), `theLensesChosenColumnOffersNoShowTake` (RED ON
  OLD — the mechanism: the pick refuses with J38's words), `aScratchColumnKeepsShowTakeAndItActs`
  (control, green both sides: two rows, a press moves the scratch pick). DONE (this commit — the PRE-FIX
  tree: the red-on-old SHA).
- B2-4 VX-244 fix: one guard — the cell menu offers "Show take ▸" only when `column.kind != .main` (the
  switcher's rule). `pick`'s `.main` refusal arm is UNCHANGED (⌃⌘←/→ on the Chosen column still speaks
  J38 — `TakesParkedFollowTests.aChosenColumnPickInTheMintGapLeavesTheParkAlone` keeps driving it
  directly). The two B2-3 absence pins turn GREEN at this commit (RUN PENDING). DONE (this commit — the
  fix: the green-on-new SHA).
- B2-5 core: bring a commit back as a take (the op, mirroring `branchVariant`'s posture) + state-transition
  tests. **`branchVariant`'s posture, VERIFIED IN CODE** (`Operations+Variant.swift`): `insertFanVariant`
  checks `liveBlock` → `ensurePlacementUnlocked` (the seal) → the source's `liveVariant` (archived and
  locked sources ALLOWED — the source is only read), inserts ONE `variant` row and writes nothing else —
  no `registerTextChange`, no `touchContainer` (so no `last_touched_at`, no churn), and NO
  `undoStack?.register` (it is not on AppSpec §9's undo list; no app caller registers one either —
  `TakesViewModel.branchTake`/`branchIntoColumn`, `EditorViewModel.mintCaretTake`). The op
  `Operations.bringBackCommitAsTake(_ commitID:) -> Variant` mirrors it in ONE transaction: the commit
  (else `commitNotFound`) and its take's row name the block, then `liveBlock` → seal → the take's
  liveness in `insertFanVariant`'s order; text = the commit's, parent = the commit's take, at the fan's
  END (`newBlankVariant`'s `MAX(fan_position)` road — the moment is not a sibling of the take as it is
  now), never chosen, never locked, label = the commit's name through the take label's own
  normalisation (P-440-3), no touch/churn/undo (P-440-4). Pins (core, NEW `BringBackCommitAsTakeTests`,
  RUN GREEN headless — with `BlockVariantOperationsTests` 29/2 passed):
  `theMomentBecomesANewTakeAtTheFansEndAndNothingElseMoves`, `anUnnamedMomentBringsBackAnUnlabelledTake`,
  `itTouchesNothingAndChurnsNothingExactlyAsABranchDoes` (side by side with a branch),
  `itRegistersNoUndoEntryExactlyAsABranchDoes` (side by side), `aSealedNoteRefuses`,
  `aDeletedTakesMomentRefuses`, `aDeletedBlockRefuses`, `anUnknownCommitRefuses`,
  `aLockedOrArchivedSourceStillBringsItsMomentBack`. No new `OperationError` case (the wire-refusal sweep
  untouched); not wire-called (no MCP change). A NEW NAMED OPERATION → AppSpec §9 owes a line at closeout
  (the plan's FOR THE CLOSEOUT already names it). DONE (this commit).
- B2-6 the pane at rest: calm one-line rows that expand; explainers behind (i); header counts.
  `BlockHistoryPane.swift`: `CommitRowView` RESTS as ONE line — the stamp (`CommitRowFace.stamp`, never
  truncates) · the name (when named, one line) · the quiet glyph (`◦` on an automatic commit only — a
  deliberate one earns none, VX-144's rule) — the whole line but Restore is the press that opens the row
  (`openCommits`, session state; hover "Show more/less of this commit"); Restore stays at the line's end
  (her "Restore per row"). OPEN adds the longer capped preview (`CommitRowFace.expandedPreview`:
  paragraphs kept, leading blanks dropped, 600-char cap, 8 lines, no ellipsis of its own), the details
  words (`notes`: "quiet" · "predates a split" — the stamp is on the line), and the row's other doors
  "Read in full" (wired in B2-7) · Name/Rename. Region headers: `HistoryRegionHeader` (title + COUNT —
  `BlockHistoryModel.commitCount` = every moment of every live take; archived/deleted/came-from counts)
  over an `ExplainerLine` whose short line is new Mac-local copy (`BlockHistoryPath.savepointsLine` etc.)
  and whose (i) holds the SHIPPED sentence verbatim; `ExplainerLine` gains an optional `tokens` (voiced:
  small type, faint ink, chrome casing — nil = every Settings host byte-identical). Empty regions stay
  hidden. Pins (Mac, compiled ✓ `build-for-testing` `DerivedData/vx440-b2`, RUNS PENDING): NEW
  `BlockHistoryClarityTests.theRegionHeadersCarryCountsAndOneLineEachWithTheWholeBehindAnI`,
  `.anEmptyRegionDrawsNoHeader`; `CommitsPageLedgerTests` — TWO JUSTIFIED PIN EDITS (VX-144's resting
  preview and three-line row retired by the design's item 1; each edit's doc names what of VX-144 it
  still holds): `thePreviewIsTheFirstParagraph…` → `theOpenPreviewKeepsParagraphsCapsAndAddsNoEllipsisOfItsOwn`;
  `theRowIsCompactAndItsActsAreWords` (rest: one voiced word, ≤ 34 pt named or bare — an ESTIMATE, the
  run prints the heights; open: three voiced words, taller); NEW
  `theRestingLineSaysWhenTheNameAndTheQuietGlyphOnly`. Unchanged and expected green:
  `BlockHistoryPaneTests` (its region pin reads the raw sentences the new header stores),
  `CommitsPageLedgerTests.theDetailsLineSaysOnlyWhatTellsCommitsApart` (`details` kept — the sheet's
  subtitle), `.theCommitsPageDrawsNoBezels`, `.theDefiningSentenceSurvivesAndThePaneBlurbIsGone`.
  DONE (this commit).
- B2-7 read in full (the sheet) + Bring back as a take (the door, the receipt). The open row's "Read in
  full" → `BlockHistoryModel.readInFull(_:of:heading:)` sets the observable `reading`
  (`CommitReading`: the commit, its take, the take's heading) → the pane's `.sheet(item:)` presents
  `CommitReadingSheet`: titled by the moment's name else "Commit · ‹stamp›"
  (`BlockHistoryPath.readingTitle`), a details line (the take's heading · `CommitRowFace.details`), the
  WHOLE text as ONE selectable read-cheap `Text` in a scroll (never an editor — P3/I5; cost = the
  moment's own length, paid once when summoned), and at its foot **Bring back as a take** (quiet) and
  **Restore** (primary). Restore is the row's own act (`model.restore`), its pre-split warning asked IN
  the sheet (the pane's alert cannot present over a sheet) → `confirmed: true`; both foot doors dismiss
  the sheet first, so the act is seen in the pane and on the page. Bring back →
  `model.bringBackAsTake` → the B2-5 op, NO flush (it copies the commit's text, never a buffer), receipt
  `BlockHistoryPath.broughtBackAsTake(label:)` ("Brought back as a take — it's the last take in this
  block's fan." / names the label when the moment had a name — P-440-4), refusals in the tray family's
  words. Inline door, undeclared — the pane's own vocabulary like Restore/Name (registry untouched). Pins
  (Mac `BlockHistoryClarityTests`, compiled ✓, RUNS PENDING): `readInFullShowsTheWholeMomentWithItsTwoFootDoors`,
  `anUnnamedMomentIsTitledByWhen`, `bringBackAsATakeLandsTheTakeAndSaysSo`,
  `bringBackUnderASealRefusesInTheStandingWords`. DONE (this commit).
- B2-8 restore says where it landed (the landing + the overlay wash). **NO FORK** — the wash is built on
  EXISTING machinery and touches no editor-seam file (`EditorTextView`, `PaneSurface`, `BlockRangeIndex`
  unchanged; `notes/TEXTKIT2_NOTES.md` read in full anyway, since the landing drives `JumpPrimitive` and
  the decor flash from `EditorViewModel`). The road: a LANDED restore (row or sheet) posts
  `RestoreLanding` (postID · blockID · the restored take · the words it now holds · a fresh id) on
  `CommandRouter.pendingRestoreLanding` (observed; cleared with its detail like the landings beside it).
  A SIGNAL each surface decides about (P-4), heard on CHANGE only (never at an arrival — a parcel nobody
  took is inert). **Write** (`EditorViewModel.consumeRestoreLanding`, the DETAIL editor only — the
  inline book/pool editors own no reveal): parks it, lands once the page SHOWS the words (the slot's
  text = the parcel's; checked at the parcel and at every settle hop after the rewrite; dropped past
  `RestoreLanding.patience` = 2 s, when she types, or when the page renders another take / lacks the
  block): caret at the block's start, the line rested in the comfort band (`restCaretLineInTheBand`, the
  mode switch's rule), and the FIRST line washed through the decor layer's existing `arrivalFlashSink`
  (the 18l-c arrival flash's face — wash fill + accent border, a `DecorRectView` below the text: an
  OVERLAY, never a rendering attribute). First line only: her "at least where it starts", and the one
  line measurable without forcing layout away from the viewport (TEXTKIT2 §3's VX-246 rule). The line
  rect's geometry moved to ONE helper (`lineFlashRect`) shared with the mode-switch flash (behaviour
  unchanged). **Takes** (`TakesViewModel.consumeRestoreLanding`, THE board only — `landingEnabled`,
  host `.takes`): parks it, lands in `adopt` AFTER `noteProjectionArrived` once the article shows the
  words (a landing made against the old projection would be ended by the delivery that brings them —
  13u2 UNIT E's structural arm), as the article's own landing with a NEW kind `.restore`
  (`TakesArticleScroll`: weighed against nothing, R-Q1's minimal reveal, FLASHED on arrival like an
  entry; `ArticleArrival` gains its `kind`). **Not governed by the mode-switch flash setting** (its title
  and help name mode switches only) — PROVISIONAL **P-440-8**; Reduce Motion's discreet variant holds.
  Other modes (Read, Lenses, Compare, Blocks, Canvas) and the sheet hosts (the book's inline and the
  scraps editors, the Takes bar's sheet, Write's take panel) land nothing: the receipt alone. A restore of
  a take the surface does not show lands nothing (no restored words there to wash). Pins (Mac, compiled ✓
  `DerivedData/vx440-b2`, RUNS PENDING): NEW `RestoreLandingTests` —
  `aLandedRestorePostsItsLandingAndARefusedOneNothing`, `aStaleRestoreLandingIsLetGoWithItsDetail`,
  mounted `writeLandsAtTheRestoredBlockAndWashesItsFirstLine` (the setting OFF; DEBUG oracle),
  mounted `writeLandsNothingForATakeItDoesNotShow`, `takesLandsOnlyOnceTheArticleShowsTheRestoredWords`,
  `takesLandsNothingForATakeTheArticleDoesNotShow`; ADDITIVE to `TakesEntryBandTests` (DEBUG):
  `aRestoreLandingFlashesItsRowEvenWithTheSettingOff`. Harness note: an inline `{ false }` predicate
  beside another closure in one test body tripped a compiler "function type mismatch" at this build —
  routed through a `pause` helper. DONE (this commit).
- B2-9 verification (headless) + the record closed: NOT STARTED.

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
