# VM-44 audit — reader G: the phone's visual metrics, extracted from code

Scope: the hard numbers behind what the designers will see in screenshots: type, touch targets, the quick-entry surface, spacing, colour and component consistency, and platform fit. Read-only and taken from `main` at `5dde1bcf9`. Paths are relative to `App/Variorum/VariorumMobile/` unless they start with `Shared/`, `Variorum/` (the Mac app, `App/Variorum/Variorum/`), `notes/` or `Spikes/`. `Spike/` and `Perf/` (debug harnesses) are excluded.

**Evidence labels.** VERIFIED means read in code, with file:line. INFERRED means derived, and the basis is stated. Tap-area heights are ESTIMATES built from three bases:
- one rendered line of `tokens.small` is 14 pt. This is pinned as measured at `Features/Shell/MobileShelfLayout.swift:110-113`.
- a 14 pt SF Mono line is about 17 pt, a 16 pt Iowan line about 20 pt, and a 19 pt title about 23 pt. These are INFERRED from the fonts' metrics.
- a book row measures 39 pt (`Features/Shell/MobileShelfView.swift:298-302`, measured).

The estimates are for the Terminal voice. Study rows run about 3 pt taller, because its body is 16 pt. iOS reference values used for comparison: the HIG's 44×44 pt minimum target, and the default text-style ramp (Large Title 34, Title 28/22/20, Headline 17 semibold, Body 17, Callout 16, Subheadline 15, Footnote 13, Caption 12/11). These are external facts from Apple's HIG, quoted from general knowledge.

---

## 0. The numbers that matter most

| Measure | Value |
|---|---|
| SwiftUI `.font(…)` call sites in the phone views | **352** |
| …of which are `tokens.small` (11.5 pt in both voices, fixed size) | **239 (68 %)**, plus 2 literal 11.5 pt sites, so **241 at 11.5 pt** |
| Sites under 15 pt | **Terminal 317/352 (90 %)** · Study 247/352 (70 %) |
| Sites that do not scale with Dynamic Type | **Terminal 347/352 (98.6 %)** · Study 258/352 (73 %) |
| Phone-specific type tokens | **none**. The phone wears the Mac's `VoiceTokens` unchanged (§1.1) |
| Distinct font sizes in use (Terminal, SwiftUI + UIKit) | **18**, seven of them between 10 and 13 pt |
| Tappable control sites inventoried | **107** (plus system-owned menus, alerts and nav back buttons) |
| …under 44 pt in at least one dimension | **103** (57 severe ≤24 pt · 28 moderate 25–35 pt · 18 marginal 36–43 pt) |
| …at or above 44×44 | **4** |
| Distinct padding values in use | **19** (2–48). No spacing scale or metrics constant exists |
| Distinct corner radii | **7** (3, 6, 8, 10, 12, 14, 22) |
| Contrast of `faint` / `muted` text on the room, Terminal light | **1.90:1 / 3.01:1** (WCAG small-text minimum 4.5:1), used at 174 text sites (§4.2) |

---

## 1. The type inventory

### 1.1 Where type comes from

All phone typography comes from four sources. Every one of them is either the Mac's or a literal.

**(a) The shared voice tokens.** These are `Shared/Theme/VoiceTokens.swift`, the same struct the Mac uses. VERIFIED: the phone's `Theme/` folder holds only `MobileVoicePreference.swift`, which is a voice switch and holds no metrics.

| Token | Terminal (light = dark) | Study (light = dark) | Scales with Dynamic Type? | Source |
|---|---|---|---|---|
| `small` | SF Mono **11.5** | SF Pro **11.5** | **No** (`.system(size:)`) | VoiceTokens.swift:296, 332, 369, 406 |
| `body` | SF Mono **14** | Iowan Old Style **16** | Terminal **No** · Study yes (`relativeTo: .body`) | :293, 329, 366, 403 |
| `title` | SF Mono **19** semibold | Iowan **21** semibold | Terminal **No** · Study yes (`.title2`) | :294, 330, 367, 404 |
| `heading` | SF Mono **15** semibold | Iowan **16** semibold | Terminal **No** · Study yes (`.headline`) | :295, 331, 368, 405 |
| `mono` | SF Mono **13** | SF Mono **12.5** | **No** | :297, 333, 370, 407 |
| `navigation` | 13 mono | 13 sans | No. **Unused on the phone** | :298, 371 |

`small` is the Mac's caption and sidebar-meta size (the doc at VoiceTokens.swift:154-160 names 13 / 11.5 as the Mac sidebar's register). The phone inherits every slot unchanged: **VERIFIED, no phone override exists**. On iOS, 11.5 pt sits between Caption 2 (11) and Caption 1 (12). The phone's whole chrome therefore runs at iOS caption size, and its row titles run at 14 pt in Terminal, below iOS Subheadline (15) and well below Body (17).

**(b) The reading page.** `ReadingPageTokens` (VoiceTokens.swift:434-450): serif **16** body and serif **25** semibold title, both `.system(size:)` and so **fixed**. The phone's paragraph face (`Features/Read/MobileReadPage.swift:164-175`) draws headings at 16× 1.6 / 1.35 / 1.15, which gives **26 / 22 / 18**, also fixed. It is the one place the phone deliberately went larger than the Mac (the comment at :160-162 says 16 here against the Mac's 15).

**(c) The UIKit editor face.** `Features/Write/MobileEditorStyle.swift:107-127`:
- editor body: Terminal mono **14**, Study Iowan **16**, both wrapped in `UIFontMetrics(.body)`, so they **scale**. The text view also sets `adjustsFontForContentSizeCategory = true` (`Features/Write/MobileEditorTextView.swift:933`). This is the **only** scaling text in Terminal apart from 5 text-style sites.
- `chrome`: mono **14** (Terminal) or sans **14** (Study), **fixed**. The keyboard bar and every UIKit sheet derive from it with `withSize(…)`, at **10.5 / 11.5 / 12 / 12.5 / 13 / 14 / 15**, all fixed (§1.3).

**(d) Literals in phone views** (VERIFIED, every one):

| Size / style | Where | file:line |
|---|---|---|
| `.system(size: 30, weight: .light)` | lock glyph on the lock screen; library-missing glyph | Features/Protection/MobileRoadFaces.swift:48 · MobileLibraryMissingView.swift:25 |
| `.system(size: 28, weight: .light)` | glyphs on the protection faces | MobileRoadFaces.swift:249, 308, 378 |
| `.system(size: 21, weight: .semibold, design: .serif)` | note title on the Read page | Features/Read/MobileReadView.swift:138 |
| `.system(size: 11.5, weight: .medium)` + tracking 2.5 | chapter caption on the Read page | MobileReadView.swift:74 |
| `.system(size: 11.5)` | truncation marker on the Read page | MobileReadView.swift:97 |
| `.system(size: 11)` | page meta ("3 of 12") on the Read page | MobileReadView.swift:155 |
| `.system(size: 10, design: .monospaced)` | **licence text** in Acknowledgments | Features/Protection/MobileAcknowledgmentsSheet.swift:59 |
| `.headline` / `.caption` / `.callout` (scale) | store-failure screen | MobileStoreFailureView.swift:35, 38, 42 |
| `.system(.footnote / .caption2, design: .monospaced)` (scale) | edit-trace diagnostics | Features/Write/MobileEditTrace.swift:562, 576 |
| UIKit `systemFont(ofSize: 13)` | callout emoji glyph in the editor | Features/Write/MobileBlockDecor.swift:241 |
| UIKit `systemFont(ofSize: 28)` + `preferredFont(.headline / .footnote)` | callout emoji picker | Features/Write/MobileEmojiField.swift:117, 122, 130 |

### 1.2 Distribution: how many uses at each size

SwiftUI call sites (352 total). VERIFIED by a script over every `.font(` in the phone tree. The per-file line lists are in Appendix A.

| Resolved size | Terminal | Study | Sites | Scales? |
|---|---|---|---|---|
| 10 | 10 mono | 10 mono | 1 | no |
| 11 | 11 | 11 | 1 | no |
| **11.5** | **11.5 mono** | **11.5 sans** | **241** (239 `small` + 2 literals) | **no** |
| 12.5 / 13 | 13 mono | 12.5 mono | 4 (`mono`, the twelve words) | no |
| 14 / 16 | **14 mono** | 16 Iowan | 70 (66 `body` + 4 `body` semibold) | Study only |
| 15 / 16 | 15 mono | 16 Iowan | 1 (`heading`) | Study only |
| 16 serif | 16 | 16 | 4 (reading page body + paragraph face) | no |
| 19 / 21 | 19 mono | 21 Iowan | 18 (`title`) | Study only |
| 21 serif | 21 | 21 | 1 | no |
| 25 serif | 25 | 25 | 1 | no |
| 28 / 30 light (glyphs) | — | — | 5 | no |
| text styles | — | — | 5 | yes |

