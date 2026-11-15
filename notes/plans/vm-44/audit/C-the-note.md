# VM-44 audit — reader C: THE NOTE (Write editor, blocks, takes, commits, history, comments, tray, note actions, modes)

Draft working material, not canon. Tree read: `~/dev/variorum` `main` at `5dde1bcf9` (2026-11-12). Every claim is
VERIFIED (file:line read) or INFERRED (source named). Paths: `VM/` = `App/Variorum/VariorumMobile/`,
`SH/` = `App/Variorum/Shared/`, `MAC/` = `App/Variorum/Variorum/`, `CORE/` = `Sources/VariorumCore/`.

## 0. The phone note as built (one paragraph, so the matrix reads)

A note on the phone is ONE screen: `MobileWriteScreen` (`VM/Features/Write/MobileWriteView.swift:63`), pushed by the
shell's `.note` route (`VM/Features/Shell/MobileShellView.swift:457-468`). There is NO mode row: no note Read, no Takes
board, no Blocks mode, no Compare. Everything else is summoned from it: a masthead (title-as-rename-door; copy · find ·
lock · ⋯ glyphs; a membership chip; a wrapping row of five text chips date · tags · more info · blocks · lens; a sealed
line; a status line with Undo/Redo), a keyboard accessory bar (Aa · ⑂ · ⋯, Aa expanding an 11-act formatting strip),
the long-press edit menu (Takes… · Extract Selection · Make Block from Selection · Block ▸), the ⑂ fan badge and a
horizontal swipe-peek on fanned blocks, three hand-built UIKit overlay sheets (takes browser, block history, comments)
and six SwiftUI sheets (membership, tags, more info, blocks/tray, lenses, note actions), plus a pushed Versions screen.

---

## 1. Gap matrix

Status key: PRESENT · PARTIAL · STALE (behind a Mac rule or visibly rough) · ABSENT · RULED-EXCLUDED.
Brain key: Core · Shared · Mac-local (= hoist owed before the phone can have it without forking).
Size: S (a door/wiring/copy) · M (a face with design) · L (a surface).

