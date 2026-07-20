# Phase 13b — Stage 0(b): The Capability Matrix

**Status:** COMPLETE (read-only audit, 2026-07-20). Auditor: Fable (Stage 0(b) agent).
**Method:** every claim below was read from the code, with file:line evidence. No
builds, no launches, no fixes. Paths are relative to
`App/Variorum/Variorum/` unless prefixed (`Shared/`, `Sources/`).
**Scope:** acts × surfaces per the Brief B enumeration; full end-to-end readings
for the editing modes (Write / Takes / Lenses) × structural + takes acts;
door-exists/gated level elsewhere.

**Legend per cell:** *Door* (where it is) · *Fires?* (does invoking do anything) ·
*Speaks?* (does a refusal/outcome surface) · *Gated* (to what) · *Works?* (does it
complete the act end-to-end per the code).
Verdict shorthand: **WORKS** · **SILENT** (fires nothing, says nothing) ·
**LECTURE** (speaks a redirect instead of acting — R115 violation) ·
**DEAD KEY** (shortcut swallowed by a disabled/unrouted menu item) ·
**MISSING** (no door at all) · **PARTIAL**.

---

## 0. The three routing regimes (read this first — they generate every violation class)

The menu bar (`EditorCommands.swift`) reaches surfaces by THREE different mechanisms,
and the mismatch between them is the mechanical source of most bad cells:

1. **Editor-router calls** — `session.editorRouter.active?.method()`. `active` is set
   only while a Write-mode `EditorTextView` is attached (`EditorViewModel.swift:258`)
   and cleared on teardown (`EditorViewModel.swift:321–327`); PostDetailView unmounts
   EditorView whenever the mode ≠ Write (`Features/Takes/PostDetailView.swift:107–136`).
   So in Takes/Lenses/Compare/Outline/Blocks/Canvas and on every non-post surface,
   `active == nil`. Items gated `.disabled(active == nil)` go GREY and their shortcuts
   become **dead keys**; items NOT gated (⌘S!) fire into nil and become **silent no-ops**.
2. **Notification broadcasts** — `TakesCommand.post(...)` (`Features/Takes/TakesCommands.swift:31–35`)
   and `.variorumSwitchMode`. Always enabled (`.disabled(session == nil)` only), but they
   act only where a listener is mounted. Listeners of `variorumTakesCommand`: EditorView
   (`Features/Editor/EditorView.swift:107`), TakesBoardView (`Features/Takes/TakesBoardView.swift:124`),
   LensesBoardView (`Features/Takes/LensesBoardView.swift:76`), CanvasView — partial
   (`Features/Canvas/CanvasView.swift:348–356`). Listener of `variorumSwitchMode`: PostDetailView
   only (`Features/Takes/PostDetailView.swift:179`). **Anywhere else, these commands fire into
   the void: enabled menu item, keystroke consumed, nothing happens, nothing speaks.**
3. **Direct actions** — ⌘N/⌘J/⌘K, import/export, undo: run directly on the session and
   work everywhere — though ⌥⌘Z's *outcome message* is delivered via regime 1 and is
   lost outside Write (`EditorCommands.swift:398–413`).

The Sitting-9 keyboard family (R73) migrated the TAKE acts to regime 2 but left the
STRUCTURAL acts on regime 1 — that split is D3, mechanically.

---

## 1. MANDATORY SPECIAL FINDING — the W ceremony's reachability (M2 / R116)

### It exists, and it is complete

- The one-sheet UI: `Features/Editor/DivideWSheet.swift` (checklist of takes, active
  take pre-marked, click-to-place cuts, Confirm gated on every marked take having a
  legal cut, Cancel touches no rows — lines 17–132).
- The state + open/confirm machinery: `EditorViewModel.swift:1983–2019`
  (`openDivideWCeremony` — flush first, live-active fan fetch, `CutPropagation`
  pre-seeding), `2027–2109` (toggle/place/cancel/confirm with drift re-verification),
  `2116–2160` (refresh-on-drift).
- The op call: `ops.divideW(blockID, cuts:)` at `EditorViewModel.swift:2098`.
- Presentation: **exclusively** a sheet on EditorView — `Features/Editor/EditorView.swift:116–120`
  (`.sheet(item: $model.divideWCeremony)`). EditorView mounts ONLY in Write mode
  (detail: `PostDetailView.swift:109`; inline book editor: `Features/BookView/BookView.swift:633`)
  and in a pool's Scraps mode (`Features/Canvas/CanvasView.swift:530`).

### The only triggers (exhaustive — verified by grep over the whole app target)

1. **Divide on a fanned block, in Write.** The planner routes `.divideAtCursor` to
   `.divideW` when the caret's block has `fanArity > 1` and an interior sentence
   boundary exists (`Features/Editor/StructuralGesturePlanner.swift:176–180`);
   `applyStructural` then opens the ceremony (`EditorViewModel.swift:1027–1031`).
2. **Cross-block Make Block whose fanned EDGE fails unique cut-propagation** —
   the executor opens the ceremony for that block mid-compound
   (`EditorViewModel.swift:1398–1407`). Strictly deeper magic than (1).

There is no other path. No door, menu item, palette row, or button anywhere is labeled
with the ceremony's existence.

### The exact user path today, from a fresh post

1. New post (⌘N / quick entry) → opens in **Write** (blockless posts force Write —
   `PostDetailView.swift:160–175`). Type; blocks crystallize.
2. Reopen later → the post opens in **Takes** (the R79 default, `PostDetailView.swift:48–52`).
   Fan a block there — the normal R72 flow: `⑂ +` → bloom → `＋ new take (branch)`
   (`Features/Takes/TakesBoardView.swift:371–376, 531–554`).
