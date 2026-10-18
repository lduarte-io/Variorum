# VX-306 ladder round 2 — cold review (Fable), 2026-10-18

Diff under review: `fb41eb9eb..6c19d57a2` (the round-1 FIX LEG + the orchestrator's words pass) on branch
`vx-306-castle-open-road`, read against round 1's report (`notes/plans/vx-306-ladder-round-1.md`) and the fix-leg
record (the plan §10). Review read: the plan's §7c/§9 words pass/§10 whole, round 1's report whole, `CastleRules.md`
whole, `SyncSpec.md` whole, REVIEW_PROMPT, the full fix-leg diff file by file, and the surrounding code of every fix
(`ProtectionOpenRoad.create` + both set-asides, `DeviceActs.createLibrary`, `Copies.openCopy` whole, the
LookInsideModel rework whole, the hook, the pane, the seeder and `LaunchFurniture`'s call site). Ran here:
`U2LookInsideTests` 4/4 green incl. the new m2 pin; **my own red-on-old revert of m2's core fix** (the quiet-arm
scoping restored to `[.silent, .touchid]` → `theAutomaticProbeNeverPressesTouchIDAndAPressDoes` RED with 3 issues,
restored by `git checkout`, green); the core protection set (my 72-suite filter) 295 tests green Debug;
`swift build -c release` green (rule 24). No "Review foci" section exists. The Mac/phone suites remain PENDING the
stage per the record — honest, the orchestrator's; my findings ADD one suite to that list (finding 1).

**Tally: 0 BLOCKER / 0 MAJOR / 3 MINOR / 3 NIT.** Every round-1 finding's fix landed as a fix (dispositions below).

## Findings (severity-ranked)

**[MINOR] · App/Variorum/VariorumTests/Protection/ReadmeStartHerePlanTests.swift:14-37 (`planPassages()`) · The words
pass's one pin FAILS when run — committed un-run and excluded from the stage's suite list** · Mechanism, reproduced
against the plan's actual bytes (a faithful replication of the parser's logic): the slice starts at
`**(5) The Start Here chapter**`.upperBound, so chunk 0 (split on `"\n>\n"`) carries the heading's same-line
parenthetical ("(the field guide's first chapter, rewritten first — VX-379; four short passages):") as its first
line — the processed chunk begins with "(the field guide's…", fails every `hasPrefix` in the filter, and passage 1
is DROPPED (drafted.count == 3, the test expects 4); and the slice's END bound is `## 8. ENVIRONMENT TRAPS`, so the
last chunk carries ALL of §7c (6)–(10) appended after passage 4 (processed length 2012 vs the seeded ~460), so
`seeded == drafted` fails too. Both `#expect`s record issues the moment the suite runs. It never has run: it is a
Mac-target test, the fix-leg record's stage list EXCLUDES it by name ("it exercises no file this leg changed; the
orchestrator's own"), and the words-pass record claims "byte-pinned to the plan" on its strength. The SEED ITSELF IS
RIGHT — I extracted the four passages correctly (blockquote lines only, bounded at `**(6)`) and they byte-equal
`ReadmeSeeder.paragraphs[5...]` exactly as the record describes (`**` leads dropped, lines reflowed) — so the defect
is confined to the pin. · Evidence: my reproduction prints `chunks: 4 · drafted count: 3 · chunk 3 len 2012`; the
independent extraction prints 4/4 MATCH against the seeder. · Fix: bound the section at `**(6)` instead of `## 8.`,
and take only `>`-prefixed lines (or start each chunk at its first `>` line) before joining; then the existing
assertions hold. Prove it both ways: green on the current seed, red with one seeded word mutated. ADD the suite to
the stage's run list (as committed it is both red and un-scheduled, so the phase could close with a red test on the
tree and break the next effort's baseline).

