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

#### FIXES AFTER THE STAGE RUN (SF-1..3) — batch 1's implementer resumed, 2026-10-28, headless

All three were the batch's TEST harnesses, not its product code; each trace below says why, with the evidence.
- **SF-1 `CapabilityRegistryTests.takesIsNeverBehindWrite`** — traced: the walk synthesizes ONE Takes and ONE
  Write context and leaves every non-mode fact at its default; `.compareWithLatestVersion` gates on the NOTE
  fact `noteHasSavedVersion` (does the mounted note have a moment — independent of mode), so it read
  `.unavailable` in BOTH contexts and the `.native` letter (`inTakes == .act`) failed. The declaration is
  right as it stands: `mode != nil && noteHasSavedVersion` acts in EVERY mode once the note has a moment (its
  road switches to Compare itself), already pinned across all `PostMode` cases by
  `VersionDoorsTests.theLatestVersionDoorActsOnlyWhereTheNoteHasAMoment` (green on the stage). Making it act
  in Takes without the fact would break P-2 (live in Takes over a note with no moment, grey in Write).
  FIX: a JUSTIFIED EDIT of the walk, the VX-377 line's class — both contexts satisfy the note fact, so the act
  is judged on mode alone (no other act reads it). DONE (this commit).
- **SF-2 `VersionDoorsTests.thePaletteListsTheLatestDoorOnlyWhileTheNoteHasAMoment` + the 4 warnings** — the
  location `AppSession.swift:762` is `AppSession.init`'s `@Dependency(\.date) var date; self.clock = date`
  (13j-era code, unchanged by this run); the `noteHasSavedVersion` observation reads NO dependency
  (`observeLatestNoteVersion` → `AppDatabase.observe` → `Queries`) and constructs no session. TWO mechanisms:
  (1) THE FAILURE is this batch's test harness — `withDependencies { $0.database = db }` built an
  `AppSession` with no date value, so swift-dependencies' strict test-context check fired inside the test.
  FIX (at that source): the harness gives the date, as every other harness in the suite does. (2) THE FOUR
  "Test «unknown»" WARNINGS are not attributed to any test: in every log that has them (green, red2, red4)
  they print on the line right after the HOST APP's own "[protection] road: opened … (a hosted test run)",
  i.e. the host app's launch building its live session (`AppBootstrap.swift:416`,
  `AppSession(database: view, …)`) while the test run was already live; red1 (`34c21e938`) has none because
  there the road opened (log line 324) before the test run started (415), and red3 (`7715a4a3d` — a tree
  carrying ALL of batch 1, the observation included) has none either. They predate batch 1 and are independent
  of it. Their source fix would be one statement in the bootstrap's `.ready` arm
  (`withDependencies { $0.date = .now } operation: { AppSession(…) }` — byte-identical live behaviour, since
  `DateGenerator.liveValue` IS `.now`) — NOT taken here: `AppBootstrap.swift` is the protection road's
  bootstrap shared with the phone (CastleRules-read territory, outside this batch's fences, and the brief says
  keep the diff tight). CHOSEN: fix the one that is batch 1's at its source; ticket-candidate the host-launch
  four for the orchestrator (Tests & tooling · Low — the seam above). DONE (this commit).