3. Now try to divide that fanned block **where you are**:
   - Bottom-bar **Divide** button → **LECTURE**: *"Divide works on selected text in
     Write (⌘1) — switch there, select, and the same door fires"*
     (`Features/Takes/TakesBottomBar.swift:169–175` → `Features/Takes/TakesViewModel.swift:740–743`).
   - **⌘⇧D** → **dead key**: the menu item is `.disabled(session?.editorRouter.active == nil)`
     (`EditorCommands.swift:84–88`), and `active == nil` in Takes (§0.1). Nothing fires,
     nothing speaks.
4. The user must, on their own: switch to Write (⌘1), place the **caret** inside the
   fanned block (the lecture said "selected text" — **wrong for Divide**, which is
   caret-positioned: `StructuralGesturePlanner.swift:150–151, 166–183`), and invoke
   Divide by any Write door (⌘⇧D / Block ▸ Divide Block at Cursor / right-click /
   bottom-bar Divide button, `Features/Editor/CommitBar.swift:105–106`).
5. Only then does the sheet appear — and only if the block's text has an interior
   sentence boundary (a one-sentence fanned block refuses `.nothingToDo`: *"No legal
   boundary for that here"* — `StructuralGesturePlanner.swift:173–175`,
   `Features/Editor/RefusalCopy.swift:34–35`).

### Verdict

**A user who creates takes in Takes mode (the normal workflow) cannot reach the W
ceremony without hidden knowledge.** The path breaks at step 3 — the surface where
fans live offers no acting divide door — and the handoff to Write is undiscoverable
because *nothing names the ceremony*:

- The Helper's Structure section lists only "⌘⇧D divide the block at the cursor"
  with no hint that divide-on-a-fanned-block opens a ceremony
  (`Features/Help/HelperView.swift:64–68`); the Dictionary tab has no entry for
  divide, merge, extract, or the W (grep: the words appear nowhere in `HelperView.swift`
  outside the shortcut rows).