**[MINOR] · App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift:122-147 +
App/Variorum/Variorum/LaunchFurniture.swift:122 · The Start Here passages seed into fresh stores on TODAY's road too
(Release, and real-variant Debug), where their claims are false until VX-329** · Mechanism: `ReadmeSeeder.seedAtBirth`
runs on every fresh store's Welcome arrangement with NO road gate; `ProtectionRoad.newRoadIsLive` is compile-time
Debug + the bootstrap's dev-variant fence, so a fresh RELEASE store (and a fresh real-variant Debug store) is born on
today's road and now carries blocks 6–9 claiming: twelve words "were shown once, when the library was created" (no
words card exists on today's road — the card is this phase's, dev-Debug only); "you can make new ones in
Settings ▸ Data Safety" (no such door exists on today's road — the new-words door is VX-308's); "its own random key,
kept in a small key file beside it" with keychain-sealed copies (the new design's shape, not today's). The fix leg's
own discipline for every OTHER VX-379 row is the opposite and is stated in the words-pass record: "TODAY's road's
words, still true for Release until VX-329 — rewritten when the road switches." These four passages invert that rule,
and the record nowhere states the Release reach. The fix-leg close's "Release: byte-unchanged in BEHAVIOUR" sentence
is true of the LEG's changes but not of this round's diff — the seeder is Release-reachable behavior. Reach: fresh
stores minted on Release builds between VX-306's merge and VX-329 (testers; any release cut in between ships it —
the runway has VX-307/308/309 before VX-329). · Pin: seed a fresh store with the new road off → the readme carries
her five blocks only (red today: nine). · Fix: (a) seed blocks 6–9 only when `ProtectionRoad.newRoadIsLive` (VX-329
then flips Release; the 17y B-DEDUPE fold already handles stores seeded short — differing seeds keep both copies), or
(b) HER explicit call at the bundle accepting the early text, recorded with a named VX-329/VX-379 row. Either way the
P-VX306-W-1 bundle entry should carry the Release-reach fact so her call is informed — it currently reads as a pure
words/placement question.

