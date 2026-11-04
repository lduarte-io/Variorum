# VX-770 — Ladder round 1 (cold review, fable-reviewer, 2026-11-04)

**Reviewer:** Fable (fresh session, zero implementation context; `notes/REVIEW_PROMPT.md` run verbatim).
**Diff under review:** `93a3ef88d..HEAD` (HEAD = c633c9d6d), branch `vx-770-takes-compare-window`.
**Anchor:** `notes/plans/fixes/vx-770-takes-compare-window.md` (the run record, read whole).
**Canon read this session:** CLAUDE.md + auto-loaded set · SurfaceContracts (The note — Takes,
the editor language, Compare/modes; the Bookcase order lines) · TEXTKIT2_NOTES §0–§4 (the diff
touches `EditorViewModel.updateCaretContext` and board pane surfaces) · the two changed core files
against AppSpec §9/§10. Every source file in the diff read in full diff form; the pins spot-read
for honesty (every mounted pin's red-on-rev/green-on-HEAD was executed for real in the run's
windows — logs named in the record — so the review's weight went to unpinned regressions and
spec drift rather than re-predicting runs).

**STATUS: COMPLETE — findings below, severity-ranked; clean bill at the end.**

---

## Findings

### F1 · MAJOR · `App/Variorum/Variorum/Features/Takes/CompareBoardView.swift:2129–2140` · Compare's host conditionally unmounts the shared comment face, so the panel-seat guard the record claims for Compare does not exist there

**What's wrong.** The batch 3 record states the seat guard "lives in the one shared host, so
Compare (already live since batch 2) gets the same guard," and walk row W14 says "Same in
Compare (the shared host)." As built it is false for Compare. The seat lives inside
`CommentGutterFace` (`CommentGutterFace.swift:77` — `shown = panelShown && entries.isEmpty ?
seat : entries`), and it works only while the host keeps the view mounted. The Takes host does
(`CommentMarginNote` builds `CommentGutterFace` unconditionally, `TakesShared.swift`), but
Compare's cell wraps it in a comment-presence conditional:

```swift
.overlay(alignment: .topLeading) {
    if lane > 0, let entries = model.face(for: postID)?.comments[slot.blockID],
       !entries.isEmpty {
        GeometryReader { ... CommentGutterFace(...) }
    }
}
```

