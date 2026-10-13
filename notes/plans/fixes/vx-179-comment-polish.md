# VX-179 — the comment area pristine pass

**STATUS: OPEN — kickoff 2026-10-12 (evening).** Ticket **VX-179** · branch `vx-179-comment-polish` ·
worktree `~/dev/variorum-vx-179` · PR `VX-179: …` (merge commit, per the standing rule). Shape:
`/architect-phase` on one ticket — Fable orchestrates + cold-reviews (`fable-reviewer` over the whole
diff; the run touches ONE `Sync/` line, written by the orchestrator itself under a full SyncSpec read),
`opus-implementer` builds, strictly sequential, fresh session per unit.

**Tonight's operational facts (hers, mid-kickoff):** the Pro's stage is HELD by the jadeite release
session — **every stage need (any `xcodebuild test`, walks, the closeout `/Applications` refresh) routes
through the `oct12coordinator` session**, never a direct `Tools/stage` claim; no commits touch the MAIN
checkout until the release reports (the bout-start board snapshot + the in-flight row land THEN — both
are open duties below). Headless `swift build`/`swift test` in this worktree runs freely.

## Her ask (2026-10-12, verbatim)

1. *"the comment pane's cursor to start typing in is misaligned and I feel like it doesn't actually
   look that good"* (the screenshot: the Comments sheet over Write, caret left of and taller than the
   "Write a comment…" placeholder).
2. *"I also feel like it's weird that comments at the side don't show as much as they could show given
   the length of a block - sometimes a block is several paragraphs but the comment is always just one
   line. it would be helpful if they were easier to read while on the side / had a scroll inside the
   comments. it could be handled well when there are multiple comments too."*
3. *"I'm also wondering why when a comment is deleted you can go into deleted comments and not even
   true delete it from there - seems a bit weird."*
4. *"In general I feel like we just need to make sure that the comment area is actually pristine +
   nice UI / UX."*

## Her kickoff rulings (2026-10-12, the kickoff sitting — all three recommended options taken)

- **R-VX179-1 — STACKED ENTRIES in the gutter card.** A block's card holds each comment as its own
  entry — stamp-ordered, thin separators — never the joined `"  ·  "` string; when the entries
  overflow the card's room, you scroll INSIDE the card.
- **R-VX179-2 — the card may grow to THE BLOCK'S OWN HEIGHT** (plus a small pad), still bounded by the
  13u3 rhythm (`roomBelow` — two cards never abut); a one-line block keeps a small card; scroll-inside
  covers overflow. The 96 pt cap retires.
- **R-VX179-3 — TRUE DELETE, CONFIRM EACH TIME.** "Delete forever…" beside Restore in the panel's
  deleted fold, asking once per press — the Delete Now posture (13j round 10: permanent acts always
  confirm). The mechanism is the Delete Now road: a `purge_intent` (the 13j §4f bend to S2); the row
  leaves the deleted listing immediately (the fence) and the janitor removes it everywhere at the
  horizon. Confirm copy is sentence case (her no-shouty-caps rule).

## What is true today (traced at kickoff — the mechanisms, with file:line)

- **The panel** (`App/Variorum/Variorum/Features/Editor/CommentsPanel.swift`): 13u3 UNIT A2's one
  writing surface. The add area is `PanelTextArea` — a SwiftUI `TextEditor` with a hand-overlaid
  placeholder at assumed insets `topInset 8 / leadingInset 5` (`PanelTextArea.placeholderLabel`,
  ~line 929). Those constants are a GUESS about `TextEditor`'s internal geometry ("the same numbers
  QuickNoteView's placeholder overlay has used since it shipped") — exactly the class that drifts per
  macOS release, and on macOS 27 the caret visibly sits left of and taller than the placeholder.
  Presented as a `.sheet` from `EditorView.swift:222` and `TakesBottomBar.swift:309`, and a `.popover`
  from `TakesShared.swift:754`.
- **The gutter card** (`Features/Editor/BlockDecor.swift`): `renderComments` (~line 864) joins ALL of
  a block's comments into ONE string (`"  ·  "`), hands it to `CommentCardView` — a single
  `NSTextField` with `maximumNumberOfLines = 4`, truncating tail (~line 1225). Card height:
  `leftCardRect` (~line 486) caps `ideal = min(blockHeight + 24, 96)` — 96 pt however tall the block.
  The 13u3 laws that MUST survive: the one law (no decoration ever moves the prose column —
  `ProseGutter.swift`'s header), the R-13u3-3 stack (glyph above face), the rhythm (`roomBelow`,
  cards never abut), card width ≤ 210 stopping at the 28 pt handle lane, badge/inline-strip grammar
  unchanged, read-tier cards click-through when `onClick == nil` (`hitTest`, ~line 1265), the
  ~0.04 ms decoration budget, overlays never rendering attributes (TEXTKIT2 §3).
- **Deleted comments**: `deletedBlockComments` (`Sources/VariorumCore/Queries/CommentQueries.swift:19`)
  lists per-block tombstones; the panel's deleted fold offers Restore only. The purge machinery:
  `Operations.purgeableTables` (`Operations+Purge.swift:15`) = container/reading/block/variant/
  commit_point — no `block_comment`; `PurgeFamily.deleteOrder` ALREADY carries `block_comment` and
  `expand`'s default arm (the row itself) is exactly right for a childless comment; the SERVER's
  allowed/owner/purge arrays ALREADY carry `block_comment` everywhere (`10_phase13j_purge.sql` —
  verified at kickoff: zero server work, zero lockstep, marker 13 untouched); the janitor's staleness
  net `tombstonedKinds` (`Sync/PurgeJanitor.swift:449`) does NOT know `block_comment` — without it a
  comment restored between intent and sweep would be purged LIVE. That one line is the orchestrator's
  (Fable, SyncSpec read in full 2026-10-12).

## The design (three units, strictly sequential, one implementer session each)

### U1 — TRUE DELETE (core + the panel door) — evidence: state-transition pins red-on-old, headless
1. `Operations.purgeableTables` gains `"block_comment"`; `validatePurgeable` gains the case: requires
   the comment TOMBSTONED (`purgeTargetNotDeleted` otherwise); missing row with any intent standing →
   skip (already purged); missing with none → `commentNotFound`. The standing `requestPurge` door is
   the op — no new operation.
2. `restoreBlockComment` gains the B1 belt: `voidPurgeIntents(db, table: "block_comment", rowID:)`
   inside its transaction (the 13j ladder-B pattern — a restore voids the stale intent).
3. `Queries.deletedBlockComments` gains the purge FENCE: exclude rows named by ANY `purge_intent`
   (live or tombstoned — "purged stays purged"; copy the standing `NOT EXISTS` arm, e.g.
   `Trash.swift:205`). Verify no other comment reader needs the arm (live readers can't see
   tombstoned rows by definition; sweep and say so in the record).