- **SF-3 `VersionDoorsTests.theMountedPageWritesNoMemoryAndOffersNoModesOrSave`** — traced: there is NO
  writer on the version page's path; the pin was not hermetic. `CommandRouter.currentBlock(for:)` answers the
  live fact (only for `activePostID` — nil here, the same test's own expectation, green), else
  `CurrentBlockMemory.current`: the session dict (empty — a fresh session's router) and, behind it, the
  PERSISTED `currentBlock.<id>` in the test host's REAL defaults domain. Every writer of that memory was
  enumerated: `noteFocusedBlock` (drops a report for a note that is not the mounted one unless
  `remembersOtherNotes: true`, which only `EditorViewModel` and `BookIndexView` pass — neither is on the
  page; `ReadPageColumn`/`ReadPageBlock`/`BlockTOCViewModel` call it only through Read's HOST or a live pane,
  neither present) and `persist`/`persistCurrentBlocks` (the mounted note only). Meanwhile `.incrementing`
  ids repeat across suites, and a read-only `defaults read io.lduarte.Variorum.debug
  currentBlock.00000000-0000-0000-0000-000000000004` on this machine returns exactly the failing value
  (`…0005|…0006|0` — another suite's note `…0004` with its first block and take, caret at 0); the domain
  carries 10 such deterministic-id keys. FIX: the pin clears the moment's three memory keys before the
  mount (and asserts the clean slate), asserts after the mount that neither the router nor the defaults hold
  a place, removes the keys after, and gains a CONTROL — the memory's one other-note writer
  (`remembersOtherNotes`) is seen at once by the same read, so the absence above can fail. No product change:
  P-440-1 holds as built. DONE (this commit).
- **Suites the SF diff reaches** (test files only — no product code changed): `CapabilityRegistryTests`
  (`takesIsNeverBehindWrite` — all walk tests share the file) and `VersionDoorsTests` (11 tests). The
  re-run window's list stands as the record above names it (+ `WingPaletteDoorsTests`,
  `CompareVersionsTests` unchanged since the green union). `build-for-testing` into
  `DerivedData/vx440-merge` ✓ TEST BUILD SUCCEEDED at the SF tip.
- Batch 2 (Block History): BUILT HEADLESS — implementer (Opus) 2026-10-28; Mac-suite RUNS + the VX-244 red-on-old run + walk PENDING the stage window; UNIT RECORD below.

### Batch 2 — UNIT RECORD (Block History: VX-431 · riders VX-331 · VX-244)

**Not done by this unit (first line, per the contract):** nothing run on the stage — every Mac pin below
is WRITTEN AND COMPILED (`build-for-testing` into `App/Variorum/DerivedData/vx440-b2`) with its RUN, the
VX-244 red-on-old run at `c9d0b3c66`, and every walk capture (the pane at rest/open, the sheet, both
landings, both voices) PENDING for the orchestrator's stage window; the core pins RAN headless (VX-331
red-on-old verified at `c42ab4b84`, green at `fdde811b6`). NOT compiled for iOS (the shared
`VersionActs.swift` only passes `session.now` through — the phone calls no `restoreCost`). No AppSpec /
SurfaceContracts / QUESTIONS edits (the closeout's, per FOR THE CLOSEOUT).

Pieces (flipped per commit):
- B2-0 record skeleton: DONE (bb23ff0be).
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
  edge ask 2). DONE (c42ab4b84 — the PRE-FIX tree: the red-on-old SHA).
- B2-2 VX-331 fix (the 30-day window in `restoreCost`): the population-2 subselect gains
  `v.deleted_at >= :cutoff` (`TrashWindow.cutoffStamp(now:)`, the listing's `>=`). The B2-1 pin RUN GREEN
  headless (`RestoreCostTests` + `NoteVersionsTests`: 39 tests / 2 suites passed). The Mac face reads
  through `VersionActs.restoreCost` (session clock) — unchanged words. DONE (fdde811b6 — the fix).
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
  (control, green both sides: two rows, a press moves the scratch pick). DONE (c9d0b3c66 — the PRE-FIX
  tree: the red-on-old SHA).
- B2-4 VX-244 fix: one guard — the cell menu offers "Show take ▸" only when `column.kind != .main` (the
  switcher's rule). `pick`'s `.main` refusal arm is UNCHANGED (⌃⌘←/→ on the Chosen column still speaks
  J38 — `TakesParkedFollowTests.aChosenColumnPickInTheMintGapLeavesTheParkAlone` keeps driving it
  directly). The two B2-3 absence pins turn GREEN at this commit (RUN PENDING). DONE (a459fd075 — the
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
  (the plan's FOR THE CLOSEOUT already names it). DONE (44ff62f65).
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
  DONE (843841758).
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
  `bringBackUnderASealRefusesInTheStandingWords`. DONE (dbfed41bb).
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
  routed through a `pause` helper. DONE (338f9ccba).
- B2-9 verification (headless) + the record closed: `xcodebuild build-for-testing` (scheme Variorum,
  platform=macOS, `DerivedData/vx440-b2`) ✓ TEST BUILD SUCCEEDED at the final tree; core `swift test`
  (full) — VariorumCoreTests 3498 tests / 467 suites PASSED (5 known issues, pre-existing), the second
  target 32/4 PASSED, the MCP target 431/79 with ONE failure, batch 1's same load flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, a 15-s
  wall-clock bound measured 27 s under the full run's load) — re-run ALONE: 3/3 PASSED in 2.2 s (no MCP
  change in this batch). DONE (this commit).

**Batch 2's rows, dispositioned:**
- VX-331 (Bug, Confirmed): FIXED — pin `RestoreCostTests.aTakePastTheThirtyDayClockIsNotCountedAsStillRestorable`,
  RED headless at `c42ab4b84` (3 issues), GREEN at `fdde811b6`.
- VX-244 (Bug, Confirmed): FIXED, BOTH arms real — pins `ShowTakeDoorTests.theTakesArticleCellOffersNoShowTake`
  and `.theLensesChosenColumnOffersNoShowTake` committed on the pre-fix tree (`c9d0b3c66`), the fix at
  `a459fd075`; RED/GREEN runs PENDING (stage window). No hollow half.
- VX-431 (Improvement): BUILT — items 1–5 of the design (B2-5…B2-8): rows calm at rest that open in
  place, Read in full (the sheet), explainers behind (i) with header counts, restore lands and washes
  (Write + Takes), Bring back as a take (a new named core op). Her ruled structure untouched (every
  take sectioned with the focused one open, the four regions, Restore per row, no purge door, the
  *[removed for publication]*

**PROVISIONALs this unit adds (for the closeout's QUESTIONS bundle; P-440-3/-4 are the plan's own, built as written):**
- **P-440-3 (built):** the brought-back take's label = the commit's name, else none (through the take
  label's normalisation).
- **P-440-4 (built):** no structural-undo entry (`branchVariant` registers none — verified); the receipt
  "Brought back as a take — it's the last take in this block's fan." / "Brought back as the take
  “‹name›” — …" when it was named.
- **P-440-8 (the restore landing's reach):** the landing lands where the restored take is SHOWN, in the
  mode she is in — Write's detail editor (caret at the block's start, comfort band, first line washed)
  and the Takes board (the article's `.restore` landing, flashed); every other mode, the sheet hosts, and
  a restored take the surface does not show land nothing (the receipt alone). The wash is NOT governed by
  the mode-switch flash setting (its words name mode switches only); Reduce Motion's discreet variant
  holds. Options for her: (a) as built; (b) every restore lands in WRITE (the `jump(to:)` road — switching
  mode from Takes/Read/Blocks), shown take or not; (c) also land an unshown take (Takes: bloom its block;
  Write: open the take panel on it); and separately (d) let the mode-switch flash setting govern this
  wash too.
- **P-440-9 (the resting row's anatomy):** one line — the stamp · the name · a QUIET glyph (`◦`,
  automatic commits only; a deliberate one earns none, VX-144's rule) — with **Restore kept at the
  line's end** (her "Restore per row", one press as before); Name/Rename and "Read in full" moved into the
  OPEN row. No disclosure chevron (the design's anatomy lists none; the row's hover says "Show more of
  this commit"). Consequence named for her verdict: an UNNAMED commit at rest is a time and (if quiet) a
  glyph — none of her words until she opens it. Options: (a) as built; (b) the moment's first words fill
  the rest of an unnamed commit's line, faint; (c) Restore into the open row too (one more press).
- **P-440-10 (wording, all Mac-local in `BlockHistoryPane.swift`):** the region one-liners "Each take's
  saved moments." · "Set aside, out of the fan." · "On the 30-day clock." · "Kept whole and set aside —
  not deleted." (the shipped sentences verbatim behind each (i)); "Read in full" + its help; the sheet's
  "Commit · ‹when›" title; "Bring back as a take" + its help; the glyph's hover "A quiet commit — the app
  saved this moment on its own"; "Show more/less of this commit".

**For the reviewer / the orchestrator (concerns, not forks — nothing here stopped the build):**
1. **No fork on item 4:** the wash rides the 18l-c arrival flash's EXISTING overlay roads (Write's decor
   `arrivalFlashSink`, the Takes article's `ArrivalFlashFace`); no editor-seam file changed. The one
   refactor inside `EditorViewModel`: the flash's line rect moved to `lineFlashRect`, shared with the
   mode-switch flash (behaviour unchanged — `ModeSwitchFeelTests` / `ComfortBandAndFlashTests` re-run at
   the window).
2. `RestoreLanding` is defined beside its producer (`BlockHistoryPane.swift`) and read by two other
   features' models — `CompareLanding`'s precedent (defined in `CompareBoardView.swift`, held by the
   router). A value type, never a sibling's view model.
3. The TAKES landing changes `TakesArticleScroll` (a new `.restore` kind; `ArticleArrival.kind`) — the
   entry/bloom/find pins ride unmodified; the article's watch/authority code is untouched.
4. `ExplainerLine` gained an optional `tokens` (voiced arm); nil keeps every Settings/MCP host byte-for-byte.
5. The Read-in-full sheet is ONE `Text` for the whole moment (selection across paragraphs needs one
   text) — cost ∝ the moment's own length, paid once when summoned; a 10k-word block's moment lays out
   whole in the sheet. A P1 reader may want it named; recorded rather than split.
6. The `CommitsPageLedgerTests` row-height bounds (≤ 34 pt at rest, both voices) are ESTIMATES — the run
   prints the heights; a miss there is a bound to re-measure, not a defect, unless the row wraps.
7. MOBILE PARITY candidates: the phone's Block History is untouched (its face, `SavepointRowFace`, keeps
   its words); `bringBackCommitAsTake` is a shared core op a phone face could adopt.
8. AppSpec §9 owes a line for the new named operation at closeout (`bringBackCommitAsTake`), and
   SurfaceContracts (The note) the Block History clarity contract.

**Stage-window run list (the orchestrator's; suite TYPE names, built as a zsh array; compare "Executed N"):**
- RED-ON-OLD at `c9d0b3c66`: `-only-testing:VariorumTests/ShowTakeDoorTests` — 3 tests, EXPECT 2
  FAILURES (`theTakesArticleCellOffersNoShowTake`, `theLensesChosenColumnOffersNoShowTake`; each fails
  on the `menu.showTake == nil` line), the control `aScratchColumnKeepsShowTakeAndItActs` passing.
- GREEN at the batch tip (new suites' counts exact): `ShowTakeDoorTests` (3) · `BlockHistoryClarityTests`
  (6) · `RestoreLandingTests` (6 — four mounted/real-window) · `CommitsPageLedgerTests` (7) ·
  `TakesEntryBandTests` (its 10 + 1 new, DEBUG) · `BlockHistoryPaneTests` · `BlockHistorySealTests` ·
  `BlockHistoryHostTests` · `TakesParkedFollowTests` · `TakesStepFollowTests` · `TakesStepFollowModelTests`
  (pick's roads, unchanged) · `ModeSwitchFeelTests` · `ComfortBandAndFlashTests` (the shared flash rect)
  · `NoteVersionsPaneTests` (the restore confirm's cost read) · `MCPPaneTabsTests` · `MCPGrantRoadsTests`
  (`ExplainerLine`'s token-free arm) · `CapabilityRegistryTests` (registry untouched — the walk) ·
  `MCPCompareLandingTests` (the router's landing family).
- Walk rows (both voices): the pane at rest (one-line rows, header counts, (i) lines) and a row open; Read
  in full on a long commit (scroll, select) → Restore from the sheet → Write lands at the block with the
  wash; Restore from a row in Takes → the article reveals and flashes the row; Bring back as a take → the
  receipt, the new take last in the fan; the Lenses Chosen column's and the Takes article's right-click
  menus without "Show take ▸", a scratch column's with it. `BlockHistoryCommitsCaptureTests` (disabled
  capture harness, VX-144's) can re-shoot the pane in both voices if the trait is dropped for a run.

#### WALK FIXES (W-1, W-2) — batch 2's implementer, resumed 2026-10-28 after the vx440-walk

**Not done by this piece (first line):** nothing run on the stage — the three pins are WRITTEN AND COMPILED
(`build-for-testing` into `App/Variorum/DerivedData/vx440-merge`), their red-on-old and green runs and the
walk re-shoot PENDING the orchestrator's window. Tree verified clean at resume (the two untracked walk
dirs `.vx440-stagelogs/` · `.vx440-walk-shots/` are the walk's, never added); pulled to `f2cea88bb`.

Pieces (flipped per commit):
- WF-1 W-1 trace + red-on-old pins: DONE (383954445 — the PRE-FIX tree: the red-on-old SHA).
- WF-2 W-1 fix: `TakesViewModel.consumeRestoreLanding` — FIRST, on every board that hears the parcel for
  its note, a ring in a pane showing the restored take ENDS (`blur()`: its flush is the restore's already,
  nothing pending); the pane goes READ and adopts the restored words (PaneSurface's read arm, untouched);
  THEN the landing, Takes board only, unchanged. `LensesBoardView` now hears the parcel too (one
  `onChange`; it ends its ring and leaves the parcel — no Lenses landing). VX-222's shape (a ring never
  outlives the words it was typing over); no editor-seam file touched (`PaneSurface`/`EditorTextView`/
  `BlockRangeIndex` unchanged), the wash mechanics unchanged. Consequence for her (recorded under
  P-440-8): after a restore beside Takes/Lenses the ring is off that pane — one click puts her back in,
  over the restored words. Build ✓ (`vx440-merge`). The two WF-1 pins turn GREEN here (RUNS PENDING).
  DONE (this commit — the fix: the green-on-new SHA).
- WF-3 W-2 trace + seam + pin (behaviour unchanged). **The trace, as far as a headless read reaches:**
  the two roads run the SAME act (`model.restore` → the parcel → Write's landing); the ONE difference is
  the sheet — its foot did `dismiss(); onRestore(false)` and the pane ran the restore in a `Task` AT ONCE,
  so the store write, the delivery's rewrite of the block and the landing (setSelectedRange + the band +
  the wash) all ran WHILE the sheet was being dismissed: the window not key, the sheet still over the page
  (the wash ran under it — the walk's "burst came late" shot at 06:06:18 is 18 s after the restore, which
  the 06:06:00 frame already shows landed), and AppKit/SwiftUI handing the window back after the act. The
  walk's frames (`m20-w1` 06:05:49 → `m21-w0` 06:06:00) show the caret at the restored block's END — the
  signature of the delivery's `programmaticReplace` moving a caret inside the replaced block to the end
  of its new text, with no landing standing after it. WHICH dismissal-time step undid or pre-empted the
  landing (focus restoration at the sheet's end; the landing running in a non-key window) is NOT
  isolatable headless (no app, no stage); the fix removes the overlap by construction rather than
  chasing it. Seam (behaviour unchanged): the sheet's foot doors hand their act to
  `BlockHistoryModel.readingFootPressed(_:for:)` (still runs at once here), the pane's `.sheet` gains
  `onDismiss` → `readingSheetDismissed()`, and `readingTrace` records `.acted` / `.dismissed` in order.
  Pin (Mac `RestoreLandingTests`, compiled ✓, RUN PENDING):
  `aSheetRestoreLandsWhereTheRowRestoreDoesAfterTheSheetIsGone` — Write + the pane mounted side by
  side, her caret at the block's END (the walk's state), the REAL sheet presented, its Restore as the
  foot does it; EXPECT RED on this commit at the trace line (`[.acted, .dismissed]` — the act ran before
  the sheet was gone); the caret line (START) is red here only if the host reproduces the walked END —
  the run says which. DONE (this commit — the PRE-FIX tree: the red-on-old SHA).
- WF-4 W-2 fix: `readingFootPressed` RECORDS the act (`pendingReadingAct`); `readingSheetDismissed()`
  (the pane's `.sheet(onDismiss:)`) runs it, at most once — a sheet closed by Close/⎋ hands nothing over.
  The sheet's foot doors (and the pre-split confirm's Restore Anyway) hand the act over FIRST, then
  dismiss. So the sheet road IS the row road (`model.restore` / `model.bringBackAsTake`), run after the
  sheet is gone: the landing and its wash happen on the page she can see; one landing behaviour. Wash
  mechanics untouched; no editor-seam file. Build ✓ (`vx440-merge`). The WF-3 pin turns GREEN here (RUN
  PENDING). DONE (this commit — the fix).
- WF-5 verification + record: `xcodebuild build-for-testing` (scheme Variorum, platform=macOS,
  `DerivedData/vx440-merge`) ✓ TEST BUILD SUCCEEDED at every piece and at the final tree (`10476aab6`).
  No core (`Sources/`) change in the walk fixes, so the core suite's batch-2 green stands (not re-run).
  DONE (this commit).

**Walk fixes — dispositioned:** W-1 FIXED on the restore road (Takes + Lenses), red-on-old pins at
`383954445`, the fix at `872d94ec7`; the GENERAL class (an outside change to a live pane's take) recorded
above as VX-248's sibling — a closeout ticket candidate (Bug · Suspected · Takes & Lenses; related VX-248),
NOT fixed here. W-2 FIXED by construction (the sheet's act runs after the sheet is gone), the pin at
`92fb2f2d8`, the fix at `10476aab6`; the exact dismissal-time step that cost the landing is not isolated
headless — the walk re-shoot is its use evidence.

**P-440-8 gains one consequence (for her verdict):** a restore beside Takes or Lenses ENDS the ring when it
sat in a pane showing the restored take (VX-222's shape) — the pane then shows the restored words, read-
only, until she clicks back in. The alternative is a second bend of P-3 (a live pane adopting an outside
change when nothing of hers is pending) — hers/the architect's, with the general class.

**Re-run window (the orchestrator's; suite TYPE names as a zsh array; compare "Executed N"):**
- RED-ON-OLD at `383954445` (W-1 pins on the pre-fix tree): `-only-testing:VariorumTests/RestoreLandingTests`
  — 8 tests, EXPECT 2 FAILURES: `aRestoreBesideTakesLeavesTheArticleShowingTheRestoredWords` (the article
  pane's string is still "Changed since the moment, and typed into."; the pane still editable) and
  `aRestoreBesideLensesLeavesTheLiveCellShowingTheRestoredWords` (the cell's string is still "A lens
  cell's own later words."); the batch-2 six pass.
- RED-ON-OLD at `92fb2f2d8` (W-2's seam, W-1 fixed): `RestoreLandingTests` — 9 tests, EXPECT 1 FAILURE:
  `aSheetRestoreLandsWhereTheRowRestoreDoesAfterTheSheetIsGone` at its trace line (`[.acted, .dismissed]`);
  its caret line fails too ONLY if the host reproduces the walked END (report which).
- GREEN at the tip `10476aab6`: `RestoreLandingTests` (9) · `TakesEntryBandTests` (11 — the restore flash
  pin rides the changed consumer) · `TakesChooseRingTests` · `TakesParkedFollowTests` ·
  `TakesStepFollowTests` · `TakesStepFollowModelTests` (the ring/park family beside the new blur) ·
  `TakesBoardTests` · `TakesLensFilterTests` · `BlockHistoryClarityTests` (6) · `BlockHistoryPaneTests` ·
  `CommitsPageLedgerTests` (7 — the no-bezel source pin reads the pane file).
- Walk re-shoot (both voices): Takes with the ring in the restored block → Restore from a pane row → the
  article shows the restored words, washed, the ring off; the same beside Lenses (no wash — no landing
  there); Read in full → Restore → the sheet closes, THEN Write lands the caret at the block's START with
  the wash (a burst after the sheet is gone).

**W-1 — TRACED (the mechanism, inputs → wrong output):**
1. The Takes bar's history door asks for the FOCUSED block (`TakesViewModel.requestBlockHistory` → the
   ring's block), so Block History opens beside Takes on the block her ring is in — the restored take's
   ARTICLE pane is the LIVE pane (the walk's shot shows "block 2/3" in the bar — the ring's block — and the
   restored block 2 stale).
2. A live pane is BUFFER-AUTHORITATIVE: `PaneSurfaceRepresentable.updateNSView` writes projection text only
   into a READ pane (`if isLive { adoptedText = nil } else if readPaneNeedsText … { view.string = text }`);
   `PaneTextAuthority`'s contract says the same ("surfaces must never clobber a live pane with projection
   text").
3. The restore writes `working_text` from outside the pane; the board's adoption drops the authority's
   buffer (`settle` — nothing pending) and the cell's resolved text IS the restored words, but the live
   surface refuses them — it keeps the pre-restore characters. My B2-8 landing then flashed that cell: the
   wash on visibly pre-restore words (her original complaint, re-created). Write is unaffected (its editor
   re-renders a clean block from the projection — the walk confirms).
4. **The twin, worse than the display:** the live pane's next keystroke hands up its WHOLE text (old words
   + the key) through `paneEdited` → autosave → the restore is silently overwritten (one writer, never a
   sync conflict). The same cell class on the LENSES board (its own history door → the inspector pane
   beside a live cell). Pre-existing before batch 2 (any Block History restore beside a live Takes/Lenses
   pane), surfaced by the landing's wash.

**VX-248's relationship — read, not assumed:** VX-248 LANDED (vx-601 batch A, `b1a82dc3`, ACCEPTED
2026-10-27 — red-on-old by revert, walk W3/W4 PASS; merged into this branch tonight). It is HER RULED bend of
P-3 for a RE-BIND only: `Coordinator.rebindIfTakeChanged` runs when the pane's BOUND take id changes
(`guard variantID != boundVariantID else { return false }`) and then adopts the new take's text. A restore
keeps the take's id, so VX-248's machinery does not fire — by its own design, not unfinished. Extending
the bend to "the bound take's text changed from outside" would be a second bend of P-3 (a decision about
when a live pane adopts, in `PaneSurface` — the editor seam) that her ruling did not make. So: the NARROW
fix on OUR road (WF-2), and the GENERAL class recorded below as VX-248's sibling.

**The general class (comment-worthy; a closeout ticket candidate, related to VX-248 — NOT reopened here):**
a LIVE pane whose take's text changes from OUTSIDE the pane keeps — and on the next keystroke writes back —
the old words. Roads that reach it today, by reading: a Block History restore beside Compare / Canvas /
Write's take panel (the narrow fix covers Takes and Lenses only), a sync apply of `working_text` under a live
pane, the MCP door's `edit_take` / `restore_commit` on a take she has live in Takes/Lenses (the door
flushes her typing FIRST, then edits — the live pane keeps her words, and her next key overwrites the AI's
edit), another window's restore. The design question is hers/the architect's: end the ring (VX-222's shape,
what WF-2 does on this road) or a second P-3 bend (adopt on an external change when nothing is pending).

Pins (Mac, `RestoreLandingTests`, compiled ✓, RUNS PENDING — EXPECT RED on this commit, the pre-fix tree):
`aRestoreBesideTakesLeavesTheArticleShowingTheRestoredWords` (mounted Takes board, the ring live in the
restored block's article pane, the pane road's restore; red line: the pane's string ≠ the restored words —
it still reads the pre-restore text; also the pane still editable) and
`aRestoreBesideLensesLeavesTheLiveCellShowingTheRestoredWords` (the Chosen column's live cell; red line:
the cell's string).

#### W-2, second pass (2026-10-28, after vx440-reshoot) — CAN'T TRACE the concrete cause headless; NO FIX applied

**First line, per the bounds:** I could NOT trace the concrete mechanism from the code. I narrowed it to
ONE link by elimination (below), but I cannot name the SwiftUI/AppKit step that breaks that link on the
sheet road, so — as the coordinator's bound requires — no fix was made this pass. **The sheet road's
LANDING ships as a named ticket**; the first pass's ORDER fix (`10476aab6` — the act runs from the
sheet's `onDismiss`, walk-verified: the sheet fades, closes, THEN the words change) stays as landed.
Tree clean at resume (the walk dirs untracked), pulled to `2224e2bd4`.

**The elimination (what the code and the reshoot frames prove):**
1. *The act ran and posted its parcel.* The pane's receipt "Saved moment restored into this take…" is on
   screen (`reshoot-c-4…f06`, `c-5`), and in `BlockHistoryModel.restore` the parcel assignment is the
   statement after that receipt, same success arm — so `CommandRouter.pendingRestoreLanding` was set.
2. *The editor applied the restored words.* The block changes from "…was saved. Write typed a third
   ending, to be undone by the sheet." (`c-1`) to "…was saved." (`c-4`), i.e. the delivery ran
   `applyProjection` → `.refetchFresh` → a fresh read → `.differential` → `programmaticReplace` →
   `adoptRewrite` (slots now hold the restored text) → the storage edit bumps the overlay generation →
   the next `viewWillDraw` schedules the settle hop. The caret at the block's END is exactly that
   rewrite's signature (block 2/2 is the note's last block; a caret at the replaced range's end rides to
   the new text's end) — with no landing standing after it.
3. *Every guard downstream of consumption passes on this state.* Once `EditorViewModel.consumeRestoreLanding`
   holds the parcel, `landRestoreIfShown` lands at the first hop after the rewrite unless: the 2-s patience
   ran out (measured from CONSUMPTION, so a late consume still lands at once — and `c-5`, 28 s later, still
   shows END), the coordinator was dirty (no typing in the burst), the page renders another take (one take
   here), or the slot's text differs from the parcel's (the same commit's text on both sides). None holds.
4. *A landing that ran and was then undone is ruled out by the frames:* its wash is a decor subview that
   only a new flash, the flash's own end, or the text view's teardown removes, and none of the 16 burst
   frames to +1.55 s shows it; a teardown-and-remount would land the fresh editor at her REMEMBERED caret,
   which the landing had just reported as the block's START (`updateCaretContext`) — not END.
5. **So the one link that failed:** the detail editor's consumer never ran with the parcel in hand. Its
   only road is a PUSH — `EditorView`'s `.onChange(of: session.commandRouter.pendingRestoreLanding)`,
   delivered only when SwiftUI re-evaluates EditorView's body after the parcel changes (an equality-gated
   change notification). On the row road that push arrives (the control landed at +0.23 s); on the sheet
   road it evidently does not.
6. **What I could not establish from the code:** WHY that push is missed after a sheet presented from the
   inspector is dismissed. Read and excluded: the editor's identity (`.id("\(postID)-caret-…")` and the
   detail's `landingGeneration` key — neither moves on this road), the pane mount rule (the window
   registry's sticky key-ness ignores sheet windows — `WindowRegistry.noteKey`), the router's clears
   (`registerDetail` for another note / `unregisterDetail` — no road here), the other consumers
   (`TakesViewModel.consumeRestoreLanding` is called only by mounted Takes/Lenses boards; none is mounted in
   Write). The candidates left are inside SwiftUI's update graph across the sheet's teardown (EditorView's
   observation not re-registered for the parcel after the dismissal transaction; or the parcel's change and
   its clearing landing within one update so the gate sees no change) — not observable without the app,
   and **the host does not reproduce it**: `aSheetRestoreLandsWhereTheRowRestoreDoesAfterTheSheetIsGone`
   (the real sheet presented and dismissed in a hosted window, the pane BESIDE the detail rather than
   inside its inspector as in the app) lands at the START in-host.

**The pin's limit, stated honestly:** that pin holds the ORDER (red-on-old verified at `92fb2f2d8`,
reshoot rb6 — exactly its trace line failed) and the in-host landing; it does NOT reproduce the app's lost
landing, so the walk re-verify is the evidence of record for that half.

**For the ticket (the landing half — Bug · Confirmed · Takes & Lenses, related VX-431; Mac-only):**
- *Mechanism to establish first (needs the app):* a DEBUG trace on the sheet road of (a) the parcel's post
  time, (b) EditorView's `onChange` fire time and the value it read, (c) the settle hop's time — against the
  row road's. One run says which of the two SwiftUI candidates it is.
- *The likely fix shape, for the architect (NOT built — it would be a blind fix today):* the sink law —
  the consumer PULLS when its surface is ready instead of relying only on the equality-gated push: the
  settle hop after a rewrite takes a parcel for its note that it has not yet seen (with a posted-at stamp
  inside `RestoreLanding.patience`, so a parcel left standing by the Lenses board — which deliberately does
  not take it — can never land a later ARRIVAL). The row road's semantics stay exactly as they are (its push
  consumes first; the pull then finds nothing).
- *Pin:* the trace above, once it names the step, decides whether a hosted pin can reproduce it (the pane
  INSIDE PostDetailView's inspector, opened through `requestBlockHistory`, is the first thing to try — the
  current pin mounts it beside the detail).

**Hashes:** no code commit this pass; the record only (this commit). No build needed (no code change);
`build-for-testing` at the tip is the first pass's green (`10476aab6`, `vx440-merge`).

- Batch 3 (gathering faces): BUILT HEADLESS — implementer (Opus) 2026-10-28; Mac-suite RUNS + the two red-on-old Mac runs + walk PENDING the stage window; UNIT RECORD below.

### Batch 3 — UNIT RECORD (gathering faces: VX-611 · VX-616 · VX-189 · rider VX-356)

**Not done by this unit (first line, per the contract):** nothing run on the stage — every Mac pin below is
WRITTEN AND COMPILED (`build-for-testing` into `App/Variorum/DerivedData/vx440-b3`, cloned from
`vx440-merge` by APFS clone) with its RUN, the two red-on-old Mac runs (VX-611 at `7715a4a3d`, VX-356 at
`0d963ce22`) and every walk capture PENDING for the orchestrator's stage window; the core pins RAN headless
(VX-189's fence pin red on the pre-fix query, then green). NOT compiled for iOS (the shared
`RecoveryCopy.swift` / `RecoveryActs.swift` gained only defaulted parameters and one overload; the core
`TrashItem` init a defaulted parameter — the phone's calls are unchanged in source). No canon / QUESTIONS /
AppSpecRecord edits (the closeout's — drafted below). The guide's MCP lesson 5 card was NOT touched
(`TutorialSeeder.swift` is VX-648's seam this window — see the concerns).

*Read in this session's own context before any code: CLAUDE.md + its canon, THIS FILE in full,
`notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · The Bookcase and books · Doors to the
outside), `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md` (MB-18, MB-19, the BATCH 3 RECORD),
`notes/SessionResiliencyProtocol.md`, and the code anchors the brief names. No subagent.*

Pieces (flipped per commit):
- B3-0 record skeleton: DONE (3b5e40b99).
- B3-1 VX-611 trace + seams + red-on-old pins (behaviour unchanged): VERDICT — REAL, both halves, traced.
  (a) THE ROW'S DOOR: `.deleteBook` is ONE capability whose declared verb is the book's
  (`BookStateCopy.deleteVerb` = "Delete Book"); every renderer of its door on a ROW glued that verb to an
  ellipsis — `BookRowMenu` (:211 — the Library List's Books section, the sidebar's Starred book rows, the
  Archived books group's right-click), the Bookcase row's context menu (`ShelfView.bookMenu` — the VX-620
  walker's W-4 sighting), the Archived books group's own button (`ArchivedView.bookRow`) — and the rule
  editor's gathering gate hovered the same verb; the confirm a gathering's door opens already said
  "Delete Gathering" (`BookStateCopy.deleteGathering`). (b) THE TRASH: `Queries.trash`'s book arm reads
  `reading` rows of either kind into ONE `.book` kind with no kind fact, so `RecoveryCopy.rowKind(item)` (the
  one row rule, the phone's accessibility labels included) answered "book"; the row's Delete Now confirm
  ("Delete this book for good?"), its receipt ("The book is gone…") and the plain Put back receipt ("Book
  put back.") read the same `.book` kind. Seams (words unchanged): `BookStateCopy.deleteVerb(_:)` /
  `deleteDoorLabel(_:)` (the book's words for both kinds at this commit) — the four renderers draw through
  them; core `Queries.TrashItem.isGathering` (defaulted init parameter; the book arm selects the row's own
  `kind` in the same statement). Pins: core `TrashAndArchiveTests.aDeletedGatheringRowsOnTheBookArmAndKnows
  ItIsAGathering` (the seam's fact — RUN GREEN headless); Mac NEW `GatheringKindWordTests` (compiled ✓
  `build-for-testing` into `DerivedData/vx440-b3`, RUNS PENDING): `theRowsDeleteDoorSaysGatheringOnAGathering
  AndBookOnABook` · `theTrashCallsADeletedGatheringAGathering` · `aDeletedGatheringsDeleteNowAsksAndAnswersIn
  ItsOwnKind` · `aPutBackGatheringSaysGatheringPutBackAndABookStillSaysBook` — RED ON OLD at this commit (the
  words are still the book's) — and the guard `everyRowRendererOfTheDeleteDoorChoosesItsWordsByKind` (green
  both sides by design). DONE (7715a4a3d — the PRE-FIX tree: the red-on-old SHA).
- B3-2 VX-611 fix (the kind word): `BookStateCopy.deleteVerb(.gathering)` = "Delete Gathering" (so every row
  door reads "Delete Gathering…" on a gathering; a book's stays "Delete Book…"; the registry's ONE declared
  verb is untouched — P-1); `RecoveryCopy.gatheringRowKind` ("gathering") through ONE rule,
  `rowKind(_:isGathering:)`, read by `rowKind(item)` (the row's word — the phone's accessibility labels ride
  it), and by `deleteNowConfirm` / `deleteNowReceipt` / `putBackReceipt`, each with a DEFAULTED
  `isGathering:` (the `isVersion`/`versions:` precedent — every shipped caller and pin byte-identical), the
  shared acts (`TrashPurge.Confirm.message`, `TrashPurge.confirm`, `TrashPutBack.run`'s plain arm) passing the
  row's fact. The Mac Trash row's Put back hover on a gathering: "The gathering comes back with its rule"
  (was "The book comes back whole — chapters and membership included", false of a gathering — PROVISIONAL
  P-440-13). The four B3-1 words pins turn GREEN at this commit (RUN PENDING). `build-for-testing` ✓.
  DONE (fe94dbbd7 — the fix: the green-on-new SHA).
- B3-3 VX-616 the gathering foot loses "+ new chapter" (a ruled DESIGN row — pinned by the list the foot
  renders from, plus the walk's capture; no red-on-old by the contract): `BookView`'s navigator foot on a
  gathering no longer draws "+ new chapter" or its hover ("Chapters need a book that holds its notes — this
  offers to bind…"); it renders `BookFootDoors.gathering()` = `[.newNote]` (NEW, beside VX-553's
  `BookFootDoors.book`) → the `GatheringNoteDoor` exactly as before (VX-217's always-drawn, greys-and-says-
  why door). Books keep their foot byte-unchanged. "Bind into a Book…" (`.bindIntoBook`, the Bookcase row's
  menu) and the hand-drag teaching offer are untouched. The registry: `.bindIntoBook`'s declaration comment
  no longer names the navigator's chapter door as a bind road (it was never a declared door — the registry
  walk's unions are unchanged and stay green). Pin (Mac, compiled ✓, RUN PENDING): `BookFootDoorsTests
  .aGatheringsFootIsTheNoteDoorAloneAndABookKeepsItsChapterDoor`. Tutorial (P-6) checked: its "＋ new chapter"
  sentences are about BOOKS ("a book from the inside", "membership, not ownership") — unaffected. DONE
  (486d05c5d).
- B3-4 VX-616 the unreachable `.createChapter` bind follow-up retired (its own commit, so the ladder can
  weigh it apart from the ruled removal): the gathering foot's door was the ONLY road that opened the bind
  with `BindFollowUp.createChapter` (the teaching offer opens it with none; the Bookcase row's bind passes
  none) — with the door gone, the follow-up's machinery was reachable by no road: `BindFollowUp` (the enum),
  `BindOffer.followUp`, `BindOffer.load(followUp:)`, `BookStructureModel.openBindOffer(followUp:)`, the
  three `.createChapter` word arms ("Bind “x” into a book to add chapters?", "Bind & Add Chapter", "Chapters
  need a book that holds its notes…") and `BookView`'s bind-then-open-the-chapter-prompt branch. RETIRED
  (dead code removed, not parked): `BindCopy.title(_:)` / `BindCopy.confirm` / `BindCopy.explanation(count:
  hearsActs:)` keep the bind's own words byte-for-byte. The bind's live roads are unchanged (the Bookcase
  row's "Bind into a Book…", the teaching offer, ⌥⌘Z's un-bind). JUSTIFIED pin edits (each comment says so):
  `BindDoorTests.theBindWordsSayTheTruthAtEveryCount` (the chapter arm's words → the bind's at count 3),
  `.aHandDragInAGatheringOffersTheBindAndItsActOpensTheConfirm` (its `followUp == .none` line gone with the
  field), `.theChapterDoorOpensTheBindWithItsCountAndItsFollowUp` → RENAMED
  `.theBookViewsBindRoadCarriesItsCountAndItsOrder` (the same road and its count/order carriage, minus the
  follow-up), `VocabularySweepTests.theCollectingPromiseIsTrueOfTheRule` (the parameter only);
  `BookOrderConversionTests` comments only. `build-for-testing` ✓. DONE (94a1486fd).
- B3-5 VX-189 the gathering's own Shared-with doors — BOOK PARITY, faces only (no wire tool, no grant
  semantics, no new reach: every door opens THE one grant sheet, whose confirm is `grantMCPAccess`'s gathering
  arm, VX-549's, untouched). MCPSpec read in full first. What a book's place doors had and a gathering's
  lacked, traced: (1) Book Settings' "Shared with" row — `BookSettingsFace.showsGrantRow` required
  `kind == .book` and `BookSettingsModel.isGrantable` read `Queries.mcpBookFacts` (books only); the held reach
  (`Queries.mcpBookReach`) ALREADY answered a gathering through `decideGathering`. (2) The row menus' "Share
  with AI…" — `BookRowMenuTable.doors` (the Library's / Starred's / Archived's right-click) and the Bookcase
  row's menu (`ShelfView.bookMenu`) required `kind == .book`, and the fence they read
  (`Queries.mcpFencedBookIDs`) named books only. (3) Every door opened `.book(id)`. Built: CORE —
  `mcpFencedBookIDs` reads `kind IN ('book', 'gathering')` on the SAME two fragments (a stale Private stamp /
  'daily' marker on a gathering — no op mints either; the op's gathering arm already refuses one), so it is
  the exact complement of the sheet's offered books AND gatherings; pin `MCPShareTests
  .theFencedSetNamesTheGatheringsTheSheetNeverOffers` RUN RED headless on the pre-fix query (2 issues: the set
  missed both stale gatherings) then GREEN (`MCPShareTests` 17/1 passed). APP — `MCPGrantPrefill.reading(_:)`
  (the ONE switch: a gathering's place is `.gathering`, a book's `.book`); `isGrantable` reads
  `mcpBookFacts ?? mcpGatheringFacts`; `showsGrantRow` drops the kind gate (superseding P-VX185-2's
  no-sharing-line and VX-549's MB-18); `grantRowCaption(_:kind:)` — "No client reaches this gathering." on a
  gathering (`MCPShareCopy.notShared(_:)`, PROVISIONAL P-440-11; a book's words unchanged);
  `BookSettingsFace.grantOpening(for:)` (Share… → the sheet on the reading's own place, WHO asked, nothing
  replaced); `BookRowMenuTable.doors` draws `.share` on any shareable reading and its button opens
  `.reading(reading)`; `ShelfView.bookMenu` the same. The registry: no declaration changed (`.mcpShareHere`
  `.contextMenu` / `.mcpShareBook` `.surface` already declared and rendered — the walk's unions unchanged);
  one doc line on the case (`Capability.swift`). Change…/Revoke: the Book Settings row carries neither
  (a book's never did); the shared icon's popover (Change…/Revoke) already reads a gathering's own grant since
  VX-549 — untouched. Pins (Mac `MCPShareFacesTests`, compiled ✓, RUNS PENDING): the "place doors unbuilt"
  messages FLIPPED to assertions — `theBookRowMenuDrawsShareOnlyOnAShareableBook` (a gathering's row draws it;
  ungated it doesn't), `theBookSettingsGrantRowDrawsOnlyWhereAGrantCanLand` (a gathering's row draws, gated
  as a book's), `theGrantRowsGateIsTheFencesOwnAnswer` ("a gathering is never grantable" flipped; a stale-
  fenced gathering joins the parity sweep); NEW `aGatheringsPlaceDoorsOpenTheSheetOnTheGathering` (the
  prefill switch, the opening, the caption, no "AI") and `aGatheringsSharedWithRowReadsItsOwnGrantAndOpens`
  (the settings model's held read on a gathering: the gate opens, its own grant named with no "through" —
  red on old by the gate). DONE (f4aaef4a9).
- B3-6 VX-356 verify (trace) + seam + red-on-old pins (behaviour unchanged): VERDICT — REAL (by trace; not
  by design). The panel marks the open note with the voice's selection glyph (`BookPanelView.marker` —
  `tokens.selectionMarker`: Terminal "› ", Study ""), and its own doc names Study's design: "Study's empty
  marker leaves the weight and the ink to say it" — a NOTE row does (open: semibold + ink; else regular +
  muted). A COLLAPSED one-note chapter row IS its note's row (row 8) and drew the same glyph (`if marked {
  marker }`), but its name is ALWAYS semibold and in the accent (`chapterRow`) — so in Study the open note's
  collapsed chapter row was pixel-identical to every other chapter row: no glyph, and no weight or ink left
  to say it. The design's own premise fails on exactly this row, so the gap is a defect, not a choice.
  (Adjacent, NOT touched — one surface: the book NAVIGATOR's `NavigatorChapterLabel` has the same shape — a
  collapsed one-note chapter's note mark is the glyph only, so Study shows nothing there either outside
  Outline's viewed-chapter wash; a ticket candidate for the orchestrator.) Seam: `BookPanelBrain.OpenNoteMark`
  (`.none` · `.glyph(String)` · `.fill`) and `chapterRowMark(_:openPostID:selectionMarker:)` — at this commit
  answering the OLD rule (the glyph, else `.none`); the chapter row draws from it; DEBUG `BookPanelMarkProbe`
  records what each mounted chapter row drew. Pins (Mac NEW `BookPanelOpenNoteMarkTests`, compiled ✓
  `build-for-testing`, RUNS PENDING): `theOpenNotesCollapsedChapterRowIsMarkedInEitherVoice` (pure; its
  Study leg RED ON OLD, the Terminal and not-the-open-note legs guards) and mounted
  `theMountedPanelMarksTheOpenNotesChapterRowInStudyAndTerminal` (the theme store STARTED so the fresh
  store reads Study; the probe's Study leg RED ON OLD — `.none`; then `setThemeVoice(.terminal)` → the ›).
  DONE (0d963ce22 — the PRE-FIX tree: the red-on-old SHA).
- B3-7 VX-356 fix (ONE voice-tokened mark): `chapterRowMark` answers `.fill` where the voice has no glyph
  (Study); Terminal's `.glyph("›")` unchanged. The face: the chapter row wears VX-562's viewed-chapter
  composition — `BookNavigatorLayout.viewedChapterFill(tokens)` (the voice's accent at 0.22, measured
  ≈1.33–1.39:1 against the room in both voices/schemes at VX-562) as a rounded `.background` behind the row,
  and the name in INK (`chapterNameInk(tokens, viewed: true)` — the accent name on an accent fill falls under
  the palette's selected-row floor; ink clears 4.5:1). An OVERLAY behind the words, never a rendering
  attribute (P-8); drawn inside the row's own frame (the grip slot is its leading air — VX-562's `washBleed`
  NOT ported: the panel's scroll/row geometry is untouched), so no word, row or drop site moves. Token-only,
  no literal colour. PROVISIONAL P-440-12 (the face is hers). The two B3-6 Study legs turn GREEN at this
  commit (RUN PENDING); `build-for-testing` ✓, no new warning in a touched file. DONE (8505d937f — the fix:
  the green-on-new SHA).
- B3-8 verification (headless) + the record closed: `xcodebuild build-for-testing` (scheme Variorum,
  platform=macOS, `DerivedData/vx440-b3`) ✓ TEST BUILD SUCCEEDED at the final tree (`8505d937f`; this
  record's commit changes no code); no new warning in a touched file (ShelfView's `Text +` deprecations at
  :362/:813 are pre-existing lines; the clone's "Stale file … outside the allowed root paths" lines are the
  clone's, harmless). Core `swift test` (full) — VariorumCoreTests **3500 tests / 467 suites PASSED** (5
  known issues, standing — batch 2's 3498 + this batch's 2), StringsWorkbook 32/4 PASSED, VariorumMCPTests
  431/79 with ONE failure, the standing load flake (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswers
  InitializeFailsTheConnectNamedAndBounded`, 28 s vs its 15-s bound under the full run) — re-run ALONE: 3/3
  PASSED in 2.2 s (no MCP-target code touched). DONE (this commit).

**Batch 3's rows, dispositioned:**
- VX-611 (Bug, Wording, Confirmed): FIXED — a gathering's row door reads "Delete Gathering…" (the Bookcase
  row's menu, `BookRowMenu`, the Archived group's button; the rule editor's gate hover "Delete Gathering"),
  the ONE capability kept (P-1); the Trash calls a deleted gathering a gathering (row word, Delete Now confirm
  + receipt, Put back's plain receipt; its Put back hover). Pins `GatheringKindWordTests` (4 words pins
  committed RED on `7715a4a3d`, fixed at `fe94dbbd7`; a renderer guard) + core
  `TrashAndArchiveTests.aDeletedGatheringRowsOnTheBookArmAndKnowsItIsAGathering` (green). RED/GREEN Mac runs
  PENDING.
- VX-616 (Improvement, RULED): BUILT — the gathering foot's "+ new chapter" and its hover removed
  (`486d05c5d`); the follow-up no road reached retired (`94a1486fd`). Design-row pin
  `BookFootDoorsTests.aGatheringsFootIsTheNoteDoorAloneAndABookKeepsItsChapterDoor` + the walk's capture.
- VX-189 (Feature, MCP — repurposed): BUILT — book parity: Book Settings' Shared-with row on a gathering, the
  row menus' Share with AI… on a gathering, both opening THE grant sheet on the gathering (`f4aaef4a9`).
  No wire / grant-semantics / reach change; Private, Seal, Own untouched. Pins: core `MCPShareTests
  .theFencedSetNamesTheGatheringsTheSheetNeverOffers` (red headless on the old query → green); Mac
  `MCPShareFacesTests` (three flips + two new), RUNS PENDING.
- VX-356 (Improvement, Suspected → CONFIRMED by trace): FIXED — Study marks the open note's collapsed chapter
  row with the navigator's viewed-chapter fill + ink; Terminal keeps its ›. Pins
  `BookPanelOpenNoteMarkTests` (both committed RED on `0d963ce22`, fixed at `8505d937f`), RUNS PENDING. Not
  hollow, not by design (the design's own premise — weight and ink say it — has nothing to say with on a
  chapter row).

**PROVISIONALs this unit adds (for the closeout's QUESTIONS bundle):**
- **P-440-11 (VX-189 wording):** a gathering's Shared-with row, unshared, reads "No client reaches this
  gathering." (the book's "…this book." kept). Options: (a) as built; (b) one kind-neutral sentence for
  both ("No client reaches this yet.").
- **P-440-12 (VX-356's Study face):** the open note's collapsed chapter row in Study wears the navigator's
  viewed-chapter face (VX-562's accent fill at 0.22 behind the row, the name in ink), inside the row's frame
  (no bleed). Options: (a) as built; (b) the name in ink only, no fill (quieter; reads as "different", less
  as "here"); (c) a Study glyph on that row only (e.g. a small accent dot — a new token, both platforms'
  theme file); (d) the fill ALSO in Terminal beside its ›.
- **P-440-13 (VX-611's extent + one hover):** the kind word reaches every sentence the Trash says about the
  row in hand (its word, Delete Now's confirm and receipt, Put back's plain receipt), the Archived group's
  delete button and the rule editor's gate hover — beyond the ticket's two named sightings, by the same one
  rule; the Trash row's Put back hover on a gathering reads "The gathering comes back with its rule" (the
  book's "chapters and membership included" was false of a gathering). NOT changed (counts, not a row's
  word): the kind filter's "Books" and Empty Trash's count ("1 book" counts a gathering among the
  readings, as its filter does). Options for the counts: (a) as built; (b) Empty Trash names gatherings
  apart ("1 book, 1 gathering").

**For the reviewer / the orchestrator (concerns, not forks — nothing here stopped the build):**
1. **B3-4 is a cleanup beyond the ruled removal**, in its own commit so it can be weighed apart: the
   `.createChapter` bind follow-up had no road left once the door went (the teaching offer and the Bookcase's
   bind pass none). Retired whole; the bind's own words and live roads byte-unchanged; four justified pin
   edits. Revertible alone if the ladder prefers the machinery parked.
2. **VX-611 reaches two renderers the ticket did not name** (the Archived group's button, the rule editor's
   gate hover) and the Trash's row-scoped sentences — the same one rule, so a row never says "gathering" in
   one place and "book" in the next (P-440-13). The registry's declared verb stays "Delete Book" (P-1: one
   capability; the kind chooses the drawn words, as `CollectingCopy.openVerb(isBook:)` already did for
   Book/Gathering Settings…).
3. **VX-189's fence read grew** (`Queries.mcpFencedBookIDs` names fenced gatherings): a core query, not the
   grant op (whose gathering arm already refused a fenced gathering on the same facts). Its other reader, the
   Bookcase's held sharing snapshot (`ShelfViewModel`), only gains the same truth.
4. **VX-189 left the guide's MCP lesson 5 card as it is** ("Right-click a note in the Library, or a book on
   the Bookcase or in the Library, and choose Share with AI…" — true, now incomplete for gatherings):
   `TutorialSeeder.swift` is VX-648's seam this window; a copy-pass line (VX-234) or the closeout's, not a
   defect.
5. **VX-356's adjacent remainder (NOT touched — one surface):** the book NAVIGATOR's collapsed one-note
   chapter row has the same Study gap outside Outline (`NavigatorChapterLabel` draws the note mark as the
   glyph only) — a ticket candidate (Books · Improvement · Confirmed by trace).
6. The fill's contrast on the panel's `surface` (not the room VX-562 measured against) is a walk-check item
   (both voices, light and dark, a palette or two).
7. MOBILE PARITY candidates: the phone's book-details "Delete Book…" door (`MobileShelfFaces
   .deleteBookDoorTitle`) on a gathering, if the phone lists gatherings there — VM's own pass; the shared
   Trash words already reach the phone (its accessibility labels and receipts ride `RecoveryCopy`). The phone
   has no Book Panel and no MCP faces.

**Canon owed at the closeout (DRAFTED — not applied; the two-file rule):**
- **SurfaceContracts, The Bookcase and books — the Delete bullet:** "…rows Open, Unarchive, Delete Book…
  (never Delete on the daily Journal)" → add "— Delete Gathering… on a gathering, everywhere the door draws
  (the one capability's verb by kind; VX-611)"; and after "The Trash row says “and N notes”" add "a deleted
  gathering's row, its Delete Now and its receipts call it a gathering (VX-611)".
- **SurfaceContracts, The book settings sheet:** add "Its Shared-with row (who reaches it, with Share…) draws
  on a book and a gathering alike — only while a client is approved and a grant can land — and Share… opens
  the grant sheet on that place (VX-189; `notes/MCPSpec.md`)."
- **SurfaceContracts, The Book Panel:** add "the open note marked in both voices — on a collapsed one-note
  chapter row, Study wears the navigator's viewed-chapter fill (VX-356, PROVISIONAL P-440-12)".
- **SurfaceContracts, The Bookcase and books (the book's mode row / navigator):** add "A gathering's navigator
  foot carries “+ new note” only; binding is the row menu's Bind into a Book… and the hand-drag's teaching
  offer (VX-616)."
- **MCPSpec, the gathering-place paragraph (VX-549's):** add "**A gathering's own place doors (VX-189 — her
  word 2026-10-28, superseding P-VX185-2 and MB-18):** Book Settings' Shared-with row and the row menus'
  Share with AI… draw on a gathering as on a book, opening THE grant sheet on the gathering (nothing
  replaced; the fence and VX-272's approved-client gate as a book's) — faces only, no wire or reach change."
- **The dated entry + narrative → `notes/AppSpecRecord.md`** (her VX-616 ruling and VX-189 repurpose in her
  words; the VX-611 trace; VX-356's verdict).

**Stage-window run list (the orchestrator's; suite TYPE names, built as a zsh array; compare "Executed N"):**
- RED-ON-OLD at `7715a4a3d`: `-only-testing:VariorumTests/GatheringKindWordTests` — 5 tests, EXPECT 4
  FAILURES (`theRowsDeleteDoorSaysGatheringOnAGatheringAndBookOnABook`, `theTrashCallsADeletedGathering
  AGathering`, `aDeletedGatheringsDeleteNowAsksAndAnswersInItsOwnKind`, `aPutBackGatheringSaysGathering
  PutBackAndABookStillSaysBook`), the guard `everyRowRendererOfTheDeleteDoorChoosesItsWordsByKind` passing.
- RED-ON-OLD at `0d963ce22`: `-only-testing:VariorumTests/BookPanelOpenNoteMarkTests` — 2 tests, EXPECT 2
  FAILURES (each on its Study leg: `.fill` expected, `.none` drawn); the Terminal legs pass.
- GREEN at the batch tip (`@Test` declarations per touched file): `GatheringKindWordTests` (5) ·
  `BookPanelOpenNoteMarkTests` (2) · `BookFootDoorsTests` (3) · `MCPShareFacesTests` (20) · `BindDoorTests`
  (11) · `VocabularySweepTests` (19) · `BookOrderConversionTests` (13); the neighbours `TrashBookNotesTests`
  · `TrashSurfaceTests` · `TrashPoolHonestyTests` · `TrashPurgeDoorsTests` · `TrashConfirmEdgeTests` ·
  `TrashPurgeSharedLayerTests` · `SnippetGroupTrashTests` · `IAAndTrashShapeTests` (the Trash words' roads) ·
  `BookRowMenuTests` · `BookDeleteAndDuplicateTests` · `TutorialBooksLessonTests` ·
  `TutorialBooksRitualTests` (`deleteVerb`) · `BookPanelBrainTests` · `BookPanelDeclarationTests` ·
  `BookPanelActingTests` · `BookPanelMCPMarksTests` · `BookPanelDragGateTests` · `BookOutlineViewedTests`
  (the fill's token maths) · `MCPGatheringGrantFacesTests` · `MCPGatheringIconTests` · `MCPGrantSheetTests`
  · `CapabilityRegistryTests` (the walk — no declaration changed).
- Walk rows (both voices; a client approved for the VX-189 rows): (1) a gathering's right-click on the
  Bookcase, in the Library's Books section and in Archived → "Delete Gathering…" (a book's "Delete Book…");
  delete one → the Trash row says "gathering", its Delete Now asks "Delete this gathering for good?", Put
  back says "Gathering put back."; (2) a gathering open → the navigator's foot shows "+ new note" only (a
  book's keeps "+ new chapter"); the row menu still offers Bind into a Book…; a hand-drag still offers the
  bind; (3) Gathering Settings… → the "Shared with" row ("No client reaches this gathering." → Share… → the
  grant sheet with WHERE = the gathering → grant → "Shared with ‹client› (…)"); the gathering's right-click
  → Share with AI… → the same sheet on the gathering; (4) a note that is a chapter's only note (named as its
  chapter) open with the Book Panel up: Study → the row washed, its name in ink; Terminal → the ›.

**Files touched (this batch):** Core `Sources/VariorumCore/Queries/Trash.swift` (`TrashItem.isGathering`,
the book arm's `kind`) · `Sources/VariorumCore/Queries/MCPGrantQueries.swift` (`mcpFencedBookIDs`). App:
`App/Variorum/Shared/RecoveryCopy.swift` · `App/Variorum/Shared/RecoveryActs.swift` ·
`Variorum/Core/Views/BookRowMenu.swift` · `Variorum/Core/Views/MCPShareRoad.swift`
(`MCPGrantPrefill.reading`, `MCPShareCopy.notShared(_:)`) · `Variorum/Features/BookView/BookPanelModel.swift`
· `BookPanelView.swift` · `BookSettingsSheet.swift` (the grant row's gate, caption and opening; the
`isGrantable` read — NOT the Private row, VX-648's) · `BookStructureModel.swift` · `BookView.swift` (the
gathering foot, the bind sheet's follow-up branch) · `Variorum/Features/Library/ArchivedView.swift` ·
`RecoveryView.swift` · `Variorum/Features/Readings/BookOrderAndConversion.swift` · `BookStateDoors.swift` ·
`RuleEditor.swift` · `Variorum/Features/Shelf/ShelfView.swift` · `Variorum/Registry/Capability.swift` (one doc
line) · `Variorum/Registry/CapabilityRegistry.swift` (`.bindIntoBook`'s comment only). Tests: NEW Mac
`GatheringKindWordTests.swift`, `BookPanelOpenNoteMarkTests.swift`; edited Mac `MCPShareFacesTests.swift`,
`BookFootDoorsTests.swift`, `BindDoorTests.swift`, `VocabularySweepTests.swift`,
`BookOrderConversionTests.swift` (comments); core `TrashAndArchiveTests.swift`, `MCPShareTests.swift`.
Commits: `3b5e40b99` · `7715a4a3d` · `fe94dbbd7` · `486d05c5d` · `94a1486fd` · `f4aaef4a9` · `0d963ce22` ·
`8505d937f` · this record's commit.

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

## THE LADDER

### Round 1 (fable-reviewer, cold, 2026-10-28 — findings file `notes/plans/fixes/vx-440-ladder-round1.md`)

**Verdict: no BLOCKER, no MAJOR; 3 MINOR · 3 NIT.** Cross-model note: nothing disputed, so no
implementer exchange was owed; the orchestrator adjudicated the dispositions directly and, round 1 being
the final findings round, checked its own fixes line-by-line against the findings (the final-round rule).

| # | Finding | Disposition |
|---|---|---|
| M-1 | `observeLatestNoteVersion` pays the classifier's automatic partial index over `version_of` at AUTOSAVE cadence for a mounted note with a version candidate (P1 pressure ∝ the library's version links) | ACCEPTED — ticket MINTED at adjudication (Debt · Confirmed · Performance · Medium). No code change this run (personal-scale cost; the design question is the observation's keying/debounce, the ticket's). |
| M-2 | The book NAVIGATOR's collapsed one-note chapter row keeps VX-356's exact Study gap (`NavigatorChapterLabel`, BookView.swift:2937) | ACCEPTED — ticket MINTED at adjudication (Improvement · Confirmed · Books · Low), pinnable exactly as `BookPanelOpenNoteMarkTests`. Out of this run's ruled scope (VX-356 named the Book Panel). |
| M-3 | The guide's MCP lesson 5 card now incomplete (gatherings have Share with AI… since VX-189) | ACCEPTED — comment added to VX-234 (the copy pass) at adjudication; `TutorialSeeder.swift` is VX-648's file this window, correctly untouched. |
| N-1 | `Button("Close")` unvoiced on the new commit-reading sheet | FIXED at adjudication (orchestrator, the small-code mandate; not bug-class, no pin owed — `VocabularySweepTests` covers the class at the stage window): `tokens.chromeLabel("Close")` at BlockHistoryPane.swift:1352. The pane header's own pre-existing bare Close (~:663) is NOT touched — outside the finding's scope; it rides the copy-pass family if she wants it. |
| N-2 | `.help("")` on ReadModeView's read-only arm leans on AppKit suppressing empty tooltips | RECORDED, no change — correct behavior today; no clean one-line fix without restructuring the modifier chain; folds into the next ReadMode touch. |
| N-3 | `paletteEntries(noteHasSavedVersion: Bool = true)` permissive default | RECORDED, no change — the reviewer's own suggestion (fold the fact into `WingPaletteDoors.Facts` at the next refactor). |

Hollow/weighed and NOT raised (the reviewer's, kept for the record): the `unmarkPostsAsVersions` core
belt (no reachable declassify road remains; unpinnable), Compare's cross-wing moment (unreachable —
versions ride wing moves), the read-in-full sheet's one-Text cost (∝ the summoned moment). Clean bill in
the findings file, including: `bringBackCommitAsTake` ≡ `branchVariant` posture verified side-by-side;
the restore landing touches no editor-seam file; VX-189 faces-only verified in SQL; `.noteVersion` holds
R-440-2 structurally.

**Round 2: NOT OWED.** The ladder's round 2 re-reviews the FIXES; this round's only fix is N-1's one
voiced label (not bug-class). Under the final-round rule the orchestrator's line-by-line check stands in:
N-1's diff is exactly the one-token change the finding proposes, verified against the file's own
chromeLabel idiom (:680/:921/:968/:1006). A fresh round re-reading a one-line diff is not spawned.

## THE STAGE RUNS

### vx440-tests (2026-10-28, claimed 05:35:12 → released 05:43:42 on the coordinator's GO; logs `.vx440-stagelogs/`, gitignored)

- **Red-on-old, all four AS EXPECTED** (test-without-building against frozen pre-fix DerivedData clones):
  rb1 `34c21e938` CompareVersionsTests 1/1 failed (the declassify pin) · rb2 `c9d0b3c66` ShowTakeDoorTests —
  the 2 expected failed, control passed · rb3 `7715a4a3d` GatheringKindWordTests — the 4 expected failed,
  guard passed on every execution · rb4 `0d963ce22` BookPanelOpenNoteMarkTests 2/2 failed on their Study legs.
- **Two test-host crashes INSIDE the window** (the coordinator's catch — my first read called the Problem
  Reporter "pre-window residue", WRONG): `Variorum-…-053550.ips` (0.10.3 host 9927, a historical clone) and
  `…-053637.ips` (0.10.4 host 10014), identical MAIN-THREAD stacks with ZERO Variorum frames — swift-testing's
  own `ABI.EncodedEvent.encode` → JSONEncoder → `Dictionary.reserveCapacity` → the Swift runtime's
  generic-metadata cache, EXC_BAD_ACCESS. A toolchain/test-harness class, NOT VX-657's family (that one is a
  GRDB page-decrypt teardown race with app frames). **Ticketed VX-661** (Bug · Confirmed · Tests & tooling ·
  Low, related to VX-657). Effect in-window: xcodebuild "Restarting after unexpected exit" during red2 (×1)
  and red3 (several), so those logs show repeated executions with totals from previous launches — the earlier
  "plan configurations" guess is corrected to crash-restarts. Every expected test delivered its verdict,
  consistently, on every execution; the red verdicts stand.
- **Green union at tip `1e4c5a4fb`: 587 tests in 71 suites — 584 passed, 3 FAILED + 4 warnings** (no
  restarts in this run), reducing to THREE batch-1 defects (the run's own pins caught them live — they are
  the red evidence):
  - **SF-1** `CapabilityRegistryTests.takesIsNeverBehindWrite`: `.compareWithLatestVersion` reads
    `.unavailable` in Takes while Write reads `.act` — the registry's takes-never-behind-Write rule. The door
    acts from any mode (the landing road switches to Compare itself), so the declaration is wrong.
  - **SF-2** `WingPaletteDoorsTests.thePaletteListsTheLatestDoorOnlyWhileTheNoteHasAMoment` + ALL 4 warnings:
    the `noteHasSavedVersion` observation reaches `@Dependency(\.date)` from `AppSession.swift:762` with no
    test value (swift-dependencies strict access in test contexts).
  - **SF-3** `VersionDoorsTests.theMountedPageWritesNoMemoryAndOffersNoModesOrSave`: mounting the version
    page records a `FocusedBlock` (utf16Offset 0) in the router's place memory — P-440-1 violated by one
    mount-path write the batch missed.
- Problem Reporter dismissed at release; zero instances and sims; dev store untouched; worktree clean at tip.
- **Fixes:** batch 1's implementer resumed with SF-1…SF-3; the three failing tests are the pins (already red
  on the current tree). Then a SHORT re-run window (`vx440-retests`): CapabilityRegistryTests ·
  WingPaletteDoorsTests · VersionDoorsTests · CompareVersionsTests at the new tip, plus any suite the fixes'
  diff reaches; the other suites' greens stand where the fixes' diff doesn't touch their code.

### vx440-retests (2026-10-28, claimed 05:57:17 → released 05:57:52 on the coordinator's GO)

- **57/57 PASSED in 6.087 s, 0 restarts** — CapabilityRegistryTests (30) · VersionDoorsTests (11) ·
  CompareVersionsTests (6) · WingPaletteDoorsTests (10) at tip `94e402cf0` (test-without-building, the
  rebuilt vx440-merge clone). The 4 remaining warnings are the PRE-EXISTING host-launch class (each follows
  the host's own "[protection] road: opened … (a hosted test run)" line — `AppBootstrap.swift:416` building
  the live session during a hosted run; ticket candidate below). No Problem Reporter, no new `.ips`, zero
  instances and sims at release, dev store untouched, worktree clean.
- **SF-1..3 adjudication (the orchestrator's line-by-line check, each diff read):** all three were defects
  in batch 1's TEST HARNESSES; product code untouched by the fixes (`1d2ce417a` · `cf8613d7a` · `94e402cf0`,
  test files + record only). SF-1 is the VX-377 justified-edit class (the registry carries exactly ONE
  reader of `noteHasSavedVersion` — `CapabilityRegistry.swift:956` — so the context edit masks nothing);
  SF-2's `\.date` access is `AppSession.init`'s, from 13j; SF-3's pin was reading another suite's persisted
  `currentBlock.<id>` key (deterministic `.incrementing` ids in the host's real defaults domain) and now
  starts clean, asserts persisted-nowhere, and carries a positive control. **The run's suite evidence is
  COMPLETE: 4/4 red-on-old as expected; the union green (584/587 with the 3 harness artifacts); the touched
  suites 57/57 green after the fixes.**
- **Closeout ticket candidates recorded here (mint at closeout, the filed-tickets triage):** (a) the
  host-launch `@Dependency(\.date)` warnings — the one-statement seam is `AppBootstrap`'s `.ready` arm
  (`withDependencies { $0.date = .now }`), deliberately NOT made in-run (the protection road's bootstrap,
  shared with the phone, outside this run's fences); Tests & tooling · Low. (b) The persisted
  `currentBlock.<id>` / `postMode.<id>` keys left in the test host's defaults domain by deterministic test
  ids — a standing cross-suite pollution source (SF-3's test now protects itself; others don't); Tests &
  tooling.

### vx440-reshoot (2026-10-28, claimed 07:52:43 → released 08:09:19 on the coordinator's GO; suites first, the walk on its "walk OK"; shots `.vx440-walk-shots/reshoot/`)

- **Reds exact:** rb5 (`383954445`) RestoreLandingTests 8 ran, EXACTLY the two W-1 pins failed; rb6
  (`92fb2f2d8`) 9 ran, EXACTLY the W-2 ORDER pin failed — the caret line green in-host, as predicted, so the
  order line is the mechanism pin and the walk is the caret evidence. **Green at tip `3e0425ea3`: 122/122 in
  11 suites, 0 restarts** (the 4 standing VX-665 warnings only).
- **Re-shoot rows:** (a) Takes and (b) Lenses — W-1 WORKS-AS-RULED in both voices (the restored words at
  once at +0.22 s, the ring off, the wash on the Takes road; no wash on Lenses by design). **(c) FINDING —
  W-2 HALF-FIXED on use:** the order is right (burst: the sheet fades over the pre-restore text, closes,
  THEN the words change) but the LANDING never fires on the sheet road — the caret stays at the block's END,
  no wash to +1.55 s, both voices; the row-road CONTROL in the identical state landed at the START with the
  wash at +0.23 s. The pin passes in-host (the host's dismissal timing evidently isn't the app's animated
  one). **Batch 2's implementer resumed for ONE final bounded pass** (trace-or-ticket; the run's last fix
  round). Incidental for the ladder's eye at closeout: the row road's wash box may cover only the first
  visual line of a two-line block (`reshoot-c-7…f02` ctl crop) — cosmetic, judged with W-2's disposition.
- **As-found notes, both resolved by the coordinator:** the Castle words calm-ask card above quick entry is
  STANDING as-found (VX-648's walk-1 recorded it at 04:12), left untouched; Home's Trash rows from 07:41–42
  (~14 field-guide lesson notes + "compare & versions — the twin") are VX-648's w2b walk content (its owned
  field-guide delete), left untouched — VX-648 corrects its own record (the coordinator's word).
- Teardown: the reshoot note to the Trash, two walk-added keys deleted by exact key, three launch-rewritten
  values re-imported, prefs diff EXIT 0 (2599/2599), voice restored, nothing purged, app quit by bundle id,
  her /Applications app never ran.

## THE WALK PLAN (claim `vx440-walk` — runs only after a green vx440-tests window, on the coordinator's GO)

An Opus walker under the orchestrator's claim (cliclick + `Tools/WalkKit/`, the DEV-STORE Debug build
`io.lduarte.Variorum.debug` only; the walker's brief is this section + the three batches' "Walk rows" lists).
**The coordinator's leg-0/teardown notes (2026-10-28, at the GO):** the dev store now carries VX-648's
local migration v1_34 — this branch's build ignores it; LEAVE IT. `theme_voice`, the fan style and the app
Appearance (Dark) are SYNCED settings — record and restore EXACTLY; macOS stays Light. The rule-21
"different library" notice may show at launch after tonight's slot set-asides — note it and dismiss. What's
New may show (build vs pref mismatch) — dismiss, and put the key back BY EXACT KEY at teardown. Teardown:
the note's delete carries its versions (they ride); the book and gathering go to the Trash; #vx440walk
deleted; if any walk content is purged forever, NAME it in the release line.
- **Leg 0 — as-found, recorded before anything:** the dev store's resting posture per the coordinator
  (e11e5233, HELD since 10-20, signed out, Study with app Appearance Dark — macOS stays LIGHT, never
  changed; no books, one note (Oct-19), Walk Wing empty, MCP server OFF, claude-code approved with 0
  grants; NEVER press Resume). Prefs exported for the end-diff; What's New dismissed after launch.
- **Mints, all through product doors, all named here (the coordinator's rule):** one note "VX440 walk
  note" (several paragraphs; 2 named commits via ⌘S; one saved version via ⌘⇧S; then one more edit so the
  live note differs from the moment) · one book "VX440 walk book" (the creation dialog) · one gathering
  "VX440 walk gathering" (rule: tag `#vx440walk`) · the tag rides the note so the gathering assembles.
  NO grant is minted: the share-door legs open the sheet and Esc out (claude-code's approval alone renders
  the doors; zero grant rows written).
- **The rows:** batch 1's (Compare auto-fill with the date-titled moment; unmark → the P-440-5 confirm;
  "Compare with now"; the latest-version door present/grey; Open full size → the band, Back, Promote) ·
  batch 2's (the pane at rest and open; Read in full on a long commit; Restore from sheet and from Takes
  with the wash; Bring back as a take; the VX-356 fill's CONTRAST check on the panel surface — the ladder's
  outstanding item) · batch 3's (Delete Gathering… wording, the Trash row's kind word, the foot without
  "+ new chapter", the two share doors, Study's open-note mark) — BOTH VOICES where a face (switch the
  voice in Settings, restore at the end). Screenshots to a gitignored dir; the keepers into the morning
  bundle.
- **Teardown:** every mint deleted (Trash → Delete Now where offered), the tag deleted, the voice and
  appearance restored, walk-added prefs keys deleted, the prefs diff ZERO against leg 0, instance closed.
  A STOPPED walk never self-cleans — evidence survives for diagnosis (the standing rule).

### vx440-walk (2026-10-28, claimed 05:59:21 → released 06:36:40; the walk 06:00–06:33; Opus walker under the orchestrator's claim; shots `.vx440-walk-shots/` — UNTRACKED, never added, deleted post-merge)

**Verdicts (both voices where a face):** batch 1 — ALL SEVEN rows WORK-AS-RULED (the auto-fill reached via
the doors; the date-titled sealed column with "a saved version of this note"; the P-440-5 confirm verbatim;
promote from Compare and from the band both land a regular note; the latest-version door grey without a
moment on File, live with one on File/note ▾/⌘K; the band exact, no mode rail, ⌘⇧S disabled; Back returns
whence it came). Batch 2 — the pane at rest, the open row, read-in-full (title = the commit's name, foot
doors, selectable), bring-back (label = the commit's name, unchosen, badge v2, the receipt naming the fan's
end), the pane-row restore in Write (wash at the block start, caret at the start) and the Lenses Chosen
right-click all WORK-AS-RULED — plus TWO exceptions below. Batch 3 — ALL FOUR members WORK-AS-RULED
(the kind words everywhere reached, with the confirm/Delete Now/Put back sentences shot; the foot; both
share doors opening the one sheet on the gathering, Esc'd, zero grants; VX-356's Study band with ink
9.95:1 on the fill, the fill 1.47:1 on the panel — reads clearly; Terminal's ›).

**Walk findings:**
- **W-1 (FINDING, bug-class):** a restore from a Block History ROW while TAKES is mounted flashes the block
  but the article keeps showing the OLD text until re-mount — Write shows the restored text at once, the
  footer counts update, the store is right. The flash thus lands on visibly pre-restore words: her original
  "unclear which part came back" complaint, re-created by display staleness. Likely the stale-pane class
  (VX-248, vx-601's root-fix ticket, was In Progress — check what landed in the merge before fixing).
  Shots: `FINDING-b2-takes-article-stale-after-restore-terminal.png` and siblings.
- **W-2 (finding, small):** the read-in-full SHEET road's restore lands the caret at the block's END where
  the pane-row road lands at its START; the sheet road's wash was not captured (burst came late) — fix the
  inconsistency, then a burst re-shoot verifies both.
- **Incidental (not this run's rows):** the note header's book popover says "This note is in 2 books —"
  counting a gathering as a book (`incidental-in-2-books-wording.png`) — wording-family ticket at closeout.
  `Tools/words-guard` fails closed with AXError -25200 on every run on this build, blocking Settings
  captures — ALREADY VX-658 (vx-601's mint, the coordinator's de-dupe); our Settings-captures fact added as
  a comment there (voice flips went through ⌘K; the tag deletion AX-only, uncaptured).
- **Honesty (the walker's not-walked list):** the bare no-door Compare auto-fill; ⌘K/note ▾ checked only
  with a moment present (File checked both ways); the sheet's scroll (the long commit fit); no scratch
  column for Lenses' control row; the Takes article cell's own header menu (the text right-click showed the
  system menu, no Show take ▸); the grant leg (no grant minted, by the plan); Settings shots (words-guard);
  the Study fill measured in app-Dark only.

**Teardown proof:** every mint out (the note's promoted versions went as notes; nothing purged forever —
Delete Now cancelled after its shot); `#vx440walk` deleted, 0 occurrences; voice restored via ⌘K; three
walk-added prefs keys deleted by exact key; three launch-rewritten bookkeeping values (idle-sweep mark,
backup log, the calm-ask launch counter) restored by defaults import — the restore-exactly rule; final
`diff leg0-prefs.xml final-prefs.xml` exit 0 (2538/2538 keys); app quit by bundle id, both strict pgreps
empty; clipboard restored; no new backup (upToDate); Resume never pressed; v1_34 left; /Applications
untouched. Leg 0: no rule-21 notice, no What's New, MCP server off, claude-code approved.

**Morning-bundle keepers:** the b1 band pair + promote confirm; b2 rest/open/sheet in both voices (the
declutter verdict); b3's VX-356 close-ups with the contrast numbers; the W-1 FINDING set.

## FOR THE CLOSEOUT (owed; do not improvise past it)

- Canon deltas in the two-file shape — batch 3's are DRAFTED in its unit record ("Canon owed at the
  closeout"); batches 1–2's DRAFTED here (apply at the merge moment, exactly these):
  - **AppSpec §9, Blocks/variants/savepoints (after branchVariant's bullet):** "**bringBackCommitAsTake
    (commit)** mints a new take on the commit's block — the commit's text, parent = the commit's take, at
    the fan's end, never chosen, never born locked, label = the commit's message when it has one; refuses
    under a seal; branchVariant's posture (no touch, no churn, no undo entry) (VX-431, vx-440)."
  - **SurfaceContracts, The note — a Versions/Compare line:** "Compare's auto-fill seats a note's saved
    versions — date-titled, sealed read-only, after its ordinary `version_of` peers — and unmarking a saved
    version there PROMOTES it after a confirm, never a bare edge delete; each Note ▸ Versions row carries
    Compare with now and Open full size; Compare with Latest Version lives on File, the note ▾ menus and ⌘K,
    rendered only while the note has a saved version; a version opens full size read-only under the identity
    band on Read's calm page (Back to the note · Promote to a regular note…) with no mode rail, no ⌘⇧S and
    no per-note memories written (R-440-1/2; `notes/plans/fixes/vx-440-sheets-history-clarity.md`)."
  - **SurfaceContracts, The note — a Block History line:** "Block History rests as one-line commit rows that
    open in place; region headers carry counts and meaning lines sit behind (i); read in full opens a sheet
    — the whole moment, Restore and Bring back as a take at its foot (the new take at the fan's end, never
    chosen, wearing the commit's name); a restore lands at the block's start with a brief wash in Write and
    the Takes article and ends the ring over the restored take (Takes and Lenses), elsewhere a receipt
    (R-440-3, W-1/W-2; vx-440)."
  - The dated entry + narratives to `notes/AppSpecRecord.md`; `Tools/canon-size` run, its line in the handoff.
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
