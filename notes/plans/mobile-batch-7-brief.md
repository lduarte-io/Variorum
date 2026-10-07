# Batch 7 — TAKES & BLOCK DOORS, the phone-local half (brief; written 2026-08-31 by the Fable orchestrator)

**The fence split is RULED (QUESTIONS #94, her words: "i agree that those
four hoists should just be deferred to the post 13u merge - seems cleaner
that way"):** this batch builds the PHONE-LOCAL items only. **PR21
replace (which must NEVER build without the `FindReplaceGate` hoist) and
copy-all-takes (the `TakeClipboard` composition hoist) are DEFERRED to
the post-13u merge** — your record carries that deferral in its own
section so the post-merge session inherits a decision, not a discovery.

**PRECONDITION — verify before deliverable 1:** batch 4.5c-phone ruled
and landed the structural fix for **B45-2** (the `displaySlot`/`slots[i]`
coupling in `MobileEditorViewModel`) — read
`notes/plans/mobile-batch-45c-phone-record.md` FIRST and confirm the
structural safety is in the tree; the reorder work below is exactly the
stale-index producer that fix exists for. If it is not there, STOP AND
REPORT.

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 + PL-10 · `notes/QUESTIONS.md` #57/#58 (the
13e batch-2/batch-3 ruled calls — fan-end, locked-take, and AR-1
semantics the phone COMPOSES, never re-decides) · `mobile-round-2.md` §31
(R15/M23), the §63 routed-out table's `commitNow` row ·
`notes/KnownIssuesAndTechDebt.md`'s forked-brains row (CalloutPalette and
BlockSelection are listed forks — the 6b `MobileTrayRowFace` precedent
governs any touch: compose shared primitives where they exist, add a
composition pin, record the fork on that row) · the 13e plan's batch-2
and batch-3 records for the Mac's shipped shapes (`notes/plans/` —
locate by grep) · the code: `MobileTakesBrowser.swift` +
`MobileTakesBrowserView.swift` (the per-take ⋯ — batch 9 just added
`History…` there), `MobileBlockMenu.swift`, `MobileCallout.swift` (the
recorded byte-copy of the Mac's `CalloutPalette` — its drift pin must
keep riding), `MobileEditorViewModel.swift` (the copy door + B45-2's
room), `MobileBlockList.swift` (6b's sheet — a candidate multi-select
host), and core `Operations` for `reorderTake` and the AR-1 ops.

## Deliverables

1. **REORDER TAKES (PL-10(a)).** Doors over the core `reorderTake` op on
   the take card's ⋯ (Move Up / Move Down rows — the phone has no chord
   culture and NO DRAG is to be built: the 13e jitter rider's
   named-coordinate-space rule makes any new iOS drag its own project;
   record that call). Compose the Mac's RULED edge semantics (#57): the
   fan's ends refuse quietly or hide the impossible direction (P-2 — read
   the Mac's shipped answer and match it), locked takes move per the
   Mac's ruled answer. Fan order is `fan_position` (jittered fractional
   keys) — the op owns the arithmetic; the face only asks.
