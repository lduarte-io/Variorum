# VX-562 — Book Outline: the highlight follows your scroll, and the book's nav info pins up top

**STATUS: OPEN — kicked off 2026-10-27 (architect-phase, wave 2; coordinator `oct27coordinator`).**
Ticket: VX-562 (single ticket — Improvement · Confirmed · Books · High · Pre-launch; project "v1 release readiness") · Branch: `vx-562-outline-follow` · Worktree: `~/dev/variorum-vx-562` (the Pro).

**Her kickoff words (2026-10-27, verbatim):** *"VX-562 contact oct27coordinator for your walk + staging needs"* — the wave-2 shape: stage traffic through the coordinator only (REQUEST → READY → GO; never self-claim), no `/Applications` refresh and no release without her word, PROVISIONAL-and-continue with every question bundled for her morning.

**Her design rulings (already on the ticket, verbatim):**
- The follow rule (2026-10-26 planning session): the outline's highlighted chapter/note follows what you're VIEWING as you scroll — *"maybe not [highlight the one you're typing in], it just follows what your view is."* The caret is ignored.
- Pre-launch at her own written word (the 10-21 improvements note): *"make the note that you're currently on highlight on the left bar ABSOLUTELY pre launch."*
- The pin's content (same note): the navigation info (number of chapters and notes) stays fixed at the top while scrolling (a beta ask she liked), widened by *"show during scroll what # note you're in, maybe what chapter you're in."*
- Scope guard (the ticket): VX-300 keeps the editing-parity scope; this ticket is ONLY the two pieces above. Viewport→block→note mapping exists (block IDs ride the text), so cost stays viewport-proportional (P1).

**Cast:** Fable architect/orchestrator (this session) · `opus-implementer` (xhigh), fresh per batch · the cold reviewer decided by the diff at ladder time — `fable-reviewer` if the diff touches the editor seam / read tier internals (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the one measurement brain), `opus-reviewer` if it stays in book-view chrome and a read-only geometry consumer. Pin-before-fix per the hallucination guard; the ladder over the whole diff.

