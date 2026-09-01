# Batch 10 — NAVIGATION (brief; written 2026-08-31 by the Fable orchestrator)

**Her three asks, verbatim (2026-08-23,
`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`):**

> *"we have the ability to star a note but I don't like where it appears
> above the shelf, I think it's awkward placing. maybe you should be able
> to swipe from your shelf to a list of starred notes on the home page?
> there could also be a smart book of starred notes - matter of fact, add
> smart book of starred notes to the 13i phase and **don't build it
> yourself**. however, **DO build a different way to see starred notes on
> the homescreen.**"*

> *"when you're within a book, there should be a new note and new chapter
> button, which the mac up does have."*

> *"we need a swipe gesture for between shelf and library it's killing
> me."*

**RULED SCOPE FENCES:** the starred SMART BOOK is 13i's — build NOTHING
book-shaped for starring (her explicit "don't build it yourself"). What
this batch builds is a phone FACE over the existing star. The award
placement she dislikes ("above the shelf") should STOP rendering there
only if the new face replaces its job — state what happens to the old
placement either way, PROVISIONAL.

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 (esp. §5.5 portrait-forever and the
named-coordinate-space drag rider referenced below) · her report above ·
`mobile-round-2.md` §67 (the starred/awkward-placing context) · the
code: `MobileShellView.swift` (the two tab stacks — BOTH stay alive by
design; any paging must not tear that down), `MobileShelfView.swift` +
`MobileShelfViewModel.swift` (the current starred region + the writing
room's pinned guarantee across 2,408 states — your changes must keep
that pin riding), `MobileLibraryView.swift`, `MobileBookDetails.swift`
(the inside-a-book surface), core `Operations` (`addPostToReading` +
`assertReadingAcceptsPosts` — the gate that must run BEFORE minting;
`createSection` — CURATED books only) and the Mac's precedent (books
mint posts inside themselves — R83-era; find the Mac's door for wording
parity, read-only).

## Deliverables

1. **THE SWIPE, shelf ↔ library.** Her "it's killing me" item. The
   ARCHITECT'S RULED SHAPE (PROVISIONAL for her): the shell's root
   becomes a horizontally swipeable band with the SHELF as home —
   swiping left goes to the Library, swiping right from the shelf goes
   to the STARRED page (deliverable 2); the tab bar stays, stays
   authoritative, and stays in sync (a swipe updates the tab selection
   and vice versa). Both stacks must STAY ALIVE exactly as today (the
   A2 liveness world and the quick-note box's lifecycle ride on it) —
   if the paging container would tear a stack down, STOP AND PROPOSE an
   alternative before building (the in-batch fork rule: the implementer
   proposes, the architect rules). Edge cases: the swipe must not fight
   the editor's horizontal gestures (the shell pages only when the ROOT
   surfaces are showing, never inside a pushed note), and the 13e
   jitter rider binds — ANY new drag/gesture math uses NAMED coordinate
   spaces, never mixed ones.
2. **THE STARRED PAGE — a phone face over the existing star.** The
   swipe-right destination from the shelf: a calm list of starred notes
   (windowed + marker, P1), rows opening the note exactly as Library
   rows do, empty-state sentence when nothing is starred. NO smart
   book, NO new query kind if a core starred read exists — find the
   existing starred projection (the shelf's current starred region
   reads one) and reuse it; if none fits, a face-side filter over an
   existing read, never a new core query (fenced). Say what happens to
   the old above-the-shelf starred region (kept or retired) —
   PROVISIONAL either way, with the writing-room guarantee pin still
   green.
3. **NEW NOTE + NEW CHAPTER inside a book.** Doors on the phone's
   inside-a-book surface: **New Note** mints INSIDE the book —
   `assertReadingAcceptsPosts` runs BEFORE minting (the standing gate:
   no stray posts on a refusal; refusals speak the shared voice) and
   the minted note opens for writing; **New Chapter** creates a
   `reading_section` — CURATED books only (a smart book's door is
   absent, not disabled-and-silent; P-2), refusing under a finished
   book in the family's voice. Wording follows the Mac's doors where
   platform-neutral. Receipts + structural-undo behaviour: verify what
   the core ops already register; never re-register.

## Pins & discipline

Real mounted surfaces via `accessibilityActivate()`; the swipe driven
as far as the harness honestly reaches (if a real pan cannot be
synthesized, drive the page-selection seam and SAY SO — the gesture
itself then rides the device queue, stated not blurred). Red-on-old for
every guard (the writing-room pin must survive; the mint gate must
refuse BEFORE minting — assert no stray container on a refused add).
Absence pins over populated surfaces (the smart book's missing chapter
door). PROVISIONALs (the band's arrangement, the old starred region's
fate, door wordings) in `notes/plans/mobile-batch-10-record.md`, written
as you go with PENDING marks resolved before the final message.
Pre-revert copies in a UNIQUELY NAMED scratchpad dir (`b10-prerevert/`),
diff-verified restores — the session scratchpad holds stale `prerevert/`
dirs from other batches; never restore from one you did not create.
STOP AND REPORT anything needing `Sources/`, `App/Variorum/Shared/`,
`App/Variorum/Variorum/`, or `EditorBrain/`.

## Environment (binding)

Own fresh named simulator (iPhone 17 family, newest iOS 26 runtime —
16-series sims are iOS 18.3, INVALID), `ApplicationAccessibilityEnabled`
armed and read back `1`, private `-derivedDataPath` under your session
scratchpad, simulator DELETED at the end. Full mobile suite at the end
from `App/Variorum/`; QUOTE the final line (baseline: **712/102 green with 2 known
issues** — batch 7's unit close, recorded in
`mobile-batch-7-cold-review.md`'s UNIT CLOSED section). The load-flaky perf pin reds → isolated re-run,
report both. Runner deaths under load observed this round — re-run and
report both. Harness trap: `MobileTakesBrowserTests.swift` declares TWO
suites. Revert `Package.resolved` drift. Never touch the real store;
never quit the live Mac app; no Release builds, installs, or pushes;
pathspec-limited commits with the standing trailer. R28: your cold
review dispatches from your report.
