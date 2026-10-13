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
| 5 | U3 panel pristine pass | IN-PROGRESS — see the U3 RECORD |
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

**U3 IN PROGRESS — building on the F-U3-1 RULING (c0888701).** The trace (measured, below) stopped at
the fork; the orchestrator ruled (a) the AppKit control with the twin-view placeholder · (i) the bar's
2 pt drift fixed here through `CaptureTextView`'s named inset · the panel-private home. Resumed the same
session (no death).

**NOT DONE BY THIS UNIT (first line, by the contract — kept current):** no `xcodebuild test`, no walk,
no app launch, no window shown, no `/Applications` touch (the stage is held) — every app-target pin
RUN, every red-on-old-by-revert run and every capture is PENDING (stage). Zero `Sources/VariorumCore/`
lines, zero `Sync/` lines. `CommentComposition` and the key grammar are byte-untouched by design.

**Revert state:** no behavioural revert is in flight, and none will run this session (app-target runs
are stage-gated).

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
| U3-d3 | pins — new `VariorumTests/CommentTextAreaTests.swift` (3 suites, 14 tests, 18 cases with the voice arguments): the pure rules (owned geometry, row height, Q-2's origins incl. the bar's red-on-old cell, the focus-report table); the REAL control mounted offscreen (caret line == placeholder line, placeholder ink == typed ink, typing attributes + twin through type/clear/IME, no dead air, mark baseline == text baseline, the held focus request + reports, ⎋ falls through, the capture box's first line at its own origin); the words (sentence case, refusals as words) + the model-level race pin (red-on-old: "Refused: commentNotDeleted(…)" etc.) | DONE (f3a4a8cc) — WRITTEN; TYPECHECKED stage-free against the built module (`real/typecheck.sh`: Swift 6 + the test target's upcoming features + the Testing macro plugin; EXIT 0, zero diagnostics, with the five existing touched-area suites in the same invocation; non-vacuity probed — a misspelt member fails it). RUN PENDING (stage) |
| U3-e | the pristine pass (the look, both voices, both appearances, sheet + popover hosts — one view): the COMPOSER (the add area as the voice's writing box: card paper + hairline, accent hairline while live, keys + Add inside it), one WRITING column / one CHROME column, inset row hairlines, the header's count only when non-zero, the deleted fold as the live list's quieter twin (struck words, then the stamp line "Deleted <date>" with Restore + "Delete forever…"), Add on `VoicedButtonStyle` (it fades when there is nothing to file — `CalmButtonStyle` ignores disabled), every word in `CommentsPanelCopy` (sentence case), O-3 (`CommentsPanelRefusalCopy`), taste numbers in `CommentsPanelMetrics`; `VoicedButtonStyle.labelInset` named | DONE (4b7cfd60) — plain build SUCCEEDED, zero warnings in touched files; REAL panel rendered offscreen (see "the look, rendered" below) |
| U3-g | **FOUND IN SELF-REVIEW (the ruling's "undo grouping" walk risk, probed): ⌘Z right after filing a comment CRASHES** — the panel clears the add area programmatically and NSTextView's typing undo then replays ranges of the OLD text (`NSRangeException: Range {13, 9} out of bounds; string length 0`). PRE-EXISTING: the shipped `TextEditor` crashes identically (`undo2.swift old`). Pin-before-fix: the pin `undoAfterTheAreaIsClearedForHerCannotReplayTheOldText` written first (this commit); its red is the probe on the pre-fix control (`real/undo.swift` vs fa488500…f3a4a8cc: uncaught exception) | PIN WRITTEN (a76de514 — whose message claimed "typechecked" FALSELY: my chained command committed past a failing typecheck (`ObservableObject` without Combine); corrected and TYPECHECKED EXIT 0 at the next commit, the helper types moved to file scope as `@Observable`); FIX next — per-area `UndoManager` via `undoManager(for:)`, ended on a programmatic adopt (`removeAllActions(withTarget:)` on the view or the storage does NOT reach TK2's registrations — measured) |
| U3-f | verify: plain build green, zero warnings in touched files; record closed; PENDING list | NOT-STARTED |

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
Study × light and dark × {empty, two comments + one deleted, typed, a refusal}: 20 PNGs, every one
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
