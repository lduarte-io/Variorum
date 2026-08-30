# The phone's archive / trash design session — the record

**Status: PROPOSE-ONLY. Nothing here is built and nothing here is decided.**
Written 2026-08-30 at her explicit authorization, as the design session
`MobileSoul` **PL-14(b)** reserved.

**The mockups:** `proposal.html` in this directory — one self-contained
page, no external requests, theme-aware.
**Published for her to view:**
*[removed for publication]*
(private until she shares it; republishing the same file path updates that
same URL).

**Her ruling that created this session, verbatim:**

> *"the phone will also have archive and delete separated and on mimicking
> the surfaces that the mac has decided on, in some way that works for
> mobile (make a note that it can have a design session and propose
> different designs to me with html when the time comes)"*

**What it decides, once she rules:** mobile round 2's **batch 6c** — the
phone's archive/trash IA separation (`§69.5`) and the **Versions** face's
door and listing shape (`§69.6`). 6a and 6b are unaffected: their design
was fully ruled by `§69` and they build without her.

---

## 1. What was read, in full, before anything was drawn

- `notes/plans/mobile-round-2.md` **§69** — batch 6's inherited design;
  §69.1's five-places map is the tie-breaker used throughout.
- `notes/plans/post-13l-polish-round.md` — **the Mac's decided surfaces**:
  her rulings A1–A7 / B1–B2 / C1–C2 / D1–D2, the architect's V1–V9 review
  pass, the ledger (rows 1–33), and **THE LIFECYCLE TABLE**.
- `notes/MobileSoul.md` in full — §2 the bar, §3 brains-in-core, §4 the
  decision grammar and the complexity test, §5 the platform truths, and
  the ledger rows **PL-11**, **PL-13**, **PL-14**.
- The phone's shipped surfaces, read directly (§6 below).

## 2. The four options

**They are numbered by how much of the phone's shape moves** — from the
insides of one screen out to the phone's top level. Higher is bigger, not
better; the numbering is the ordering axis, not a ranking.

| # | name | what moves | Archive lives | the Trash lives |
|---|------|------------|---------------|-----------------|
| 1 | **One past screen** | one screen's insides — no new doors | a segment | the other segment |
| 2 | **Two rooms** | a screen's doors — two new doors, two new screens | its own pushed screen; door = the Library's trailing row, narrowed to `archive` | its own pushed screen; door = a 🗑 glyph in the path line |
| 3 | **Follow the phone's own precedent** <br>*(recommended)* | the phone's **areas mechanism** — one filter, one glyph, one row retires | the Library's `archived` **filter** | its own pushed screen; door = a 🗑 glyph |
| 4 | **The third tab** | the phone's **top level** — new permanent chrome | a segment of a new `keep` tab | the other segment |

**Versions, the tray and Block History are the same in all four** — they
are note- and block-scale, and they live where their subject lives. The
page draws them once, in a shared section.

### What each is worse at

- **1 — One past screen.** One door still claims the two are the same kind
  of thing — the exact claim her B2 ruling separated. A segment is a weaker
  statement than a room (you must press it to learn the difference), and
  the door needs a name covering both, which is how `"Archived & Deleted"`
  got its awkward name. **Cheapest and least committed.**
- **2 — Two rooms.** Spends the phone's two most crowded strips at once
  (the path line is deliberately two doors wide — P38's crowding lesson,
  cited in the shipped code). And the Archive door is still the **last row
  of a scrolling list**: you scroll past everything you didn't archive to
  reach what you did. That is the phone's version of *"just going to the
  library you get a little lost."* It fixes the conflation and leaves the
  findability.
- **3 — Precedent.** Three real costs: **(a)** the filter row is at its
  width budget — four text doors + a sort control at 390 pt, and Dynamic
  Type breaks it first; **(b)** an archived note sits one tap from the live
  listing, so a mis-tap lands in an unfamiliar list; **(c)** "trash" leaves
  the Library's surface as a *word* and becomes a glyph, which is a worse
  door for a rare, urgent visit.
- **4 — The third tab.** Permanent chrome for a rarely-and-urgently visited
  room, against a two-word tab bar that is part of the phone's calm. And it
  is the **only option that misreports the map**: three places at the top
  level, two in context, so a new user concludes there are three. Its
  footer explainer is a patch over that, and chrome needing a sentence to
  explain itself is a sign the chrome is wrong.

### Five-places coverage

All four can express all five places. **One exception worth naming:**
option 4 expresses them and still *misreports* them — a legibility failure,
not a capability one. The other three make no claim about the note-scale
places, which is the honest shape.

## 3. The recommendation — Option 3, and why

