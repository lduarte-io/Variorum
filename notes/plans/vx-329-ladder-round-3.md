# VX-329 — ladder round 3 (cold review, Fable, 2026-10-22) — FINAL round

**Reviewer:** fresh `fable-reviewer`, zero implementation context, REVIEW_PROMPT verbatim; round 3's scope per the
ladder rule — re-review what landed since round 2's read, against round 2's findings: (1) the round-2 MAJOR's fix
(the five flipped runbook pins, `c47c61b84`); (2) the two MINOR word corrections (`514f8e60c`) and the delta brief's
rule-27 line (`6882f89b8`); (3) U4 whole (`fe311b5b7`..`0f17932a9` — the fact, her words, the face, the whole
set-aside, (D)'s landings and gates, the pins); (4) the one-byte runbook fix (`190bf985e`) and the closing-batch
record's telling of it; (5) the honesty of the records landed since round 2 (§8 staging row, the U4 record, the
closing batch record) against the tree and the logs; (6) the switch-day testers' section (`a7176e7f7`) against the
shipped build.
**Canon read in full, myself:** CLAUDE.md + auto-canon · `notes/CastleRules.md` whole (17, 20, 21, 26, 27 U4's
heart) · the plan whole (§1–§8, every unit record, THE RULING, the closing batch record) ·
`notes/plans/vx-329-ladder-round-1.md` · `-round-1-fixes.md` · `-round-2.md` (rounds 1–2's findings are the spec for
items 1–2) · `notes/plans/vx-329-switch-day.md` whole · `notes/SurfaceContracts.md` (Doors — Library protection).
**Review foci:** the plan carries no "Review foci" section (round 1 checked; re-confirmed) — none bind.
**Constraints honored:** headless `swift build`/`swift test` and read-only verification only; no stage, no
`xcodebuild test` (the closing runs are the record; their logs read from the session scratchpad:
`vx329-mac-suite-closing.log`, `vx329-ios-suite-closing.log`); no subagents; no edits to product code or the plan.

---

## FINDINGS (severity-ranked)

