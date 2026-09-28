# 18l-c U6 (takemania) + the post-U5 window — ladder ROUND 1 (opus-reviewer, 2026-09-28)

**Window:** `36263c2f..4cdcdf73` (the U5 ladder's fix pass · the #153 seam act `4861947c` · UNIT
U6 whole). **Verdict: 0 BLOCKER · 0 MAJOR · 4 MINOR · 8 NIT.** Same-model round (Opus reviewed,
Opus implemented) → the ORCHESTRATOR ARBITRATES against the spec; dispositions below, landed
repo-first before the fix session sees them. The reviewer wrote no file (read-only round); this
document is the round's record, the findings transcribed from its report faithfully, condensed
only where the mechanism is fully kept.

**The reviewer's scope flag, dispositioned first:** the #153 seam act touches
`BookIndexEditModel.takePendingLiveBlock` — the plan's cast puts the editor seam on Fable's
side; the reviewer reviewed it anyway (finding it sound) and left the re-review call to the
orchestrator. **Disposition: SUFFICIENT, recorded honestly** — the line was AUTHORED by Fable
(the orchestrator's seam act, `4861947c`), consumes the existing pure `PaneCaretLanding.entering`
exactly as two sibling models already do, touches no TK2/`PaneSurface`/`EditorTextView` code,
carries a revert-verified pin, and has now ALSO been cold-reviewed by Opus. The Fable-review
rule's purpose (Fable judgment on editor-seam diffs) is served by authorship + this cold pass;
U8 (Fable-reviewed) re-enters the landing family regardless.

**Reviewer disclosure, verified:** an accidental `jekyll-extract.py --help` run rewrote the
resource BYTE-IDENTICALLY (incidentally proving reproducibility: 58 ¶ · 9,321 w · 50,779 B) and
left a stray `./--help`, deleted. Tree verified clean by the orchestrator (`git status` empty,
no stray file).

## FINDINGS × DISPOSITIONS (each verbatim-faithful; the orchestrator's call in bold)

| # | Sev | Finding (mechanism kept whole in the reviewer's report §, transcribed below) | **Disposition** |
|---|---|---|---|
| F1 | MINOR | `Takemania.swift:249-254` + seeder/restore — a REFUSED MEMBERSHIP (finished/full book) leaves an empty tagged note in the POOL on every Restore press, accumulating; the heal only sees book members; the toast's "try again" can never succeed. Red-on-old pin described (lock, delete, restore ×2 → two Pool orphans). Fix: mint through `newPostInReading` (the op's own no-stray doctrine), then tag; name the lock in the failure line | **CONFIRMED — FIX with the described red-on-old pin** (the op-doctrine shape exactly; the failure line names the lock) |
| F2 | MINOR | `JekyllTakemaniaSeedTests` `withJekyllWorld` never injects the mark leaves, so restore pins WRITE the `.real`-variant Jekyll mark into the test host's real defaults domain (`SampleLibrarySeeded.Variorum.jekyll-and-hyde` present on this machine; every precedent injects both leaves; breaks RUN A A2 row 8's headless-never-marks rule). Red-on-old described | **CONFIRMED — FIX** (inject both leaves per the precedents + the described pin; delete the one stray key from the Debug domain after verifying its exact name — the key is test-written, never the dev store's) |
| F3 | MINOR | `SampleLibraryJekyllBook.swift:91-95` — the disclaimer's "delete whichever copy" advice omits that DELETING A BOOK KEEPS ITS NOTES (registry rule `deleteBookKeepsItsNotes`), so the spare copy's four notes land in the Pool and Restore answers `alreadyWhole`; the shared tag cannot separate the copies | **CONFIRMED — FIX the PROVISIONAL wording for accuracy now** (state the fact plainly, e.g. the reviewer's line); the wording REMAINS hers to polish (R-18l-12) and rides her bundle with this fact named |
| F4 | MINOR | U6's PROVISIONAL items 3–5 unlogged in QUESTIONS (CLAUDE.md's rule), and item 3 — the SEED-RELATIVE DATE SCHEME — visibly moves her Library: takemania lands edited-yesterday at the TOP of every edited-sort Library/Timeline incl. her real store post-refresh, the exact displacement Sherlock's 1892 clock prevents | **CONFIRMED as process; the date-scheme half arbitrated WITH the mechanism the reviewer's own round surfaced:** the recency is FORCED by her tray requirement — the implementer's revert R-U6-4 PROVED the 1886 clock ships an EMPTY tray (30-day purge clocks cannot hold period stamps), so "re-clock to 1886" is not a fix, it deletes a ruled deliverable. **FIX = file #156** carrying the fork honestly — (a) as built: a real Leaving tray, and takemania tops the Library on first launch · (b) the 1886 clock: no displacement, and the tray ships empty · there is no third road without faking rows — plus the Title Case book name and the contents/typed-note-shape PROVISIONALs; her bundle grows it |
| F5 | NIT | The closing-run row predates `57d04110` (a `Shared/` clock fix) — the phone first-write suite and the generic iOS build never re-ran on the final code | **CONFIRMED — RE-RUN both on the final tree and amend the row** (cheap; Foundation-only risk honestly low) |
| F6 | NIT | `Takemania.swift:436-449` — the keep-on-top cuts composed BY HAND instead of `KeepOnTopDivide.compose` (the Domain home's own two-homes-drift warning; the seeded note would silently stop showing the real default if the composition changes) | **CONFIRMED — FIX** (compose through the helper over the live fan) |
| F7 | NIT | `BookIndexEditModel.swift:164-165` — the comment's lead line still says "#153 PROVISIONAL … parks at the block's START" over the (a′) body | **CONFIRMED — FIX** (retitle the lead; the orchestrator's own seam-act file, taken by the fix pass with the rest) |
| F8 | NIT | `SampleLibraryTests.theMarksAreIndependent` — a FOURTH `Book.all` loop hands Jekyll the encryption mark, silently diluting the pin's only-it intent (the three re-arms missed this consumer) | **CONFIRMED — FIX** (per-book marks in that loop or an explicit list) |
| F9 | NIT | The U6 record states the label count three ways (17 · 16 named · 18 distinct); 18 distinct is right by the script | **CONFIRMED — FIX the two stale numbers** |
| F10 | NIT | The brief's shelf word-aggregate note (KnownIssues row 15's class) was never addressed — the floor grows ~12.3k words | **CONFIRMED — FIX** (one line on row 15 + the record) |
| F11 | NIT | `18lc-u5-ladder-round1.md` never received the sanity-pass verdict its last line promises | **CONFIRMED — the ORCHESTRATOR'S OWN record debt, taken directly** (appended with this round's commit, below) |
| F12 | NIT | `SeededBookRestore.swift:119-120` — a mid-history `ScriptError` falls to the "nothing else was touched" arm while a half-built note stands (unreachable today except by a script bug; the pins catch that) | **CONFIRMED — FIX** (name `ScriptError` in `failureLine`; one line) |

**Clean bill (the reviewer's, headline items):** the dedupe facts list byte-identical (pinned +
revert red); #155's premise verified read-only in `Sync/` (the defense leg WOULD revive an
edited copy — keeping Jekyll out is the traced answer); the whole history through §9 operations
on the quiet facade, undo depth 0 pinned; title-last completeness + the heal revert-verified
four ways; time zones checked (tray clocks hold across zones, no DST exposure); the resource
reproducible; P-1 registry discipline; the phone's first-write order + own mark; the #153 (a′)
line sound with row-36 scrubs right; the U5 fix pass verified; P1/P2 hold.

**Fix flow:** same-model → these dispositions land repo-first (this commit); the FIX SESSION is
the resumed U6 implementer (bounded, its own unit); round 2 = a FRESH `opus-reviewer` re-reviews
the fixes. F11 is the orchestrator's and lands now.
