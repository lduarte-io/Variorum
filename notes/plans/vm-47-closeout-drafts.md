# VM-47 — closeout drafts (applied at the merge, then this file is deleted)

**What this is.** The texts the merging session applies at VM-47's merge, each paste-ready under its own heading.
None is applied on this branch now: another run's merge (VM-64) is about to change several of these files on main,
so each edit is made at the merge moment on LATEST main, and this working file is then deleted (it is not a record;
the record is `notes/plans/vm-47-sizes-and-look.md`). Where the canon-split rule puts an edit in the PR (the contract
lines and the parity row) or on main after the merge (the ledgers), the merging session decides by CLAUDE.md's rule —
the texts are the same either way.

**The slots** — every one is spelled `‹PENDING: …›`, so one search finds them all: the PR number · the merge commit ·
the QUESTIONS number (VM-64's drafts take #280, so likely #281) · the parity row's number (VM-64's take PL-79, so likely
PL-80) · VM-64's three-file merge-in and its narrow read · VM-64's timing door's place in Settings · the targeted
window · the re-capture · the merge gate (the whole phone and whole Mac targets) · `Tools/canon-size` · the wave-1
phone build · whether the walk's screenshots stay until her sitting.

---

## (a) The contract lines

### `notes/SurfaceContracts.md` › The app

**(a1) In the bullet that begins "- **Two voices, exactly two: Terminal (leads) and Study**",** after the sentence

> Appearance (follow system, light, dark) is a local preference applied once as `NSApp.appearance`.

insert:

> **On the phone** the voice and palette are the library's own, read through the Mac's settings road (the shared
> `ThemeStore` and `VoiceTokens.resolve(settings:dark:)`), so a change on either device reaches the other and the phone
> keeps no voice of its own; Settings ▸ Look ▸ Voice writes the library's voice (R-47-2), and before a library answers
> the phone wears what an unset library reads, Study under the sea-glass (PROVISIONAL P-47-15). Light, dark or follow
> the system is this phone's own (Settings ▸ Look ▸ Appearance in the Mac's words, PROVISIONAL P-47-24; this device's
> defaults, never the `setting` table), reaching every window, the editor and its overlays (LK-1/LK-2;
> `notes/plans/vm-47-sizes-and-look.md`).

**(a2) A new bullet directly after that one:**

> - **The phone's sizes and grounds** (`notes/plans/vm-47-sizes-and-look.md`; the sizing sheet's numbers PROVISIONAL as
>   a set, P-47-1). Every phone type site reads one of twelve roles from one table (`Shared/Theme/PhoneType.swift`) — in
>   Study 13 · 15 · 17 · 20 · 24; in Terminal the same roles in SF Mono, its prose roles two points under (PROVISIONAL
>   P-47-4). Her words — the note, titles, rows, previews — grow with the system text size across its whole range; the
>   app's chrome grows to xxxLarge and holds; nothing on the phone is drawn under 13 pt, in SwiftUI or UIKit (pinned).
>   The phone's muted and faint inks are its own (`PhoneInks`: the voice's hue taken darker until muted clears 4.5:1 and
>   faint 3:1 on every shipped ground; the Mac's are untouched), and the faint carries no words under 17 pt — glyphs,
>   placeholders, edges and disabled words only (pinned). Everything tappable answers across at least 44 × 44 pt
>   without changing its drawn size, on one spacing scale with a 20 pt gutter (`PhoneMetrics`); the formatting strip's
>   28 pt acts are the ruled exception (R22/R25). The controls are one set (`PhoneControls`: text button, inline act,
>   icon button, chip, field, calm button, sheet header, segmented choice — the system control —, section header, menu
>   row), with no private builds and no literal or system colour (pinned); the ★ wears its own star token. Her words sit
>   on the paper (`tokens.surface`) — the roots' lists, a book's contents, Archived, the Trash, Versions, and the note in
>   Write with its masthead (PROVISIONAL P-47-16, P-47-17) — and bars, sheets, section bands and path lines on the room,
>   every ground running to the screen's edges (R-47-1); a book's Read page keeps its cream page in the voice's own room
>   (R-13u-10), a peeked take card wears the take tint (R13), and inside a sheet her previews (the Blocks sheet, the
>   tray) and the three hand-built overlays keep the sheet's own ground for now.

**(a3) A new bullet directly after the bullet that begins "- **The sidebar:**"** (it ends "…the open sheet dismisses
(VX-889)."):

> - **The phone's bottom bar** (`notes/plans/vm-47-sizes-and-look.md`; LK-5). Starred · Bookcase · Library in the
>   band's order at the `tab` role (17 pt, chrome), the current word semibold in her ink on a chip, the others in the
>   corrected muted; each cell a third of the width and at least 56 pt tall, the whole cell answering (the drawn numbers
>   PROVISIONAL P-47-21). It shows on the three roots and on every pushed list — a book's contents, the Trash, Archived,
>   Versions' listing — and never inside a note; a book's Read page, Versions' reader and Protection carry none
>   (PROVISIONAL P-47-18). A tab tapped from a pushed list returns the stack being left to its root and then changes the
>   page, and the current tab pops its own stack to its root, so a hidden page always stands at its root (PROVISIONAL
>   P-47-19). Pushed screens keep the system's top bar — the back door and both swipe-backs — each screen's own run
>   filling its row (PROVISIONAL P-47-20). While the capture box or the Library search holds the keyboard the bar rides
>   above it.

**(a4) A new bullet directly after (a3):**

> - **The phone's Settings** (`notes/plans/vm-47-sizes-and-look.md`). One sheet: the shared sheet header over one list
>   that scrolls at every text size, its groups' names on the room and its rows on the paper — Library (the sync row ·
>   Protection…), Look (Voice: Terminal | Study · Appearance: Follow system | Light | Dark), Tags (Manage Tags), Help
>   (Acknowledgments), Diagnostics (Record edit trace · Edit trace…‹PENDING: VM-64's timing door, as its merge-in places
>   it›); Debug builds add their dev-store groups at the foot. Every door is a menu row answering across its whole width
>   at 44 pt or more, and a choice is its label over the system's segmented control (the group names, the voice's word
>   and the drawn parts PROVISIONAL P-47-25, P-47-26). It opens from the ⋯ menu all three roots carry on their top line
>   (the system menu; Settings its one item today — PROVISIONAL P-47-22) and from a note's ⋯ sheet, and Done returns her
>   where she was.

