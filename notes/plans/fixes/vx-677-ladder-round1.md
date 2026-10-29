# VX-677 — ladder ROUND 1 (cold review, Fable, 2026-10-29)

**Scope:** the run's whole diff, `git diff origin/main...HEAD` at tip `3cf128fed` (merge base `039aededb`; the tested
SHA for the final window's evidence was `092909955` — every source change since is record-only, verified by
`git diff --stat` over non-notes paths). Reviewed cold per `notes/REVIEW_PROMPT.md`: the run record read in full,
MCPSpec in full, TEXTKIT2_NOTES §0/§3–4, SurfaceContracts in full (the app · the Bookcase and books · the note ·
doors), every product file of the diff read line by line, the new pin files read, the three changed MCP wire suites
re-run headless by the reviewer (21/21 green). No BLOCKER, no MAJOR found. Findings below, severity-ranked; the
clean bill after them. Dispositions column to be filled by the cross-model flow (findings → the implementer
verbatim → agree/dispute → the reviewer's final call).

---

## Findings

**F-L1 [MINOR] · App/Variorum/VariorumTests/OutsideWriteLivePaneTests.swift:170,175,183 · the Takes twin keeps the
exact VX-692 donor/recipient closure shape that hollowed its Lenses sibling for two windows.**
`aLiveTakesArticleShowsAnAIsEditToItsOwnTake` wraps its two fixture predicates in
`#expect(await Self.settle(window, hosting) { … })` (:170, :175) and then, in the same enclosing `withWorld`
closure, binds the same-typed plain closure `let shows = await Self.settle(…, timeout: 4) { …aiWords }` (:183) —
byte-for-byte the shape D-1 proved merged in this very file (`closure #5` emitted once for the Lenses pin's c1 and
c3). The twin compiled honestly at `1d960469e` (the binary panel), but the merge is BUILD-SENSITIVE — the run's own
lesson (R12: the MCPShareFaces merge did NOT recur on a rebuilt binary; the handoff: "a red can vanish on
rebuild"). *Mechanism if it merges:* `shows` runs the `prose(2/3)` fixture body — on `post` the pane shows the AI's
words, the predicate never turns true, the 4-s timeout makes a FALSE RED at any future window; on `rev664` the
decisive assertion goes hollow (the red-on-old survives only via the editability line). *Fix:* bind the two fixture
predicates to locals first (the D-1 Lenses repair's steps 2–3, applied to the twin). Test-only — no pin owed; the
general sweep stays VX-692's (High, ticketed), but this file is the run's own new pin file and its sibling already
bit twice, so the two-edit fix belongs in this run's fix round.

**F-L2 [MINOR] · App/Variorum/Variorum/Features/MCP/MCPDoor.swift:1095–1112 (`takeShowOffer`) · her TAKE of an ask
can end the ask and then do nothing, silently — against the status seam's "a door that did nothing speaks a
refusal" (SurfaceContracts §The app).**
*Mechanism:* `takeShowOffer` runs `endShowOffer()` first, then
`Task { await MCPNavigator(session:).deliver(offer.request.target, into: router) }` (:1102) with the three-state
`Delivery` result DISCARDED. An ask stands indefinitely while its client is connected, and nothing ends it when its
TARGET dies — so a takes/lens/compare ask whose note is deleted while the ask stands (a wire `delete_note`, her own
Delete, a sync removal) delivers `.unfinished` (`open(noteID)` never mounts the dead note's detail inside
`mountWait`): the ask is gone from the seam, nothing opened, nothing spoken. The no-window arm of the same function
speaks AND keeps the ask (`MCPShowOfferCopy.noWindow`); this arm is silent. The sibling silence on the receipt road
is already recorded (batch 3's F-B3-2, `openShow`); the ask's take is a NEW door built this run, so the contract
binds it directly. *Pin (red-on-old):* stage a standing ask on a takes target, delete the note, `takeShowOffer()` →
expect a spoken refusal (old: `status.current == nil`, nothing said). *Fix shape:* speak on `.unfinished` from the
take road (the navigator already answers the three states — e.g. `session.status.refuse(MCPShowRule
.partialShowWords)` or its own sentence), and fold F-B3-2's `openShow` line into the same touch. *Adjacent product
question, unruled — QUESTIONS candidate for the P-676 bundle:* should an ask END (or re-say itself) when its target
dies, rather than keep offering a dead thing? Not a ruling for this ladder to make.

**F-L3 [NIT] · App/Variorum/Variorum/Features/MCP/MCPDoor.swift:1108 · her take's Activity row is best-effort
(`try? await runner.run { recordMCPShowTaken … }`), silently droppable.**
Ruling (4) says Activity logs the ask AND the take; the take's row is the only ruled Activity row written with a
swallowed error (the comment owns it: "a lost line never undoes what she opened" — a defensible posture, and a red
pin would need a failing store). Recorded so the orchestrator can dismiss it deliberately rather than by silence.

**F-L4 [NIT] · App/Variorum/VariorumTests/RestoreLandingInspectorTests.swift:41,44 · two stale comment lines still
name the removed `VX668-TRACE`** (the handoff's own two-line tidy — confirming it has not landed yet; the only
`VX668`-trace references left in the tree, verified by grep over App + Sources).

**F-L5 [NIT] · the record (canon deltas owed) · batch 2's carry family and VX-668's sheet-road landing have NO
drafted contract lines in the record** — batch 3 drafted its MCPSpec/SurfaceContracts lines and batch 4 named its
Block History line, but VX-663/VX-662/VX-681/VX-680/VX-624's SurfaceContracts §Bookcase lines and §The note's
"(the read-in-full sheet's own landing is VX-668)" pointer (which must become the landed fact: the sheet road lands
at the block's start as the row road does) exist only as the closeout checklist's one line. Draft them before the
closeout applies the two-file rule, so nothing lands from memory.

---

## Merge gates the ladder CONFIRMS (already the plan's; restated as the reviewer's own line)

- **C1** (`vx677-c/rev668`, EXACTLY 1 failure) is the VX-668 fix's owed red-on-old — the fix landed with its pin
  revert-verified by BUILD only; the merge correctly waits on the run (the record's F-4 names the deviation
  honestly).
- **C7** (`vx677-c/revFW2`, EXACTLY 1 failure) is F-FW-2's owed red — the pin is "red by mechanism" only, never yet
  run; **C4/C5** are DA-1's repaired pin's red/green. A hollow green on any of these follows the record's own rule:
  record it, never fix it.
- The **W-668-V1 ×3** sheet-road walk is the landing half's evidence of record (the post/rewrite race falls either
  way per press — one green press is not the verdict).

## Review foci (the handoff's standing ladder eyes), each addressed

1. **Batch 2's six stare points** — all examined against the code: (i) the authority's home-switch is sound AFTER
   D-2 (the row-first rule consulted at both the report and the act; the end-of-landing re-seed restores the row's
   true top); (ii) `scrollToVisible` as the block's act is justified (a block is not a SwiftUI view) and is not a
   second loop — one landing, one authority; (iii) the second-inline-editor-same-note edge is recorded, filtered by
   `editing.postID` + `scrollView == nil`, acceptable; (iv) the widened Index observer fires per scroll but its new
   body is two assignments — Release-safe; (v) VX-662's pick (a) is not a product fork (the road table holds: (b)
   and (c) each leave a stale road (a) closes); (vi) VX-663's `landingAt:` outranks the identity re-anchor on the
   FIRST adoption only — later `.onChange` adoptions pass none, `theAddressSurvivesMembershipAndOrderChangesByIdentity`
   unmodified.
2. **P-680-2(a)'s reading (D-2)** — the reviewer CONCURS with the dispositions record: the row-first rule is the
   design's own words ("the row first, the block within about a second"; the guard's contract), not a new product
   decision; the dissenting reading would leave the Outline landing's standing drift correction off exactly where
   nothing else corrects it (the live Study walk met the 37-pt drift and the fix corrected it). P-680-2 stays in
   her bundle with the row-first arm noted, as the closeout checklist already says.
3. **F-B5-1** — the old VX-440 sheet pin stays the ORDER pin; `RestoreLandingRewriteHopTests` is the landing pin;
   no conflict.
4. **The `clear()` / refusal-toast / ⌥⌘O trio** — verified in `StatusCenter` + `MCPDoor`: `clear()` never ends a
   standing ask (that is what makes "the toast's ✕ sends it to the line" true); a refusal toasting beside a
   standing ask shows two messages in two places (deliberate — the 18i one-message comment stays true of
   `current`/`quietLine`; `lineItem` is the one new rule); ⌥⌘O takes a standing ask first and the registry fact
   (`aiLastChangeAvailable`) includes it; a quiet receipt takes the line for its six seconds, then the ask is back
   (P-676-3(a) as built — the receipt's `deliver` sweeps the ask's TOAST under the one-message rule, the ask holds
   the line: consistent with the ruling). The named hazard (a future "silence everything" caller missing
   `endStanding`) stands recorded, not built around — agreed.
5. **VX-692's macro hazard** — addressed as F-L1 (one proven-shape site left in the run's own new pins); the new
   fixes-unit and batch 4/5 pins honor the bind-to-locals rule (checked: `RestoreLandingRewriteHopTests`,
   `HelperWindowThemeTests`, `MCPShowOfferFacesTests`, `CommitRestingPreviewTests` carry no closure-bearing
   expression inside a macro; the plain-function-body helpers (`chosen`) are the recorded-safe shape).
6. **Trailer discipline** — verified: 0 `Co-Authored-By`/`Claude-Session` lines over the branch's 102 commits.

## Clean bill (load-bearing things specifically checked and found solid)

- **The fences:** `git diff origin/main...HEAD` over `Sources/VariorumCore/Sync`, `Server/`,
  `Sources/VariorumCore/Protection`, `App/Variorum/Shared/Protection` is EMPTY; no schema change, no migration, no
  new dependency, no literal colour; `Package.swift` untouched. Mobile parity: no `Shared/` or `VariorumMobile/`
  file in the diff; the two new core files (`MCPShowDial`, the grants ops/queries rows) are additive types the
  phone never reads — "nothing mobile-visible" holds.
- **VX-664 (the editor seam's High):** the pure rule is right — suspicion computed BEFORE `settle` drops buffers,
  judged against what the pane HOLDS (`liveHeld`: the focus's `showing:` baseline, then her keystrokes), her own
  text compared through `StoredText.stripped`; nothing pending wins every race (the typed-in-the-gap confirm is
  declined via `isPending`, same main-actor hop from confirm to `endRing`); the confirmation is one row by key,
  off-main (P1/P2), weak-owner-safe. Every owner wired at its existing settle seam with the INCOMING delivery's raw
  stored text (verified per owner — Takes/Lenses/Write's panel from `new`, Compare from the new face's
  `workingText`/slot text, Canvas from the new projection, the TOC model from the delivered rows/facts, the book
  Index context-gated per note); every focus door passes its host's resolution as the baseline. P-3 whole: the live
  pane never adopts — it stops being live; `liveHeld` is a mirror, never a second liveness answer. The sweep table
  S1–S21 read against the code: the SAFE rows' mechanisms hold (new rows, released sources, non-text acts, the
  full-document editor's own discipline), the residuals are honestly ticketed (VX-683) and guarded
  (`anOutsideWriteRacingHerPendingTypingLeavesTheRing`).
- **B2-i (A-677-2, ratified):** one factored adoption body (`adoptProjectionText`) for both read roads; the go-live
  completion gated to the read→live transition with a moved projection (TRACE 1a's native record); the click place
  handed to the landing as a re-bind's; the four-writer comment corrected.
- **VX-656:** the delegate-owned `UndoManager` answered only for the wired view; history ended at BOTH dismantles
  and belted at `teardown()` with a guard that can never clear the window's manager; every existing
  `textView.undoManager` reader resolves through the delegate's answer (WHEN unchanged, WHERE moved); the undo-hint
  comment corrected for per-editor histories. No TK1 API, nothing on the live storage, `BlockRangeIndex`/
  `runStructural` untouched.
- **VX-668:** the WHY is a measured TK2 fact (frame-constant storage edits never run the text view's own
  `viewWillDraw` on 27.0.1 — offscreen probes, 0-vs-2 calls), consistent with the live trace (S4) and with R13's
  in-host green (the long note's rewrite moves the frame); the fix is ONE guarded `needsDisplay = true` at
  `adoptRewrite` (the one tiling-write door), VX-282 R1-2's precedent, never a direct hop; the pin stages the
  interleaving deterministically with `#require`d premises (taken-before-the-rewrite; frame unchanged) so drift
  fails as fixture, never as a hollow green. The wider class is ticketed (VX-702) and the TEXTKIT2_NOTES §3 entry
  drafted (F-FX-2). The trace is fully removed (grep 0 over App + Sources; `strings` 0 per the record).
- **VX-676/675, the wire:** the dial read in the decision's OWN read; `never` decided AFTER the target's read
  decision (an unreadable target answers the ONE not-shared shape under every dial — no oracle; the version arm's
  refusal is `decide(standing, note: nil, …)` over no facts, byte-identical, walk-verified as JSON); the version
  target rides the NOTE's read decision + `isVersionHistory`, never spending; `version_id` with any other target
  refuses pre-read; the schema and descriptions updated (VX-606 held); the answer is fire-and-forget
  (`list_my_activity` maps `show_in_app_offered` back to `show_in_app` with `offered: true`, never lists her take;
  refused rows carry no title at the wire — `entry` gates `title` on `allowed`); `grantsFingerprint` excludes the
  dial's row (no tool re-announce — deliberate and commented); `MCPSession.instructions` 3,061/3,100 (the 3,250
  allowance unused), the pinned never-call clause kept. The reviewer re-ran `MCPShowOfferServerTests` +
  `MCPShowServerTests` + `MCPShowCompareServerTests` headless at the tip: 21/21 green; `MCPGrantOperationsTests`
  17/17 green.
- **VX-676, the app:** the standing slot's lifecycle is exactly the ruling — present at the toast's full prominence,
  the toast's own clock fades only the toast, `clear()` never ends it, the line's ✕ / the take / a newer ask / the
  client's disconnect / the library's close end it (`adoptConnected` runs on the host's report, on `stopServer`,
  on `previewConnected`, so a server stop and a lock end asks too); one ask at a time, doors id-named so an older
  ask's door never acts on a newer one; her take opens through `creationRouter` (her press's rule — never raises a
  window on the agent's side); the two doors are declared in the registry (P-1) and the three line homes gate on
  `lineItem`. Activity rows as ruled (the ask the wire's, the take the app's, a dismissal logging nothing).
- **DA-1:** the mechanism is real in the code (`reconcileServer`'s server-off arm → `stopServer` →
  `adoptConnected([])` → the ask ends — correct door behaviour on the pin's old staging); the repair changes staging
  only (server ON + `previewConnected`), assertions byte-identical plus one non-vacuity line; the live probe held
  the line to +21.5/+25.5 s in both voices.
- **VX-624:** `LandingReach` is read live per look through a closure (never frozen — TEXTKIT2 §3's rule);
  `scrollReported` keeps the boxes' zeros from ever reading as a floor; a floored target still finishes by the
  at-home rules (hold, veto, watchdog); nil-reach surfaces decide byte-identically; the per-surface sweep's SAFE
  rows match the code's own residual clamps.
- **VX-680 + D-2:** the park is a strict one-shot (set only by `carryPlace`'s Outline arm; spent once; dropped by
  focus, collapse, collapse-all, reveal, chapter reveal, block landing, and the Outline leaving); the row-first rule
  is consulted at both decision points from the same sighting; the end-of-landing net re-seeds the row's true top
  and reveals at most once, never after `handedover`; `OutlineBlockSighting.read` honors every TK2 rail (`options:
  []`, `.layoutAvailable` only, no forced layout, no `layoutViewport`, `BlockRangeIndex` read-only, cost ∝ the one
  block + one index pass, target row only while pending).
- **VX-681 / VX-663 / VX-662:** the `.read .flow` arm's fallback-by-nil-default keeps every existing `Place`
  spelling; the carry reads the follower's slot at the switch (the flow clears it after — `switchMode` carries
  first); `adopt(landingAt:)` resolves against the adoption's own entries, outranks the identity re-anchor on the
  first adoption only, drops a foreign place; the carried-reveal arm's `report: true` closes the stale-anchor class
  by W21's own rule while the cold-open seed stays unreported (18d kept).
- **VX-674:** `restingWords` is nil exactly when a name stands (one normalisation, `SavepointRowFace.name`); first
  line only, 160-`Character` cap (never mid-grapheme), no face ellipsis; muted small face with `lineLimit(1)`; the
  open row, the sheet and the phone untouched.
- **VX-572:** the migration keeps her words and reads every chord from its declaration; the ID-level registry walk
  replaces the string guard both ways; the filter and chord reader are correct pure logic (exact modifier set with
  a key, superset for modifiers-only, digit spans, accent/case folding; her folding never overwritten by a search —
  `searchCollapsed` emptied per query); P-8 held (`fixedSize` + `lineLimit` on every chrome text in the new files);
  `HelperView.groups` survives as the one projection for Settings and the older pins.
- **F-FW-2:** `HelperSceneContent`/`HelperThemedRoot` are the other window roots' exact shape (own `ThemeStore`,
  `.environment`, `.task { start() }`, `.id(session)`); `VariorumApp` touched in the ONE helper-window region
  (VX-678's `appDelegate.services` line untouched — verified in the diff); the no-library fallback kept; the pin
  mounts the WINDOW's root, which is exactly why the old face pin was blind (its five tests stay green on the
  revert — said in C7's expectations).
- **Process:** red-on-old discipline held throughout (behavioural-revert products binary-panel-verified to differ
  only in their member; hollow pins recorded and repaired rather than patched — anomaly A; a real defect found
  behind a "pin artifact" suspicion — anomaly B); the hallucination guard honored (D-3/F-B2W-1 deferred to a ticket
  with a stage-trace plan instead of a blind fix); findings-not-fixed lists kept per batch; QUESTIONS/PROVISIONALs
  accumulated for her bundle, no invented product behavior found anywhere in the diff.

— round 1 reviewer (Fable), 2026-10-29