**Not in this effort (rider candidates, offered — never seated without her word):** VX-96 (Book Outline: reveal-without-focus roads keep the title-over-blank beat — Bug · Confirmed, this exact surface) · VX-616 ("+ new chapter" renders on a gathering's navigator foot — a door that can never act — Bug · Confirmed) · VX-563 (a keyboard way to navigate the in-note book view — Improvement · Confirmed, adjacent to the follower). Bundled in §MORNING BUNDLE.

---

## THE BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied byte-verbatim per the architect-phase skill; binding on every batch)

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

**Application notes that bind the same way (the skill's precisions):** P-1's scope is the ROUTED vocabulary, grown incrementally — surface-local doors that already work are not retro-declared wholesale; acts whose only doors are inline declare `.surface`, never mis-file under `.contextMenu`. The FULL-DOCUMENT editor is never absorbed into the pane surface; both surface kinds consult the ONE authority. Storage-coupled code lives feature-side, never in shared `Registry/`/`Surface/` layers. Every equality-gated sink delivers its stored state AT WIRE TIME, and overlay geometry refreshes trigger on every input axis (storage edits, width reflows, AND the first post-layout display pass) — state computed before layout exists is garbage that equality gates then freeze. The closing form for a recurrence of a fixed class is the sweep table: instance × host/path, each cell FIXED-with-named-pin or provably SAFE with the mechanism stated.

---

## DESIGN (the architect's, from the recon + the VX-75/VX-92 records; line numbers as of branch base `ba6bdf3eb` — verify at build time, never trust blind)

### The surface, as read

- `BookView.body` (BookView.swift:252, "BV") is `SideColumn { mode body } panel: { navigator }`; the navigator (BV:709–1004) renders in every non-Index mode and is `ScrollViewReader { VStack { bookMasthead; ScrollView { chapter rows + note rows }; foot doors } }`.
- `case .outline:` (BV:301–313) is `VStack(spacing:0) { BookArchivedLine; outlineBody }`; `outlineBody` (BV:1774–2067) is ONE SwiftUI `ScrollView` (coordinate space `BookView.outlineSpace = "book-outline-scroll"`, BV:1580/1974) holding a VStack of `BookOutlineRows.Segment`s — `.run([Row])` small rows (`OutlineRunRow`, BV:2614; far rows `Color.clear` at manifest height) and `.expanded(entry)` notes (`OutlinePostRow`, BV:2672). Row IDs are the landing anchors: `chapter-<sectionID>` · `page-<postID>` · `unfiled` · `path-<n>` (BookOutlineRows.swift:36–49).
- **Every realized row already reports `OutlineAnchorGeometry { top, height }` in `outlineSpace`** → `BookView.outlineAnchorMoved` (BV:1628), kept in the reference box `OutlineLandingBox` (BV:1535 — a reference type precisely so geometry bookkeeping never re-lays-out the lazy column). Its existing `topRow` rule (first row with `top >= -tolerance`) is the WRONG rule for a follower (a tall story spanning the viewport top is skipped); the follower needs **"the last anchor whose top ≤ probe."**
- The navigator highlight today is `navigatorMarks(entry)` (BV:2254): `model.focusedPostID == entry.postID || (mode == .spread && isOnSpread)`. `focusedPostID`'s only writer is `BookViewModel.focus(_:caret:fanBlock:)` (BookViewModel:1012), which ALSO seeds the caret and the live editor — **focus is welded to the live-editor authority, so the follower must never write it.** Multi-note chapter rows have no highlight today.
- The nav info today is `bookMetaLine` (BV:2303 → `BookViewCopy.metaLine`, BV:3185 — "book · N chapters · M notes · …"), rendered INSIDE the ScrollView's title block (BV:1783–1804), so it scrolls away. The sidebar note box's "chapter · N of M in this book" wording brain is `NoteBoxCopy.whereLine` (Core/Views/NoteBox.swift:170) — focus-driven, not view-driven.
- Landing machinery: `LandingAuthority` (`Surface/LandingAuthority.swift`; `landing.land/end/userTookOver/isPending`), `landOutline` (BV:1607), user takeover via `.onScrollPhaseChange` (BV:1990). VX-96's pre-mount arm (`outlineRowPreMounts`, BookViewModel:605) is adjacent machinery the follower must not touch.

### The mechanism (both pieces ride ONE new read-only slot)

**1. The viewed pair.** A pure, unit-tested rule — *given the anchor geometries `[(id, top, height)]` and a probe offset (the viewport's top edge + a small ε), the viewed anchor is the LAST anchor whose `top ≤ probe`; resolve it through `BookOutlineRows` to `(viewedSectionID?, viewedPostID?)`* — a `page-` anchor names the note (and its chapter); a `chapter-` anchor names the chapter alone; above the first anchor both are nil. The rule is monotonic and handles a tall expanded story spanning the viewport (its top ≤ probe while the next anchor's top > probe). It lives app-side (view geometry, never Domain — the layer-placement note). The bookkeeping extends `OutlineLandingBox` (stays a reference box, the row-53 lesson); the derivation coalesces to one publish per run-loop turn and **publishes only CHANGES of the derived pair** (equality-gated — and per the wire-time law, the box delivers its current pair at wire/mount time and recomputes on EVERY input axis: scroll reports, width reflows, expansion/collapse, the first post-layout pass, landing end).
- **Freeze while `landing.isPending`** (a programmatic travel must not flicker the highlight through intermediate rows); on the landing's end deliver the settled pair. User takeover (`onScrollPhaseChange`) unfreezes.
- The slot is `private(set)` on `BookViewModel` (e.g. `viewedOutlinePair`), written by the box's publish, read-only everywhere else. **It never touches `focus`, `pendingReveal`, the caret, or the landing's aim.** P1: O(1) per report, one O(anchors) scan per coalesced turn, anchors ∝ the book's rows — viewport-proportional cost unchanged.

**2. The follow-highlight (ledger 1).** In `.outline` mode `navigatorMarks(entry)`'s note-row term becomes *the viewed note* (`viewedPostID == entry.postID`) — her ruling: the caret is ignored, the highlight follows the view. Chapter rows (BV:753 family) gain a quieter viewed-chapter mark (token wash/ink per voice — no literal colour; `Theme/VoiceControls.swift` vocabulary). Every other mode's marks stay byte-identical (`.spread` keeps its term; Index has its own column and is untouched). The sidebar note box stays focus-driven (it IS the focused note's controls — not this ticket's surface).
- PROVISIONAL P-562-1: the navigator does NOT auto-scroll to keep the viewed row in view in v1 (most navigators fit on screen; the Open list's follow idiom is the obvious extension) — bundled for her.
- PROVISIONAL P-562-2: the follow runs in OUTLINE only (the ticket's name and her sentence). The same navigator shows in Book/Read flow modes, where no place-highlight exists today; extending the follower to the flow's `flowAnchor` reports is a natural follow-up — bundled, not built.

**3. The pinned nav info (ledger 2).** A pinned header lands as a SIBLING ABOVE `outlineBody` in the `.outline` VStack (BV:307–310) — never inside the ScrollView (the landing math measures anchor tops in `outlineSpace`; a header inside the scroll content would shift every top — the Index file's archived-line convention argues sibling-above, and it keeps `safeAreaInset` questions moot). Content, one line, muted, chrome-vocabulary: the meta counts (`BookViewCopy.metaLine` — N chapters · M notes) **moved up from the scrolling title block** (no duplication), then, when the viewed pair resolves, the position — "note N of M" and the chapter's name — composed through ONE wording brain beside `NoteBoxCopy.whereLine` (reuse or a sibling pure function; one brain, two readers). `lineLimit` on every fixedSize text (P-8, the b6dae25 class).
- PROVISIONAL P-562-3: the meta line MOVES to the pin (the scrolling title block keeps the title + expand/collapse doors); the position segment appears whenever a viewed note resolves, with no at-rest suppression. Taste call bundled.
- PROVISIONAL P-562-4: the chapter segment shows only in a chaptered book (her "maybe what chapter you're in" honoured as: present when chapters exist, absent otherwise).

### Evidence (the acceptance unit's kinds)

- The pure rule: table-driven unit tests (spanning story · at-top nils · between chapters · unfiled · empty book · probe ε edge).
- Mounted: the `BookOutlineLandingTests` scaffold (the `.serialized` mounted-BookView suite with pump/settle/anchorTop helpers) — land on a far story, assert the viewed pair + the navigator mark + the pin's words at settle; assert freeze-during-landing (no intermediate pair published while `isPending`); assert the pin header sits OUTSIDE the scroll content (first anchor's top unshifted against the pre-change value, or the landing suites' continued green as the guard). HARNESS FACT (18l-c U8, TEXTKIT2 notes): a synthesized scroll wheel does not move a SwiftUI ScrollView in the test host — drive the viewport through the landing/reveal doors or feed the box synthetic geometry; never a CGEvent scroll.
- New-capability tests are born-red-then-green by nature; the red-on-old pin discipline binds any BUG found along the way (traced mechanism, red pin, behavioral revert).
- The walk (ledger 3): the seeded sherlock in Outline — scroll continuously, capture the navigator highlight walking the stories and the pin's "note N of M · chapter"; a navigator click (landing) shows no flicker-through; store untouched, nothing added.

### The one batch (ONE acceptance unit, ONE fresh `opus-implementer`)

Both ledger pieces in one session — the pin consumes the follower's slot, so splitting would manufacture a seam. The implementer brief is §BATCH BRIEF below. Mounted suites run ONLY at the orchestrator's stage window (REQUEST → READY → GO through `oct27coordinator`); the implementer iterates headless (`swift build`, `xcodebuild build-for-testing`) and hands the suite list to the orchestrator.

## LEDGER

| # | Item | Status |
|---|---|---|
| 1 | The follow-highlight: the Outline navigator's highlighted chapter/note follows the viewport as the content scrolls (the view, never the caret) | NOT-STARTED — design §DESIGN pieces 1+2, batch 1 |
| 2 | The pinned nav info: chapters + notes counts fixed at the top while scrolling; the current note # (and chapter) said during scroll | NOT-STARTED — design §DESIGN piece 3, batch 1 |
| 3 | The walk (Opus walker, seeded sherlock, store left as found) + the test batch under coordinator GO | NOT-STARTED |
| 4 | The ladder (one round minimum; reviewer per the diff — expected `opus-reviewer`: no editor seam, no custody, no `Sync/`) | NOT-STARTED |

## LIVE STATUS (batch 1 — the implementer's; flipped in the same commit as each piece)

Implementer: a fresh `opus-implementer`, 2026-10-27. Preflight read in full, in my own context: this record, `notes/SurfaceContracts.md` §The Bookcase and books, the VX-75 and VX-92 records, `notes/TEXTKIT2_NOTES.md` §3, `notes/SessionResiliencyProtocol.md`; every §DESIGN coordinate re-verified against the tree (no `App/` change since base `ba6bdf3eb`; the line numbers stand).

- **DONE (this commit) — A. The pure rule + the wording brain.** `Features/BookView/BookOutlineViewed.swift` (nonisolated: the last row in column order whose top ≤ the probe — `probe` = the column's 10-pt row gap, ≥ the landing's 2-pt tolerance; resolved in ONE pass through `BookOutlineRows` to the pair, the chapter being the heading in force above the row; the viewed note's column ordinal; the pin's position words) + `BookNavigatorMark` (the one per-mode mark table) + `NoteBoxCopy.viewedLine` beside `whereLine` (the place and chapter pieces factored out and shared — `whereLine`'s output byte-identical, its pins unchanged); table tests `VariorumTests/BookOutlineViewedTests.swift` (13 tests). `build-for-testing` GREEN (`DerivedData/vx562-bft1.log`). Tests PENDING the orchestrator's stage window.
- **DONE (this commit) — B. The slot + the box.** `BookViewModel.viewedOutlinePair` (`private(set)`, written only by `noteOutlineViewed(_:)`, equality-gated against the slot itself — the wire-time law); `OutlineLandingBox.rowTops` written per report in O(1) from `outlineAnchorMoved`, ONE derivation queued per run-loop turn (`queueViewedPair` → `deriveViewedPair`, static over box/landing/model/structure so no closure holds the view); the derivation runs only in `.outline` and is FROZEN while `landing.isPending`; `landOutline` wires `landing.onFinish` to deliver the settled pair at the landing's end (her scroll's `userTookOver` ends it too); re-derived on the entries, sections and expansion axes and at the Outline's `onAppear`; `forgetViewedPair()` at its `onDisappear`. `outlineRows` gained a static twin over the two models. Never writes focus, the caret seeds, `pendingReveal` or a landing's aim. `build-for-testing` GREEN (`vx562-bft2.log`; the two `outlineSpace` Sendable warnings are the base tree's own).
- **DONE (this commit) — C. The follow-highlight.** `navigatorMarks` retired into `BookNavigatorMark` (piece A), read by two small label views — `NavigatorNoteLabel` (marker + title ink) and `NavigatorChapterLabel` (grip, name, a one-note chapter's note marker, and in `.outline` the QUIETER viewed-chapter wash: `tokens.wash` at the masthead popover's 0.55 resting strength, cornerRadius 6, reaching `BookNavigatorLayout.washBleed` = 6 pt past the row) — so a pair change re-renders the marks, never `BookView`'s body. The wash's room: the list's content steps in 6 pt and its scroll steps out 6 pt (every row's text and frame unmoved; the clip and scroller move outward by 6). Every other mode's marks byte-identical. DEBUG oracle: `BookOutlineGeometry.navigatorChapterMarks` / `.navigatorNoteMarks` (owned, released with the book).
- **DONE (this commit) — D. The pinned nav info.** `OutlinePinnedLine` — a sibling between `BookArchivedLine` and `outlineBody` in the `.outline` VStack (below the archived line, as the count line always sat), on the prose column's measure and left edge, one muted `small` line (`lineLimit(1)`, tail truncation), the archived line's hairline below it. Content `BookViewCopy.outlinePinLine(meta:position:)`: the count line MOVED out of the scrolling title block (the title row keeps "expand all" / "collapse all", its height unchanged — the doors were already its tallest members), then `BookOutlineViewed.positionLine` (rows read only while a pair is viewed). DEBUG oracle: `BookOutlineGeometry.outlinePinLines` / `.outlinePinFrames` (global rect). `build-for-testing` GREEN (`vx562-bft3.log`).
- **DONE (this commit) — E. Mounted pins** (an extension in the `BookOutlineLandingTests` scaffold, the `.serialized` suite): `theNavigatorFollowsWhatThePageShowsNeverTheCaret` (rest ⇒ nothing viewed, the counts pinned; a live long story + a reveal elsewhere ⇒ at the landing's end the pair is the target's, focus untouched, the target note marked and the caret's note NOT, the target's chapter washed and the caret's not, the pinned line's words, the pinned line's frame unmoved across the travel, and leaving for the spread clears the pair and the wash); `aLandingHoldsTheFollowerStillUntilItEnds` (every turn from the second reveal to its `DONE` samples the pair — it must not move; then the settled pair and words); `herOwnScrollMovesTheFollowerWithNoLanding` (a programmatic clip scroll — the Library infinite-scroll pin's road, never a wheel — then the pair checked against THE RULE over the geometry oracle's tops, scrolled again and checked to move forward). `Pair.none` renamed `Pair.nothingViewed` (no `Optional.none` reading can make an `#expect` vacuous). `build-for-testing` GREEN (`vx562-bft4.log`; the only warnings in touched files are the base tree's own four). All PENDING the orchestrator's stage window.
- **NOT-STARTED — F. Close.** Headless `build-for-testing` green, ledger rows 1–2 → BUILT-PENDING-SUITES, §IMPLEMENTER SELF-ASSESSMENT, the suite list for the orchestrator's stage window.

No revert is in flight. No mounted suite has run (never mine to run).

## BATCH BRIEF (batch 1 — the whole unit; a fresh `opus-implementer` at xhigh; this section is the brief, self-contained)

You are the implementer for VX-562 in the worktree `~/dev/variorum-vx-562` (branch `vx-562-outline-follow`; run EVERYTHING from this absolute path). One batch = this whole record's §DESIGN, both pieces.

**Read first, in this order, in full:** this record file (`notes/plans/fixes/vx-562-outline-follow.md`); `notes/SurfaceContracts.md` §The Bookcase and books; `notes/plans/fixes/vx-75-book-outline-first-edit-flash.md` and `notes/plans/fixes/vx-92-outline-swap-stability.md` (the surface's two governing priors — the swap seam, the placeholder road, the landing machinery, the harness lessons); `notes/TEXTKIT2_NOTES.md` §3's macOS-27 measured findings and harness facts (the U8 scroll fact binds your tests); `notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds you from the first commit). CLAUDE.md's auto-loaded canon you already have.

**Build exactly §DESIGN:** the viewed-pair slot (pure rule + `OutlineLandingBox` bookkeeping + the `private(set)` publish on `BookViewModel`), the `.outline` navigatorMarks change + the chapter-row mark, the pinned header sibling-above with the moved meta line + the position words through one wording brain. The four PROVISIONALs (P-562-1…4) are decided — build them as written, do not re-open them. Line numbers in §DESIGN are from base `ba6bdf3eb`: verify every coordinate against the tree before editing.

**Hard fences:** never write `focusedPostID`/`focus()`, `pendingReveal`, the caret seeds, or the landing's aim from the follower. Do not touch `EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `ReadPostView`'s internals, `outlineRowPreMounts`, or anything under `Sources/VariorumCore/Sync/` — if the trace genuinely pulls you toward the editor seam, STOP and report to the orchestrator instead. No new dependencies. No literal colours (tokens only); chrome text per `Theme/VoiceControls.swift`; every `fixedSize` chrome text carries a `lineLimit`. Sentence case in all rendered copy, no shouty caps. No schema, no migrations.

**Tests:** the pure rule's table tests + the mounted assertions per §DESIGN Evidence. You may run `swift build` / `swift test` (core) and `xcodebuild -scheme Variorum -destination 'platform=macOS' build` / `build-for-testing` from `App/Variorum/` freely (headless). **You may NOT run `xcodebuild test` yourself — every mounted suite run happens at the orchestrator's stage window.** End your batch by handing the orchestrator: the suite list to run (suite-level `-only-testing` args), the expected pass shape, and any suites whose CHANGED SOURCE files they exercise (grep the tests for the changed types — the closeout rule).

**Process:** commit per coherent piece with honest messages, push after every commit, NO attribution trailers. Maintain this record's LIVE STATUS section (add it under the ledger) from your first commit: per-piece `DONE (hash)` / `IN-PROGRESS — what remains` / `NOT-STARTED`, every unverified claim marked PENDING. Synchronous foreground waits only (poll logs with a `grep -q … && break; sleep 5` loop; never background a run you must act on; never end your turn waiting). No subagents except at most ONE Sonnet, read-only, for EXTERNAL facts only. The environment traps section at the end of this file binds verbatim. When the build is done and headlessly green: flip the ledger rows to BUILT-PENDING-SUITES, write your self-assessment (what you built, risks, what you'd want a reviewer to stare at) as §IMPLEMENTER SELF-ASSESSMENT, commit, push, and END with a short report — do not start the walk, the suites, or the ladder.

## MORNING BUNDLE (for her — PROVISIONALs, riders, taste calls; grows as the run proceeds)

- **Riders offered (cheapest while this code is open; none seated without your word):** VX-96 (Low — this exact surface: hold the pre-mount arm for the landing's lifetime) · VX-616 (Low — "+ new chapter" on a gathering's navigator foot, a door that can never act) · VX-563 (Medium — a keyboard way to navigate the in-note book view; adjacent to the follower). Say the word and any of them seats as a member.
- **P-562-1 (PROVISIONAL, built):** the navigator does not auto-scroll to keep the viewed row visible in v1. The obvious extension is the Open list's follow idiom (follows on your next act; a hand scroll stops the follow) — want it?
- **P-562-2 (PROVISIONAL, built):** the follow runs in Outline only. The same left navigator shows in the Book/Read flow modes, where no place-highlight exists today; the flow has the same anchor reports, so extending the follower there is a bounded follow-up — want it (now, as a ticket, or not)?
- **P-562-3 (PROVISIONAL, built):** the "book · N chapters · M notes" meta line MOVES from the scrolling title block into the pinned header (no duplication); the "note N of M · ‹chapter›" segment shows whenever a viewed note resolves, with no at-rest suppression.
- **P-562-4 (PROVISIONAL, built):** the chapter name shows in the pin only when the book has chapters.

## ENVIRONMENT TRAPS (carried verbatim into every batch brief)

Instance checks use `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the looser pattern matches builds) plus `xcrun simctl list devices booted`; treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications refreshes while one lives. `xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line (Swift Testing's count INCLUDES skipped tests — read the `skipped:` lines); zsh `pipestatus`; NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles). EVERY `xcodebuild test` run needs the stage — and the stage comes ONLY as the coordinator's GO (REQUEST → READY → GO; a FREE stage is never an invitation); headless `swift build`/`swift test`/`xcodebuild build|build-for-testing` never needs it. The dev store is library e11e5233, HELD since 10-20, signed out, Study — NEVER press Resume (one press consumes the hold); restore the store exactly as found; walk content to the Trash or removed, and say which. After every Debug launch, dismiss a What's New sheet if one shows. Backups WAL-safe with UTC names into `Backups/safety-copies/`, always before touching the real store (the A1 rail). Never `git checkout` over uncommitted work; commit per piece, push after every commit; never force-push or rewrite pushed history. Commits carry NO attribution trailer (her standing rule). The resiliency protocol binds: LIVE STATUS from the first commit, synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`), no subagents from the implementer (one Sonnet read-only external-facts agent at most).