**(a5) In the bullet that begins "- **Messages carry a kind on the one status seam**",** in its phone passage, replace

> sitting above the tab bar and above the keyboard,

with

> sitting above the bottom bar wherever one shows (a root or a pushed list) and above the keyboard, its words at 15 pt
> growing by lines and its Undo answering across 44 × 44 pt (PROVISIONAL P-47-36; `notes/plans/vm-47-sizes-and-look.md`),

### `notes/SurfaceContracts.md` › The Bookcase and books

**(a6) In the bullet that begins "- **The wing switcher**",** its phone passage ends

> the swipe, wing management and the follow are the mobile catch-up's (PROVISIONAL; `notes/plans/fixes/vm-55-wings-underneath.md`).

Append after that sentence:

> The Bookcase root's top line reads the wing's name, "Bookcase" and the count ("Home · Bookcase · N books"; Terminal
> "~/home/bookcase · N books"), matching its tab (R-47-3); where the line cannot fit the phone's width it is cut at its
> end — the count first — with every door on it at 44 pt and the ⋯ last (PROVISIONAL P-47-27).

### `notes/SurfaceContracts.md` › Doors to the outside

**(a7) In the protection bullet's phone passage,** after the sentence that ends

> rule 11's export-off notice never fires there (the phone has no scheduled export), and no Look inside yet (`notes/plans/vm-8-castle-catchup.md`).

insert:

> The phone's Settings carries ONE Protection… door — the standing row, drawn whenever the screen can act; the sync row
> inside Settings is handed no door of its own, so a paused state that would offer one (keys locked, not yet joined)
> says its sentence alone — and the screen opens on the stack she stands on (VM-27; PROVISIONAL P-47-23).

### `notes/AppSpec.md` §12

**No change.** §12 "The app" already states what is now true on both platforms: the voice and palette ride the store,
a store with no palette wears the sea-glass, appearance is a local preference, no literal colour outside the token
layer. Its sidebar and keyboard lines are the Mac's, and the phone's surfaces belong in SurfaceContracts, which (a1)–(a7)
carry. ‹PENDING: `Tools/canon-size` at the merge — it REPORTS; a crossing is a line in the handoff›.

---

## (b) `notes/MobileSoul.md` §6 — the parity ledger row (append after the newest row)