**[MINOR — the ruling the fix-leg record asked round 2 for] · Sources/VariorumCore/Protection/Executor/Acts/
DeviceActs.swift:109-137 (`createLibrary`) · The core act writes the silent item, this Mac's Apple key and THE LIVE
KEY FILE (`writeLiveKeyFile`, an atomic replace) before `leaves.library.createLibrary` meets the no-clobber belt** ·
Verified by reading the write order — the record's trace is accurate. My ruling, as asked: AGREE with the
hand-forward, and it should be built (VX-307's first commit or this phase's close, whichever is cheaper): a core
preflight — refuse a non-empty slot BEFORE the first write — makes the act honest on its own instead of by its
callers' manners. After m1 it is unreachable from any app road (`.startFresh` is an empty slot by verdict; both
faces set the slot aside first — traced), so NOT a blocker now; but the act's doc says "in an empty slot" while its
actual failure mode over a non-empty slot is writing over the live key file (rule 1's "as essential as the library")
plus two orphan keychain items — exactly the class m1 just paid for. · Pin (red today, headless): core
`createLibrary` with a file in the slot → refuses with ZERO custody/apple/key-file writes and the live key file
byte-untouched. · Route: a named hand-forward in the handoff (VX-307), or fix now; the record's note alone is not an
owner.

**[NIT] · the m2 hand-forwards' routing (the fix-leg record's two enshrined edges) ·** (i) at *Make this my library*
over a copy only Touch ID opens, the preflight and the act each press (two prompts for one press); (ii) the look's
typed *Open* with a WRONG secret falls through to the copy's quiet roads, Touch ID included — a prompt after a wrong
secret, and the copy OPENS (rule 17's letter, arguably surprising after a mistyped secret). Both are recorded in the
record and (ii) is now PINNED AS EXPECTED by
`LookInsideRoadTests.theLooksFirstTryNeverPressesTouchIDAndHerOpenMay` (`look.phase == .open` after
"not this copy's passphrase"). Fine as the recorded interim — but the only home either edge has is the fix-leg
record's prose. They must land by name in the handoff/VX-307's brief (as m3 landed as VX-411), and VX-307 must know
pin (ii) is a deliberate flip-target, not a wall.

**[NIT] · Sources/VariorumCore/Protection/Executor/Acts/Copies.swift:255-257 vs
App/Variorum/Shared/Protection/ProtectionCopyDoors.swift:120-122 · Two same-named doors, opposite defaults** · Core
`ProtectionExecutor.lookInside(… quietRoads: = .includingTouchID)`; app `ProtectionCopyDoors.lookInside(…
quietRoads: = .withoutAPress)`. Both locally motivated (core: the model's own door + the scenario world/walk read
byte-for-byte; app: a caller that says nothing never prompts) and both documented — but the PROMPTING default sits
on the lower layer, so a future core caller that says nothing presses Touch ID. Safer shape when next touched
(VX-307 touches exactly this seam): drop the core default and make every core caller choose; the handful of
test/walk call sites take `.includingTouchID` explicitly. Not worth churn now.

**[NIT] · App/Variorum/Shared/Protection/ProtectionCopyDoors.swift (`pick`) + CopyDoorsModel ·
A PICKED copy is filed into safety copies but the standing Restore list doesn't show it until the pane reopens** ·
Mechanism: `roads.pick` files the picked pair/library into this Mac's safety copies (P-VX306-U3-0: "the copy then
stays listed"); nothing posts `CopyDoorsListModel.copiesChanged` (only the backup hook posts it), and the pane's
`.task` runs per appearance — so after closing the picked copy's doors sheet, the list omits the copy she just
filed until she leaves and reopens the pane. m4's own class, one line to cure with the seam m4 just built (post
`copiesChanged` after a pick lands a copy), pinnable at the model level exactly as m4's. Self-heals on reopen;
fix now or ride VX-309 (the copies list's owner) by name.

## Round 1's findings — did each fix land as a fix? (the round-2 re-check, finding by finding)

- **m1 (K5's missing face over a record-less store) — LANDED, verified.** Both faces now take ONE road,
  `ProtectionOpenRoad.startNewLibraryFromAFace` = `create(setAsideLiveKeyFile: true, setAsideUnopenableLibrary:
  true)`. Traced the composition myself: `setAsideUnopenableLibraryFor` (slot non-empty → store + sidecars + live
  key file move WHOLE to `Previous Libraries/<stamp>/`, sidecars first with rollback, never deleted) then
  `setAsideLiveKeyFileFor` (guards `!fileExists(slot)` — a no-op after the first moved everything; over an EMPTY
  slot it alone moves the orphan key file, so the plain missing-library case is byte-equivalent to pre-fix); rule
  27's face is byte-equivalent to its old call; today's road (`LibraryMissingLobby`'s own act) untouched;
  `.startFresh` untouched. The headless pin asserts the strong set (the words, the new key file, the old key file
  byte-equal aside, the old store still opening with its own key, exactly ONE folder aside); the bootstrap twin is
  the reviewer's pin as specified (PENDING the stage). The implementer's red-on-old (pre-fix flag restored →
  1 issue; probe showing `liveKeyFileOverwritten=true silent 1->2 apple 1->2`) is consistent with
  `DeviceActs.createLibrary`'s write order, which I read (finding 3 rules on the residue).
- **m2 (the automatic quiet probe pressing Touch ID) — LANDED, verified red-on-old BY ME.** `CopyQuietRoads` scoping
  in `openCopy`'s custody arm (the Apple-wrap arm correctly stays in `.withoutAPress` — it never prompts); every
  call site enumerated: the two AUTOMATIC probes (`ProtectionCopyDoors.opensQuietly` :111, the look's `begin()` →
  the app wrapper's `.withoutAPress` default) never press; the three DELIBERATE presses (the look's typed Open, the
  confirm's preflight :162, the act's `openCopy` :340) pass `.includingTouchID`. I ran the core pin green, reverted
  the scoping line, saw 3 issues red, restored green. The app pins (`CopyDoorsQuietProbeTests` ×2) exercise the
  REAL production seams (not planted tautologies) with a counted `.touchid` read standing in for the press;
  `CopyDoorsModelTests`/`LookInsideRoadTests` pin the handed scope end to end. The recorded red-on-old (4 issues on
  the pre-fix Shared files) is credible and the committed core default keeps every pre-fix call byte-identical.
- **m3 (pair retention) — TICKETED as disposed.** VX-411 exists on Linear: Castle & sync · Confirmed · Debt ·
  Medium, project "Castle & backups before launch", body pointing at round 1's MINOR 3 + the files, naming VX-309
  as the natural owner and rule 22. Correctly labeled to her 2026-10-14 rule.
- **m4 (the stale Restore list) — LANDED, mechanics verified.** The hook posts `copiesChanged` on the main actor
  only after `takePair` answers `.written`; `CopyDoorsListModel` observes from birth (weak self; token removed in
  deinit; `MainActor.assumeIsolated` under a `.main`-queue observer is sound) and re-reads with newest-read-wins
  numbering — I walked both orderings (older-finishes-last dropped by the guard; older-finishes-first overwritten
  by the newer) and both pins assert exactly them. No edit to fenced `StoreBackup.swift`; the pane untouched. The
  Mac seam twin (`ProtectionBackupHookTests.aLandedPairTells…`) exercises the real hook → the real listing
  (PENDING the stage; its stated by-trace red — the pre-fix `handle` posts nothing — is correct by the diff).
- **NIT 1 — LANDED.** `CatalogNames.backupsFolderName == "Backups"` (read the constant: behavior-preserving);
  the source pin's rationale (a behavior pin is green on both sides) is honest and its logic was demonstrated on
  both file states; today's road's literal deliberately untouched.
- **NIT 2 — LANDED.** The `guard try?` became a do/catch with one `log(…)` line and the SAME `break` (behavior
  unchanged); the line carries an error description of a custody LISTING failure — no key material class. The
  no-committed-pin rationale (the unified log has no test seam; a seam would be new global state) is sound; the
  harness-only probe observation is recorded.
- **NIT 3 — LANDED, the rework walked whole.** One reader per model lifetime (traced: a reader exists only past a
  successful open, and after `forget` the phase guard refuses a new assignment); every read runs through `read()`
  which records the in-flight task with no suspension between creation and recording (main-actor serialized);
  `forget()` drops all state at once, then closes the outgoing reader DETACHED, after awaiting the in-flight read;
  stale reads land nothing (`self.reader === reader` guards in `load`/`moreNotes`/`show` and the first-page arm in
  `attempt`); the forgotten-while-opening arm closes the fresh reader detached; double-forget is a no-op that keeps
  the first closing task. Close is never refused (the P-2-shaped reading of "busy guard" — better than the report's
  own offer). Interleavings I probed for a leak or a landing-on-closed: forget-during-open, forget-during-first-read,
  forget-during-page-read, submit-after-close (unreachable via the face; harmless via the closed-guard arm) — none
  found. The no-new-pin rationale (a deterministic close-during-read needs a holdable reader; the core reader's
  reads are fixed queries) is acceptable; the proof suite now awaits `closing` (+ the off-main assertion).
- **NIT 4 — LANDED.** `offersSetPassphrase` born `!passphraseExists()`, re-read in `makeSetPassphraseSheet`'s close
  (BOTH roads to the sheet — the pane's row and the reminder bar — construct through that one function on the same
  model, checked by grep); the pane's condition `if let roadStanding, roadStanding.offersSetPassphrase`; the sheet
  keeps its refusal for a passphrase appearing while it stands; the reminder untouched (it never shows once one
  exists). The headless pin + the composition pin (asserting on `ProtectionWords.reminderSetDoor`, which the row
  renders — and which today's title-case row does not collide with) are the right pair; the composition pin's
  by-construction red is credible (the pre-fix condition composed the row for every standing model).

## Clean bill (load-bearing things specifically checked and found solid)

1. **No sync surface.** SyncSpec read in full against the leg: zero synced-table, payload, schema, `Server/` or
   `Sync/` lines; the marker untouched; the one notification is app-local; nothing touches `SyncCustodyRecord`/
   the vault leaf/device identity; S1–S5 unimplicated. The custody change is the protection executor's copy-open
   READ scope only.
2. **Rule 24 / Release parity of the core change.** `swift build -c release` green here; no `#if DEBUG` added; the
   core's new parameter defaults keep every existing call byte-identical (the scenario world, the lifecycle walk and
   the U2 suites read unchanged — confirmed in the diff).
3. **Rule 17 held through m2.** The deliberate doors still reach the copy's own quiet road on this Mac (Touch ID's
   included); only the never-asked automatic probes narrowed; the Apple wrap (never a prompt) stays in both scopes.
   Look inside still writes nothing (the write-log/byte-identical/private-folder proofs re-run with the close
   awaited).
4. **m1 leaves no clobber road.** Both faces set aside FIRST; the set-aside moves (never deletes); the no-clobber
   belt stays as the last line; the pins assert the old key file byte-equal and the old store still opening — rule
   26's "not handled" honored as set-aside-whole, K5's "as if absent" honored as the door ACTING.
5. **Suites.** Core: `U2LookInsideTests` 4/4 and the protection set (my 72-suite filter, 295 tests) green Debug on
   the final tree; release build green. The Mac/phone batches remain PENDING the stage exactly as the record says,
   with the stage list and the two optional red legs spelled out — plus finding 1's suite to add.
6. **The words pass's content.** The four seeded passages byte-match §7c (5) (my own independent extraction, 4/4),
   her five blocks keep their place, count and bytes; `noShoutyCaps…` holds; P-VX306-W-1 recorded in QUESTIONS #233
   with the never-option (c) named; her real store's readme untouched by any session (the record's handoff line).
7. **Process.** No commit trailers on any fix-leg commit (checked the full range); per-piece commits with the pin in
   the same commit; the round-1 report committed unedited; the record's LIVE STATUS discipline held; the two-writers
   machinery fact (the words-pass commit landing mid-leg) recorded honestly and the leg built on it; no worktree
   residue claimed or found; VX-409/VX-411 routings real on the board/Linear.
8. **P1.** Nothing in the leg scales with corpus size (the list re-read is copies-proportional; the look's reads
   stay page-bounded; no text copied across entities; no word-level tracking).