2. **TAKE → BLOCK and TAKES → BLOCKS (PL-10(d)).** Doors over the AR-1
   core ops (the ruled semantics: the NEW BLOCK GETS A COPY and the
   original take is ARCHIVED on its own block — never a row move):
   `Take to New Block Below` on the per-take ⋯; `All Takes to Blocks` in
   the takes browser's chrome (its footer/actions region — pick the
   honest spot, record it PROVISIONAL). Receipts through the shared
   voice; both acts registered for structural undo by the ops themselves
   (verify, don't re-register).
3. **M23 — COPY FOLLOWS THE SCREEN (R15, her ruling verbatim: "copy
   should follow what's on the screen").** The masthead copy door (and
   any other whole-note copy road) takes what the SURFACE displays — a
   lens active or a take peeked means the copy carries the displayed
   text, not the store's chosen. THE RULE'S SHAPE IS RULED: *ask the
   surface what it is displaying* — never a second selection-derivation
   rule (§31's exact wording). Pin: with a lens active whose pick
   diverges from chosen, copy == what renders; with no lens, byte-
   identical to today (red-on-old on the lens case).
4. **CALLOUT SWATCHES + A REAL EMOJI PICKER (PR19).** The phone's
   callout submenu gains the colour swatch rows and a real emoji-picking
   road (the phone-native shape: the emoji keyboard on a small entry —
   the existing prompt is the fallback; pick and record). ONE VOCABULARY:
   compose `MobileCallout`'s existing mirrored rows; if you must extend
   the mirrored row set, extend the existing drift pin the same commit
   (the pin exists so the Mac's `CalloutMenu.rows` and the phone's copy
   cannot drift silently — never weaken it). The `CalloutPalette` fork is
   RECORDED, not hoisted (#94's class; note it on your record's residue
   list — the forked-brains row already carries it).
5. **BLOCK MULTI-SELECT (PR20 — the 13e E2 twin, phone shape).** A
   selection mode over blocks in the note (enter via a block ⋯ `Select
   Blocks…` row or long-press — pick the phone-native door, record it
   PROVISIONAL), tap-to-toggle with visible selection state, and a
   bulk **Delete N Blocks…** act with ONE confirm + ONE compound undo
   entry (the 13e/13j compound precedent; the Trash road — takes
   preserved, Put back real). **Deliberately NOT built: Merge Selected**
   — batch 9's proposal (A) recommends it but it is PROPOSE-ONLY and
   awaits her ruling; your record says so. Where the Mac's app-local
   `BlockSelection` brain has a pure rule you need, follow the 6b
   precedent: compose shared primitives, composition pin, record the
   fork on the forked-brains row — never a silent re-implementation.
   P1: selection state is ids, never text copies.
6. **THE commitNow RIDER (routed here by §63 — this IS the takes
   batch):** `MobileBlockHistory.commitNow` is safe today ONLY because
   its one caller is a dismissing UIMenu row. If ANY of your work gives
   commit (or any unlatched write door you touch) a non-dismissing host,
   it takes the `MobileWriteLatch` the same day. If nothing does, one
   line in the record saying so.

## Pins & discipline

Real mounted surfaces via `accessibilityActivate()`; menu rows via their
UIMenu actions where drivable (say which). Red-on-old by behavioural
revert, output QUOTED, production or fixture named; restores from
pre-revert copies, never `git checkout --` on files this batch edits.
Absence claims over POPULATED surfaces. Hollow pins declared, not
manufactured. PROVISIONALs (door placements, the emoji road, the
multi-select entry gesture) in `notes/plans/mobile-batch-7-record.md`,
written as you go; PENDING marks resolved before the final message.
STOP AND REPORT anything needing `Sources/`, `App/Variorum/Shared/`,
`App/Variorum/Variorum/`, or `EditorBrain/`. The `planVisibleTakeEdit`
tripwire: zero Swift hits in your diff, and STOP if a trace runs through
it.

## Environment (binding)

Own fresh named simulator (iPhone 17 family, newest iOS 26 runtime —
16-series sims are iOS 18.3, INVALID), `ApplicationAccessibilityEnabled`
armed and read back `1`, private `-derivedDataPath` under your session
scratchpad, simulator DELETED at the end. Full mobile suite at the end
from `App/Variorum/`; QUOTE the final line (baseline: read the latest
unit-close counts in `mobile-batch-45c-phone-record.md` / its cold-review
file before claiming one). The load-flaky perf pin reds → isolated
re-run, report both. Runner deaths under load observed this round —
re-run and report both. Harness trap: `MobileTakesBrowserTests.swift`
declares TWO suites; filtering by the first name runs a subset. Revert
`Package.resolved` drift. Never touch the real store; never quit the
live Mac app; no Release builds, installs, or pushes; pathspec-limited
commits with the standing trailer. R28: your cold review dispatches from
your report.