4. The panel: "Delete forever…" beside Restore on each deleted row, confirm-each-time
   (R-VX179-3; `.confirmationDialog` or alert in the panel's own idiom), classed receipt on land
   ("Comment deleted forever." — wording the implementer's, sentence case), refusals through the
   standing `perform` seam. The fold's count shrinks as the fence hides the row.
5. Pins (core, `swift test` headless): purge refuses a LIVE comment; a tombstoned comment's intent
   hides it from `deletedBlockComments` (red-on-old); restore voids the intent (red-on-old);
   requestPurge dedup/idempotence for the comment kind. Panel-side pins (app target) are written but
   their RUN is stage-gated — mark PENDING and leave them to the verification pass.
6. **Off-limits: `Sources/VariorumCore/Sync/` — already handled.** The orchestrator lands
   `tombstonedKinds` + its two-client convergence pin BEFORE this unit spawns (see LEDGER row 2).

### U2 — THE GUTTER CARDS (R-VX179-1/2) — evidence: geometry pins + the walk (stage-gated)
1. `leftCardRect`: the 96 pt cap retires — ideal = the block's height + the small pad, still
   `roomBelow`-bounded and `cardMinHeight`-floored. Geometry pins updated + a red-on-old cell (a tall
   block's card height follows the block on new, clamps at 96 on old).
2. `CommentCardView` re-forms for STACKED ENTRIES: one entry per comment (wrapping text, no 4-line
   truncation), thin separators, stamp order (the panel's order — `(created_at, id)`); content taller
   than the card scrolls INSIDE the card. Mechanism constraints: pooled views (the ~0.04 ms budget);
   scroll must not steal the page's wheel when the card has nothing to scroll; the read tier's
   click-through (`onClick == nil` ⇒ `hitTest` nil) keeps working — a read-tier card that cannot
   scroll shows what fits (strictly better than the old 4 lines; recorded consequence, not a defect).
   The tooltip keeps the full text. `CommentBrief` may grow a stamp field if the entry needs it.
3. Untouched by design: the one law (prose never moves), the R-13u3-3 stack, badge + inline-strip
   grammar, card width/lane numbers, `commentGutterFaces`' decision shape (height inputs may grow).
4. The voice idiom: Terminal's `// ` prefix per entry vs once per card — implementer proposes at
   build time in the record; the walk decides taste.

### U3 — THE PANEL PRISTINE PASS (her items 1 + 4) — evidence: the walk (stage-gated) + any
   mechanism pins that fall out
1. TRACE FIRST (the hallucination guard): measure where the add area's caret actually sits vs the
   placeholder overlay, and why the caret is tall (typing attributes vs the applied font?). The fix
   is MECHANISM-level, not a nudged constant: either derive the placeholder's position from the
   editor's real text geometry, or replace `PanelTextArea`'s `TextEditor` with an AppKit-backed text
   view whose insets/typingAttributes are OURS so caret and placeholder coincide by construction. If
   the fix is a rewrite of `PanelTextArea`, return with the proposal BEFORE building (the
   implementer-proposes-architect-rules fork). Check `QuickNoteView`'s placeholder overlay for the
   same drift (the constants claim shared provenance) — if it drifts too, fix the shared mechanism
   and close with a sweep table (instance × host), per the constitution's closing form.
2. The pristine pass, within existing tokens and idioms (`VoiceControls` vocabulary, both voices,
   both appearances): the add area's empty state (the sheet today is a large void with a bare
   placeholder), header/footer rhythm, the deleted fold's look, row spacing/stamp line typography.
   No new settings, no new doors, no semantics changes — §2 D's contract (add area owns the leftover
   space, click-anywhere, ⌘⏎/⎋/⏎ grammar) is untouched. Taste numbers PROVISIONAL, chosen against
   the real surface on the walk.
3. U1's "Delete forever…" row joins the pass (one visual language for the fold).

## Sizing & cast
Three ticket-sized units under one theme (not phase-sized; within guidance). U1 first — fully
headless-verifiable tonight; U2/U3 build now, verify when the stage frees (via `oct12coordinator`).
One ladder after all units over the whole run diff: `fable-reviewer` (the run carries a `Sync/` line
and decoration-overlay work beside the editor; Fable's judgment is the safe default), round 2
re-reviews fixes, cap three. Pin-before-fix binds per fix class; every bug-class fix red-on-old,
verified by revert.

## Environment traps (this run's own)
- The stage is the release session's → `oct12coordinator` for EVERY stage act; no `xcodebuild test`,
  no walks, no app launches, no `/Applications` touch from this run until granted.
- No commits in `~/dev/variorum` (main) until the release reports; ALL work commits in THIS worktree
  on `vx-179-comment-polish`, pushed after every commit (the resiliency protocol binds).
- Instance checks before anything screen-adjacent: `pgrep -fl 'Variorum.app/Contents/MacOS'`,
  discriminate by PATH; the author's real-store app is NEVER touched.
- `swift build` / `swift test` (core) run freely here. Keep heavy `xcodebuild build` invocations to
  what a unit actually needs while the release archive runs.
- Never add a custom build configuration; Mac tests (when granted) from `App/Variorum/` with
  suite-level `-only-testing`; zsh `pipestatus`; Swift Testing counts skipped tests (read `skipped:`).
- Screenshots in gitignored dirs; `default.profraw` in the main checkout is pre-existing debris —
  leave it.

## The binding principles (the 13b constitution, P-1…P-9 — copied per the architect-phase skill; the
application notes in `.claude/skills/architect-phase/SKILL.md` bind with it)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut /
  palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data,
  never per-view if-statements. A registry-walk test asserts every declared door exists and every
  rendered door is declared.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly for the user — or delivers the operations layer's real refusal. A door
  that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component that every pane
  composes; "what text does this pane show, and is it live" is answered by ONE pure, unit-tested
  authority (`PaneTextAuthority`); views never re-derive it. Exactly one live pane; the live pane is
  buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** No listener derives business state or
  availability from a broadcast; no flow's correctness depends on broadcast ordering. Cross-feature
  flows route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature. The response is never another patch: write the feature's DESIGN MEMO,
  get the author's rulings on the product-flavored edges, then build to the memo.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for
  every happy path; any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness. Red-on-old stays
  absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly
  as the substrate (invalidation ∝ realized rows; one live editor; virtualized long views).
  Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`.
  `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint
  lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority,
  and gesture routing splits by concern.

## LIVE STATUS / LEDGER (flip per piece, same commit)

| # | item | status |
|---|---|---|
| 1 | Record file + kickoff rulings landed, branch pushed | DONE (93b5b720) |
| 2 | The `Sync/` line: `tombstonedKinds` + `block_comment` + two-client stale pin (orchestrator) | DONE (37b9a6e7) — pin red-on-old VERIFIED BY REVERT (all 5 expectations fail, the comment purged live, stores diverge); full PurgeConvergenceTests 20/20 green headless |
| 3 | U1 true delete (core + panel door) | BUILT (89b5a9af…, last code f92436e8) — core pins red-on-old by revert + full `swift test` green + the app target builds; app-target pin RUN + the walk PENDING (stage) — see the U1 RECORD |
| 4 | U2 gutter cards | BUILT (1a7d2242…b179a9fe) — plain build green, pins typechecked stage-free, tables replayed; pin RUN + revert + the walk PENDING (stage) — see the U2 RECORD |
| 5 | U3 panel pristine pass | BUILT (e5211a8e…) — the caret fixed at mechanism (F-U3-1), the bar's drift (Q-2), the pass, O-3, two pre-existing undo defects (U3-g); plain build green, the real control/panel measured + rendered offscreen, pins typechecked, U3-g red by revert; pin RUN + the walk PENDING (stage) — see the U3 RECORD |
| 6 | Mac-target test runs + the walk (stage via oct12coordinator) | WINDOWS 1–3 DONE (all suites green; R-c exact) + THE WALK DONE (20+ rows, both voices; 6 findings — see THE WALK) |
| 7 | The ladder (fable-reviewer, whole diff) | ROUND 1 RUNNING (spawned after window 3) |
| 8 | Bout-start board snapshot + in-flight row on main | DONE — snapshot was the coordinator's (beb0a30c); in-flight row 5b1c8c94 on main |
| 9 | Ticket VX-179 description gains branch/record pointers; Done rides the PR merge | pointers DONE; Done at merge |
| 10 | Closeout: PR → merge commit; canon deltas (R1-1: AppSpec §7 + §9 contract lines + QUESTIONS provisional bundle, on latest main); worktree + branch + vx179-test checkout removed; debris + walk-evidence tidy; MOBILE PARITY line | NOT-STARTED |

**MOBILE PARITY (provisional):** the Mac faces are Mac-only; U1's core ops are shared — the phone's
comments sheet gains no purge door this run (a `notes/MobileSoul.md` ledger row lands at closeout).

## U1 RECORD (implementer, 2026-10-12)

**U1 BUILD CLOSED (2026-10-12) — VERIFICATION PENDING (stage).** Everything headless is done and green;
what remains needs the stage (via `oct12coordinator`): the three app-target pins' compile + run, and
the walk (one capture per row, both voices — incl. the popover-host check below).

**NOT DONE BY THIS UNIT (first line, by the contract):** no `xcodebuild test`, no walk, no app launch,
no `/Applications` touch (the stage is the release session's) — every app-target pin RUN and every
capture is PENDING (stage). No `Sync/` line touched (U0's line is the orchestrator's, landed at
37b9a6e7). No mobile door (the phone's fold reads the same fenced query and gains no purge door —
the MOBILE PARITY line above).

**Revert state:** no behavioural revert is in flight — U1-c's seven reverts all ran and were restored
(`git diff --stat HEAD` empty after the last; the restored tree re-ran 43/3 green).

### LIVE STATUS

| piece | what | status |
|---|---|---|
| U1-a | record section + ledger row 3 IN-PROGRESS | DONE (89b5a9af) |
| U1-b | core: `purgeableTables` + the `block_comment` arm (tombstoned; dead block refuses; seal refuses) · `restoreBlockComment` belt · the MCP redo road's belt · the `deletedBlockComments` fence · `restoreCost`'s fence · the core pins | DONE (7aad738a) — `swift test --filter "PurgeOpsTests\|RestoreCostTests\|BlockCommentTests"`: 43 tests / 3 suites green, 0 skipped (headless) |
| U1-c | red-on-old by behavioural revert, per arm (evidence table below) | DONE (874b3e40) — whole-old + R1–R7 all red as designed, each restored, the restored tree 43/3 green |
| U1-d | the panel door: `requestDeleteForever` / `deleteForever` on the model, the fold's "Delete forever…" + the confirm, the receipt; app-target pins WRITTEN (run PENDING stage) | DONE (f92436e8) — code + 3 app-target pins WRITTEN in `CommentsPanelEditorTests` (`deleteForeverAsksEveryTimeThenTakesTheRowOffTheFold`, `deleteForeverUnderASealRefusesInTheSealsWords`, `theDeleteForeverWordsAreSentenceCase`); app-target COMPILE PENDING (U1-e's plain build covers the app target only — the test target compiles at the stage-gated run); RUN PENDING (stage) |
| U1-e | verify: touched suites + the full `swift test` headless + ONE plain `xcodebuild build` | DONE (375007d2) — touched suites 43/3 green; full `swift test` (headless, this worktree at f92436e8) GREEN: core **2,704 tests / 307 suites** (the VX-168 baseline 2,691/307 + exactly this unit's 13 pins), VariorumMCPTests 122/18, workbook 40/6, EXIT 0; skips = the standing gated measurement/integration tests only; the ONE plain `xcodebuild -scheme Variorum -destination 'platform=macOS' build` (Debug, from `App/Variorum/`): **BUILD SUCCEEDED**, EXIT 0, no warning in a touched file |

### What U1 decided (with the traces)

1. **D-1 — the seal (PROVISIONAL, the brief's decided default):** the `block_comment` arm refuses
   under a SEALED post through `ensurePlacementUnlocked` (`lockedPost`) — QUESTIONS #23(a)'s posture
   (every comment write refuses under a seal) extended to the permanent write. Pin
   `PurgeOpsTests.aSealedPostRefusesACommentsDeleteForever` (the listing still reads under the seal;
   unsealed, the same ask lands). Recorded consequence: the variant arm has no seal check (a take
   deleted before a seal can be Delete-Now'd from the tray under it) — the two kinds now differ under
   a seal; this unit does not touch the take arm. If the author rules #23 the other way, the line
   comes out and the pin flips.
2. **D-2 — a DEAD block refuses (`blockNotFound`); a live UNPLACED block passes.** Traced:
   `ensurePlacementUnlocked` asks only a LIVE placement — a dead block (its placement tombstoned by
   `deleteBlock`) and a released one (divide-W/merge) both have none, so the guard passes SILENTLY.
   For the dead block that silence is a hazard, not a neutral answer: a comment that died WITH its
   block (the cascade trigger stamps it with the block's exact `deleted_at`) could be purged alone,
   then `restoreBlock`/`restoreContainer`/⌥⌘Z flip it back LIVE on the stamp
   (`flipBlockCascadeTombstones`) with its intent still LIVE (none of those roads voids a comment
   intent) — her next delete of it would then be fenced out of the fold and handed to the janitor
   with no confirm: the 13j B1 class. So the arm takes `restoreBlockComment`'s own guard pair
   (`liveBlock` first, then the seal). The door can't meet a dead block in ordinary use (the fold
   exists only on a live block; a race shows the seam's refusal). A live unplaced block has no post
   to seal it and purges like any other comment write. Pins:
   `aCommentUnderADeadBlockRefusesItsOwnPurge` (both a cascade victim and an earlier-deleted comment
   refuse; Put back then revives the victim with zero comment intents) and
   `aCommentOnALiveUnplacedBlockPurges`. Not marked PROVISIONAL — it is a mechanism guard, not a
   product call; the orchestrator may re-rule it.
3. **D-3 — the fence is the STANDING STAMP-AWARE arm**, copied from `Trash.swift:205`: a LIVE intent
   fences; a completed one fences only the tombstone it covered (`pi.deleted_at >= row.deleted_at` —
   purged stays purged); a VOIDED intent from before a restore-then-re-delete never hides the fresh
   tombstone. The brief's "ANY purge_intent (live or tombstoned)" is read as "copy the standing arm",
   which is exactly this — a literal any-state fence would leave a re-deleted comment in a limbo no
   door reaches (the B1 finding that made the Trash's arm stamp-aware). Pinned:
   `aReDeletedCommentListsInTheFoldDespiteItsVoidedIntent` + the completed-intent half of
   `anIntentNamedCommentLeavesTheDeletedFoldAtOnce`.
4. **D-4 — the B1 belt rides EVERY comment revive road, not only `restoreBlockComment`** (item 2's
   belt, applied to the second door the sweep found): `reapplyAddedComment` — the ⇧⌥⌘Z of an AI
   client's `add_comment` (`Operations+MCPWrites.swift`) — flips a tombstoned comment live, and the
   undo puts that comment on the fold where "Delete forever…" can name it before the redo. The
   precedent decides the direction (the revive wins and voids): `reapplyAddedTake` and 17d P28's
   redo road. Pin `theCommentRedoRoadVoidsALiveIntentLikeItsSiblings`.
5. **D-5 — the panel road** (U1-d, built at f92436e8): the model calls `requestPurge`
   through `perform`, then `session.sweepLocalPurge()` — the Delete Now road's own act at confirm
   (`TrashPurge.confirm`: on a never-signed-in install the cleanup IS the app's, so the bytes go now;
   a no-op under a configured chain, whose janitor owns it). Pin of the local road for the kind:
   `theLocalRoadTakesAPurgedCommentWhole` (row physically gone, intent completed, fold empty).

### The sweep — every reader of deleted comments × verdict

| reader | where | verdict |
|---|---|---|
| `Queries.deletedBlockComments` | `Queries/CommentQueries.swift` | FENCED (the arm) — pinned |
| Mac panel fold | `CommentsPanel.swift:134` (`deletedBlockComments`) | covered (reads the fenced query) |
| phone fold | `VariorumMobile/Features/Write/MobileComments.swift:130` | covered (same query; no phone door — a row deleted forever on the Mac drops here too) |
| `Queries.restoreCost.deletedComments` (the version-restore confirm's population 3) | `Queries/RestoreCost.swift:143` | FENCED (the arm) — `RestoreCostTests.aCommentDeletedForeverIsNotCountedAsStillRestorable` |
| `VersionsCopy` "N deleted comments" | `Shared/VersionsCopy.swift:161` | covered (renders `restoreCost`) |
| `blockComments` · `containerComments` · `commentCounts` · `renderPost.comment_count` · the carve precondition (`Operations+Deletion.swift:302`) · `copyLiveComments` · MCP `MCPNoteStructure.swift:130` · `SeededFurnitureDedupe.swift:789` · `SampleLibraryDedupe.swift:997` | — | SAFE: LIVE readers (`deleted_at IS NULL`). A fenced row is tombstoned by construction (the arm mints only for a tombstone; every revive road voids — table below), and the standing doctrine fences TOMBSTONE readers only (the Trash, the tray, `deletedTakes`) |
| the search index (`SearchIndex` comment source) | `Persistence/SearchIndex.swift:141` | SAFE: a doc exists only for a LIVE comment (`Source.live` = `deleted_at IS NULL`) — a tombstoned comment has no doc to fence |
| `PurgeFamily.expandBlock` (every comment of a purged block) | `Sync/PurgeFamily.swift:172` | not a listing — the purge itself; Sync-owned |

### The sweep — every comment REVIVE road × the B1 belt

| road | verdict |
|---|---|
| `restoreBlockComment` (the panel's Restore, both platforms) | BELT added — `restoringACommentVoidsItsLiveIntent` |
| `reapplyAddedComment` (MCP `add_comment`'s ⇧⌥⌘Z) | BELT added — `theCommentRedoRoadVoidsALiveIntentLikeItsSiblings` |
| `flipBlockCascadeTombstones` (`restoreBlock`, `restoreContainer`, `revertDeleteBlock`, the structural redo's revive) | SAFE by D-2: an intent exists only for a comment deleted on its OWN stamp under a live block; the cascade trigger stamps LIVE comments only and stamps are ms-precision, so no later block death shares it — the exact-stamp flip never reaches it (pinned at the end of `aCommentUnderADeadBlockRefusesItsOwnPurge`) |
| `SampleLibraryDedupe.reviveSampleCopy` (Sync-owned, exact retirement stamp) | SAFE by the same stamp argument; U0's `.stale` net is the designed second net |
| a peer's restore arriving by sync | U0's line (`tombstonedKinds` + `block_comment`) — the orchestrator's |

### Observations (NOT fixed here — out of this unit's surface; for the orchestrator)

- **O-1:** `restoreCost.deleted_takes` counts deleted takes with no purge fence — a take Delete-Now'd
  from the tray still counts as "waiting in Block History" on the version-restore confirm. Pre-existing
  (13u3 UNIT E / 13j); the variant twin of the row fenced here. Ticket candidate.
- **O-2:** the comments panel's doors (Add · Save · Revert · Delete · Restore, and now Delete
  forever…) are undeclared in the P-1 registry (`CommentsPanel` has no `surfaceCapabilities`) —
  pre-existing; the new door follows the panel's own precedent rather than half-declaring one door.
  The fold qualifies as a TRASH SURFACE under the evolved purge-door rule ("purge doors live in trash
  surfaces … never in the writing flow" — `CapabilityRegistry.swift`'s `.deleteNow` note): it lists
  only rows already deleted, and it is her R-VX179-3 placement.
- **O-3:** the panel's `perform` default arm words an unmapped refusal as `"Refused: \(error)"`. The
  new door's race-window refusals (`purgeTargetNotDeleted`, `blockNotFound`, `commentNotFound`) fall
  to it; the seal is mapped. U3's pristine pass may route the default through
  `OpsRefusalCopy.message(for:)` as the tray does.

### Red-on-old evidence (U1-c — behavioural reverts over 7aad738a, headless `swift test --filter`)

| # | revert | pins that went RED (and nothing else) | restored |
|---|---|---|---|
| W | whole pre-fix `Sources/` (89b5a9af) under the new pins | all 12 comment pins (`unsupportedPurgeTarget(table: "block_comment")` — the door did not exist) + `aCommentDeletedForeverIsNotCountedAsStillRestorable`; 32 tests / 15 issues | `git checkout HEAD -- Sources/` |
| R1 | the fence arm off `deletedBlockComments` | `anIntentNamedCommentLeavesTheDeletedFoldAtOnce` (2 issues — the live-intent AND the completed-intent halves) | `git checkout --` |
| R2 | an ANY-STATE fence (no stamp clause) | `aReDeletedCommentListsInTheFoldDespiteItsVoidedIntent` (the voided intent hides the re-delete) | `git checkout --` |
| R3 | the `restoreBlockComment` belt off | `restoringACommentVoidsItsLiveIntent` + `aReDeletedCommentListsInTheFoldDespiteItsVoidedIntent` (2 issues: the fold hides the re-delete; the intent stays live) | `git checkout --` |
| R4 | the `reapplyAddedComment` belt off | `theCommentRedoRoadVoidsALiveIntentLikeItsSiblings` | `git checkout --` |
| R5 | the arm's seal line off | `aSealedPostRefusesACommentsDeleteForever` (4 issues — "an error was expected but none was thrown and 1 was returned": the intent minted under the seal) | `git checkout --` |
| R6 | the arm's `liveBlock` guard off | `aCommentUnderADeadBlockRefusesItsOwnPurge` (5 issues — both comments mint; and after Put back the cascade victim is LIVE with its intent STANDING: the traced B1 hazard, observed) | `git checkout --` |
| R7 | the `restoreCost` fence off | `aCommentDeletedForeverIsNotCountedAsStillRestorable` (the count stays 2) | `git checkout --` |

Feature pins (not bug-class — the door is new): `aLiveCommentRefusesOnlyDeletedCommentsPurge`,
`aDeletedCommentMintsOneTravellingIntentAndAskingTwiceIsOne` (dedup: the second ask mints 0),
`aMissingCommentRefusesByNameUnlessAlreadyPurged`, `aCommentOnALiveUnplacedBlockPurges`,
`theLocalRoadTakesAPurgedCommentWhole` — each red on the whole-old run (W), green on the fix.

### The panel door (U1-d) — what was built, and what the walk must check

- `CommentsPanelModel`: `pendingDeleteForever` (the pending id) · `requestDeleteForever(_:)` (raises
  the confirm only for a row the fold shows) · `cancelDeleteForever()` · `deleteForever(_:)` (the id
  PASSED IN — 13l Act 2's rule; `requestPurge` through `perform`, a classed receipt
  "Comment deleted forever.", then `session.sweepLocalPurge()` — D-5). No undo entry.
- The fold row: "Delete forever…" beside Restore, `VoicedButtonStyle` `.quiet` (present, never
  calling — the row's own Delete is quiet too), `chromeLabel` like Restore.
- The confirm: `.alert(presenting:)` on the panel — `BlockHistoryPane`'s shape. Title "Delete this
  comment forever?", body "It leaves every device, and there's no putting it back." (the Trash's
  own permanence phrase), buttons Delete forever (destructive) / Cancel. Sentence case throughout.
- **WALK CHECK, PENDING (stage):** the panel has THREE hosts — two `.sheet`s (`EditorView.swift`,
  `TakesBottomBar.swift`) and one `.popover` (the Takes margin note, `TakesShared.swift`). Every
  shipped confirm-each-time door in the app (the tray's `confirmationDialog`, Block History's
  `.alert`) is hosted in a sheet or inspector, never a popover, so the POPOVER host is the one this
  unit could not prove headlessly: the walk must press Delete forever… from the Takes margin
  note's popover and see the confirm appear AND act (the popover is `.transient`). If it does not,
  the fallback is an INLINE confirm on the fold row (the row's buttons become "Delete forever ·
  Cancel" under the question) — robust in every host by construction; U3's pass owns the fold's
  look either way.

### Dispositions (U1's rows, the brief's items 1–5)

| item | disposition |
|---|---|
| 1 — `purgeableTables` + the `block_comment` arm | BUILT — pins `aLiveCommentRefusesOnlyDeletedCommentsPurge`, `aMissingCommentRefusesByNameUnlessAlreadyPurged`, `aDeletedCommentMintsOneTravellingIntentAndAskingTwiceIsOne`; seal (D-1, PROVISIONAL) red-on-old R5; dead block (D-2) red-on-old R6; unplaced passes `aCommentOnALiveUnplacedBlockPurges` |
| 2 — the restore belt | FIXED — `restoringACommentVoidsItsLiveIntent` (R3); EXTENDED to the MCP redo road (D-4, R4) |
| 3 — the fence + the reader sweep | FIXED — `anIntentNamedCommentLeavesTheDeletedFoldAtOnce` (R1), stamp-aware `aReDeletedCommentListsInTheFoldDespiteItsVoidedIntent` (R2); the sweep found `restoreCost` and fenced it (R7); every other reader proven safe (the sweep tables) |
| 4 — the panel door | BUILT (f92436e8) — app-target pins WRITTEN; compile + RUN PENDING (stage); the walk PENDING (stage) |
| 5 — pins | 12 core pins in `PurgeOpsTests` + 1 in `RestoreCostTests` (all red on the whole-old tree W; the bug-class ones red per arm, R1–R7); 3 app-target pins in `CommentsPanelEditorTests` (RUN PENDING) |

### PENDING (stage-gated — none of it claimed)

- App-target pins (`CommentsPanelEditorTests`: `deleteForeverAsksEveryTimeThenTakesTheRowOffTheFold`,
  `deleteForeverUnderASealRefusesInTheSealsWords`, `theDeleteForeverWordsAreSentenceCase`) — they
  have NOT been compiled (a plain `build` does not build the test target) nor run. Run with
  `-only-testing:VariorumTests/CommentsPanelModelEditorTests` + `CommentCompositionTests` under a
  held claim; the suite file gained `import GRDB` for the two row reads.
- The walk, both voices, one capture per row: (1) a deleted comment's row shows Restore + "Delete
  forever…"; (2) the press raises the confirm (title/body/buttons as above); (3) Cancel leaves the
  row; (4) Delete forever drops it from the fold with the receipt; (5) the POPOVER host (the Takes
  margin note) — the confirm appears and acts (see U1-d's walk check; fallback named there);
  (6) under a seal the refusal speaks the seal's words.

### PROVISIONAL — owed to `notes/QUESTIONS.md` at the merge moment (the shared-ledger rule: only the
merging session touches it, on latest main)

**P-VX179-U1-1 — the comment purge under a SEALED post.** Built: (a) REFUSE (`lockedPost`) —
QUESTIONS #23(a)'s posture (every comment write refuses under a seal), the brief's decided default.
Options for her: (a) refuse — as built; (b) ALLOW — a purge of an already-deleted comment changes
nothing she can read under the seal, and it would match the TAKE arm (a deleted take's Delete Now
from the tray has no seal check today) and Delete Now of a sealed note in the Trash; (c) refuse for
comments AND add the same seal check to the take arm (consistency the other way — a change outside
this unit). Pin to flip under (b): `aSealedPostRefusesACommentsDeleteForever` (+ the app pin
`deleteForeverUnderASealRefusesInTheSealsWords`).

## U2 RECORD (implementer, 2026-10-12)

**U2 BUILD CLOSED (2026-10-12) — VERIFICATION PENDING (stage).** The gutter comment cards
(R-VX179-1/2): the 96 pt cap retired; the margin card re-formed as STACKED ENTRIES that scroll inside
the card. Everything stage-free is done: the plain app build green, the pins typechecked against the
built module, every pure-table and geometry cell replayed from a source copy. What remains needs the
stage (via `oct12coordinator`): the pins' compile-in-target + RUN, red-on-old by revert, and the walk.

**NOT DONE BY THIS UNIT (first line, by the contract):** no `xcodebuild test`, no walk, no app launch,
no `/Applications` touch (the stage is the release session's) — every app-target pin's COMPILE and
RUN, every red-on-old-by-revert check, and every capture is PENDING (stage). Zero `Sync/` lines, zero
core-package lines (app-side geometry and rendering only). No mobile face (the phone has no gutter card).

**Revert state:** no behavioural revert is in flight, and none will run this session — the pins live
in the app target, whose test build is stage-gated; red-on-old by revert is PENDING (stage).

### LIVE STATUS

| piece | what | status |
|---|---|---|
| U2-a | record section + ledger row 4 IN-PROGRESS | DONE (1a7d2242) |
| U2-b | geometry: `leftCardRect`'s 96 pt cap retires (the pad named `cardHeightPad`, kept at 24); the cap's one pinned cell flipped; the red-on-old-shaped cells | DONE (6c941167) — `Phase13SurfaceTests.aMarginCommentCardSitsInTheLEFTGutterClearOfTheHandleLane`'s cap cell flipped (`== 96` → `== 824`); new `ProseGutterTests.theCardGrowsToTheBlocksOwnHeightWithinTheRhythm` (6 height cells red-on-old by arithmetic — old answers 96; the parity cells green both sides). Compile + RUN + revert PENDING (stage) |
| U2-c | the card: stacked entries, scroll inside, the wheel routing, the identity reconcile in `renderComments` | DONE (e3629851) — `CommentCardView` + the pure `CommentCardLayout` (arrange · wheelOwner · reconcile) moved to the new `Features/Editor/CommentCard.swift`; `renderComments` reconciles by identity and presents the stacked card; the plain Debug build SUCCEEDED (zero warnings in touched files) |
| U2-d | pins: the pure tables (arrangement · wheel owner · reconcile) + mounted card + controller cells (app target — WRITTEN only; compile + RUN PENDING stage) | DONE (b193aa1f) — new `VariorumTests/CommentCardTests.swift` (3 suites, 14 tests); the card gained the budget's component-wise `CardContent ==` + two DEBUG counters the pins read. STAGE-FREE EVIDENCE (no test target built, nothing run): `swiftc -typecheck` of the new file AND of the two edited existing functions (extracted verbatim) against the plain build's `Variorum.swiftmodule` — EXIT 0, zero diagnostics (non-vacuity probed: a misspelt member fails it); a source-copy REPLAY of every pure-table cell and every geometry cell (new vs old formula) — all as pinned. RUN + red-on-old by revert PENDING (stage) |
| U2-e | verify: the plain `xcodebuild … build`; record closed | DONE (b179a9fe) — after the last code change (read-tier cards carry no scroller view; two pin cells for it): `xcodebuild -scheme Variorum -destination 'platform=macOS' build` (Debug, from `App/Variorum/`) **BUILD SUCCEEDED**, EXIT 0, zero warnings in a touched file (the log's 9 warnings are pre-existing, untouched files); the pins re-typechecked EXIT 0 |

### The settled design (written before the code — the record must let a fresh session finish)

1. **Geometry:** `ideal = blockHeight + cardHeightPad` (24, the shipped pad), still
   `min(ideal, roomBelow − cardRhythmAir)` and nil below `cardMinHeight`. Every card under the old
   cap (block ≤ 72 pt) is byte-identical; nothing else in the family moves.
2. **The card (`CommentCardView`):** the margin-card arm hosts a small `NSScrollView` (overlay
   scroller, no horizontal axis) over a flipped document view holding one wrapping label per comment
   (pooled inside the card) with 1 pt hairline separators (`tokens.line`, the panel's own hairline);
   a pure `CommentCardLayout.arrange` places them. `present` is idempotent (an unchanged pass does no
   label work); labels are measured only when the entries or the width change. The strip and badge
   arms keep the single shipped label, byte-identical. The tooltip keeps the shipped joined string.
3. **Events:** the interactive card hit-tests as ONE door (itself — the labels and the clip view never
   take a click; the scroller stays draggable); the read tier keeps `hitTest → nil` (click-through,
   no scrolling — it shows what fits). The card's `scrollWheel` routes through a pure
   `CommentCardLayout.wheelOwner`: content that fits → the page; otherwise the gesture's first moving
   event decides (the card when it can move that way, else the page) and the whole gesture latches
   to that owner (the Mac's nested-scroll latching); a wheel notch decides per notch.
4. **Pooling with scroll state:** `renderComments` reconciles cards by BLOCK IDENTITY (a pure
   `CommentCardLayout.reconcile`) so a block that stays visible keeps its card and therefore its
   inner scroll position while the page scrolls; a card that comes to show a different block resets
   to its top.
5. **The voice idiom (PROPOSAL, PROVISIONAL — the walk decides):** Terminal's `// ` PER ENTRY, as a
   hanging mark (wrapped lines align after it), ink at 0.75 — the panel's own row idiom.

### What U2 decided (with the traces)

1. **D-1 — the pad stays 24 (`BlockDecor.cardHeightPad`).** `ideal = blockHeight + 24`, bounded by
   `roomBelow − cardRhythmAir` and floored at `cardMinHeight` exactly as shipped. Why not a "cleaner"
   pad (e.g. the card ending at its block's own bottom): every card under the old cap (a block of
   72 pt or less — nearly every one-to-three-line block) stays BYTE-IDENTICAL, and every existing
   geometry pin rides unmodified except the one cell that pinned the cap; a different pad would move
   every shipped card. A one-line block (17 pt Terminal) keeps its 41 pt card — room for two short
   entries before the inner scroll. Accepted consequences, for the walk: (i) a tall block with a short
   comment shows a tall card that is mostly its leading rule — a margin bracket along the block, the
   entries at its top; (ii) a block taller than the window, scrolled so its top is off-screen: the
   card scrolls with its block (it is an overlay subview in document space, top-aligned to the
   block's first line), so its entries leave with the block's top and the rule continues along the
   rest — option for the walk, NOT built: a "sticky" entry stack (needs viewport input in the
   geometry — a design call); (iii) the card's hit area grows with it: a click in the gutter beside a
   tall commented block, left of `textLeft − 28`, opens the panel (the card is the block's door, as
   it was over its first 96 pt).
2. **D-2 — the stack.** Each comment one wrapping 11 pt label (the shipped size; no line limit, no
   truncation), the panel's own 1 pt hairline (`tokens.line`) between entries with 4 pt air each side
   (PROVISIONAL taste numbers), placed by the pure `CommentCardLayout.arrange`. ORDER, traced at both
   suppliers: `EditorViewModel.observeComments` and `ReadPostViewModel.startDecorContext` both map
   `Queries.containerComments` (`ORDER BY bc.block_id, bc.created_at, bc.id`; `Dictionary(grouping:)`
   keeps sequence order within a group) — the panel reads `Queries.blockComments`, ordered
   `(created_at, id)`: the same order (core pin `Phase13SurfaceQueryTests.containerCommentsGroupsLive
   NotesPerBlock`). No stamp is drawn (the panel is the stamp's home; a 210 pt read face stays calm),
   so `BlockDecor.CommentBrief` did NOT grow — `id + text` is what the card renders.
3. **D-3 — one door, and the events' road (traced).** The window delivers a click and a wheel event
   to whatever `hitTest` answers. The stacked card now holds an `NSScrollView` → `NSClipView` → the
   flipped stack view → the entry labels, any of which would otherwise be that answer — swallowing
   the click (the card's `mouseDown` is the panel's door) and taking the wheel straight into the inner
   scroll. So an interactive card answers ITSELF for every point (the vertical `NSScroller` excepted,
   so it stays draggable): `mouseDown` → `onClick` wherever she clicks, and every wheel event reaches
   the card's router. The read tier (`onClick == nil`) answers nil exactly as shipped, so clicks AND
   wheel events go to the text view beneath (click-to-focus and the page's scroll intact) — its cards
   therefore cannot scroll and show what fits (entries past the card's edge are clipped there; the
   brief's accepted consequence, strictly more than the old four truncated lines) and carry no
   scroller view at all. The strip and badge arms keep `super.hitTest` exactly.
4. **D-4 — the wheel's owner (`CommentCardLayout.wheelOwner`, pinned by table).** Content that fits
   ⇒ the page, always — `super.scrollWheel`, NSResponder's default, hands the event to the next
   responder (the text view, on up to the clip and the page's scroll view): the very road the event
   takes over bare gutter. Overflowing ⇒ the card when it can move that way (toward its top while
   scrolled down, toward its bottom while there is more below), else the page; mostly-horizontal ⇒ the
   page. A trackpad GESTURE latches: `.mayBegin`/`.began` decide, the rest of the gesture and its
   momentum follow, the latch clears at `.cancelled` or momentum's end — so neither scroll view sees
   half a gesture, a card scrolled to its end stops there, and the NEXT gesture moves the page (the
   Mac's nested-scroll latching). A wheel notch (no phases) decides alone. The sign convention:
   `scrollingDeltaY > 0` reveals content ABOVE (AppKit moves a flipped clip's origin by −deltaY; the
   natural-scrolling inversion is already applied) — WALK CHECK W-3; if it were inverted the symptom
   is unmistakable and the fix is one comparison in `wheelOwner` plus its table.
5. **D-5 — the pool pairs by IDENTITY (`CommentCardLayout.reconcile`, pinned by table).** Traced: the
   shipped `pool` paired cards with the visible commented blocks by POSITION — harmless while a card
   held no state. A scrolled card holds state: a page scroll that moves the visible commented set by
   one block would hand every card to its neighbour's block, mid-scroll. Now a block keeps the card
   already showing it (and her inner scroll position); the rest take the free cards in pool order; new
   cards only when the pool runs out; surplus removed — still a pool. A card that comes to show a
   different block (`identity` changes) returns to its top.
6. **D-6 — the budget.** The decoration pass re-presents every visible card on every scroll, layout
   and caret move. `presentCard` compares the whole `CardContent` first and returns on no change; the
   colours are compared by sRGB components because the pass re-makes them from the tokens every time
   (`NSColor(tokens.…)` — object equality across re-made colours is not guaranteed, and a false
   "changed" would rebuild every entry every pass). Labels are measured only when the entries or the
   width change; a height-only change (her block grew a line) re-arranges by arithmetic and never
   re-measures — both pinned by DEBUG counters. Steady-state work is below the shipped pass's (whose
   `present` removed and re-added a fresh rule `NSView` on every pass). View count per card grows
   (scroll view + clip + stack + N labels + N−1 hairlines), still ∝ visible commented blocks (P1).
7. **D-7 — the overflow cue: AppKit's own.** `flashScrollers()` once when a card's content (or its
   block) changes into an overflowing state, interactive cards only. A bottom fade was considered and
   not built: a gradient mask's orientation under AppKit-managed (geometry-flipped) backing layers
   could not be verified without the stage — a walk option (P-VX179-U2-2).
8. **D-8 — the voice mark: PER ENTRY, HANGING (PROPOSAL, PROVISIONAL — the walk decides).** Terminal's
   `// ` leads each entry at the panel's 0.75 of the comment ink; wrapped lines align after it (a
   `headIndent` of the mark's width); a newline inside a comment displays as a LINE separator so its
   later lines hang too (display only — the stored text untouched). Reasoning: the panel — the one
   editing home — draws the mark per row as a label BESIDE the text (`CommentsPanel` row, "never part
   of the text"), so its rows hang; once per card would make entries 2…n read as the first's
   continuation, which is the joined string's defect re-made. Study has no mark (prefix ""),
   unchanged.

### Dispositions (U2's rows — the brief's items 1–4; design rows her rulings made, so the evidence is
a geometry oracle + the walk, red-on-old where a cell is the old law)

| item | disposition |
|---|---|
| 1 — geometry (R-VX179-2) | BUILT (6c941167) — the cap's cell flipped (`Phase13SurfaceTests`' `BlockDecorGeometryTests.aMarginCommentCardSitsInTheLEFTGutterClearOfTheHandleLane`: `== 96` → `== 824`); new `ProseGutterTests.theCardGrowsToTheBlocksOwnHeightWithinTheRhythm` (six height cells RED ON OLD — 96 there — seven with the flipped cap cell; the parity cells green both sides; confirmed by the source-copy replay below); every other geometry pin unmodified |
| 2 — the card (R-VX179-1) | BUILT (e3629851 + the refinements at b193aa1f/b179a9fe: component-wise content equality, DEBUG counters, read-tier cards carry no scroller) — pins in `CommentCardTests.swift` (b193aa1f, b179a9fe) |
| 3 — the one law | UNTOUCHED BY CONSTRUCTION — no line in `ProseGutter`, the text views, `PaneSurface` or any measurement road; the change lives in the gutter card and the height arithmetic `roomBelow` already bounds. The one-law pins (`ProseGutterTests`' production-loop cells, `nothingInTheGutterEverCoversProse`, `IndicatorGutterTests`) ride unmodified — RUN PENDING |
| 4 — pins | WRITTEN: 3 new suites / 14 tests + the new geometry test + the flipped cell; typechecked stage-free; RUN PENDING (stage) |

### Stage-free evidence (what WAS proven tonight — none of it is a pin run)

- **The plain build:** `xcodebuild -scheme Variorum -destination 'platform=macOS' build` (Debug) BUILD
  SUCCEEDED after every code piece (U2-c, U2-d, U2-e); zero warnings in `CommentCard.swift` /
  `BlockDecor.swift`.
- **Typecheck of the pins without the test target:** `swiftc -typecheck` (Swift 6, the test target's
  upcoming features, the Testing macro plugin) of `CommentCardTests.swift`, and of the two edited
  existing functions extracted verbatim, against the plain build's `Variorum.swiftmodule` — EXIT 0,
  zero diagnostics; non-vacuity probed (a misspelt member fails it). This proves the pins COMPILE
  against today's app module; it does not build the test bundle or run anything.
- **Source-copy replay of the pure decisions:** a scratch executable compiled from a verbatim copy of
  `CommentCardLayout` + `leftCardRect` (with the OLD formula beside it) checked every table cell in
  `CommentCardLayoutTests` and every height cell of the geometry pin: ALL AS PINNED; the old formula
  answers 96 on exactly the seven cells the two pins call red-on-old (six + the cap cell), and the same value on the parity
  cells (17 → 41, 72 → 96, room-20 → nil, the shipped 54 / 34 / 21 rhythm cells). A replay of a COPY
  — the stage's revert is still owed.

### PENDING (stage-gated — none of it claimed)

- **Pin RUN** (under a held claim, via `oct12coordinator`), suite-level:
  `-only-testing:VariorumTests/CommentCardLayoutTests -only-testing:VariorumTests/CommentCardViewTests
  -only-testing:VariorumTests/CommentCardControllerTests -only-testing:VariorumTests/ProseGutterTests
  -only-testing:VariorumTests/BlockDecorGeometryTests -only-testing:VariorumTests/IndicatorGutterTests
  -only-testing:VariorumTests/MarginHoverCommentTests -only-testing:VariorumTests/CommentsAndReorderTests`
  (the last two mount `CommentCardView` through the controller and must ride unmodified).
- **Red-on-old by revert** (geometry): set `leftCardRect`'s ideal back to `min(blockHeight + 24, 96)` →
  exactly the six height cells of `theCardGrowsToTheBlocksOwnHeightWithinTheRhythm` + the flipped
  cap cell (seven) go red, nothing else; restore. (The card pins are FEATURE pins — they fail to COMPILE on the
  pre-U2 tree, which is their red.)
- **The walk** — DEV-STORE Debug build, both voices, both appearances, one capture per row:
  W-1 a tall multi-paragraph block with one short comment (the card follows the block; entries at its
  top; the rule along the block — D-1 (i)); W-2 three comments on a one-line block (stacked, hairlines,
  the inner scroll; the scroller flashes once); W-3 THE WHEEL: over an overflowing card at rest,
  scrolling down moves the card and up moves the page; at the card's end the gesture stops and the next
  gesture moves the page; over a card that FITS the page always scrolls; a mouse-wheel notch too;
  W-4 a click anywhere on a card — on an entry's words, between entries, on the empty lower part —
  opens the panel; W-5 the read tier (workspace read pane, note window read face, book Outline, spread
  book): stacked entries showing what fits, click-through to the text, the page scrolls over it;
  W-6 the strip (inline setting) and the badge (a narrow window) unchanged; W-7 the voice mark per entry
  in Terminal vs none in Study (the D-8 taste call); W-8 a card scrolled mid-way keeps its position while
  the page scrolls and its block stays visible; W-9 a block taller than the window with its top scrolled
  off (D-1 (ii)); W-10 two adjacent commented blocks, the first tall — the cards never abut.

### Observations (NOT fixed here — out of this unit's surface; for the orchestrator)

- **O-U2-1:** do the STRIP's and the BADGE's single labels pass a click on their own text through to the
  card's `mouseDown`? Their `hitTest` stays `super.hitTest` (byte-identical, per the brief), which
  answers the `NSTextField` label for a point over its text; whether a non-selectable label forwards the
  press is AppKit's, unverified here. The margin card no longer depends on it (D-3). If the walk finds a
  dead press on a badge's "#2", it is a ticket candidate, and D-3's one-door rule is the fix shape.
- **O-U2-2:** Takes' own margin note (`TakesShared.swift` ~724–730 — `tokens.commentPrefix + first.text`)
  is a separate SwiftUI comment face showing only the FIRST comment; untouched (not the gutter card). If
  R-VX179-1's spirit should reach it, that is a Takes-surface decision.

### PROVISIONAL — owed to `notes/QUESTIONS.md` at the merge moment (the shared-ledger rule)

- **P-VX179-U2-1 — the voice mark in the stacked card.** Built: (a) per entry, hanging, 0.75 ink (the
  panel's row idiom). Options: (b) once per card, at the first entry; (c) no mark in the card (the
  separators carry the grammar).
- **P-VX179-U2-2 — the overflow cue.** Built: (a) AppKit's scroller flash once per new overflowing
  content. Options: (b) a bottom fade on an overflowing card; (c) nothing (the cut line is the cue).
- **P-VX179-U2-3 — a tall block whose top is scrolled off.** Built: (a) the card scrolls with its block
  (entries leave with the top; the rule continues). Option: (b) a sticky entry stack that stays in view
  while any of its block is visible (a geometry change — needs the viewport as an input).
- Taste numbers, PROVISIONAL: entry air 4 pt, hairline 1 pt in `tokens.line`, mark at 0.75 ink, the pad 24.

## U3 RECORD (implementer, 2026-10-12)

**U3 BUILD CLOSED (2026-10-12) — VERIFICATION PENDING (stage).** Built on the F-U3-1 RULING (c0888701):
(a) the AppKit control with the twin-view placeholder · (i) the bar's 2 pt drift fixed through
`CaptureTextView`'s named inset · the panel-private home; plus the pristine pass, O-3, and two
PRE-EXISTING undo defects found in self-review (U3-g — a crash and a draft desync). Everything
stage-free is done and green: plain builds, the REAL compiled control and panel measured and rendered
offscreen, the pins typechecked, the undo fix's two arms red by behavioural revert on the real module.
What remains needs the stage: the pins' RUN and the walk (the PENDING list at the end). Resumed the
same session after the ruling (no death).

**NOT DONE BY THIS UNIT (first line, by the contract):** no `xcodebuild test` (the 16 new pins are
WRITTEN + TYPECHECKED, never run), no walk, no app launch, no window shown, no `/Applications` touch —
every app-target pin RUN and every capture is PENDING (stage); the red-on-old by revert ran OFFSCREEN
through probes against the real module, not through the test target. O-U3-3 (the capture box's own
undo desync) is measured and NOT fixed (another surface). Zero `Sources/` lines (no core, no `Sync/`),
verified by path diff. `CommentComposition`, `CommentPanelKeys` and `CommentPanelKeyMonitor` are
byte-untouched; `CommentsPanelEditorTests` and `CommentPanelParkTests` are UNMODIFIED (no cell pinned
the old control's internals).

**Revert state:** no behavioural revert is in flight — U3-g's R-a and R-b ran on the committed fix and
were restored by `git checkout --` (`git diff --stat` empty after each; the restored tree rebuilt and
re-measured green).

**The probe carve-out (the brief's):** the trace's measurements come from a HEADLESS OFFSCREEN probe —
a scratch `swiftc` executable (`.prohibited` activation policy; no `NSApp.run`, no
`makeKeyAndOrderFront`, no activation; any `NSWindow` it creates is never ordered in) that mounts the
panel's control verbatim in an `NSHostingView` and reads the real text view's geometry.

### LIVE STATUS

| piece | what | status |
|---|---|---|
| U3-a | record section + ledger row 5 IN-PROGRESS | DONE (e5211a8e) |
| U3-b | TRACE: the offscreen probe measures `TextEditor`'s real insets / padding / typing attributes / caret rect vs the hand-assumed `topInset 8 / leadingInset 5`; the sweep measured | DONE (13b8807e) — the numbers and the mechanism below |
| U3-c | the mechanism decision | STOPPED AT FORK F-U3-1 (13b8807e) — the traced fix is a `PanelTextArea` rewrite; the proposal below, the orchestrator rules |
| U3-d1 | Q-2: `CaptureTextView` owns `textInset`/`lineFragmentPadding`/`firstLineOrigin` as named statics; `makeNSView` reads them; `QuickEntryBar.placeholderOrigin` = the box's origin (the 2 pt fix); `QuickNoteView.placeholderOrigin` derived = (6, 6), visibly unchanged | DONE (1d347966) — plain build SUCCEEDED, zero warnings in the three files |
| U3-d2 | Q-1/Q-3: `Features/Editor/CommentTextArea.swift` (the AppKit control — owned geometry, explicit typing attributes, the twin placeholder, the twin `//` mark, measured row height, first-responder reports + counted, HELD focus request); `CommentsPanel` rewired (`PanelTextArea` + its ruler retired; `@FocusState` → `focus` fed by the reports through the pure `CommentPanelFocus.after(report:inArea:current:)`; ONE `CommentsPanelMetrics`) | DONE (fa488500) — plain build SUCCEEDED, zero warnings in touched files; the REAL compiled control verified offscreen (the evidence table below). Mark: SwiftUI does NOT bridge `firstBaselineOffsetFromTop` for a representable (measured, `baseline.swift`), so the mark is a second configured twin owned by the control |
| U3-d3 | pins — new `VariorumTests/CommentTextAreaTests.swift` (3 suites, 15 tests at f3a4a8cc; 16 with U3-g's undo pin — 20 cases with the voice arguments): the pure rules (owned geometry, row height, Q-2's origins incl. the bar's red-on-old cell, the focus-report table); the REAL control mounted offscreen (caret line == placeholder line, placeholder ink == typed ink, typing attributes + twin through type/clear/IME, no dead air, mark baseline == text baseline, the held focus request + reports, ⎋ falls through, the capture box's first line at its own origin); the words (sentence case, refusals as words) + the model-level race pin (red-on-old: "Refused: commentNotDeleted(…)" etc.) | DONE (f3a4a8cc) — WRITTEN; TYPECHECKED stage-free against the built module (`real/typecheck.sh`: Swift 6 + the test target's upcoming features + the Testing macro plugin; EXIT 0, zero diagnostics, with the five existing touched-area suites in the same invocation; non-vacuity probed — a misspelt member fails it). RUN PENDING (stage) |
| U3-e | the pristine pass (the look, both voices, both appearances, sheet + popover hosts — one view): the COMPOSER (the add area as the voice's writing box: card paper + hairline, accent hairline while live, keys + Add inside it), one WRITING column / one CHROME column, inset row hairlines, the header's count only when non-zero, the deleted fold as the live list's quieter twin (struck words, then the stamp line "Deleted <date>" with Restore + "Delete forever…"), Add on `VoicedButtonStyle` (it fades when there is nothing to file — `CalmButtonStyle` ignores disabled), every word in `CommentsPanelCopy` (sentence case), O-3 (`CommentsPanelRefusalCopy`), taste numbers in `CommentsPanelMetrics`; `VoicedButtonStyle.labelInset` named | DONE (4b7cfd60) — plain build SUCCEEDED, zero warnings in touched files; REAL panel rendered offscreen (see "the look, rendered" below) |
| U3-g | **FOUND IN SELF-REVIEW (the ruling's "undo grouping" walk risk, probed) — TWO pre-existing undo defects in the panel, both measured offscreen in the SHIPPED `TextEditor` and in the new control pre-fix:** (1) ⌘Z right after filing CRASHES — the panel clears the add area programmatically and NSTextView's typing undo replays ranges of the OLD text (`NSRangeException: Range {13, 9} out of bounds; string length 0` — `undo2.swift old`, `undo.swift`); (2) after any ⌘Z/⇧⌘Z the box and the draft DISAGREE — AppKit sends no `textDidChange` for an undo or a redo (measured TK2 and TK1, `undo4.swift`; the shipped `TextEditor` too, `undo5.swift`: view "" / binding "new"), so ⌘⏎ filed words she had undone. FIX: each area's coordinator owns its `UndoManager` (`undoManager(for:)` — measured to be ⌘Z's road: `undo:` reaches `NSWindow`, which undoes through the first responder's manager), ENDED on a programmatic adopt (`removeAllActions(withTarget:)` on the view or the storage does NOT reach TK2's registrations — measured), and the area hears its own manager's did-undo/did-redo notifications and re-syncs the binding, the placeholder and the height. (A `breakUndoCoalescing()` tried mid-trace was NOT needed — measured green without it — and is not in the code.) | DONE — PIN a76de514 (+ the honest correction d3a21eea); FIX 7d9e5525 — plain build SUCCEEDED; the pin's exact steps replayed offscreen against the REAL module (`real/undopin.swift`): 10/10 PASS incl. the redo cells; typecheck EXIT 0; REVERTS R-a/R-b RED as predicted, restored (the table below) |
| U3-f | verify + close: plain build green at the final code; the touched-area suites + the new pins typechecked together (EXIT 0); zero `Sources/` lines; the record closed (sweep, dispositions, PENDING, PROVISIONALs, observations) | DONE (0b5a7a40) |

### U3-b — THE TRACE (measured, offscreen; macOS 27.0 26A428, Swift 6.4)

Probe sources, kept DURABLE in the worktree's gitignored `scratchpad/vx179-u3-probe/`
(`probe.swift` the add area · `probe2.swift` the rows + the two capture hosts · `spike.swift` the
placeholder feasibility spike · `esc.swift` the ⎋ road). Re-run any of them with
`xcrun swiftc -swift-version 5 -O <file> -o /tmp/p && /tmp/p` (`probe.swift` also takes `--window`).
`PanelTextArea` is copied VERBATIM from `CommentsPanel.swift:957–1032` (only a geometry report added to
the placeholder) and mounted exactly as `addArea` mounts it (horizontal `Metrics.inset − 5` = 7,
vertical `rowAir` = 7), fonts = `tokens.body` in each voice. Coordinates: the host's, top-down
(`NSHostingView` is flipped).

| quantity | Terminal (SF Mono 14) | Study (Iowan Old Style 16) |
|---|---|---|
| the text view under `TextEditor` | `PlatformTextView`, TK2 on | same |
| `textContainerInset` — assumed top **8** | **(0, 0)** | **(0, 0)** |
| `lineFragmentPadding` — assumed leading **5** | 5 (= `NSTextContainer`'s own default) | 5 |
| typing attributes at mount, EMPTY | the applied font (14 pt), no line spacing | the applied font (16 pt) |
| the empty document's caret (TK2 `.standard` segment) | x 12, y 7–24 (17 = the font's line) | x 12, y 7–29 (22) |
| the first TYPED line / its baseline | y 7–24 / 21 | y 7–29 / 24 |
| the placeholder overlay's text / baseline | x 12, y 15–32 / **29** | x 12, y 15–37 / **32** |
| placeholder − real line | **+8 pt down, 0 across** | **+8 pt down, 0 across** |

Identical with an offscreen, never-ordered-in window and the text view first responder (`--window`).

**THE MECHANISM.** The overlay places the placeholder by a GUESS at `TextEditor`'s private geometry
(top 8 / leading 5, "the same numbers QuickNoteView's placeholder overlay has used since it shipped").
On macOS 27 the text view's `textContainerInset` is (0, 0): its first line starts at the view's top,
so the placeholder is drawn a full 8 pt BELOW the line the caret blinks on and typed text lands on —
start typing and the words jump 8 pt up. The leading guess lines up only because 5 is
`NSTextContainer`'s default `lineFragmentPadding`; neither number belongs to the panel. **The "tall
caret" is NOT a typing-attributes defect:** at mount the empty view's typing attributes already carry
the applied font, and the caret is exactly that font's line (17 / 22 pt). What reads as "left of and
taller than" is that line-high caret drawn 8 pt above the placeholder: in Study the bar spans y 7–29
while the placeholder's "W" spans ≈ y 21–32 (cap height 11.27) — it starts ≈ 14 pt above the W's top
and stops 3 pt above its baseline, at the W's left edge (the x a first typed glyph takes, which is
right). The "shared provenance" claim is STALE: the quick-note pad left `TextEditor` at 13u3 UNIT C.

**The same false constant, twice more inside the panel** (`probe2.swift`, the row exactly as
`commentRow` mounts it):
- **The rows' height ruler** pads its invisible `Text` by `topInset` 8 at the top AND the bottom while
  the real text starts at 0 ⇒ every comment row's text area is **16 pt taller than its text** (Terminal
  33 for a 17 pt line, Study 38 for 22) — all of it dead air between the comment and its stamp line.
- **Terminal's `// ` mark** is padded `.top(PanelTextArea.topInset)` ⇒ its baseline sits at 29 while
  its comment's first line's baseline is 21: **the mark sits 8 pt below the line it marks.**

### The sweep (instance × verdict — FINAL for the measurement, the fixes wait on the ruling)

| instance | host | mechanism | measured | verdict |
|---|---|---|---|---|
| the add area's placeholder | the panel: 2 sheets (`EditorView`, `TakesBottomBar`) + the Takes popover | `TextEditor` + overlay at guessed (5, 8) | +8 pt | DRIFTS — her defect; fix = F-U3-1 |
| the rows' height ruler | same | guessed 8, top and bottom | +16 pt dead air per row | DRIFTS — same fix |
| Terminal's `// ` row mark | same | `.padding(.top, topInset)` | +8 pt | DRIFTS — same fix |
| `QuickNoteView`'s placeholder | the quick-note pad | `CaptureTextView` (OWNED inset (0, 2), padding 0) + host padding (6, 4) + overlay (6, 6) | x 6 = 6; baseline 20 = 20 (T), 23 = 23 (S) | PROVABLY SAFE — every number is the box's own explicit geometry, not a guess (the literal 6 = 4 + 2 is derivation by hand — see Q-2) |
| `QuickEntryBar`'s placeholder | Bookcase / Library quick entry | `CaptureTextView` + a `ZStack` placeholder at the box's top that ignores the box's own 2 pt inset | baseline 26 vs typed 28 (T), 29 vs 31 (S); x equal | DRIFTS 2 pt — not the `TextEditor` class (its inset IS owned) but the same "overlay ignores its box's geometry" shape, on a SECOND surface — see Q-2 |
| the phone's comments sheet | `MobileCommentsSheetView` | a `UILabel` at a literal (8, 10) inside a `UITextView` | not measured (iOS) | OUT OF SURFACE — observation O-U3-1 |
| any other `TextEditor` | — | grep: `CommentsPanel.swift:988` is the app's ONLY `TextEditor` | — | none |

### THE FORK — F-U3-1 (STOPPED HERE: the traced fix is a rewrite of `PanelTextArea`)

**(a) RECOMMENDED — an AppKit-backed control whose geometry is the panel's own, the placeholder laid
out by the same machinery at the same origin.**
1. An `NSViewRepresentable` over an `NSTextView(usingTextLayoutManager: true)` subclass, on
   `CaptureTextView`'s proven recipe (TK2 opt-in at init, the `FallbackCanary`, no TK1 API, the
   write-gated style apply, `SpellcheckLevel.current.apply`, `allowsUndo`) — but NOT `CaptureTextView`
   itself: its ⏎-files rule is R-13u-4's identity, and the panel's ⏎ is a newline.
2. Explicit geometry in ONE Metrics place: `textContainerInset`, `lineFragmentPadding` = the panel's
   named numbers; `font`/`textColor`/`insertionPointColor` AND `typingAttributes` set explicitly from
   the voice (`CaptureTextStyle`'s road — `EditorTypography.resolve` is what `tokens.body` renders;
   rows in `commentInk`), re-asserted when the text empties — the caret is the font's line BY
   CONSTRUCTION, not by tonight's SwiftUI behaviour.
3. **The placeholder by construction: a TWIN non-editable, non-selectable TK2 text view** with the
   identical configuration (font, inset, padding), laid over the editable one at the same frame,
   hit-testing nil, shown only while the text is empty (and hidden while marked text is pending) — the
   same engine lays the same font out under the same insets, so the placeholder's first glyph sits
   where the first typed glyph will and its line IS the caret's line. **Spike evidence**
   (`spike.swift`, rendered to a bitmap offscreen, inset 0 and 6): a twin-configured view's ink box ==
   the typed text's ink box. The cheaper `draw(_:)` override with string drawing comes out **0.5 pt
   high in Terminal** (string drawing uses the unrounded ascender 13.54; TK2 rounds the line to a
   baseline at 14) and exact in Study — close is not "by construction", so the twin. (Drawing through
   a standalone `NSTextLineFragment` lays nothing out — zero bounds — so TK2's own line drawing is not
   reachable without a layout manager; the twin is the cheapest exact road.)
4. **Sizing:** rows grow with their text by measuring the real text view (`PaneMeasurement.height(of:)`
   in `sizeThatFits` — `CaptureTextView`'s road) plus the named inset, retiring the invisible `Text`
   ruler, its `rulerSlack` guess and the 16 pt dead air; the add area keeps its fixed leftover height
   and scrolls itself, and click-anywhere holds (the text view's `minSize` = the visible area, so a
   click below the last line lands the caret at the end — NSTextView's default).
5. **Focus:** `@FocusState` + `.focused($focus, equals:)` gives way to the representable's
   first-responder REPORTS (`CaptureNSTextView.onCaretChange`'s road, delivered async — the B2 NIT-1
   lesson) writing the panel's `focus` (`@State`), and a counted focus REQUEST for the open-time
   `focus = .add`. `.onChange(of: focus)`'s commit-on-leave, `handle(_:)`'s routing and
   `CommentPanelKeyMonitor` stay byte-unchanged; `CommentComposition` untouched.
6. **Keys — unchanged by construction:** the local monitor sees ⌘⏎/⎋ first; every other key is
   NSTextView's default (⏎/⇧⏎ type a newline, as today). ⎋ falling through (nothing to undo) behaves
   as today — measured (`esc.swift`): a plain `NSTextView` and SwiftUI's `PlatformTextView` both hand
   `cancelOperation:` to the next responder (neither overrides it; `complete:` is not invoked), so the
   sheet or popover closes by its host's own road.
7. **Pins:** a pure geometry table (placeholder origin == text origin == the named inset; row height =
   measured + 2 × inset); mounted app-target pins, offscreen-hosted (RUN PENDING stage): the twin's
   first line == the editable view's empty-caret segment in both voices, the row mark's baseline ==
   its row's first-line baseline. The existing panel suites ride unmodified — checked: nothing in
   `VariorumTests` references `PanelTextArea` or its constants (they pin the model).
8. **Size / risks for the walk:** one new file (~200 lines); `CommentsPanel.swift` loses
   `PanelTextArea` and gains the focus plumbing. Walk risks: the focus reports in the POPOVER host
   (transient popover + first responder), the first open's caret (the counted request beside the
   panel's own `makeKey` ask), undo grouping, IME marked text over the placeholder.

**(b) Keep `TextEditor`; introspect its private `PlatformTextView`** once mounted (a zero-size
representable walking SwiftUI's hosting tree) and read its real `textContainerOrigin` /
`lineFragmentPadding` into the overlay, or SET explicit insets on it. Smaller diff, but it couples the
panel to SwiftUI's private view tree (class name, sibling order, whether SwiftUI re-applies its insets
on update) — the drift class moved, not closed. Not recommended.

**(c) Re-tune the constants to (0, 5)** — tonight's numbers. Ruled out by the brief (a nudged
constant), and the probe shows why: neither number is the panel's.

**For the ruling (with the recommendation):**
- **Q-1 — the fork:** (a) or (b). Recommend **(a)**.
- **Q-2 — `QuickEntryBar`'s measured 2 pt drift** (a second surface; not the `TextEditor` class):
  (i) fold a two-line derivation into this unit's sweep — `CaptureTextView` exports its owned inset as
  a named static that `makeNSView` and the bar's placeholder padding both read (exact by
  construction), and `QuickNoteView`'s literal 6 = 4 + 2 derives from the same static (no visible
  change there); the walk adds one capture of the bar per voice; (ii) ticket it for the Bookcase
  surface. Recommend **(i)** — small, mechanism-level, and the sweep's closing form wants every
  instance fixed or provably safe.
- **Q-3 (under (a)) — the control's home:** a panel-private `Features/Editor/CommentTextArea.swift`
  (one consumer) — recommended; or `Core/Views` beside `CaptureTextView` sharing a base text-view
  class (premature with one consumer).

**Observation O-U3-1 (not this surface):** the phone's comments sheet places its placeholder as a
`UILabel` at a literal (8, 10) inside a `UITextView` (whose default inset (8, 0, 8, 0) + padding 5 put
text at (5, 8)) — the same hand-placed shape on iOS; unmeasured here; for the VM board.

### F-U3-1 RULING (the orchestrator, 2026-10-12 — same turn as the proposal; the implementer resumes on it)

- **Q-1: (a).** The AppKit control on `CaptureTextView`'s recipe — insets, `lineFragmentPadding` and
  typing attributes owned in ONE Metrics place; the placeholder a configured TWIN non-editable TK2
  text view over the editable one (the spike's pixel-exact arm; the 0.5 pt `draw(_:)` arm rejected);
  rows sized from the real text view (the ruler and its 16 pt dead air retire); Terminal's `//` mark
  aligns to the real first baseline. CONSTRAINTS: `CommentComposition`, `CommentPanelKeys`, the key
  monitor and the panel's focus SEMANTICS stay byte-unchanged (open-focused-on-add; focus-loss saves
  an in-place edit; ⎋ falls through to the host's close when there is nothing to undo — the measured
  `cancelOperation:` path is the contract); `CommentsPanelEditorTests`/`CommentPanelParkTests` pass
  UNMODIFIED except cells pinning the old control's internals, each edit justified in the record. The
  three walk risks (popover focus, undo grouping, IME marked text) become named walk rows.
- **Q-2: (i).** Fix `QuickEntryBar`'s 2 pt drift in this unit, exactly as proposed: `CaptureTextView`
  exports its owned inset as a named static; `makeNSView`, the bar's placeholder padding and
  `QuickNoteView`'s derived literal all read it (QuickNote visibly unchanged — it is the parity
  proof). Capture SEMANTICS (microsyntax, filing) untouched — this is alignment only. One bar
  capture per voice joins the walk; the sweep table closes with every instance fixed or provably
  safe.
- **Q-3: the panel-private home** — `Features/Editor/CommentTextArea.swift` (one consumer; a shared
  base class is premature). The shared inset static lives with `CaptureTextView` where it is owned.
- O-U3-1 (the phone's hand-placed placeholder): minted on the VM board at this ruling (see ledger).

### U3-d — what was built (on the F-U3-1 ruling) and the offscreen evidence

**Built.** `Features/Editor/CommentTextArea.swift` — `CommentTextArea` (`NSViewRepresentable`) over
`CommentTextAreaView`: the editable `CommentNSTextView` (TK2 at init; inside an `NSScrollView` for the
add area, bare for a row so the list's wheel is never taken), a PLACEHOLDER twin behind it at the
editable view's own frame (read from the view, `textView.convert(.zero, to: area)`), a MARK twin
beside it — every view configured by ONE `configure(_:editable:)` (inset, padding, container), so a
twin lays the same font out from the same point. `CommentTextStyle(tokens:ink:)` is the one look
value (font = `EditorTypography.resolve` = what `tokens.body` renders; caret `accent`; placeholder
`faint`; mark `commentInk` × 0.75) and owns `typingAttributes`, re-stated at every style change and
whenever the area empties. Row height = `PaneMeasurement.height(of:)` (the one measurement brain) →
`CommentsPanelMetrics.rowHeight`. Focus: `becomeFirstResponder`/`resignFirstResponder` (+ a focused
view leaving its window) report async; the panel's `focus` takes them through the pure
`CommentPanelFocus.after(report:inArea:current:)`; the open-time ask is a counted request, HELD when
the area has no window yet and served on arrival. IME: `setMarkedText`/`unmarkText` refresh the twin.
Spelling: `SpellcheckLevel.current`. Canary armed on every view. ONE numbers place:
`CommentsPanelMetrics` (internal, in `CommentsPanel.swift`) — the text geometry (`textInset` (0, 2),
`lineFragmentPadding` 0, `firstLineOrigin`, `rowHeight`, `markColumn`, `markInkOpacity`) beside the
layout's taste numbers; the panel's private `Metrics` is now a typealias of it.

**Evidence — the REAL compiled control, offscreen** (`scratchpad/vx179-u3-probe/real/control.swift`,
built by `real/build.sh` against this worktree's Debug `Variorum.debug.dylib` with `@testable import
Variorum` — the app's own compiled code, not a copy; `.prohibited` activation, no `NSApp.run`; the one
`NSWindow` (the focus check) is never ordered in):

| check | Terminal | Study |
|---|---|---|
| empty caret vs the placeholder twin's first line (area coords) | (0, 2, h 17) == (0, 2, h 17) | (0, 2, h 22) == (0, 2, h 22) |
| placeholder INK box vs the same words TYPED (bitmap, pure-red vs pure-blue ink) | (0, 4.5, 138 × 12) == (0, 4.5, 138 × 12) | (0, 7, 138 × 12.5) == (0, 7, 138 × 12.5) |
| typing attributes' font, empty / after type-then-clear | == the style font / == | == / == |
| twin: after typing · after clearing · while marked (IME) · after commit+clear | hidden · shown · hidden · shown | same |
| a row's height vs its text (one line) — the dead air | 21 = 17 + 2 × 2 (none) | 26 = 22 + 2 × 2 (none) |
| a two-line row | 38 = 2 × 17 + 4 | 48 = 2 × 22 + 4 |
| the `// ` mark's first baseline vs the text's | 16 == 16 | (no mark) |
| the focus request raised before a window | held; served on arrival: first responder, report `[true]`; resign → `[true, false]` | — |
| ⎋ (`cancelOperation:`) on the area | reaches the next responder (1×) — the host's close road, as `PlatformTextView` did | — |
| Q-2 — the real `CaptureTextView` + a placeholder at `QuickEntryBar.placeholderOrigin` | baseline 16 == typed 16; x 0 == 0 | 19 == 19; 0 == 0 |
| Q-2 — `QuickNoteView.placeholderOrigin` (the parity proof) | (6, 6) — unchanged | (6, 6) |

Red-on-old (the measured defect on the OLD control, U3-b): +8 pt placeholder vs caret line in both
voices, 16 pt dead air per row, the mark 8 pt low; the bar 2 pt high. The same checks on the new tree:
all equal (above). The app-target pins that hold these (U3-d3) can only RUN under the stage.

### U3-e — the pristine pass (what changed, and why each)

1. **The composer.** The add area — still §2 D's add area whole (it owns every point the comments
   leave; a click anywhere lands the caret: the text fills the card, and the card's padding and foot
   row raise the counted focus request through a background tap, the hint words passing clicks through;
   ⌘⏎ / Add files, ⎋ clears, ⏎ is a newline) — now reads as a place to write: the voice's `card`
   paper and `line` hairline at `VoicedField`'s radius (the app's own writing box, no bezel), the
   hairline taking the accent at `VoicedChip`'s "on" strength while the caret is in it, and its keys
   hint + Add door INSIDE the box they act on (they lived in a bar under the whole panel). The
   screenshot's "void with a word floating in it" becomes a framed, quiet box with its first line
   ready.
2. **Two columns.** A WRITING column (`writingInset` = the chrome inset + the card's padding) where
   every word starts — the composer's text, every comment, every stamp line, live or deleted — and a
   CHROME column (`inset`) for the title, the card's edge, the hairlines, the fold's toggle. Row
   separators are held in from the panel's edges (rows of one list, not bands of the panel).
3. **Header:** the count shows only when non-zero; title and count share a first baseline.
4. **The deleted fold — one visual language with the live list:** a quiet toggle on the chrome column
   ("▸ Deleted (n)", its word aligned through the vocabulary's own `VoicedButtonStyle.labelInset`,
   named in `VoiceControls` rather than re-typed), and each row the live row's twin in a quieter
   register — the words struck through and muted, then the same stamp line ("Deleted <date>", then
   Restore and U1's "Delete forever…" at the trailing edge). The fold is present only when something
   is deleted.
5. **Add fades when there is nothing to file.** It was a `CalmButtonStyle`, which ignores the
   disabled state — a live-looking door that did nothing; it is now the panel's own
   `VoicedButtonStyle(.primary)` like Save, which fades. (The vocabulary gap in `CalmButtonStyle`
   itself is app-wide — observation O-U3-2, not touched here.)
6. **Words:** every string the panel shows is in `CommentsPanelCopy` (title, Close, Save, Revert,
   Delete, Restore, Add, Cancel, the fold toggle, "Deleted", the stamp format, the help line, the
   observation-failure line); sentence case throughout — `unsavedMark` "unsaved · ⌘⏎" → "Unsaved ·
   ⌘⏎" (Terminal still lowercases it via `chromeLabel`); the delete receipt names the fold by its
   word ("…it's under Deleted below, restorable.").
7. **O-3 — every refusal in words.** `CommentsPanelRefusalCopy.message(for:)` in `TrayRefusalCopy`'s
   shape: the panel's own arms (seal, empty text — exactly as before — plus `commentNotFound`,
   `commentNotDeleted`, `purgeTargetNotDeleted`, `blockNotFound`), then `OpsRefusalCopy.message(for:)`.
   Traced: `commentNotFound`/`commentNotDeleted` are mapped NOWHERE in the app, and the shared table's
   own fallback is still `"Refused: \(error)"`, so routing through it alone would not have closed O-3
   for the panel's races; its `purgeTargetNotDeleted` sentence speaks of the Trash (wrong here — in the
   panel it means the comment was restored between the listing and the confirm). The observation's
   failure line is worded too (`observationFailed`). PROVISIONAL wording (P-VX179-U3-3).
8. **Numbers:** `CommentsPanelMetrics` — chrome inset 16 (was 12), card padding 12, header 14/10,
   list top 4, row air 9 (was 7 — when rows also carried 16 pt of dead air), stamp gap 3 (was 1), add
   floor 156 (was 132 — the floor now holds the card's margins and foot, so ≈ 86 pt of writing room
   stays), card margin 12, foot padding 8, foot gap 6, radius 8, live stroke 0.55, fold toggle air 6.
   All PROVISIONAL, for the walk.

### The look, rendered (the implementer's own check — NOT the walk)

`scratchpad/vx179-u3-probe/real/render.swift` renders the REAL `CommentsPanel` (the compiled app
module) over a THROWAWAY in-memory store, offscreen, to `scratchpad/vx179-u3-renders/` — Terminal and
Study × light and dark × {empty, two comments + one deleted, typed, a refusal} = 16 PNGs (plus 4 "foldOpen" renders that came out identical to the two-comments ones — the fold did not open offscreen), every one of the 20
opening with the caret in the add area (the first responder was `CommentNSTextView` in all 20 — the
open-focused-on-add semantics, through the held request). What the renders cannot show: the caret
itself (a never-key window draws none), hover washes, the OPEN fold (SwiftUI buttons in a never-key
window ignore synthetic clicks, and its accessibility tree is not built offscreen — the walk's), and
the popover host.

**PROBE INCIDENT (machinery honesty — recorded, contained):** the render probe's FIRST run did not
inject `@Dependency(\.database)`; an access fell to `AppDatabase.liveValue`, which tried to open a
store at the UNSANDBOXED default path `~/Library/Application Support/Variorum/variorum.sqlite`. The
open refused (the Keychain save failed, so no encrypted library was created) and the process
stopped; it had created exactly one directory and one 120-byte key-record file
(`variorum-keys-2b4ad7a7f6e1873e.json`), both born 22:09:03 by `stat`, during that run. Neither real
store was touched (both live under `~/Library/Containers/io.lduarte.Variorum(.debug)`); the
directory did not exist before the run. I removed exactly that file and directory. The probe now
injects ONE in-memory store with `prepareDependencies` before anything runs, refuses to start if the
default folder exists, and reports at exit that it was never created ("default store folder created:
false" on every later run).

### U3-g — behavioural reverts (ANNOUNCED before they start; the fix is committed first, so `git checkout -- App/Variorum/Variorum/Features/Editor/CommentTextArea.swift` is the safe restore)

- R-a: remove `undoHistory.removeAllActions()` from the programmatic adopt → expect the pin's replay to
  CRASH at the undo after the clear (`NSRangeException`).
- R-b: remove the did-undo/did-redo observers' sync → expect "the draft follows the undo" and the redo
  cells to FAIL.
Each revert: edit → plain build → `real/undopin` (a probe binary linked DYNAMICALLY against the debug
dylib, so the rebuilt module is what it runs) → restore by `git checkout --` → `git diff --stat` empty.

| revert | result on the real module | restored |
|---|---|---|
| R-a — the adopt's `removeAllActions()` off | "nothing to undo into" FAIL, then the replay CRASHED: `NSRangeException … Range {13, 9} out of bounds; string length 0` — the shipped defect, reproduced | yes |
| R-b — the did-undo/did-redo sync off | 2 FAIL: "the draft follows the undo", "placeholder back after the undo" (the redo cells pass under R-b only because the draft never moved — the undo cells are the discriminating ones) | yes |
| the restored tree, rebuilt | `undopin` 10/10 PASS; `control` every check equal (both voices) | — |

### The sweep, closed (instance × verdict — the constitution's closing form)

| instance | host | verdict |
|---|---|---|
| the add area's placeholder (her defect: +8 pt) | the panel — sheets in `EditorView` and `TakesBottomBar`, the popover in `TakesShared` (one view) | FIXED — the twin; caret line == placeholder line, ink == typed ink, both voices (probe + pins) |
| the comment rows' height ruler (+16 pt dead air per row) | same | FIXED — rows measured from the real text view (`aRowIsItsTextWithNoDeadAir`) |
| Terminal's `// ` row mark (+8 pt) | same | FIXED — the mark twin; baseline == the text's (`theMarkSitsOnTheTextsFirstBaseline`) |
| `QuickEntryBar`'s placeholder (+2 pt) | Bookcase / Library quick entry | FIXED (Q-2) — `placeholderOrigin` = the box's own `firstLineOrigin`; baselines 16 == 16 / 19 == 19 on the real box |
| `QuickNoteView`'s placeholder | the quick-note pad | PROVABLY SAFE, now BY CONSTRUCTION — derives (6, 6) from the same static; unchanged (the parity cell) |
| the phone's comments sheet (`UILabel` at a literal (8, 10)) | `MobileCommentsSheetView` | OUT OF SURFACE — O-U3-1, minted on the VM board at the ruling |
| any other `TextEditor` | — | NONE — the panel's was the app's only one, and it is gone |

### Dispositions (U3's rows — her items 1 + 4, the brief's items, U1's hand-offs)

| row | disposition |
|---|---|
| her item 1 — the misaligned caret | FIXED at mechanism (F-U3-1 (a)): traced + measured (U3-b), the control (fa488500), pins + probe evidence; the walk PENDING |
| the sweep (QuickNote + any other overlay) | CLOSED — the table above; the bar's 2 pt FIXED under Q-2 (1d347966) |
| her item 4 — "pristine + nice UI / UX" | BUILT (4b7cfd60) — the composer, two columns, the fold's one language, Add's honest disabled state, the words; taste numbers PROVISIONAL; the walk decides |
| U1's "Delete forever…" row joins the pass | DONE — the fold's stamp line carries Restore + "Delete forever…" (the confirm unchanged) |
| O-3 — the fallback refusal's raw dump | FIXED — `CommentsPanelRefusalCopy` (4b7cfd60); red-on-old pin `thePanelsRacesSpeakWordsNotTheEnum` (RUN PENDING) |
| sentence case / every string in the copy enum | DONE — `everyPanelWordIsSentenceCase` |
| the three ruled walk risks | popover focus → walk row W-U3-6; undo grouping → PROBED, found TWO pre-existing defects, FIXED (U3-g) + pinned, still a walk row (W-U3-7); IME marked text → probed (the twin hides while composing) + pinned, still a walk row (W-U3-8) |
| U3-g — ⌘Z after filing crashes; ⌘Z desyncs the draft | FIXED (7d9e5525) — pin first (a76de514/d3a21eea), red by revert R-a/R-b on the real module |

### PENDING (stage-gated — none of it claimed)

- **Pin RUN** (via `oct12coordinator`, suite-level, held claim):
  `-only-testing:VariorumTests/CommentPanelGeometryRuleTests -only-testing:VariorumTests/CommentTextAreaMountedTests
  -only-testing:VariorumTests/CommentPanelWordsTests -only-testing:VariorumTests/CommentsPanelModelEditorTests
  -only-testing:VariorumTests/CommentCompositionTests -only-testing:VariorumTests/CommentPanelKeysTests
  -only-testing:VariorumTests/CommentPanelParkTests -only-testing:VariorumTests/CaptureFocusReportTests
  -only-testing:VariorumTests/CaptureKeysTests -only-testing:VariorumTests/CaptureTextViewKeyTests
  -only-testing:VariorumTests/CaptureHandOffTests -only-testing:VariorumTests/QuickNoteParkTests` (the last six ride UNMODIFIED over the capture box's
  named-inset change). In-target red-on-old for U3-g: the revert pair above, re-run as test runs.
- **The walk** — DEV-STORE Debug build, both voices × both appearances, one capture per row:
  W-U3-1 the sheet from Write: empty panel — the composer, the placeholder on the caret's line, the
  caret line-high (her screenshot's exact state); W-U3-2 typing replaces the placeholder in place (no
  jump), ⌘⏎ files, the box clears, the new comment visible; W-U3-3 three comments incl. a multi-line one
  — the writing column, the stamp lines, Terminal's `// ` on its line with wrapped lines hanging;
  W-U3-4 click a comment and edit in place, the "Unsaved · ⌘⏎" mark, click elsewhere saves; W-U3-5 the
  deleted fold open — struck rows, "Deleted <date>", Restore, "Delete forever…" (+ U1's confirm);
  W-U3-6 THE POPOVER host (the Takes margin note) — opens focused on the add area, typing lands, the
  composer's live hairline, ⎋ with nothing typed closes it, Delete forever's confirm appears and acts
  (U1's walk check); W-U3-7 UNDO — type, ⌘⏎, then ⌘Z: no crash, nothing comes back; type, ⌘Z: the
  text goes AND Add greys (the draft followed); ⇧⌘Z brings it back; W-U3-8 IME — compose Japanese in
  the empty add area: the placeholder hides while composing; W-U3-9 the click-anywhere contract — the
  composer's padding and foot row land the caret; W-U3-10 a refusal under a seal reads in the alarm
  register, in words; W-U3-11 the Takes bottom-bar sheet; W-U3-12 the quick-entry bar, empty, both voices
  — the hint on the typed line (no 2 pt drop when typing); W-U3-13 the quick-note pad — unchanged.

### PROVISIONAL — owed to `notes/QUESTIONS.md` at the merge moment (the shared-ledger rule)

- **P-VX179-U3-1 — the composer's look.** Built: (a) the add area as a framed writing box (card paper +
  hairline, the accent hairline while live, the keys hint and Add INSIDE it). Options: (b) the box
  without the live hairline; (c) the shipped flat area with the keys and Add in the foot bar.
- **P-VX179-U3-2 — the taste numbers** (`CommentsPanelMetrics`: chrome 16, card padding 12, header
  14/10, list top 4, row air 9, stamp gap 3, add floor 156, card margin 12, foot 8/6, radius 8, live
  stroke 0.55, fold air 6, text inset (0, 2)).
- **P-VX179-U3-3 — the refusal words** (`CommentsPanelRefusalCopy`'s four sentences + `observationFailed`).
- **P-VX179-U3-4 — undo is PER AREA, and a programmatic replacement ends it** (U3-g's semantics: ⌘Z
  in a comment undoes that comment's typing only; after filing, reverting, a park restore or a store
  arrival there is nothing to undo into). Options: (b) one panel-wide undo history (needs a design
  for what undoing across areas means); (c) make the filing clear itself undoable (⌘Z after ⌘⏎
  brings the filed words back into the box — a duplicate-filing hazard).
- **P-VX179-U3-5 — Add as a voiced word** (`VoicedButtonStyle(.primary)`, fades when there is nothing
  to file) instead of the bordered `CalmButtonStyle` (which ignores disabled — O-U3-2).

### Observations (NOT fixed here — for the orchestrator)

- **O-U3-2:** `CalmButtonStyle` ignores the disabled state app-wide (no fade, no ink change), so every
  `.disabled` Calm button reads live. The panel stepped around it (P-U3-5); the vocabulary fix is
  app-wide — ticket candidate.
- **O-U3-3 (HIGH — the lost-prose neighbourhood): `CaptureTextView` has U3-g's second defect** —
  measured on the real box (`real/capture-undo.swift`): type "a thought", ⌘Z → the box shows "" while
  the binding keeps "a thought", so ⏎ in the quick-entry bar or the quick-note pad files words she
  undid. Same mechanism (no `textDidChange` on undo/redo), same fix shape (the box's own manager +
  its did-undo/did-redo). Another surface — ticket candidate.
- **O-U3-4 (harness hazard):** an un-injected `@Dependency(\.database)` in ANY headless harness falls
  to `AppDatabase.liveValue`, which opens — and on a fresh machine CREATES — a store at the
  unsandboxed default path (this unit's probe incident, contained and recorded above). The tests are
  safe by the harness's explicit injection; a scratch probe is not. Worth a line in the probe notes.

## STAGE WINDOW 1 (the orchestrator, 2026-10-12 late — granted and coordinated by oct12coordinator)

Pinned checkout `~/dev/variorum-vx179-test` at c0888701 (U0+U1+U2 product code; U3 record-only),
own DerivedData, claim `vx179-tests`. Results:
- **All 12 U1/U2 suites GREEN — 83 tests** (64/9: CommentCardLayout/View/Controller, ProseGutter,
  BlockDecorGeometry, IndicatorGutter, MarginHoverComment, CommentsAndReorder, CommentPanelPark;
  + 19/3: CommentComposition, CommentPanelKeys, CommentsPanelModelEditor — the type names behind
  `CommentsPanelEditorTests.swift`; the "CommentsPanelEditorTests" -only-testing name matched no
  type and ran zero tests, caught by the suite-count check).
- **U2's red-on-old REVERT CHECK EXACT:** the old `min(blockHeight + 24, 96)` formula back in →
  exactly 7 cells red (6 in `theCardGrowsToTheBlocksOwnHeightWithinTheRhythm` + the flipped cap
  cell in BlockDecorGeometryTests), file restored → 24/2 green again.
- U1's three panel-model pins (deleteForever) rode the CommentsPanelModelEditor suite GREEN.
Stage released after; result line sent to the coordinator. WINDOW 2 owes: the U3 suite list (the
U3 RECORD's), a U3-g revert spot-check through the test target, and the walk (U1's popover
confirm + U2's W-1…10 + U3's W-U3-1…13, both voices).

## FOUND-WORK TICKETS (minted during the run)
- VX-182 — restoreCost.deleted_takes lacks the purge fence (U1's O-1).
- VX-183 — comments panel doors undeclared in the capability registry (U1's O-2).
- VM-14 — the phone's hand-placed comments placeholder (U3's O-U3-1).
- VX-193 — CaptureTextView's undo desync: ⏎ files undone words (U3's O-U3-3, HIGH; measured).
- VX-194 — CalmButtonStyle ignores the disabled state app-wide (U3's O-U3-2).

### U3 FIX LEG (implementer, 2026-10-12 — the orchestrator's window-2 red)

**THE RED:** `CommentTextAreaMountedTests/aFocusRequestBeforeAWindowIsHeldAndServedOnArrival`, in the
xcodebuild runner, alone and in the set (99/100 green): `window.firstResponder === area.textView`
false (:358), `log.reports == [true]` false (:359), `log.reports == [true, false]` false (:362). No
`xcodebuild test` in this leg (the stage is not mine); reproduced with offscreen probes against the
real module.

**THE MECHANISM (traced, measured — `real/focusrunner.swift`):** the runner runs a `@MainActor async`
test body as a JOB ON THE MAIN QUEUE. The control serves a held focus request one main-queue turn
after the window arrives (`viewDidMoveToWindow` → `DispatchQueue.main.async` — `CaptureNSTextView`'s
precedent: let the window settle first) and delivers its first-responder reports on the next turn
(the B2 NIT-1 rule: never inside a view update). The pin's `settle` only pumps `RunLoop.main.run(until:)`
synchronously, and a nested run loop does NOT drain main-queue blocks while its caller is itself a
main-queue job — so neither block could run before the expectations. My earlier probe ran the same
steps at TOP LEVEL (outside any main-queue job), where the nested run loop does drain the queue —
which is why it measured green. Reproduced in the runner's shape (the steps inside a main-actor
`Task` with the main run loop running): sync settle → served **false**, reports **[]** then **[]** —
exactly the three red expectations; a SUSPENDING settle (yield + a 10 ms sleep per turn, the
`CaptureFocusReportTests` idiom, green in this same runner since 17y B2) → served **true**, **[true]**,
**[true, false]**.

**WHICH SIDE IS WRONG: the PIN's environment assumption, not the product.** In the app the main queue
drains between events, so the held request is served on the turn after arrival (the render probe's 20
panels all opened with the caret in the add area). The contract the pin holds is unchanged — a
request raised before a window is HELD and SERVED on arrival, and the area REPORTS arrival and
departure; only how the pin lets a turn pass changes.

**Revert announced BEFORE it starts (the product side, to prove the fixed pin still discriminates):**
R-c — make `CommentTextAreaView.requestFocus()` DROP a windowless request (`CaptureTextView.takeFocus`'s
shipped behaviour: return at the window guard, no hold) → expect the fixed pin's "served on arrival"
and "reports [true]" cells RED in the runner shape; restore by `git checkout --
App/Variorum/Variorum/Features/Editor/CommentTextArea.swift`. No revert in flight at this commit.

**THE FIX (the pin, 2ceacf60):** the focus cell settles with `settleLettingTurnsPass` — the suite's
synchronous `settle` plus `await Task.yield()` and a 10 ms `Task.sleep` per turn (`CaptureFocusReportTests`'
idiom, green in this runner since 17y B2). Every other mounted cell keeps the synchronous settle: none
waits on a deferred turn, and all 15 were green in the runner. No product line changed — the trace
did not demand one. Typecheck EXIT 0.

**EVIDENCE (offscreen, real module, the runner's shape — `real/focusrunner.swift`):**

| tree × settle | served on arrival | reports after arrival | after resign |
|---|---|---|---|
| product as committed × the OLD synchronous settle | false | [] | [] — the runner's three reds, reproduced |
| product as committed × the FIXED settle | true | [true] | [true, false] |
| R-c (the product's hold removed: a windowless request is dropped) × the FIXED settle | **false** | **[]** | [] — RED: the fixed pin still discriminates the product mechanism |
| R-c restored (`git checkout --`, `git diff --stat` empty), rebuilt × the FIXED settle | true | [true] | [true, false] |

**Red-on-old reasoning:** the held request is new in this control (the shipped `TextEditor` had
`@FocusState`; `CaptureTextView.takeFocus` drops a windowless request — R-c is exactly that shipped
behaviour), so the pin is a FEATURE pin; its discriminating revert is R-c, red as above. The runner's
red was the pin's environment, never the product: proven by reproducing it with the product unchanged
and the old settle.

**PENDING (stage):** the runner re-verification — `-only-testing:VariorumTests/CommentTextAreaMountedTests`
(expect all 9 tests — 13 cases with the voice arguments — green incl. this cell) or the whole U3 list again; optionally R-c through the test target (expect
exactly this cell red: 3 issues at the served / [true] / [true, false] expectations).

## STAGE WINDOW 2 (the orchestrator, 2026-10-12 ~22:30 — suites DONE, the walk BLOCKED)

- **Suites at the tip: 100 tests / 16 suites, 99 green, ONE deterministic red** —
  `CommentTextAreaMountedTests/aFocusRequestBeforeAWindowIsHeldAndServedOnArrival` (alone and in
  the set). Routed to the U3 session; its FIX LEG traced it to the PIN's environment (a
  main-actor test body is a main-queue job; the old synchronous settle could never drain the
  control's one-turn-deferred focus service) and fixed the pin only — zero product lines, verified
  by path diff (`ff30b1f7..HEAD -- App/Variorum/Variorum/` empty, `Sources/` untouched since U1).
  Runner re-verification of the mounted suite + the R-c discriminating revert: NEXT WINDOW.
- **The WALK is BLOCKED at the first capture:** `walk-cap` fails twice ("could not create image")
  on my dev Debug instance — the Screen Recording denial shape for THIS session's host. Per her
  standing rule (relayed by oct12coordinator): stopped immediately, no workaround, my instance
  killed (no real-store instance existed at any point), stage released, the coordinator took the
  grant/restart to her. The walk re-books on READY once this session can capture.

## STAGE WINDOW 3 (the orchestrator, 2026-10-12 ~23:00 — ~10 min)

- CommentTextAreaMountedTests **9/9 GREEN** after the fix leg's pin fix (the runner's own shape).
- **The R-c discriminating revert, run through the test target:** the windowless-request drop back
  in → RED on exactly the one focus cell with exactly 3 issues; restored → 9/9 green again. The
  fixed pin still catches the product mechanism — the feature pin discriminates.
- Every VX-179 suite is now GREEN in the runner (window 2's 99 + the fixed mounted suite).
- Remaining stage need: THE WALK only (behind her Screen Recording fix for this session).
- The LADDER (fable-reviewer, read-only) starts now — the skill's own allowance: screenshot-verify
  where the environment allows, else record and fold into the next drive; the walk rows stay owed.

## LADDER ROUND 1 (fable-reviewer, 2026-10-12 — the whole run diff `c84eddf1..HEAD`, 24 files)

**What was reviewed, cold:** the full diff read file-by-file in this session; the run record; CLAUDE.md
+ its auto-loaded canon; SyncSpec IN FULL (the diff carries a `Sync/` line); TEXTKIT2_NOTES §3–4 (a new
TK2 control + decoration-overlay work); the 13j purge machinery around every touched arm
(`Operations+Purge`, `PurgeFamily.expand`/`deleteOrder`, `PurgeJanitor.familyVerdict` + the
table-agnostic intent collection at PurgeJanitor.swift:338, `Trash.swift:205`'s standing fence arm);
the server purge arrays (`10_phase13j_purge.sql:219/226/377/380/565/616/660` — `block_comment`
present everywhere, zero server work, marker untouched, as claimed). The full headless suite re-run by
the reviewer at the tip: **core 2,704/307 · VariorumMCPTests 122/18 · workbook 40/6 — all green**,
matching the record's finals exactly. No "Review foci" section exists in the record. Constraints this
session: no `xcodebuild test`, no app launch, no window (the stage is not this session's) — the
app-target suites stand on the stage windows' runs (83 + 100 green, reverts exact), re-read here, not
re-run.

### Findings (severity-ranked)

**R1-1 · MINOR · notes/plans/fixes/vx-179-comment-polish.md (LEDGER row 10) + AppSpec §7/§9 — the
merge-moment CANON DELTA is owed and unlisted.** R-VX179-1/2/3 are rulings born in a ticket, and the
workflow rule (CLAUDE.md, "Tracker & parallel work") is that such a ruling lands in canon at the merge
exactly as a sitting's would. Two standing AppSpec sentences are now bent by R-VX179-3: §7's
`block_comment` note ("Deleted comments stay visible and resurrectable") and §9's comments bullet
("deleted comments visible and resurrectable") — a comment given "Delete forever…" is deliberately
neither, and §9's quiet enumeration of the purge road doesn't know the sixth purgeable kind. Evidence:
ledger row 10 names PR/worktree/debris/MOBILE-PARITY and the PROVISIONAL deposits, but no AppSpec
contract line. Fix: add the canon-delta duty to the closeout row — one contract line each at §7's
block_comment note and §9's comments bullet (what is now true + a pointer to this record), landed by
the merging session on latest main.

**R1-2 · MINOR (bug half SPECULATIVE) · CommentsPanel.swift:1098 (`close()`) + the U3 walk list — the
POPOVER host's dismiss-with-a-dirty-edit road is uncovered by any walk row.** U3 replaced `@FocusState`
with async first-responder reports: on a transient popover's click-away, the area's departure report
travels `viewWillMove(toWindow: nil)` → `DispatchQueue.main.async` (CommentTextArea.swift:560–563,
142–145) and lands while the SwiftUI view is being dismantled, so `.onChange(of: focus)`'s
commit-on-leave cannot be assumed to run; the panel's `close()` (which commits dirty edits) never runs
on that road; and the draft park nets REFUSAL-time drafts only (CommentsPanel.swift:254–296). Whether
words are actually lost — and whether the old `@FocusState` road saved them (likely the same class,
i.e. pre-existing) — is not traceable headlessly, so the BUG half is SPECULATIVE and no red-on-old pin
can be named without the stage. The coverage gap is concrete: W-U3-6 checks open/typing/⎋/confirm on
the popover, and W-U3-4's "click elsewhere saves" stages the SHEET. Fix: add one walk row — edit a
comment in the Takes margin-note popover, click away to dismiss, reopen: the edit saved (or parked and
said). If it drops words: pre-existing-class → ticket; new-in-U3 → the fix pass.

**R1-3 · NIT (SPECULATIVE) · CommentCard.swift:522–539 (`scrollWheel`) — the latch re-decides on
`.mayBegin`/`.began` only, not on "the gesture's first MOVING event" as `wheelOwner`'s own doc
(CommentCard.swift:110–112) promises.** If AppKit ever delivers a zero-delta `.began`, an overflowing
card latches `.card` (the zero-delta answer, CommentCard.swift:124) and the `.changed` events never
re-decide — a gesture pushing past the card's edge would rubber-band inside the card instead of moving
the page. Unverified whether zero-delta `.began` occurs in practice (ordinarily `.began` carries the
first movement); W-3's walk row shows the symptom unmistakably if real. Fix if the walk sees it:
re-decide while the latched decision was made on zero deltas (one condition beside the `.began` arm) +
its table cell.

0 BLOCKER · 0 MAJOR · 2 MINOR · 1 NIT.

### Clean bill (load-bearing things specifically checked and found solid)

- **The `Sync/` line (U0):** `familyVerdict`'s staleness net traced end-to-end — the intent collection
  is table-agnostic, `expand`'s default arm is the comment row itself, `deleteOrder` already carried
  `block_comment` first, the stranded-origin exemption can't reach the kind, and adding it to
  `tombstonedKinds` cannot make a block/container family spuriously stale (under a dead block every
  comment is tombstoned by cascade or its own hand; batch application is atomic). The two-client pin's
  choreography (restore lands before the intent; sweep at the intent holder) is exactly the B1 shape;
  red-on-old by revert recorded at ledger row 2. Zero schema, zero lockstep, wire untouched
  (`purge_intent` rows are ids/enums, ALL-PLAIN — SyncSpec read in full).
- **The purge arm (U1):** every refusal traced against the real guards (`liveComment`-shaped fetch,
  tombstone check, `liveBlock`, `ensurePlacementUnlocked`); D-2's cascade-victim hazard independently
  re-derived (an intent can only ever name a comment deleted on its OWN stamp under a live block, so
  no exact-stamp flip reaches it) and confirmed closed; idempotence + already-purged skip; the fence
  is byte-the-same stamp-aware arm as `Trash.swift:205` — its cross-device clock-skew residual (a
  voided intent's later stamp vs a skewed re-delete) is the 13j-ruled standing class, inherited, not
  new. Both revive-road belts (restoreBlockComment, reapplyAddedComment) sit inside their
  transactions; the reader/revive sweep tables re-walked and found complete.
- **The suite, re-run by the reviewer:** core 2,704/307 + MCP 122/18 + workbook 40/6 green at the tip
  — the record's counts exact.
- **U2 geometry + card:** the cap retirement's arithmetic (parity ≤ 72 pt blocks, rhythm bound, floor,
  width/lane untouched); the seven red-on-old cells matched the stage window's revert exactly;
  `reconcile`'s table (duplicates, shrink/grow, pool never minting per pass) correct; one-door
  `hitTest` + read-tier click-through + no-scroller-on-read-tier; `wheelOwner`'s fit/overflow/edge/
  horizontal table correct with `stack.frame.height` safe as the content input (document ≥ viewport by
  construction); the budget's idempotent `presentCard` + measure-only-on-text/width-change, with
  component-wise colour compare (the old `present` re-minted the rule view every pass — the new card
  is strictly cheaper at steady state); pool z-order unchanged (`pool(below: false)` was a plain
  `addSubview`, as the reconcile path is).
- **U3 control:** TK2 opted in at init on all three views, ZERO TK1 API in every touched file (grep),
  canary armed per view, no custom caret drawing, twins are separate views (no rendering attributes —
  TEXTKIT2 §3/§4 respected); geometry owned in ONE metrics place with the stamp line and both capture
  hosts deriving from it (the bar's +2 exact, QuickNote's (6,6) parity exact); the undo fix's
  mechanism (per-area `undoManager(for:)`, programmatic adopt ends history, did-undo/redo re-sync)
  traced and its replay/reverts (R-a/R-b, 10/10) read; `CommentPanelFocus.after`'s rule correct in
  BOTH report orders; ⎋ `cancelOperation:` fall-through preserved; `CommentTextStyle`'s Equatable gate
  PROBED by the reviewer (NSColor(Color(hex:)) conversions — plain and alpha'd — compare equal, and a
  same-source dynamic colour does too), so no per-pass re-apply churn hides there.
- **The panel door:** confirm EVERY time with no don't-ask state anywhere; the id rides `presenting:`
  into the action (13l Act 2's rule honored); the door raises only for a row the fold shows; refusals
  worded (O-3 closed for the panel's reachable races, the shared fallback's rawness recorded);
  `deleteForever` = `requestPurge` through `perform` + the `TrashPurge.confirm`-shaped local sweep
  (`AppSession.sweepLocalPurge` verified: explicit store, no-op under a configured chain). Sentence
  case pinned on every new word.
- **Process:** pin-before-fix held per class (feature pins labelled honestly as compile-red); every
  bug-class arm red-on-old by revert (W, R1–R7, R-a/R-b, R-c) and window-verified; the window-2 red
  traced to the PIN's environment with the product proven unchanged by path diff; found work ticketed
  (VX-182/183/193/194, VM-14); PROVISIONALs enumerated for the merge-moment QUESTIONS deposit; zero
  commit trailers on all 33 run commits; shared ledgers untouched from the worktree; `PanelTextArea`
  fully retired (zero references).

**Disposition flow from here (the cross-model rule):** R1-1…R1-3 go to the implementer verbatim; its
agree/dispute returns to this reviewer, who makes the final call and implements confirmed fixes in
this session (R1-1 is closeout-ledger work the orchestrator may take; R1-2/R1-3 are walk rows — no
product line changes unless a walk row goes red).

## THE WALK (the orchestrator's own hands, 2026-10-12 ~22:45–23:10 — dev-store Debug build from the
pinned checkout, cliclick + screencapture from this tmux pane, both voices; captures in
`/tmp/vx179-walk/` for tonight only, deleted at closeout per the evidence rule)

**PASSED (the headline rows):**
- **U1's POPOVER CONFIRM — the unit's one unprovable row: the "Delete this comment forever?"
  alert PRESENTS over the transient popover, the popover stays, the act lands, the receipt
  speaks, the fence empties the fold. End-to-end in BOTH hosts (EditorView sheet + Takes margin
  popover). The ruled inline-confirm fallback is NOT needed.**
- W-U3-1/2 the composer: caret ON the placeholder's line (her screenshot's defect gone), Add
  fades empty, files on ⌘⏎, clears, newest visible, count only when non-zero.
- W-U3-7 BOTH undo arms live: file-then-⌘Z — NO crash, nothing returns; type-then-⌘Z — the text
  goes AND Add fades (the draft followed); ⇧⌘Z returns both. The U3-g fixes hold in the real app.
- W-U3-10 the seal refusal in the ALARM register, in words — PLUS the refused-draft PARK
  round-trip (unseal → reopen → "seal probe" back with the try-again receipt, Terminal idiom).
- W-U3-4 edit-in-place + focus-loss-saves; W-U3-9 click-anywhere; W-U3-5 the fold's one visual
  language (struck words · "Deleted <stamp>" · Restore · Delete forever…).
- W-1/W-9/W-10 geometry: the card grows to its block's height, top-aligned to the first line;
  cards never abut (the short-first-neighbour correctly degrades to a badge under the rhythm);
  a block taller than the window scrolls its card AWAY with it — gutter empty, nothing pinned.
- W-2/W-4 stacked entries in the small card; click ANYWHERE on a card opens the panel.
- W-6 narrow-window degradation to badges; W-7 Terminal's hanging `//` mark (card rows + panel),
  Study markless; W-U3-12 the quick-entry bar's typed text sits ON the hint's line in Terminal
  (the 2 pt drop gone), microsyntax offer intact. Dark = the black room (Bookcase + Settings
  frames; a dark CARD frame deferred to the next window or her use).

**FINDINGS (the fix leg's; each with its capture):**
- **F-W-1 (W-3 FAILS for synthetic/mouse wheels):** line-based wheel events over an OVERFLOWING
  card scroll the PAGE in both directions — the card's content never moves, while the page (the
  same event stream) moves normally. Internal inconsistency independent of natural-scroll; real
  mouse wheels post line deltas too. Candidates: wheelOwner's sign/latch on non-precise deltas,
  or the events never reaching the card's scrollWheel. U2's own warning named this row.
- **F-W-2:** a mouse-DOWN on the card's scroller lane opens the panel — the knob is not
  draggable in practice (CommentCardView.mouseDown fires the door on press). "The scroller
  stays draggable" does not hold.
- **F-W-5:** at the 800 pt window the TWO-comment block's badge reads "…" where its one-comment
  neighbours render "#1" (and the same block renders "#2" correctly at 1380 pt beside
  card-wearing neighbours) — the count is lost exactly where the badge matters most.
- **F-W-3 (W-U3-4's regression):** while a row is DIRTY its stamp line VANISHES — no
  "unsaved · ⌘⏎" mark, no Save/Revert doors (the U3-e restyle lost them; the save semantics
  are intact). The copy exists in CommentsPanelCopy; nothing renders it.
- **F-W-4:** in the POPOVER host, ⎋ with a typed UNSUBMITTED draft closes the whole popover and
  the draft is gone — the escape ladder's clear-first rung is skipped (the sheet host's monitor
  behavior does not hold in the popover). One accidental ⎋ loses her words.
- **W-OBS-2 (trace, maybe pre-existing):** Read mode's `read` arm (and its `edit` index) shows
  NO comment face at the default split width — not even the badge — on commented blocks; ~90 pt
  of visible gutter exists beside the contents column. The one law holds (nothing over prose);
  whether this host's textLeft arithmetic should yield a badge is the question.
**NOT WALKED, with reasons:** W-U3-8 IME (synthetic composition undrivable from this harness;
the offscreen probe + pin stand); W-U3-11 the TakesBottomBar sheet host (the identical panel in
the identical presentation walked at EditorView; low residual risk); W-U3-13 the quick pad's
door (not located quickly; Q-2's parity is measured + by construction); W-8 card-mid-scroll
persistence (blocked by F-W-1 — no wheel reaches the card). The inline-strip arm of W-6 is the
unchanged standing face (byte-identical arm + pins).
**Walk machinery notes:** the earlier "could not create image" was her CLOSED SCREEN, not a
permission (she fixed the setting; capture then worked first try). Window-targeted `walk-cap`
returned stale composites at the sheet boundary — full-screen `screencapture -x` used throughout
instead. The what's-new sheet swallowed the first scripted keystrokes (caught by the full-frame
check; nothing landed anywhere unintended).

## ROUND 1 DISPOSITIONS (the orchestrator, 2026-10-12 — the cross-model flow: R1-1 is the
orchestrator's own process finding; R1-2/R1-3 go to their implementers verbatim with the walk's
findings, agree/dispute returns to the reviewer for the final call)

- **R1-1 — AGREED, the orchestrator's duty (no implementer):** the merge-moment canon delta is
  real and now NAMED in ledger row 10 — at the merge, on latest main, the merging session lands
  ONE contract line at AppSpec §7 (the block_comment bullet's "visible and resurrectable" gains
  "until deleted forever — the 13j purge road, VX-179") and ONE at §9 (the comments family bullet
  gains the purge door + block_comment as the sixth purgeable kind), each with the pointer to
  this record; QUESTIONS gains the run's PROVISIONAL bundle the same moment.
- **R1-2 — to the U3 session with the walk findings:** trace the popover dismiss-with-dirty-edit
  road offscreen (agree/dispute); the live walk row joins the next stage window's list either way.
- **R1-3 — to the U2 session with F-W-1:** the wheel fix leg owns the latch; it answers
  agree/dispute while fixing the routing.

## U2 FIX LEG (implementer, 2026-10-12 late — the walk's F-W-1/F-W-2/F-W-5, W-OBS-2, ladder R1-3)

**NOT DONE BY THIS LEG (first line, by the contract):** no `xcodebuild test`, no app launch, no window
on screen, no stage act — every trace is an OFFSCREEN probe against the real Debug module (U3's
`real/build.sh` road: `Variorum.debug.dylib`, `@testable`, a never-ordered-in window, `.prohibited`
activation), kept in the worktree's gitignored `scratchpad/vx179-u2-fix/`. The pins' RUN and the
re-walk of the fixed rows are PENDING (the runner's next window).

**Revert state:** no behavioural revert in flight — R-FL ran (announced at 979bd931) and was RESTORED (`git checkout --`, `git diff --stat` empty, rebuilt, the replays green again).

### LIVE STATUS

| piece | what | status |
|---|---|---|
| FL-a | this section | DONE (9667e4d5) |
| FL-1 | F-W-1 — trace (precise + line events, offscreen, real module), fix at mechanism, table pins red-on-old by replay; R1-3 answered | DONE — traced 6061ba1f · fix 5d092268 · pins 979bd931 · R-FL red/restored (the evidence below); R1-3 answered below. RUN + the re-walk PENDING (runner) |
| FL-2 | F-W-2 — a press on the scroller belongs to the scroller; fix + pin | DONE — fix 5d092268 · pin 979bd931 · R-FL: OLD door 1× / no drag → FIXED door 0× / drag 0 → 112.5. RUN + the re-walk PENDING |
| FL-3 | F-W-5 — the "…" badge traced; a badge always carries its count; pin red-on-old | DONE — fix 5d092268 · pins 979bd931 · R-FL: OLD 7 of 8 counts "…" at the floor → FIXED 24/24 whole (22/28/32 pt). RUN + the re-walk PENDING |
| FL-4 | W-OBS-2 — TRACE ONLY (pre-existing or new?), answered before any fix | DONE (this commit) — PRE-EXISTING: Read mode has never hosted a decoration controller (THE TRACES) |
| FL-5 | the plain build; pins typechecked; record closed | DONE (this commit) — plain build SUCCEEDED after the restore (zero warnings in touched files); `CommentCardTests.swift` typechecked EXIT 0 against the built module |

### THE TRACES (offscreen, the REAL module — probes in `scratchpad/vx179-u2-fix/`; written before any fix)

**Probe machinery (honesty):** `build.sh` = U3's road (links `Variorum.debug.dylib`, `@testable`). A
synthetic wheel `NSEvent` is bound to a window only through CG event field 51 (found by a field scan;
the public window fields 91/92 do not bind it), and its `locationInWindow` is then PINNED at the
window's top-left corner (no field moves it), so the probes scroll the page to put that corner inside
the view under test. `NSWindow.sendEvent` dispatches NOTHING into a never-ordered-in window (measured:
no `scrollWheel` anywhere, the controls included), so the dispatch probes order a BORDERLESS window in
at (−20000, −20000) — off every display (`NSScreen` intersection checked false at exit), `.prohibited`
activation (cannot activate, cannot take key), ordered out after each fire; no pointer or keyboard
event is ever posted to the system (`NSApp.postEvent`/`sendEvent` inside the probe only). The
"queue road" (post → `nextEvent` → `NSApp.sendEvent`, so `NSApp.currentEvent` IS the event during
dispatch — measured `current=true`) is the live loop's shape.

**F-W-1 — the wheel over an overflowing card (walk-scroll's exact line events: `units: .line`,
`wheel1 = −lines`; `hasPreciseScrollingDeltas` false, `scrollingDeltaY` = ∓3, no phases).**

| delivery | down (−3) at rest | up (+3) at rest |
|---|---|---|
| straight to the tip's `card.scrollWheel` | CARD 0 → 30, page still | page (the router forwards) |
| real dispatch, `window.sendEvent`, off-display window (plain page / layer-backed page) | CARD 0 → 30 | PAGE 102 → 72 |
| real dispatch, the queue road (`currentEvent` set) | CARD 0 → 30 | PAGE 102 → 72 |

So candidates (a) and (c) are DEAD: the table's sign and the latch are right for line deltas (the
router chooses the card for down, the page for up, and the card moves when the router is reached),
and the geometry is right (hit-testing answers the card: `hit=CommentCardView`). What the probes
CANNOT have is the live app's one condition — an ACTIVE app with a KEY window (making the probe active
would take her focus; not done). The documented responsive-scrolling model (AppKit 10.9 release notes
+ WWDC13/215, via a read-only lookup, paraphrase-grade, no Apple-engineer statement; forum reports that
it changed again on 14+) is that the scroll VIEW takes the event — "the first event reaches the scroll
view", later events of a gesture are captured by its tracking loop un-hit-tested. The tip's road
depended on AppKit calling the CARD's own `scrollWheel` (an `NSView` override on a subview of the
document) and on hand-delivering the event to a scroll view hit-testing had NOT chosen
(`scroller.scrollWheel(with:)`): the hit view's nearest enclosing scroll view is the PAGE (measured:
`enclosing=PAGE`). The walk's symptom — the page takes BOTH directions, the card never moves — is
exactly what dispatch-to-the-hit-view's-scroll-view does with that hit view. **Mechanism (b),
refined: the events never reach the card's router in the live (responsive) dispatch, because the
view hit-testing answered (the card) belongs to the PAGE's scroll view.** Three further measured facts
the fix stands on: (1) a hit view INSIDE a plain inner `NSScrollView` makes that scroll view scroll
natively under real dispatch (stand-in 0 → 30); (2) a plain inner scroll view SWALLOWS a wheel it
cannot take (fits, or pushing past either end — nothing moves; the documented "gobbles" behaviour), so
"fits/end ⇒ the page" can only come from hit-testing answering a view of the PAGE; (3) an
`NSScrollView` subclass overriding `scrollWheel` WITHOUT declaring responsive compatibility does not
scroll at all (its `super` moves nothing) — so the router must not live in a scroll-view subclass
either. And NSScrollView's `.began` handling blocks in its own tracking loop (a `.began` delivered by
hand never returned — the probe had to be killed), i.e. the gesture's owner is fixed by whichever
scroll view takes its first moving event.

**R1-3 (answered below) falls out of the same fact.**

**F-W-2 — a press on the scroller lane.** Tip, offscreen: with the overlay scroller just FLASHED
(`alpha 1`), `hitTest` at the lane answers the `NSScroller`, the door stays shut and a press-drag
scrolls the card (0 → 112.5). After the overlay scroller FADES (4 s): `hitTest` at the lane answers
the CARD, the press OPENS THE PANEL (door 1×) and nothing scrolls — the walk's finding reproduced. A
faded overlay scroller declines the hit, so `super.hitTest` falls through to my "everything else is
the door" rule.

**F-W-5 — the "…" badge (the badge arm, NOT a squeezed card; pre-existing since 13u3 A1).** The real
badge measured: the label's need (the cell's own width) vs its frame:

| `textLeft` | badge | label (after the shipped inset `min(6, max(2, (w − 16)/2))`) | "#1" | "#2"…"#9" | "#12" / "#28" |
|---|---|---|---|---|---|
| 28 (Write's floor — an 800 pt window less the sidebar) | 22 | 16 | 15.74 whole | 16.71–17.46 TRUNCATED | 22.14 / 23.94 TRUNCATED |
| 34 | 28 | 16 (the inset is still 6) | whole | TRUNCATED | TRUNCATED |
| 60 | 32 | 20 | whole | whole | TRUNCATED |

The inset was tuned to "#1" (the walk that chose `commentBadgeMinWidth` 19 measured "#1"); every other
digit is ~1 pt wider and two-digit counts ~6 pt — so the count is lost exactly where the badge stands
in for a card.

**W-OBS-2 — Read mode shows no comment face: PRE-EXISTING (answered, not fixed).** Not a `textLeft`
question at all: Read mode's files (`ReadModeView`, `ReadEditPane`, `NoteIndexColumn`,
`NotePagesView`, `ReadNoteLanding`) carry ZERO comment references and have never hosted a
`BlockDecorOverlayController` (`git log -S` over `Features/ReadMode` + `Surface/`: no such commit; the
17p sweep table already recorded "take pane: none, it hosts no decor at all"). The `read` arm's rows are
SwiftUI `ReadPageBlock` texts; the `edit` index's panes are `PaneSurface`s. VX-179's diff touches none
of these files (`git diff c84eddf1..HEAD --stat` over them: empty). For the orchestrator to ticket:
Read mode has no comment face of any kind (no card, no badge) — a decoration host is a design decision
for that surface (gutter room, the read arm being SwiftUI rows), not a fix.

### THE FIX (5d092268) — one hit decision, the router retired

`CommentCardView.hitTest` → `hitTarget(at:during: NSApp.currentEvent)` (during dispatch AppKit has set
`currentEvent` to the event it is dispatching — measured `current=true` on the queue road) → the pure
`CommentCardLayout.hitAnswer(wheel:inScrollerLane:overflows:)`: a WHEEL the card can take (the
unchanged `wheelOwner` table) answers the card's own STACK — inside its scroll view, which then scrolls
NATIVELY; a wheel the page takes answers the CARD, whose scroll view is the page (the walk's own observed
road); a PRESS on the vertical scroller's lane of an overflowing card answers the scroller, faded or not;
every other press is the door. The card's `scrollWheel` override and its latch are GONE — no event is
hand-delivered to a scroll view hit-testing did not choose (both of the old road's hand-offs are what
the live dispatch bypasses). F-W-5: the pure `CommentCardLayout.badgeFace(text:width:need:)` — the
shipped inset where the count fits (byte-identical), else the inset yields to the count, else the "#"
goes; `need` is the label cell's own width (a copy measured); `present` sets the badge's words only when
the COUNT changes, so the decoration pass never undoes a fitted "12" back to "#12". The strip is the
shipped line, untouched.

### R-FL — red on old by behavioural revert (offscreen, the real module both sides; announced 979bd931, restored)

| replay | OLD (`CommentCard.swift` at 6061ba1f) | FIXED (5d092268) |
|---|---|---|
| line wheel, card at rest, DOWN — the view hit-testing answers IN DISPATCH (local monitor) → its scroll view | `CommentCardView` → **PAGE** | `CommentCardStackView` → **the card's own** |
| … UP at rest / DOWN at its bottom / entries fit (both ways) | card → PAGE | card → PAGE (unchanged — the page's wheels stay the page's) |
| … UP mid-way | card → PAGE | stack → the card's own |
| the outcomes on this road (inactive app) | card 0 → 30 · page · page · card 60 → 30 · page · page | the same six — right |
| trackpad-shaped gesture, DOWN at rest — the dispatch stack (the gesture's tracking needs a screen and throws offscreen, so the STACK is the evidence) | `NSWindow sendEvent` → `CommentCardView.scrollWheel(with:)` (the override) → hand-delivered into the inner's `trackGestureScrollWithEvent` | `NSWindow sendEvent` → `-[NSView scrollWheel:]` (the stack) → `-[NSView scrollWheel:]` (its clip) → the card's own scroll view tracks — two native hops |
| … UP at rest | (not captured) | five or more native hops — out to the page |
| a press on the scroller lane AFTER the overlay fades | hit = the card; **door 1×**, no drag | hit = `NSScroller`; door 0×, drag 0 → 112.5 |
| badges at Write's floor (22 pt), "#1/#2/#3/#4/#7/#9/#12/#28" | 1 whole, **7 "…"** | 8 whole (and all 24 across 22/28/32 pt) |

**The honest limit, stated:** offscreen the OLD card's line-wheel OUTCOME is not red — the probe app is
inactive with no key window, so its dispatch delivers to the hit view's own `scrollWheel` (the
traditional road), where the old router worked. The walk's failure needs the live, ACTIVE app's
dispatch, which a probe cannot have without taking her focus. What is red offscreen is the MECHANISM the
fix changes — which scroll view the hit view belongs to (old: the page's, for every wheel) — plus the
whole F-W-2 and F-W-5 outcomes. The re-walk of W-3 is the outcome's proof (PENDING).

### R1-3 — the implementer's answer (returns to the reviewer for the final call)

**AGREE that the mismatch was real; DISPUTE that one condition could fix it — the latch is retired
instead.** The doc promised "the gesture's first MOVING event re-decides" while the code re-decided on
`.mayBegin`/`.began` only — true. But re-deciding inside a gesture is impossible against AppKit:
measured, once a scroll view takes a gesture it tracks the rest itself
(`NSScrollingBehaviorConcurrentVBL _scrollView:trackGestureScrollWithEvent:` — and a `.began` handed to
an `NSScrollView` by hand never returned), so no later event reaches any router. With the fix there is
no latch at all: the owner is whichever scroll view hit-testing hands the gesture's first dispatched
event to. A zero-delta `.mayBegin` starts no tracking (measured — it returned at once), so the ordinary
gesture decides on its first MOVING `.began` — down → the card's own scroll view, up → the page (the
stacks above). Only a zero-delta `.began` itself (unverified that AppKit sends one) is decided by the
table's zero-delta row — the card when it overflows, DELIBERATELY: the alternative (the page) would make
the card unscrollable by any gesture that begins without movement. The `wheelOwner` doc now says this
(5d092268); the zero-delta row stays pinned. W-3's re-walk shows it if real.

### Dispositions (the fix leg's rows)

| row | disposition |
|---|---|
| F-W-1 | FIXED at mechanism (hit-testing chooses the scroll view; the router + latch retired) — pin `aWheelTheCardCanTakeIsHitTestedIntoItsOwnScrollView` + the `hitAnswer` table; red-on-old by R-FL's mechanism column; outcome by the re-walk (PENDING) |
| F-W-2 | FIXED — pin `aPressOnTheScrollerLaneBelongsToTheScroller` + the table; red-on-old by R-FL (door 1× / no drag → 0× / drag) |
| F-W-5 | FIXED (pre-existing since 13u3 A1's badge arm — the inset tuned to "#1") — pins `aBadgeShowsItsWholeCountAtWritesFloor` + the `badgeFace` table; red-on-old by R-FL (7 of 8 "…" → 8 whole); byte-identical wherever the count fit |
| W-OBS-2 | PRE-EXISTING, answered not fixed — Read mode has never hosted a decoration controller (THE TRACES); for a ticket |
| R1-3 | AGREE / DISPUTE as above — the latch retired; the zero-delta row deliberate |

### PENDING (the runner's next window — none of it claimed)

- **RUN:** `-only-testing:VariorumTests/CommentCardLayoutTests -only-testing:VariorumTests/CommentCardViewTests
  -only-testing:VariorumTests/CommentCardControllerTests -only-testing:VariorumTests/BlockDecorGeometryTests
  -only-testing:VariorumTests/MarginHoverCommentTests -only-testing:VariorumTests/IndicatorGutterTests
  -only-testing:VariorumTests/ProseGutterTests` (the new cells + every card/badge suite riding the same view).
- **Optional red-on-old through the test target:** R-FL again (`git show 6061ba1f:<CommentCard.swift>`) —
  the fix-leg cells go COMPILE-red there (`hitTarget`, `hitAnswer`, `badgeFace`, `lineLabel` are new); the
  behavioural red is R-FL's table above.
- **THE RE-WALK (her real app's shape — the one road no probe has):** W-3 over an overflowing card in
  Write — mouse-wheel (walk-scroll) DOWN scrolls the card, UP at rest moves the page, at the card's end the
  page moves; trackpad: a gesture down scrolls the card, a gesture up at rest moves the page, and a card
  that FITS never takes a wheel; W-8 (unblocked now): a card scrolled mid-way keeps its place while the
  page scrolls; F-W-2: press-drag the scroller lane (after the overlay faded) — the knob drags, the panel
  stays shut; a press anywhere else on the card still opens the panel; F-W-5: the 800 pt window — the
  two-comment block's badge reads "#2" beside its "#1" neighbours.

### ORCHESTRATOR VERIFICATION + DISPOSITIONS (the U2 fix leg accepted, 2026-10-13 early)

Verified by spot-check, never trust: the five commits exist as claimed (9667e4d5 · 6061ba1f ·
5d092268 · 979bd931 · a6791a97), the tree is clean and in sync with origin both ways, the fix commit
touches exactly `CommentCard.swift` (+ the record), the pins commit exactly `CommentCardTests.swift`
(+ a `present`-gate line and the record), `hitAnswer`/`badgeFace` are in the code where the record
says with the `scrollWheel` override gone (grep: only comment references remain), and the test file
carries 20 `@Test` functions. The mechanism trace is accepted — hit-testing choosing the scroll view
is architecturally CLEANER than the latch road (no event hand-delivered to a scroll view hit-testing
didn't choose), and the honest limit (the active-app outcome is the re-walk's to prove) is correctly
stated, not papered over.

**The probe-machinery disclosure, adjudicated ACCEPTED:** the dispatch probes' borderless window at
(−20000, −20000) — off every display (checked at exit), `.prohibited` activation (never active, never
key), ordered out after each fire, no event ever posted to the system — touches no screen, steals no
focus and runs no app instance in any user-visible sense. That is within this run's "offscreen probes
fine" line and needed no stage claim. The disclosure itself is exactly the honesty the run asks for.

**W-OBS-2 → VX-226 minted** ("Read mode has no comment face — no card, no badge, on either arm";
Backlog, Improvement, pointer to THE TRACES above). A design decision for her, not this run's fix.

**R1-3:** the AGREE/DISPUTE above is queued for LADDER ROUND 2's reviewer, who makes the final call
(the cross-model flow). The zero-delta row stays pinned as deliberate pending that call.

**Next:** the U3 FIX LEG (F-W-3, F-W-4, R1-2) dispatches now, strictly sequential; then the stage
window (the PENDING list above + U3's rows), then round 2.

## U3 FIX LEG 2 (implementer, 2026-10-13 — the walk's F-W-3/F-W-4, ladder R1-2)

**NOT DONE BY THIS LEG (first line, by the contract):** no `xcodebuild test`, no app launch, no window
on screen, no stage act. Every trace is an OFFSCREEN probe against the real Debug module (U3's
`real/build.sh` road), kept in the worktree's gitignored `scratchpad/vx179-u3-fix2/`. The pins' RUN and
the re-walk of the three rows are PENDING (the runner's next window). `CommentCard.swift` /
`CommentCardTests.swift` (U2's) are untouched.

**Probe machinery (honesty — U2's accepted road, plus one new piece, disclosed):** throwaway in-memory
store injected with `prepareDependencies` before anything runs (the default store folder checked absent
at start and at exit, every run: never created); `.prohibited` activation (never active, never key);
events only through the app's own queue (`postEvent` → `nextEvent` → `sendEvent`), nothing posted to the
system. Panels traced in a never-ordered-in borderless window; the POPOVER traces need a real popover, so
— the new piece — an anchor window is ordered in OFF-DISPLAY at (−20000, −20000) with alpha 0 (U2's
machinery) and the popover's own window is found the turn it appears, set alpha 0 and checked against
every `NSScreen` (ordered out and the run aborted if it touched one — it never did: it lands at
(0, −19880), x clamped, y off every display; a safety probe with an EMPTY popover ran first,
`popsafe.swift`). The walk's own captures in `/tmp/vx179-walk/` were read as evidence.

**Revert state:** no behavioural revert in flight — R-FL2a/b/c (announced at 618441ea) all ran and were restored (`git checkout --`, zero diff after each); the restored tree rebuilt green and replayed 0 failures.

### LIVE STATUS

| piece | what | status |
|---|---|---|
| FL2-a | this section + the three traces | DONE (deedc13f) |
| FL2-p | the three behavioural PINS, before any fix (`CommentPanelFixLeg2Tests` in `CommentTextAreaTests.swift`) — RED on the pre-fix module by BEHAVIOUR (not only by compile), replayed offscreen in the runner's shape (`pinrunner.swift`: a main-actor Task + the pin's suspending `turns()`): F-W-3 2 cells, F-W-4 2 cells, R1-2 1 cell FAIL; every premise PASS | DONE (f5e2fc06) — typecheck EXIT 0 against the pre-fix module; RUN PENDING (stage). The pure `claims` table cell lands WITH the F-W-4 fix (it names the new rule) |
| FL2-1 | F-W-3 — the dirty row's stamp line: fix + pin red-on-old | FIXED (c166804b) — `CommentTextArea.revealBelow` + `CommentTextAreaView.revealForEditing()` (rows only; never for a row taller than the list); triggered by the caret's arrival (one turn later), the text view's scroll-to-caret (not during a mouse gesture), and growth while focused; the panel MEASURES its stamp line (`onGeometryChange` → `stampLineHeight`) and passes gap + height + row air. Plain build SUCCEEDED, zero warnings in touched files; replays: the pin's two cells RED → GREEN (runner shape); the walk's state re-rendered (`renders/clip-fixed.png`): the edited last row's "Unsaved · ⌘⏎ · Save · Revert · Delete" in view (list visible 54…289 vs 0…235 before); the earlier U3 replays unchanged (undo 10/10, control checks, the focus pin); the six touched-area suites typecheck EXIT 0 |
| FL2-2 | F-W-4 — popover ⎋ skips the clear rung: fix + pin red-on-old | FIXED (b44f984c) — `CommentPanelKeys.claims(eventWindow:panelWindow:)` (own window OR its parent) behind the monitor's guard; the pure table cell `thePanelClaimsKeysAddressedToItsWindowOrItsParent` joins the pins; plain build SUCCEEDED; replay (runner shape, real module): the F-W-4 cells RED → GREEN (first ⎋ clears + stays; second closes); confirmed in the product's SwiftUI `.popover` host with parent-addressed keys (`swiftpop --anchor`: ⎋ clears, the popover stays) |
| FL2-3 | R1-2 — the popover dismiss-with-dirty-EDIT: AGREE/DISPUTE + (real ⇒) fix + pin | AGREE (measured, below) · FIXED (aaf9be65) — `CommentPanelHostWatcher` (zero-size; hears `NSPopover.willCloseNotification` for the popover whose content window is the panel's own) runs the panel's ONE leaving body, `commitDirtyEdits()` (now shared by Close, `.onDisappear` and the watcher); plain build SUCCEEDED, zero warnings in touched files; replays: the pin (runner shape, AppKit popover `close()`) RED → GREEN; the product's SwiftUI `.popover` dismissed by a CLICK AWAY and by the BINDING: store 'First note.' → 'First note. — edited in the popover', model no longer dirty. Accepted consequence: Close inside a popover commits twice in flight (Close's body, then the popover's willClose) — the second is the same text, a harmless repeat write; a later teardown finds nothing dirty |
| FL2-4 | reverts (announced first), plain build, typecheck, record close | DONE (fd93e60c) — reverts announced 618441ea, run and restored (the table below); plain build SUCCEEDED on the restored tree, zero warnings in touched files; the touched-area suites + the new pins typecheck EXIT 0 |

### THE TRACES (offscreen, the REAL module; written before any fix)

**F-W-3 — "a dirty row loses its stamp line" (`dirty.swift`, `clip.swift`; the walk's `u34-dirty.png`).**
The face is NOT lost: rendered offscreen, a dirty row shows "Unsaved · ⌘⏎", Save, Revert and Delete —
one line or grown by a newline/wrap (`renders/2-dirty.png`, `4-dirty-wrap.png`). The walk's capture
shows the real state: the edited row ("Third: Edited in place.| short.") is the LAST row of a list that
is CAPPED and SCROLLED (the first row's stamp cut at the top edge), and the list's visible region ends
right under the caret's line — the dirty row's stamp line is CLIPPED below the list. Reproduced at the
walk's panel size (470 × 440, three comments, one long): list visible y 0…235; the last row's area
233…259; its stamp line ends ≈ 277 → not visible at rest, with the caret in the row, or dirty. THE
MECHANISM: the comments list is height-capped (`room − addFloor`) and scrolls; NOTHING reveals the row
being edited — a text view's own scroll-to-caret only ever reveals the caret's LINE (and since U3 a row
has no scroll view of its own, that scroll lands on the LIST, minimally), never the stamp line under it,
which is where the panel puts the dirty face. Class: the capped list never revealed the edited row
since 13u3 A2 (reasoned, not measured on the old tree); U3-e's add floor 132 → 156 shrank the cap by
24 pt and made it bite at the default panel size. Feasibility measured: an AppKit `scrollToVisible` of
the row area + an allowance moves the SwiftUI list offscreen (visible 45…280 → the stamp line visible).

**F-W-4 — popover ⎋ closes the popover and drops the draft (`popesc.swift`, `swiftpop.swift`).** The
capture `u36-popover-typed.png` shows the composer's hairline in the ACCENT — which renders only while
`focus == .add` — so the panel KNEW the caret was in the composer and `CommentComposition.escape` would
answer clear-the-draft. Measured, the real panel in a real popover (AppKit `NSPopover` and SwiftUI
`.popover`, the product's host), keys ADDRESSED TO THE POPOVER WINDOW: ⎋ clears the draft, the popover
stays — the rung works. Keys ADDRESSED TO THE PARENT WINDOW (the anchor): a typed 'x' STILL lands in
the popover's composer (AppKit forwards it into the popover's first responder — measured, not the
probe's doing), and ⎋ CLOSES the popover with the draft unconsumed — the walk's F-W-4, reproduced
exactly. The diagnostic monitor saw both keys addressed to the parent; the popover window is a CHILD
of it (`pw.parent === anchor`). THE MECHANISM: the panel's local monitor claims only `event.window ===
its own window`; in a popover host the keyboard's events are addressed to the PARENT window (the
parent keeps window-server key status — the capture's active traffic lights) and AppKit delivers them
into the popover, so the monitor passes ⎋ on, ⎋ reaches the composer → `cancelOperation:` →
`_NSPopoverWindow` closes the popover, and the model dies with its never-parked add draft. Ruled out on
the way (static, `lldb` symbol + disassembly reads of AppKit): the transient-popover machinery DOES
register its own local monitor (`_NSTransientUIElementRegisterForEvents` →
`addLocalMonitorForEventsMatchingMask:0x40E placement:1`), but its key-down branch only calls each
element's `_closeForKeyDownEvent:`, which for `NSPopover` is a bare `ret` — it never consumes ⎋; no
other app monitor takes ⎋ (`PageTurnKeyMonitor` is window-scoped, `OneWingChord` takes ⌘L only,
`CalmAsks` returns every event). (CORRECTED at the fix commit: an earlier draft of this line said "local monitors run newest-first (measured)" — two later runs DISAGREE on the order (a diagnostic monitor registered after the panel's saw ⎋ in one run and not in another), so the order is NOT established; neither the mechanism nor the fix depends on it.)

**R1-2 — the popover dismiss with a dirty EDIT (`r12.swift`, `r12m.swift`, `oldroad.swift`).** The real
panel in the product's SwiftUI `.popover`; a comment row edited in place (the model: 1 dirty id); the
popover dismissed by a CLICK AWAY (a mouse-down/up on the parent outside the popover — AppKit's
transient monitor closes it) and, separately, by the binding set false. Both roads: the store still
holds the OLD text 1.5 s and 4 s later; the model is still dirty, no status. Why: `NSPopover` posts
`willClose` and `didClose` (animated, 0.4 s apart — the popover truly closed), but SwiftUI never tears
the popover's content down — a `.onDisappear` on the content (the probe's own wrapper) NEVER fires, and
the row's text view stays first responder inside the ordered-out window, so it neither resigns nor
leaves its window: the focus-report road and the panel's `.onDisappear` net — both of the panel's
"leaving saves an in-place edit" roads — never run. The pre-U3 road, APPROXIMATED (`oldroad.swift` — a
SwiftUI popover with a `TextEditor`, `@FocusState`, `.onChange(of: focus)` and `.onDisappear`, NOT the
old panel's code): after the same click-away, neither `.onChange` nor `.onDisappear` fired.

**R1-2 — the implementer's answer: AGREE.** The bug is real and measured (offscreen, the product's host
shape): a dirty in-place edit is LOST when the popover is dismissed — the panel's documented net
("a popover dismissed by a click outside it" — `.onDisappear`) never runs for popover content. The
reviewer's mechanism is right in its premise (commit-on-leave cannot be assumed) and the class is
PRE-EXISTING (13u3 A2 — the approximated old road loses it the same way), not U3's async reports.
Fix below; the walk row the reviewer asked for joins the PENDING list.

### THE DESIGN (written before the code)

- **F-W-3 — the row being edited stays WHOLLY visible.** `CommentTextArea` gains `revealBelow` (the
  height of what the host draws under the area that belongs to it — the row's stamp line, measured by
  the panel with `onGeometryChange`, plus the gap and the row's own bottom air — a measured number, not
  a guess); the area reveals its own frame + that allowance (minimal scroll, up the clip-view chain)
  when its caret arrives (deferred one turn — never during the click's tracking), after every
  scroll-to-caret (typing, caret moves), and when it grows while focused. A row taller than the list's
  visible height reveals nothing extra (the caret's own scroll governs — never fight the caret).
- **F-W-4 — the monitor claims what AppKit delivers into its window.** A key event addressed to the
  panel's window OR to that window's PARENT (a popover's) is the panel's to claim — a pure rule
  (`CommentPanelKeys.claims`), table-pinned; what each key MEANS is untouched (`act`, `handle`,
  `CommentComposition.escape`), so with nothing to undo ⎋ still passes on and closes the popover.
- **R1-2 — the host's closing saves, as `.onDisappear` was meant to.** A zero-size watcher in the panel
  observes `NSPopover.willCloseNotification` for the popover whose content window is the panel's own
  and commits every dirty row — the SAME body as `.onDisappear` and `close()` (factored into one
  `commitDirtyEdits()`). The add draft is untouched (#118(a): leaving never files it).

### Behavioural reverts (ANNOUNCED before they run — the fixes are committed at c166804b, so `git checkout -- <file>` is the safe restore; replay = `pinrunner` in the runner's shape against the rebuilt real module)

- **R-FL2a (F-W-3):** `CommentTextAreaView.revealForEditing()` returns at once → expect the two F-W-3
  cells RED (caret arrival; dirty and grown), every premise green. Restore:
  `git checkout -- App/Variorum/Variorum/Features/Editor/CommentTextArea.swift`.
- **R-FL2b (F-W-4):** `CommentPanelKeys.claims` answers the OLD guard (own window only) → expect "the
  first ⎋ clears the draft" and "the popover stays" RED. Restore: `git checkout --
  App/Variorum/Variorum/Features/Editor/CommentsPanel.swift`.
- **R-FL2c (R1-2):** `CommentPanelHostWatcher.isHost` answers false (the watcher hears nothing) →
  expect "the popover's closing saved it" RED. Restore: the same `git checkout --` of `CommentsPanel.swift`.
After the last: `git diff --stat` empty, rebuild, replay all green.

| revert | the pin replay (runner shape, the rebuilt real module) | restored |
|---|---|---|
| R-FL2a — the reveal off | exactly the two F-W-3 cells FAIL (caret arrival; dirty and grown); every premise and every other cell PASS | yes — zero diff |
| R-FL2b — the own-window claim | exactly "the first ⎋ clears the draft" + "the popover stays" FAIL | yes — zero diff |
| R-FL2c — the watcher deaf | exactly "the popover's closing saved it" FAIL (store 'First note.') | yes — zero diff |
| the restored tree, rebuilt | 0 failures (11/11 cells); the earlier U3 replays unchanged | — |

### The sweep — the two NEW mechanism classes this leg found

| class | instances | verdict |
|---|---|---|
| a key monitor guarding `event.window === its own window` inside a POPOVER (AppKit addresses a popover's keys to the parent) | `CommentPanelKeyMonitor` (the comments panel — popover AND sheet hosts) | FIXED (F-W-4) |
| | `PageTurnKeyMonitor` (`NotePagesView`), `WingSwitcherSheet` (a sheet), `PressReporter` (mouse presses — addressed to the window under the pointer, never forwarded) | NOT IN A POPOVER / not keys — safe |
| popover CONTENT relying on `.onDisappear` (never fires on a popover's dismissal — measured) | the comments panel's `.onDisappear` (dirty edits) | FIXED (R1-2 — the watcher) |
| | `.onDisappear` in the other popover-presenting files (`LensesBoardView`, `CommitBar`, `BookArrivals`) — attached to the HOST boards/bars (teardown, DEBUG probes), not to popover content; none persists her state | not the class — safe |

### Dispositions (the fix leg's rows)

| row | disposition |
|---|---|
| F-W-3 — "a dirty row loses its stamp line" | the face was CLIPPED, not lost (traced) — FIXED c166804b (the edited row stays wholly visible); pin `theEditedRowAndItsStampLineStayInViewInACappedList` (RED on old by behaviour — replay + R-FL2a); the re-walk PENDING |
| F-W-4 — popover ⎋ drops the draft | FIXED b44f984c (the monitor claims its window's parent's keys); pins `escapeInAPopoverClearsTheDraftFirstThenCloses` (RED on old — replay + R-FL2b) + the pure `thePanelClaimsKeysAddressedToItsWindowOrItsParent`; the re-walk PENDING |
| R1-2 — popover dismiss-with-dirty-EDIT | AGREE — real, measured, pre-existing class (13u3 A2; the approximated old road loses it too) — FIXED aaf9be65 (the host-closing watcher); pin `closingThePopoverSavesADirtyInPlaceEdit` (RED on old — replay + R-FL2c); the reviewer's walk row joins the PENDING list. Returns to round 2's reviewer for the final call (the cross-model flow) |

### PENDING (the runner's next window — none of it claimed)

- **Pin RUN:** `-only-testing:VariorumTests/CommentPanelFixLeg2Tests` (4 tests — expect all green) + the
  standing U3 list (`CommentTextAreaMountedTests` — the control gained `revealBelow`, a defaulted memberwise
  parameter; `CommentPanelGeometryRuleTests`, `CommentPanelWordsTests`, `CommentsPanelModelEditorTests`,
  `CommentCompositionTests`, `CommentPanelKeysTests`, `CommentPanelParkTests`). Optional in-target revert
  spot-checks: R-FL2a/b/c as above (expect exactly the named cells red).
- **The re-walk, both voices, the dev-store Debug build:** F-W-3 — edit the LAST comment of a capped list
  (three comments, one long) in the EditorView sheet: its "Unsaved · ⌘⏎ · Save · Revert" stays in view while
  typing and as it grows; F-W-4 — in the Takes margin note's POPOVER, type a draft, ⎋ clears it and the
  popover STAYS, a second ⎋ closes it; R1-2 (the reviewer's row) — in the same popover edit a comment in
  place, CLICK AWAY to dismiss, reopen: the edit is saved. Plus a regression look: the sheet host's ⎋ ladder
  and Close unchanged.

### ORCHESTRATOR VERIFICATION + DISPOSITIONS (the U3 fix leg 2 accepted, 2026-10-13)

Verified by spot-check, never trust: the eight commits exist as claimed (deedc13f … 74944126), the
tree is clean and in sync both ways, the leg's whole diff touches exactly `CommentsPanel.swift`,
`CommentTextArea.swift`, `CommentTextAreaTests.swift` and the record — `CommentCard.swift` and
`CommentCardTests.swift` (U2's) untouched as promised. The `claims` rule read in place: own window or
the window's DIRECT PARENT only — the child-window relation only the popover host creates (a sheet's
parent is `sheetParent`, not `parent`), so the sheet and inline hosts keep own-window behavior by
construction; the monitor still consumes only acts the ladder handles. `revealBelow` is measured by the
panel and passed down, never guessed. The watcher keys on the popover whose CONTENT window is the
panel's own — scoped, not global.

**The probe-machinery disclosure, adjudicated ACCEPTED:** U2's accepted road plus the real-popover
piece — anchor off-display at alpha 0, the popover's window alpha 0 the turn it appears and checked
against every screen (abort if touched; it never was), a safety probe first, and the in-memory store
with the default store folder verified absent at start and exit of every run (the earlier probe
incident's class, handled by construction). Within the offscreen-probes line; no stage need.

**F-W-3's mechanism correction accepted:** the walk's reading ("the stamp line vanishes — a restyle
loss") was WRONG about the mechanism and the trace corrected it — the face was clipped below the capped
list's edge, a 13u3-era class the U3-e floor raise made bite at the default size. The finding row in
THE WALK stands as observed; this section's trace is the mechanism of record.

**R1-2:** AGREE with measurement (SwiftUI never tears popover content down; `.onDisappear` never
fires), pre-existing class, FIXED with the one shared leaving body. The answer is queued for LADDER
ROUND 2's reviewer, who makes the final call (the cross-model flow). The accepted consequence (Close
inside a popover commits twice — a harmless same-text repeat) is noted for the reviewer.

**Next:** the stage window (the U2 and U3 PENDING lists above — suites, optional in-target reverts,
the mini-walk in both voices + a dark card frame), then LADDER ROUND 2 over the whole fix-leg diff
(a887bda6-era tip → current) with the R1-2/R1-3 answers returned to the reviewer.

## STAGE WINDOW 4 (orchestrator, 2026-10-13 ~00:50–01:35 — the fix-leg suites + the mini-walk; claim vx179-tests via oct12coordinator, released clean, no instance left)

**The suite run** (pinned checkout advanced to c6d18035; `build-for-testing` pre-built before the claim;
`test-without-building`, 15 suites): **101 tests — 100 green, ONE red:**
`CommentPanelFixLeg2Tests/escapeInAPopoverClearsTheDraftFirstThenCloses` — BOTH its expectations fail
in the runner (`model.addDraft == "x"` the premise, and the final `!popover.isShown`): in the runner's
environment a key addressed to the parent window never reaches the popover's composer at all. The pin's
premise, not the product, is the first suspect (the window-2 focus-pin precedent) — but see the walk's
F-W-4-R below: the LIVE host's key routing differs from BOTH models the offscreen probes used, so the
pin and the product behavior go back together. Log `/tmp/vx179-fixleg-suites.log`. The in-target revert
spot-checks were skipped for time (the offscreen reverts stand as the red-on-old evidence; the one
suite red made the discriminating story moot for F-W-4 anyway).

**THE MINI-WALK** (dev store Debug from the pinned checkout, Study voice, line-wheel events via a fresh
CGEvent poster — the old /tmp/walk-scroll binary now traps and was replaced; captures kept as crops in
`/tmp/vx179-walk2`):

| row | result |
|---|---|
| W-3 down-wheel over the overflowing card | **GREEN** — the card scrolls (stacked entries, hairline, "Third:" entry scrolled in), the page frozen byte-still |
| W-3 at the card's end | **GREEN** — the page takes over seamlessly (shown twice); the card then rides away with its block |
| W-3 up over a mid-scrolled card | **GREEN** — the card scrolls back; topping out hands the remainder to the page natively (no dead wheel) |
| W-3 up at the card's top | **GREEN** — the page moves |
| W-3 a card that fits | **GREEN** — wheel passes to the page both directions, never swallowed |
| W-8 inner place across a page scroll | **GREEN** — card visible through a page scroll keeps its inner position exactly. OBSERVED: a card recycled fully OFF-view and back reminds at its top (virtualization's remint; arguably by design — for round 2's reviewer to weigh) |
| F-W-2 press on the faded lane | **HALF-GREEN** — the door stays SHUT (three presses, no panel: the walk's harm is gone) but **F-W-2-R (residual):** the knob does NOT track a press-drag in the live app, faded or freshly flashed (cliclick dd/dm/du verified real). The offscreen probe likely got legacy-style scrollers where tracking behaved; the live overlay scroller doesn't. To the U2 fix leg |
| the card-body press | **GREEN** — the door opens the panel as ever |
| F-W-5 the badge at 800 pt | **GREEN** — the two-comment block reads a whole "#2" beside "#1" neighbours; no "…" anywhere. (A badge press is not a door — hover-tier face; not a fix row) |
| F-W-3 dirty row in a capped list (sheet) | **GREEN** — editing the last row of the capped, scrolled list shows "Unsaved · ⌘⏎ · Save · Revert · Delete" wholly in view as the row grows; Revert restored the text. The dirty face also showed correctly in the POPOVER host |
| the sheet's ⎋ ladder (regression) | **GREEN** — draft, first ⎋ clears + sheet stays, second ⎋ closes. The claims change left the sheet host untouched |
| F-W-4 the popover's ⎋ ladder | **HALF-GREEN** — the original harm is GONE: no ⎋ ever closed the popover with a draft in it, and the draft was cleared (never dropped). But **F-W-4-R (residual):** the live ladder runs ⎋ #1 = a DEAD press that silently blurs the composer (caret vanishes, reproduced twice), ⎋ #2 = clears the draft, and the CLOSE rung never fires at all (⎋ with an empty composer leaves the popover open; Close and click-away still work). The live host's key addressing differs from both probe models — the panel makes the popover window KEY on open (the ask-for-keyboard dance), so live keys are popover-addressed, not parent-addressed. To the U3 fix leg WITH the red pin |
| R1-2 dismiss-with-dirty-EDIT (the reviewer's row) | **GREEN — THE SAVE LANDED LIVE.** A dirty in-place edit in the popover survived a click-away dismissal and reopened saved (clean row, new text). The watcher works in her app |
| the dark frame | **GREEN** — Write's gutter cards and Takes' margin entries in the black room, legible, prose unmoved; appearance restored to Follow system |

**W4-OBS-1:** a click-away dismissal DROPS a typed, unsubmitted composer DRAFT silently (the watcher
saves dirty EDITS only). The ⎋ road now protects drafts; the click-away road doesn't. Pre-existing and
possibly acceptable — for round 2's reviewer, and ultimately her taste call if the reviewer thinks it
rises.

**Honest limits:** the trackpad-gesture arm was NOT walked (no honest synthetic road for phased
gestures; the U2 leg's dispatch-stack evidence plus her daily use cover it — recorded, not claimed).
The Terminal-voice re-pass was SKIPPED on reasoning: every fixed mechanism (hitTest, claims, the
watcher, revealBelow) is voice-blind code shared by both voices, and the first walk covered Terminal's
voice-specific panel rows; the time went to the residuals instead. VX-222 was queued behind the window.

**Walk-machinery notes:** the old `/tmp/walk-scroll` binary traps (SIGTRAP) — replaced with a minimal
CGEvent line-scroll poster in the session scratchpad. Mid-window the Data volume hit 100% (ENOSPC);
freed ~300MB of my own walk artifacts (the first walk's captures — already slated for closeout
deletion — and full-screen originals whose crops are kept); vx-184's cleanup later freed the volume to
34 GiB. Only my own artifacts were touched.

**Dispositions out of this window (in order):**
1. **U3 FIX LEG 3** (next, headless): F-W-4-R — trace the LIVE key addressing (the popover window is
   key; whose window do its key events carry?), fix the ladder (one ⎋ = clear with a caret still in
   place, empty ⎋ = close), and make the red pin model the live addressing so it goes red-on-old for
   the real mechanism; W4-OBS-1 recorded for the reviewer.
2. **U2 FIX LEG 2** (after U3's leg): F-W-2-R — the overlay scroller's knob must track a live drag;
   trace with overlay-style scrollers forced in the probe.
3. Then LADDER ROUND 2 over the whole fix-leg diff, with R1-2's AGREE (now live-proven), R1-3's
   answer, and this window's record before the reviewer.

## U3 FIX LEG 3 (implementer, 2026-10-13 — STAGE WINDOW 4's F-W-4-R and the red F-W-4 pin)

**NOT DONE BY THIS LEG (first line, by the contract):** no stage act of any kind (no `xcodebuild test`, no
app launch, no window on screen). Offscreen probes only (the accepted machinery; probes in the gitignored
`scratchpad/vx179-u3-fix3/`). **The live dead first ⎋ is NOT reproduced by anything available to this
leg** (the traces below say exactly why); the fix is built to not depend on the unmodellable factors, and
its live confirmation — with a DEBUG trace that names the road — is the next stage window's.
`CommentCard.swift` / `CommentCardTests.swift` untouched.

**Revert state:** no behavioural revert in flight — R-FL3a/b ran and were restored (`git checkout --`, zero diff); the restored tree rebuilt green and replayed 0 failures.

### LIVE STATUS

| piece | what | status |
|---|---|---|
| FL3-a | this section + the traces | DONE (0012cb60) |
| FL3-1 | the fix — ownership by delivery + first responder, the explicit close rung, stale monitors released, a DEBUG trace line | DONE (22a3a587) — `CommentPanelKeys.delivers(…)` (pure over identities + the live-window form) replaces `claims`; the monitor hands `handle` the area read from the window's first responder (`CommentNSTextView.role`, set by the panel: `.add` / `.comment(id)`); `handle(_:in:)` — the close rung is `close()` + consume; the monitor releases itself on its popover host's `willClose` (+ a DEBUG `installedMonitors` count); the DEBUG `comment-keys` trace line. Plain build SUCCEEDED, zero warnings in touched files. Replays (runner shape, the real module, `fl3runner.swift`): 8/8 PASS; the fix-leg-2 pins' replay (`pinrunner`) 11/11 PASS; walk 4's stale sequence (`walk4`) as before |
| FL3-2 | pins (what the runner CAN model) + replays + reverts | DONE — pins 8eeb3bf9 (+ the B3 cell made robust, this commit); reverts announced 8eeb3bf9, run and restored (the table below) |
| FL3-3 | record close | DONE (772e89a4) |

### THE TRACES (offscreen, the real module — and the walk-4 crops in `/tmp/vx179-walk2/`)

1. **My fix-leg-2 F-W-4 model was an artefact — retracted.** Offscreen the app is never active, so it
   has NO key window, and a key addressed ANYWHERE (window 0, the anchor, the popover) lands in the
   popover's composer (`keystate.swift`: all three addressings → the composer; the diagnostic monitor saw
   the first as popover-addressed). The "AppKit forwards parent-addressed keys into the popover" I recorded
   at fix leg 2 is the inactive app's fallback routing, not the live or the runner's road — exactly what
   the runner's red premise showed (there, the panel's `makeKey` ask makes the popover truly key, and a
   parent-addressed key goes to the parent).
2. **What a ⎋ the panel passes on does in this host:** the composer's chain is `CommentNSTextView →
   NSClipView → NSScrollView → CommentTextAreaView → AppKitPlatformViewHost → PopoverHostingView →
   PopoverHostingController → NSPopover* → _NSPopoverWindow* → NSWindow*` (* = overrides
   `cancelOperation:`; SwiftUI's popover hosting does NOT) — a passed ⎋ that REACHES the composer closes
   the popover through `NSPopover.cancelOperation:` (`cancelop.swift`), the walk-1 F-W-4. A passed ⎋
   that is delivered to the MAIN window instead meets the Takes board's own `.onExitCommand {
   closeAllFans() }` (`TakesBoardView.swift:308`) and is swallowed there — consistent with walk 4's
   "the close rung never fires".
3. **Stale panels — MEASURED, a real leak:** a dismissed popover's content is never torn down (fix leg
   2's R1-2 mechanism), and SwiftUI makes a NEW popover window per presentation; so every opening leaves
   the whole previous panel alive in its ordered-out window — model, its store observation (the panel's
   `.task` never cancels), its key monitor installed: after three openings THREE panel monitors listen,
   two stale (`stale.swift`). W4-OBS-1's "dropped" draft is not dropped — it lives on, unreachable, in the
   stale panel (`walk4.swift`: 'an earlier draft' still in the old composer after the reopen).
4. **The stale-monitor double-claim hypothesis — FALSIFIED offscreen:** a closed popover window stops
   being a child of its parent (`parent` = nil after close), so a stale panel claims neither addressing;
   replaying walk 4's sequence (open, type, dismiss, reopen, type, ⎋ ×3) under both addressings, the live
   panel's ladder works (⎋#1 clears, ⎋#2 closes) and the stale draft is untouched (`walk4.swift`).
5. **The walk-4 crops:** `f4-g` — the popover just opened, the composer NOT focused (no accent hairline,
   no caret) despite the panel's open-time focus request, so the first responder moved after the request;
   `f4-h` (clicked in, typed) — caret + ACCENT hairline (the panel's `focus == .add`); `f4-i` after ⎋#1 —
   identical to `f4-h` (draft and caret intact: a dead press; the reported "blur" is not visible in this
   frame — the caret blinks); `f4-j` after ⎋#2 — cleared; `f4-k` after ⎋#3 — empty, caret drawn, still
   open. The caret is drawn in the popover's composer throughout (AppKit draws a caret only in a key
   window, or a popover receiving its key parent's keys), while the main window's traffic lights stay
   active. The SHEET's ladder (`24-esc1`) cleared on the FIRST ⎋.
6. **What is NOT explained:** under every road I can construct, the shipped monitor CLEARS on ⎋#1
   whenever the event reaches it with `focus == .add` and a draft (`CommentComposition.escape` —
   `.addDraft(non-empty) → .clearDraft`), and `f4-h` shows both. So live, either the first ⎋ did not
   reach the panel's monitor at all, or the monitor's view of WHICH area holds the caret (the async
   `focus` value) disagreed with the first responder at that instant. Neither is observable offscreen
   (no active app, no real key window) nor in the runner (its popover is truly key — the road where the
   shipped ladder works: the measured runner state, the red pin's premise failure).

### THE DESIGN (written before the code) — the ladder stops depending on what could not be observed

1. **Ownership by DELIVERY and the FIRST RESPONDER:** a ⌘⏎/⎋ is the panel's iff its window is VISIBLE
   and is the window AppKit delivers keys to — the key window, or a visible child (a transient popover) of
   the key window — and that window's first responder IS one of the panel's writing areas; the AREA (the
   composer or comment N) is read from that responder, never from the async `focus`. No `event.window`
   addressing, no focus-report timing, no stale panel (its window is hidden) can steer it. Inactive app
   (no key window — the offscreen fallback): the event's own window or its parent, as before.
2. **The close rung is the panel's own act:** when the ladder answers `.close`, the panel closes itself
   (`close()` — commit dirty rows, then `dismiss`) and consumes the key, instead of passing ⎋ on and
   hoping the host closes (measured: the passed ⎋ can land on the Takes board's `.onExitCommand`). Same
   contract: with nothing to clear, ⎋ closes the panel — now in every host by construction.
3. **Stale monitors released:** the panel's key monitor uninstalls when its popover host closes (the
   watcher's `willClose`), so dismissed panels stop listening (the leak's key half; the stale model's
   store observation is recorded as an observation for the orchestrator).
4. **A DEBUG-only trace line** (`Logger` category `comment-keys`) per ⌘⏎/⎋ the panel monitor sees: its
   window, the key window, the event's window, the first responder's area, the decision — so the next
   stage window can read the LIVE road in `log show` and confirm or kill this leg's reasoning.

**PROBE SAFETY — TWO INCIDENTS, disclosed (the sheet-host replay, `sheet.swift`).** To replay the SHEET's
ladder I presented the real panel by SwiftUI `.sheet` from an off-display window. (1) The first run used a
TITLED anchor window: AppKit constrains a titled window onto a display when it is ordered in — the window
had alpha 0 set BEFORE ordering, the display check ran right after `orderFront` and the process aborted at
once: a fully transparent window was ordered in on a display for an instant; nothing was drawn. (2) The
rerun, with a borderless anchor, aborted on the SHEET's own window: SwiftUI placed it on a display; the
guard found it within one ≤ 5 ms turn, set alpha 0 and ordered it out — it may have drawn for up to one
frame before the guard reached it; I cannot rule that out. No app instance, no store, no focus change
(`.prohibited`), and I STOPPED sheet probes there — no rerun. The sheet host's ladder is therefore
verified by reasoning + the runner + the walk (PENDING), not offscreen: in a sheet the key window IS the
sheet, so `delivers` owns its keys; the first ⎋ clears; the empty ⎋ now `close()`s the sheet (before:
passed on to the sheet's own `cancelOperation:`, which closed it) — the same outcome by the panel's act.

### The pins (FIX LEG 3) — what the runner CAN model, and the gap stated

Order, honestly: the fix landed (22a3a587) BEFORE these pins; their red-on-old is by announced behavioural
revert (below), U2's fix-leg road — not pin-before-fix.

| pin | models | red on old? |
|---|---|---|
| `escapeInAPopoverClearsTheDraftFirstThenCloses` (REWRITTEN — its fix-leg-2 form addressed keys to the PARENT, the retracted offscreen-artefact road; its premise failed in the runner) | keys addressed to the DELIVERY window (the key window — the runner's popover, made key by the panel's own ask — else the popover) | NO, honestly: on this road the shipped ladder works; it guards the contract on the road the runner has |
| `theKeyIsThePanelsWhereItIsDelivered` (REPLACES `thePanelClaimsKeysAddressedToItsWindowOrItsParent`, which pinned the superseded `claims`) | the ownership rule as a pure table over identities | a feature pin of the replacement rule; the cells where the old rule differs are named in it (addressed-to-the-panel-but-delivered-elsewhere; hidden panels) |
| `theCloseRungClosesEvenWhereAPassedEscapeIsSwallowed` (NEW) | the product's SwiftUI `.popover`, the content carrying `.onExitCommand {}` — a host whose chain SWALLOWS a passed ⎋, as the Takes board's does live (there in the MAIN window; here inside the popover — the swallow's place differs, the property tested is the same: the close rung must not depend on where a passed ⎋ lands) | YES — revert R-FL3a below |
| `aDismissedPopoversPanelStopsListening` (NEW) | a dismissed SwiftUI popover's panel releases its key monitor (DEBUG `installedMonitors`) | YES — revert R-FL3b below |

**THE GAP (stated, per the brief):** the walk's dead FIRST ⎋ is not reproduced by the runner or offscreen.
The runner's popover becomes truly key and the shipped ladder works there; offscreen has no key window.
The fix removes every dependency this leg could name (event addressing, the async focus value, a stale
panel, where a passed ⎋ lands); whether one of them WAS the live first ⎋'s cause is for the DEBUG trace
line to show on the next live walk (`log show --last 10m --predicate 'subsystem == "io.lduarte.Variorum"
&& category == "comment-keys"' --info`): each ⌘⏎/⎋ prints the panel's window, the key window, the event's
window, the panel's parent, the first responder's AREA, the ownership verdict and whether it was handled.

### Behavioural reverts (ANNOUNCED before they run — the fix is committed at 22a3a587; restore by `git checkout -- App/Variorum/Variorum/Features/Editor/CommentsPanel.swift`; replay = `fl3runner` in the runner's shape against the rebuilt real module)

- **R-FL3a (the explicit close):** `handle`'s `.close` returns `false` (passes ⎋ on, the shipped
  behaviour) instead of `close()` → expect B2's "closes the panel even where a passed ⎋ is swallowed"
  RED; B1's close stays green (there the passed ⎋ reaches `NSPopover.cancelOperation:`).
- **R-FL3b (the release):** the monitor's `willClose` observer does not release → expect B3's "its
  monitor is released" RED.
- **No revert for the ownership rule itself:** its behaviour differs from the old rule only where the key
  window and the event's window disagree — not constructible offscreen (no key window) — so the table and
  the live trace carry it.

| revert | the replay (runner shape, the rebuilt real module, `fl3runner`) | restored |
|---|---|---|
| R-FL3a — the close rung passes ⎋ on (the shipped behaviour) | exactly B2 "closes the panel even where a passed ⎋ is swallowed" FAILS; B1's close stays green (there the passed ⎋ reaches `NSPopover.cancelOperation:`) | yes — zero diff |
| R-FL3b — no release on the host's closing | first run: B3 went red on its PREMISE (the "count back to before" form was fragile — leaked monitors from earlier cells inflate `before`); the cell was made robust ("this dismissal releases exactly one": `after == open − 1`, in the pin AND the replay); rerun: exactly B3 "its monitor is released" FAILS (1 → 1) | yes — zero diff |
| the restored tree, rebuilt | `fl3runner` 8/8 · `pinrunner` (fix leg 2's pins) 11/11 · `walk4` (the stale sequence) as before | — |

### W4-OBS-1 — the click-away "drops" a typed draft (PROPOSAL ONLY, not built — it edges on a taste call)

Traced (`walk4.swift`): the draft is not dropped — it lives on, unreachable, in the dismissed popover's
STALE panel (SwiftUI never tears popover content down; the reopen is a new panel with a new model). Same
root as this leg's stale monitors, but NOT the ladder's mechanism: the ladder fix releases the stale
panel's keyboard and leaves its draft where it was. The repair this record proposes for round 2 / her:
**(a)** on the popover host's closing (the watcher's `willClose`, where dirty edits already save), PARK a
non-empty add draft in the existing `CommentDraftPark` and let the next open's `restoreParkedDraft()` put
it back with the park's own receipt — "parking is not filing", so #118(a) (leaving never FILES) stands;
**(b)** keep today's behaviour (a click-away abandons an unsubmitted draft, like ⎋⎋ does); **(c)** file it
on leaving (reverses #118(a) — her ruling). Recommended: (a). Not built: it is a taste call on #118(a)'s
edge, and the brief says propose and wait.

### Observations (NOT fixed here — for the orchestrator)

- **O-FL3-1 (measured leak):** every Comments popover opening leaves the previous panel ALIVE —
  its model and its STORE OBSERVATION (the panel's `.task` loop never cancels, so each stale panel
  re-reads its comments on every relevant write) — for the app's life. This leg releases the stale
  panels' KEY monitors; the observation and model leak remains. Ticket candidate (a panel-level "stop"
  on the host's closing, or a host that tears its content down).
- **O-FL3-2 (live, from the walk-4 crops):** in the Takes popover the panel opened with the composer NOT
  focused (`f4-g`: no caret, no accent) — the open-focused-on-add contract (§2 D) did not hold live there,
  while it holds in the runner and offscreen. The first responder moved after the panel's focus request
  (likely the popover becoming key). The DEBUG trace + the next walk should look; not this leg's fix.

### Dispositions (FIX LEG 3)

| row | disposition |
|---|---|
| the red F-W-4 pin (runner premise) | its premise modelled fix leg 2's offscreen artefact (parent-addressed keys) — RETRACTED and REWRITTEN onto the delivery road; honestly not red on old there (the record says why) |
| F-W-4-R — dead first ⎋ | NOT reproduced (no environment available here models the live key road — measured why); the fix removes every dependency this leg could name (addressing, the async focus value, stale panels); the DEBUG `comment-keys` trace names the live road on the next walk — CONFIRMATION PENDING |
| F-W-4-R — no close rung | FIXED (22a3a587) — the panel closes itself; pin `theCloseRungClosesEvenWhereAPassedEscapeIsSwallowed`, red on old by R-FL3a |
| stale panels' key monitors (found here) | FIXED (22a3a587) — released on the host's closing; hidden panels never own a key; pin `aDismissedPopoversPanelStopsListening`, red on old by R-FL3b |
| the sheet host's ladder (regression) | by construction (the key window is the sheet) + the runner + the walk — PENDING (the offscreen sheet replay was stopped on the safety incidents above) |
| W4-OBS-1 | PROPOSED (a) — not built (a taste call on #118(a)'s edge) |

### PENDING (the runner's next window — none of it claimed)

- **Pin RUN:** `-only-testing:VariorumTests/CommentPanelFixLeg2Tests` (now 6 tests: F-W-3, the rewritten
  F-W-4 ladder, the ownership table, the close rung, the monitor release, R1-2 — expect all green) + the
  standing U3 suites (`CommentTextAreaMountedTests` — the control gained `role:`; the others unchanged).
  Optional in-target reverts R-FL3a/b (expect exactly the named cells red).
- **The live walk (Takes margin note's popover, both voices if time), with the DEBUG trace captured:**
  start `log stream --predicate 'subsystem == "io.lduarte.Variorum" && category == "comment-keys"' --info`
  (or `log show --last 10m … --info` after); open the popover, click into the composer, type a draft:
  ⎋ #1 clears it and the popover STAYS; ⎋ #2 (empty) CLOSES the popover; reopen — a fresh composer. Read
  the trace lines for each ⎋ (key window, event window, area, owns, handled) and record them — they are
  the live road this leg could not observe. Then: the SHEET's ladder (EditorView) — ⎋ clears, ⎋ closes;
  ⌘⏎ files in both hosts; R1-2's click-away save (unchanged — the monitor release and the save watcher
  are separate observers of the same `willClose`).

### ORCHESTRATOR VERIFICATION + DISPOSITIONS (the U3 fix leg 3 accepted, 2026-10-13)

Verified by spot-check: the five commits as claimed (0012cb60 … e294e8e4), tree clean and in sync, the
diff confined to the two panel files, the test file and the record; `delivers` replaces `claims` in
place with the monitor consulting it; 22 pins in the file. **The retraction is accepted as the
mechanism of record:** fix leg 2's parent-forwarding model was the inactive probe app's fallback
routing — the honest correction is exactly what the hallucination guard is for, and the runner's red
premise was the tell. The new ownership-by-delivery model matches the three environments' facts (live:
the popover made key; runner: the popover truly key; offscreen: no key window at all), reads the area
from the first responder instead of the async focus value (closing O-FL3-2's class), and the close
rung no longer depends on where a passed ⎋ lands (the Takes board's `.onExitCommand` swallow is a
concrete, measured mechanism for walk 4's missing close). The F-W-4 ladder cell being honestly NOT
red-on-old is correctly stated — the close-rung and release cells carry the red-on-old burden
(R-FL3a/b, discriminating exactly).

**The two sheet-probe incidents, adjudicated:** ACCEPTED as disclosed — alpha 0 before any order-in,
the first aborted instantly, the second guarded within one turn with at most one frame possibly drawn;
no app instance, no store, no focus change; and the leg STOPPED sheet probes on its own. The tightened
line going forward: offscreen probes never order in a window whose position has not first been set
off-display, and SwiftUI-sheet-class presentations are out of bounds offscreen — the sheet regression
check rides the runner and the walk, where it belongs.

**O-FL3-1 → VX-229 minted** (the stale panel's model + store observation leak; the monitors are
released by this leg). **W4-OBS-1's park-the-draft proposal is HELD** for round 2's reviewer and her
taste — not built, correctly.

**Next:** the U2 FIX LEG 2 (F-W-2-R) dispatches now; then the short stage window (the two PENDING
suites' run + the trace-read walk rows), then LADDER ROUND 2.

## U2 FIX LEG 2 (implementer, 2026-10-13 — STAGE WINDOW 4's F-W-2-R: the lane's knob does not track a live press-drag)

**NOT DONE BY THIS LEG (first line, by the contract):** no stage act — no `xcodebuild test`, no app
launch, no window on any display. Offscreen probes only, under the TIGHTENED line: a probe window's
position is set off-display (−20000, −20000) BEFORE it is ever ordered in, `.prohibited` activation, no
SwiftUI sheet-class presentation, no event posted to the system. U3's files (`CommentsPanel.swift`,
`CommentTextArea.swift`, `CommentTextAreaTests.swift`) untouched. The wheel road (W-3/W-8, all green
live) and the door-shut answer stay byte-intact. The pins' RUN and the lane re-walk are PENDING.

**Revert state:** no behavioural revert in flight.

### LIVE STATUS

| piece | what | status |
|---|---|---|
| FL2-a | this section | DONE (f53d1621) |
| FL2-1 | trace F-W-2-R offscreen (overlay style confirmed/forced; the live sequence modelled) — mechanism found or the gap stated | DONE (75f55b2d) — the lane hands presses to an overlay scroller that tracks only on its 6 pt knob part; off it, a dead press (THE TRACE) |
| FL2-2 | the fix (the lane's press-drag scrolls the card, faded or flashed; door + wheel untouched) | DONE (this commit) — the card owns the lane drag (`mouseDown`/`mouseDragged`/`mouseUp` + the pure `laneDragOffset` at the native knob ratio); `HitAnswer.scroller` → `.lane`, answering the card; replayed: every lane position drags 0 → 212.04 (overlay; native knob 212), door 0×; the wheel replay byte-identical to leg 1's fixed column |
| FL2-3 | pins (what the runner can model) + red-on-old by replay; plain build; record closed | DONE (this commit) — pins at 835fe8a0 (typecheck EXIT 0); plain build SUCCEEDED (zero warnings in touched files); red-on-old by replay (the table below); RUN + the lane re-walk PENDING |

### THE TRACE (offscreen, the real module — `scratchpad/vx179-u2-fix2/knob.swift`; written before any fix)

The real controller renders an overflowing card (10 entries) on a page scroll view in a borderless window
whose contentRect sits at (−20000, −20000) before it is ever ordered in (`window ever on a display:
false`); mouse events are built with explicit window locations and dispatched through the app's own
queue (`postEvent` → `nextEvent` → `NSApp.sendEvent`, so `NSApp.currentEvent` is the event in hit-testing).

**The hypothesis "the probe got LEGACY scrollers" is FALSE:** `NSScroller.preferredScrollerStyle` = 1
(overlay) on this machine, and the card's scroll view and its scroller both report 1 — leg 1's lane probe
already printed `style=1`. Forcing legacy is the CONTROL below.

| press (then a 38 pt drag down, 4 steps, up) | overlay (the live style) | legacy (control) |
|---|---|---|
| scroller geometry | lane 17 pt wide; KNOB hit part **6 pt** wide (x 8–14), 26 pt tall | knob 11 pt wide (x 3–14) |
| ON the knob, flashed | `testPart` = knob → hit `NSScroller` → door 0× → **card 0 → 212** | 0 → 189.5 |
| ON the knob, hover first | 0 → 212 | 0 → 189.5 |
| ON the knob, after a 4 s fade | 0 → 212 | 0 → 189.5 |
| the lane's leading edge (x 2) | `testPart` = **none** → hit `NSScroller` → door 0× → **card 0 → 0 (DEAD)** | 0 → 0 |
| the lane's trailing edge (x 15) | **none → DEAD** (door shut, nothing moves) | 0 → 0 |

**The mechanism (traced):** leg 1's hit rule answers the `NSScroller` for EVERY press on the 17 pt lane,
but an overlay scroller only tracks a press that lands on its 6 pt knob part; everywhere else in the lane
`testPart` answers none and `NSScroller.mouseDown` does nothing with it — no drag, no forward to the door.
That is EXACTLY the live residual (three presses, door shut, zero movement). The live report adds that
even a press aimed at the flashed knob's own pixels failed; the offscreen knob tracks wherever it is hit,
so live either the 6 pt part was missed (the collapsed overlay knob draws thinner than its expanded hit
part and sits at the lane's trailing side), or the overlay scroller's hover/expansion state — which runs
only in an ACTIVE app's KEY window, unavailable to any probe without taking her focus — gates its
tracking. **Both explanations share one cure:** stop handing the lane to the `NSScroller`. The card OWNS
the lane drag itself — the same responder road (`mouseDown` → `mouseDragged` → `mouseUp` to the view
that took the press) the drag handle beside it has used live since 13 C1 — mapping the pointer's travel
to the content's at the native knob ratio (content travel ÷ knob travel), so the knob still follows the
pointer one-to-one as it would under AppKit's own tracking.

### THE FIX (835fe8a0) — the card owns its lane

`CommentCardLayout.hitAnswer`'s press-on-the-lane answer is now `.lane` (was `.scroller`), and
`hitTarget` answers the CARD for it (was the `NSScroller`). The card's `mouseDown` asks the same pure
decision: a lane press on an overflowing interactive card starts the card's own drag (the press's window
y, the contents' offset, content travel = document − clip, knob travel = the scroller's knob slot − its
knob, falling back to the clip's proportional share), flashes the overlay scroller so the knob shows;
`mouseDragged` moves the clip by the pure `CommentCardLayout.laneDragOffset` (content travel ÷ knob
travel — the native knob ratio, so the knob still follows the pointer one-to-one — clamped at both
ends); `mouseUp` ends it. Every other press is the door, unchanged; with no lane drag in flight
`mouseDragged`/`mouseUp` fall to `super` exactly as before. The WHEEL arms of the decision and
`hitTarget` are untouched.

### Red on old by replay (offscreen, the real module; overlay is this machine's preferred style)

The OLD column is THE TRACE's run — the pre-fix module (no commit touched `CommentCard.swift` between
fix leg 1's close and this leg's fix: `git log a6791a97..75f55b2d -- CommentCard.swift` is empty). The
FIXED column is the same probe, same dispatch road, after 835fe8a0's build.

| press, then a 38 pt drag down (overlay) | OLD | FIXED |
|---|---|---|
| on the knob — flashed · hover first · faded | hit `NSScroller`, card 0 → 212, door 0× | hit the card, 0 → 212.04, door 0× |
| the lane's leading edge (x 2) — flashed | hit `NSScroller`, **0 → 0 (dead)**, door 0× | 0 → 212.04, door 0× |
| the lane's trailing edge (x 15) | **0 → 0 (dead)** | 0 → 212.04 |
| the leading edge, FADED (4 s) | (dead by the same `testPart` none) | 0 → 212.04 |
| the slot below the knob (part 3) | (not measured on old) | 0 → 212.04 |
| legacy control, every position | knob 0 → 189.5; edges 0 → 0 | 0 → 189.3 |
| the wheel road (fix leg 1's six dispatch rows) | — | byte-identical to fix leg 1's fixed column (down → the card's own · up → the page · bottom → the page · mid-way up → the card · fits → the page both ways) |

### What only the walk can prove (stated, not claimed)

The dead live press is REPRODUCED offscreen for every lane point off the knob's 6 pt part; the live
report adds a dead press aimed at the knob's own pixels, which offscreen tracks. Two live-only conditions
could explain that cell — the knob's hit part missed by a few points (the collapsed overlay knob draws
thinner than its hit part), or the overlay scroller's hover/expansion state machine, which runs only in an
ACTIVE app's KEY window. The fix removes BOTH dependencies (the knob part and the scroller's state machine
no longer take part), but that it does so live is the re-walk's to show. The road the drag now uses —
`mouseDragged`/`mouseUp` delivered to the view that took `mouseDown` — is the drag handle's beside it,
live since 13 C1.

### Dispositions (FIX LEG 2)

| row | disposition |
|---|---|
| F-W-2-R (the lane's knob does not track a live press-drag) | FIXED at mechanism — the card owns the lane drag; pins `aPressDragAnywhereOnTheLaneScrollsTheCard` (the measured dead edge, the trailing edge, the knob column; door shut; drags back; off-lane door; a fitting card all door) + `theLaneDragFollowsTheKnobRatioAndStopsAtTheEnds` + the hit table's `.lane` cell; red-on-old by replay (the table above); the live outcome PENDING the re-walk |
| the coordinator's hypothesis (the probe had legacy scrollers) | FALSIFIED — the probe was overlay (`preferredScrollerStyle` 1); the dead press is the overlay knob's 6 pt hit part, reproduced |
| the door-shut answer | INTACT — every lane press door 0× (pinned); every off-lane press the door (pinned) |
| the wheel road (W-3/W-8 live-green) | UNTOUCHED — the wheel arms unchanged; the dispatch replay identical |

### PENDING (the runner's next window — none of it claimed)

- **RUN:** `-only-testing:VariorumTests/CommentCardLayoutTests -only-testing:VariorumTests/CommentCardViewTests
  -only-testing:VariorumTests/CommentCardControllerTests` (the lane-drag cell replaces fix leg 1's
  `aPressOnTheScrollerLaneBelongsToTheScroller`, whose answer — the `NSScroller` — was the dead road).
- **THE LANE RE-WALK** (overlay, the live app): on an overflowing card, press-drag (cliclick dd/dm/du)
  ~38 pt down — on the flashed knob, on the faded lane's left edge, and on its right edge: the contents
  scroll and the knob follows the pointer; drag back up: it returns; three presses on the lane: still no
  panel; a press on the entries: the panel opens; then a wheel pass (W-3) to see the road unchanged.

### ORCHESTRATOR VERIFICATION + DISPOSITIONS (the U2 fix leg 2 accepted, 2026-10-13)

Verified by spot-check: the four commits as claimed (f53d1621 … 236d65aa), tree clean and in sync,
the diff confined to `CommentCard.swift` + `CommentCardTests.swift` + the record (U3's files
untouched), `.lane` and the pure `laneDragOffset` in place with the card's own mouseDown →
mouseDragged → mouseUp road. **My legacy-scroller hypothesis is FALSIFIED and withdrawn** — the probe
was overlay all along; the real mechanism (an overlay scroller tracks only its 6 pt knob part; every
other lane press answers `testPart` none and dies) is measured and accepted as the mechanism of
record. The fix is the right shape: the card owning the lane drag at the native knob ratio removes
BOTH of the knob-pixel cell's possible live-only causes (hit-area width, hover/expand state) from the
road entirely, reuses the drag handle's proven live event path, and leaves the door and every wheel
branch byte-unchanged (the six wheel replays identical). The replay table is honestly red-on-old
(the trace ran on the pre-fix card; no commit touched the file between leg 1's close and the fix).

**Next:** READY to the coordinator for the SHORT window — the PENDING suite runs (U2's three card
suites + CommentPanelFixLeg2Tests' six + the standing U3 list) and the walk rows (the lane drags at
knob/left edge/right edge + back up + three lane presses no panel + an entry press opens + one W-3
wheel pass; the popover ⎋ ladder with the `comment-keys` trace streamed and READ; the sheet ladder;
⌘⏎ in both hosts; R1-2's click-away save re-check). Then LADDER ROUND 2.

## STAGE WINDOW 5 (orchestrator, 2026-10-13 ~02:25–02:50 — the fix-leg re-run + the trace-read walk; claim vx179-tests, released clean, no instance left)

**The suite run** (pinned checkout at ec4adb5d, pre-built): **70 tests / 11 suites — 67 green, 2 red,
both in CommentPanelFixLeg2Tests:** `escapeInAPopoverClearsTheDraftFirstThenCloses` (the rewritten
cell still fails its typed-premise at :765 — even on the delivery road the runner's popover never
receives the key) and `closingThePopoverSavesADirtyInPlaceEdit` (NEWLY red since leg 3 — stored stays
'First note.'). Log `/tmp/vx179-window5-suites.log`. **Both behaviors are PROVEN GREEN LIVE below**,
so these are runner-environment divergences for a PIN-ONLY leg, not product defects — but the R1-2
cell's flip from green (window 4) to red (this window) must be TRACED by that leg, not assumed
harmless: leg 3's monitor-release or delivery changes may interact with the runner's popover teardown
in a way the pin road sees and the live road doesn't.

**THE WALK (dev store, the leg-3+leg-2 build; the `comment-keys` DEBUG trace STREAMED AND READ —
`/tmp/vx179-commentkeys2.log`; captures in `/tmp/vx179-walk2/w5-*/w6-*`):**

| row | result |
|---|---|
| R1-2 click-away save (re-check, FIRST) | **GREEN** — a dirty in-place edit in the popover survived click-away dismissal and reopened SAVED (w5-d/e). The runner's new red does not reproduce live |
| the popover ⎋ ladder | **FULLY GREEN — and the dead-⎋ mystery SOLVED.** With keys that actually deliver (System Events): ONE ⎋ clears the draft and the popover STAYS (trace: `escape … owns=true handled=true`, area=add from the first responder), ONE more ⎋ CLOSES the popover (the explicit close rung fired past the Takes-board swallow). **Every "dead first ⎋" in windows 4–5 was cliclick's `kp:esc` NEVER REACHING the popover host** — zero trace lines for cliclick ⎋ while typing and System-Events keys all arrive; cliclick ⎋ DOES reach the sheet host. Walk-tool skew; the app was innocent; O-FL3-2's focus question dissolves with it (the composer was focused; the presses never arrived) |
| ⌘⏎ in the popover | **GREEN** — filed a comment (count 2→3; trace `commit … handled=true`); the in-place edit's ⌘⏎ save also traced (area=comment(id)) |
| the sheet ladder (regression) + ⌘⏎ | **GREEN** — filed via ⌘⏎ (trace: panel window IS the key window, parent=-1), draft cleared on first ⎋, sheet closed on second; both deleted after with the quiet receipt, the Deleted fold counting |
| the lane drags (F-W-2-R's re-walk) | **ALL GREEN** — the flashed KNOB drag scrolled the card to its end; the FADED lane's left region and right edge both drag (down and up, content following, no sheet); three plain lane presses leave the door SHUT (the lane flashes the scroller — the courtesy visible); an entry press OPENS the panel. One instrument miss recorded honestly: an x=478 press (one point LEFT of the lane, which spans 479–496 by the knob's own pixels) correctly fired the door — and an x=481 retest was invalidated by a sheet left open, then re-run clean at 482 GREEN |
| W-3 wheel pass | **GREEN** — down-wheel over the card scrolls the card, page frozen (the wheel replays were byte-identical across the leg-2 fix, and window 4 walked the full table) |

**Store state after:** the walk note's comments restored byte-exact; the two test filings deleted
(each leaving one tombstoned row in the Deleted fold — walk debris consistent with the note's
standing debris); appearance untouched this window; no instance running.

**Walk-machinery lesson (for every future walk):** cliclick KEYBOARD events (`kp:esc`) do not reach
an NSPopover-hosted panel, while its CLICKS and DRAGS deliver fine everywhere and System Events
keystrokes/key codes deliver everywhere — drive popover keys via `osascript` key codes only. The
`log` shell function in her profile shadows `/usr/bin/log`; use the absolute path. The trace needs
`--debug` (the line is debug-level; `--info` alone shows nothing).

**Dispositions out of this window:**
1. **U3 PIN LEG (headless, next):** trace WHY the runner's popover never receives delivered keys and
   why `closingThePopoverSavesADirtyInPlaceEdit` flipped red at leg 3; remodel or honestly
   runner-skip the two cells with the gap stated; NO product code without a traced live-relevant
   mechanism.
2. A ~5-minute runner re-run bundled before/with ROUND 2.
3. **ROUND 2** (fresh fable-reviewer) over the whole fix stack with this window's evidence.

## U3 PIN LEG (implementer, 2026-10-13 — STAGE WINDOW 5's two runner reds; headless, pin-only)

**Not done in this leg, stated first:** no product line changed (no traced live-relevant mechanism
was found — below); no stage act (no `xcodebuild test`, no app launch, no window on a display); the
runner re-run is PENDING (the orchestrator's ~5-minute window). Offscreen probes only, under the
tightened line (`.prohibited`, in-memory store, the default store folder checked absent at start and
exit, popover windows alpha 0 and checked against every NSScreen, no sheet probes).

### LIVE STATUS
- [x] Traces written (below) before any edit.
- [x] The two AppKit-host cells remodelled onto the product's own presenter (SwiftUI `.popover`) —
  8beab85b (test file only; typecheck EXIT 0; `pinleg.swift` replays the four popover cells in suite
  order, runner shape, real module at the tip: **14/14 green**).
- [x] Red on old for the remodelled R1-2 cell — **REVERT R-PL ANNOUNCED** (runs after this commit):
  `CommentPanelHostWatcher.isHost` answers `false` (the watcher deaf — fix leg 2's R-FL2c road), the
  app rebuilt, `pinleg` rebuilt and run, then restored by
  `git checkout -- App/Variorum/Variorum/Features/Editor/CommentsPanel.swift` and rebuilt. Nothing is
  committed while it is in flight.
  **R-PL RAN — 12/14:** the R1-2 cell RED on exactly its save (stored `["First note."]`; its three
  premises green — one dirty edit, the popover up when dismissed, closed after) AND
  `aDismissedPopoversPanelStopsListening` red (the monitor's release asks the same `isHost`, so the
  revert silenced both). Restored (`git checkout --`, worktree clean). To isolate the watcher alone:
  **REVERT R-PL2 ANNOUNCED** — the WatcherView's closure skips `self.onHostClosing?()` (isHost
  untouched), rebuilt, replayed, restored the same way.
  **R-PL2 RAN — 13/14: RED ON EXACTLY ONE EXPECTATION**, R1-2's save (stored `["First note."]`), every
  premise green (one dirty edit · up when dismissed · closed after); the release cell green. Restored
  (`git checkout --`, worktree clean), rebuilt, the tip replay **14/14** again, typecheck EXIT 0.
- [x] Dispositions + the runner's PENDING list (below).
- [ ] Dispositions + the runner's PENDING list.

### THE TRACES (window 5's log `/tmp/vx179-window5-suites.log`, window 4's `/tmp/vx179-fixleg-suites.log`, the walk's `/tmp/vx179-commentkeys2.log`; offscreen replays in `scratchpad/vx179-u3-pin/`)

**T1 — which window owns the keyboard, per road (read from the DEBUG `comment-keys` lines):**

| road | panel window | key window | parent | reading |
|---|---|---|---|---|
| LIVE popover (the walk, 02:31–02:32) | 117391 / 117402 | **117375 = the PARENT** | 117375 | the app's main window stays key; AppKit forwards its keys into the popover's first responder (`delivers`' parent clause) |
| LIVE sheet (02:33–02:37) | 117417 … | the sheet itself | −1 | the sheet window is key |
| RUNNER, SwiftUI `.popover` host (`theCloseRung…`, 02:27:49) | 117362 | **117362 = the panel** | 117361 (the off-display anchor) | the popover window itself is key (its borderless anchor can never be) — keys arrive |
| RUNNER, the suite's AppKit `NSPopover` host (the ladder cell, 02:27:47) | — | — | — | **ZERO lines for two posted ⎋** |

The monitor writes a line for EVERY ⌘⏎/⎋ it sees, before its ownership check; it is installed when
its view enters the popover's window and released only when the view leaves a window or the
popover's `willClose` arrives (leg 3). Zero lines for two ⎋ therefore means **the ladder's AppKit
popover had already closed before its first ⎋** — and, the draft being `""`, before or at the `x`.

**T2 — the AppKit host's popover is never the runner's key window.** Window 4 (pre-leg-3) addressed
the ladder's keys to the anchor (the popover's parent): `x` never landed and the popover stayed up
to the end (its final `!isShown` failed). Window 5 addressed them to `NSApp.keyWindow ?? popover`:
`x` never landed again. Neither the popover nor its anchor was the key window either time — the
anchor is borderless (`canBecomeKey` false, measured offscreen) and the popover did not take key —
so **the key window during these cells was a THIRD window**: by elimination one the host app (the
dev-store test host) or an earlier suite left key. Offscreen the two hosts are structurally alike
(both `_NSPopoverWindow`, `canBecomeKey` true, parent a borderless `NSWindow`, behavior transient;
SwiftUI's animates, the suite's does not — `hosts.swift`), so the difference is runner-only: the
SwiftUI presenter's popover ends up key there (T1), the hand-built one does not.

**T3 — the R1-2 flip (green in window 4, red in window 5) is the same early close, not a leg-3 line.**
- The R1-2 cell posts NO key, so every leg-3 key-path change — delivery ownership, the
  first-responder area, the close rung — never runs in it (the monitor returns at `act == nil`).
- The one leg-3 line on its road is the monitor's own release on `willClose`. It removes the key
  monitor and its own observer; it touches neither the watcher (`CommentPanelHostWatcher`, a separate
  observer) nor the model. Replayed offscreen against the leg-3 module in the runner's shape
  (`sequence.swift`, the cells' steps verbatim): R1-2 alone **PASS**, R1-2 after the two SwiftUI
  cells in window 5's order **PASS** (stored = the edited text both times).
- The cell's premise `dirtyCommentIDs.count == 1` PASSED in the runner, then `popover.close()` and 60
  turns did not save. A `willClose` posted AFTER the edit saves (the replays). The one reading that
  fits is that the runner's popover **closed BEFORE the edit** — the watcher then ran with nothing
  dirty, the edit landed in a hidden window, and `close()` on a closed popover posts nothing.
- That is exactly T1's ladder evidence in the same run: window 5 is the first run where the
  AppKit-host popover is found closed early, in BOTH cells that use it. What closes it is the
  runner's key-window machinery around a popover that is not key (a transient popover closes on
  interaction outside it; window 5 newly sends the ladder's keys to the third window, and newly
  runs two key-taking SwiftUI popovers before R1-2). The exact event is not observable without the
  stage and is NOT claimed; no product line R1-2 exercises can produce it.
- **Live is the product's presenter, not this one:** the walk proved the click-away save in windows
  4 AND 5 (the R1-2 rows), through SwiftUI's `.popover` from a key main window (T1's first row).

**T4 — a safety disclosure about the old cell:** in window 5 the ladder cell's `x`, ⎋, ⎋ were
addressed to `NSApp.keyWindow`, which (T2) was not the panel's window — so they went to whatever
window the TEST HOST had key: possibly the dev-store app's own window (the dev store; never the real
store). What those three keys did there is not knowable from the log. The remodel never posts a key
to a window that is not the panel's own or its parent: it REQUIRES that first (below).

### THE REMODEL (the design, written before the code)
1. Both cells move onto `SwiftUIPopoverHost` — the product's own presenter (`TakesShared.swift`'s
   `.popover(isPresented:)`; Write and the Takes bottom bar present a sheet), and the host whose keys
   provably arrive in the runner (T1). The hand-built `NSPopover` host and its helper retire.
2. Keys go through ONE guarded road: the delivery window is `NSApp.keyWindow` only when it IS the
   panel's window or its parent, the panel's window when no window is key (offscreen); any other key
   window FAILS the cell's premise by name — a test never types into the host app's windows. The
   close-rung cell takes the same road.
3. Each cell states the popover is still up as a premise before it acts (so an early close in the
   runner reads as itself, never as a missing save or a missing key).
4. R1-2 dismisses by the binding — the road the click-away and the panel's own close both end on
   (`NSPopover` closes → `willClose`); window 5's `aDismissed…` cell proved that road posts `willClose`
   in the runner (its monitor was released).

### Dispositions (the pin leg)
| row | disposition |
|---|---|
| runner red 1 — `escapeInAPopoverClearsTheDraftFirstThenCloses` | **REMODELLED, not skipped** (8beab85b): onto the product's own `.popover` presenter, whose keys provably arrive in the runner (window 5's trace on the sibling cell: the popover window key, `owns=true handled=true`), through the one guarded key road. Honestly NOT red on old (unchanged statement — on this road the shipped ladder already worked). **Gap stated:** the LIVE road (the main window key, its popover child fed its keys) cannot be hosted in the runner — an off-display anchor can never be key; it stands on `theKeyIsThePanelsWhereItIsDelivered`'s table (`owns(true, parentOf: parent, key: parent, …)`) and the walk's window-5 trace (`key=117375 … parent=117375 … owns=true handled=true`) |
| runner red 2 — `closingThePopoverSavesADirtyInPlaceEdit` (the window 4 → 5 flip) | **TRACED to the runner's hand-built popover closing BEFORE the edit** (T3 — the exact closing event is runner-only and not observable without the stage; NOT claimed). **No leg-3 product line is on the cell's road** (it posts no key; the monitor's own release touches neither the watcher nor the model; the save replays green in both orders against the leg-3 module). **No live ordering hazard found:** the save is proven live through the product's presenter in windows 4 and 5. **REMODELLED** (8beab85b) onto that presenter, dismissed by its binding; **red on old by R-PL2 on exactly its save**, premises green; restored green |
| T4 — the old cell's keys went to the test host's own key window | **DISCLOSED for the orchestrator:** in window 5 (02:27:47) the ladder's `x`, ⎋, ⎋ were addressed to a key window that was neither the panel's nor its anchor — the DEV-STORE test host's own window by elimination (never the real store). Window 4's anchor-addressed keys may have been delivered the same way. What they did there is not knowable from the log — a glance at the dev store's front note is the orchestrator's call. The remodel can no longer do this (`deliveryWindow` fails the premise by name instead) |
| product code | **none** — no traced live-relevant mechanism (the coordinator's rule for this leg) |

### PENDING (the runner's next window — none of it claimed)
- `CommentPanelFixLeg2Tests` (6 tests) — expected green: the four popover cells replayed 14/14 offscreen
  in the runner's shape; the remodelled cells now ride the road the runner already passed in window 5.
  If a premise fails, it names itself: "the popover is up" / "still up when it is dismissed" = an
  early close; "the key window is the panel's or its parent's" = the runner's key window is the host's.
- The U3 suites beside it, unchanged this leg (`CommentTextAreaTests`' other suites) — regression only.


### ORCHESTRATOR VERIFICATION + DISPOSITIONS (the U3 pin leg accepted, 2026-10-13)

Verified by spot-check: six commits as claimed, the diff confined to the test file + the record (the
R-PL/R-PL2 reverts touched `CommentsPanel.swift` transiently, announced first and restored to a clean
tree — the standard pattern). The traces are accepted: the runner's reds were the HAND-BUILT host's
early close (the cells' own harness), the R1-2 flip is that same early close and NO leg-3 line sits
on its road — proven by the discriminating pair (R-PL2: the watcher's call site alone red on exactly
the save, premises green). The remodel is the right shape: the product's own presenter, ONE guarded
key road that fails a premise BY NAME rather than typing into the test host's window, early closes
reported as themselves. The ladder cell's honestly-not-red-on-old gap is accepted as stated — the
live parent-key road's evidence of record is the `delivers` table plus window 5's read trace.

**T4 (the old cells' stray keys), adjudicated:** the next stage window glances at the dev store's
front note for stray characters from windows 4–5's suite runs (an "x" at a caret). The dev store is
the fenced walk store and the note is expendable walk debris — low stakes, checked for honesty's
sake. The reworked cells cannot reach it any more by construction.

**Next:** the ~10-minute runner window (CommentPanelFixLeg2Tests expected 6/6 + the standing U3
suites as regression + the T4 glance), then LADDER ROUND 2.

## STAGE WINDOW 6 (orchestrator, 2026-10-13 ~03:25 — the final pre-round-2 re-run; 9 min, released clean)

**The suite run** (pinned checkout at 8ecf97b1): **49 tests / 8 suites — 48 green, ONE red:**
`CommentPanelFixLeg2Tests` is 5/6 — `closingThePopoverSavesADirtyInPlaceEdit` is GREEN (the pin
leg's early-close trace vindicated; the product save was never broken) and the whole standing U3
regression set is green. The one red is the ⎋ ladder cell again, now failing DIFFERENTLY: the
remodeled harness's typing works (the SwiftUI presenter receives keys), but a delivered ⎋ neither
cleared the draft (:754) nor left the popover shown (:755) — in the RUNNER the SwiftUI popover is
ITSELF the key window (the pin leg's measured fact), and on that road the ⎋ appears to reach
`NSPopover`'s own close before/instead of the monitor's clear rung. **No live trace shows the
popover as key** (window 5's trace: the PARENT stays key throughout; the panel's makeKey ask
measurably does not make a live popover key), so this is third-time runner-vs-model disagreement on
ONE cell whose live behavior is proven green twice with the trace read. DISPOSITION: no fourth blind
remodel — the cell goes to **ROUND 2's reviewer as an explicit open finding** (cross-model: the
reviewer makes the final call; if it judges the runner's popover-key road live-reachable, it
implements the fix itself; if not, it rules the cell's honest fate — runner-skip with the gap
stated, or a redesign it can defend). The open question for it, stated precisely: **can a LIVE
popover window ever become key** (the makeKey ask, a future host, macOS drift)? If yes, the runner
red is a real bug on that road; if provably no, the cell pins an unreachable road.

**T4 (the old cells' stray keys): CLEAR.** The test host opens on the Bookcase, so windows 4–5's
stray `x`/⎋⎋ went to the quick-entry bar, which ⎋ clears — the Pool shows NO stray note (its
vx222-titled 2026-10-13 rows are that session's own suite debris, untouched by me), and the walk
note's text is unchanged at the glance. No instance left running.

## LADDER ROUND 2 (fable-reviewer, 2026-10-13 — the fix stack `a887bda6..3c0af624`, 37 commits; the cross-model flow's final calls discharged in this session)

**What was reviewed, cold:** the whole round-2 diff read file-by-file in this session
(`CommentCard.swift`, `CommentsPanel.swift`, `CommentTextArea.swift`, `CommentCardTests.swift`,
`CommentTextAreaTests.swift`, the record); round 1's findings and every fix leg's traces, reverts and
orchestrator acceptances in this record; TEXTKIT2_NOTES §3–4 re-read (the diff carries NSTextView
overrides and decoration-overlay work); the path diff verified ZERO `Sources/` (core), ZERO `Sync/`,
ZERO `Server/` lines in the range — SyncSpec not re-read this round on that fact (round 1 read it for
U0). Constraints honored: no `xcodebuild test`, no app launch, no window ordered in, no stage act; the
full HEADLESS suite re-run by this reviewer at the tip + this round's one edit: **`swift test` EXIT 0 —
core 2,704 / 307 and workbook 40 / 6 read exactly; VariorumMCPTests ran green in the same invocation.**
No commit trailer in any of the 37 commits (grep). Mac-target runs stay PENDING (stage) and are marked
so below.

### The final calls (the cross-model flow — the reviewer's word is the disposition)

**R1-2 — CONFIRMED CLOSED (agree upheld, fix accepted).** The implementer's AGREE was measured (SwiftUI
never tears popover content down; `.onDisappear` never fires; the approximated old road loses the edit
the same way — pre-existing class, 13u3 A2), and the fix is the right shape, re-verified here in the
code: `CommentPanelHostWatcher` is scoped by CONTENT-WINDOW IDENTITY (never global), runs the panel's
ONE leaving body (`commitDirtyEdits`, shared by Close, `.onDisappear` and the watcher), and the
accepted double-commit consequence is idempotent twice over (`CommentComposition.commit` answers
`.unchanged` on the second pass; `editBlockComment`'s own no-op guard behind it). Red-on-old held by
the discriminating pair (R-FL2c, then the pin leg's R-PL2 — the watcher's call site alone, red on
exactly the save with premises green). Live-proven TWICE (windows 4 and 5's click-away rows); the
runner cell GREEN at window 6 after the pin leg's remodel. Nothing further owed.

**R1-3 — CONFIRMED CLOSED, the dispute UPHELD.** The finding's mismatch was real (the doc promised a
first-moving-event re-decision the code never made) — and the implementer's dispute of my proposed
one-condition fix is correct: re-deciding mid-gesture is IMPOSSIBLE against AppKit (measured — once a
scroll view takes a gesture its tracking loop captures the rest un-hit-tested; a `.began` handed to an
`NSScrollView` never returns), so the latch was rightly retired WHOLE and the decision moved to
hit-testing per dispatched event (`hitAnswer`), where the owner is whichever scroll view AppKit itself
hands the gesture's first event to. The zero-delta `.began` row deliberately answers the overflowing
card — the alternative makes the card unscrollable by any gesture that begins without movement — and
is table-pinned. The doc now states the real mechanism; W-3 walked FULLY green (window 4: both
directions, the end-of-card handoff, fits-passes, notch). My one-condition proposal is superseded by
a strictly better fix; no further action.

### THE OPEN FINDING (stage window 6's ⎋ ladder cell) — THE RULING

**The question, answered: can a LIVE popover window ever become key?** Not provably never —
`_NSPopoverWindow.canBecomeKey` is true (measured offscreen, the pin leg's T2), the panel itself asks
`makeKey()`, and macOS owns the policy, so "unreachable forever" cannot be claimed. But it is measured
NOT to happen on macOS 27.0, twice, with the DEBUG trace read (windows 4–5: the PARENT keeps key
throughout; the panel's makeKey ask measurably does not take on a live transient popover; AppKit
forwards the key parent's keys into the popover's first responder).

**Why the reachability question is MOOT for the product:** even if a live popover became key (macOS
drift, a future host), that road's ladder is ALREADY PINNED GREEN by the sibling cell
`theCloseRungClosesEvenWhereAPassedEscapeIsSwallowed` — the same presenter (SwiftUI `.popover`), the
same guarded key road, the identical ladder steps (type → first ⎋ clears and the popover stays →
second ⎋ closes), on a STRICTLY harder host: its `.onExitCommand {}` swallow punishes any
pass-through, so an unconsumed first ⎋ fails at the uncleared draft and an unconsumed second fails at
the still-open popover — every miss the red twin could catch fails in the sibling too. It was green in
windows 5 AND 6 on exactly the popover-is-key road, and `theKeyIsThePanelsWhereItIsDelivered` pins the
ownership rule on BOTH roads plus the hidden-panel and no-key arms. **No product mechanism can
distinguish the twins:** the swallow wrapper sits in the VIEW RESPONDER CHAIN, below the pre-dispatch
local monitor — it cannot affect whether the monitor consumes. So the runner red was CELL-LOCAL
environment, not a road defect: the retired cell was the process's FIRST popover cell, and three
windows produced three DIFFERENT failure shapes on it (window 4: parent-addressed keys never arrived;
window 5: the key-premise failure; window 6: an unconsumed-⎋ shape) while the sibling stayed green in
the same runs. **NO PRODUCT FIX — no live-reachable road shows a defect, and the road the runner rims
is pinned green by the sibling.**

**The cell's honest fate, ruled and IMPLEMENTED (f173bac2):** RETIRED as a strict-subset duplicate;
the ruling folded into the sibling's doc comment. The coverage ledger after it: the clear AND close
rungs on the runner's popover-is-key road = the sibling cell; ownership on every road (parent-key,
popover-key, hidden panels, the no-key fallback) = the pure `delivers` table; the LIVE parent-key road
end-to-end = window 5's walk with the `comment-keys` trace read — the standing, honestly-stated gap:
the runner cannot host that road (an off-display anchor can never be key), so it lives on the table +
the walk. If a macOS point release ever changes popover key policy, the sibling and the table still
pin the behavior; the per-release re-verify (TEXTKIT2_NOTES §5) and the next walk are where a change
would show. `CommentPanelFixLeg2Tests` is now **5 tests**; the runner's next window expects 5/5.

### W4-OBS-1 (the click-away dropping a typed, unsubmitted composer draft) — THE RULING

**NOT reviewable on spec grounds — to the author.** The canon is silent on what a dismissal does to an
unsubmitted draft: #118(a) rules only that leaving never FILES, and the ⎋ ladder's clear is an
EXPLICIT gesture where a click-away is not ruled either way. Per the standing rule (spec silence on
product behavior is a question, never a reviewer's ruling), the proposal stays UNBUILT and joins the
merge-moment QUESTIONS deposit as **P-VX179-R2-1**: (a) park a non-empty add draft on the popover
host's closing (`CommentDraftPark`, restored with the park's own receipt at the next open) — the
record's recommendation, spec-coherent ("parking is not filing", the park already exists for
refusal-time drafts); (b) keep today's behavior (a click-away abandons an unsubmitted draft, as ⎋'s
clear does deliberately); (c) file it on leaving (reverses #118(a) — her ruling alone). Her call.

### Round-2 findings (severity-ranked)

**R2-1 · NIT · the record (STAGE WINDOW 5's walk-machinery lesson) — the trace line's stated level is
wrong.** The lesson says the `comment-keys` line "is debug-level; `--info` alone shows nothing", but
the code has logged it at `.notice` (default level) since it was born at 22a3a587 — never `.debug`
(git -S). The lesson's ADVICE still works (`--debug` includes default-level lines), so no operational
harm; recorded here so the next walk's reader trusts the code fact. No code change.

**R2-2 · NIT (recorded consequence, no fix) · CommentCard.swift (`hitTest` → `hitTarget(during:
NSApp.currentEvent)`).** `NSApp.currentEvent` persists BETWEEN dispatches, so a non-dispatch `hitTest`
query (tool-tip/tracking machinery) arriving right after a wheel can read the stale wheel and answer
the STACK where a press query would get the card. Traced to no degradation: both answers name the same
geometry, tool tips ride tracking rects (not hitTest), and during REAL dispatch the current event IS
the one being dispatched — the offscreen dispatch replays and the live walk both validated the
dispatch road. Weighed and recorded; nothing to pin.

**0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT.** No new BLOCKER/MAJOR ⇒ **the ladder CLOSES at round 2**
(the cap-three rule's early close). The one implemented change of this round (the cell retirement,
f173bac2, test file + record only) is owed the implementer's ONE SANITY PASS per the cross-model flow
— the orchestrator dispatches it; its scope is a 35-line test deletion plus doc lines.

### Clean bill (load-bearing things specifically checked and found solid this round)

- **U2's fix stack (CommentCard):** `hitAnswer`'s three-way decision re-derived (wheel → the owner's
  scroll view by hit-testing; lane press → the card's own drag; everything else the door);
  `laneDragOffset`'s ratio math incl. the proportional-knob fallback (`clip × (1 − clip/doc)`)
  correct; the drag road is the drag handle's proven `mouseDown`→`mouseDragged`→`mouseUp`; the door
  still fires on the down, read-tier `nil` answers intact (click-through, no scroller view), the strip
  arm byte-identical; `badgeFace`'s order (shipped inset where the count fits = byte-identical; the
  "#" goes before any truncation; never "…"), and `present`'s count-change gate stops the decoration
  pass undoing a fitted face. The walk's W-3/W-8/F-W-2/F-W-5 rows all green (windows 4–5).
- **U3's fix stack (CommentsPanel + CommentTextArea):** `delivers`' ten table cells each re-derived
  (both key roads, the hidden-panel arm closing the stale class, the no-key fallback confined to
  offscreen); the monitor reads the AREA from the window's FIRST RESPONDER at key time (closing the
  async-focus class); the close rung is the panel's own `close()` — commits dirty rows, then
  `dismiss()` — host-independent by construction; the monitor's release and the save watcher are
  separately scoped observers of the same `willClose`, both keyed on content-window identity;
  `revealForEditing` is bounded (rows only, never for a row taller than the clip, never during a mouse
  gesture's tracking, deferred one turn on caret arrival and growth, and structurally non-recursive —
  `scrollToVisible` is not `scrollRangeToVisible`); the `adopt` writes added this round are plain
  stored properties (not the A47c gated-write class).
- **TK2 hygiene over the whole round-2 diff:** zero TK1 API (grep over the range), overlays stay plain
  views (no rendering attributes), the twin-placeholder machinery untouched, the canary untouched; the
  new `CommentNSTextView` overrides are super-first and TK2-safe.
- **Path and process discipline:** the range touches app target + record only (path diff: zero core,
  zero `Sync/`, zero server); every behavioural revert in the legs was announced first, discriminating,
  and restored to a zero diff (R-FL; R-FL2a/b/c; R-FL3a/b; R-PL/R-PL2); the honestly-not-red cells are
  labelled as such in the record; the two sheet-probe incidents led to a tightened offscreen line that
  the later legs visibly honored; zero commit trailers (37 commits); worktree clean and in sync.
- **The headless suite at the tip + this round's edit:** `swift test` EXIT 0 (core 2,704/307, workbook
  40/6 read exactly; the MCP target green in the same invocation); the retired cell's file re-typechecked
  stage-free against the built module (EXIT 0, with `EditorTestSupport.swift` — non-vacuous: the lone-file
  invocation errors).

### PENDING (the runner's next window — the orchestrator's; none of it claimed by this round)

- `-only-testing:VariorumTests/CommentPanelFixLeg2Tests` — now **5 tests, expect 5/5 green** (the
  retirement leaves F-W-3, the ownership table, the close rung, the monitor release, R1-2).
- The standing U2/U3 suites as regression (unchanged by this round — the one edit was a deletion).
- Nothing else: round 2 ordered no product change, and the walk rows it leaned on are already walked.

### Implementer sanity pass (Opus, 2026-10-13 — f173bac2 + e8510e3b)

**AGREE.** The deletion removes ONLY the retired cell. The suite is coherent at 5 tests: `areas`, `turns`, `key`, `seed`, `deliveryWindow`, `SwiftUIPopoverHost` and `swiftUIPopover` are all still used. The stage-free typecheck with `EditorTestSupport.swift` returns EXIT 0 at e8510e3b. The final calls on R1-2 and R1-3 state my legs correctly. Precisions, none of them changing the ruling and none acted on:
1. **"Strict subset" holds on every rung but one.** The retired no-swallow twin uniquely caught a FIRST-⎋ *acted-and-passed* defect: the panel clears the draft but returns the event, so `cancelOperation` closes the popover as well. The sibling's swallow masks exactly that defect. Today the code's shape excludes it (`handle` returns true on every branch; the monitor returns nil when handled). No mounted cell now pins that return contract. This is a NIT-level gap, recorded and not reopened.
2. **The cell history is overstated in two places.** The sibling's new doc line ("three stage windows … while this twin stayed green on the same presenter and the same key road") and the ruling's "while the sibling stayed green in the same runs" are both inaccurate. The retired cell ran on the HAND-BUILT `NSPopover` host in windows 4 and 5, and only window 6 ran it on the SwiftUI presenter. The sibling did not exist in window 4, which ran c6d18035; it was born at 8eeb3bf9. The ruling's conclusion does not depend on either wording.
3. **"Every revert … discriminating"** in the clean bill: R-PL reddened TWO cells, because the monitor's release shares `isHost`. R-PL2 was the discriminating one, as the pin leg recorded.
4. **A placement nit:** the sibling's doc says "`delivers`' table below", but the table sits above it.

## CLOSEOUT (orchestrator, 2026-10-13 early morning — her overnight mandate)

**The run:** four units built and accepted (U0 the `Sync/` line · U1 true delete · U2 gutter cards ·
U3 the panel as a text editor), five fix legs (U2 ×2, U3 ×2 + the pin leg), two walks across six
stage windows, every fixed row proven in the live app. **The ladder: round 1 0B/0M/2m/1n → the fix
legs → ROUND 2 0B/0M/0m/2n — CLOSED, no round 3; the sanity pass agreed** (its four accuracy
corrections recorded; the sibling cell's doc corrected). Final calls: R1-1 discharged at this merge
(the §7/§9 contract lines + the QUESTIONS bundle); R1-2 confirmed closed; R1-3 confirmed with the
dispute upheld. Pre-existing bugs found and fixed on the way: the ⌘Z-after-filing crash, the
filing-undone-words desync, the 13u3 badge-inset truncation, the popover dirty-edit loss, the
clipped dirty-row face. Found-work tickets: VX-182, VX-183, VX-193 (HIGH), VX-194, VX-226, VX-229,
VM-14. Main merged INTO the branch pre-close (230cbfc5; 0.9.4 — the What's-New flip ended; merged
tree `swift test` EXIT 0; round 2's full read at the pre-merge tip: core 2,704/307 · workbook 40/6).

**FINAL MAC SUITE RUN (window 7, 2026-10-13 ~04:10, at the tip d925c105 on the MERGED tree):**
**103 tests / 15 suites / ALL GREEN, exit 0** — the whole comment set (the three card suites,
BlockDecorGeometry, MarginHoverComment, IndicatorGutter, ProseGutter, CommentPanelFixLeg2 5/5, the
seven panel suites). Log `/tmp/vx179-window7-suites.log` (deleted with the walk evidence at
cleanup). Six minutes, released clean, no instance.

**Her handoff:** `notes/handoffs/vx-179-handoff.md` (the morning checklist). **Mobile parity:** the
MobileSoul.md row lands on main at the merge. **The refresh:** the coordinator's one-folded-refresh
plan governs; the outcome is recorded below at the merge.