- The tutorial (P6's future spine) never divides anything — it covers polish /
  thread / fork only (`Features/Tutorial/ModesTutorialView.swift:253, 272, 320`).
- The ONE in-app breadcrumb is a refusal string on a *different* command: Make Block
  on a fanned middle span says *"…use Divide Block at Cursor to open the take
  ceremony instead"* (`RefusalCopy.swift:30–31`) — reachable only in Write, only by
  attempting the wrong gesture first.
- The Takes-mode lecture actively steers AWAY from the trigger: "select text" points
  at Extract/Make-Block-shaped gestures, and Make Block on a fanned block refuses.

Confirming the R116 hypothesis: **fanning happens in Takes; divide is Write-gated;
the ceremony's only trigger sits on the one surface her workflow never brings her to,
behind a gesture whose fanned behavior is documented nowhere the user can see.**
(Also noteworthy for the M2 memo: even in Write the ceremony is *only* reachable as a
side effect of Divide — there is no "Divide into takes…" named door, though the sheet
itself is titled "Divide into takes", `DivideWSheet.swift:30`.)

---

## 2. Editing modes × STRUCTURAL acts (full depth)

### 2.1 Write mode (the only surface where structural acts work)

| Act | Doors | Fires? | Speaks? | Works end-to-end? | Evidence |
|---|---|---|---|---|---|
| Divide (single-variant) | Block menu ⌘⇧D (`EditorCommands.swift:84–88`) · context menu (`EditorViewModel.swift:2179`) · bottom-bar button (`CommitBar.swift:105–106`) | yes — all funnel to `divideAtCursor` → `invokeGesture` → planner → `applyStructural` (`EditorViewModel.swift:993–1010`) | yes — refusals via `RefusalCopy` into the status line (`EditorViewModel.swift:1024–1025`, `CommitBar.swift:117–128`) + beep (`:2944–2947`) | **WORKS**: visible snap, `ops.divide`, caret at successor, differential seam edit (`EditorViewModel.swift:1033–1042`) | ✓ |
| Divide (fanned → W) | same doors | yes | drift/refusal paths speak (`:1998–1999, 2059–2061, 2159`) | **WORKS**: `.divideW` plan → one sheet → `ops.divideW` (`:1027–1031, 2097–2103`); full re-render by design | §1 |
| Extract | same three doors (⌘⇧E; `EditorCommands.swift:90–94`, `CommitBar.swift:107–108`) | yes | yes; fanned-extract passive hint (`EditorViewModel.swift:1054–1060`); middle-span refusal names Make Block (`RefusalCopy.swift:28–29`) | **WORKS** (`:1044–1053`) | ✓ |
| Make Block from Selection | same three doors (⌘⇧K; `EditorCommands.swift:96–100`) | yes | yes — incl. `.fannedMiddleSpan` (the ceremony breadcrumb, `RefusalCopy.swift:30–31`) and `.wholeBlockSpan` (`:26–27`) | **WORKS**: two divides under one compound (`EditorViewModel.swift:1062–1085`); cross-block spans get the guided CONFIRM alert (`EditorView.swift:121–137`, executor `:1252–1377`, fanned edges auto-proceed or open the W `:1398–1407`) | ✓ |
| Merge (binary + chain) | same three doors (⌘⇧M; `EditorCommands.swift:104–108`) | yes | yes — `.notASeam` copy (`RefusalCopy.swift:32–33`); merged-away fans spoken (`EditorViewModel.swift:1159–1165`) | **WORKS** (`:1087–1146`) | ✓ |
| Delete in Every Take | Block menu (`EditorCommands.swift:113–117`) · context menu (`EditorViewModel.swift:2186–2188`) | yes | apply-and-report (skipped takes named — `deleteInEveryTake`, `EditorViewModel.swift:1644`) | **WORKS** | ✓ |
| Structural undo ⌥⌘Z | Edit menu (`EditorCommands.swift:67–75`), per-op label | yes | yes in Write ("Undid: …" via active editor `:406–407`) | **WORKS** | ✓ |
| Enablement honesty | bottom-bar buttons dim by planner verdict but stay clickable and speak (`CommitBar.swift:102–115, 154–160`; `EditorViewModel.swift:2195–2218`) | — | — | 9d fire-and-speak intact in Write | ✓ |

### 2.2 Takes mode (the flagship takes surface — structural acts)

| Act | Door | Fires? | Speaks? | Verdict | Evidence |
|---|---|---|---|---|---|
| Divide | bottom-bar "Divide" | yes | redirect lecture | **LECTURE** (R115 violation) — and the copy is factually wrong for Divide ("selected text"; divide is caret-based) | `TakesBottomBar.swift:169–175`; `TakesViewModel.swift:740–743`; planner `StructuralGesturePlanner.swift:150–151` |
| Divide | menu ⌘⇧D | no — item disabled (`active == nil`) | no | **DEAD KEY / SILENT** | `EditorCommands.swift:84–88`; §0.1 |
| Extract | bottom-bar "Extract" | yes | redirect lecture | **LECTURE** | `TakesBottomBar.swift:169–175` |
| Extract | menu ⌘⇧E | no | no | **DEAD KEY** | `EditorCommands.swift:90–94` |
| Make Block | bottom-bar "Make Block" | yes | redirect lecture | **LECTURE** | `TakesBottomBar.swift:169–175` |
| Make Block | menu ⌘⇧K | no | no | **DEAD KEY** — this is D3's "Make Block is SILENT in Takes" (the shortcut, vs the bar button which lectures) | `EditorCommands.swift:96–100` |
| Merge | bottom-bar "Merge" / menu ⌘⇧M | lecture / dead key | as above | **LECTURE** / **DEAD KEY** | `TakesBottomBar.swift:169–175`; `EditorCommands.swift:104–108` |
| **New block at post end** | — | — | — | **MISSING** (D3's third leg): no add-block door anywhere in Takes; blocks are born only by typing in Write (crystallization, `EditorViewModel.swift:965–970`) or import | no door found in `TakesBoardView.swift` / `TakesBottomBar.swift` |
| Delete in Every Take | menu only | no (disabled) | no | **DEAD KEY**; no Takes-side face | `EditorCommands.swift:113–117` |
| Reorder blocks | — | — | — | **MISSING** in Takes (drag handles are Write's, `EditorViewModel.swift:2820–2837`; ↑↓ are Blocks mode's, `Features/TOC/BlockTOCView.swift:260–264`) | — |
| Structural undo ⌥⌘Z | Edit menu | **yes — the undo RUNS** | **no** — outcome message goes to `editorRouter.active?` = nil | **PARTIAL/SILENT-OUTCOME**: rows change with zero feedback (also true everywhere outside Write) | `EditorCommands.swift:398–413` |

*Mitigations present:* the bottom-bar block menu's "Open in Write" navigation door
(`TakesBottomBar.swift:78–83`) and the empty-post "Start writing (Write mode)" door
(`TakesBoardView.swift:285–295`) both actually fire the mode switch (regime 2, listener
mounted) — navigation works; the acts still don't.

### 2.3 Lenses mode (structural acts)

Identical to Takes — the same `TakesBottomBar` rides the board
(`Features/Takes/LensesBoardView.swift:70`), so all four structural buttons **LECTURE**
(`TakesBottomBar.swift:169–175`) and all four shortcuts are **DEAD KEYS**
(§0.1). No add-block, no reorder. Same ⌥⌘Z silent-outcome. Empty-post door: same
working redirect (`LensesBoardView.swift:196–214`).

---

## 3. Editing modes × TAKES acts (full depth)

### 3.1 Write mode

| Act | Doors | Verdict | Evidence |
|---|---|---|---|
| First take / branch (⌘T) | Block menu → `TakesCommand.post(.branch)` → EditorView handler → `mintCaretTake(blank:false)` | **WORKS**; speaks "New take added… ⌘⇧T shows the takes"; no-caret case speaks | `EditorCommands.swift:137–139`; `EditorView.swift:164–165`; `EditorViewModel.swift:2440–2469` |
| Blank take (⌥⌘T) / blank-as-chosen (⇧⌥⌘T) | same channel | **WORKS** (asChosen chooses in the same transaction) | `EditorViewModel.swift:2450–2461` |
| Show/expand takes (⌘⇧T) | Block menu · bottom-bar "Takes" button · ⑂ badge (fanned blocks) | **WORKS** — opens WriteTakesPanel (the v2 card grammar, R87) | `EditorCommands.swift:124–132`; `CommitBar.swift:113–114`; `EditorView.swift:96–101, 494–497`; `EditorViewModel.swift:2409–2434` |
| Choose ✓ | WriteTakesPanel per-card ✓ | **WORKS** in the panel. The ⌘⏎ shortcut in Write **LECTURES**: "Write shows the chosen takes already — Takes (⌘2) is where you pick" | panel `Features/Editor/WriteTakesPanel.swift:143–148`; lecture `EditorView.swift:172–174` |
| Step takes ⌃⌘←/→ | keyboard family | **LECTURE** in Write ("Step through takes in Takes (⌘2)…") | `EditorView.swift:175–177` |
| Archive take (⌘⇧A) | keyboard family → `archiveCaretTake` · WriteTakesPanel ⋯ menu | **WORKS**, speaks | `EditorViewModel.swift:2494–2510`; `WriteTakesPanel.swift:150` |
| Unarchive | WriteTakesPanel archived section | **WORKS** — the ONLY unarchive face in the app | `WriteTakesPanel.swift:172–189` |
| Lock/unlock take | WriteTakesPanel ⋯ menu | **WORKS** — the ONLY lock face in the app | `WriteTakesPanel.swift:151–153` |
| Delete take | WriteTakesPanel ⋯ + archived-row Delete | **WORKS**; refusals speak (last-active, chosen) | `WriteTakesPanel.swift:154–156, 183–185`; `EditorViewModel.swift:2976–2980` |
| Label a take | — | **MISSING at the OPERATION level**: no set-label op exists in core (grep over `Sources/VariorumCore/Operations/` — labels are only ever written by conflict/rescue paths); labels render but can never be authored | render sites `TakesBoardView.swift:562–564`, `WriteTakesPanel.swift:133–135` |
| Commit ⌘S | menu "Commit Take" → `commitCaretVariant` · bottom-bar "commit ⌘S" | **WORKS** in Write; no-caret speaks | `EditorCommands.swift:46–51`; `CommitBar.swift:38–41`; `EditorViewModel.swift:2328–2347` |
| History / restore | bottom-bar "history" → CommitHistoryView; restore w/ pre-split warning | **WORKS** | `CommitBar.swift:42–47, 147–150, 207–236`; `EditorViewModel.swift:2349–2402` |
| Save choices as lens ⌘⇧L | keyboard family → prompt sheet | **WORKS** | `EditorView.swift:19, 102–105, 180–181`; `EditorViewModel.swift:2475–2492` |

### 3.2 Takes mode

| Act | Doors | Verdict | Evidence |
|---|---|---|---|
| First take (unfanned block) | `⑂ +` toggle → bloom shows growth doors · block menu items · ⌘T family | **WORKS** (R72 honored; doors below the cards after batch 12) | `TakesBoardView.swift:371–376, 343–347, 531–554`; `TakesBottomBar.swift:54–85, 102–114` |
| + take (branch) | bottom-bar "+ take" · block menu · dashed growth doors · card context menu · ⌘T | **WORKS**; sealed refusals speak via `statusMessage` → ChromeNotice | `TakesBottomBar.swift:102–114`; `TakesBoardView.swift:531–554`; `TakesShared.swift:77–79`; `TakesViewModel.swift:646–657, 873–889` |
| Blank take / blank-as-chosen | growth doors · block menu · ⌥⌘T/⇧⌥⌘T | **WORKS** | `TakesBoardView.swift:540–543`; `TakesViewModel.swift:659–673, 753–760` |
| Choose ✓ | per-card ✓ · card context menu · ⌘⏎ | **WORKS**; keyboard no-focus case speaks | `TakesBoardView.swift:569–572, 660–663`; `TakesShared.swift:84–87`; `TakesViewModel.swift:807–814` |
| Expand / collapse / expand-all / close-all / ⎋ | ⑂ button · header words · ⌘⇧T · ⎋ | **WORKS** (expand-all hidden for slot-split by design) | `TakesBoardView.swift:239–247, 123, 144–147`; `TakesViewModel.swift:390–406, 817–823` |
| Archive take | ⌘⇧A / menu "Archive Take" (focused pane required; speaks otherwise) | **WORKS** — but the take then VANISHES from the surface (fans are active-only: `Sources/VariorumCore/Queries/TakesQueries.swift:52, 81`) with **no unarchive door in Takes** — recovery requires knowing about Write's panel | `TakesViewModel.swift:826–835`; `WriteTakesPanel.swift:172–189` |
| Unarchive take | — | **MISSING** on this surface (archived takes not even visible) | above |
| Delete take | — | **MISSING**: `deleteTake` exists on the VM (`TakesViewModel.swift:696–698`) with NO face on the board (cards have no ⋯ menu; context menu lacks it; no shortcut) | `TakesBoardView.swift:557–582, 636–679`; `TakesShared.swift:73–114` |
| Lock/unlock take | — | **MISSING** (VM method `setTakeLocked` unfaced here, `TakesViewModel.swift:686–694`) | — |
| Label take | — | **MISSING** (no op — §3.1) | — |
| Commit focused take | bottom-bar "commit ⌘S" button | button **WORKS** (`commitFocusedTake`; speaks when no pane focused). **The advertised ⌘S is a SILENT NO-OP**: the menu's "Commit Take" is never disabled and calls `editorRouter.active?` = nil — the keystroke is consumed, nothing happens, nothing speaks | button `TakesBottomBar.swift:115–120`; `TakesViewModel.swift:703–711`; menu `EditorCommands.swift:46–51` |
| History / restore | bottom-bar "history" → sheet with Restore | **WORKS**; no-pane case speaks | `TakesBottomBar.swift:121–123, 223–267`; `TakesViewModel.swift:745–751` |
| Step ring ⌃⌘←/→ | keyboard family | **WORKS** (single-take case speaks "⌘T branches a second") | `TakesBoardView.swift:178–181`; `TakesViewModel.swift:775–803` |
| Write new takes everywhere | header "post actions ▾" | **WORKS**, reports count | `TakesBoardView.swift:251–256`; `TakesViewModel.swift:586–597` |
| Save choices as lens | post actions ▾ / ⌘⇧L | **WORKS** | `TakesBoardView.swift:257–259, 184–186` |
| Diff against chosen | card context menu | **WORKS** (sheet) | `TakesShared.swift:95–101`; `TakesBoardView.swift:128–132` |

### 3.3 Lenses mode

| Act | Doors | Verdict | Evidence |
|---|---|---|---|
| New column (arrange / write) | "+ column" menu; ≤4 columns (menu disabled at cap — silent cap, `.help` explains) | **WORKS** (`addScratchColumn` / `addWriteColumn` → `branchAllFans`) | `LensesBoardView.swift:172–191`; `TakesViewModel.swift:311–333` |
| Save lens 💾 | column door + ⌘⇧L (scratch fallback; speaks when nothing unnamed) | **WORKS** | `LensesBoardView.swift:382–383, 135–147`; `TakesViewModel.swift:476–501` |
| Adopt (✓ Make this the post) | per-column door; swap-preserving (R92); toast names the preservation lens | **WORKS** | `LensesBoardView.swift:413–419`; `TakesViewModel.swift:516–540` |
| Promote ⧉ | per-column menus (takes ride / chosen-only / keep-as-lens) | **WORKS** | `LensesBoardView.swift:361–394`; `TakesViewModel.swift:547–577` |
| Diverge here | card context menu + ⌘T (per-column thread semantics) | **WORKS** | `TakesShared.swift:88–94`; `LensesBoardView.swift:100–109`; `TakesViewModel.swift:440–472` |
| Branch-all-fans | = "new lens — write new takes" (R82 rename) | **WORKS** | `LensesBoardView.swift:177–181` |
| Pick switching | ‹ take k of n › + ⌃⌘←/→ + "Show take" submenu | **WORKS**; main column pick refusal speaks | `LensesBoardView.swift:273–289`; `TakesViewModel.swift:420–434, 840–850` |
| Slot swap / remove column | column-name menu; ✕ | **WORKS** | `LensesBoardView.swift:311–342, 404–407`; `TakesViewModel.swift:349–381` |
| Rename / duplicate / delete lens | ⋯ menu (named-lens columns) — *no rename door visible*: `renameLens` exists (`TakesViewModel.swift:626–628`) but the ⋯ menu offers only Duplicate/Delete | **PARTIAL** — rename **MISSING** a face | `LensesBoardView.swift:395–400` |
| Blooms (⌘⇧T) | — | **LECTURE**: "Blooms live in Takes (⌘2)" | `LensesBoardView.swift:96–97` |
| Commit ⌘S | same bar; same silent-⌘S | button WORKS · **shortcut SILENT** | §3.2 |
| Take archive ⌘⇧A / delete / lock / unarchive / label | ⌘⇧A works on the focused pane; the rest **MISSING** exactly as in Takes | `LensesBoardView.swift:133–134` |

---

## 4. The other post modes (door-exists level)

### 4.1 Compare (AlignedPostsView)

- Mark as Versions / Unmark — **WORKS**, speaks (`Features/Takes/AlignedPostsView.swift:155–183, 269–284`).
- Diff sheet — WORKS (`:285`).
- ⑂ fan expand + per-take ✓ choose — WORKS (`:360, 375`).
- **Every keyboard-family command is a SILENT no-op** (no `variorumTakesCommand`
  listener mounted; §0.2). ⌘S silent; structural shortcuts dead keys.
- No comments/tags/callout doors; no bottom bar. Status messages speak (`:216`).

### 4.2 Outline (OutlineDraftView)

- Make outline post — **WORKS**, speaks on refusal (`Features/Outline/OutlineDraftView.swift:114–124, 182–186, 209–213`).
- Outline↔draft mapping click-through — WORKS (`:217, 259–262`).
- All take-family keys + ⌘S: **SILENT** (no listener). Structural: dead keys.

### 4.3 Blocks (BlockTOCView)

- Rename block (Name…) — WORKS (`Features/TOC/BlockTOCView.swift:266–270, 134–136, 220–233`).
- Reorder ↑↓ — WORKS (`:260–264, 141–152`).
- Delete block — WORKS (`:280–282, 154–156`).
- Tray restore — WORKS (`:309–330, 160–162`).
- Move to pool — WORKS (`:272–278, 164–166`).
- Jump to block (→ Write caret) — WORKS (`:271`; `PostDetailView.swift:245–257`).
- Expand-to-edit one pane — WORKS (`:288–305`).
- **No callout door, no comments door, no takes doors** on rows; take family + ⌘S:
  **SILENT** (no listener). New-block-at-end: **MISSING** here too.

### 4.4 Canvas (CanvasView)

- Drag/position/reset — WORKS (`Features/Canvas/CanvasView.swift:121–146, 434–436`).
- ‹ › view-local switcher + ✓ choose viewed + 💾 save picks as lens — WORKS
  (`:443–500, 219–233, 239–247, 308–314`).
- Block Tags… — WORKS (`:431–433`, `Features/Pool/BlockTagViews.swift`).
- Keyboard family: **partially SILENT** — handled only while a switcher is open, and
  only step/choose; branch/blank/blank-choose/archive/save-lens/toggle-fan/close-all are
  silently dropped (`:348–356`, `default: break`). ⌘S silent; structural dead keys.
- No comments door on cards; no growth (new-take) doors — viewing-only by R40 design,
  but nothing says so.

---

## 5. Post lifecycle × surfaces

| Act | Write | Takes/Lenses | Library | Pool posts | Shelf | Open post (masthead) |
|---|---|---|---|---|---|---|
| Rename post | — | — | context menu + pencil (`Features/Library/LibraryCatalogView.swift:358, 171–178`) | — | (books only) | click title → popover — **WORKS** (`PostDetailView.swift:191–243`) |
| Seal/unseal | "seal" — **WORKS** incl. full teardown-then-lock (`CommitBar.swift:54–58`; `EditorViewModel.swift:2243–2265`) | "seal" — WORKS (`TakesBottomBar.swift:127–131`; `TakesViewModel.swift:713–722`) | **MISSING** | **MISSING** | **MISSING** | — |
| Entry date | date popover — WORKS (`CommitBar.swift:70–98`) | same (`TakesBottomBar.swift:135–163`) | — | — | — | — |
| Post tags | "tags…" sheet — WORKS (`CommitBar.swift:59–66`; `Features/Tags/TagViews.swift` TagAssignmentSheet) | same (`TakesBottomBar.swift:132–134, 198–200`) | chips + Tags… + batch "Tag N posts" (`LibraryCatalogView.swift:233–236, 335–346, 362`) | tag menu (`Features/Pool/PoolPostsView.swift:155–167`) | — | — |
| Archive / delete / restore | **MISSING** on the open post | **MISSING** | context menu Archive/Delete — WORKS (`LibraryCatalogView.swift:397–405`); recovery surface (`Features/Library/RecoveryView.swift:143–196`) | context menu — WORKS (`PoolPostsView.swift:190–191`) | — | **MISSING** |
| Export post (md/PDF/takes) | **MISSING** on the open post (File menu = library-bulk + caret-block only, `EditorCommands.swift:56–66`) | **MISSING** | Export submenu — WORKS (`LibraryCatalogView.swift:391–394`) | **MISSING** | books: Export Markdown/PDF (`Features/Shelf/ShelfView.swift:277–278`) | **MISSING** |
| Add to book | — | — | — | Add to Book menu — WORKS (`PoolPostsView.swift:171–176`) · drag onto shelf row — WORKS (`ShelfView.swift:214–222`) | drop target | MembershipChip → Add to Book (curated + smart-by-tagging) — **WORKS**, refusals readable (`Features/BookView/MembershipChip.swift:79–94, 189–201, 167–187, 234–251`) |
| Duplicate as version | — | post actions ▾ — WORKS (`TakesBoardView.swift:260–262`) · Lenses main-column ⧉ (`LensesBoardView.swift:361–366`) | context menu — WORKS (`LibraryCatalogView.swift:385`) | context menu — WORKS (`PoolPostsView.swift:186`) | — | chip → Duplicate + "Open the Copy" — WORKS (`MembershipChip.swift:102–124, 217–229`) |
| Mark/unmark versions | — | — | per-row menus — WORKS (`LibraryCatalogView.swift:369–383`) | — | — | Compare mode — WORKS (§4.1) |
| New post | ⌘N (`EditorCommands.swift:32–35, 277–289`) · sidebar toolbar (`Features/Library/SidebarView.swift:162–171`) · quick-entry bars (`Features/Shelf/QuickEntryBar.swift:96–112`) · palette | — | — | — | — | all **WORK** |

Non-post-surface silent keys: on Shelf/Library/Pool/Blocks-area/Folder/Recovery/
Tutorial, ⌘1–⌘7 (mode switch), the whole take family, and ⌘S are enabled menu items
that act on nothing and say nothing (§0.1–0.2). ⌘⇧B (seams), ⌘N/⌘J/⌘K, import/export
work everywhere (regime 3; `EditorCommands.swift:209–211, 237–251`).

## 6. Books (Book view + Shelf)

| Act | Door | Verdict | Evidence |
|---|---|---|---|
| New book (curated/smart/journal) | Shelf "+ New Book" alert | WORKS | `ShelfView.swift:82–107, 167–173` |
| New post in book | navigator "+ new post" / flow-end twin; journal "+ new entry"; hidden on finished books; smart books get a SPEAKING absence notice | WORKS (in-closure gate) | `BookView.swift:251–301, 429–461, 302–314` |
| Chapter create/rename/reorder/assign | "+ new chapter", context menu Rename/Move Up/Down, drag-reorder w/ insertion bar, per-post Chapter submenu | WORKS | `BookView.swift:252–255, 330–344, 175–189, 346–361` |
| Chapter delete/restore | context menu + navigator restore door | WORKS | `BookView.swift:338–343, 262–269` |
| Post card expand/collapse | card click / ▾ / expand-all / collapse-all | **PARTIAL — D1**: collapse ▾ and collapse-all silently no-op on the FOCUSED post (`expanded = contains ∨ focused` force-disjunct) | `BookView.swift:544–546, 603, 386–389` |
| Finish/extent faces | navigator ⚙ sheet + shelf Length & Extent + Finish/Reopen | WORKS (parse refusals speak) | `BookView.swift:697–764`; `ShelfView.swift:263, 273–275, 330–377` |
| Book-scrub | bottom slider | WORKS (model-driven) | `BookView.swift:478–501` |
| Reading flow | Book/Read picker | WORKS | `BookView.swift:128–134, 66–77` |
| In-book editing | focused post = inline EditorView ⇒ full Write capability INCLUDING the menu-bar structural doors and the W (inline editor registers as `active`) | WORKS | `BookView.swift:629–650`; `EditorView.swift:79–84` |
| Pin/unpin, rename, manage posts, edit filter, daily-journal designation, delete book | shelf context menu | WORKS | `ShelfView.swift:247–283` |

## 7. Pool & Blocks area

| Act | Door | Verdict | Evidence |
|---|---|---|---|
| Mint scrap | Blocks-area quick entry (own bar) | WORKS | `Features/Pool/BlocksAreaView.swift:114–170` |
| Drag into draft | scrap row `.onDrag` → editor drop = `poolDragCopy` | WORKS; sealed target speaks | `BlocksAreaView.swift:108–112`; `Features/Editor/EditorTextView.swift:82–88`; `EditorViewModel.swift:2286–2289` |
| ⌥-drag whole fan | modifier read at drop | WORKS | `EditorTextView.swift:87` |
| Pool as editor / canvas | "open as editor" + PoolDetailView Scraps·Canvas picker | WORKS | `BlocksAreaView.swift:82–84`; `CanvasView.swift:502–553` |
| Block tags | pool faces + canvas Tags… | WORKS | `Features/Pool/BlockTagViews.swift`; §4.4 |
| Bookless posts (Pool area) | rows: tags/add-to-book/open/duplicate/archive/delete + drag | WORKS | `PoolPostsView.swift:145–191` |
| Import drop | sidebar drop + Blocks-area drop + File▸Import | WORKS | `SidebarView.swift:157–161`; `BlocksAreaView.swift:60`; `EditorCommands.swift:59, 325–343` |

## 8. ⌘K palette & menu bar (registry view)

Palette vocabulary (`RootView.swift:225–245`): New Post · Today's Entry · Go to
Shelf/Library/Pool · Archived & Deleted · Modes Tutorial · Settings · Toggle Seams ·
two voices — plus catalog search (posts/books/blocks with caret-precise landing,
`Features/CommandPalette/CommandPalette.swift:91–114`). **Absent:** every takes act,
every structural act, export/import, seal, entry date, comments — despite the file
header claiming "the export/import doors" are included (`CommandPalette.swift:5–10`;
a doc-vs-code drift). R15's "every buried capability typeable" is currently false.

Menu bar totals: Block menu = 20 items across 3 regimes (§0); File = import/export
3 doors; Edit = ⌥⌘Z; View = ⌘K; modes ⌘1–⌘7; Help ⌘/ (`EditorCommands.swift` passim;
helper `Features/Help/HelperView.swift`). The Helper's shortcut sheet lists the
structural four with no mode caveat (`HelperView.swift:64–68`) — it teaches keys that
are dead on the default surface (Takes, per R79).

---

## 9. Ranked list 1 — SILENT DOORS (fires nothing, says nothing)

1. **⌘S "Commit Take" outside Write** — menu item always enabled
   (`EditorCommands.swift:46–51`, no `.disabled`), calls `editorRouter.active?` = nil;
   meanwhile the Takes/Lenses bar ADVERTISES "commit ⌘S" and the Helper teaches it
   (`TakesBottomBar.swift:115`; `HelperView.swift:57`). Committing is a daily act on
   the default surface. Worst cell in the audit.
2. **The take keyboard family in Compare/Outline/Blocks + every non-post surface**
   (⌘T, ⌥⌘T, ⇧⌥⌘T, ⌘⏎, ⌃⌘←/→, ⌘⇧A, ⌘⇧L, ⌘⇧T, Close All): enabled items
   (`EditorCommands.swift:124–162`) post `variorumTakesCommand` with no listener
   mounted (§0.2) — keystroke consumed, nothing anywhere.
3. **Structural shortcuts ⌘⇧D/E/K/M as dead keys in Takes/Lenses/every non-Write
   surface** — disabled menu items swallow them silently (`EditorCommands.swift:84–108`).
   This is her "Make Block silently does nothing" (R112).
4. **⌘1–⌘7 mode keys on non-post surfaces** — enabled, broadcast, no PostDetailView
   listening (`EditorCommands.swift:214–225`; `PostDetailView.swift:179`).
5. **⌥⌘Z's outcome outside Write** — the undo *executes* but "Undid: …"/"Undo failed:"
   go to a nil editor (`EditorCommands.swift:398–413`): rows change with zero feedback
   (silent success AND silent failure — arguably more dangerous than a dead key).
6. **D1 — book card collapse ▾ / collapse-all on the focused post** — fires,
   mutates state, visually nothing (`BookView.swift:544–546, 603, 386–389`).
7. **Canvas's partial command handler** — branch/blank/archive/save-lens/toggle-fan
   silently dropped; step/choose dropped unless a switcher is open
   (`CanvasView.swift:348–356`).
8. **⌘⇧' (comments), ⌃⌘↑/↓ (block nav), "Delete in Every Take", Callout menu as dead
   keys outside Write** — all `.disabled(active == nil)`
   (`EditorCommands.swift:113–117, 167–202`).

## 10. Ranked list 2 — LECTURE-AND-REFUSE doors (R115 fire-and-DO violations)

1. **The Takes/Lenses bottom-bar structural four** — Divide · Extract · Make Block ·
   Merge all call `speakStructuralGesturesLiveInWrite`
   (`TakesBottomBar.swift:167–175`; `TakesViewModel.swift:740–743`). Ranked first:
   these are THE daily structural acts on THE default surface, the redirect is wrong
   for Divide ("selected text" — divide is caret-based), and following it correctly
   is the only road to the W ceremony (§1). Each could fire-and-DO: switch mode,
   restore the block position, run the planner.
2. **⌘⏎ Choose in Write** — "Write shows the chosen takes already — Takes (⌘2) is
   where you pick among them" (`EditorView.swift:172–174`). Could open the caret
   block's WriteTakesPanel (the door exists one line away: `.toggleFan`).
3. **⌃⌘←/→ step-takes in Write** — "Step through takes in Takes (⌘2)…"
   (`EditorView.swift:175–177`). Same fix shape.
4. **⌘⇧T blooms in Lenses** — "Blooms live in Takes (⌘2)" (`LensesBoardView.swift:96–97`).
   Could switch to Takes with the block expanded.
5. *(borderline, recorded not charged)* Main-column pick refusal — "use ✓ to change
   them" (`TakesViewModel.swift:420–424`): a genuine model rule (I3), phrased as
   instruction; acceptable as a real refusal.
6. *(compliant contrasts, for the registry)* Empty-post "Start writing (Write mode)"
   buttons DO act (`TakesBoardView.swift:285–295`; `LensesBoardView.swift:196–214`),
   as does the block menu's "Open in Write" (`TakesBottomBar.swift:78–83`) — the
   navigation half of fire-and-DO already exists; only the "and-apply" half is unbuilt.

## 11. Ranked list 3 — MISSING doors on basic acts

1. **New block at the end of a post — no door in Takes or Lenses** (D3's third leg;
   R112's verbatim example). The model mints blocks freely (`newBlock`,
   crystallization); only Write-typing reaches it. No "+ block" exists on the board,
   the bar, or the block menu (`TakesBoardView.swift`, `TakesBottomBar.swift` — absent).
2. **Take delete / lock / unarchive in Takes and Lenses** — the flagship takes surface
   cannot delete a take, cannot lock one, cannot even SEE archived takes (fans are
   active-only: `Sources/VariorumCore/Queries/TakesQueries.swift:52, 81`); all three
   live only in Write's per-block sheet (`WriteTakesPanel.swift:149–189`). Archiving
   from Takes (⌘⇧A works) then strands the user: the take vanishes with no visible
   way back on that surface.
3. **Take LABEL — no operation exists at all** (no setter in
   `Sources/VariorumCore/Operations/`; grep clean). The schema column, the card
   renderers, and the W sheet all display labels no user can write. Needs a core op
   + faces (a schema-adjacent gap worth the M-memo track).
4. **Structural acts with no working door on Takes/Lenses** (the acting half of the
   lecture list): divide/extract/make-block/merge are model-complete and
   surface-absent where fans live.
5. **Post export from the open post** — exporting the post you're looking at requires
   navigating to Library and right-clicking its row (`LibraryCatalogView.swift:391–394`);
   the File menu offers only library-bulk and caret-block (`EditorCommands.swift:56–66`).
6. **Post archive/delete from the open post** — same detour (Library/Pool context
   menus only; `LibraryCatalogView.swift:397–405`, `PoolPostsView.swift:190–191`).
7. **⌘K palette vocabulary** — no takes/structural/export/seal/date/comments commands
   (`RootView.swift:225–245`), contradicting both R15's ratified promise and the
   palette's own header (`CommandPalette.swift:5–10`).
8. **Rename lens** — op + VM method exist (`TakesViewModel.swift:626–628`); the ⋯
   column menu offers only Duplicate/Delete (`LensesBoardView.swift:395–400`).
9. **Callout/presentation outside Write** — Block▸Callout is the only face
   (`EditorCommands.swift:188–202`), dead outside Write; no face in Takes/Lenses/
   Blocks/Canvas.
10. **Reorder blocks in Takes** — handles are Write's (`EditorViewModel.swift:2820–2837`),
    ↑↓ are Blocks mode's (`BlockTOCView.swift:260–264`); the default surface has neither.
11. **Block comments in Compare/Outline/Canvas** — comment faces exist in Write
    (`CommitBar.swift:67–69`, margin/inline), Takes/Lenses (bar block-menu +
    margin note: `TakesBottomBar.swift:73–76`; `TakesShared.swift:143–196`), Blocks: none;
    Canvas: none.
12. **Seal from Library/Shelf** — seal lives only inside the open post's bars (low;
    arguably correct placement, recorded for the registry).

---

## 12. Cross-cutting notes for the architect

- **The D3/D4 generator is structural, not incidental**: three routing regimes (§0)
  with per-item gating decisions scattered across `EditorCommands.swift` — exactly
  what P-1's capability registry replaces. Every silent cell above is one of:
  ungated-call-into-nil (⌘S), gated-to-grey (structural four), or
  broadcast-without-listener (take family, ⌘1–7).
- **The advertised-but-dead pattern** (bar labels "commit ⌘S"; Helper teaches ⌘⇧D/⌘S
  with no surface caveat) is worse than absence — it manufactures exactly R112's
  "confusion of what is possible and what is broken."
- **The W memo (M2)** should decide: a named, discoverable door ("Divide into takes…")
  on fanned blocks IN TAKES (where fans live), what the Takes-side divide does
  (fire-and-DO: switch + caret + plan), Helper/dictionary coverage, and the
  one-sentence-block edge (today: silent-ish `.nothingToDo`).
- **D2 corroboration (recorded in passing, not traced to pixels):** the margin-grid
  article widens by the reserved rail (`TakesBoardView.swift:315–319`) and the
  masthead follows (`PostDetailView.swift:70–75`); both columns center via
  `.frame(maxWidth: measure)` inside `.frame(maxWidth: .infinity)` — widening the
  measure by the rail shifts the prose column left by ~rail/2 relative to the other
  modes' 680pt centering. Consistent with her screenshot; trace before fixing.
- Counts for the ledger: **14 surfaces × 46 acts audited; ~310 populated cells; 8
  silent-door classes (≈40 concrete key/surface combinations), 4 charged lecture
  doors (+2 borderline), 12 missing-door findings (2 of them operation-level gaps:
  take label, lens rename face).**