1. **It is the only option grounded in a rule the phone already applied
   twice**, rather than in taste. The Mac's sidebar is `Shelf · Library ·
   Pool · Blocks · Archived`. The phone has two tabs and folds the rest
   into the Library's filter row: **Pool → `bookless`**, **Blocks →
   `scraps`** — both shipped, both verified in code this session.
   **Archived is the third application of an unbroken precedent.** The
   phone's tab bar is not the Mac's sidebar and never was.
2. **It says what she said archive IS.** Her words: *"archive is available
   forever and maybe still valuable even if you don't want it in your
   current library."* A filter says *still your library, differently
   scoped*; a separate room says *gone*. The filter is the truer statement
   of her own sentence.
3. **It keeps the Mac's deliberate asymmetry** — Archive got a *room*, the
   Trash got an *icon* — without pretending two tabs are five sidebar
   areas. The Trash's phone door (a path-line glyph) is the exact analogue
   of her B1 ruling, which replaced the Library's ⋯ with a trash icon.
4. **"Search it separately" comes free and correct**: one search field,
   scoped by the filter you stand in, and **13o inherits one scoping rule**
   instead of a second search surface.

**The honest caveat:** its one real risk is the filter row's width, which
is a measurement question, not a taste one — so it is question 2 below and
not something quietly decided.

**Second choice: option 2** — the most literal mimicry, no width risk, pays
purely in discoverability. **Option 1** if the cheapest move is wanted.
**Option 4 is the one I would argue against**; finding 1 is the only thing
it has going for it, and finding 1 has a cheaper fix that works everywhere.

## 4. Two findings — neither depends on which option she picks

**Finding 1 — a deleted *book* has no door from where books live.** Books
live on the Shelf; a deleted book rows in the Trash; in options 1, 2 and 3
the Trash's only door is in the **Library**. So deleting a book from the
Shelf means switching tabs to find it. **Inherited, not introduced** — the
Mac's trash icon is in the Library masthead too — and option 4 fixes it by
accident. **The cheap fix works in every option:** the Shelf's path line
renders the same 🗑 from the same door table (one declaration, two
renderers, no new surface).

**Finding 2 — the phone has *two* ⋯ menus, and the grain pairing falls out
for free.** The Mac teaches the two sizes of moment with two chords (⌘S =
this take's moment, ⌘⇧S = this note's). The phone has no chord culture
(PL-11's own words), so that teaching needs another home — and it already
has one, because the phone keeps block acts in the **block ⋯** and note
acts in the **note ⋯**:

```
block ⋯  →  Commit Take    +  Block History…
note  ⋯  →  Save a Version +  Versions…
```

Two menus, two grains, each holding its own *write a moment / see the
moments* pair. Arguably a **clearer** teaching surface than two chords, and
the pocket guide's natural lesson. It costs the note ⋯ sheet two rows
(question 5).

## 5. What does NOT translate from the Mac's decided surfaces

1. **The side panel.** Four of the Mac's five recovery surfaces open
   *beside* the live editor (`InspectorPanel`: `references · scraps · tray
   · blockHistory · versions`). The phone covers the page with a sheet and
   stands the editor down. Already recorded for Block History — the Mac's
   ledger-row-33 "jump to the current block" door is meaningless on the
   phone and was correctly not ported. **Same class for Versions:** the Mac
   reads a moment beside the note; the phone must cover it, so *Read* is a
   push, not a peek.
2. **Hover.** There is none, and every act must be a visible button. Not
   aesthetic: a SwiftUI `Menu` row is a door no in-process pin can drive
   (measured — its accessibility tree comes back empty), and this app has
   shipped dead purge doors under green view-model pins before.
3. **Two search fields.** The Mac's Archive has its own search box beside
   the Library's. Option 3 gives the phone one box, scoped by filter —
   arguably better, definitely different. **13o inherits the answer either
   way**, so it should be recorded.
4. **The `note ▾` menu.** No menu bar on the phone. Its equivalent is a
   sheet of big tappable rows, which is why two extra rows cost more there
   than two menu items cost the Mac.
5. **⌘⇧S.** No chords. `Save a Version` must be a visible row, and the
   grain pairing is taught by the two menus instead (finding 2).

## 6. Grounding — what was verified in the code this session

So a later session need not re-derive it. (No app code was touched.)

- `MobileTrashView.swift` — the phone's **combined** recovery surface: one
  `ScrollView`, Trash section → `Divider` → Archived section. Its own
  header comment names the two-section shape and its reason.
  **Known-interim by her word.**
- Its door is `MobileLibraryView.recoveryRow` — the Library listing's
  **trailing row**, labelled `RecoveryCopy.surfaceName` =
  `"Archived & Deleted"`.
- `App/Variorum/Shared/RecoveryCopy.swift` already records the split as the
  phone's to make: *"It stays for the PHONE, whose recovery surface still
  holds both lists — a face, and mobile's own round to move."* Section
  names are `trashSection = "Trash"` and `archivedSection = "Archived"`;
  `daysLeftLabel` and `archivedForever = "kept — no clock"` are the clock
  vocabulary.
- The Library's filter row is `All · Bookless · Scraps` + a sort menu that
  renders **only** on the `.all` filter (`MobileLibraryView.filterRow`).
  `Filter` = `.all`, `.bookless`, `.scraps`.
- The tab bar is **text-only, two words**: `Shelf · Library`
  (`MobileShellView.tabBar`).
- **The precedent is exact:** Mac sidebar `Pool` → phone `bookless`; Mac
  sidebar `Blocks` → phone `scraps` (`MobileLibraryViewModel.Filter`'s own
  comments name them as the parity-C3 areas).
- The Mac's sidebar is `SidebarSelection`: `shelf · library · poolPosts ·
  blocks · archived` (+ leaf cases) — `archived` added as **the fifth
  area** at the polish round's ledger row 8.
- The Mac's Trash door is the Library masthead's **trash icon**, which
  replaced the ⋯ menu (her B1).
- `MobileBlockHistory.swift` — the Block History twin (**batch 6a, landing
  in the tree as this was written**): four regions, door in the block ⋯,
  no purge door. Its words come from `Shared/BlockHistoryFace.swift`.
- **There is no Versions face on the phone at all.** The core is ready:
  `Operations.saveNoteVersion` / `restoreNoteVersion` /
  `promoteNoteVersion` and `Queries.noteVersions` (→ `NoteVersionItem`:
  `postID`, `savedAt`, `blockCount`, `preview`, `cadence`) all exist, and
  the born-archived classifier already hides versions from the phone's
  listings by construction.
- The Mac's Versions words are `Shared/VersionsCopy.swift` (`VersionsPath`)
  — **already shared**, so the phone's face inherits every sentence.
- The Write masthead is: title (rename) · `⧉ copy` · `⌕ find` · `🔒 seal` ·
  `⋯ note actions`, then the membership chip, then a wrapping flow of
  **five** chips (`date · tags · more info · blocks · lenses`) whose
  crowding is already flagged PROVISIONAL for her. **A sixth chip is not a
  free move** — which is why the proposal puts Versions in the ⋯ sheet.
- The note ⋯ sheet (`MobileNoteActions.swift`) currently holds three rows:
  Undo · Redo · Delete Note….

## 7. Questions only she can answer

1. **Which option** — or which parts of which. They mix; option 3's Archive
   with option 2's labelled Trash row is a coherent hybrid.
2. **Does the Library's filter row take a fourth door?** If yes, what gives
   — the sort shrinks to a glyph, the row scrolls horizontally, or the sort
   moves into the search row? (Judged by her hands; it gets tighter at
   larger Dynamic Type sizes.)
3. **The Trash's door: a glyph, a labelled row, or both?** A glyph is
   tidier; a word is findable in a hurry.
4. **Does Archive get its own search field, or share the Library's scoped
   by filter?** 13o inherits the answer.
5. **Do `Save a Version` and `Versions…` go in the note ⋯ sheet?** It grows
   a three-row sheet to five and buys the grain pairing (finding 2).
6. **Should the Shelf get a Trash door too** (finding 1)?
7. **The word.** The Mac's surface is `Archived`. Does the phone say
   *archived* or *archive* — and does `"Archived & Deleted"` retire?
8. **Where does the per-note tray's door sit?** Candidates: a row in the
   note ⋯, or the phone-native one — the existing `blocks` chip's sheet
   gains segments `in the note | archived | leaving`, one subject in three
   states. **⚠️ FLAGGED:** batch 6b may place this door before she reads
   the page; if it does, this question is already answered and that answer
   stands. The tray's *shape* is not in question — §69.3 ruled it.
9. **On a version row, is the tap "Read"** with restore/promote/delete on
   the moment itself, or should the row carry its own ⋯? Four verbs do not
   fit a phone row inline; the proposal draws the first.

## 8. A note on the mockups' own design

The page is set in the app's **Study** voice; the mockups are drawn in its
**Terminal** voice. Both palettes are the shipped values from
`App/Variorum/Shared/Theme/VoiceTokens.swift`, unmodified — so the page and
the artifact are the app's own two voices side by side, and the frames read
as objects on a page rather than blending into it. The frames honour the
Terminal idioms (`~/path` prefixes, lowercased chrome, monospace) so they
read as this app and not as generic iOS. Dark follows the viewer's system
appearance and uses the phone's real black room (R51), never an inversion.

## 9. Discipline notes

- **No product behaviour was invented.** Everything undecided is a question
  in §7, per CLAUDE.md's guardrail.
- **No app code, no builds, no tests.** Two new files only.
- Every option was checked against the five-places map; the one coverage
  finding is recorded (§2, option 4).
- Only files under this new directory were created; `mobile-round-2.md` and
  the app tree were left entirely alone (another session was editing them
  live), and the commit staged **explicit paths only** — the standing rule
  born at 13p round 9.