### 1a. The Write editor core

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| E1 | Live TK2 editor, block identity as re-stamped projection, autocorrect/dictation/marked-text safety | AppSpec §4, §15.1; MobileSoul §5.2 | PRESENT | `VM/Features/Write/MobileEditorViewModel.swift:1818` (`storageDidEdit`, gateless fallback verdict) | Shared (`SH/EditorBrain/*`) | VM-12 (silent keyboard drop, editability authority) · VM-19 · VM-24 | — | VERIFIED. VM-24 is the one standing mobile red (caret suite), VM-19 a test-posture gap; neither re-run here. |
| E2 | Type-time crystallization of the open tail; bulk paste segments in the tail | OverallModel §7; AppSpec §7 Segmentation | PRESENT | `MobileEditorViewModel.swift:1634-1636` (paste arms bulk), `:2024-2058` | Shared (`TailCrystallizer`, `CrystallizationPlanner`) | PL-24(1), PL-41(a) | — | VERIFIED. |
| E3 | **Return key model** — chip ON: Return is structural (empty block below at a block's end; divide at the START of the word mid-text; empty block above at a block's start; chains in an empty block) | AppSpec §7 "Segmentation / the Return key" (U-1, U-19, R-13u4-2, VX-806); `MAC/Features/Editor/EditorTextView.swift:192-250` | STALE | `VM/Features/Write/MobileEditorTextView.swift:1014-1020`; `SH/EditorBrain/BlockRangeIndex.swift:184-209` | Shared (`SH/EditorBrain/TypedReturn.swift` — compiles into iOS, ZERO phone callers) | PL-21(1), PL-31, VM-7 | M | VERIFIED: a phone Return anywhere but the note's very end is a content newline INSIDE the current block (`verdict` → `.block`); only Return at the document end opens a tail. A phone user writing in the middle of a note silently builds multi-paragraph blocks; no empty-block chain. AppSpec says "The phone's Return model is its own" — the model is unruled (Q1). |
| E4 | ⇧⏎ = the newline that stays inside the block | AppSpec §12 keyboard family | ABSENT | `MobileEditorTextView.swift:1010-1013` (comment: "the phone has no soft-newline ⇧⏎ story yet") | — | PL-21(1) | S | VERIFIED. Only matters once E3 changes. |
| E5 | Per-note segmentation chip (newlines make blocks on/off) | `MAC/Features/Editor/CommitBar.swift:993-1003` (`newlinesChip`) | ABSENT | — (phone reads `header.effectiveSegmentation`, `MobileEditorViewModel.swift:2301`, never writes it) | Core op `setSegmentationDefault`; words `SegmentationFaceCopy` Mac-local | — | S | VERIFIED. |
| E6 | "Make every newline a block" / "Split this block at its newlines" | `CommitBar.swift:917-922`; capabilities `.splitEveryNewlineIntoBlocks`, `.splitBlockAtNewlines` | ABSENT | — | Core (`splitBlockAtNewlines`, `Domain/NewlineSplitting`) | PL-21(2) | S | VERIFIED (zero phone callers). The repair a phone user most needs given E3. |
| E7 | **Seam carves**: backspace at a block's start merges the texted seam (#34); backspace beside an EMPTY block deletes it (A7) | AppSpec §9 `deleteBlock(requiring:)`; `SH/EditorBrain/EditorEditRoute.swift:156-163` (`macArms`) | ABSENT | `SH/EditorBrain/EditorEditRoute.swift:170-175` (`phoneArms` — no carve arms); `MobileEditorViewModel.swift:1614-1617` | Shared (`SeamCarvePlan`, the two arms) | VM-1 (row 51), PL-24(e), PL-40 | M | VERIFIED: on the phone ⌫ at the start of a paragraph REFUSES (`.seamKeystrokeDeclined`, naming Merge with Previous). An empty block cannot be removed by ⌫. The single most "doesn't behave like a text editor" defect in this area. |
| E8 | Cross-block compound (select across paragraphs, delete/type over) | AppSpec §9 merge/compound; OverallModel §3 insureTakes | PARTIAL | `VM/Features/Write/MobileStructural.swift:798-849` | Shared (`CrossBlockCompound`) | PL-23(1)(2) | S | VERIFIED: works; the receipt is a bare Undo with NO words (`:842`) where the Mac names where every block went (`CrossBlockEditCopy`, Mac-local). Device gesture-matrix walk still owed. |
| E9 | Whole-paragraph selection + delete | 13j J9 | PRESENT | `MobileStructural.swift:705-752` | Shared | — | — | VERIFIED (one undo entry, no confirm by her R13). |
| E10 | **Structural-flight keystroke fence** | Mac fence `EditorSurfaceController` (isEditable off + deferring keystrokes) | ABSENT (data bug) | `MobileEditorViewModel.swift:1531-1573` (gate checks `noteIsGone`, `isLive`, `header.locked` — never `structural.structuralInFlight`); `MobileStructural.swift` sets no `isEditable=false` | — | **VM-2 — STILL REAL** | S | VERIFIED today: no reference to `structuralInFlight` outside `MobileStructural.swift`; a keystroke (or autocorrect) in a divide/merge settle window can resurrect a moved half or land in a released block. |
| E11 | Live markdown face, caret-aware closer | SurfaceContracts §The note "editor language" (VX-296) | PRESENT | `MobileEditorViewModel.swift:2082` | Shared (`SH/MarkdownFace`) | PL-54, VM-24 | — | VERIFIED. |
| E12 | Formatting acts B · I · S · code · link · heading (cycle + picker) · bullet · checklist · indent · outdent | `MAC/Features/Formatting/MarkdownActs.swift` | PRESENT (rough) | `VM/Features/Write/MobileKeyboardBar.swift:472-477, 663-677` | Core (`Domain/MarkdownEditing`) + Shared (`MarkdownSurfaceDoors`) | — | — | VERIFIED vocabulary parity. Acts are 28 pt wide × 38 pt tall (`:123, :252-288`), under the 44 pt floor by her R22 trade — see §2. |
| E13 | List continuation on ⏎, exit on empty item, Tab/⇧Tab indent, checkbox tap toggle | 13k K5/K8 | PRESENT | `MobileEditorTextView.swift:1014-1054`; `:968-976` | Core/Shared | — | — | VERIFIED. |
| E14 | Paste-plain door (line breaks → spaces) | `MAC/Features/Editor/EditorTextView.swift:780-791` | ABSENT | `MobileEditorTextView.swift:1097-1101` (paste only flags bulk) | Shared (`SH/PlainPaste.swift`) | PL-24(a), VM-1 | S | VERIFIED (zero phone references). |
| E15 | Smart quote / dash substitution | Mac Write disables both (`EditorTextView.swift:905-906, 972-973`) | STALE (divergent) | `MobileEditorTextView.swift:923-978` (no `smartQuotesType`/`smartDashesType` set → iOS defaults ON) | — | VX-438 (Needs Lillian, "pick one owner") | S | VERIFIED. A phone edit writes curly quotes/em dashes the Mac never would (Q8). |
| E16 | Spellchecking level + one-shot check (⌘; / ⌘:) | SurfaceContracts §The app keyboard family (VX-798); Mac setting local, default OFF (`MAC/Features/Settings/AppSettingsView.swift:733`) | PARTIAL | — (system continuous spellcheck, default on; no setting, no one-shot) | Mac-local (`SpellcheckLevel`) | — | S | VERIFIED absence of any phone control; behaviour is iOS default (Q8). |
| E17 | Find in note | SurfaceContracts §The note (find bar, "2 of 15" readout, VX-441) | PARTIAL | `MobileEditorViewModel.swift:1027-1029`; `MobileEditorTextView.swift:946, 1074` | iOS system navigator | PL-39(1) | M | VERIFIED: find only; replace is switched off at the protocol (`supportsTextReplacement=false`). Takes-aware find/replace (PL-1) absent. |
| E18 | Arrival scroll + per-note session place memory; first open = top | SurfaceContracts §The note (R-18l-1) | PRESENT | `MobileEditorViewModel.swift:549-568`; `MobileWriteView.swift:34-51` | phone-local (session memory) | VM-10 DONE (PR #132), PL-22, PL-38 | — | VERIFIED. PROVISIONALs #200(a–c) still await her ratify. |
| E19 | Re-font on voice switch keeps place | PL-33 | PRESENT | `MobileEditorViewModel.swift:746` | — | PL-33 | — | VERIFIED (blank-page half has no mechanism, recorded). |
| E20 | Editor voice: fresh store = Study; voice + palette are SYNCED store settings | SurfaceContracts §The app ("Study is the fresh-store default"; palette, VX-710) | STALE | `VM/Theme/MobileVoicePreference.swift:30-32` (absent → `.terminal`); `MobileWriteView.swift:180` (two-parameter `resolve`) | Shared (`VoiceTokens.resolve(voice:palette:tint:dark:)`, `PaletteTint`) | PL-22 | M | VERIFIED: the phone's voice is a LOCAL pref defaulting to Terminal (14 pt monospace body, `VM/Features/Write/MobileEditorStyle.swift:110-112`) and it ignores the synced palette — the phone wears Classic colours whatever she picked. Plausibly part of her "weirdly tiny font" (INFERRED). Cross-area: theme reader. |
| E21 | Dynamic Type for chrome | MobileSoul §5.6 | ABSENT | `SH/Theme/VoiceTokens.swift:296, 369` (`small` = fixed 11.5 pt); overlay sheets hard-code 10.5–13 pt (`VM/Features/Takes/MobileTakesBrowserView.swift:301-314, 713-739`; `VM/Features/Write/MobileCommentsSheetView.swift:195-287`; `VM/Features/Write/MobileBlockDecor.swift:207`) | Shared tokens | VM-9 (launch audit) | M | VERIFIED. Body text scales (`MobileEditorStyle.swift:107-125`); every chip, receipt, sheet row and comment marker does not. |
| E22 | Block seams (dotted, global toggle) + editing indicator setting | SurfaceContracts §The note editor language; synced keys `seams_visible`, `editing_indicator` (`CORE/Queries/AppearanceQueries.swift:137-156`) | ABSENT | — | Core (settings read) | PL-21(5) | S | VERIFIED (no phone reader of either key). |

### 1b. Block menu and structural acts

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| B1 | Block menu: Comments… · Callout ▸ · Name Block… · Commit Take · New Block Below · Divide Block · Merge with Previous · Archive Block · Delete Block | Mac block ▾ / context menu (capability registry) | PRESENT | `VM/Features/Write/MobileBlockMenu.swift:164-224`; doors: bar ⋯ `MobileKeyboardBar.swift:737-762`, edit menu `VM/Features/Takes/MobileEditMenuSeam.swift:85-87` | — | — | — | VERIFIED. Reachable only with the keyboard up (bar) or via the edit menu (§3). |
| B2 | Divide at caret, fanned = keep-on-top | AppSpec §9 divide (U-2) | PRESENT | `MobileStructural.swift:82-182` | Core (`KeepOnTopDivide`, `divideW`) | PL-21 (shipped) | — | VERIFIED. Needs caret + ⋯; Return never divides (E3). |
| B3 | Divide presets (keep on bottom · copy to both · choose per take) | AppSpec §9 divideW sheet presets; SurfaceContracts §The note ceremony sheets | ABSENT | — | Core (`divideW`, `divideDuplicating`) | PL-21(3) | M | VERIFIED. PL-21(3) owes "three plain rows… never the hand-placement surface" (Q11). |
| B4 | Divide/Merge choosing takes (the ceremonies) | AppSpec §9 divideW / mergeCeremony | RULED-EXCLUDED | — | Core | MobileSoul §4.5 | — | Her ruled exclusion. |
| B5 | Merge with previous (fanned = carry-all) | AppSpec §9 merge / mergeCeremony | PRESENT | `MobileStructural.swift:217-334` | Core op; carry-all composition FORKED (phone C5 vs Mac `MAC/Features/Editor/FannedDefaults.swift`) | VM-1 (CarryAllMerge sibling note) | S (hoist) | VERIFIED. No "merge with next", no N-way "Merge Selected Blocks". |
| B6 | Extract Selection | AppSpec §9 extract | PRESENT | `MobileEditMenuSeam.swift:76-79`; `MobileStructural.swift:341-343` | Shared (`StructuralGesturePlanner`) | — | — | VERIFIED (edit menu only, needs a selection). |
| B7 | Make Block from Selection | capability `.makeBlock` | PRESENT | `MobileEditMenuSeam.swift:80-83` | Shared | — | — | VERIFIED. |
| B8 | Move Selection into a New Take | AppSpec §9 `moveSpanToNewTake` (QUESTIONS #128) | ABSENT | — | Core | PL-34 | S | VERIFIED (zero phone callers). |
| B9 | New Block Below | AppSpec §9 `newBlock` registers undo ("New Block", R-13u-3) | STALE | `MobileStructural.swift:518-552` | Core (`CORE/Operations/Operations+Block.swift:64-83`) | PL-23(4) | S | VERIFIED: the door's comment (`:546-552`) says `newBlock` registers no undo and so the receipt carries no Undo — false since R-13u-3; the stack now holds "New Block" (the note ⋯ will offer it) but the receipt doesn't. |
| B10 | Delete Block (confirm, names the tray + undo) | AppSpec §9 deleteBlock | PRESENT | `MobileBlockMenu.swift:407-451`; `MobileStructural.swift:568-609` | Core | — | — | VERIFIED. |
| B11 | Archive Block | AppSpec §9 (13j round-7) | PRESENT | `MobileStructural.swift:631-662` | Core | — | — | VERIFIED. |
| B12 | **Reorder blocks** (move up/down, to #n, top/bottom, drag) | `MAC/Features/TOC/BlockTOCView.swift:378-450, 485-490` (Blocks mode) | ABSENT | — | Core (`reorder`) | — | M | VERIFIED: zero phone `reorder`/`moveBlock` callers. A phone user cannot reorder paragraphs except by cut/paste (which mints new blocks and loses identity). |
| B13 | Move block to Snippets | `BlockTOCView.swift:445` (`moveBlock` → pool) | ABSENT | — | Core | — | S | VERIFIED. Cross-area: Snippets reader. |
| B14 | Name a block; names render | AppSpec §7 `block.name` | PRESENT | `MobileBlockMenu.swift:327-367` (alert); `VM/Features/Write/MobileBlockList.swift` (renders) | Core | — | — | VERIFIED. |
| B15 | Block tags | AppSpec §7 `block_tag` | ABSENT | — | Core | VX-128 (her open question) | — | VERIFIED; hers whether it exists at all. |
| B16 | Block list (jump list) | Read's `▸ 01` column / Blocks TOC | PRESENT | `MobileBlockList.swift` (chip "blocks") | Core (`Queries.blockTOC`, `tocHandle`) | PL-19 | — | VERIFIED. |
| B17 | Blocks multi-select bulk bar (delete · merge · split at newlines · tag · move) | capabilities `.deleteSelectedBlocks`, `.mergeSelectedBlocks`, `.splitSelectedBlocksAtNewlines` | PARTIAL | `MobileBlockList.swift:103-235` (select + delete only) | Core | — | M | VERIFIED. |
| B18 | Structural undo / redo door | AppSpec §9 "Structural undo and redo" (quiet undo retires, PROVISIONAL #226) | STALE (bug) | `VM/Features/Write/MobileUndoDoor.swift:202, 246` (`undo(with:)` / `redo(with:)`); receipt `MobileWriteView.swift:611-642`; note ⋯ `VM/Features/Write/MobileNoteActions.swift:261-286` | Shared (`StructuralUndoCopy`) | **VM-16 still real**, **VM-20 still real** (`MobileUndoDoor.swift:285` "It is saved first") | S | VERIFIED. A quiet press says "Undid: X" and offers a Redo that acts on a different entry. |
| B19 | Cross-block receipt naming where every block went | 13u1 item 5 | ABSENT | `MobileStructural.swift:842` | Mac-local (`CrossBlockEditCopy`) | PL-23(1) | S | VERIFIED. |

### 1c. Takes

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| T1 | Fan badge (⑂, count-free, fanned blocks only) | SurfaceContracts §The note ("a corner badge only on fanned blocks") | PRESENT | `VM/Features/Takes/MobileTakesChrome.swift:195-224` | phone face | VM-17 | — | VERIFIED. VM-17's pile is INFERRED unlikely: badge geometry comes from `firstLineGeometry`, which forces `.ensuresLayout` (`MobileEditorTextView.swift:603-619`) — the opposite of VX-230's unlaid-frame read. Probe still owed per the ticket. |
| T2 | Swipe-peek + pill ‹ take k/n · label › + ✓ choose | MobileSoul §4.1 (the phone's native takes grammar) | PRESENT | `MobileTakesChrome.swift:24-36, 318-330`; `VM/Features/Takes/MobileTakesController.swift:146-258` | phone brain | — | — | VERIFIED. |
| T3 | Takes browser: choose, branch-the-displayed, blank, edit any take (one live card), archived section | SurfaceContracts §The note Takes; AppSpec §9 | PRESENT (rough) | `VM/Features/Takes/MobileTakesBrowser.swift:130-483`; view `MobileTakesBrowserView.swift` | Core ops | — | — | VERIFIED. Hand-built overlay (see §2). |
| T4 | Card ⋯: Block History… · Label… · Move Up/Down · Lock/Unlock · Take to New Block Below · Archive · Delete; sheet: All Takes to Blocks | Mac `TakeCardMenu.rows` (`MAC/Features/Takes/TakesShared.swift:650-669`) | PRESENT | `MobileTakesBrowser.swift:798-829` | Core (`reorderTake`, `takeToBlockBelow`, `takesToBlocks`) | PL-10(a)(d) delivered | — | VERIFIED. |
| T5 | "New branched take" from THIS card (branch a non-displayed take) | VX-594 (R-601-4) — first row of the Mac card menu | ABSENT | `MobileTakesBrowser.swift:399-429` (branches only the DISPLAYED take) | Core | — | S | VERIFIED: to branch take 3 she must first swipe to it. |
| T6 | Copy all takes | capability `.copyAllTakes` | ABSENT | — | Core (`Queries.blockTakes`) + Mac-local `MAC/Features/Takes/TakeClipboard.swift` | PL-10(c), VM-7 | S | VERIFIED. |
| T7 | Blank-and-chosen (⇧⌥⌘T) | capability `.blankTakeAsChosen` | ABSENT | — | Core | — | S | VERIFIED; low value. |
| T8 | Diff a take against the chosen | capability `.diffAgainstChosen` | ABSENT | — | Core `Domain/TextCompare`; Mac-local `LineDiff` (`MAC/Features/Takes/DiffView.swift:24`) | — | M | VERIFIED. Compare-class. |
| T9 | Takes board as a MODE (single column, per-note open-fan memory, expand-all, changing-block wash) | SurfaceContracts §The note Takes | RULED-EXCLUDED in shape (browser + swipe is the ruled face; expand-all excluded) | — | — | MobileSoul §4.1, §4.5 | — | — |
| T10 | Lens-aware `show ▾` filter on takes | SurfaceContracts §The note Takes (VX-168) | ABSENT | — | Core (`Domain/LensTakeFilter`) | PL-53 (VX-168 note) | M | VERIFIED. |
| T11 | Conflict takes discoverable (S5) | MobileSoul §5.3 | PRESENT | badge + card label | — | — | — | INFERRED: a conflict take is an active take labelled "conflict", so the block grows ⑂ and the card/pill show the label. Nothing marks it as a conflict beyond the word — the same on the Mac. |
| T12 | AI-labelled take truncation face (client yields, label kept) | VX-352 `CORE/Domain/TakeLabelFace.swift` | ABSENT | browser card meta | Core | — | S | VERIFIED (zero phone callers); minor. |

### 1d. Commits, history, lineage

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| H1 | Commit the take | AppSpec §9 commit; SurfaceContracts §The app commit vocabulary | PARTIAL | `MobileBlockMenu.swift:194-197`; `VM/Features/Takes/MobileBlockHistory.swift:198-216` | Core | PL-28 | — | VERIFIED: unnamed only (`kind: .manual`, no message); no latch (double tap = two commits, `MobileBlockMenu.swift:107-111`). |
| H2 | Name a commit at filing; rename later | SurfaceContracts §The app ("⌘S always commits… name field"); AppSpec §9 `renameCommitPoint` | ABSENT | — | Core (`renameCommitPoint`, `Domain/SavepointName`); field seam `SavepointNameField` Mac | PL-28 | S | VERIFIED. |
| H3 | Block History (savepoint runs · archived · deleted with clock · came from) | Mac panel RETIRED into History & Lineage (VX-801) | STALE | `MobileBlockHistory.swift` + `MobileBlockHistorySheetView.swift` | Core (`Queries.blockHistory`) + Shared (`SH/BlockHistoryFace.swift`) | VM-41, PL-53 (row face), PL-70 | L | VERIFIED: the phone keeps the face the Mac retired; door only on a take card ⋯ (§3). |
| H4 | Restore a commit, insuring the replaced words | AppSpec §9 `restoreCommit(…, insuringBuffer:)` (#274) | STALE (her ruling unwired) | `MobileBlockHistory.swift:483` | Core | **VM-43 still real** | S | VERIFIED: `ops.restoreCommit(variantID, commitID:)` with no insurance. |
| H5 | Bring back a commit as a take | AppSpec §9 `bringBackCommitAsTake` | ABSENT | — | Core | PL-62(b) | S | VERIFIED. |
| H6 | Commits face: reading pane, all-takes rail, ↑/↓ swapper, against-now wash, two-box compare | SurfaceContracts §The note History & lineage | ABSENT | — | Core (`Domain/TextCompare`, `Domain/CommitRail`); Mac-local `MAC/Features/History/CommitsFaceModel.swift`, `CommitsFaceCopy` | VM-41 | L | VERIFIED. |
| H7 | Lineage face (family vertical, Put back, Bring back as a take, Compare with now, origin doors "See original from…") | same | PARTIAL | phone keeps "came from" with Put back (`MobileBlockHistory.swift:543`) | Core (`Queries.lineagePeers`/`lineageTree`, `Domain/LineageFamily`, `bringBackFromLineage`); Mac-local `LineageFaceModel`, `LineageFaceCopy` | VM-41, PL-70 | L | VERIFIED. |

### 1e. Whole-note versions

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| V1 | Save a Version · Versions… · read · restore (real-cost confirm) · promote · delete | AppSpec §9 save/restore/promoteNoteVersion | PRESENT | `VM/Features/Write/MobileVersions.swift`; `MobileNoteActions.swift:184-225` | Core + Shared (`VersionActs`, `VersionsCopy`) | PL-14(f), PL-29, PL-48 | — | VERIFIED. |
| V2 | Compare with Latest Version; versions in Compare; full-size version under the identity band | SurfaceContracts §The note Versions (vx-440) | RULED-EXCLUDED | — | — | PL-62 ("Mac-only by her named exception") | — | Reopens with Compare (§1i). |

### 1f. Comments and callouts

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| C1 | Comments on a block: list, add, edit, delete, deleted fold + restore | AppSpec §9 comments; SurfaceContracts §The note | PRESENT (rough) | `VM/Features/Write/MobileComments.swift`; `MobileCommentsSheetView.swift` | Core | PL-25 | M | VERIFIED. Not the Mac's one-writing-surface panel (click-anywhere add, edit in place); `CommentComposition` is still Mac-local (hoist owed). |
| C2 | Half-typed comment kept on any close but ⎋ | QUESTIONS #223 (VX-257) | ABSENT | `MobileCommentsSheetView.swift:163-166` (close clears the field) | Shared (`SH/CommentDraftPark.swift` — phone uses it for REFUSED drafts only, `MobileComments.swift:39-104`) | **VM-18 still real** (Needs Lillian) | S | VERIFIED. |
| C3 | Placeholder aligned to the text origin | VX-179 F-U3-1 | STALE | `MobileCommentsSheetView.swift:223` (`(8, 10)` hand-placed) | — | VM-14 (Parked) | S | VERIFIED. |
| C4 | "Delete forever…" on a deleted comment | AppSpec §9 `purgeBlockComment` | ABSENT | — | Core | PL-46 (VX-179) | S | VERIFIED. |
| C5 | Comment presence on the page | Mac: whitespace gutter, LEFT, measure never moves | STALE (held design call) | `MobileBlockDecor.swift:24-27, 207` (●n at the last line's END, 10.5 pt) | phone face | PL-10 (her call held) | S | VERIFIED. |
| C6 | Comment draft field above the keyboard | — | INFERRED defect | `MobileCommentsSheetView.swift:186-254` (frames computed once in `render()`, no keyboard handling, no `layoutSubviews`) | — | — | S | INFERRED: the takes browser needed an explicit keyboard fix ("THE GATE DEFECT", `MobileTakesBrowserView.swift:77-96`); the comments sheet has no twin, so its bottom-pinned draft field likely sits under the keyboard. Device check. |
| C7 | Callout: toggle · five colours (swatched) · emoji · remove; one frame wash + leading glyph | AppSpec §9 presentation; SurfaceContracts §The note | PRESENT | `VM/Features/Write/MobileCallout.swift`; `MobileBlockMenu.swift:226-323`; `MobileBlockDecor.swift` | Core (`BlockPresentation`); palette MIRRORED (`MobileCallout.names` vs `MAC/Features/Editor/BlockDecor.swift:564-565`) | VM-1 (fork list) | — | VERIFIED; the mirror is a recorded fork. |

### 1g. This note's tray

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| R1 | Tray: Archived (Put back) · Leaving (Put back, Delete Now on takes, clocks) | SurfaceContracts §The note ("Leaving and Archived VIEWS with a shared blocks/takes filter") | STALE (shape) | `VM/Features/Write/MobileNoteTray.swift`; door = blocks chip segments (`MobileBlockList.swift:27-45`) | Core reads + Shared `RecoveryCopy`; Mac-local `MAC/Features/Tray/TrayFilter.swift` | PL-21(6), PL-14(e) | M | VERIFIED: phone stacks sections with a takes disclosure; the Mac's U-9 two-view + filter shape is not adopted. |

### 1h. Note actions and note metadata

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| N1 | Rename note | AppSpec §9 renameContainer | PRESENT (rough) | `MobileWriteView.swift:240-250, 334-344`; `MobileEditorViewModel.swift:1178-1195` | Core | PL-24(b) | S | VERIFIED: a system alert; errors print as raw `String(describing:)` (`:1193`); title `lineLimit(1)`. |
| N2 | Title quickfill (first line / date offered faint) | SurfaceContracts §The note (VX-569) | ABSENT | — | Mac-local `TitleQuickfill` | — | S | VERIFIED. |
| N3 | Entry date set/clear | AppSpec §9; Mac calendar picker (`CommitBar.swift:928-932, 1005-1027`) opening on `EntryDatePickerDay` | STALE | `MobileWriteView.swift:434-468` (text field "2026-08-09"); `MobileEditorViewModel.swift:1329-1350` | Core (`Domain/EntryDatePickerDay`) | — | S | VERIFIED: she types an ISO date into an alert. |
| N4 | Shift date a day earlier | AppSpec §9 `shiftEntryDate` (VX-587) | ABSENT | — | Core | PL-68 | S | VERIFIED. |
| N5 | Seal / unseal the note | AppSpec §9 lockPost; Mac words "Seal / Unseal" | PRESENT (rough) | `MobileWriteView.swift:687-704, 280-300`; `MobileEditorViewModel.swift:1159-1168, 1291-1312` | Core | — | S | VERIFIED: phone calls it "Lock Note" (recorded platform word); `unlockPost`'s `noteInSealedBook` refusal prints a raw enum dump (`:1309-1311`). Q4 on the word. |
| N6 | Delete note (to Trash) | AppSpec §9 deleteContainer | PRESENT | `MobileNoteActions.swift:288-296` | Core + Shared `RecoveryCopy` | — | — | VERIFIED. |
| N7 | **Archive note** | capability `.archiveNote`; Mac Library/Pool rows | ABSENT (half-door) | — (`VM/Features/Shell/MobileArchiveModel.swift:104-109` only UNarchives; Library long-press = Star + Delete, `MobileLibraryView.swift:501-517`) | Core | — | S | VERIFIED: the phone can take a note out of the Archive but never put one in. |
| N8 | Duplicate with tags / without tags | AppSpec §9 duplicateAsVersion (VX-383); `CommitBar.swift:884-892` | ABSENT | — | Core + Mac-local `NoteDuplicate` act, `DuplicateCopy` | PL-48 | S | VERIFIED. |
| N9 | Export Note (.md) | capability `.exportNote` (`MAC/Core/Views/NoteExport.swift`) | ABSENT | — (no share sheet anywhere in the phone) | Core (`Queries.variorumDocumentText`); act Mac-local | VM-30 (library-level sibling) | S | VERIFIED. Phone shape = share sheet (MobileSoul §5.7). |
| N10 | Copy full text | AppSpec §12 ("Copy full text… Variorum document format") | STALE (divergent format) | `MobileWriteView.swift:592-603`; `VM/Features/Write/MobileNoteClipboard.swift:9-17, 191-205` | Core (`Queries.exportPost` on the phone vs `Queries.variorumDocumentText` on the Mac) | — | S | VERIFIED: phone copies chosen-takes Markdown (no title, no tags, no alternates, following her R15 "copy should follow what's on the screen"); Mac copies the document format that re-imports whole (Q3). |
| N11 | Copy for AI | capability `.copyForAI` | ABSENT | — | Mac-local `CopyForAI` | — | S | VERIFIED; may be N/A (no MCP on phone). |
| N12 | Private mark (never shared with AI) | AppSpec §12 MCP rules; `container.ai_private_at` synced | ABSENT | — | Core (store truth) | PL-69 | S | VERIFIED: a phone user can neither see nor set it. |
| N13 | Star / unstar from inside the note | Mac note rows + ⌘K | ABSENT in Write | Library long-press only (`MobileLibraryView.swift:501-507`) | Core | — | S | VERIFIED. |
| N14 | Word count + per-note word target | AppSpec §9 setPostWordTarget; `CommitBar.swift:1031-1037` | ABSENT | — | Core (`TextMetrics` Shared, `setPostWordTarget`) | PL-35 | S | VERIFIED (zero phone references). |
| N15 | Created / edited stamps on the note (exact fact reachable) | SurfaceContracts §The Library/§The note (VX-351) | ABSENT | — | Core (`Domain/TimeStampFace`) | VM-22, PL-35 | S | VERIFIED: no stamp at all on the phone's note masthead. |
| N16 | Tags on the note | AppSpec §9 applyTag | PRESENT | `VM/Features/Write/MobileNoteTags.swift` | Shared (`TypedTagPath`) | — | — | VERIFIED. |
| N17 | Books holding the note; add / remove / diverge for book | AppSpec §9 readings | PRESENT | `VM/Features/Write/MobileMembership.swift` | Core | VM-6 (ownership choice sheet), VM-21 | — | VERIFIED. Ownership copy/move choice is the books reader's. |
| N18 | Move / Copy to Wing from the note | `CommitBar.swift:949-977` | ABSENT | — | Core + Mac-local `WingNoteDoors` | — | S | Cross-area: wings reader. |
| N19 | References: add URL, open, remove; file rows listed | AppSpec §7 reference; SurfaceContracts §The note | PARTIAL (ruled) | `VM/Features/Write/MobileReferences.swift:1-24` | Core | VM-12 ("more info" → "info") | — | VERIFIED. Side-by-side panel RULED-EXCLUDED; file bookmarks are local-only by model. |
| N20 | Receipts: kind on one seam, `receipt_style` quiet line, fades | SurfaceContracts §The app messages | STALE | `MobileWriteView.swift:316-323`; `MobileEditorViewModel.swift:981-984` | Core setting | PL-22 (18i face call, hers) | S | VERIFIED: one masthead line that never fades and is replaced only by the next report; refusals and receipts share it. |

### 1i. The note's modes

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| M1 | Mode row + per-note mode memory | SurfaceContracts §The note | ABSENT (no modes) | — | — | PL-19 | — | VERIFIED. |
| M2 | **Read mode for a note** (calm page, continuous or paged; `edit · read`) | SurfaceContracts §The note Read | ABSENT | — (phone Read exists for BOOKS only, `VM/Features/Read/MobileReadView.swift:1-26`) | Shared (`FlowParagraph`, `MarkdownRendering` core); paged `MAC/Features/ReadMode/NotePagesView.swift` Mac-local | PL-19 | M | VERIFIED. Not on the exclusion list (Q6). |
| M3 | Lenses | SurfaceContracts §The note Lenses | PARTIAL (ruled compromise) | `VM/Features/Takes/MobileLenses.swift:1-70` | Core | PL-19 | — | VERIFIED: switch, save view, save into, ✓ make this the note, rename, delete, loud fallback; board/scratch/promote/duplicate deliberately Mac-only. |
| M4 | Compare | SurfaceContracts §The note Compare | RULED-EXCLUDED (her 2026-11-12 reversal: wanted after v1) | — | see below | MobileSoul §4.5 | L | See "Compare brains". |
| M5 | Blocks workbench | SurfaceContracts §The note Blocks | PARTIAL | `MobileBlockList.swift` | Core | — | M | = B12 + B17. |
| M6 | Canvas | Debug-only on the Mac | RULED-EXCLUDED | — | — | MobileSoul §4.5 | — | — |

**Compare brains (record only, per brief).** Core: `Queries.blockKinship` (`CORE/Queries/TakesQueries.swift:235`),
`Queries.versionPeers` (`CORE/Queries/Lineage.swift:182`), `Queries.lineagePeers` (`CORE/Queries/LineagePeers.swift`),
`Domain/TextCompare` (word-level view-time compare), `Queries` note-version listing (`CORE/Queries/NoteVersions.swift`).
Mac-local, hoist owed before any phone Compare: `PostAlignment` (the lineage-keyed row registration,
`MAC/Features/Takes/TakesModels.swift:113`), `CompareComposition` (aligned vs free segments, up to four columns,
`MAC/Features/Takes/CompareModels.swift`), `LineDiff` (`MAC/Features/Takes/DiffView.swift:24`), `VersionCompareDoor`
(`MAC/Core/Views/VersionCompareDoor.swift`). Her swipe-tabs-aligned-block-by-block idea maps onto `PostAlignment.rows`
directly (each row = one swipe-synchronised position).

### 1j. Counts

E 22 · B 19 · T 12 · H 7 · V 2 · C 7 · R 1 · N 20 · M 6 = **96 rows** (counted from the table, first word of the
status cell): PRESENT 30 (several marked "rough") · PARTIAL 9 (M3/N19 are ruled compromises) · STALE 13 · ABSENT 38 ·
RULED-EXCLUDED 5 (B4, T9, V2, M4, M6) · INFERRED defect 1 (C6, device check owed).

---

## 2. What's there but behind

1. **Every touch target in the note is small, and none of the chrome scales.** VERIFIED: `tokens.small` is a fixed
   11.5 pt (`SH/Theme/VoiceTokens.swift:296, 369`); it sets every masthead chip, the copy/find/lock/⋯ glyphs (bare SF
   symbols at 11.5 pt with no padding, `MobileWriteView.swift:592-704`), the sealed line, the receipt and its Undo.
   Overlay sheets hard-code 10.5–13 pt type and 24–32 pt tall buttons: take card ⋯ 30×26 and ✓ 28×26
   (`MobileTakesBrowserView.swift:835-836`), Done 24 pt tall (`:318`), comment Edit/Delete/Restore 20 pt tall at
   11.5 pt (`MobileCommentsSheetView.swift:280-295`), the ●n comment marker 10.5 pt (`MobileBlockDecor.swift:207`).
   The formatting strip is 11 acts at 28×38 pt (`MobileKeyboardBar.swift:123, 252-288`) — her own R22 trade, but she
   now says "many of the button affordances are absolutely tiny". This is the area's clearest match to her words.
2. **The phone is in Terminal at 14 pt monospace by default** (`VM/Theme/MobileVoicePreference.swift:30-32`), ignores the
   synced voice and palette (two-parameter `resolve`, `MobileWriteView.swift:180`), so a Mac user in Study + sea-glass
   opens her phone to a different, smaller, mono note in Classic colours. INFERRED contributor to "weirdly tiny font".
3. **The keyboard bar is a full-width opaque band.** `configureWithOpaqueBackground()` with `backgroundColor =
   face.surface` (`MobileKeyboardBar.swift:514-520`) paints a band behind the three iOS 26 glass circles. INFERRED: this
   may be part of her "pale band around the quick click buttons rather than just the buttons" (her sentence most likely
   names the quick-entry band — another reader's — but the shape repeats here).
4. **Return and Backspace don't behave like a text editor.** Return mid-note never makes a paragraph block (E3); ⌫ at a
   paragraph's start refuses with a sentence naming Merge with Previous (E7). Divide and merge exist only behind caret +
   keyboard + ⋯. Paired with no block reorder (B12) and no "make every newline a block" repair (E6), a phone user's
   structure drifts from what the Mac would make of the same typing.
5. **VM-2 is still live** — the structural flight has no keystroke fence (E10); her phone's autocorrect can land in the
   window.
6. **The undo door mis-speaks** (VM-16) and says "It is saved first" (VM-20); New Block Below's receipt offers no Undo
   while the stack now holds one (B9, its comment asserting the opposite at `MobileStructural.swift:546-552`). Stale
   headers also still claim "Structural UNDO stays Mac-side in v1" (`MobileStructural.swift:52-54`) and "the phone has
   no structural undo" (`MobileMembership.swift:26-29`) — doc drift, not behaviour.
7. **History lives on the old face behind an odd door.** Block History is the Mac's retired panel shape, reachable only
   from a take card's ⋯ inside the takes browser (`MobileTakesBrowser.swift:264-288`) — so a single-take block's history
   is ⑂ → card ⋯ → Block History…, which closes the browser and opens a second overlay. Commit Take lives in the block
   ⋯ — the pair is split across two surfaces. Restore does not insure (VM-43). Commits cannot be named or renamed.
8. **Three different sheet grammars on one screen.** Takes browser, block history and comments are hand-built UIKit
   overlays with a fixed top (120/160 pt), dim-tap or Done only — no swipe-to-dismiss, no `accessibilityViewIsModal`
   (`MobileTakesBrowserView.swift:189`, `MobileBlockHistorySheetView.swift:115`, `MobileCommentsSheetView.swift:99`);
   membership/tags/more info/blocks/lenses/note actions are native SwiftUI sheets; prompts (rename, date, name block,
   label take, emoji) are system alerts with a text field.
9. **The masthead grows and never settles.** Title + membership row + a wrapping chip row + sealed line + a status line
   that never fades (`MobileEditorViewModel.swift:981-984`) push the first line of prose down; the status line keeps
   the last receipt or refusal until the next act. `receipt_style` is not read (PL-22).
10. **Note-level acts are thin.** The note ⋯ sheet holds five rows (Save a Version · Versions… · Undo · Redo · Delete
    Note…, `MobileNoteActions.swift:106-115`). Missing vs the Mac's `note ▾` (`CommitBar.swift:855-990`): Compare with
    Latest (ruled out), Duplicate ×2, Copy for AI, Export Note, Private, Make every newline a block, date picker, shift
    date, Move/Copy to Wing. Archive Note exists nowhere on the phone (N7).
11. **Raw error dumps survive** on rename, seal/unseal and entry date (`MobileEditorViewModel.swift:1193, 1310, 1345-1348`
    — `String(describing: error)`), e.g. unsealing a note in a sealed book.
12. **The comments sheet** drops a half-typed comment on close (VM-18), has the mis-placed placeholder (VM-14), no
    "Delete forever…" (PL-46), and (INFERRED) its draft field likely sits under the keyboard (C6).
13. **Tutorial teaches the retired divide default** (VM-3 still real: `VM/Features/Tutorial/MobileTutorialSeeder.swift:596-599`
    "copied onto both halves… quick to delete").
14. **Entry date is typed as text** ("2026-08-09") in an alert (N3) where the Mac has a calendar opening on the shared
    `EntryDatePickerDay` rule.
15. **Smart quotes/dashes ON, spellcheck squiggles ON** by iOS default (E15, E16) while the Mac's Write has both off —
    the same note gets different characters depending on which device typed them.
16. INFERRED, perf-adjacent (for the perf reader): `MobileWriteScreen.init` mints a full `MobileEditorViewModel` plus six
    other models on EVERY struct init (`MobileWriteView.swift:143-174`); `State(initialValue:)` keeps only the first, and
    each discarded editor model has already registered an observer on the shared per-post autosave coordinator
    (`MobileEditorViewModel.swift:225-232`) that only `teardown()` removes. This is the "autosave-registry leak" class
    VM-1 names (row 74), and extra work on the note-open road she reports as laggy. Not measured here.

---

## 3. Flow notes — how she gets around a note on the phone today

- **Open:** Library or shelf row → push Write (`MobileShellView.swift:457-468`), keyboard down (`focus: false`) except
  the Today/new-note roads. Lands at the session's remembered place, else the top (VM-10).
- **Masthead (always visible, scrolls with nothing):** title (tap → rename alert) · copy · find · lock · ⋯ (note sheet);
  books chip (sheet); chips date (alert) · tags (sheet) · more info (sheet) · blocks (sheet: in the note | archived |
  leaving = the tray) · lens (sheet).
- **Writing:** tap into prose → keyboard + bar `Aa · ⑂ · ⋯`. Aa swaps the bar to the 11-act strip; × swaps back; the
  strip resets on every keyboard hide.
- **Block acts:** only two roads, both needing the caret in a block: the bar's ⋯ (keyboard up) or the edit menu's
  `Block ▸` (tap the caret again / select). Reading with the keyboard down, there is no block door at all except the ⑂
  badge (fanned blocks only) and the ●n marker (commented blocks only).
- **Divide:** place caret → raise keyboard → ⋯ → Divide Block. **Merge:** caret in the LOWER block → ⋯ → Merge with
  Previous (⌫ at the seam refuses and tells her to do this). **Extract / Make Block:** select text → edit menu.
- **Takes:** ⑂ badge or bar ⑂ → browser overlay for that block; swipe a fanned paragraph to peek, ✓ in the pill to
  choose. Branching a non-displayed take needs a swipe to it first.
- **History:** ⑂ → a card's ⋯ → Block History… (browser closes, history overlay opens). Commit lives elsewhere (block ⋯).
- **Comments:** block ⋯ → Comments…, or the ●n marker. **Callout / Name:** block ⋯.
- **Versions:** note ⋯ → Versions… (pushed screen). **Tray:** blocks chip → archived / leaving.
- **Undo a structural act:** the receipt's Undo (until the next message replaces it) or note ⋯ → Undo X / Redo Y.
- **Awkward, in her terms:** acts hide behind the keyboard; commit/history split; history two levels deep inside
  another sheet; the tray behind a chip called "blocks"; no way to reorder paragraphs; every target small.

---

## 4. Open questions for the author (real product calls only)

**Q1 — The phone's Return model** (PL-21(1), PL-31; AppSpec: "The phone's Return model is its own").
(a) Adopt the Mac's chip-ON model through the shared `TypedReturn` (Return = new block / divide at word start / chain;
a bar or long-press door for the in-block newline). (b) Keep Return as content and add a visible "new paragraph block"
act on the bar, plus "Make every newline a block" as the repair. (c) Adopt (a) but default the chip OFF on the phone,
with the per-note chip in the masthead.

**Q2 — Backspace at a paragraph's start.** The Mac carves are ruled; the phone's absence is recorded "deliberately
unbuilt". (a) Build both (empty-block delete + texted-seam merge) exactly as the Mac. (b) Build only the empty-block
carve; keep the texted seam a deliberate merge.

**Q3 — What the phone's Copy copies.** (a) Keep her R15 phone rule: the chosen/peeked text as Markdown, title-less.
(b) Match the Mac's Copy full text (document format: title, tags, alternates; re-imports whole). (c) Both: "Copy
text" and "Copy with takes", the latter riding Export's share sheet.

**Q4 — The note seal's word.** The phone says "Lock Note"; the Mac says "Seal", books now have "Sealed", and "lock" also
names take locks and Castle's lock. (a) Unify on Seal/Unseal. (b) Keep the phone's Lock.

**Q5 — Where commit and history live** (her batch-9 move put history on each take card). (a) The VM-41 surface opened
from the block ⋯ with Commit beside it (the G2 pairing restored). (b) Keep history on the take card only. (c) Both doors.

**Q6 — A Read mode for one note.** (a) A masthead `edit · read` switch to a calm page (the book Read's page, one note).
(b) None — the phone's Write is its reading surface; Read stays book-only (record as a ruled compromise).

**Q7 — Divide presets when the block is fanned** (PL-21(3)). (a) A small sheet of three plain rows (keep on top · keep on
bottom · copy to both). (b) Keep the one default — her complexity-test doctrine says the phone may prove the presets
unnecessary.

**Q8 — Text substitution and spelling on the phone** (VX-438). (a) Mirror the Mac: quotes/dashes off, spellcheck off by
default, a setting. (b) Keep iOS defaults (phone-native expectation). (c) One synced setting both platforms read.

**Q9 — The comment marker** (PL-10, held). (a) Keep ●n at the last line's end. (b) Move to a left gutter mark like the
Mac. (c) A count on the block's trailing edge beside ⑂.

**Q10 — Closing the comments sheet with words in it** (VM-18, Needs Lillian). (a) Any close parks the draft (Mac
parity). (b) Done parks, dim-tap/swipe discards. (c) Ask before discarding.

**Q11 — Compare after v1** — scope only: is the target her swipe-tabs aligned block by block over `PostAlignment`, or
the takes diff (T8) first as the smaller compare?
