# Phase 13b — Stage 0(c): the self-driven app-drive inventory

**Session:** 2026-07-20, ~03:05–03:50, Fable (the Brief C auditor).
**Instance driven:** the Debug build at
`~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/Build/Products/Debug/Variorum.app`
(PID 58603, dev store — "Sync off (dev store)" verified in the sidebar footer, screenshot 01).
Binary verified current: no source file newer than the build (batch-14 code).
**Screenshots:** `notes/plans/phase-13b-stage0-screens/` (50 files, numbered in walk order).
**Judging frame:** R111/R112 — usability and visual quality on the app's own terms,
not mockup fidelity. No fixes were made.

**Dev-store mutations made (for re-seed awareness):** one branched take on
"the glass city dream" (2026-07-06) block 1; one quick-entry post
"stage0 audit scratch post" (Untitled, no book). Nothing deleted, nothing archived
(the archive act was environment-blocked; see Reachable vs blocked).

---

## Defect inventory (ranked by how much each would bother a daily writer)

Format: **Dx-N** · repro · what's wrong · screenshot.

### Tier 1 — daily-writer blockers and betrayals

- **AD-1 · ⌘S "commit" is advertised everywhere and does nothing on the default surface.**
  Repro: open any post (it opens in Takes), File→Commit Take (or ⌘S).
  Wrong: before/after captures are PIXEL-IDENTICAL (verified by byte compare) — no
  commit, no refusal, no feedback — while the Takes/Lenses bottom bar prints
  "commit ⌘s" as a live-looking door and the Helper teaches it ("commit — an
  immutable savepoint of the take you're in"). Matrix silent-door #1 confirmed live.
  `10-takes-before-commit.png` / `10b-takes-after-commit.png`, bar visible in both;
  Helper in `36-helper-w1.png`.

- **AD-2 · A 4-take fan shows only 2 takes with NO way to see the rest.**
  Repro: "the night we decided" → Takes (margin grid, 2 high · 1 wide) → open the
  ⑂4 block's fan.
  Wrong: rail header says "takes · 4", exactly TWO cards render (chosen + one),
  then the growth doors — no pager, no "+2 more", no scrollbar, no affordance of
  any kind for takes 3 and 4. Half the fan is invisible and unreachable from the
  flagship takes surface. `30-resized-grid.png`.

- **AD-3 · The structural four are dead keys AND wrong-lecture doors in Takes/Lenses.**
  Repro: in Takes, Block menu → all four (Divide/Extract/Make Block/Merge) are
  `enabled=false` (⌘⇧D/E/K/M are swallowed silently); the bottom-bar "divide" door
  fires a lecture: *"Divide works on selected text in Write (⌘1) — switch there,
  select, and the same door fires."*
  Wrong: R115 violation (lecture-and-redirect instead of fire-and-DO), and the
  lecture's instruction is factually wrong for divide (divide is caret-based, not
  selection-based — the matrix's charge confirmed on screen). Menu state verified
  via AX (`enabled=false` in Takes, `enabled=true` in Write). `37-divide-lecture.png`.

- **AD-4 · Takes archives strand the user: no take door exists on a take card.**
  Repro: right-click any take card in Takes.
  Wrong: the context menu is the STOCK NSTextView menu (Cut/Copy/Paste/Fonts/
  Writing Tools/Spelling) — zero Variorum vocabulary: no archive, no choose, no
  label, no lock, no delete. Combined with fans being active-only in the rail
  (matrix ranked-list-3 #2), ⌘⇧A archiving a take makes it vanish with no visible
  recovery on this surface. (The archive act itself could not be completed live —
  see Reachable vs blocked — but the missing doors are directly observed.)
  Menu enumerated via AX; capture context in `18-card-context-menu.png`.

- **AD-5 · D1 live: an expanded book card can never be re-collapsed by its own toggle.**
  Repro: orbit book → press "the night we decided" card (expands, body renders) →
  press the same card again.
  Wrong: PIXEL-IDENTICAL before/after (byte compare) — the toggle no-ops, exactly
  the D1 mechanism (the card press evidently focuses the post; the force-expand
  disjunct then pins it). "collapse all" DOES collapse it — the asymmetry proves
  the per-card door is the broken one. `22-card-expanded.png` /
  `24-card-collapsed.png` (identical) / `25-collapse-all.png` (works).

### Tier 2 — layout and spacing defects (the D2 family)

- **AD-6 · D2 live: margin grid shifts the whole article + masthead left ~118pt.**
  Repro: same post, Takes style stack → margin grid (via Settings "Takes open as").
  Wrong: article left edge moves from ~x705 to ~x538 (displayed px; masthead moves
  with it), the reserved right rail sits EMPTY until a fan opens; Write and stack
  agree with each other, margin grid disagrees with both. Compare
  `08-post-write-mode.png` (stack) / `09b-write-via-menu.png` (write) vs
  `12-takes-margin-grid.png`.

- **AD-7 · The margin-grid article cell balloons into a mostly-empty grey slab.**
  Repro: open any fan in margin grid with wash on.
  Wrong: the washed block cell reserves the full 2-high grid height — with 1–2
  takes, ~2/3 of a ~430px cell is empty grey below ~150px of text. This is the
  most likely mechanism behind the author's "suspicious inter-block vertical gaps"
  report. `14-fan-door-pressed.png` (1 take), `30-resized-grid.png` (4 takes).

- **AD-8 · Margin comments render clipped UNDER the sidebar; invisible at normal widths.**
  Repro: "the night we decided" in Takes at a wide window (1600pt) — a comment
  ("// verify this date against the log") appears at the far left, HARD-CLIPPED by
  the window/sidebar edge ("verify this date / ainst the log"); at the default
  1422pt width the same comment is entirely hidden.
  Wrong: the comments margin column is laid out in space the sidebar owns — the
  R110 "comments visible in the left margin" surface is invisible or half-clipped
  at real window sizes. `30-resized-grid.png` (left edge), absent in earlier
  same-post captures at 1422pt.

- **AD-9 · Takes-at-rest inter-block gaps are ~3-4× Write's paragraph gaps.**
  Repro: same post in Write (⌘1) vs Takes (⌘2), no fans open.
  Wrong: the collapsed takes article inserts a tall "⑂ +" rail row between blocks;
  the calm-prose read is broken by large vertical voids (the author's gap
  complaint, second mechanism). Compare `08-post-write-mode.png` vs
  `09b-write-via-menu.png`.

- **AD-10 · Take cards hard-clip text mid-word with no fade/ellipsis/see-more.**
  Repro: any take card in the margin grid rail.
  Wrong: cards cut at fixed height mid-line ("though the morning may" → raw cut);
  AX reports the card TextAreas laid out at 403pt inside ~100pt frames. Reads as a
  rendering bug rather than a design. `15-branched-take.png`, `30-resized-grid.png`.

- **AD-11 · Canvas opens with every card overlapping in one pile.**
  Repro: any post → Canvas (⌘7), first open.
  Wrong: all 7 block cards spawn at the same x, vertically overlapping — each card
  covers the previous card's last lines; nothing suggests they're draggable/
  arrangeable. Also the filter popup reads "All scraps" on a POST canvas — pool
  vocabulary on the wrong surface. `35-canvas.png`.

### Tier 3 — capability confusion and crowding (D4 class)

- **AD-12 · Two near-identical ✓ glyphs mean different things on adjacent cards.**
  The chosen card wears "✓ chosen" (state) AND a corner ✓; the non-chosen card
  wears ONLY a corner ✓ (the choose ACTION) with an otherwise-empty header. State
  and action share a glyph one card apart. `15-branched-take.png`.

- **AD-13 · The Write bottom bar wraps under crowding; its acts grey while it names
  a current block.** At 1422pt the Write bar's "date:" item wraps into a stacked
  two-line fragment breaking the baseline; the same bar says "blk 3/3 · 023ee55c ·
  88w block" (a current block exists) while divide/extract/make block/merge/takes
  sit greyed — the bar simultaneously asserts and denies a current block.
  `09b-write-via-menu.png`.

- **AD-14 · Refusal quality is inconsistent door to door.** "history" with no
  focused take speaks correctly ("Click into a take first — History shows that
  take's savepoints"); "+ take" speaks the BLOCK MENU's copy ("…the block menu acts
  on the block you're in" — nothing about takes); ⌘S and expand-all say nothing at
  all; the refusal line, once shown, never auto-dismisses (it survived multiple
  later interactions and a fan expansion). `39-refusal-strip.png`,
  `38-plus-take-nofocus.png`, `16-archive-no-focus.png` (message placement also
  pushes the whole article down rather than overlaying).

- **AD-15 · "expand all" no-ops on single-take blocks that the per-block door opens.**
  Repro: glass city dream (three 1-take blocks) → "expand all": zero change, no
  message; pressing a block's ⑂ opens that same single-take fan fine.
  Wrong: either expand-all should open them or the door should be gated/dimmed
  (the ratified "offered only where meaningful"); live-looking + silent is the
  worst combination. `13-margin-grid-expanded.png` (after expand-all: nothing).

- **AD-16 · The ⑂ and + margin doors are ONE fused hit target.** AX shows a single
  button described "⑂ +" per block — two different acts (open fan / mint take)
  share one click target; on fanned blocks the + disappears entirely ("⑂4"), so
  the quick-mint door exists only where you need it least. Tree evidence in the
  session log; visible in `08-post-write-mode.png` etc.

- **AD-17 · Quick-entry mints land you in Takes, titled "Untitled".**
  Repro: shelf quick-entry → type text → ⏎.
  Wrong: the promise is "just start typing", but the minted post opens in TAKES
  (typing does nothing there — "click into a take"); masthead reads "Untitled / in
  no book". The one flow the shelf optimizes for (capture a thought, keep typing)
  requires a manual ⌘1 to continue. `41-quickentry-minted.png`.

- **AD-18 · Mode-to-mode chrome inconsistency.**
  (a) Lenses/Compare/Outline/Blocks embed STOCK Aqua controls (white "Duplicate as
  Version" capsule, "Choose a post…"/"Choose the outline…" popups, checkbox,
  square ↑↓ buttons) inside the voiced terminal chrome — two design languages on
  one screen (`31-lenses.png`, `32-compare.png`, `33-outline.png`,
  `34-blocks-mode.png`). (b) The bottom bar exists in Write/Takes/Lenses, is
  ABSENT in Compare/Outline/Blocks/Canvas and the book view — the ⌘k advice line
  comes and goes surface to surface. (c) A single Lenses column runs the full
  window width (~200-char lines) while Write holds a ~680pt measure
  (`31-lenses.png`). (d) A permanent two-line explainer paragraph rides above the
  Lenses bar (`31-lenses.png`).

- **AD-19 · Shelf header crowding/ambiguity.** "today's entry + new book" reads as
  ONE phrase; they are two separate buttons ("today's entry", "+ new book") with
  no visual separation. `01-launch-dev-window.png`.

- **AD-20 · Library polish nits.** Journal rows print the date twice (title =
  date + date column); the add-to-book door is an unlabeled circle-arrow glyph;
  shelf lowercases book titles while Library title-cases the same books; the
  palette clips its last visible row mid-height and prefixes every command with a
  meaningless ⌘ glyph. `03-library.png`, `06-palette-open-w1.png`.

- **AD-21 · Book card "expanded" state keeps the excerpt card fully visible above
  the body** — the first paragraph appears twice in a row (excerpt then body), and
  the disclosure triangle still points ▸ (collapsed) while expanded.
  `22-card-expanded.png`.

- **AD-22 · Settings is entirely stock Aqua** — no voice styling anywhere
  (`11-settings.png`). Defensible as macOS convention; recorded for the registry
  discussion since every other chrome surface is voiced.

### Positive contrasts worth keeping (for the P-1 registry)

- Archive-with-no-focus SPEAKS a correct, specific refusal ("Click into a take
  first — ⌘⇧A archives the take you're in") — `16-archive-no-focus.png`.
- The ⌘K palette finds posts instantly and ⏎ opens them (`07-palette-search-w1.png`).
- The reading-flow view is calm and handsome (`26-reading-flow.png`).
- The shelf quick-entry does mint-and-open in one gesture (`41-quickentry-minted.png`).
- Mode switching via ⌘1–⌘7 and the sidebar rail buttons works when a post is open.

---

## Reachable vs blocked

**Environment:** the session was screen-LOCKED for most of the audit
(`CGSSessionScreenIsLocked=1` verified at 03:11; unlocked sometime around ~03:33 —
traffic lights turned colored; fully unlocked by the 03:47 check). Under lock:

- **Worked:** window-targeted `screencapture -l` (all captures); the AX tree
  (after a warm-up flake); AXPress on buttons/menu items/menu-bar items; AXSelected
  on sidebar rows; AXValue+AXConfirm on text fields (palette, quick-entry);
  keyboard events via `CGEventPostToPid` (⌘1–⌘7 verified working).
- **Blocked (with consequences):**
  - **Synthetic mouse clicks and scroll wheel never delivered** (SwiftUI tap
    gestures need real key-window hit-testing). Consequence: could not
    click-to-focus a take card or a post body → could NOT complete the
    ⌘⇧A archive-a-focused-take + recovery hunt, could not provoke D1's
    body-focused variant (the card-press variant DID reproduce), could not mount
    the live editor anywhere, could not scroll (worked around with AX window
    resize).
  - AX position hit-testing (`AXUIElementCopyElementAtPosition`) returned
    kAXErrorCannotComplete (-25204) under lock.
  - SwiftUI word-menus (style:/block ▾/post actions ▾) and the take-card
    AXShowMenu popup would not open via AX under lock — the style switch was
    executed through Settings' "Takes open as" popup instead (which worked).
  - System Events (osascript) saw 0 windows for the app throughout — driving was
    done with a direct ApplicationServices tool instead. My one JXA attempt
    segfaulted (osascript crash report 03:11, in DiagnosticReports — harness-side,
    not the app).
- **No author-ask TCC errors:** Accessibility was granted (`AXIsProcessTrusted()
  = true`); screen capture worked. No literal permission-error text was ever
  produced, so nothing needs granting for a repeat run — but a repeat run in an
  UNLOCKED session would unlock the blocked items above (real clicks would work).

**INCIDENT — the author's real-store app exited during the audit window.**
At 03:05 `pgrep` showed PID 49686 (`/Applications/Variorum.app`) running; at
03:24 its windows were still enumerable (including an open Settings "Appearance"
window); by 03:27 the process was gone. Evidence of non-involvement: every event
this session posted was addressed to PID 58603 exclusively (`CGEventPostToPid`,
`AXUIElementCreateApplication(58603)`); no event, Apple event, or signal ever
targeted 49686; `open` commands used the DerivedData path only. There is NO
Variorum crash report in `~/Library/Logs/DiagnosticReports` for the window, and
unified-log queries for the exit returned nothing (heavily filtered). Cause
unknown — possibly system-initiated (memory pressure/idle under the locked
session) or the author's own action if she was present. **Author action: relaunch
/Applications/Variorum.app when next at the machine.** The store is WAL-safe by
design; no data risk is expected.

---

## Matrix confirmations (predicted worst cells reproduced live)

| Matrix cell | Live result |
|---|---|
| Ranked-1 #1 — ⌘S silent outside Write while advertised | **CONFIRMED** — pixel-identical before/after (`10`/`10b`), bar + Helper advertise it |
| Ranked-1 #3 — structural ⌘⇧D/E/K/M dead keys in Takes | **CONFIRMED** — Block menu items `enabled=false` in Takes via AX |
| Ranked-1 #4 — ⌘1–⌘7 enabled with no post open, do nothing | **CONFIRMED** — View→Write on Library: no change (`05`) |
| Ranked-1 #6 / D1 — book card collapse no-op | **CONFIRMED (card-press variant)** — second press pixel-identical; collapse-all works (`22`/`24`/`25`) |
| Ranked-2 #1 — Takes bar structural four lecture, wrong for divide | **CONFIRMED** — lecture text captured, says "selected text" for caret-based divide (`37`) |
| Ranked-3 #2 — takes archive strands (no unarchive/see-archived in Takes) | **CONFIRMED at door level** — stock context menu, no take vocabulary anywhere on the surface; archive act itself blocked by environment |
| Cross-cutting D2 corroboration — margin-grid left shift | **CONFIRMED** — ~118pt article+masthead shift (`08` vs `12`) |
| Ranked-3 #1 — no + block door in Takes/Lenses | **Not directly provoked** (needs typing), but no such door was visible anywhere on the Takes board/bar during the whole drive — consistent |
| Helper teaches dead keys with no caveat | **CONFIRMED** — `36-helper-w1.png` |

New findings NOT in the matrix's ranked lists: AD-2 (2-of-4 takes with no pager) —
arguably the worst single discovery of the drive; AD-7 (grey slab reserve); AD-8
(comments clipped under the sidebar); AD-10 (mid-word card clipping); AD-11
(canvas overlap pile + "All scraps" mislabel); AD-12 (✓ state/action collision);
AD-14 ("+ take" borrows block-menu refusal copy; refusals never dismiss); AD-17
(quick-entry lands in Takes); AD-21 (expanded card keeps excerpt + stale ▸).