**Mechanism (traced).** She presses the Compare face's door → `onClick` sets `seat` and
`panelShown = true` (the `@State` on `CommentGutterFace`); the comments panel opens as that
view's `.popover`. She deletes the block's LAST comment in the panel →
`deleteBlockComment` commits → `CompareViewModel.read`'s live feed delivers a projection whose
`PostFace.comments` no longer holds the block (`Queries.containerComments` omits comment-less
blocks) → the host's `!entries.isEmpty` fails → SwiftUI unmounts `CommentGutterFace` → its
`@State` (`panelShown`, `seat`) is destroyed and the popover is torn down mid-act — the deleted
fold with its Restore vanishes under her. This is precisely the regression the seat was built to
prevent (batch 3's trace: "a live feed that empties the face while her panel is open … would
tear the panel down mid-act"). The one shipped pin
(`TakesPostUndoStalenessTests.herOpenPanelKeepsItsSeatWhenTheLastCommentLeaves`, :320) mounts
the TAKES board only, so nothing covers Compare.

**Evidence.** Code read: `CompareBoardView.swift:2129` (the conditional), `:570` (`face(for:)`),
`CommentGutterFace.swift:41–51` (the seat's doc declares it guards "every host's feed"),
run record batch 3 AS BUILT ("so Compare's already-live feed gets the same guard") and W14.

**Red-on-old pin (names the pin that proves it).** A Compare twin of the seat guard, in the
batch 2 Compare rig: comment once on a block, mount `CompareBoardView`, find the block's
`CommentCardView` by identity, press its `onClick` (panel opens), `deleteBlockComment` the only
comment, settle, assert the card is still in the hierarchy and the oracle still holds the seat
(`BoardCommentFaceOracle.reader(scope, board:)`). RED on today's HEAD; GREEN after the fix.

**Fix.** Hoist only the `lane > 0` test; always build the face view (Takes' own shape):
`CommentGutterFace(session:blockID:entries: model.face(for: postID)?.comments[slot.blockID] ?? [],
…)` — the shared host already renders nothing when `shown` is empty, and the oracle's
record/forget already rides the inner branch. One realized-cell overlay more per row, viewport
bounded (P1 unaffected).

### F2 · MINOR · `App/Variorum/Variorum/Features/Takes/TakesBoardLayout.swift:407–431` · `forgetPages`' follow-the-scroll exception keeps a COLLAPSED fan's stale page

**What's wrong.** `forgetPages(ofClosed:)` skips a block when `followTheScroll &&
isRowVisible(blockID)` — modelling "a strip that stays mounted keeps its page." That is right
for the two hand-close doors (the block still `hasFan`, so under follow-the-scroll its strip
stays mounted). It is wrong for the third door, `closeCollapsedFans` (:407): a collapsed block
has `hasFan == false`, so `isBloomed`'s follow-the-scroll arm (`slot.hasFan && visible`) is
false and the strip unmounts regardless — yet its page survives in `pageOffsets`. When the fan
later returns (⇧⌥⌘Z re-adding the takes, a new second take) and reopens, the re-born strip
meets the stale page: VX-638's own lie ("2–3 of 3" over cards 1–2) through the one door the fix
added. Corner conditions: follow-the-scroll ON (non-default), row visible at collapse, fan
returns. The stated rule ("a fan that closes forgets its pages, from the three close doors") has
a hole at its third door.

**Red-on-old pin.** Pure state transition on the layout (the `TakesPagerAfterCloseTests`
family's shape): `followTheScroll = true`, the row visible, a page set for the block,
`closeCollapsedFans([block])` → assert `pageOffset == 0` for both keys. RED on HEAD, GREEN
after the fix.

**Fix.** `closeCollapsedFans` forgets unconditionally (a collapsed fan's strip never stays
mounted — the visibility exception is the hand-close doors' only): pass a flag or forget before
applying the exception, e.g. `forgetPages(ofClosed:evenWhileVisible: true)` from
`closeCollapsedFans` only.

### F3 · NIT · `App/Variorum/Variorum/Features/Takes/TakesArticleScroll.swift:917–941` · the in-storm re-aim's judged-height equality can collide with a revisited content height

`reaimWhereTheColumnReEstimated` gates on `content != landingJudgedContent`. The measured storm
revisits heights (batch 1's own story: `5190 → 2121 → 5190`): if an aim judged the column at
height H, the column passed through H′ with the row home (judged stays H by design), and then
returned to exactly H with the row re-based off home, the gate refuses and the landing falls to
the watch — the OLD one-hop behaviour, in that corner. Never worse than the pre-fix road (the
watch backstop is intact), so this is an observation, not a bug: no pin is demanded. If it ever
shows in a walk, a per-geometry-pass generation stamp instead of the raw height closes it.

### F4 · NIT · `App/Variorum/Variorum/Features/Takes/CompareBoardView.swift:107–115` · `CompareRow.id` survives as a second, unread identity

The board keys rows by `spineID` (:1771); `CompareRow.id` remains only as `Identifiable`
conformance. The implementer's own residue (R-B4-4) already names it. One identity per type is
the cleaner end state; retire `id` (or make `Identifiable` use the spine) at the next touch.
No behaviour rides on it today (verified: nothing else reads `.id` for row identity — the
toggle pins key panes by identifier, the composition pins read rows structurally).

---

## Dispositions of the record's open uncertainties (checked, no finding)

- **Batch 2's prediction miss / the `:417` red** — the reconciliation's mechanism (an oracle
  record surviving a closed-but-alive window; `BoardCommentFaceOracle` now attributes per
  board) is the correct reading; the reconciled guard carries real non-vacuity lines and real
  measure assertions (`BoardCommentGutterTests:393–444` read). The consolidated b3r green run
  executed it. Solid.
- **The "Modifying state during view update" warnings** — the oracle writes only from
  `onAppear`/`onChange` (`BoardCommentFaceOracle.swift:146–164`), and the per-suite counts were
  shown identical pre/post. Pre-existing class, correctly left as a ticket candidate (R-B4-2
  names the deeper pane-seed class). Agree: not this run's.
- **VX-758's arm choice** (her "creation date" vs the broken Entry-date arm) — the code
  admits only the implementer's reading: the Created arm (`c.created_at NOT NULL`) always
  ordered every note; only the Entry-date arm matches "unless items have an entry date."
  Verified `stampOrder` old shape and `Queries.LibrarySort.entryDate`'s spelling
  (`Timeline.swift:177`, `COALESCE(entry_date, created_at)`) — the book now matches the Library
  byte-for-byte, ties by id in the same direction. The known midnight-zone corner rides with the
  Library's rule, deliberately. Her-bundle line (R-B5-5) is the right routing; no finding.
- **VX-739's conditional fix** — resolved FIXED by the b5gate red leg (red on rev both arms).
  The guard's placement is correct: `suppressEditProcessing` is raised by exactly the three
  storage-write primitives (`setSurfaceContent`, `applySeamEdit` :1018/:1028,
  `programmaticReplace` :4483), and both executors end with their own `updateCaretContext()`
  (`EditorSurfaceController.swift:149/:236`) outside suppression, so the live arm loses nothing.
  R-B5-2/R-B5-3 (the `noteFocusedBlock` sibling, the ledger's text-keyed-cache weakness) are
  honestly recorded residues; agree with deferring the `Shared/` hardening.
- **VX-652 option C** — the premise re-check (trailing-pinned SwiftUI `Menu`, screen-constrained
  only, no alignment API) is consistent with AppKit behaviour as documented; not building a new
  AppKit pull-down blind at night's edge is the right call; re-owning with the design preserved
  is honest. No finding.

## Clean bill (checked and found solid)

1. **VX-757's `spineID` uniqueness** (the `ForEach` key): argued from I2 and the composition —
   each anchor block composes into exactly one row; a peer block sits in one row of its column;
   anchor-less rows key by the first peer COLUMN index, so two columns sharing a block id cannot
   collide; `a:`/`p‹n›:` prefixes separate the kinds. No reachable duplicate id found, including
   the same-note-in-two-columns and note-compared-with-itself shapes.
2. **VX-757's one-row-structure parity**: old free arm (cells straight in the `HStack`, clear
   space `maxWidth: .infinity`) and old aligned arm (`VStack` spacing 4, moved line, kin
   `ForEach`) are reproduced exactly by `rowView`/`peerColumn` — including the aligned-empty-kin
   case (no clear space, `isFree` guard) and the moved line's `!kin.isEmpty` condition.
3. **VX-740's dedupe** (`makeOutlinePost`): `autoFilled = true` before the `contains` check;
   yields only to the SAME note's seat; the full-board refusal and the beside-open-note append
   unchanged. Matches P-770-1 verbatim.
4. **T1/T2 are true moves**: `BlockDecor.commentFace` is the old per-block arm byte-for-byte
   (threshold, card rect, badge rect, yields order unchanged); `presentGutterFace`'s card
   content equals the old `renderComments` card arm including the tooltip join
   (`"  ·  "` — verified against the 93a3ef88d source) and the badge's `"#n"`.
5. **The one-law guards are real measurements**: `aCommentNeverMovesTheTakesProse` compares
   commented vs plain prose left/width to 0.5 pt and asserts every face's `maxX` left of the
   prose; the Compare guard's non-vacuity line was red-on-rev. The Compare lane is a pure
   function of column width (`CompareGutter.lane`), never comment presence — P-770-3's rider 1
   holds in code.
6. **VX-732's feed** is Write's own query, observation region `block_comment` +
   `container_block` (no keystroke wake), equality-guarded adopt; the old per-row `.task` read
   and after-panel refresh fully retired; Compare's feed rides the projection. P1/P-8 bounds
   hold as stated (reads ∝ the note's comments; faces per realized row).
7. **VX-733's rule and conductor**: `TakesOpenFanRule` is pure and correctly guarded
   (`liveVariantCount > 1` held-before; `<= 1` and not-a-gap to close; left-the-note excluded);
   the session record is written beside the open set, `∩ expandedBlocks` at read launders any
   staleness; R-770-1/R72/archive-road guards all ran green on BOTH trees in the real window.
   The canon delta (the collapse sentence for the Takes bullet) is proposed for closeout, not
   smuggled — correct two-file routing.
8. **VX-756's fix discipline**: the re-aim is entry-kind-only (`landingIsBanded`,
   kind == .entry — the find road excluded), ride-through excluded, one aim per content-height
   change, pocket-bounded (24) inside the 64-aim fence, through the ONE step; `beginWatch` and
   both step aims stamp the judged height; all bookkeeping reset per landing in `landArticle`.
   U2's per-report failure cannot recur by construction. Real red ×4 / green ×4 at the window.
9. **VX-634**: the label fixed where minted (`Operations+Deletion.swift:144`); the four
   existing label pins edited with it (the ritual — verified the diffs are label-only); the
   fence's allow-list names "Archive Variant" with its reason and the sweep table is in the
   record; the phone's one "Delete Take" reference is its own door-menu pin, unaffected.
10. **Scope fences**: no `Sync/`, no schema, no custody, no `Shared/` source file, no
    `PaneSurface`/`EditorTextView`/`BlockRangeIndex` line, no capability-registry delta, no TK1
    API, no attribute stamp in the diff (verified against the full diff stat and file list).
    Core changes (VX-758, VX-634) correctly owe the six phone suites at the merge gate — planned
    in the record, not skipped.
11. **Evidence hygiene**: every bug member is red-on-old verified by a behavioural revert run
    the orchestrator executed (windows b1/b2/b3r/b4-red/b5gate), the whole Mac target is green
    at HEAD (5824/1015, zero failures), and the two core members ran red→green under plain
    `swift test` with revert verification. The one prediction miss and the one mis-seated
    assertion were reconciled honestly and re-run. No test deletions or weakenings beyond the
    deliberate VX-758 pin re-shape (which the record and her kickoff sentence justify).
12. **Commit hygiene**: no `Co-Authored-By`/`Claude-Session` trailers anywhere in
    `93a3ef88d..HEAD`; the worktree is clean but for an uncommitted `Package.resolved`
    workspace artifact (xcodebuild churn — drop or commit deliberately at closeout, not with
    the ladder).

## Verdict

One MAJOR (F1 — a real, reachable regression of the record's own stated guarantee on Compare,
with a clean pin and a small fix), one MINOR (F2), two NITs. Nothing BLOCKER-class: no invariant
violation, no spec drift against ruled canon (the two product bends — P-770-3's lane and
B3-P1/P2 — are PROVISIONAL and routed to her bundle as required). Round 2 should re-check F1's
and F2's fixes and their pins; F3/F4 need no round.