- **PL-‹PENDING: number› (2026-11-19, VM-47 — Sizes and look, the catch-up's wave 1, umbrella 1; a MOBILE run's own
  row; the record `notes/plans/vm-47-sizes-and-look.md`):** the phone takes the Mac's look at phone-right sizes, every
  brain shared — zero `Sources/` lines, zero schema, marker untouched, nothing refuses; the Mac's look byte-identical
  (`VoiceTokens.swift` untouched, its token pins green). **What the phone GAINED:** a type layer
  (`Shared/Theme/PhoneType.swift` — twelve roles, Study 13 · 15 · 17 · 20 · 24, Terminal's prose roles two under; her
  words scale across Dynamic Type's whole range, chrome to xxxLarge; nothing under 13 pt in SwiftUI or UIKit — VM-48);
  its own readable muted and faint inks (`PhoneInks`) and one spacing scale with 44 pt targets (`PhoneMetrics`,
  `phoneHitArea` — VM-49); one set of controls (`PhoneControls` — VM-50); the library's voice and palette through the
  Mac's settings road — `ThemeStore` moved to `Shared/` (QUESTIONS #199), the phone's own voice preference retired, the
  voice row writing the library's voice (R-47-2) — with light, dark or follow the system per device (`AppearanceChoice`'s
  rule shared; LK-1/LK-2), her words on the paper and bars and sheets on the room (R-47-1 — VM-51, VM-53); borders that
  follow a light or dark switch (`MobileTraitBorder` — VM-54); the bottom bar on roots and lists, "Bookcase" on its tab
  and on the root's top line (LK-5, SW-1, R-47-3 — VM-52); Settings as one grouped list reachable from every root's ⋯
  and a note's ⋯ sheet, with one Protection door (VM-53, VM-27); VM-55's wing door and one message line on the same
  layer. **ANSWERED here:** PL-22's owed palette — the phone reads the library's palette, through the Mac's own
  `resolve(settings:dark:)` now that LK-1/LK-2 made the voice the library's too (superseding PL-22's "never the Mac's
  `resolve(settings:dark:)`"), and PL-22's note that the in-app appearance choice is Mac-only (the phone has its own, per
  device) · QUESTIONS #195 MINOR 3 (the unsynchronised `MobileEditorStyle.voice` global: main-actor storage, one writer
  where the library's settings land) · §5 truth 6's Dynamic Type half (the layer scales with her text size; VoiceOver
  stays VM-218's). **STILL OWED, each with its ticket:** the palette chooser (VM-247); the numbers' look at true size on
  her phone (P-47-1, the wave-1 install); the screens that adopt the layer as they are rebuilt — the note's top row
  (VM-148), the overlays as real sheets (VM-152), the Library's filter row (VM-93), the takes badge, comment mark and
  pill (VM-188, VM-195), the capture box (VM-73, VM-74), the keyboard bar (VM-137, VM-138, VM-139); the accessibility
  sizes' cut rows and squeezed sheets (VM-218); the editor body's floor and its launch-time paragraph scale (VM-137); the
  pocket guide's "shelf" words (VM-212, VM-211); Settings from a pushed list (no ticket yet — her call, the handoff's
  checklist). **The MAC should know:** nothing changes on the Mac; `ThemeStore` and `AppearanceChoice`'s rule now live
  in `Shared/Theme/` (moves, the Mac's tests byte for byte), and a callout's dark wash on a hued dark paper reads by hue
  alone (P-47-35 — measured on the phone, inferred for the Mac). Verified by ‹PENDING: the targeted window, the
  re-capture and the merge gate (the whole phone / the whole Mac target)›; merged as PR #‹PENDING› (`‹PENDING›`).

---

## (c) `notes/AppSpecRecord.md` — the dated entry (append at the end)

## 2026-11-19 — VM-47, Run: Sizes and look (the mobile catch-up's wave 1, umbrella 1; SurfaceContracts The app · The Bookcase and books · Doors · MobileSoul §6 PL-‹PENDING›; branch `vm-47-sizes-and-look`, PR #‹PENDING›, merge commit `‹PENDING›`)

**The effort.** Eight members, the sub-issue roster read at kickoff: VM-48 · VM-49 · VM-50 · VM-51 · VM-52 · VM-53 ·
VM-54 · VM-27, in five batches (the layer — type, inks, metrics; the controls and the 44 pt targets; the library's
voice and palette with the grounds and VM-54's borders; the bar; Settings with VM-27), then two re-lands (VM-55's branch
merged in ahead of its PR, batch 6; main with VX-981 and VM-78, batch 7) and two batches of the walk's fixes; run
overnight 2026-11-19 under `/run-phase`, nov18 coordinating the stage beside the wave's three other mobile runs and two
Mac runs; this run merged last of the four mobile runs. **Cast.** Fable orchestrated (one session; its context compacted
once at her word, `notes/plans/vm-47-orchestrator-handoff.md` its map); a fresh `opus-implementer` per batch, with a
fresh closer for batches 1, 2 and 3's stage work as each builder ended near its context's limit (batch 3's closer also
answered round 1 and applied its fixes); fresh implementers for the VM-55 re-land, R-47-3, the walk's driver, the walk's
two fix batches, the re-land of main, rounds 2 and 3's answers and fixes, and the closeout writing; four fresh readers
for the walk's captures; the orchestrator ran every test window and drove both walk parts with the runbook's own calls
once the walker stood down. A fresh `fable-reviewer` for the midway review and each of rounds 1–3 (the diff changes the
editor's face values and a default's meaning, the phone's voice). The record `notes/plans/vm-47-sizes-and-look.md`
(FOR A LATER READER at its top); the walk `notes/plans/vm-47-walk.md`; the ladder files `notes/plans/vm-47-ladder-midway.md`,
`-round1.md`, `-round2.md`, `-round3.md`; the handoff `notes/handoffs/vm-47-handoff.md`; the bundle QUESTIONS
#‹PENDING›.

**Her words (verbatim).** At kickoff (2026-11-19): "i want to get everything set up for an overnight session" · "the
whole issue is that i need to use my weekly limit up before tomorrow" · "i want one claude coordinator named nov18, then
i want all the VM in the first wave launched with instructions to talk to stage coordinator nov18, i want the vx-981 and
vx-980 added too. and add the high priority (private eye not shown on journal) to one of those runs - maybe the MCP run,
since it deals with the private mark." On the shape: "yeah that's fine on the five sequential batches - you can do a
midway through review it if you prefer. also - up to 5 rounds as long as a major is found." On the phone: "ok i talked
to vm-64 about that and resolved the previous install blocker with vm-55. now, i'll plan to have the wave 1 build
installed on my phone after the last vm has merged in, by the last one. sound good? the phone step is the single wave-1
install after all four runs have merged. whoever is last can probably do it overnight over wifi." **R-47-1 and R-47-2**,
one message: "grounds - prose should not be on the tint, which is what I understood you mean. that sounds good. voice
only row - yeah, that's fine. also - agreed, i'll do the hands part in the morning." Her leaving, relayed by the
coordinator: "rule provisionally in my absence". Later: "continue - I hit my limit, I have more now. I'm telling all
sessions the same thing." · "ok - seems like you have a decent amount left. I want you to prepare for compaction and
give me a kickoff prompt to send you post compaction." **R-47-3**, by the question tool, her pick: "Bookcase
(Recommended)" (the option read "The top line says Bookcase, matching the tab, your swipe names and the Mac."). The
rulings it built are the VM-44 sitting's (2026-11-12 and 2026-11-15; `notes/plans/vm-44/her-words.md`): the look —
"just use the mac app as your visual direction. the study mode especially. the sea greeen theme"; LK-1/LK-2 — "follow
the library but if the phone has dark mode on, that shouldn't change what your mac is like (the device dark mode)";
LK-5 — "Words on a chip", and on pushed screens "Roots and lists, not notes"; LK-6's accepted default (Terminal keeps
its lowercase chrome); SW-1. The composition: "22 is fine, composition is fine." (2026-11-15).

**§12 The app narrative — the phone's sizes, inks and controls (VM-48, VM-49, VM-50).** 241 of 352 type sites had been
the Mac's 11.5 pt caption and Terminal's chrome ignored the system text size. One table of twelve roles now serves both
forms — SwiftUI's modifier and UIKit's `PhoneType.uiFont` — with two scaling classes (her words to the end of the range;
chrome to xxxLarge and held) and a 13 pt floor; 325 SwiftUI sites, 19 on the shelf and 38 UIKit sites moved onto the
roles, the smaller candidate taken wherever a site's role was unclear (P-47-8). The two corrected inks are a rule whose
output ships as constants, the rule pinned over every palette and voice. The controls replaced five calm buttons, four
field builds and twelve hand-built sheet headers; every audit G §2 site was adopted, given a hit area, or left with the
open ticket that rebuilds it (the record's batch-2 inventory). Two mechanisms were real defects: the Terminal path line
wrapped (a 13 pt mono path beside two 17 pt mono word doors wanted ≈ 437 pt at 402) and the UIKit form had no floor
(the midway review's M-1); a third, the held chrome growing ⅓ pt past xxxLarge because the cap read `scaledValue` while
the font came from `scaledFont`, was caught by its own pin. The walk then found the corrected faint still carrying words
under 17 pt — doors' words, sentences, headers — where the sheet allows it only on glyphs, placeholders, edges and
disabled words, and the fields' placeholders in iOS's grey (no modifier reaches a placeholder; the fix builds the field
with its `prompt:`); both swept, with source rules that scan every phone view and every shared page's phone arm.

**§12 The app narrative — the library's look on the phone (VM-51, VM-54).** The phone had read no synced theme setting
(PL-22: its voice was a local preference, five sites on the palette-less resolver), so it wore the Classic colours
under a Mac in sea-glass. `ThemeStore` moved whole to `Shared/` (QUESTIONS #199's deferred hoist, the Mac's tests byte
for byte; two additive members, the phone's landing seam and its placeholder); the router holds it, and every phone
read — the five sites, the UIKit editor's face (one main-actor writer where the library's settings land, closing #195
MINOR 3) and later VM-55's message line — takes the Mac's settings road. Before any library answers the phone wears what
an unset library reads (P-47-15). Under R-47-1 her words moved onto the paper at the screens' ground lines, the note in
Write by the one authorized line in the fenced editor file (piece 3.10: the text view's background reads the face's
paper, the Mac editor's own `EditorSurfaceChrome.paper`); the walk then found every ground stopping at the safe area
(the band's `.clipped()` cut each page's `ignoresSafeArea()` ground — in dark a black band round the note), fixed by a
sideways-only clip. VM-54 was not hollow by the code: four sites froze a dynamic colour into `CALayer.borderColor` and
no view registered for trait changes; `MobileTraitBorder` re-resolves at each change of the interface style.

**§12 The app narrative — the bar and Settings (VM-52, VM-53, VM-27).** The bar is one view over the layer, shown by the
shell's destination builder — so a note pushed over a list covers the list's bar by construction, never by a flag —
on the roots and the pushed lists; a tab from a pushed list returns the stack being left to its root before the page
changes (P-47-19), the invariant VM-55's wing landing already relied on. W-009's empty system bar was traced screen by
screen and kept (the back door and both swipe-backs; P-47-20 names each screen's owner). Settings became one grouped
scrolling list on the shared controls, opened from one ⋯ menu on all three roots (the gear retired into it) and from a
note's ⋯ sheet; the appearance choice shares the Mac's pure rule (the enum moved to `Shared/Theme/AppearanceChoiceRule.swift`,
the Mac's AppKit half left beside its pin) and the phone's owner writes each window's interface style from this device's
defaults. VM-27's mechanism: one closure fed two renderers on the sheet, the sync row's door and the standing row, so
the word showed twice whenever the row was in a doored paused state; the standing row stays. Its pin's first run found a
harness defect: the sync chain read `@Dependency(\.database)` ambiently, a test bootstrap installs none, and the read fell
through to the live default, creating an encrypted store in the simulator test host's own container — no network call,
no write by the round; the harness now binds the library's database and fences the outer scope, and the class is VM-248.
The walk's tab road found the hidden Library's search taking the keyboard back after the pop uncovered it; the shell now
tells each page whether it is on screen and the search gives the keyboard back while hidden.

**§12 The Bookcase and books narrative — the root's word (R-47-3).** VM-55's wing door had led the Bookcase root's line
with the wing's name and kept the page word "Shelf" under a tab that says "Bookcase" (LK-5, SW-1) — one screen under two
names. Her ruling made the page word "Bookcase"; the pins of both runs that read the line moved with the ruling as their
reason, and a literal pin was added. The line is three characters longer in Terminal, so P-47-27's tail truncation bites
earlier. The other phone "shelf" words were read and left with their owners (the pocket guide's prose, VM-212; the Debug
guide door's note, VM-211); "Pin to Shelf Top" left the phone with VM-78's VM-83.

**The re-lands.** VM-55's tip `49e795bb6` merged in at `0ff256975` — 23 conflicting phone files, each resolved so both
runs' intent survives (VM-55's behaviour, words and views; this run's drawing), never by file; its new faces put on the
layer (the wing door's title `meta`, the wing list on the sheet header, the message line as the sizing sheet's receipt
line); four meetings decided (the path line holds every 44 pt target, P-47-27; the line's lift keyed to a bar on screen;
the tab's word in VM-55's pins; the wing landing pinned). Main `a09d6a025` (VX-981 and VM-78) merged in at `4866c7fb8`
by VM-78's round-4 map, hunk by hunk, the map's governing rule taken over its quoted pre-walk inks; one new pin for the
one row restyled by hand. ‹PENDING: VM-64's three files, the merge commit, and its narrow read›.

**The walk.** One walk for the whole run, on the tree with VM-55 re-landed and R-47-3's word: 99 captures in part A (the
core under the sea-glass in all eight combinations of voice, appearance and size) and 184 of 186 in part B (the second
palette, Settings' flows, the bar's roads and VM-55's faces, VM-54's flip, the wider pass in three combinations), read by
four fresh readers against the sizing sheet; 29 findings — 11 this run's (10 fixed with pins red on a snapshot of the
pre-fix tree, the eleventh P-47-30), 11 questions for her (§5's P-47-27 extended and P-47-31 … P-47-40, with the warning
ink P-47-41 from the fixes), 7 other tickets'. ‹PENDING: the re-capture›.

**The ladder.** Midway, after batch 2 (her word): 0 BLOCKER · 1 MAJOR (M-1, the UIKit floor — fixed, red on old 20
issues) · 2 MINOR (comments) · 2 NIT. Round 1: 0 · 0 · 1 MINOR · 4 NIT (two doc sentences; one NIT dismissed, the
reviewer's own filtered-grep error) — no MAJOR, so under her rule no further round was earned. Round 2 was taken anyway
because VM-55's re-land, the round-1 fixes and R-47-3 entered after round 1: 0 · 0 · 0 · 2 NIT (one hollow, one doc
sentence). Round 3 was taken because the walk's fixes and the re-land of main entered after round 2: 0 · 0 · 1 MINOR
(the walk's questions not yet in §5 — discharged by the rows) · 2 NIT (one test-only narrowing of a placeholder
exemption). Every finding dispositioned in its round file; no MAJOR open.

**The gates.** Batch 1, the whole phone target: 883 tests in 145 suites, its reds traced (one real defect fixed, one pin
moved to its rule, VM-24's caret test main's); the targeted re-run 118 in 12 green; the Mac's seven theme types 42 green.
Batch 2: 900 in 148 (two test premises fixed test-only), 13 in 1 re-run green, the path line red on a snapshot (22
issues). Midway's fix: red on a snapshot (20 issues), 75 in 6 green, the Mac 40 in 6. Batch 3: 916 in 151 (one test
premise fixed test-only), the Mac's 102 theme-store types 511 green, VM-54 red on a snapshot (5 issues). Batch 4: 117 in
12. Batch 5: 80 in 14 (the VM-27 harness red, fixed), the Mac's 15 types 84 green, VM-27 red on a snapshot and green on
the fix. On the tree with VM-55 re-landed: the whole phone target 1,045 tests in 179 suites, one host launch, the one red
VM-24's caret pin (2 of 3 cases); the Mac's 114 types 565 green; R-47-3's nine types 65 green. The walk's fixes: part A's
window — every pin red on the snapshot (55 issues), 290 in 52 on the fix with one red (the marker pin measured the
glyph's bearing — the pin moved to the layout origin), the Mac's nine types 36 green; batch 2's window — all twelve pin
types red on the snapshot, 64 of 65 suites green on the fix (one source rule read a placeholder as a door's word — fixed
test-only), the Mac's ten green. ‹PENDING: the targeted window (batch 7's 64-type phone array and 25-type Mac leg, the
join pin and its red-on-old)› · ‹PENDING: the merge gate — the whole phone target / the whole Mac target›.

**Born, triaged at mint:** VM-247 (Feature · Settings & onboarding · Mobile · Medium · Backlog — the palette row the lock
mockup draws, which no ticket owned) · VM-248 (Debt · Confirmed · Tests & tooling · Mobile · Medium · Backlog — an
unscoped database read in a phone test falls through to the live store). Remainders went as comments to their owners
(the record's §6 "Closeout"): ‹PENDING: the ticket pass's comments, by owner›. **Canon:** SurfaceContracts ×7 (The app:
the phone's look in the voices bullet, the sizes-and-grounds bullet, the bottom bar, Settings, the message line's place;
The Bookcase and books: the root's top line; Doors: the one Protection door); AppSpec, OverallModel, CoreDescription,
SyncSpec, CastleRules, MCPSpec and CLAUDE.md unmoved by this run; QUESTIONS #199 (the hoist LANDED) and #195 MINOR 3
(CLOSED) marked; `Tools/canon-size` ‹PENDING›. **MOBILE PARITY:** PL-‹PENDING›. **Release:** none; nothing in
`/Applications`. **The wave-1 phone install:** this run, the last mobile merger, prepared ‹PENDING: the build, its
signing check, the sync-version check and the block›; the install is hers.

---

## (d) `notes/QUESTIONS.md`

### (d1) The bundle (append as the next free number)

#‹PENDING: number› — **THE VM-47 PROVISIONAL BUNDLE (Run: Sizes and look, the mobile catch-up's wave 1, umbrella 1;
2026-11-19; the binding record is `notes/plans/vm-47-sizes-and-look.md`, FOR A LATER READER at its top and §5 the calls
in full; your checklist is `notes/handoffs/vm-47-handoff.md`, which opens in plain words and names each call's
captures).** Thirty-eight calls, each built on its most defensible reading while you were away ("rule provisionally in
my absence", your words as relayed by the stage coordinator). Ruled during the run and not here: R-47-1 (the grounds),
R-47-2 (the voice row), R-47-3 (the Bookcase root's word). Each line: the call · the options · what is built.

**Sizes and numbers**
- **P-47-1 — the sizing sheet's numbers as a set** (type 13 · 15 · 17 · 20 · 24, the 44 pt minimum, the 20 pt gutter,
  the spacing scale, the row minimums, the two corrected inks). As drawn · her own numbers. **Built: as drawn.**
- **P-47-4 — Terminal's prose roles "two points under"**. (a) every prose role, size and line pitch both two under ·
  (b) sizes two under, pitches proportional · (c) only body, note title and screen title, rows at Study's sizes.
  **Built: (a).**
- **P-47-21 — the bar's drawn numbers** (cells a third × at least 56, ≈ 60 at xxxLarge; the chip 8 × 16 → 8 → 4,
  radius 12 where the mockup draws 9; the bar above the keyboard as before). As built · her numbers. **Built: as
  listed.**
- **P-47-12 — the note's top row** (VM-148 rebuilds it). (a) the four tools as 22 pt icon buttons in ink, 44 × 44,
  the chips 44 tall in their flow · (b) the tools at 17 pt in faint with only a 44 pt frame · (c) the chips as 32 pt
  capsules in one row. **Built: (a)** — the title has 54 pt less.
- **P-47-8 — role judgment calls** (the batch-1 role map; batch 6 adds VM-55's faces — the wing door's title `meta`,
  the wing list's names `control`, the message line's words `controlInline` 15). The smaller candidate each time · her
  picks. **Built: the smaller.**
- **P-47-7 — the Library/Archive filter row's five words.** (a) `meta` 13 (one unshrunk row at 375 and 402 pt; Terminal
  at 320 pt cuts its last words, a named known issue) · (b) `chip` 15 · (c) scroll or wrap (against #92(b)). **Built:
  (a)**; the known issue owned by VM-93.
- **P-47-10 — the filter row stays as words.** (a) five word doors and the sort glyph, 44 tall, word-wide · (b) the
  system segmented control (truncates; breaks #92(b) at 375 pt Terminal) · (c) chips in a scrolling row. **Built:
  (a).**

**Grounds and inks**
- **P-47-16 — the note in Write on the paper.** (a) the paper (`tokens.surface` on the settings road; the Mac editor's
  ground) · (b) the voice's own room under every palette · (c) the library's room (against R-47-1). **Built: (a).**
- **P-47-17 — Write's masthead ground.** (a) the paper, one ground with the note · (b) the library's room (her title on
  the tint in light) · (c) the title on the paper, the tools on the room (needs VM-148). **Built: (a).**
- **P-47-15 — what the phone wears before a library answers** (the lobby and the shell's first frame). (a) the Mac's
  storeless placeholder, Terminal in the voice's own colours · (b) what an unset library reads, Study under the
  sea-glass · (c) a device cache of the last library's look. **Built: (b).**
- **P-47-5 — the dark faint.** (a) the every-palette floor — Study #766F5F, Terminal #6B7168 · (b) the sheet's #736C5D
  (2.91:1 on teal & rust's dark card). **Built: (a).**
- **P-47-29 — the masthead chips' inks after the walk's fix.** (a) set chips ink, empty chips the corrected muted, the
  active lens the accent, the membership and blocks chips unchanged · (b) the one-book membership chip in ink too · (c)
  set chips muted as well. **Built: (a).**
- **P-47-30 — the segmented choice's unchosen words on iOS's track** (4.44:1 light, ≈ 4.1:1 dark, under 4.5:1). (a) as
  built · (b) the unchosen words in ink · (c) a hand-built control with a token track (loses iOS 26's glass selection).
  **Built: (a), no code.**
- **P-47-37 — the disabled calm button** (1.65:1 Study light, 2.09:1 Terminal dark). (a) the Mac's 35% dim · (b) the
  word in the corrected faint at full opacity · (c) the act shown only when it can act. **Built: (a).**
- **P-47-41 — the shared pages' warning words in the system orange** (≈ 2.2:1 on the paper; the sync row's paused
  states, the Account sheet's warnings). (a) as built · (b) a phone warning ink derived to clear §D's floor in every
  palette, the Mac's arm unchanged · (c) the alarm. **Built: (a).**
- **P-47-35 — a callout's dark wash on teal & rust's dark paper** (1.05:1; reads by hue alone). (a) the Mac's exact
  washes · (b) the dark washes stepped off the paper on every palette, Mac and phone alike · (c) a hairline edge in dark.
  **Built: (a).**

**The path line, the bar and the message line**
- **P-47-27 — what gives way on the Bookcase's top line** (measured by the walk: Terminal loses the count at the default
  size and the page word at ax5; Study at ax5 loses the count; Study default fits 3 books with ≈ 5.5 pt to spare). (a)
  one 44 pt line, the text cut at its tail · (b) cut the middle · (c) wrap in Terminal · (d) "+ New Note" as a glyph.
  **Built: (a).**
- **P-47-9 — the top line's doors.** (a) 🗑 an icon button, + New Note an inline act at 15 (Settings since moved into
  the ⋯) · (b) all icons · (c) words at 15 with the path cut. **Built: (a).**
- **P-47-31 — the trash door is a colour emoji** (U+1F5D1, untintable). (a) keep the emoji · (b) a monochrome glyph in
  the muted tone or ink. **Built: (a).**
- **P-47-18 — where the bar shows beyond "Roots and lists, not notes".** (a) the roots and the pushed lists; none on
  Read, Versions' reader or Protection · (b) every pushed screen but Write · (c) Protection with the bar except while
  new words are held. **Built: (a).**
- **P-47-19 — a tab from a pushed list.** (a) the stack being left returns to its root, then the page changes · (b) each
  stack keeps its place (the system tab bar's memory). **Built: (a).**
- **P-47-20 — W-009, the system bar on pushed screens.** (a) kept — the back door and both swipe-backs; each screen's
  owner fills its row (VM-148, VM-122, VM-100/VM-99, VM-110, VM-147) · (b) hidden, a back button in each header · (c) the
  title in the system bar. **Built: (a)** — W-009 deferred with owners.
- **P-47-36 — the message line wraps to two lines** (63 pt for "Note moved to the Trash — 30 days to put it back.").
  (a) the line grows by lines · (b) one line, tail-cut · (c) shorter receipt words in her wording pass. **Built: (a).**

**Settings and its words**
- **P-47-22 — the ⋯ on a root.** (a) the system `Menu` · (b) a sheet of menu rows · (c) the ⋯ opens Settings directly.
  **Built: (a).**
- **P-47-23 — where Protection opens.** (a) on the visible stack · (b) the shelf's stack after a tab change · (c) inside
  the Settings sheet (the lock mockup's S1). **Built: (a).**
- **P-47-26 — Settings' drawn parts** (menu rows ≥ 44, no chevron or value; a choice's label over the system control;
  the sync row's doors under its line; the edit trace's system switch; no foot line). As built · the mockup's chevrons
  and values once the values exist. **Built: as listed.**
- **P-47-24 — the appearance row's words.** (a) the Mac's own row, "Appearance" · "Follow system" · "Light" · "Dark",
  nothing beneath · (b) the drafts ("System"; "Light or dark is for this iPhone only."). **Built: (a).**
- **P-47-25 — the list's names.** (a) the drafted group names "Library", "Look", "Help" and the voice's word "Voice" ·
  (b) "Theme" for the voice (the Mac's word) · (c) today's section words as group names. **Built: (a).**
- **P-47-13 — sheet headers whose title was a muted path, and Create Book's Cancel.** (a) the shared header, the path
  title kept muted, Cancel semibold in Done's place · (b) an ink title everywhere · (c) Cancel regular. **Built: (a).**

**The largest text size**
- **P-47-14 — the class of a field's typed text.** (a) `control`, chrome — a field stays one 44 pt line · (b) her
  words' class — fields grow past 44 at the accessibility sizes. **Built: (a).**
- **P-47-32 — the capture box focused at ax5 leaves no book on screen.** (a) as built (R27's floor in lines of the
  scaled text) · (b) the floor's line height capped at xxxLarge · (c) one book row kept at the accessibility sizes.
  **Built: (a).**
- **P-47-34 — Terminal's Settings title breaks after "~/" at ax5.** (a) as built · (b) a path-shaped sheet title holds
  at xxxLarge · (c) one line, tail-cut. **Built: (a).**
- **P-47-40 — Protection's state lines grow as her words at ax5.** (a) as built · (b) the app's state lines and ruled
  sentences hold at xxxLarge · (c) the posture line full range, the sync sentence `meta`. **Built: (a).**

**Terminal's lowercase**
- **P-47-39 — Terminal lowercases her words on some screens** (Versions' rows, Starred's names) and not others. (a) as
  built, predating the run · (b) the chrome lowercased, her quoted words left as written · (c) no excerpt in Terminal's
  meta. **Built: (a).**

**Smaller look items**
- **P-47-33 — the fields' caret is the system blue** (the editor's caret wears the accent). (a) tint the fields with the
  accent · (b) leave the system blue. **Built: (b).**
- **P-47-6 — the quick-entry hint at the note-body size.** (a) the longest of its own cuts that fits · (b) let it wrap ·
  (c) new shorter words in her wording pass. **Built: (a).**
- **P-47-38 — the tag field's hint cut mid-word at 17 pt.** (a) as built · (b) P-47-6's rule ("type a tag — ⏎ applies
  it") · (c) new words in her wording pass. **Built: (a).**
- **P-47-11 — the Trash's seven kinds.** (a) filter chips in a scrolling row · (b) the segmented choice · (c) a menu.
  **Built: (a).**

**The wording pass** — the group names "Library", "Look", "Help"; the appearance row's words (the Mac's); "More" (the
⋯'s spoken name); "Settings" in a note's ⋯ sheet and in the roots' ⋯ menu; retired: the "Sync" and "Voice" section
words and "Recording edit trace — tap to stop"; the capture box's hint cuts (no new words); drafted and not built:
"Variorum for iPhone", "System", "Light or dark is for this iPhone only.", "Voice and palette belong to your library, so
they change on every device." **Held for her hands:** the wave-1 install; the Account sheet's first sight (no capture or
mounted test shows it); her glance at which Protection door stayed (VM-27 — the standing row); the palette row
(VM-247). **One remainder no ticket owns:** Settings has no door on a pushed list, Read or Protection (VM-53's title
says "every screen"; its text "every root and a note") — a ticket or her acceptance. **Status: OPEN.**

### (d2) The two older items to mark

**#199** — in its line, replace

> `ThemeStore` (PR23 + arch MINOR 3's structural half)

with

> `ThemeStore` (PR23 + arch MINOR 3's structural half — **LANDED 2026-11-19 at VM-47**, `dc9a5fd05`: moved whole to `Shared/Theme/ThemeStore.swift`, the Mac's behaviour and tests byte for byte; `notes/plans/vm-47-sizes-and-look.md` batch 3)

**#195** — in its line, replace

> **MINOR 3** (`MobileEditorStyle.voice`, an unsynchronised mutable global a non-serialized suite mutates while 81 of 86 suites run parallel)

with

> **MINOR 3** (`MobileEditorStyle.voice`, an unsynchronised mutable global a non-serialized suite mutates while 81 of 86 suites run parallel — **CLOSED 2026-11-19 at VM-47**, `987e9edc5`, `90228e98a`: main-actor storage, one app writer where the library's settings land; the residual — the suites share the process-global look across awaits — is the editor seam's, VM-137; `notes/plans/vm-47-sizes-and-look.md` batch 3)

---

## (e) The master plan and the run-finals ledger

### (e1) `notes/DetailedPlanForPhases.md` — the in-flight row retired

Delete the row that begins

> | **VM-47 — Run: Sizes and look (mobile catch-up wave 1, umbrella 1).** Eight members (VM-48…VM-54 and VM-27)

### (e2) `notes/DetailedPlanForPhases.md` — the latest closeout

Roll the paragraph under "### Latest closeout" (VM-64's, if it merged first) verbatim into
`notes/PhaseCloseoutArchive.md`, then put this in its place:

**→ VM-47 CLOSED 2026-11-19 — RUN: SIZES AND LOOK (the mobile catch-up's wave 1, umbrella 1 — the wave's LAST mobile
merger; the record `notes/plans/vm-47-sizes-and-look.md`, FOR A LATER READER at its top; /run-phase overnight under her
frame — provisional running — nov18 coordinating; PR #‹PENDING›, merge commit `‹PENDING›`).** Eight members in five
batches, then two re-lands and two batches of the walk's fixes, no `Sources/`, `Sync/`, custody, schema or operation
line, the Mac's look byte-identical: a phone type layer of twelve roles that grows with the system text size and never
draws under 13 pt (VM-48); the phone's own readable inks, one spacing scale and 44 pt targets (VM-49); one set of
controls (VM-50); the library's voice and palette through the Mac's settings road — `ThemeStore` moved to `Shared/` —
with light or dark per device and her words on the paper (VM-51, R-47-1, R-47-2); borders that follow a light or dark
switch (VM-54); the bottom bar on roots and lists, "Bookcase" on its tab and the root's top line (VM-52, R-47-3);
Settings as one grouped list from every root's ⋯ and a note's ⋯ sheet, with one Protection door (VM-53, VM-27). VM-55
re-landed ahead of its PR (23 files), main merged in with VX-981 and VM-78 by VM-78's map, ‹PENDING: VM-64's three
files›. The ladder (all Fable): midway 0B/1M/2m/2n · r1 0/0/1/4 · r2 0/0/0/2 · r3 0/0/1/2 — no MAJOR open. The walk:
283 of 285 captures read by four fresh readers; 11 of this run's defects, 10 fixed with pins red on old, one a question.
The whole phone target on the VM-55 tree 1,045 / 179 (main's VM-24 red only), the Mac's 114 types 565 green;
‹PENDING: the targeted window · the re-capture · the merge gate, whole phone / whole Mac›. Canon: SurfaceContracts ×7
(the phone's look, sizes and grounds, bar and Settings; the Bookcase's top line; the one Protection door); QUESTIONS
#199 and #195 MINOR 3 marked; `Tools/canon-size` ‹PENDING›. QUESTIONS #‹PENDING› (thirty-eight PROVISIONAL calls and the
wording pass). Born, triaged: VM-247 · VM-248. MOBILE PARITY: PL-‹PENDING› — the phone takes the Mac's look at
phone-right sizes, the library's voice and palette, the bar and Settings; zero schema, marker untouched. INSTALL: this
run prepared the single wave-1 phone build ‹PENDING›; the install is hers. **Her bundle: the thirty-eight PROVISIONAL
calls, the wording pass, the Account sheet's first sight, the one unowned remainder (Settings from a pushed list), the
install.**

### (e3) `notes/plans/run-finals-ledger.md` — append after the newest row

- **2026-11-19 · VM-47 — Run: Sizes and look** (PR #‹PENDING›, merge commit `‹PENDING›`): eight members (VM-48/49/50/51/
  52/53/54 + VM-27) in five batches, then the VM-55 re-land (its tip merged in ahead of its PR, 23 files), R-47-3, two
  batches of the walk's fixes and the re-land of main (VX-981 + VM-78 by VM-78's round-4 map), ‹PENDING: VM-64's three
  files›; Fable orchestrated (one session, compacted once at her word), Opus implemented with fresh closers at the
  ~530–713k context seams, four fresh readers for the walk; a fresh fable-reviewer per round — midway 0B/1M/2m/2n (M-1
  the UIKit 13 pt floor, red on old 20 issues), round 1 0B/0M/1m/4n (one NIT dismissed), round 2 0B/0M/0m/2n, round 3
  0B/0M/1m/2n (the walk's questions into §5) — rounds 2 and 3 taken for new ground, not earned; windows: batch 1 883/145
  (one real defect, one pin moved), re-run 118/12; batch 2 900/148, re-run 13/1, the path line red on old 22 issues;
  midway fix 75/6 + Mac 40/6, red on old 20; batch 3 916/151 + Mac 511/102, VM-54 red on old 5 issues; batch 4 117/12;
  batch 5 80/14 + Mac 84/15, VM-27 red on old 2 issues after its harness fix; the VM-55 tree's whole phone target
  1,045/179 (VM-24's red only) + Mac 565/114; R-47-3's 65/9; the walk's fixes — part A every pin red on old (55 issues),
  290/52 on the fix with one pin moved, Mac 36/9; batch 2 all twelve types red on old, 64/65 suites on the fix with one
  test-only rule fix, Mac 10 types; the walk 99 + 184 captures (2 timing misses), 29 findings; ‹PENDING: the targeted
  window, the re-capture, the merge gate — whole phone / whole Mac›; born VM-247/248; bundle QUESTIONS #‹PENDING›; the
  wave-1 phone build ‹PENDING›.
