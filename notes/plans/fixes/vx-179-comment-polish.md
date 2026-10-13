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
| 4 | U2 gutter cards | IN-PROGRESS — see the U2 RECORD |
| 5 | U3 panel pristine pass | NOT-STARTED |
| 6 | Mac-target test runs + the walk (stage via oct12coordinator) | HELD — stage |
| 7 | The ladder (fable-reviewer, whole diff) | NOT-STARTED |
| 8 | Bout-start board snapshot + in-flight row on main | HELD — until the release session reports |
| 9 | Ticket VX-179 description gains branch/record pointers; Done rides the PR merge | NOT-STARTED |
| 10 | Closeout: PR → merge commit; worktree + branch removed; debris tidy; MOBILE PARITY line | NOT-STARTED |

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

**U2 IN PROGRESS.** The gutter comment cards (R-VX179-1/2): the 96 pt cap retires; the margin card
re-forms as STACKED ENTRIES that scroll inside the card.

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
| U2-d | pins: the pure tables (arrangement · wheel owner · reconcile) + mounted card + controller cells (app target — WRITTEN only; compile + RUN PENDING stage) | DONE (this commit) — new `VariorumTests/CommentCardTests.swift` (3 suites, 14 tests); the card gained the budget's component-wise `CardContent ==` + two DEBUG counters the pins read. STAGE-FREE EVIDENCE (no test target built, nothing run): `swiftc -typecheck` of the new file AND of the two edited existing functions (extracted verbatim) against the plain build's `Variorum.swiftmodule` — EXIT 0, zero diagnostics (non-vacuity probed: a misspelt member fails it); a source-copy REPLAY of every pure-table cell and every geometry cell (new vs old formula) — all as pinned. RUN + red-on-old by revert PENDING (stage) |
| U2-e | verify: ONE plain `xcodebuild … build`; record closed | NOT-STARTED |

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