UIKit font assignments (the editor's chrome, the keyboard bar, and the three hand-rolled overlay sheets):

| Size | Sites (file:line) | Used for |
|---|---|---|
| **10.5** | BlockDecor.swift:207 · CommentsSheetView.swift:310 | comment marker ●n in the text; comment date |
| **11.5** | CommentsSheetView.swift:234, 245, 287, 346/351 · BlockHistorySheetView.swift:363, 402, 511 | Edit / Delete / Restore / Cancel buttons; meta lines |
| **12** | BlockHistorySheetView.swift:194, 429, 480 · TakesBrowserView.swift:438, 713, 906 · TakesChrome.swift:223, 462 (+ bold :471) | take-card meta, choose ✓, ⑂ fan badge, pill text |
| **12.5** | CommentsSheetView.swift:204 · BlockHistorySheetView.swift:182, 375, 391, 506 · TakesBrowserView.swift:314 | the three overlays' **Done** buttons; history rows |
| **13** | CommentsSheetView.swift:195, 212, 220, 306 · BlockHistorySheetView.swift:175 · TakesBrowserView.swift:301 (+ footer and buttons :321, 328, 378) | overlay headers; comment draft and text; "+ new take" footer |
| **14** | KeyboardBar.swift:573, 629, 641, 740, 777, 830, 853 · TakesBrowserView.swift:739, 917 | every keyboard-bar act; take-card ⋯ |
| **15** | TakesChrome.swift:468 | takes pill ‹ › |
| editor body (scales) | BlockHistorySheetView.swift:361 · TakesBrowserView.swift:557, 811, 938 | take-card text; history title |

### 1.3 By screen: what is set where

All 11.5 entries are fixed. ★ marks text she reads or types as content, as opposed to chrome.

| Screen | Element | Font → size (Terminal / Study) | file:line |
|---|---|---|---|
| **Tab bar** (all roots) | "starred · shelf · library" doors | small → 11.5 | Features/Shell/MobileShellView.swift:600 |
| **Shelf** | path line "~/shelf · 6 books" | 11.5 | Features/Shell/MobileShelfView.swift:228 |
| | 🗑 · + new note · settings doors | 11.5 | MobileRecoveryDoors.swift:95 · MobileShelfView.swift:242, 251 |
| | book name | body semibold → 14 / 16 | MobileShelfView.swift:283 |
| | book meta (count · tags) | 11.5 | :294 |
| | ✎ today badge · + new book · ✎ today's entry | 11.5 | :411, 383, 438 |
| | empty state; report / error / star lines | 11.5 | :206; 117, 125, 136 |
| **Quick-note box** | ★ **typed text** | **small → 11.5** | Features/Shell/MobileQuickNote.swift:1243 |
| | placeholder "new note — just start typing · ⏎ opens it" | 11.5, faint | :1233 |
| | "✓ saved" indicator · "open ↵" door · boundary / error lines | 11.5 | :1286, 1297, 1167, 1176 |
| **Starred** | path; ★; kind word | 11.5 | Features/Shell/MobileStarredView.swift:96, 116, 124 |
| | name | body → 14 / 16 | :119 |
| **Library** | path · + new note · 🗑 | 11.5 | Features/Shell/MobileLibraryView.swift:203, 218 |
| | ★ **search field** (typed text and placeholder) | 11.5 | :232 |
| | filter doors "all · books · notes · bookless · scraps" | 11.5 **with `minimumScaleFactor(0.7)`, so they can shrink to 8.05 pt** | MobileListingFilters.swift:190, 193 |
| | sort glyph (SF Symbol) | 11.5 | MobileLibraryView.swift:298 |
| | note title / book name / hit title | body → 14 / 16 | :484, 356, 535 |
| | entry date / book meta / hit detail | 11.5 | :491, 362, 540 |
| | Archived row; empty / truncation lines | 11.5 | :179; 452, 462, 397, 524 |
| | scraps: ★ preview | body | Features/Shell/MobileScraps.swift:304 |
| | scraps: tags, pool picker, + new scrap | 11.5 | :310, 292, 327 |
| **Book contents** | book title | title → 19 / 21 | Features/Shell/MobileBookView.swift:233 |
| | chapter labels | 11.5 | :90 |
| | note title / date | 14 / 11.5 | :251 / :257 |
| | nav-bar "details" "read"; + new note / + new chapter rows | 11.5 | :142, 149; 218 |
| **Read (book)** | book title / note title / ★ body | 25 / 21 / **16 serif** (fixed) | MobileReadView.swift:61 / 138 / MobileReadPage.swift:170-173 |
| | chapter caption / page meta | 11.5 medium / **11** | MobileReadView.swift:74 / 155 |
| **Write masthead** | note title | title → 19 / 21 | Features/Write/MobileWriteView.swift:245 |
| | copy · find · lock · ⋯ icons (SF Symbols) | 11.5 | :598, 672, 699, 653 |
| | membership chip; date · tags · more info · blocks · lens chips | 11.5 | :515; 462, 480, 498, 543, 569 |
| | sealed line + Unlock; receipt + Undo / Redo | 11.5 | :288, 295; 319, 621, 634 |
| **Write surface** | ★ prose | editor body 14 / 16 (**scales**) | MobileEditorStyle.swift:110-125 |
| | ⑂ fan badge / ●n comment marker | 12 / **10.5** | TakesChrome.swift:223 / BlockDecor.swift:207 |
| | takes pill text / ‹ › | 12 / 15 | TakesChrome.swift:462 / 468 |
| | callout emoji | 13 | BlockDecor.swift:241 |
| **Keyboard bar** | Aa · ⑂ · ⋯; the strip's 11 acts | chrome 14 (fixed) | KeyboardBar.swift:573, 629, 740, 777, 830, 853 |
| **Takes browser** | header / Done / footer | 13 / 12.5 / 13 | Features/Takes/MobileTakesBrowserView.swift:301-328 |
| | card meta, ✓ / ⋯ / ★ card body | 12 / 14 / editor body | :713-739 / :811 |
| **Comments** | header / Done / draft / ★ comment text / date / Edit · Delete | 13 / 12.5 / 13 / 13 / **10.5** / 11.5 | Features/Write/MobileCommentsSheetView.swift:195, 204, 212, 306, 310, 287 |
| **Block history** | header / Done / rows / meta / act | 13 / 12.5 / 12.5 / 11.5 / 12 | Features/Takes/MobileBlockHistorySheetView.swift:175, 182, 375, 363, 480 |
| **SwiftUI sheets** (Tags, References, Membership, Note actions, Block list, Lenses, Book details, Create book, Tag manager) | sheet title / **Done** / rows / meta and doors | 19 / **11.5** / 14 / 11.5 | e.g. MobileNoteTags.swift:152, 156, 224, 238 (Appendix A lists every line) |
| | Block-list rows (★ the block's own words) | **11.5** | Features/Write/MobileBlockList.swift:521 |
| **Settings** | everything but the two voice rows | **11.5** (21 sites) | Features/Shell/MobileSettingsView.swift:92-365 |
| | voice rows | 14 / 16 | :525, 530 |
| **Trash / Archive** | titles / meta and every door | 14 / 11.5 | MobileTrashView.swift:241 / 136-281 · MobileArchiveView.swift:153 / 162, 171 |
| **Lock and protection** | titles / sentences / captions / fields and buttons | 19 / 14 / 11.5 / 14 | MobileRoadFaces.swift, MobileProtectionScreen.swift, MobileProtectionDoors.swift (Appendix A) |
| | ★ **the twelve words** | `mono` → **13 / 12.5** | MobileRoadFaces.swift:265, 269 · MobileProtectionScreen.swift:621, 625 |
| | licence text | **10** | MobileAcknowledgmentsSheet.swift:59 |

### 1.4 Flags

1. **Under 15 pt.** Every chrome element on every screen, and four content surfaces:
   - the quick-note text she types (11.5),
   - the Library search text (11.5),
   - the block-list rows (11.5),
   - the comment text (13).

   In Terminal, row titles, the editor prose and every keyboard-bar glyph are 14. VERIFIED (§1.3).
2. **Does not scale with Dynamic Type.**
   - In Terminal: everything except the editor body, the take-card text (UIKit `face.body`) and 5 text-style sites.
   - In Study: everything except `body`, `title` and `heading`.
   - The Read page is fixed in both voices.
   - No `@ScaledMetric` and no `dynamicTypeSize` handling exists. VERIFIED: grep finds only the editor's `adjustsFontForContentSizeCategory` (MobileEditorTextView.swift:933) and the emoji field's labels (MobileEmojiField.swift:118, 123).

   The phone's own doctrine says otherwise: "**Dynamic Type and VoiceOver are phone-native expectations** — the token layer should scale with the user's text size where it can" (`notes/MobileSoul.md:136-140`, owed at the parity round's Stage E). It is unmet.
3. **Mac-sized tokens inherited unchanged.** Every `VoiceTokens` type slot. The phone's only deviations from the Mac:
   - the editor body is wrapped in `UIFontMetrics`, at the same base values;
   - the editor paragraph gap is 1.0× the point size (Mac 0.5×) (MobileEditorStyle.swift:190);
   - the Read page is 16 against the Mac's 15.
4. **The build is smaller than the ratified mockups.** INFERRED from the files.
   - The look canon drew the phone in a **340 px-wide frame** (`Spikes/MobileMockups/mobile-look-v1.html:27`, v2 :27).
   - The build copied the mockup's pixel values as points onto a **402 pt** device (iPhone 17 Pro width, cited at KeyboardBar.swift:60). Relative to the screen, everything renders about **15 % smaller** than mocked.
   - Several values were also cut below the mockup:

   | Element | Mockup | Build |
   |---|---|---|
   | tab bar | 12.5 px (v1:65, v2:37) | 11.5 |
   | path line | 13 px (v1:52) | 11.5 |
   | masthead context row | 13 px (v1:72) | 11.5 chips |
   | book row | 14.5 px (v1:54) | 14 |
   | prose | 14.5 px (v1:77) | 14 |

   The editor's own header admits it: "the mockup's phone frames hint slightly larger — her on-device feel round rules" (MobileEditorStyle.swift:29-30).
5. **The shelf's layout brain is welded to 11.5 pt.** `MobileShelfLayout.smallLineHeight = 14` drives the quick-note box's line cap and the writing-floor guarantee, and it is test-pinned against the real fonts (MobileShelfLayout.swift:88-117, 214-221). Any type change on the shelf must update this brain and its pins. VERIFIED.
6. **Low-contrast tiny text.** See §4.2. Faint and muted ink at 11.5 pt makes small text read smaller still.

---

## 2. The touch-target inventory

**How these are built.** Almost every control is a `Button` with `.buttonStyle(.plain)` around a bare `Text` at 11.5 pt. With `.plain` the hit region is the label's own frame. Padding applied **outside** the button (Settings, path lines, the tab bar) adds no hit area. Padding **inside** the label plus `.contentShape(Rectangle())` does: that is the row pattern. VERIFIED per site below. Glyph widths at 11.5 pt SF Mono are about 6.9 pt per character (INFERRED, 0.6 em).

Verdicts: **S** = severe (≤24 pt tall) · **M** = moderate (25–35 pt) · **m** = marginal (36–43 pt) · **OK** = ≥44×44.

| ID | Screen / control | Built as (file:line) | Est. tap area (w × h) | |
|---|---|---|---|---|
| T1 | Tab bar: starred · shelf · library | plain `Text` 11.5; the bar's padding (top 12, bottom 8) sits outside the buttons. MobileShellView.swift:576-609 | 35–50 × **14** | S |
| T2 | 🗑 trash door (Shelf, Library) | plain glyph 11.5. MobileRecoveryDoors.swift:89-100 | 14 × 14 | S |
| T3 | Shelf "+ new note" | plain text. MobileShelfView.swift:234-246 | 70 × 14 | S |
| T4 | Shelf "settings" | plain text. :247-255 | 55 × 14 | S |
| T5 | Shelf book row | v11 inside the label + contentShape. :269-307 | full row × **39** (measured, :301-302) | m |
| T6 | ✎ today badge | h8 v3 chip, r6. :406-425 | 51 × 20 | S |
| T7 | "+ new book" row | v11 h12 + contentShape. :377-392 | full × 36 | m |
| T8 | "✎ today's entry" fallback row | same. :432-448 | full × 36 | m |
| T9 | book row long-press (pin · star · delete) | system context menu. :317-350 | n/a | — |
| T10 | Quick-note box, collapsed (tap to focus) | box contentShape + onTapGesture. MobileQuickNote.swift:1263-1273 | full−40 × **≈34** at rest | M |
| T11 | quick-note "open ↵" | plain text. :1293-1301 | 42 × 14 | S |
| T12 | Starred row | v10 h12 + contentShape. MobileStarredView.swift:110-130 | full × 37 (Study ≈40) | m |
| T13 | Library "+ new note" | plain text. MobileLibraryView.swift:209-222 | 70 × 14 | S |
| T14 | Library search field | `TextField`, v8 h12, r8. :229-246 | full−40 × 30 | M |
| T15 | filter doors ×5 (Library, Archive) | plain text 11.5, gap 11, scale 0.7. MobileListingFilters.swift:184-205 | 21–56 × 14 | S |
| T16 | sort glyph (`Menu`) | SF Symbol 11.5. MobileLibraryView.swift:282-304 | 13 × 13 | S |
| T17 | Library note row | v10 h12 + contentShape. :478-498 | full × 37 | m |
| T18 | Library book row | same. :348-370 | full × 37 | m |
| T19 | search hit row | same. :528-548 | full × 37 | m |
| T20 | "Archived" row | v11. :174-189 | full × 36 | m |
| T21 | scraps pool picker (`Menu`) | 11.5 label; padding outside the label (INFERRED: adds no hit area). MobileScraps.swift:284-299 | ≈ text × 14 | S |
| T22 | "+ new scrap" row | v11. :321-336 | full × 36 | m |
| T23 | Book nav bar "details" · "read" | system `ToolbarItem`s (font 11.5). MobileBookView.swift:134-150 | system cell | OK |
| T24 | Book contents note row | v10 h20. :246-266 | full × 37 | m |
| T25 | "+ new note" / "+ new chapter" rows | v11. :192-226 | full × 36 | m |
| T26 | Book Details "done" | plain. MobileBookDetails.swift:249-252 | 30 × 14 | S |
| T27 | Book name (rename) | semibold body, no padding. :366-376 | text × 17 | S |
| T28 | Finish / Reopen row | full width, **no vertical padding**. :388-407 | full × 17–28 | M |
| T29 | "Use as Daily Journal" | same. :411-429 | full × 17 | S |
| T30 | Delete Book… / Archive rows | same. :314-360 | full × 17–28 | M |
| T31 | Create Book close door | plain. MobileCreateBook.swift:206-209 | ≈ text × 14 | S |
| T32 | book-name field | v8 h12, body. :211-222 | full × 33 | M |
| T33 | kind doors "Book · Smart Book" | plain text 11.5. :284-294 | text × 14 | S |
| T34 | tag picker rows | v8 + contentShape. :323-350 | full × 33 | M |
| T35 | OR / AND doors | plain text. :352-362 | text × 14 | S |
| T36 | "Create Book" | full width, v12, r10. :235-256 | full × 41 | m |
| T37 | Read page: a note body opens Write | onTapGesture on the whole note. MobileReadView.swift:160-161 | note-sized | OK |
| T38 | Write title (rename) | title 19, plain. MobileWriteView.swift:240-250 | text × 23 | S |
| T39 | masthead **copy** icon | SF Symbol 11.5, plain, faint. :592-603 | **14 × 14** | S |
| T40 | masthead **find** icon | :667-677 | 14 × 14 | S |
| T41 | masthead **lock** icon | :687-704 | 14 × 14 | S |
| T42 | masthead **⋯** (note actions) | :648-658 | 14 × 14 | S |
| T43 | membership chip "~/journal" | plain text 11.5. :510-522 | text × 14 | S |
| T44 | date chip | :456-468 | text × 14 | S |
| T45 | tags chip | :475-487 | text × 14 | S |
| T46 | "more info" chip | :492-505 | text × 14 | S |
| T47 | "blocks" chip | :538-549 | text × 14 | S |
| T48 | lens chip | :557-578 (chips 12 apart horizontally, **4 pt** vertically: Features/Write/MobileChipFlow.swift:28-29) | text × 14 | S |
| T49 | "Unlock Note" (sealed line) | :289-298 | text × 14 | S |
| T50 | receipt Undo / Redo | :611-642 | text × 14 | S |
| T51 | ⑂ fan badge in the gutter | UIButton 26 × max(line, 18). Features/Takes/MobileTakesChrome.swift:216-223 | 26 × 17–25 | M |
| T52 | ●n comment marker | UIButton max(w, 20) × max(line, 18), 10.5 pt. MobileBlockDecor.swift:203-214 | 20–24 × 17–25 | M |
| T53 | takes pill ‹ › | 20 × 28. MobileTakesChrome.swift:479-492 | 20 × 28 | M |
| T54 | takes pill ✓ | 22 × 28. :497 | 22 × 28 | M |
| T55 | keyboard bar resting Aa · ⑂ · ⋯ | iOS 26 glass cells, measured 62 × 48 (comments at KeyboardBar.swift:318-335, 360-364, 411) | 62 × 48 | OK |
| T56 | formatting strip ×11 (× B I S ⟨⟩ 🔗 # • ☑ ⇥ ⇤) | exact width 28 (23 at the 320 pt Display Zoom width) × height 38. KeyboardBar.swift:123, 286-288, 684-690. **Her R22/R25 ruled the one-row shape knowing it breaks 44** (:129-141) | **28 × 38** | M |
| T57 | Takes browser "Done" | sizeToFit × **24**. MobileTakesBrowserView.swift:312-318 | 30 × 24 | S |
| T58 | "Branch this one ⧉" / "Blank ○" | height 32. :334-345 | text × 32 | M |
| T59 | "Turn takes into blocks" | height 26. :373-383 | text × 26 | M |
| T60 | take card ✓ choose | 28 × 26. :836 | 28 × 26 | M |
| T61 | take card ⋯ | 30 × 26. :835 | 30 × 26 | M |
| T62 | archived card ⋯ | 30 × 26. :953 | 30 × 26 | M |
| T63 | take card body (tap to edit) | label frame from y 30. :837-845 | full × ≈18–20 for a one-line take | M |
| T64 | Comments "Done" | × 24. MobileCommentsSheetView.swift:201-208 | 30 × 24 | S |
| T65 | comment draft field | height 40. :209-218 | full−96 × 40 | m |
| T66 | Add / Save | 52 × 40. :225-230 | 52 × 40 | m |
| T67 | Cancel (editing) | 52 × **20**. :232-237 | 52 × 20 | S |
| T68 | per-comment Edit / Delete / Restore; "deleted" fold | max(w, 40) × **20**, 11.5 pt. :280-295 | 40 × 20 | S |
| T69 | Block history "Done" | × 24. MobileBlockHistorySheetView.swift:179-186 | 30 × 24 | S |
| T70 | history row act (Restore, Bring back…) | × 26. :476-481, 520-527 | text × 26 | M |
| T71 | history rows (take header 34, quiet run 30, quiet 34) | fixed table heights. MobileBlockHistory.swift:346-356; selection :280 | full × 30–34 | M |
| T72 | every SwiftUI sheet's **Done** (Tags, References, Membership, Note actions, Block list, Lenses, Tag manager, Acknowledgments, Edit trace, Settings) | plain 11.5 text. MobileNoteTags.swift:155 · MobileReferences.swift:189 · MobileMembership.swift:223 · MobileNoteActions.swift:101 · MobileBlockList.swift:353 · MobileLenses.swift:579 · MobileTagManager.swift:260 · MobileAcknowledgmentsSheet.swift:30 · MobileEditTrace.swift:548 · MobileSettingsView.swift:95 | 30 × 14 | S |
| T73 | Tags: type field | v8 h12. MobileNoteTags.swift:179-195 | full × 30 | M |
| T74 | Tags: "✕ remove" | plain. :234-240 | text × 14 | S |
| T75 | Tags: suggestion rows | v4 + contentShape. :259-277 | full × 25 | M |
| T76 | References: link row | v6. MobileReferences.swift:247-263 | full × 29 | M |
| T77 | "+ add a link" | v8. :298-315 | full × 30 | M |
| T78 | Membership: diverge / remove | plain. MobileMembership.swift:292-305 | text × 14 | S |
| T79 | Membership: open copy | plain. :248-256 | text × 14 | S |
| T80 | Membership: "+ book" rows | v4. :333-349 | full × 25 | M |
| T81 | Note actions rows (Save version, Versions, Undo, Redo, Delete) | full width, title + detail, no padding. MobileNoteActions.swift:318-339 | full × 33+ | M |
| T82 | Block list: Select / Done picking | plain. MobileBlockList.swift:325-344 | text × 14 | S |
| T83 | Block list: segment doors (in the note · leaving · archived) | plain. :469-484 | text × 14 | S |
| T84 | Block list: "Delete N" | plain. :451-458 | text × 14 | S |
| T85 | Block list rows | **vertical padding 0** (2 while picking), 11.5 text, 1–2 lines. :498-535 | full × **14–28** | S |
| T86 | Tray: takes disclosure ▸ | plain. MobileNoteTray.swift:573-584 | text × 14 | S |
| T87 | Tray: Put back / Delete now | plain. :670-681, 699-721 | text × 14 | S |
| T88 | Lenses: "the note" row | **no padding, no contentShape**. MobileLenses.swift:673-687 | text × 17 | S |
| T89 | Lenses: lens rows | no contentShape. :689-711 | text lines × 33 | M |
| T90 | Lenses: restore / save / save into / adopt | plain. :734-791 | text × 14 | S |
| T91 | Versions: "back to listing" | plain. MobileVersions.swift:436-445 | text × 14 | S |
| T92 | Versions: version row | v10 + title + 2-line meta. :401-425 | full × ≈55 | OK |
| T93 | Versions: restore / promote / delete | plain. :483-512 | text × 14 | S |
| T94 | Trash: sort "newest first" | plain. MobileTrashView.swift:163-173 | text × 14 | S |
| T95 | Trash: **Empty Trash** | plain, alarm ink. :141-150 | text × 14 | S |
| T96 | Trash: kind filter doors | plain. :177-198 | text × 14 | S |
| T97 | Trash row: Put back · **Delete now** · Open note | plain, **18 pt apart**. :249-288 | text × 14 | S |
| T98 | Archive row: Unarchive · Open note | plain. MobileArchiveView.swift:157-176 | text × 14 | S |
| T99 | Settings voice rows | v8 h20 + contentShape. MobileSettingsView.swift:515-545 | full × 33 | M |
| T100 | Settings: Protection… · Acknowledgments · Manage Tags · Record edit trace · Edit trace… (+ DEBUG rows) | plain 11.5; **padding outside the button**. :150-160, 172-182, 196-206, 266-292, 303-369 | text × 14 | S |
| T101 | Settings sync row doors (shared `PageDoor`, phone arm) | `.act` v9 h14; `.inlineAct` v6. Shared/Theme/SharedPageStyle.swift:333-362 | 35 / 29 tall | M |
| T102 | Tag manager "+ new tag" | v11. MobileTagManager.swift:396-413 | full × 36 | m |
| T103 | Tag manager rows (acts are long-press only) | v9, no tap act. :359-394 | n/a | — |
| T104 | Lock / protection `MobileRoadButton` (Open, Face ID, Use the words, Start fresh) | body, v10 h16, r8. MobileRoadFaces.swift:404-428 | text+32 × 37–41 | m |
| T105 | passphrase / twelve-words fields | v11 h12, r8. :160-166, 189-200 | full × 39–43 | m |
| T106 | "use the twelve words" disclosure | plain 11.5. :178-186 | text × 14 | S |
| T107 | Protection screen doors | body text only. MobileProtectionScreen.swift:225-233 · MobileProtectionDoors.swift:66-76 | text × 17 | S |
| T108 | gate-style radio rows | full width, no padding. MobileProtectionDoors.swift:158-180 | full × 17–20 | S |
| T109 | library-missing "Start" door | v10 h16. MobileLibraryMissingView.swift:38-53 | text+32 × 37 | m |

System-owned, so they meet the platform's own metrics: alerts, every `UIMenu` (the block ⋯ menu, take ⋯, the # heading picker), context menus, the UIKit edit menu, the navigation back button, and the emoji picker sheet.

**Count.** 107 tappable control sites, of which **103 are under 44 pt** (57 severe, 28 moderate, 18 marginal) and 4 are OK (T23, T37, T55, T92). Counts are per control *site*. Per-row controls multiply on screen: a Trash screen of 10 rows draws 30 severe targets.

**Worst offenders by screen:**
- **Write masthead.** Four 14×14 icon doors in faint ink, 14 pt apart (T39–T42), and six 14 pt-tall chips stacked 4 pt apart vertically (T43–T48). This is the screen she lives on.
- **Tab bar.** The app's primary navigation is three 14 pt-tall words (T1).
- **Shelf and Library path lines.** 🗑 at 14×14 and "+ new note" / "settings" at 14 pt tall (T2–T4, T13), plus the sort glyph at 13×13 (T16).
- **Trash and Archive.** Restore and **Delete now** are 14 pt-tall words 18 pt apart (T97). A destructive act sits beside a restorative one at caption size.
- **The UIKit overlays.** "Done" is 24 pt tall on all three (T57, T64, T69). Comment Edit / Delete are 20 pt tall (T68). Take-card ✓ / ⋯ are 28×26 / 30×26 (T60–T61).
- **Settings.** Every row except the voice rows is a 14 pt-tall word (T100).
- **Block list.** Rows carry zero vertical padding (T85).

---

## 3. The quick-entry surface, dissected

### 3.1 Where it sits (the shelf's composition, VERIFIED)

`MobileShelfView.body` (MobileShelfView.swift:81-171) stacks, top to bottom:
1. the **path line** ("~/shelf · N books" plus 🗑, + new note, settings; padding h20, top 14, bottom 6; :225-260);
2. a `GeometryReader` region split by `MobileShelfLayout.split` into a **bounded, self-scrolling books list** and **the quick-note box** (:89-114);
3. up to three 11.5 pt status lines (:115-141);
4. the **tab bar** (:142).

The background throughout is `tokens.room`, ignoring the safe area (:144). The split is animated `.easeOut(0.18)` on focus (:113).

The layout brain's numbers (Features/Shell/MobileShelfLayout.swift):

| Constant | Value | Line |
|---|---|---|
| books shown before the list scrolls | 8 rows | :69 |
| books' maximum share of the region | 50 % | :74 |
| guaranteed writing lines (focused) | 6 | :88 |
| estimated book-row height | 42 | :104 |
| box chrome (padding + status row + spacing) | 56 | :108 |
| one line of `small` | 14 | :113 |
| minimum field lines | 3 | :117 |
| **collapsed region** = 14 + 56 | **70 pt** | :143-145 |
| expanded floor = 6 × 14 + 56 | **140 pt** | :95-97 |

### 3.2 The box itself (`MobileQuickNoteBox`, MobileQuickNote.swift:1141-1305)

| Property | Value | Line |
|---|---|---|
| Outer container | `VStack(spacing: 6)`, padding **h20, bottom 8** | :1153, 1181-1182 |
| Field | `TextField("", axis: .vertical)`, `.plain` style, **font `tokens.small` (11.5)**, ink `tokens.ink`, `lineLimit(1…lineCap)`, `.submitLabel(.return)` | :1241-1247 |
| Line cap | **1 at rest** (her 2026-08-30 ruling); when focused, the region allows up to (height − 56) ÷ 14 lines | :1212-1226, ShelfLayout :214-221 |
| Field frame when focused | `minHeight = writingHeight − 56`, so the whole area is the field's hit target | :1257-1259, 1278-1281 |
| Box padding | **h12, v10** | :1267-1268 |
| Border | `RoundedRectangle(cornerRadius: 8)`, **stroke `tokens.faint`, 1 pt, dash [4, 3]** (the Mac's "dashed cutout"). **No fill.** | :1269-1271 |
| Tap | contentShape + `onTapGesture { focused = true }` over the whole box | :1272-1273 |
| Placeholder | "new note — just start typing · ⏎ opens it" (MobileQuickNote.swift:56), **11.5 pt faint** (contrast 1.90:1 on the room in Terminal light), lowercased in Terminal, plus a **7×14 blinking block cursor** in accent when Terminal and not focused | :1230-1240; cursor MobileShelfView.swift:461-478 |
| Status row under the box | "typing… / saving… / ✓ saved" (11.5, faint, or accent when saved), Spacer, then the "open ↵" door (11.5, accent, plain, **42×14**) | :1283-1304; copy :56-91 |
| Hold and error lines | 11.5, faint / alarm, `lineLimit(3)` | :1162-1179 |
| Autofocus | **none** (deliberate: "raising a keyboard on every phone launch is hostile") | :1115-1118 |
| Return | ⏎ hands off: it opens the note (A5-1). The box holds **one** wrapped paragraph | :1124-1127 |

**What the eye gets at rest.** INFERRED from the numbers above: a 1 pt faint dashed rectangle about 34 pt tall (14 pt line + 10 + 10) and 362 pt wide on a 402 pt phone, with an 11.5 pt faint mono hint inside. Below it sits a 70 pt reserved region, and below that the tab bar. Three facts explain why "the box looks awkward":
1. the hint's 11.5 pt mono reads smaller than any other text on the shelf except the meta;
2. the faint dash at 1.90:1 is barely there;
3. the box is far shorter than the books' 39 pt rows, yet its dashed outline makes it the heaviest-looking object on the screen.

At 14 pt mono the hint (42 characters, about 8.4 pt each, so about 353 pt) would no longer fit on one line inside the 338 pt the box leaves. Any size increase needs shorter copy or a wrap rule.

### 3.3 Against the keyboard and the safe area

- **Shelf.** No `.ignoresSafeArea(.keyboard)` on the shelf. VERIFIED: grep finds `ignoresSafeArea(.keyboard)` only in MobileWriteView.swift:185. SwiftUI's default keyboard avoidance therefore shrinks the shelf's VStack, and the layout brain re-splits the smaller region (the comment at MobileShelfView.swift:84-88 says the reader carries "the keyboard's own inset").
  - The consequence (INFERRED from the VStack order at :82-143): while she types in the quick note, **the status lines and the three-word tab bar ride between the box and the keyboard**.
  - The field has **no input accessory**. VERIFIED: no keyboard-placement toolbar exists anywhere on the phone. The system keyboard sits directly under the tab bar.
- **The bottom safe area.** The tab bar sits inside the safe area with its own 12 / 8 padding (MobileShellView.swift:583-584), so it clears the home indicator. Its hairline top rule is a 1 pt rectangle in `tokens.line` (:586-588).

### 3.4 The "whole pale band around the quick click buttons"

**Finding.** No quick-action button group exists on the quick-entry surface. VERIFIED: the box's only control is the "open ↵" text door (T11). The one place where a group of quick buttons sits inside a band is **the editor's keyboard bar**, the `inputAccessoryView` above the keyboard in Write. INFERRED (strong) as what she means.

What draws the band (VERIFIED, Features/Write/MobileKeyboardBar.swift):
- **The view.** A `UIToolbar` built in `makeBar()` (:501-524), installed as the editor's `inputAccessoryView` (MobileEditorTextView.swift:993).
- **The paint.**
  - `UIToolbarAppearance.configureWithOpaqueBackground()` (:515), with `backgroundColor = face.surface` (:516).
  - The surface token is Terminal light **#FBFBF7**, dark #0C0D0C; Study light **#FFFFFF**, dark #14120F (VoiceTokens.swift:274, 310, 347, 384).
  - `shadowColor = face.line` (:517) draws a hairline at the band's top edge.
  - The same appearance is applied to standard, compact and scroll-edge (:518-520).
- **The size.** Full screen width, **52 pt tall**: a fixed 48 pt content row plus 4 pt of air, measured (:360-364, 425, 461).
- **The buttons inside it.** Three `UIBarButtonItem`s (Aa · ⑂ · ⋯) separated by flexible space (:590-603). iOS 26 wraps each one in its own **glass circle, measured 62×48** (:318-335, 361). Expanded, the eleven acts sit in **one glass capsule** about 328×48 (:621-700).
- **The result.** The bar draws an opaque pale strip across the full width between the text and the keyboard, and *also* draws a glass circle around each button. Those are the two layers her sentence separates: "a whole pale band … rather than just the buttons themselves".
- **Why it is like this.** The band was in the ratified mockup. `.kbar { background:#FBFBF7; border-top:1px solid #E4E4DC }` (`Spikes/MobileMockups/mobile-look-v2.html:41`, LK8 "A") was drawn before iOS 26 added a glass cell per item. The build kept the mockup's band and gained the system's circles on top of it.
- **Its vertical history** is documented at :312-424: her R7 / R12 complaint about the circles "touching the keyboard bar", the 4 pt air, and the 72 → 52 pt drop at her R22. Any restyle has to keep the measured 48 pt content row, because iOS anchors that row and it cannot shrink (:418-424).

If the designers find she meant something on the shelf instead, the only filled chip-like element near the box is the **✎ today badge** on the Journal row (r6, `tokens.surface` fill, `tokens.line` stroke, h8 v3; MobileShelfView.swift:406-425). Its fill against the room is 1.045:1, which is invisible, so it is unlikely to read as a "pale band". INFERRED.

### 3.5 Phone box vs the Mac's quick-entry band

The Mac's band is `Variorum/Features/Shelf/QuickEntryBar.swift`, placed at the Bookcase foot (`Variorum/Features/Shelf/ShelfView.swift:222-246`) and at the Library's foot (`Variorum/Features/Library/LibraryCatalogView.swift:285`).

| | Phone | Mac |
|---|---|---|
| Where | Shelf root only, between the books list and the tab bar | Bookcase foot **and** Library foot, under the cards band, above the ⌘K hint bar |
| **Typed text size** | **`tokens.small` 11.5** (MobileQuickNote.swift:1243) | **the editor body: mono 14 / Iowan 16** (`CaptureTextStyle`, Variorum/Core/Views/CaptureTextView.swift:186-191) |
| Placeholder | 11.5, faint, "…· ⏎ opens it" | **body**, faint, "new note — just start typing · ⏎ opens it · ⇧⏎ new paragraph" (QuickEntryBar.swift:223, 384-387) |
| Block cursor (Terminal) | 7 × 14 | 8 × 16 (:389-391) |
| Box | dashed faint [4, 3], r8, padding **h12 v10** | dashed faint [4, 3], r8, padding **h14 v12** (:428-432) |
| Outer margins | h20, bottom 8 | **h28, v10** (:470-471) |
| Paragraphs | one; ⏎ opens | many; ⏎ files and opens, ⇧⏎ new paragraph, ⌘⏎ files without opening (:413-424) |
| Height | 1 line at rest; on focus expands into the ruled half-screen (≥140 pt) | grows with content to **160 pt max**, then scrolls (:345) |
| Doors inside the box | none (the "open ↵" door sits under it) | **File ⌘⏎** button inside the dashed box, on its first line (:426, 505-526) |
| Title suggestion chip | absent (VERIFIED, no `suggestedTitle` on the phone) | present (:440-452) |
| Save indicator | "typing… / saving… / ✓ saved" row | none (filing is explicit) |
| Autofocus | never | on every Bookcase mount, through a non-stealing ask (:477-487) |
| Band background | room | none of its own; the column is `tokens.surface` (ShelfView.swift:246) |

The shape (dashed cutout, r8, faint) is shared. **Size and density are not**: the phone types at 82 % of the Mac's point size, with tighter padding, on a device held closer than a desktop screen. That is the opposite of the usual Mac → iPhone scaling.

---

## 4. Spacing, colour and component consistency

### 4.1 Is there a scale? No. VERIFIED.

- **Padding values in use** (count of sites): 2 (3) · 3 (1) · 4 (34) · 6 (15) · 8 (26) · 9 (1) · 10 (17) · 11 (7) · 12 (43) · 14 (13) · 16 (10) · 18 (5) · **20 (68)** · 22 (8) · 24 (15) · 28 (5) · 32 (3) · 40 (2) · 48 (4). That is 19 values. 20 is the de-facto screen gutter, but rows use 12 inside an outer 8 (Library, Shelf) or a flat 20 (Book contents).
- **Stack spacing values**: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 26, 28 (12 values).
- **Corner radii**:

  | Radius | Used by | Sites |
  |---|---|---|
  | 3 | callout swatch | MobileCallout.swift:90 |
  | 6 | today badge, acknowledgement cards, peek marker | MobileShelfView.swift:416 · MobileAcknowledgmentsSheet.swift:67 · MobileTakesChrome.swift:402 |
  | **8** | fields, buttons, the quick-note box | 16 sites |
  | 10 | Create Book button, take cards, callout wash, protection cards | MobileCreateBook.swift:248 · MobileTakesBrowserView.swift:658, 877 · MobileBlockDecor.swift:228 · MobileProtectionScreen.swift:637 · MobileRoadFaces.swift:281 |
  | 12 | read page | MobileReadView.swift:109 |
  | 14 | takes pill | MobileTakesChrome.swift:434 |
  | 22 | the three UIKit overlay sheets | MobileTakesBrowserView.swift:119 · MobileCommentsSheetView.swift:54 · MobileBlockHistorySheetView.swift:86 |
- **Row heights**: never declared. They emerge from padding:
  - v11 rows ≈36–39 (shelf book, "+ new …", door rows);
  - v10 rows ≈37 (Library, starred, book contents);
  - v9 ≈35 (tags); v8 ≈33 (settings voice, tag picker); v6 ≈29 (references); v4 ≈25 (suggestions, tray, membership);
  - v0 rows ≈14–28 (block list, book details, lenses).
  - The only declared heights are UIKit: the history table (30 / 34 / 52 / 56 / 62 / 84, MobileBlockHistory.swift:346-356), overlay buttons (20 / 24 / 26 / 32 / 40), and the keyboard bar (52).
- **No metrics module exists** (VERIFIED: no `Metrics` / `Spacing` / `Layout` type in `VariorumMobile/` or `Shared/`). `MobileShelfLayout` is the only geometry brain, and it is shelf-only.

### 4.2 Colour: the token layer holds well. Contrast is the problem.

**Literals that bypass the tokens** (VERIFIED, the complete list for phone views):
- `.foregroundStyle(.red)`: the editor canary line, "deliberately not the voice's alarm" (MobileWriteView.swift:278).
- `Color(.systemBackground)`: the store-opening frame (MobileStoreFailureView.swift:23).
- The callout wash palette as a **private hex table** "value-mirroring the Mac palette's hexes" (MobileCallout.swift:105-126), plus `UIColor.separator` on swatches (:96). This is a second copy of a Mac table.
- `Color.orange` / `Color.red` / `.red` in the shared page style's phone arm: warnings, error captions and the destructive door (Shared/Theme/SharedPageStyle.swift:105, 125, 337).
- Opacity derivations of tokens: `accent.opacity(0.12)` for the block-list pick (MobileBlockList.swift:534), `accent.opacity(0.85)` for scrap tags (MobileScraps.swift:311), and `ink` at α 0.25 for the overlay dims (MobileTakesBrowserView.swift:295, MobileCommentsSheetView.swift:189, MobileBlockHistorySheetView.swift:168).
- **The star is `accent`, not the `star` token.** `tokens.star`, "BLUE in every voice" (VoiceTokens.swift:128-134), is **never read on the phone** (grep finds zero uses). The ★ on Starred rows is accent (MobileStarredView.swift:115-117), which is green in Terminal.

**Contrast of the ink tokens on `room`** (WCAG ratios computed from the token hexes; INFERRED arithmetic):

| Voice | ink | muted | faint | accent | line (hairlines) | surface vs room |
|---|---|---|---|---|---|---|
| Terminal light | 13.9 | **3.01** | **1.90** | 4.59 | 1.18 | **1.045** |
| Terminal dark | 14.8 | 6.44 | 3.26 | 9.56 | 1.38 | 1.079 |
| Study light | 14.5 | **3.44** | **2.10** | 5.36 | 1.27 | 1.061 |
| Study dark | 16.4 | 6.30 | 3.58 | 8.65 | 1.43 | 1.123 |

Text-ink usage on the phone (VERIFIED counts of `foregroundStyle(tokens.X)`): **muted 130, faint 44**, accent 87, ink 77, alarm 29. UIKit adds `face.muted` at 42 sites.
- **Faint** is used for: inactive tab and filter words, the quick-note placeholder and box border, the masthead tool icons, and empty chips.
- **Muted** is used for: nearly every meta line and path line.

Both sit below 4.5:1 in light mode, mostly at 11.5 pt. The `surface` fills on fields, the today badge and button cards are about 1.05:1 against the room, so field and button **fills are effectively invisible in light mode**. Only the hairline at 1.18–1.27 draws them.

### 4.3 Palette, dark mode, both voices

- **Palette: not supported on the phone. STALE.**
  - Every phone token read goes through the **palette-less** two-parameter resolver, `.resolve(voice:dark:)` (VariorumMobileApp.swift:57 · MobileShellView.swift:179 · MobileWriteView.swift:180 · MobileSettingsView.swift:76 · MobileEditorStyle.swift:102). The token file defines that road as "the palette-less road by definition" (VoiceTokens.swift:231-244).
  - The Mac's contract is that "a store with no palette wears the sea-glass … the voice's shipped colours live on as Classic" (AppSpec §12; `Sources/VariorumCore/Queries/AppearanceQueries.swift:12-13`).
  - So the phone always shows **Classic**: Terminal's green and grey, or Study's blue and tan. The same synced store reads sea-glass on her Mac.
- **Dark mode: covered.**
  - SwiftUI resolves per `colorScheme` at every token site, and UIKit uses dynamic `UIColor` providers (MobileEditorStyle.swift:100-106). VERIFIED.
  - One gap, INFERRED: CGColor borders are resolved once at apply time, on the take cards, the pill and the comment draft (MobileTakesBrowserView.swift:709, 904 · MobileTakesChrome.swift:460 · MobileCommentsSheetView.swift:215), and no trait-change hook exists. A light/dark flip while one is on screen keeps the old border until the next render.
- **Both voices: covered, with one phone-local switch** (LK2).
  - The phone's default is **Terminal** (`Theme/MobileVoicePreference.swift:31-33`), while the Mac's fresh-store default is **Study** (AppSpec §12).
  - Terminal also **lowercases all chrome** (VoiceTokens.swift:304, 340) and sets it in mono, which reads smaller than the same point size in a proportional face.
  - Study's chrome is the same 11.5 pt, in SF Pro.

### 4.4 List-row anatomy, per list

| List | Row is a… | Title | Secondary | Padding (v / h) | ≈ height | Acts | file:line |
|---|---|---|---|---|---|---|---|
| Shelf books | Button + separate today badge | body **semibold**; invisible "› " column in Terminal | meta 11.5 muted | 11 / 12 (+8 outer) | 39 | long-press: Pin · Star · Delete | MobileShelfView.swift:266-351 |
| Library books | Button | body **regular**, no marker column | meta 11.5 | 10 / 12 (+8) | 37 | **none** | MobileLibraryView.swift:348-378 |
| Library notes | Button | body, 1 line | entry date 11.5 (undated: **nothing**) | 10 / 12 (+8) | 37 | long-press: Star · Delete | :478-518 |
| Search hits | Button | body | detail 11.5 | 10 / 12 | 37 | none | :528-548 |
| Book contents | Button | body | date 11.5 | 10 / **20** | 37 | none | MobileBookView.swift:246-266 |
| Starred | Button | ★ 11.5 + body | kind 11.5 faint | 10 / 12 | 37 | long-press: Unstar | MobileStarredView.swift:110-142 |
| Trash | **VStack, not a button** | body, 2 lines | meta 11.5, 2 lines | 10 / 12 | ≈60 | inline 11.5 links: Put back · Delete now · Open note | MobileTrashView.swift:239-297 |
| Archive | VStack, not a button | body, 1 line | — | 10 / 12 | ≈40 | inline links: Unarchive · Open note | MobileArchiveView.swift:150-182 |
| Tag manager | HStack, **not tappable** | #name body, indent 18 per depth | path 11.5 faint | 9 / 0 | 35 | **long-press only**: New Child · Rename · Delete | MobileTagManager.swift:359-394 |
| Settings | plain text links | 11.5 | — | 4 (outside) | 14 hit | tap | MobileSettingsView.swift:150-369 |
| Versions | Button | body | meta 11.5, 2 lines | 10 / 12 | 55 | tap = Read | MobileVersions.swift:401-425 |
| Lenses | Button, no contentShape | body ("› " when active) | meta 11.5 | 0 | 17–33 | long-press: rename · delete | MobileLenses.swift:673-711 |
| Block list | Button | **11.5** block handle, 2 lines | ⑂ 11.5 | **0** | 14–28 | tap = jump; picking mode | MobileBlockList.swift:498-535 |
| Tray | VStack | body preview | meta 11.5 faint + Put back | 4 / 0 | ≈40 | inline links | MobileNoteTray.swift:655-729 |
| Note tags | HStack | #leaf body | path 11.5 | 4 | 25 | "✕ remove" link | MobileNoteTags.swift:210-244 |
| References | Button (link) / VStack (file) | body accent | "opens" 11.5 | 6 | 29 | long-press: Remove | MobileReferences.swift:241-296 |
| Scraps | VStack, **not tappable** | body preview, 3 lines | tags 11.5 accent 85 % | 8 / 12 | ≈45–70 | none | MobileScraps.swift:301-316 |
| Take cards (UIKit) | UIView, r10, 1 pt border | meta chrome 12 | — | 8 / 12 | ≥60 | ✓ 28×26 · ⋯ 30×26 · body tap | MobileTakesBrowserView.swift:614-853 |
| Block history (UIKit) | table cell | chrome 12.5 | 11.5 | fixed heights | 30–84 | act button ×26 | MobileBlockHistorySheetView.swift:476-547 |

**The same thing built two ways** (VERIFIED):
1. **A book row on the Shelf vs in the Library.** Semibold vs regular weight, v11 vs v10, a marker column vs none, a long-press menu vs none (MobileShelfView.swift:269-307 vs MobileLibraryView.swift:348-370). The Library's own comment claims "one row rule" because the *words* are shared through `MobileShelfFaces`. The *anatomy* is not.
2. **A note row in four lists.** Library (button, date), Book (button, h20, no long-press), Archive (non-button with inline links), Trash (non-button, 2-line title plus meta plus links). There are four anatomies for one object.
3. **"Calm button" styles.** Five separately written versions of one idea, a surface fill plus a line stroke:

   | Version | Padding | Radius | Site |
   |---|---|---|---|
   | `PageDoor .act` | v9 h14 | r8 | SharedPageStyle.swift:334-346 |
   | `MobileRoadButton` | v10 h16 | r8 | MobileRoadFaces.swift:404-428 |
   | library-missing start door | v10 h16 | r8 | MobileLibraryMissingView.swift:38-53 |
   | Create Book | full width v12 | **r10** | MobileCreateBook.swift:235-256 |
   | today badge | v3 h8 | **r6** | MobileShelfView.swift:406-425 |
4. **Fields.** Three versions. Library search, tag field and Create Book name use v8 h12 with `surface` and `line` at r8 (MobileLibraryView.swift:229-246 · MobileNoteTags.swift:179-195 · MobileCreateBook.swift:211-222). `pageFieldChrome` and the lock-screen field use v11 h12 with `card` and `line` (SharedPageStyle.swift:157-172 · MobileRoadFaces.swift:207-214). The comment draft is a UIKit field 40 tall, r8 (MobileCommentsSheetView.swift:72, 209-218).
5. **Protection chrome helpers.** Two copies: `MobileProtectionChrome.door / line / caption` (MobileProtectionDoors.swift:37-86) and private `door / line / caption` in MobileProtectionScreen.swift:222-250.
6. **Sheet headers.** Every SwiftUI sheet hand-rolls "Title (19) … Done (11.5 text)" instead of a navigation bar. That is ten copies (T72's lines). The three UIKit overlays hand-roll a different header (13 pt label, 12.5 pt "Done", 24 pt tall).
7. **Choice controls.** Segmented choices are written as rows of 11.5 pt plain words, in five places: filter row, Trash kinds, block-list segments, Create Book kind, OR / AND. There is **no `Picker`, `Toggle`, `List` or `Form` anywhere on the phone** (VERIFIED by grep). The edit-trace on/off is a text button (MobileSettingsView.swift:266-280).

### 4.5 Sheets vs pushes vs menus vs overlays

| Pattern | Used for | Sites |
|---|---|---|
| **Push** (NavigationStack, system inline nav bar with back) | book contents, book Read, a note's Write, Trash, Archive, Versions, Protection | MobileShellView.swift:437-489 |
| **SwiftUI sheet** | Settings, Create Book, Book Details (detents medium / large), the note masthead's Membership, Tags, References, Blocks + Tray, Lenses, Note Actions (detents medium / large); Settings → Tag manager, Acknowledgments, Edit trace; protection sheets | MobileShellView.swift:266 · MobileShelfView.swift:393 · MobileBookView.swift:152-156 · MobileWriteView.swift:345-415 · MobileSettingsView.swift:382-390 |
| **Hand-rolled UIKit overlay "sheet"** (dim, r22 top corners, fixed top offset, **no grabber, no swipe-down**; closed by tapping the dim area or the 24 pt Done) | Takes browser (top 120), Comments (top 160), Block history (top 120) | MobileTakesBrowserView.swift:46, 119, 189 · MobileCommentsSheetView.swift:24, 54, 99 · MobileBlockHistorySheetView.swift:55, 86, 115 |
| **Alert with a text field** (rename, entry date, new chapter, new scrap, add link, save lens, tag create / rename) | text entry for single values | MobileWriteView.swift:334, 434 · MobileBookView.swift:160 · MobileScraps.swift:340 · MobileReferences.swift:219 · MobileLenses.swift:617 · MobileTagManager.swift:290-335 |
| **Context menu (long-press)** | the *only* road to Pin / Star / Delete on shelf rows, Star / Delete on note rows, Unstar, tag acts, reference Remove, lens acts | MobileShelfView.swift:317 · MobileLibraryView.swift:501 · MobileStarredView.swift:135 · MobileTagManager.swift:378 · MobileReferences.swift:290 · MobileLenses.swift:709 |
| **UIMenu** | the block ⋯ menu, take ⋯, # heading picker (long-press) | MobileKeyboardBar.swift:745, 784 · MobileTakesBrowserView.swift:808, 929 |
| **SwiftUI `Menu`** | the Library sort glyph; the scraps pool picker | MobileLibraryView.swift:283 · MobileScraps.swift:284 |

Sheet detents are declared on only 2 of the SwiftUI sheets (Note actions, Book details). All others open at the full large detent.

---

## 5. Platform-fit findings

1. **Desktop-density chrome.** Text-link verbs at caption size are the primary act everywhere: Put back, Delete now, Unarchive, Done, diverge, remove, Edit, Delete, settings, + new note. That is the Mac's sidebar register carried to a touch screen (§2: 57 severe sites). Five rows of plain words stand in for segmented controls (§4.4 item 7).
2. **No hover-only affordances.** VERIFIED: no `onHover` or `hoverEffect`. The Mac's hover equivalent became **long-press-only** acts. Pin, Star and Delete on book rows; Star and Delete on note rows; every tag act; reference Remove; and lens rename / delete have **no visible affordance** (§4.5). Tag-manager rows are not tappable at all (MobileTagManager.swift:359-394).
3. **No swipe actions.** VERIFIED: zero `swipeActions`. Lists are `LazyVStack`s of buttons, not `List`, so the iOS swipe-to-delete or star vocabulary is unavailable.
4. **No pull to refresh or pull to search.** VERIFIED: zero `refreshable` and zero `searchable`. Library search is a hand-rolled `TextField` at 11.5 pt (MobileLibraryView.swift:229-246), with no scope bar, no cancel and no recent searches.
5. **No large titles, and a double header on pushed screens.** Roots hide the nav bar and draw their own 11.5 pt path line (MobileShellView.swift:429). Pushed screens set **no `navigationTitle`** (VERIFIED: grep finds none) and keep the system inline nav bar, so Write, Book, Trash, Archive, Versions and Read each show an **empty system bar with a back chevron above the app's own masthead**. INFERRED from the code: the Write masthead adds title + membership + chip rows (MobileWriteView.swift:229-333) under that bar.
6. **No haptics.** VERIFIED: zero `sensoryFeedback` or `UI*FeedbackGenerator`. That covers choosing a take, deleting, sealing, filing the quick note, the band's page settle, and the keyboard-bar acts.
7. **Tab bar.** Three text-only words at 11.5 pt with no icons, ruled at **LK7 "A"** (`notes/plans/mobile-app-plan.md:286-287`). Its hit areas are glyph-sized (T1). A swipe band also pages between the three roots (MobileShellView.swift:183-264); the bar is its only visible index.
8. **Context menus are used where they fit** (rows), but they carry *destructive primary acts* that have no other door on that surface (Delete Book on the shelf, Delete Note in the Library).
9. **Keyboard avoidance.**
   - Write: correct. The text view's bottom is pinned to `keyboardLayoutGuide` (MobileEditorTextView.swift:1118-1123), with interactive dismissal (:935).
   - Takes browser: handles the keyboard explicitly (MobileTakesBrowserView.swift:196-206).
   - **Comments overlay: no keyboard handling** (VERIFIED: no keyboard notification in MobileCommentsSheetView.swift). It is framed to the full surface, which ignores the keyboard (MobileWriteView.swift:185; MobileCommentsSheetView.swift:148-151), and its draft field sits at the sheet's bottom − 56 (:209-218). INFERRED: the field is covered by the keyboard while she types a comment. Confirm on device.
   - Shelf: the tab bar rides above the keyboard while the quick note is focused (§3.3).
10. **Safe areas.** Rooms extend under the safe areas through `background(...ignoresSafeArea())` on every root (e.g. MobileShelfView.swift:144). Content stays inside. The editor's text inset is 8 / 15 (MobileEditorTextView.swift:953).
11. **Dynamic Type, Display Zoom.** See §1.4 item 2.
    - The only Display Zoom accommodation is the keyboard strip narrowing to 23 pt at 320 pt width (KeyboardBar.swift:143-192).
    - The filter row can shrink to 70 % (8.05 pt) (MobileListingFilters.swift:193).
    - The Settings sheet is a non-scrolling `VStack` (VERIFIED: no `ScrollView` in MobileSettingsView.swift; body :89-381). It cannot grow with larger text without clipping.

---

## 6. Open questions for the author (real calls only)

1. **The keyboard strip's 28 pt acts (her R22/R25).** She ruled eleven acts on one row knowing they fall under 44 (MobileKeyboardBar.swift:129-141). Does that ruling stand in the redesign? Options:
   - (a) keep it;
   - (b) two rows, accepting a taller bar;
   - (c) fewer acts on the strip, with the rest in a menu.
2. **The keyboard bar's band.** Options:
   - (a) drop the opaque band and let iOS 26's glass buttons float;
   - (b) keep a band but draw no per-button circles (one capsule, a look change she reserved, :352-355);
   - (c) keep both as built.
3. **The text-only tab bar (LK7).** Options:
   - (a) keep it text-only but larger, with real hit areas;
   - (b) icons plus words (the v2 mockup's rejected "B/C");
   - (c) the system tab bar.
4. **The phone's default voice.** Terminal on the phone (MobileVoicePreference.swift:31-33) against Study on a fresh Mac store. Options:
   - (a) keep Terminal;
   - (b) default to Study to match the Mac;
   - (c) follow the synced `theme_voice`. This reverses LK2's phone-local switch, so it is her call.
5. **Palette on the phone.** The phone always shows Classic, while her Mac's store shows sea-glass. Options:
   - (a) follow the synced palette (the Mac's four-parameter road);
   - (b) a phone-local palette like the voice;
   - (c) stay Classic.

---

## 7. One page for the designer

**The type scale as built** (Terminal; Study in brackets where it differs). Only the Terminal editor prose, Study's body / title / heading, and 5 text-style sites scale with Dynamic Type.

| pt | Role as built | Sites |
|---|---|---|
| 10 | licence text | 1 |
| 10.5 | comment marker ●n; comment date (UIKit) | 2 |
| 11 | Read page meta | 1 |
| **11.5** | **all chrome**: tab bar, path lines, every door, chip, meta, the Settings rows, **the quick-note text, the Library search text, block-list rows** | **241** + 7 UIKit |
| 12 / 12.5 | UIKit overlay meta; overlay Done; the twelve words (12.5 Study) | ~14 |
| 13 | overlay headers; comment text; the twelve words | ~10 |
| **14** [16] | row titles, editor prose, keyboard-bar glyphs | 70 + editor + 9 UIKit |
| 15 [16] | one heading; pill arrows | 2 |
| 16 serif | Read body | 4 |
| 18 / 22 / 26 serif | Read headings | (paragraph face) |
| 19 [21] | screen and sheet titles | 18 |
| 21 / 25 serif | Read note / book titles | 2 |
| 28 / 30 light | protection glyphs | 5 |

**Gaps against an iOS-native phone ramp** (gaps only; the design pass proposes the scale):
- nothing between 11.5 (chrome) and 14 (rows) in SwiftUI chrome, and no 13 pt footnote tier for chrome;
- nothing at 15–17 for primary list text in Terminal: row titles are 14, against iOS Body 17 and Subheadline 15;
- no 17 pt body anywhere except the Study voice's 16;
- 7 distinct sizes are crowded between 10 and 13;
- the editor prose (14 mono) is smaller than iOS Body;
- content she *types* outside the editor (the quick note, search, tag field) uses the chrome size;
- no Dynamic Type for chrome, rows or the Read page;
- no title tier between 19 and 25 outside the Read page;
- no large-title tier.

**Sub-44 pt targets: 103 of 107** control sites (57 at 24 pt or less, 28 at 25–35, 18 at 36–43). Only the keyboard bar's resting trio, the system nav items, the Read page note body and the Versions row clear 44×44.

**The ten most visible metric problems:**
1. **All chrome is 11.5 pt**, the Mac's caption size, carried unchanged: 241 SwiftUI sites, 68 % of all type. In Terminal it is also mono and lowercased. (VoiceTokens.swift:296, 332, 369, 406)
2. **The quick-note box types at 11.5 pt.** That is the home screen's main writing area, at 82 % of the Mac's own quick entry (MobileQuickNote.swift:1243 vs Mac CaptureTextView.swift:186-191). It sits in a faint 1 pt dashed outline (1.90:1) about 34 pt tall at rest.
3. **The keyboard bar draws a full-width opaque pale band** (`face.surface`, 52 pt, hairline top) around three iOS 26 glass circles. That is two backgrounds for three buttons, and it is her "pale band" (MobileKeyboardBar.swift:515-517).
4. **The Write masthead's four tool icons** (copy · find · lock · ⋯) are 11.5 pt SF Symbols in faint ink with **14×14 pt** targets. Six 11.5 pt chips are stacked 4 pt apart vertically below them (MobileWriteView.swift:255-276, 592-704; MobileChipFlow.swift:28-29).
5. **The tab bar** is three 11.5 pt words with glyph-sized hit areas, about 14 pt tall, with inactive words at 1.90:1 (MobileShellView.swift:576-609).
6. **Inline text-link verbs** at 14 pt tall are the primary act on Trash, Archive, Tray, Versions, Membership, Tags and Settings. **Delete now sits 18 pt from Put back** (MobileTrashView.swift:249-288).
7. **List rows sit under 44.** Library, book, starred and search rows are about 37. Shelf book rows are 39. "+ new …" rows are 36. Block-list rows are 14–28, with zero padding. Book-details rows are 17–28.
8. **The UIKit overlays.** "Done" is 24 pt tall. Comment Edit / Delete are 20 pt tall. Take-card ✓ / ⋯ are 28×26 / 30×26. The pill's ‹ › ✓ are 20–22×28. The comment marker is 10.5 pt. There is no grabber and no swipe-to-dismiss.
9. **Low contrast at small size.** `muted` is 3.0:1 and `faint` is 1.9:1 in Terminal light, across 174 text sites plus 42 UIKit. Field and button fills are invisible (`surface` vs room 1.045:1).
10. **No spacing system and duplicated components.** There are 19 padding values, 7 radii, five "calm button" builds, three field builds, four note-row anatomies, ten hand-rolled sheet headers, no `List` / `Picker` / `Toggle`, no swipe actions, no haptics, and no palette (the phone is always Classic while her Mac shows sea-glass).

---

## Appendix A: every SwiftUI `.font(…)` and UIKit font size, by file (VERIFIED, line numbers)

`small` = 11.5 fixed · `body` = 14 mono / 16 Iowan · `title` = 19 / 21 · `mono` = 13 / 12.5 · `heading` = 15 / 16. Generated by script over the tree at `5dde1bcf9`. Comment lines are excluded.

| File | Fonts (×count: lines) |
|---|---|
| `Features/Protection/MobileProtectionScreen.swift` | **small** ×15: 60,68,138,246,366,377,385,416,483,493,499,509,547,557,576 · **body** ×12: 227,239,304,360,445,452,469,477,552,587,592,653 · **title** ×2: 335,650 · **mono** ×2: 621,625 · **body semibold** ×1: 564 |
| `Features/Protection/MobileRoadFaces.swift` | **body** ×8: 164,197,218,255,312,381,387,416 · **small** ×7: 68,130,155,183,226,283,348 · **title** ×3: 102,117,252 · **.system(28, light)** ×3: 249,308,378 · **mono** ×2: 265,269 · **.system(30, light)** ×1: 48 |
| `Features/Shell/MobileSettingsView.swift` | **small** ×21: 92,99,109,121,142,154,176,192,200,262,273,286,299,307,317,325,334,342,350,365,534 · **body** ×2: 525,530 |
| `Features/Shell/MobileLibraryView.swift` | **small** ×16: 101,110,120,179,203,218,232,298,327,362,397,452,462,490,524,540 · **body** ×3: 356,484,535 |
| `Features/Protection/MobileProtectionDoors.swift` | **body** ×10: 46,69,101,151,170,373,504,509,665,742 · **small** ×6: 40,53,60,90,127,671 · **title** ×1: 81 · **body semibold** ×1: 577 |
| `Features/Write/MobileWriteView.swift` | **small** ×16: 278,288,295,319,462,480,498,515,543,569,598,621,634,653,672,699 · **title** ×1: 245 |
| `Features/Write/MobileVersions.swift` | **small** ×11: 387,390,413,440,451,454,487,497,507,529,543 · **body** ×2: 409,466 |
| `Features/Shell/MobileBookDetails.swift` | **small** ×7: 250,270,329,351,379,400,422 · **body** ×4: 325,347,394,417 · **title** ×1: 246 · **body semibold** ×1: 371 |
| `Features/Shell/MobileShelfView.swift` | **small** ×11: 117,125,136,206,228,242,251,294,383,411,438 · **body** ×1: 278 · **body semibold** ×1: 283 |
| `Features/Shell/MobileTrashView.swift` | **small** ×12: 136,146,154,168,186,207,222,226,245,254,268,281 · **body** ×1: 241 |
| `Features/Takes/MobileLenses.swift` | **small** ×10: 580,589,607,701,729,739,747,765,776,788 · **body** ×2: 680,697 · **title** ×1: 576 |
| `Features/Write/MobileMembership.swift` | **small** ×9: 224,237,243,253,276,288,295,302,317 · **body** ×2: 283,340 · **title** ×1: 220 |
| `Features/Write/MobileNoteTray.swift` | **small** ×10: 486,580,600,605,618,666,674,695,704,717 · **body** ×2: 661,689 |
| `Features/Shell/MobileCreateBook.swift` | **small** ×8: 207,225,233,288,299,333,340,357 · **body** ×3: 213,244,337 · **title** ×1: 203 |
| `Features/Takes/MobileBlockHistorySheetView.swift` | UIKit **12.5** ×4: 182,375,391,506 · **12** ×3: 194,429,480 · **11.5** ×3: 363,402,511 · **13** ×1: 175 · editor body ×1: 361 |
| `Features/Write/MobileBlockList.swift` | **small** ×10: 333,357,447,456,476,492,515,521,528,543 · **title** ×1: 312 |
| `Features/Shell/MobileBookView.swift` | **small** ×9: 90,102,111,125,142,149,218,237,257 · **title** ×1: 233 · **body** ×1: 251 |
| `Features/Write/MobileNoteTags.swift` | **small** ×7: 156,167,185,215,229,238,255 · **body** ×2: 224,269 · **title** ×1: 152 |
| `Features/Write/MobileReferences.swift` | **small** ×6: 190,199,209,256,272,306 · **body** ×3: 252,268,282 · **title** ×1: 186 |
| `Features/Takes/MobileTakesBrowserView.swift` | UIKit **12** ×3: 438,713,906 · editor body ×3: 557,811,938 · **14** ×2: 739,917 · **13** ×1: 301 (and its `chrome` local at 307,321,328,378) · **12.5** ×1: 314 |
| `Features/Read/MobileReadView.swift` | page.serif (16) ×3: 89,102,150 · page.serifTitle (25) ×1: 61 · **small** ×1: 66 · .system(11.5, medium) ×1: 74 · .system(11.5) ×1: 97 · .system(21, semibold, serif) ×1: 138 · paragraph face ×1: 143 (16/18/22/26: MobileReadPage.swift:164-175) · .system(11) ×1: 155 |
| `Features/Write/MobileCommentsSheetView.swift` | UIKit **11.5** ×4: 234,245,287,351 · **13** ×3: 195,212,220 · **12.5** ×1: 204 · row sizes passed as parameters: 12 (:301), 13 (:306), **10.5** (:310), 11.5 (:346) |
| `Features/Write/MobileEditTrace.swift` | **small** ×6: 544,550,571,595,604,615 · .system(.footnote, mono) ×1: 562 · .system(.caption2, mono) ×1: 576 |
| `Features/Shell/MobileArchiveView.swift` | **small** ×7: 102,105,121,136,140,162,171 · **body** ×1: 153 |
| `Features/Write/MobileKeyboardBar.swift` | UIKit chrome **14** ×7: 573,629,641,740,777,830,853 (link glyph sized to it: 656) |
| `Features/Shell/MobileScraps.swift` | **small** ×6: 256,267,275,292,310,327 · **body** ×1: 304 |
| `Features/Shell/MobileTagManager.swift` | **small** ×5: 261,272,281,370,403 · **title** ×1: 257 · **body** ×1: 364 |
| `Features/Protection/MobileLibraryMissingView.swift` | **small** ×3: 57,64,73 · **body** ×2: 32,42 · .system(30, light) ×1: 25 · **title** ×1: 28 |
| `Features/Shell/MobileQuickNote.swift` | **small** ×6: 1167,1176,1233,**1243 (the typed text)**,1286,1297 |
| `Features/Shell/MobileStarredView.swift` | **small** ×5: 61,79,96,116,124 · **body** ×1: 119 |
| `Features/Protection/MobileAcknowledgmentsSheet.swift` | **small** ×3: 27,34,55 · **body** ×1: 46 · **heading** ×1: 52 · .system(10, mono) ×1: 59 |
| `Features/Write/MobileEditorStyle.swift` | UIKit: editor body mono 14 scaled (111) / Iowan 16 scaled (118-125); chrome mono 14 (112) / sans 14 (126), both fixed |
| `Features/Write/MobileNoteActions.swift` | **small** ×3: 102,176,328 · **title** ×1: 98 · **body** ×1: 325 |
| `MobileStoreFailureView.swift` | .headline 35 · .caption 38 · .callout 42 (all scale) |
| `Features/Write/MobileEmojiField.swift` | UIKit preferredFont .headline 117 / .footnote 122 (scale) · systemFont 28: 130 |
| `Features/Takes/MobileTakesChrome.swift` | UIKit **12** ×2: 223,462 (bold 471) · **15** ×1: 468 |
| `Features/Write/MobileBlockDecor.swift` | UIKit **10.5**: 207 · systemFont 13 (emoji): 241 |
| `Features/Shell/MobileListingFilters.swift` | **small**: 190 (minimumScaleFactor 0.7: 193) |
| `Features/Shell/MobileRecoveryDoors.swift` | **small**: 95 |
| `Features/Shell/MobileShellView.swift` | **small**: 600 (tab bar) |