**[MINOR] · notes/plans/vx-329-switch-day.md §"The beta testers' line" (the paste-ready message's last paragraph,
and the prose sentence above it) · "reinstalling 0.9.8 still opens your old library" is true only BEFORE Start
fresh is pressed — and the message instructs pressing it two sentences earlier** · Evidence (the mechanism, traced):
*Start fresh…* moves the old library WHOLE out of the slot into `Previous Libraries/<stamp>/`
(`PreDesignSetAside.setAsideWhole` — step (3) unlinks every member from the slot,
`Sources/VariorumCore/Protection/Files/PreDesignSetAside.swift:144–152`), then the calm creation mints a NEW 0.10
library into the slot (`ProtectionOpenRoad.startFreshOverAPreDesignStore` → `create`). A reinstalled 0.9.8 then
launches against the slot, which holds the new library under a format-3 key file (`variorum-library-keys.json`) and
a key 0.9.8 does not hold — the old library does NOT open on reinstall alone; the road back is the aside
(hand-move its files back into the slot — they are whole, same inodes, pinned by `PreDesignSetAsideTests` and
walked live on her store's byte copy). The sentence is honest for the tester who saw the face and quit WITHOUT
pressing Start fresh ("0.10 writes nothing to a store it refuses" — pinned,
`PreDesignStoreRefusalTests.theLiveSlotShowsHerPreDesignFaceAndTouchesNothing`), but the message's own prescribed
flow (paragraph 2: "Press Start fresh") makes the common case the one where the sentence is wrong. Nothing is ever
lost (nothing deleted; the aside is whole) — the cost is a tester reinstalling 0.9.8 expecting their old library
and meeting its lobby over an unreadable store. · Fix (wording only; the message is paste-ready FOR HER, so the
corrected words go through her before it is sent with the release note): split the last line's two cases — e.g.
*"If you ever need the old version again: before you press Start fresh, reinstalling it still opens your old
library — 0.10 never writes to a library it can't open. After Start fresh, your old library is whole in Previous
Libraries (inside Variorum's folder) — move its files back and the old version opens it."* The prose sentence above
the message ("…so reinstalling 0.9.8 still opens it") takes the same clause. Doc/message-class — no pin (the
justification above is the traced degradation); zero product edits.

**[NIT] · notes/plans/vx-329-ladder-round-2.md:243 · a dangling edit fragment** · The round-2 fix-leg's
compile-evidence bullet (flipped at `1c891d09e`) ends "…The pins' GREEN run is the closing Mac batch's." and is
followed by a stray orphan line "  in the next commit)." — residue of the flip. · Fix: delete the line (record
hygiene; the closing-batch record is the truth it pointed at).

**[NIT] · notes/plans/vx-329-release-switch.md §6d ("The build:" step 1) + §8 addendum · the older fingerprint-named
key file is written `variorum-keys-<fp8>.json`; the real name carries 16 lowercase hex characters** · Evidence: the
code's one rule (`LibraryClassifier.isOlderFingerprintKeyFileName` — `middle.count == 16`, lowercase hex;
`CatalogNames.isPreDesignKeyFileName` delegates to it), R-U1-2's own text ("`variorum-keys-<fp16>.json`"), the
staging row ("the two `variorum-keys-<fp16>.json`") and her real store's copy on disk all say fp16 — while this
codebase's `fp8` convention elsewhere (the backup pair names) means EIGHT hex characters, and the pins deliberately
assert an 8-hex name is NOT pre-design (`PreDesignStoreFactTests`: `variorum-keys-0a1b2c3d.json` keeps rule 27). A
later reader implementing from §6d's letter would match the wrong width. The shipped code and pins are right; the
two doc spots are the drift. · Fix: one-word correction (`<fp8>` → `<fp16>`) in the §6d build step and the §8
addendum, at the closeout's record pass. Doc-class, no pin.

## DISPOSITION NOTES (checked, deliberately not findings)

- **"Her two approved word corrections" (`514f8e60c`) — the approval is recorded only in the commit message.** The
  round-2 fix route said the corrected sentences "go through her (the morning bundle)"; the commit asserts her
  approval and nothing in the repo contradicts it (she was in session that day — the U4 words sitting). Not a
  finding (no traceable wrong mechanism); the closeout's AppSpecRecord entry should carry the approval's narrative
  so the record outlives the commit message.
- **The "byte-equal trio" is really a byte-equal PAIR plus an annotated draft.** The literal and
  `notes/DataSafetyRunbook.md` are byte-equal including the final byte (my own reconstruction below); the draft
  record (`notes/plans/vx-329-restore-md-draft.md`) differs ONLY by its two deliberate annotation asides ("*(The
  next two paragraphs are shared constants…)*", "*(A shared constant, shown inline:)*") and their line-wrap
  consequences — all six of `514f8e60c`'s correction lines landed in it too. The binding equality is the pin's pair;
  round 2's "trio" phrasing was loose, not wrong in substance.
- **Round 2's reviewer shared the newline blind spot.** The closing-batch record attributes the one-byte miss to
  the r2 fix leg's count-based proof; round 2's own "byte-equality reconstruction … BYTE-EQUAL: True" ran after the
  rewrite and was equally newline-insensitive (a true byte comparison would have been False at that tip). The
  suite's own pin caught it in the closing run — the tripwire working. Recorded for completeness; the record as
  written is accurate about what it names.
- **The gate-arm revert's issue count (closing batch record: "2 tests … 8 issues") is mechanism-consistent but not
  re-runnable here.** The direction is certain from the code: with `|| lobby.face.preDesignStore` reverted on both
  gates, a pre-design lobby falls to `default: return .refused(.failed)` in `bringInPlaintextExport` and
  `makeThisMyLibraryInTheEmptySlot` (AppBootstrap.swift:713/:798), so both pins read `.refused(.failed)` at
  `== .made`. The exact per-test issue arithmetic (8 vs my read of ~4) is the stage run's own; a revert re-run needs
  `xcodebuild test`, outside this round's limits. No product consequence either way.
- **T-5's landing over a pre-design slot overwrites the OLD library's restore-hold marker in place** (the new hold
  is written at `ProtectionCopyDoors.swift:400` before the set-aside runs `carryingHold: false`), so a pre-design
  library that was itself sitting mid-hold loses its hold file from its aside. Recorded as designed in THE RULING
  ("T-5 … carrying no hold: its own hold was written first") and inert in practice: the hold is a sync gate, a
  pre-design store cannot sync against marker 14 at all, and Start fresh (her door) and T-8 both carry the hold
  whole. Checked, accepted.
- **The §8 rehearsal record and the switch-day REHEARSED marks** (landed after round 2's read): the marks now cite
  a §8 record that exists; `780e95618` honestly corrected the prior commit's overclaimed marker flip. Round 1's
  MAJOR is closed in substance. The rehearsal's SQL/walk claims are the orchestrator's own acts (not re-runnable
  headless); the quoted product sentences I could check match the code byte-for-byte (`makeMineReceipt`, the
  backups-folder refusal, rule 21's notice, the VX-464/VX-469 lines).
- **F-U4-1..5 and P-VX329-U4-1..6 are recorded with real referents** (I re-traced F-U4-4's mechanism: with no
  listing, `ProtectionLobbyFace.derive`'s facts-nil arm defaults `preDesignStore` false, so the typed field shows
  with the keychain line — exactly as flagged; F-U4-5 was discharged at `a7176e7f7`). The phone's F-U4-2/3 state is
  honest: the fact and model compile for iOS, the auto-ask stands down (`ProtectionLobbyModel.swift:112`), the face
  is VM-8's.
- **The `.stale-<epoch>` set-aside names ride the members but never the fact** — deliberate and consistent
  (`CatalogNames.isPreDesignKeyFileSetAsideName` is "never part of the slot's fact"; the keyless-arm pin asserts a
  lone `.stale` name keeps rule 27). Checked: this design's own `variorum-library-keys.stale-…` can never read as a
  pre-design set-aside (the prefix+".json" round-trip reaches `isPreDesignKeyFileName`, which refuses it).
- **The walk-window record's checkable claims hold:** the captures exist (`~/vx329-walk/cap-01..`, deletion owed at
  closeout as stated); the staged copy at `/Users/Shared/vx329-rehearsal/` holds exactly the staging row's 7 files
  (store + wal + shm + `variorum-keys.json` + two `variorum-keys-<fp16>.json` + the 0-byte `store.sqlite` stray)
  plus `README-for-Lillian.md`; the A1 twin's path matches the record; every product sentence the walk record
  quotes exists byte-identical in the tree.
- **DiagnosticReports matches the closing record:** the one Variorum .ips is F-FL-1's 08:24; the 14:47
  `swiftpm-testing-helper` .ips exists as recorded; no test-host crash from the closing runs.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The five flipped runbook pins (`c47c61b84`) are justified edits, byte-exact.** My own reconstruction of the
   Swift literal (closing-indent stripped, `\`-continuations joined, the three interpolated constants substituted
   exactly as Swift evaluates them) finds each of the five new expectation strings EXACTLY ONCE in the literal and
   once in `notes/DataSafetyRunbook.md`, and each of the five old strings ZERO times in both — the red-on-old is
   the then-current red, as the finding said; the absence arms and the eight heading pins kept; the stale U1
   comment above the floors rewritten true; zero product edits in the commit (its only other file is the ladder
   record). The new rule-27 pin quotes the amendment whole (loss leg + synced exception, both secrets).
2. **The one-byte fix (`190bf985e`) is exactly one byte of meaning and the records tell it honestly.** The blank
   line before the closing `"""` gives the literal its final newline; my reconstruction proves literal == repo doc
   **byte-equal including the final byte** (14,684 bytes each). The closing-batch record names the failing pin, the
   mechanism (the r2 proof's newline-insensitivity), the fix and the 5/5 re-run — and the closing Mac log confirms
   the one red was `theShippedRunbookAndTheRepoCopyAreOneDocument` at DataSafetyTests.swift:219 and nothing else.
3. **The two word corrections (`514f8e60c`) are true of the shipped build.** "One copy a day lands in each place":
   both legs share the 24 h clock (`StoreBackup.Configuration.interval = 24*60*60`,
   `ProtectionBackupPair.farInterval = 24*60*60`) and the pane's own sentence agrees ("once a day",
   `DataSafetyPane.swift:132`). "The pane says what opens a copy": `ProtectionWords.dataSafetyWhatOpensABackup`
   rendered at `DataSafetyPane.swift:144` — rule 5's one-sentence reduction, exactly the
   considered-and-not-pursued ledger's shape. The delta brief's rule-27 entry (`6882f89b8`) now carries the
   amendment's words ("the account's passphrase or twelve words").
4. **U4's FACT is pure, names-only, and precedes every road.** `AssessRules.preDesignStore(storeFile:catalog:)`
   reads the store's presence and the container-root foreign names only (`$0.place == .container &&
   $0.folders.isEmpty`), one rule with the picked-copy classifier (`CatalogNames.isPreDesignKeyFileName` delegates
   to `LibraryClassifier`'s two name rules); an undecodable format-3 NAME still counts as a live key file (listed
   with `role == .live`, `document` nil), so that slot keeps the lobby; `ProtectionOpenRoad.route`'s
   `.preDesignStore` arm returns the lobby BEFORE any quiet candidate; the gatherer skips every silent-item read
   and key try on the fact (`ProtectionFactsGatherer.swift:56–58,101`), pinned by
   `aMacThatRemembersALibraryOfThisDesignShowsHerFaceNeverTheLobbysRoads` (`custody.reads` empty) — the §8
   addendum's wedge closed at its mechanism.
5. **Her words are byte-faithful and the Mac face is hers alone.** `preDesignLead` / `preDesignBody` /
   `preDesignStartFreshConfirm` / the two doors match §6d byte-for-byte (my own comparison; `PreDesignFaceTests`
   additionally reads §6d from the plan file at test time, so a drift goes red); the face branch renders her lead
   as the heading (no lobby title — P-VX329-U4-1 (a)), her body, her two doors, the confirm before the act, the
   busy dots with no "Opening…" (P-VX329-U4-4); *Start fresh…* renders only with the fact AND a wired act
   (`offersStartFresh` — P-2), and the automatic Touch ID ask stands down on the fact.
6. **The whole set-aside (`PreDesignSetAside.swift`, read line by line) delivers rule 20's substance.** Members
   named from the listing alone in leave-order (sidecars, store, older key files + their `.stale` set-asides,
   the hold when carried) — never this design's files, the lived-here marker, the recipe or hers; stage by
   `linkat` with per-link same-file verification and a same-volume guard, ANY failure removing the staging (and a
   Previous Libraries folder the act made) with nothing moved; the commit ONE `renamex_np(RENAME_EXCL)` that never
   overwrites an existing stamp; the unlink per-entry only while the slot's name is still the aside's inode. The
   resume is identity-based (`lstat` device+inode, never a byte): stale staging swept only when every file is
   still linked elsewhere, else committed to its own stamp (never deleted); a committed remainder finishes into
   THAT folder in members' order; a store leaves only when every present sidecar is its aside's too — the
   foreign-WAL case refuses and leaves the slot as it is (the one case where unlinking would orphan newer frames).
   No byte of the old store is ever read (`Data(contentsOf:)` exists only in the pins). The 16 crash arms, the
   failed-link refusal, the taken-stamp arm and the sweep-safety pin are real and non-vacuous; my own headless run:
   **`swift test --filter PreDesign` — 18 tests in 3 suites PASSED** (the fact's 7, the set-aside's 8, the
   classifier's 3).
7. **(D) is one seam and the gates are fact-scoped.** `setAsideLibraryWholeFor` routes a pre-design slot through
   the whole act by a fresh disk read (`slotHoldsAPreDesignStore` — never the stale face), so T-5
   (`ProtectionCopyDoors.swift:406`, via `setAsideUnopenableLibraryFor`), T-8 (`:487`, carrying the hold) and the
   faces' *Start a New Library* all keep her confirm's promise; `startFreshOverAPreDesignStore` re-reads the fact
   and moves nothing on a stale face; `create` runs the resume on every creation (a first launch returns at once);
   the two gates admit exactly `noKeyFileAnywhere != nil || face.preDesignStore` and every other occupied shape
   still refuses (`AppBootstrap.swift:713/:798`); one landing at a time (`copyLandingRunning` shared by Start
   fresh and both landings).
8. **The closing records are honest against their logs.** The closing Mac log:
   `✘ Test run with 5097 tests in 892 suites failed … with 19 issues (including 4 warnings and 14 known issues)`,
   the ONE real red the runbook byte pin, the 4 warnings the standing `Date.swift:37` class, xcodebuild's failing
   list naming only that test — exactly as recorded; U4's four Mac suites and the r2-flipped pins all ✔ inside
   that run (grepped individually). The closing phone log:
   `Test run with 808 tests in 126 suites passed … with 4 known issues`, zero ✘, TEST SUCCEEDED, every "skipped"
   mention a test's own name — exactly as recorded.
9. **The U4 record matches git.** The fork was committed before the ruling, the ruling before the build
   (`8cdc33118` → `b02b9bb8f` → `5e3d19d91` → `6da8cb743` → `0f17932a9`); the Sync/ fence
   (`git diff 238519724..HEAD -- Sources/VariorumCore/Sync`) is EMPTY at the tip; the staging row (round 2's NIT)
   landed in the ruling commit with date, the 7 files by name, the per-file cmp and the A1 twin.
10. **The switch-day testers' section is otherwise true of the shipped build:** the deploy-closes-the-sync-window
    timing, Copy full text as the old-build road (never 0.9.8's broken export door), VX-461 shipping only in 0.10
    (walked live, three arms), her face's lead quoted byte-identical, Start fresh's set-aside-whole promise, and
    the message's sync arm (§8's rehearsed join). The one wrong clause is the MINOR above.
11. **No violations of the absolute classes in the round-3 diff:** nothing tracks word-level change, nothing
    copies text across entities (the set-aside moves directory entries, never bytes), nothing scales with corpus
    size (the set-aside is per-member constant work over a handful of names), no trigger, no schema, S1–S5 and
    I1–I10 untouched; rule 24 honored (the new core files carry no `#if DEBUG`; the seam parameter is internal).

## MY VERIFICATION RUNS (headless, this session)

- `swift test --filter PreDesign`: **18 tests in 3 suites PASSED**.
- Full core debug suite ×3 at the tip (`06e28e31f`): **VariorumCoreTests 3303 tests in 431 suites PASSED** (clean
  on runs 1*/3; U4's recorded debug floor exactly) · StringsWorkbook 32/4 PASSED · VariorumMCPTests 383/71 with the
  ONE recurring `MCPHarnessTimeLimitTests` wall-clock flake (16.5–18.6 s against its 15 s bound under the full
  parallel load; the phase's documented, closeout-ticketed flake; the MCP target untouched by this phase).
  (*Run 1's single transient core issue did not reproduce in run 3's clean pass — the recorded load-flake family.)
- `swift test -c release` (the full package): run in this session; result appended below.
- The byte proof (scratchpad, mine — not the fix leg's): the evaluated runbook literal (indent stripped,
  continuations joined, interpolations substituted) **== `notes/DataSafetyRunbook.md`, all 14,684 bytes, final
  newline included**; the five new pins ×1/×1, the five old strings ×0/×0, both word corrections ×1/×1.

- **The release leg (`swift test -c release`, full package, at the tip):** ALL GREEN, exit 0 — VariorumCoreTests
  **3274 tests in 426 suites PASSED** (U4's recorded release floor exactly); VariorumMCPTests 383/71 PASSED (no
  flake this run); StringsWorkbook 32/4 PASSED.

---

**ROUND 3 VERDICT: PASS — no BLOCKER, no MAJOR. One MINOR (the testers' message's "reinstalling 0.9.8 still opens
your old library" clause — a wording fix routed through her before the message is sent) and two NITs (a dangling
line in the round-2 record; the §6d/§8-addendum `<fp8>` → `<fp16>` doc drift). Round 2's MAJOR fix is CONFIRMED
(byte-exact justified edits, green in the closing run but for the one-byte pin, itself fixed and re-proven here);
both round-2 MINOR word corrections and the delta-brief line are CONFIRMED as landed and true of the shipped
build; U4 is CONFIRMED whole — the fact, her words, the face, the set-aside's crash story, (D)'s one seam, and the
pins are solid, and the records landed since round 2 are honest against the tree and the logs. The hard cap
stands: the three findings are wording/record fixes under the orchestrator's line-by-line check; nothing here
re-opens the ladder.**
