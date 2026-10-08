# VX-99 — Pro library stayed Apple-openable after Castle (the record)

**NOT DONE by the fix session (2026-10-08):** the double-crash residual of the resume's another-device road
(recorded under THE RESUME-RULE DELTA — outside the ruled scope); the two PRE-EXISTING 13x reds in
`PostureSwitchTests` (VX-106 now, out of scope); no dev-store walk or capture (the plan's evidence clause — a key
file's wraps are invisible in UI; the pins carry it); no phone run (the phone COMPILE is recorded); no core re-run
after the resume-rule delta (it touches no `Sources/`; core stands green at 37e26d2e's code); the cold review (the
orchestrator's ladder).

**Status: FIX BUILT (both pieces — the ceremony/resume/local-only decision and the ruled resume rule), pins
red-on-old and revert-verified (V99-A, V99-B), Mac + core green (bar VX-106's two pre-existing reds) — awaiting the
cold review.** Findings: read-only investigation 2026-10-08. The fix ran after 13x merged, in the
Sync/-custody slot taken at `f797dbe7`.

## Cast (changed at her word, 2026-10-08)

Kicked off on Fable per CLAUDE.md's custody rule. **Switched to Opus by her word mid-investigation**:
*"There's no way this prompt and session will work with Fable - even though I'm trying to keep my users
safe, every other message trips the safeguards. Note the change and continue on Opus."* The
orchestrator and the investigation are Opus from that point on. The cold reviewer for the eventual fix is
**hers to name** (Fable is the standing rule for custody; the same safeguard friction may apply).

## Evidence read (field names and short id prefixes only, never a wrapped value)

| key file | written (local, UTC−6) | library key | corpus key id | `apple` | `master` | `recovery` |
|---|---|---|---|---|---|---|
| `variorum-keys.json` (format 1) | Sep 1 01:55 | 8e15… | — | no | no | yes |
| `…-8e15801e…` (format 2) | Sep 5 21:28 | 8e15… (same key) | 3309… | **no** | yes | yes |
| `…-182738de…` (format 2) | Sep 7 02:15 | **1827… (re-keyed)** | **a781… (rotated)** | **yes** | yes | yes |
| `…-a1e93a2d…` (post-follow) | Oct 8 00:55 | a1e9… | a781… (unchanged) | no | yes | **no** |

Sources: `~/dev/variorum-fixtures/pro-castle-apple-wrap-2026-10-08/` (copied to scratch first), the live
post-follow file (id fields only), the pre-13x ledger row 51.

## (1) Which road — TRACED

- **The Castle entry on the Pro was the pre-13x MIGRATION at the window (Sep 5 21:28)** — §11: both her
  devices mapped to Castle; the `8e15…` file is the same library key re-written as format 2 with the
  master-wrapped copy and NO `apple` copy. Castle-correct.
- **Sep 7 02:15 local = 08:15Z = her REPLACE ALL KEYS on the real account** (pre-13x ledger 51, the
  *[removed for publication]*
  Castle", `updated_by_device` her MacBook Pro). That act re-keyed the library (8e15→1827) and wrote the
  `182738de` file **with an `apple` copy**. The vault stayed Castle (no Apple-held master copy) — only the
  Pro's local key file was wrong. That is why no Castle-only key file existed beside the library.
- **The mechanism** (`App/Variorum/Shared/PostureSwitch.swift`, identical at the Sep 7 build `9693e769`
  line 1041 and today line 1065): `writeNewKeyFile` sets
  `let apple: AppleKey? = entersCastle ? nil : leaves.appleKeys.read()`. Replace All Keys runs
  `run(entersCastle: false, …)` (line 420), so on a CASTLE account it adds the Apple copy whenever the
  iCloud key is readable on that Mac. Her Pro still held its iCloud key from the Standard/13p era
  (`appleKeyID a330…`). The VAULT side of the same act is posture-gated
  (`appleHeldCopyForStandard`, line 1166: `guard leaves.posture() == .standard else { return nil }`) —
  the key-file side is not. The doc comment at line 1047 states the intent ("the Apple copy ONLY under
  Standard's Replace All Keys"); the code does not implement it.
- The crash-resume road (`resume`, line ~1243 → `rekeyCustodyAndSnapshot` with `marker.entersCastle`)
  shares the same writer, so a resumed Castle Replace All Keys would do the same.
- Custody moved correctly (`moveCustodyForSwitch` derives the gate from posture → biometric), which is
  why the Pro kept asking for Touch ID and nothing looked wrong.

## (2) Today's code — YES, it still produces this state

Bug-class fix with a red-on-old pin. **No existing test covers Replace All Keys on a CASTLE account:**
the test world's iCloud key is always readable (`makeWorld`, `InMemoryAppleKeyBacking`), and the only
key-file assertion is the Standard one (`replaceAllKeysThroughTheDoorIsFollowedByTheSibling…`, line 2674:
`newFile.apple != nil`).

**The fix shape (for the fix session, NOT built):** the key file's Apple copy follows the same rule as the
vault's — present only when the posture is Standard (enrolled: exactly when `appleHeld != nil`; local-only:
`leaves.posture() == .standard`), on both the ceremony road and the resume road. **Pins:** (a) a Castle
world, iCloud key readable, Replace All Keys → the new key file's `apple == nil` (RED today); (b) the same
through the resume road after an injected crash at `.rekeyLibrary` (RED today); (c) the Standard pin at
line 2674 stays green. **Class sweep owed:** every other key-file writer that can add `apple`
(`ProtectionController.swift` ~749 and ~1536, the reconcile's Apple arm and the custody move) verdicted
FIXED or SAFE-with-mechanism. These are Mac-app suites (`VariorumTests`) ⇒ a stage slot via oct7coordinator.

**The net that already exists (13x, not yet on main):** 13x's `castleKeyFileAppleOpenable` arm detects this
state at the next open and offers the follow — that is how W-3 found it. It is detection, not prevention.

## (3) The missing local twelve-words copy — DESIGNED, not a gap

Design §7 step 5: the follow writes *"L′ under the typed secret and under M′ (the other secret's local
copy lands when that secret is next typed here)"*. Her 00:55 follow was the posture-mismatch follow
(`PostureSwitch.swift` ~764–783, passphrase typed, `recoveryWords: nil`), so only the passphrase copy and
the master-wrapped copy landed, plus `vaultRecoveryWrapDigest`. The words still open the library ONLINE
through the vault (§3.5: the master-wrapped copy makes both local secret copies caches).

**THE SAFE DOOR for her words — the lobby's twelve-words road, online:** Lock Library Now → at the lock
screen choose the twelve words → type them while online. Mechanism (`StoreLaunchGate.swift` 896–941): the
local copy is absent, so the vault road runs; the words must unwrap the VAULT's master
(`format.unwrapMaster(withRecoveryKey:)`) and then the key file's master-wrapped copy of the library key
BEFORE anything is written — a typo or a wrong set writes nothing — and only then is the local copy landed
(`setRecoveryWrap`) with the vault's digest. Nothing is generated and nothing on the server changes.
**Doors to avoid:** Regenerate Twelve Words (mints new words, the old die); anything offering to *set up* or
*generate* words (`generateAndLandRecoveryPhrase`); Replace All Keys (rotates everything and, until the fix,
re-adds the Apple copy on this Pro). Offline, the road refuses honestly (the vault is needed).

## (4) The phone — NOT this shape (by trace; device unread)

The phone never ran Replace All Keys: the Sep 7 act was the Pro's (ledger 51), and the corpus key is still
`a781…` (the Pro's post-follow file), so no rotation has run anywhere since. Every re-key the phone ran
was a FOLLOW, and the follow derives `entersCastle` from the vault
(`fetched.format.masterWrappedByAppleHeld == nil`, line 764 — Castle ⇒ `apple: nil`). So the phone's live
key file carries no Apple copy from this mechanism. It very likely carries **no local twelve-words copy**
either (it followed with the passphrase — the same designed shape as the Pro). The same lobby road lands
the words there. Confirming either fact needs her device (field names only).

## Consequence for her backups (hers to decide — reported, never acted on)

The app's own `Backups/` folder holds **13 snapshot pairs under the `182738de` key** (Sep 7 → Oct 7), each
with its own key file written with it (decision 11: never rewritten). Those key files carry the Apple copy,
so **those 13 snapshots open through her Apple account** for as long as they exist — the exact
"Standard-era backup" situation the Castle ceremony offers to delete. Time Machine copies of that window are
the same. Deleting them is her call; nothing here touches them.

**CONFIRMED on her phone (2026-10-08, read-only `devicectl device copy from`, field names only):** the
phone's one live key file `variorum-keys-2f70a42f…` (written Sep 7 02:16, the follow one minute after the
Pro's Replace All Keys) carries `formatVersion · keyFingerprint · master · passphrase · storeID ·
vaultCorpusKeyID (a781…) · vaultKDF · vaultRecoveryWrapDigest` — **no `apple`, no `recovery`.** Clean of
this bug; its words copy lands by the same lobby road. (A separate dev-scope `Variorum-dev` folder sits
beside it, untouched since Sep 5 — irrelevant here.)

## HER RULINGS (2026-10-08, after the findings — verbatim-faithful)

1. **Sequencing:** *"We'll wait for 13x to merge and free the sync / custody slot … 13x should merge soon,
   and we'll fix it as soon as it does."* No code before 13x's merge.
2. **The review ladder:** *"we'll try running a Fable cold review and if it fails (stops responding because
   it's stuck on that prompt, or worse, switches to opus 4.8), we'll kill it and do an opus 5.5 review.
   we'll do an opus 5.5 cold review either way at the end too - if the fable one also works great, if not
   we know we got an opus 5.5 in at least."*
3. **The backups:** *"i'll handle them soon, after this phase is done."* Hers; never touched here.

## THE FIX PLAN (written 2026-10-08; RE-VERIFY every line number against the merged tree before the spawn)

**Trigger:** 13x (VX-6) merges to `main`. Then, in `~/dev/variorum-vx-99`: `git merge origin/main` (a merge
commit, never a rebase), re-read `PostureSwitch.swift` (13x's VX-80 fix touched the follow and the resume
roads — confirm `writeNewKeyFile`, `replaceAllKeys`, `resume` and `appleHeldCopyForStandard` are where this
record says), take the Sync/-custody slot by editing this effort's in-flight row, then spawn.

**One acceptance unit — "a Castle Replace All Keys never makes an Apple-openable key file."** Evidence:
red-on-old pins verified by behavioral revert + the class-sweep table + the touched Mac suites green +
core headless green. No walk on her real store (the pins carry it); her Pro re-checks naturally at its next
Replace All Keys, and 13x's detector stays as the net.

**Cast:** orchestrator Opus 5.5 (this session); implementer a fresh `opus-implementer` (custody would be
Fable work by standing rule — her switch to Opus covers it); reviewers per her ruling 2 above.

**The implementer's brief (self-contained):**
- Read: CLAUDE.md; `notes/SyncSpec.md` whole; `notes/plans/pre-13x-postures-design.md` §1 (decisions 6,
  28, 30, 35), §3.4, §3.5, §4, §5's Replace All Keys row, §7; this record whole;
  `notes/SessionResiliencyProtocol.md`'s implementer section (commit per piece, push after each, a LIVE
  STATUS section in this file from the first commit, foreground waits only).
- **Pins FIRST, red on today's code** (in `App/Variorum/VariorumTests/PostureSwitchTests.swift`, the
  `makeWorld` harness; posture set to `.castle`, the vault carrying no Apple-held copy, the iCloud key
  READABLE):
  (a) Replace All Keys through the runner → the new key file's `apple == nil` and `appleKeyID == nil`;
  the vault still has no Apple-held copy; custody target biometric.
  (b) the same, crashed at `.rekeyLibrary` (or the nearest existing fault point before the key file is
  written) and finished through `resume` → `apple == nil`.
  (c) the Standard pin (`newFile.apple != nil` in `replaceAllKeysThroughTheDoorIsFollowedByTheSibling…`)
  stays green — the guard on the other side.
  (d) a local-only (no vault) Castle library's Replace All Keys → `apple == nil`, if the harness reaches
  that road; else record why not.
- **The fix:** the key file's Apple copy follows the vault's rule — present only when the posture is
  Standard. Enrolled road: exactly when the vault write carried an Apple-held copy (`appleHeld != nil`);
  local-only road and resume: `leaves.posture() == .standard`. Prefer threading ONE decision from
  `runCeremony` into `writeNewKeyFile` over a second posture read. Entering Castle stays `nil`. Fix the doc
  comment only if it stops matching.
- **Behavioral revert:** commit the fix, then revert the one decision line, run the pins (red, exact
  names recorded), restore, run again (green). Name the revert in this file BEFORE starting it.
- **Class sweep (a table in this file):** every writer that can set a key file's `apple` copy —
  `PostureSwitch.writeNewKeyFile` (ceremony + resume + follow), `ProtectionController` ~749 and ~1512–1582
  (the reconcile's Apple arm / landing), `leaveCastle`, enrollment's key-file write, the 13x adoption/
  hand-off roads — each FIXED-with-pin or SAFE-with-the-mechanism-stated (the posture gate it reads).
- **Runs:** core `swift test` headless (free). Mac suites `PostureSwitchTests` + every suite the diff
  touches + the tutorial spine, by suite-level `-only-testing`, **under a stage slot from oct7coordinator**
  (message it; never run `xcodebuild test` without the held claim). Confirm the "Test run with N tests"
  line and read the skipped lines.
- Commit message for the fix states the traced mechanism and the pin names (CLAUDE.md's small-fix rule).
  No `Co-Authored-By` / `Claude-Session` trailer.

**The ladder (her ruling 2):** round 1 = a fresh `fable-reviewer` running `notes/REVIEW_PROMPT.md`
VERBATIM over the fix diff (`git diff <merge-of-13x>..HEAD`), zero framing. If it stalls or comes back as
another model, the orchestrator kills it and records that, then runs a fresh Opus 5.5 reviewer the same
way. Findings land in this file before any fix session; fixes with traced mechanisms + revert-verified
pins; round 2 re-reviews. **At the end, an Opus 5.5 cold review runs either way** (her ruling — a guaranteed
Opus 5.5 read); a new BLOCKER/MAJOR from it is a fix round like any other. Hard cap three rounds counts the
rounds that produced findings; her end-review is hers on top.

**Close:** the PR `VX-99: …` (merge commit) after 13x's; VX-99 Done rides it; the in-flight row retired;
QUESTIONS untouched unless a PROVISIONAL arises; MOBILE PARITY: the phone shares `PostureSwitch.swift`
(Shared/), so the fix reaches it with the next phone install — a MobileSoul row or "nothing
mobile-visible" (it is invisible in UI); the `/Applications` refresh at the post-merge window with the A1
rail, via oct7coordinator.

## TRIGGER MET (2026-10-08)

13x merged (PR #136, `2d88dd49`; the 13x closeout session's message). `origin/main` merged into this
branch at `b6628b0e` (merge commit). **Re-verified on the merged tree:** `PostureSwitch.swift` UNCHANGED by
13x — `replaceAllKeys` :419, `writeNewKeyFile` :1049 with the bug line :1065, `appleHeldCopyForStandard`
:1163 (posture gate :1166), `resume` :1243; the door-time `appleKeyReadable` :373 is posture-gated too (F3).
**13x DID change `ProtectionController.swift`** (+47/−8 — the `castleKeyFileAppleOpenable` detector arm), so
the class sweep reads it on the merged tree. The slot taken on main (`f797dbe7`). The fix session spawns.

## LIVE STATUS (the implementer flips each line in the same commit as its piece; PENDING = unverified)

- Pins (a)–(d) written, RED on the pre-fix code: DONE — written in `PostureSwitchTests.swift`
  (the `VX-99` MARK after `replaceAllKeysRefusesAnUnreachableAppleKeyAtTheDoorBeforeAnyScreen`):
  (a) `aCastleReplaceAllKeysWritesNoAppleCopyIntoTheNewKeyFileWhileTheICloudKeyIsReadable`;
  (b) `aCastleReplaceAllKeysResumedAfterACrashWritesNoAppleCopyAndAStandardOneStillDoes` (three seams —
  mid re-encryption, after the vault write before custody, `.rekeyLibrary` — plus a STANDARD resume control);
  (c) the standing `replaceAllKeysThroughTheDoorIsFollowedByTheSiblingAndAStaleCopyOpensNothing` (`newFile.apple
  != nil`) untouched; (d) `aLocalOnlyCastleLibrarysReplaceAllKeysWritesNoAppleCopyAndAStandardOneStillDoes`
  (the harness reaches the runner's local-only road; the DOOR refuses a non-enrolled library —
  `replaceKeysNotEnrolled` — so (d) pins the runner's road, reached whenever its own enrolled reading fails at
  the run). **DONE (0dd76c59) — RED ON THE PRE-FIX CODE**, verified under the coordinator's stage slot
  (claimed 02:01:58, `vx-99-impl`), `test-without-building -only-testing:VariorumTests/PostureSwitchTests`
  over the pre-fix build: "Test run with 49 tests in 1 suite failed … with 8 issues". Mine, each at its
  Apple-copy expectation and nowhere else: (a) :2261 `newFile.apple == nil && newFile.appleKeyID == nil` +
  :2263 "an error was expected but none was thrown" (the iCloud key OPENED the new key file); (b) :2305
  (seam 1, mid re-encryption), :2324 (seam 2, after the vault write), :2341 (seam 3, `.rekeyLibrary`) — the
  STANDARD resume control inside (b) passed; (d) :2387 — its Standard control passed. **Two further reds are
  NOT this diff's** — see "PRE-EXISTING REDS" below.
- The fix: DONE (37e26d2e) — `PostureSwitch.swift`: ONE decision per road threaded as a required
  `appleCopy:` into `rekeyCustodyAndSnapshot` → `writeNewKeyFile` (`let apple: AppleKey? = appleCopy ?
  leaves.appleKeys.read() : nil`). Ceremony, enrolled: `appleCopyInKeyFile = appleHeld != nil` (exactly when
  the vault write carries an Apple-held copy); ceremony, local-only: `!entersCastle && leaves.posture() ==
  .standard`; resume: `!entersCastle && leaves.posture() == .standard` (the plan's letter — see "THE RESUME
  RULE" below); the follow (both calls): `!entersCastle` (the vault's word, behavior unchanged). Entering Castle
  stays nil on every road. Doc comments on `writeNewKeyFile` / `rekeyCustodyAndSnapshot` / `runFollow` updated.
  GREEN — see the Mac suites line.
- Behavioral revert (named here BEFORE it runs): DONE — **REVERT V99-A**: in `rekeyCustodyAndSnapshot`, the
  one hand-off line `try await writeNewKeyFile(newKey: newKey, appleCopy: appleCopy, …)` → `appleCopy:
  !entersCastle` — exactly the pre-fix decision for every road (ceremony, resume, follow). Expected: RED on
  (a), (b) seams 1–3 and (d)'s Castle arm; their Standard controls, the standing Standard pin (c) and every
  other test unchanged. **RESULT (over 37e26d2e + the one-line edit, built, `-only-testing:VariorumTests/
  PostureSwitchTests`): "Test run with 49 tests in 1 suite failed … with 8 issues" — RED exactly on (a) :2261 +
  :2263, (b) :2305 / :2324 / :2341, (d) :2387 (the pre-fix run's six expectations, line for line); the two
  PRE-EXISTING reds identical; nothing else.** Restored with `git checkout --`; `git diff` CLEAN; rebuilt.
- Class sweep table: DONE — "THE CLASS SWEEP" below (13 writers: 2 FIXED with pins, 11 SAFE with the gate stated).
- Core headless run: DONE — `swift test` on the fixed tree (37e26d2e's code; the diff touches no `Sources/`):
  **"Test run with 2346 tests in 270 suites passed" + "40 tests in 6 suites passed"** (the 13x closeout's own
  baseline numbers); skips only the standing env-gated set (13o's gated measurement suites, the real-server pass,
  the fixture minters).
- The phone COMPILE: DONE — `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'
  build` into a scratch DerivedData: **BUILD SUCCEEDED** (`Shared/PostureSwitch.swift` compiles there; the
  changed signatures are private to the runner). No simulator run.
- The PRE-EXISTING proof: DONE — main's exact code (`origin/main` c71d7f68: its `PostureSwitch.swift` + its
  `PostureSwitchTests.swift` swapped in, `git diff --stat origin/main -- App Sources` EMPTY, built) under the same
  slot: **"Test run with 46 tests in 1 suite failed … with 2 issues"** — the same two tests at main's own lines
  :2607 / :2839 (this branch's :2780 / :3012 minus the 173 lines the pins add). Restored with `git checkout --`;
  `git diff` CLEAN. (A first swap attempt truncated both files — zsh read `$M:A…` as a path modifier and
  `git show` failed into the redirect; caught at once, both restored from HEAD by `git checkout --`, sizes
  re-checked, nothing built or committed from the truncated state.) Stage RELEASED; the coordinator told.
- Mac suites under a stage slot: DONE (the coordinator's slot, `vx-99-impl`, zero Variorum instances at each
  run's start; over the RESTORED fix, 37e26d2e's code) — **batch 1, the runner's whole reach** (`PostureSwitchTests`
  · `PostureSwitchDrillTests` · `VX80CastleFollowRecoveryTests` · `AppleRelinkDoorTests` · `CopyRegisterPinTests` ·
  `Phase13pControllerTests` · `EncryptionFlowTests`' nine suites · `Phase13pProtectionBrainTests`' five suites):
  **"Test run with 178 tests in 20 suites failed … with 2 issues"** — 174 passed, the 2 skipped are
  `PostureSwitchDrillTests`' standing opt-in gate (`VARIORUM_POSTURE_DRILL=1`), the 2 issues are EXACTLY the two
  PRE-EXISTING reds below; (a), (b), (d) and the Standard pin (c) passed by name. **Batch 2, THE TUTORIAL SPINE**
  (the eleven `TutorialWalkTests` suites + `TutorialBooksLessonTests` + `TutorialBooksRitualTests`): **"Test run
  with 99 tests in 13 suites passed"**, no skips.

**THE RESUME-RULE DELTA (the orchestrator's ruling, 5ce7175b — LIVE STATUS of the second piece):**
- Pin (e) written, RED on 449f5618's code: DONE (d4c39bbf) —
  `aStandardReplaceAllKeysResumedIntoAnotherDevicesCastleFollowsTheVaultNotAStalePosture` (after pin (d)): A's
  STANDARD Replace All Keys killed at `.beforeVaultWrite`, B (`sharing: a`, "sibling device") enters Castle whole,
  A resumes by the passphrase with its scripted posture STILL `.standard` → expects the follow flag + B's name,
  `outcome.entersCastle`, the new key file `apple == nil && appleKeyID == nil`, custody `.biometric` and the posture
  Castle, the old Standard-era key file GONE from the live folder, the offer listing A's pre-switch pair, the
  marker cleared. **RED on the pre-fix build** (d4c39bbf's tree = 449f5618's code + the pin; slot 2, claimed
  02:47:22, zero instances): "Test run with 50 tests in 1 suite failed … with 7 issues" — pin (e) at EXACTLY its
  five ruled expectations: :2445 `outcome.entersCastle`, :2449 `aFile.apple == nil && aFile.appleKeyID == nil`,
  :2452 custody `.biometric` / posture Castle, :2453 the old key file still in the live folder, :2455 the offer;
  the other two issues are VX-106's pair (now :2836 / :3068), identical; pins (a)–(d) GREEN on this tree.
- The fix (the ruled scope — the resume's `.vaultWrite`/`.reencrypt` arm only): DONE (this commit) —
  `let vaultSaysCastle = fetched.format.masterWrappedByAppleHeld == nil`;
  `let roadEntersCastle = byAnotherDevice ? vaultSaysCastle : entersCastle` (feeding `rekeyCustodyAndSnapshot`'s
  `entersCastle` and `listPreSwitchPairs`); `appleCopy: !vaultSaysCastle` for the WHOLE arm. The
  `rekeyCustodyAndSnapshot` doc comment now names the resume's rule. Green PENDING.
  **Residual recorded (not built — outside the ruled scope):** the arm advances the marker as
  `marker.advanced(to: .reencrypt)`, which keeps the ORIGINAL `entersCastle` and no follow flag; a SECOND crash
  inside the walk of an another-device resume resumes at `.reencrypt`, where `byAnotherDevice` cannot fire (it
  requires `.vaultWrite`) — that resume still lands NO Apple copy (the whole-arm rule reads the vault), but moves
  custody by the marker's posture and does not retire the old key files. Pre-existing shape, a double-crash corner;
  for the reviewer / the orchestrator.
- Behavioral revert (named here BEFORE it runs): **REVERT V99-B** — the arm's two decisions back to 449f5618's:
  `let roadEntersCastle = entersCastle` (the marker's) and `appleCopy: !entersCastle && leaves.posture() ==
  .standard`. Expected: RED on pin (e) alone; (a)–(d), the own-write Standard resume control in (b), and every
  other test as before. **DONE — over 2a667130 + the two-line edit, built, `-only-testing:VariorumTests/
  PostureSwitchTests`: "Test run with 50 tests in 1 suite failed … with 7 issues" — RED on pin (e) ALONE, at the
  same five expectations as the pre-fix run (:2445 · :2449 · :2452 · :2453 · :2455); VX-106's pair identical;
  (a)–(d) green.** Restored with `git checkout --`; `git diff` CLEAN; rebuilt.
- Green: DONE (slot 2, zero instances at each start, over the RESTORED 2a667130 code) — **batch 1 (the same
  twenty suites): "Test run with 179 tests in 20 suites failed … with 2 issues"** — 175 passed, 2 skipped (the
  drill suite's standing gate), the 2 issues EXACTLY VX-106's pair; passed by name: (a), (b), (d), (e), the Standard
  pin (c), `aCeremonyKilledBeforeItsVaultWriteResumesIntoAnotherDevicesSwitchAsTheFollowAndSaysSo`,
  `aCeremonyWhoseOwnWriteLandedResumesAsItselfAfterAFollowerFinishedAndSpeaksTheOrdinaryDone`. **The spine: "Test run
  with 99 tests in 13 suites passed"**, no skips. Stage RELEASED; the coordinator told. **Phone compile** re-run on
  2a667130's code: BUILD SUCCEEDED. Core not re-run (no `Sources/` change since 37e26d2e's green core run).

## PRE-EXISTING REDS in `PostureSwitchTests` (found by this run; NOT this diff's; NOT fixed here — handed to the orchestrator)

The pre-fix red run (above) also failed two tests that my pins do not touch:
`regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling` (:2780 `try #require(siblingController.changeNotice)`)
and `theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord` (:3012 `try #require(controller.changeNotice)`).
**Traced mechanism (13x's, not VX-99's):** 13x F1 added the `castleKeyFileAppleOpenable` arm to
`ProtectionController.reconcileFollow` (`ProtectionController.swift:680`): `!reading.hasAppleHeldCopy, keyFile?.apple != nil,
!switchInProgress ⇒ owe(.castleKeyFileAppleOpenable); return` — it returns BEFORE `changeElsewhere` runs (:696). Both tests
build the harness's default "Standard" world (`makeWorld()` — the key file carries an `apple` copy) over a vault born by
`VaultEnrollment.setUp(passphrase:)` with NO Apple-held copy (the harness's own note: "the 2b world's account is
Castle-shaped", :3873 pre-pins), with the controller's custody shape not yet adopted (`.unknown`), so before 13x the
mismatch arms fell through to the change notice and now the new arm owes the follow first. The 13x closeout's widened Mac
run (209 tests in 20 suites, `phase-13x-library-portability.md` §THE PHASE CLOSEOUT item 3) did not include
`PostureSwitchTests`, which is how it reached `main`. Whether the fix is the tests' world (an Apple-held copy in the vault,
or a Castle key file) or the arm's order is a 13x-surface call — a second unit; this batch does not "also do" it. The
green criterion for this batch is therefore: every `PostureSwitchTests` test green EXCEPT exactly these two, which stay
red identically on both sides of the fix (recorded with each run).

## THE RESUME RULE (the plan's letter built; one corner recorded for the orchestrator — PROPOSAL, not built)

Built per the plan: the resume's key-file decision is `!marker.entersCastle && leaves.posture() == .standard`. The
resume's ONLY key-file-writing arm is `.vaultWrite`/`.reencrypt` (the `.rekeyLibrary` arm reads the file the ceremony
already wrote), and that arm always holds the FETCHED vault. **The corner the posture read leaves open:** a STANDARD
Replace All Keys killed before its own vault write while ANOTHER device ENTERED CASTLE resumes as the follow
(`byAnotherDevice`) with `marker.entersCastle == false`. In production the posture there is the controller's
derivation — Castle once the ready's vault read landed; but under an INDETERMINATE reading (the vault unread at ready,
online by the time of Finish) it is the custody SHAPE (silent ⇒ Standard), so the resumed follow would still wrap L′
under the iCloud key on a now-Castle account. The same corner also moves custody by the stale posture
(`moveCustodyForSwitch(entersCastle: false)`), skips `retireOldKeyFiles` (gated `follow && entersCastle`) and lists no
offer — the old Standard-era key file stays in the live folder (it opens only the OLD library key, so nothing written
after the re-key; 13x's detector owes the follow at the next ready). **PROPOSAL (for the orchestrator; not built):** in
the resume's enrolled arm derive the road's posture from the fetched vault exactly as `runFollow` does —
`let entersCastle = byAnotherDevice ? (fetched.format.masterWrappedByAppleHeld == nil) : marker.entersCastle` and
`appleCopy: fetched.format.masterWrappedByAppleHeld != nil` — decision 8's "the vault's word, when in hand" (arm 1 of
`Posture.derive`), which also honors decision 35 (no posture-driven write on an indeterminate reading). It is a
behavior change on the resume's follow road beyond this unit's letter, so it waits for the orchestrator's word.

**ORCHESTRATOR RULING (2026-10-08, under the architect mandate — a technical call inside ruled canon, not new
product behavior): BUILD THE PROPOSAL, IN THIS UNIT.** Grounds: the same bug class (an Apple copy written on a Castle
account from a stale posture read), reached on a road this unit already owns; the vault is fetched in that very arm
(:1288), so its word is in hand and decision 8 (posture is the ACCOUNT's once a vault exists) + decision 35 (no
posture-driven write on an indeterminate reading) say to use it; it is exactly `runFollow`'s existing rule, so it adds
no new behavior, it closes a divergence from the follow. **Scope as ruled:** in the `.vaultWrite`/`.reencrypt` arm
only — `appleCopy: fetched.format.masterWrappedByAppleHeld != nil` for the WHOLE arm (own-write: the vault carries an
Apple-held copy exactly when this device's own Standard Replace All Keys wrote one — equal to the built rule there),
and `entersCastle` from the vault (`masterWrappedByAppleHeld == nil`) when `byAnotherDevice` (so custody moves and
`retireOldKeyFiles` follow the account, as the follow's do). **Pin owed, red on 449f5618's tree:** a STANDARD Replace
All Keys killed before its own vault write, another device enters Castle, the resumed road runs with the posture read
still STANDARD (the indeterminate-reading shape) → the new key file has `apple == nil`, custody target `.biometric`
(or `.passphrase` per the gate dials), the old Standard-era key file retired from the live folder. Plus the existing
pins (a)–(d) stay green and the own-write Standard resume control still lands its Apple copy. A second behavioral
revert (V99-B, named here before it runs) proves the new pin red-on-old. Then the cold review covers the whole diff.

## THE CLASS SWEEP (every road that can put an `apple` copy into a key file — on the merged tree, 37e26d2e)

Census: `grep setAppleWrappedCopy` + every `StoreKeyEnvelope(…apple:…)` construction + every key-file save/copy in
`App/` and `Sources/` (tests excluded). The class: a key file gains L under the iCloud key A while the account (or,
local-only, the library) is Castle.

| # | writer (file:line) | verdict | the gate / the mechanism |
|---|---|---|---|
| 1 | `PostureSwitchRunner.writeNewKeyFile` via `runCeremony` — Replace All Keys / Use Castle (`PostureSwitch.swift` :1092, decided at :560 / :638) | **FIXED** — pins (a), (d), the round-1 MAJOR pin; reverts V99-A, V99-C | enrolled: `appleHeld != nil` — the vault write's own Apple-held copy, which `appleHeldCopyForStandard` gates on **THE VAULT'S WORD** (`fetched.format.masterWrappedByAppleHeld != nil` — round 1's MAJOR fix, replacing the `posture == .standard` guard that a stale/indeterminate read could flip; the readable / vault-id refusals kept) AND the caller's load-bearing `entersCastle ? nil` suspenders (the enter-Castle road's fetched vault is still the OLD Standard one); the door twin `appleKeyReadable` reads the same word; local-only: `!entersCastle && posture == .standard` (no vault — the library's own posture, decision 8); entering Castle: nil |
| 2 | the same writer via `resume`'s `.vaultWrite`/`.reencrypt` arm (the decisions :1338–1339, the call :1376) | **FIXED** — pin (b) seams 1–2 (seam 3's `.rekeyLibrary` arm writes no key file — it reads the ceremony's) + pin (e) (the another-device road); reverts V99-A, V99-B | the orchestrator's ruling (5ce7175b): `appleCopy: !vaultSaysCastle` — the vault just fetched — for the whole arm; the road's `entersCastle` from the vault when `byAnotherDevice`, the marker's otherwise. (First built as `!marker.entersCastle && posture == .standard` at 37e26d2e; superseded at 2a667130.) Residual: the double-crash corner under THE RESUME-RULE DELTA |
| 3 | the same writer via `runFollow` (:799, :818 — incl. the ceremony's CAS-refused → follow road) | SAFE (behavior unchanged) | `appleCopy: !entersCastle`, `entersCastle = fetched.format.masterWrappedByAppleHeld == nil` — the vault just fetched (decision 8). Pinned: `aCastleFollowerOfReplaceAllKeysFinishesTheWalkAndListsNoOffer` (`apple == nil`), `aCeremonyKilledBeforeItsVaultWriteResumesIntoAnotherDevicesSwitch…` (`apple == nil`), the Standard sibling in (c) (`apple != nil`) |
| 4 | `PostureSwitchRunner.followIntoStandard` (:912, the write :926) | SAFE | reached only through `followIntoStandardAct` (`VariorumApp.swift:271`, `VariorumMobileApp.swift:129`) from `reconcileFollow`'s arm `reading.hasAppleHeldCopy … !switchInProgress` (`ProtectionController.swift:707`) — the VAULT says Standard (the account left Castle elsewhere, §7). Pinned: `theFollowIntoStandardAddsTheAppleCopy…` |
| 5 | `PostureSwitchRunner.leaveCastle` (:1221, the write :1248) | SAFE | IS the Castle → Standard switch (decision 7): `guard leaves.posture() == .castle`, user-initiated through `PostureSwitchModel(.leave)` with the consent sentence + re-auth; adding the copies is the act |
| 6 | `ProtectionController.reconcileAppleKey` → `landAppleCopyOffMain` (`ProtectionController.swift:1612`) | SAFE | `guard let determined = postureReading.determined` (decision 35 — indeterminate writes nothing) + `guard determined == .standard`; skipped while `switchInProgress || markerPending` (:1437) — so it never lands a copy mid-road of row 1/2 |
| 7 | the route's Standard-waiting landing, `StoreLaunchGate.effectiveGate` (`StoreLaunchGate.swift:372`) | SAFE | `!enrolled` (no per-store sync custody) AND raw-key custody `.silent` (corner 45: silent ⇒ Standard-waiting; a Castle library's raw key is gated or nowhere — `rawKeyCustody` reads `.gatedOrNone`) AND `apple == nil && passphrase != nil` AND the key belongs |
| 8 | enrollment / setup / Connect landing, `ProtectionController.landVaultMaterial` (:1669) via `EncryptionSession.adoptEnrolledMaterial` → `onVaultMaterialLanded` | SAFE | writes the master copy, the descriptor + corpus id, the typed P/W copies — never `apple`; a Standard enroll's file copy arrives through row 6 (posture-gated) |
| 9 | §11 migration's key-file leg (`ProtectionMigration.swift:~258`) | SAFE | master copy + reconciliation only; the file names no `apple` at all |
| 10 | the deliberate re-link door (`AppleRelinkModel.swift:119` → `healAppleHeldCopy`) | SAFE | refuses unless `controller.posture == .standard`; writes the VAULT's copy, then the file's copy lands only through `controller.reconcile()` → row 6 |
| 11 | sync setup / the heal's vault writes (`EncryptionSession.swift:444`, `VaultEnrollment.swift:202`, `CorpusRotation.swift:428`) | SAFE (out of the key-file class) | vault-side Apple-held copies — the account's posture by definition; row 1's enrolled decision reads exactly this |
| 12 | snapshot key files, `StoreBackup.writeSnapshotKeyFile` (`StoreBackup.swift:589`) | SAFE by inheritance | a byte-copy of the LIVE key file written with each snapshot (decision 11, never rewritten) — carries `apple` exactly when the live file does, which rows 1–11 now gate. Her 13 pre-fix Castle-era pairs under `182738de` carry it — hers to handle (ruling 3) |
| 13 | the 13x roads — adoption (`LibraryAdoption.swift:214/251/271`), hand-off, open-a-copy, the restore hold (`LibraryHandOff` · `LibraryOpenModel` · `RestoreHoldModel` · `BackupRestoreCandidates`) | SAFE (adds none) | none calls `setAppleWrappedCopy` or builds an envelope with `apple:`; adoption byte-copies a pair's OWN key file and the open road reads `apple` only to open (`StoreLobby.openWithAppleKey`) or to list roads. An adopted Standard-era pair under a Castle account is 13x's `castleKeyFileAppleOpenable` detection (the follow re-keys + retires) — detection, as 13x designed it |

MOBILE PARITY: `PostureSwitch.swift` is `Shared/` — the fix reaches the phone with its next install; nothing
mobile-VISIBLE (a key file's wraps have no face).

## ROUND 1 — IMPLEMENTER RESPONSES (the Opus implementer, 2026-10-08; to `vx-99-ladder-round1.md` at 818727be — nothing fixed, the stage untouched)

**[MAJOR] `appleHeldCopyForStandard`'s posture guard (`PostureSwitch.swift:1193`) — AGREE.** My own trace:
- `CorpusRotation.prepare` (`CorpusRotation.swift:~402–427`) builds a FRESH `KeyVaultFormat.create(…)` for M′ and
  adds an Apple-held copy only `if let appleHeldCopy`; nothing carries the old M's Apple-held copy forward (it could
  not — it wraps M, not M′). So `appleHeldCopy: nil` on a Standard account rewrites the vault Castle-shaped — the
  ACCOUNT's posture flips (Posture.derive arm 1 reads exactly that column).
- Direction (i) reaches it through every door gate: `PostureSwitchModel.start` (:~141–207) checks `followPending`
  (computed only by a reconcile), the restore hold, `rotationInProgress`, `enrolled`, the recorded corpus id
  (unchanged — leaving Castle rotates nothing), and `appleKeyReadable == false` — which is nil under a `.castle`
  read (`appleKeyReadable(keptUnder:)`, :373, the same posture guard). And the controller re-reads the vault only at
  READY (`AppBootstrap.readyHousekeepingBody` :589), after a switch, after the follow model acts and after a relink —
  so a Mac left open while the phone runs Use Standard keeps its `.castle` read for the whole session. Replace All
  Keys there drops the Apple-held copy with no consent sentence; the Done says "keys replaced". Confirmed.
- Direction (ii) — a `.standard` read on a Castle account (an indeterminate ready's silent shape) — passes the
  guard; the vault's `appleKeyID` is nil under Castle so the id check (:1198) cannot fire; A is read and M′ gains an
  Apple-held copy: the account silently leaves Castle. Confirmed by reading; narrower, as the reviewer says.
- Pre-existing (the guard predates VX-99); VX-99 made the KEY FILE agree with the vault (`appleCopyInKeyFile =
  appleHeld != nil`), so after the fix both halves are wrong together rather than split — the fix belongs at the
  decision, as proposed: `fetched.format.masterWrappedByAppleHeld != nil` in place of the posture guard, keeping the
  readable / vault-id refusals.
- **Two refinements for whoever builds it:** (1) **the door twin** — `appleKeyReadable(keptUnder:)` (:372–377) holds
  the SAME fetched vault and the SAME `leaves.posture() == .standard` guard; left alone, direction (i)'s door would
  pass with `nil` and the runner's belt would refuse `appleKeyUnreachable` AFTER the words screens on a device that
  cannot read A — F3 (MINOR-N4)'s exact regression. The door should read the vault's word too, one rule with the belt.
  (2) **the harness ripple** — the default `makeWorld()` is a MISMATCH world (Standard posture + key file over a vault
  `setUp(passphrase:)` minted with NO Apple-held copy — the harness's own note "the 2b world's account is
  Castle-shaped"); today a Standard-world Replace All Keys ADDS the Apple-held copy to that Castle-shaped vault (which
  is direction (ii) inside the harness). Under the fix those runs follow the Castle-shaped vault instead, so tests
  that rely on the old behavior will move. By READING (not run — no stage): pin (c)
  `replaceAllKeysThroughTheDoorIsFollowedByTheSiblingAndAStaleCopyOpensNothing` (the sibling's Standard follow),
  pin (b)'s STANDARD resume control, `theReplaceKeysCeremonyWalksCopyFoursOrderRefusesAStaleMasterAndLandsTheNewPassphraseUnderTheNewProof`
  (decision 30's PRESENCE asserted after a default-world RAK), and likely
  `theSiblingThatOpenedByThePassphraseFollowsAReplaceAllKeysWithZeroPrompts`,
  `theUnfollowedDeviceOpensReadsAndWaitsWithEveryDoorSpeakingTheSentence`,
  `aNearEmptyCopysReplaceAllKeysLosesNothingTheFullerServerHolds`. The honest repair is a harness parameter that gives
  a Standard world a vault Apple-held copy under its own `apple` (the account really Standard), with the deliberate
  mismatch tests (`thePosturePinsHoldInTheTwoDeviceWorld` (a), the Castle-account sibling roads) opting out
  explicitly. **A hypothesis, untested:** the same harness change may clear VX-106's pair — the 13x arm
  (`ProtectionController.swift:680`) fires only on `!reading.hasAppleHeldCopy`, and with the vault Standard neither
  that arm nor the follow-into-Standard arm (:707 — the key file carries `apple`, shape `.unknown`) fires, so
  `changeElsewhere` would run. Worth one run before VX-106 is worked separately.

**[MINOR] the `.reencrypt` advance at :1362 (my recorded double-crash residual) — AGREE.** My trace matches:
`RotationMarker.advanced(to:)` (`CorpusRotation.swift:236–240`) copies `self` and sets the step — the original
`entersCastle` (false for Replace All Keys) and `follow` nil; the next resume enters the arm at `.reencrypt`, where
`byAnotherDevice` cannot fire (:1316 requires `.vaultWrite`), so `roadEntersCastle = false`: custody by the stale
posture, no `retireOldKeyFiles`, no offer; the Apple copy stays correct (`!vaultSaysCastle` reads the fresh fetch).
The proposed fix (advance with `entersCastle: roadEntersCastle` and `follow: (marker.isFollow || byAnotherDevice) ?
true : nil`) closes those three. **Two more facts keyed on `byAnotherDevice` are lost on the same double crash and the
proposed marker does not carry them:** (1) the Done — `outcome.followedAnotherDevicesSwitch` / `otherDeviceName`
(:1386–1389) — so the second resume speaks the ORDINARY Done on a road that was another device's switch (user-visible,
copy §2b's conflict sentence lost); (2) the words rule — `recoveryWords: byAnotherDevice ? nil : typedWords` — so typed
words would land on the new key file although they are not the account's; LATENT in production (both resume doors
pass `recoveryWords: nil` — `PostureSwitchModel.swift:549`), live only for a caller that passes words. Whether the
marker should carry an explicit another-device bit (or the arm should key those two on the carried follow flag — an
ordinary follow's own resume also writes `follow: true`, so the flag alone does not mean "another device's switch")
is the builder's call; I flag it so the pin can cover the Done too.

**[NIT] the class sweep's row 1 — AGREE.** The row states the posture gate as the safety mechanism without its limit.
If the MAJOR is fixed in this unit the row becomes "the vault's word (`masterWrappedByAppleHeld != nil`) + the
readable / vault-id refusals"; if deferred, the row must carry the residual the way row 2 carries its corner.

## ROUND 1 — ORCHESTRATOR DISPOSITION (2026-10-08, overnight mandate — her word: "use your own judgement on what's in scope")

All three findings AGREED by the implementer with self-traced mechanisms (c40cd03b); the orchestrator verified the
MAJOR's premise in code (the ceremony fetches the vault at :524; the Apple-held decision at :1193 reads
`leaves.posture()`). **RULED IN-UNIT, all three** — the same stale-posture class this ticket exists to close, one call
above the key-file fix; leaving the MAJOR out would keep a road that silently flips the ACCOUNT's posture.
Scope for the fix pass, including the implementer's refinements: (1) the vault's word (`masterWrappedByAppleHeld != nil`)
replaces the posture guard in `appleHeldCopyForStandard` AND its door twin `appleKeyReadable(keptUnder:)`, keeping the
readable/vault-id refusals; (2) the harness's Standard worlds get a vault Apple-held copy (a parameter; the deliberate
mismatch tests opt out) — every moved test named in the record with its reason, none weakened; (3) the double-crash
marker carries the road's facts AND an explicit another-device bit, so the second resume keeps the custody move, the
retirement, the offer, the Done's other-device sentence and the words rule; (4) the NIT's row rewritten to the final rule.
Red-on-old pins per finding, a named revert each. **VX-106:** if the harness change turns VX-106's two tests green, that
is RECORDED, not claimed as VX-106's fix — the arm-order question stays variorum-da's (a harness fix can hide a product
question). Per the cross-model flow the REVIEWER makes the final call and implements; then the suites green; then one
implementer sanity pass.

## ROUND 1 — FIX PASS (the reviewer implements, cross-model flow — LIVE STATUS; PENDING = unverified)

**Final calls (the reviewer, under the coordinator's authorization 2026-10-08):** all three round-1 findings
CONFIRMED and built in-unit per the orchestrator's disposition. Scope exactly as disposed: the vault's word in
`appleHeldCopyForStandard` AND its door twin `appleKeyReadable`; the harness's Standard worlds made
account-consistent via one parameter with the deliberate-mismatch tests opting out; the double-crash `.reencrypt`
marker carrying the road's facts; the NIT's sweep row rewritten.

- **The MAJOR fix — DONE, compiles (TEST BUILD SUCCEEDED).** `PostureSwitch.swift`:
  `appleHeldCopyForStandard(keptUnder:)` and `appleKeyReadable(keptUnder:)` both gate on
  `fetched.format.masterWrappedByAppleHeld != nil` (the vault's word) in place of `leaves.posture() == .standard`,
  keeping the readable / vault-id refusals. The caller's `entersCastle ? nil : …` guard STAYS load-bearing (the
  enter-Castle road's fetched vault is still the OLD Standard one, so the belt alone would read it Standard and add a
  copy — the `entersCastle` guard is the suspenders). The local-only road (`!entersCastle && posture == .standard`,
  :638) is UNCHANGED — a genuinely local-only library has no vault, so its posture IS its own (decision 8's second
  sentence); not in the MAJOR's scope.
- **The MINOR fix — DONE, compiles.** `PostureSwitch.swift` resume `.vaultWrite`/`.reencrypt` arm: the `.reencrypt`
  advance is now `RotationMarker(step: .reencrypt, entersCastle: roadEntersCastle, …, follow: (marker.isFollow ||
  byAnotherDevice) ? true : nil)` in place of `marker.advanced(to: .reencrypt)`. NO Sources/ touch: the fix stays
  entirely in `App/Variorum/Shared/PostureSwitch.swift` using the EXISTING `RotationMarker` fields — I deliberately
  did NOT add a marker field (which would touch `Sources/VariorumCore/Sync/CorpusRotation.swift`, outside this
  custody round's ruled surface). The load-bearing facts (roadEntersCastle → custody to the gate, retirement, the
  offer, outcome.entersCastle) are all carried. **Documented residual (not built — needs a field in Sync/):** the
  Done's other-device sentence (`followedAnotherDevicesSwitch`/`otherDeviceName`) and the words rule
  (`recoveryWords: byAnotherDevice ? nil : …`) still key on `byAnotherDevice`, which is spent at `.reencrypt`, so a
  double-crashed another-device resume speaks the ORDINARY Done and (if a caller passed words) would land them —
  both are cosmetic-only / unreachable in production (both resume doors pass `recoveryWords: nil`,
  `PostureSwitchModel.swift:549`). Carrying them needs an `RotationMarker.byAnotherDevice` field (a Sync/ change) —
  flagged for the orchestrator.
- **The harness change — DONE, compiles.** `PostureSwitchTests.makeWorld` gains `vaultSaysCastle: Bool? = nil`
  (nil ⇒ derive from `standard`: a Standard world's ACCOUNT is now genuinely Standard — the vault carries an
  Apple-held copy under this device's A, landed right after `setUp`). Five deliberate-mismatch tests opt out with
  `vaultSaysCastle: true` (named below). No assertion weakened — the opt-outs keep their Castle-shaped vault and
  their existing expectations verbatim.
  - MOVED / re-fixtured (reason: the fixture is now account-consistent; the production code's behavior on a genuinely
    Standard account is UNCHANGED): the default Standard worlds' vault now carries A, so a Standard RAK keeps the
    account Standard and a sibling follows into Standard (the behavior these tests already assert). No expectation
    changed; the fixture was corrected. The suite run names every test whose pass/fail flips.
  - OPT-OUTS (kept Castle-shaped, `vaultSaysCastle: true`): `theMismatchFollowReKeys…`,
    `aStandardBornLibraryWithNoCustodyJoinsCastleThroughTheFollow`,
    `aFollowKilledAfterTheReKeyResumesAndStillRetiresTheOldKeyFiles`, `aWrappedLegacyKeyFileStaysAtTheFollow`,
    `thePosturePinsHoldInTheTwoDeviceWorld` (part a). Each is a documented posture-MISMATCH (a Standard-shaped
    library FOLLOWING into a Castle account) and asserts `masterWrappedByAppleHeld == nil`.
- **The two new pins — DONE, compile.** `PostureSwitchTests.swift`, after pin (e):
  (MAJOR) `aStandardAccountsReplaceAllKeysUnderAStaleCastlePostureKeepsTheAppleCopyByTheVaultsWord`;
  (MINOR) `aDoubleCrashedAnotherDeviceResumeKeepsTheRoadsCastleFactsNotTheStaleMarker`.
- **Build:** `xcodebuild build-for-testing -scheme Variorum -destination 'platform=macOS'` (scratch DerivedData):
  **TEST BUILD SUCCEEDED** — the pins, both fixes and the harness change compile. Also the phone compile re-run is
  owed before close (shared file).
- **Reverts (named BEFORE they run):** **V99-C** (the MAJOR) — in `appleHeldCopyForStandard` AND `appleKeyReadable`,
  `fetched.format.masterWrappedByAppleHeld != nil` → `leaves.posture() == .standard` (the pre-fix guard). Expected:
  RED on the MAJOR pin (the door `appleKeyReadable` + the vault/key-file Apple copy dropped under the stale Castle
  read); every other test green. **V99-D** (the MINOR) — the `.reencrypt` advance back to
  `marker.advanced(to: .reencrypt)`. Expected: RED on the MINOR pin alone (custody `.auto`, outcome not entersCastle,
  the old key file not retired); every other test green, the MAJOR pin green.
- **Runs owed (PENDING — under the stage slot):** PostureSwitchTests (red via V99-C, red via V99-D, full green), the
  batch-1 suite set (the runner's whole reach + the Phase13p suites), the tutorial spine; core headless `swift test`
  (the diff touches no `Sources/`, so the 13x baseline stands — a confirmation run only if time); the phone compile.
  **VX-106's two pre-existing reds:** if the account-consistent fixture turns them green, RECORDED here, never
  claimed as VX-106's fix (the arm-order question stays variorum-da's).
- **The NIT — DONE.** The class-sweep row 1 rewritten below.

## ROUND 1 — FIX PASS RESULTS (stage runs, 2026-10-08 — slot 3, `vx-99-review`, zero Variorum instances throughout)

All runs `test-without-building` over one scratch DerivedData, each suite in its OWN `-only-testing` invocation
(combining many `-only-testing` flags via a zsh variable silently selected 0 tests — zsh does not word-split
unquoted `$var`; single-suite invocations are reliable).

- **FULL GREEN (the committed fix, 155188c5 + the one added opt-out):**
  - `PostureSwitchTests`: **52 tests passed** — including the two new pins
    (`aStandardAccountsReplaceAllKeysUnderAStaleCastlePostureKeepsTheAppleCopyByTheVaultsWord`,
    `aDoubleCrashedAnotherDeviceResumeKeepsTheRoadsCastleFactsNotTheStaleMarker`) and the two formerly-red VX-106
    tests (now green — see VX-106 below).
  - **Batch-1, the runner's whole reach (20 suites, 181 tests, all green):** PostureSwitchTests 52 ·
    PostureSwitchDrillTests 2 · VX80CastleFollowRecoveryTests 4 · AppleRelinkDoorTests 8 · CopyRegisterPinTests 2 ·
    Phase13pControllerTests 50 · EncryptionFlowTests's nine suites (EncryptionFlowTests 5 · CopyFlowRoundTests 7 ·
    CrossoverRoundTests 11 · AccountLifecycleDoorTests 2 · AccountDoorWiringTests 4 · TerminologyPinTests 1 ·
    RetiredNamesPinTests 1 · SyncLockedFaceTests 2 · FreshAccountSetupGeneralityTests 1) · Phase13pProtectionBrainTests's
    five suites (ProtectionDialsTests 9 · ProtectionCopyTests 10 · ProtectionCadenceTests 4 · StoreKeyGuardBackingTests 3 ·
    ProtectionDialsPerStoreTests 3).
  - **The tutorial spine (13 suites, 99 tests, all green):** the eleven TutorialWalkTests suites (BookShape 10 · Door 10 ·
    WritingActs 7 · TakesActs 5 · StructureActs 10 · LookingActs 6 · LibraryActs 9 · DeletionActs 13 · WherePlacesActs 7 ·
    PrivacyChapter 2 · FannedMatrix 2) + TutorialBooksLessonTests 13 + TutorialBooksRitualTests 5.
  - Phone compile re-run on the fix: **BUILD SUCCEEDED** (`VariorumMobile`, generic iOS Simulator). Core not re-run —
    the diff touches no `Sources/`, so the 13x baseline stands (the Mac build compiles the core package anyway).
- **V99-C (the MAJOR revert — both guards back to `leaves.posture() == .standard`, named before it ran):** over the
  rebuilt tree, `PostureSwitchTests` **failed with 3 issues, ALL in the one MAJOR pin** — :2522
  `checkDoor().appleKeyReadable == true` (the door returned nil under the stale Castle read), :2529
  `after.format.masterWrappedByAppleHeld != nil …` (the vault dropped the copy — the account silently re-entered
  Castle), :2510 `Caught error: .appleHeldCopyAbsent` (the unwrap of the dropped copy). Every other test green
  (the MINOR pin, VX-106's pair, all pre-existing). Restored; the tree is clean vs HEAD for `PostureSwitch.swift`.
- **V99-D (the MINOR revert — the `.reencrypt` advance back to `marker.advanced(to: .reencrypt)`, named before it ran):**
  `PostureSwitchTests` **failed with 3 issues, ALL in the one MINOR pin** — :2592 `outcome.entersCastle` ("keys replaced"
  on a Castle account), :2595 custody `.biometric` / posture `.castle` (went `.auto`), :2596 the old Standard-era key
  file retired (it stayed). Every other test green (the MAJOR pin, VX-106's pair). Restored; clean vs HEAD.

**VX-106 (recorded, NOT claimed):** the two pre-existing `PostureSwitchTests` reds
(`regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling`,
`theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord`) PASS under the account-consistent harness.
Mechanism: with the Standard world's vault now carrying an Apple-held copy, `reconcileFollow`'s 13x arm
(`ProtectionController.swift:680`, `!reading.hasAppleHeldCopy`) no longer fires spuriously, so `changeElsewhere` runs
and the change notice lands — the behavior these tests already assert. This is a FIXTURE correction, not a product fix;
the ARM-ORDER question (whether :680 should precede `changeElsewhere` for a genuine Castle-key-file-apple case) stays
variorum-da's — a harness fix can hide a product question, so it is not claimed here.

**ONE added opt-out, surfaced during the green (recorded):** `aNearEmptyCopysReplaceAllKeysLosesNothingTheFullerServerHolds`
takes `vaultSaysCastle: true`. On a genuinely-Standard account a near-empty SIBLING (its own, different iCloud key)
running Replace All Keys correctly refuses `appleKeyUnreachable` (the account's A is not this device's — exactly what
`replaceAllKeysUnderStandardRefusesWhenTheAppleKeyIsUnreadableOrAnotherAccountsAndNeverMints` pins); that refusal is
orthogonal to this pin's pull-to-head purpose, so its account is Castle. No assertion changed.

## THE DOUBLE-CRASH RESIDUAL — mechanism + pin shape (NOT built; for the orchestrator's ruling after green)

The MINOR fix carries the road's SECURITY-load-bearing facts in the `.reencrypt` marker (roadEntersCastle → the
custody move, `retireOldKeyFiles`, the offer; outcome.entersCastle) using the EXISTING `RotationMarker` fields, so
the fix stays entirely in `App/Variorum/Shared/PostureSwitch.swift` with NO `Sources/VariorumCore/Sync/` touch. Two
facts still key on the in-memory `byAnotherDevice`, which is SPENT once the resume lands at `.reencrypt` (the corpus
key id now matches, so the discriminator returns false):
1. **The Done's other-device sentence** — `outcome.followedAnotherDevicesSwitch` / `otherDeviceName` (set only
   `if byAnotherDevice`, PostureSwitch.swift ~:1407). A double-crashed another-device resume speaks the ORDINARY
   "keys replaced"/done copy instead of "you followed [device]'s switch". Cosmetic (the keys and postures are
   correct); user-visible only on the rare double-crash.
2. **The words rule** — `recoveryWords: byAnotherDevice ? nil : typedWords` (PostureSwitch.swift ~:1400). If a caller
   passed the twelve words to the second resume, they would land on the new key file although they are not the
   account's words. LATENT only — both production resume doors pass `recoveryWords: nil`
   (`PostureSwitchModel.swift:549`), so it is unreachable in the app; a test that passed words could reach it.
**Why not carried:** carrying them needs the marker to REMEMBER "another device" across the crash — an additive,
local-only `RotationMarker.byAnotherDevice: Bool?` field (defaulted nil; `sync_state` only, never synced, no mirror
column, no merge/wire impact) — which lives in `Sources/VariorumCore/Sync/CorpusRotation.swift`. I did NOT build it:
this is a custody round, not a sync round, and the standing rule forbids touching `Sources/VariorumCore/Sync/` absent
an explicit go; a field there is also a (small) protocol-surface change deserving its own nod.
**Pin shape if ruled in:** extend `aDoubleCrashedAnotherDeviceResumeKeepsTheRoadsCastleFactsNotTheStaleMarker` with a
caller that passes `recoveryWords:` to the SECOND resume, and assert (red-on-old) that the new key file carries NO W
copy from those words (`newFile.recovery == nil` for the other-device road) AND `outcome.followedAnotherDevicesSwitch
&& outcome.otherDeviceName == "sibling device"`. Red on the current fix (byAnotherDevice spent at `.reencrypt`), green
once the marker carries the bit and the `.reencrypt` arm reads `marker.byAnotherDevice` first in its discriminator.

## ROUND 1 — CLOSED (2026-10-08)

The Fable reviewer's fix pass is ADOPTED (155188c5 + c1daa77c, verified: the diff touches only `PostureSwitch.swift` +
its tests, zero `Sources/`; V99-C and V99-D each red on their own pin alone; PostureSwitchTests 52/52, batch-1 181/20,
spine 99/13, phone compile). **The double-crash residual is RULED OUT of this unit → VX-107** (Backlog, Low): one
cosmetic Done sentence on a double crash + a latent words rule no production door reaches, against a `Sources/…/Sync/`
marker field, another stage slot and another custody review; every key-protecting fact of that road is already carried
and pinned. VX-106's pair greened under the account-consistent harness — RECORDED, not claimed (the arm-order question
stays variorum-da's). Next: one implementer check pass over the whole diff, then round 2 by a fresh Opus 5.5
reviewer, which doubles as her ruled "Opus 5.5 cold review at the end either way" (Fable already had round 1).

## ROUND 1 — IMPLEMENTER SANITY PASS (the Opus implementer, 2026-10-08 — headless, read-only over 155188c5 + c1daa77c; no stage, no fixes)

**Verdict: no regression found; nothing blocks round 2.** Three questions, each traced:

1. **Does an opt-out hide a regression? No.** Of the six `vaultSaysCastle: true` opt-outs, five
   (`theMismatchFollowReKeys…`, `aStandardBornLibraryWithNoCustodyJoinsCastleThroughTheFollow`,
   `aFollowKilledAfterTheReKey…`, `aWrappedLegacyKeyFileStaysAtTheFollow`, `thePosturePinsHold…` (a)) test a
   Standard-shaped library FOLLOWING INTO a Castle account. Under the new Standard default, `runFollow` reads the vault
   (unchanged code, :792) and would follow into Standard, which is correct for that vault and simply not those tests'
   subject. The follow logic itself did not move. The sixth (`aNearEmptyCopys…`) is posture-agnostic. Its Standard
   form refuses `appleKeyUnreachable` only because `makeWorld(sharing:)` mints a NEW iCloud key per world, so every
   sibling is a different-Apple-ID device. **Harness limitation, recorded:** the harness cannot express a same-Apple-ID
   SIBLING on a Standard account. That case is covered single-device (the MAJOR pin, (b)'s control, (c)), not in sibling
   form.
2. **Is any road's posture decision now inconsistent? Not for the Apple copy.** Every road that holds a fetched vault now
   reads it: the door (:382), the belt (:1212), the follow (:792), the resume arm (:1357). The local-only road reads the
   library's own posture, with no vault (decision 8). The posture is still READ in three places, all pre-existing and
   outside VX-99's class (none can put an Apple copy on a Castle account):
   - **(a) Custody on the Replace All Keys road** (`moveCustodyForSwitch(entersCastle: false)` →
     `effective(posture: leaves.posture())`). This is by design: Replace All Keys re-saves custody "in its current
     shape". So under the MAJOR pin's stale Castle read on a Standard account, the vault and the key file say Standard
     while custody stays gated. The next ready's follow-into-Standard arm (`ProtectionController.swift:707`, gated
     shape + an Apple-held copy) heals that mismatch.
   - **(b) `leaveCastle`'s `guard leaves.posture() == .castle`** (and the pane offering Use Standard). Under a stale
     Castle read on an already-Standard account, it rewrites the vault's Apple-held copy under THIS device's iCloud key
     (`settingAppleHeldCopy` replaces). For the same Apple ID that is idempotent; for a different Apple ID it re-homes
     the account's copy, a user act behind the consent sentence.
   - **(c) The Use Castle door** under a stale Standard read on a Castle account. It runs a full rotation with the
     insurance turned off: a Castle Replace All Keys under the entering copy.

   (b) and (c) are for round 2's / the orchestrator's awareness, not this unit's.
3. **Does anything break the follow or the enter-Castle road? No.**
   - **Enter-Castle:** the belt is never reached (`entersCastle ? nil :` stays load-bearing, as the reviewer
     documented). `appleKeyReadable`'s only consumer is `PostureSwitchModel.swift:201` inside the `.replaceKeys` case,
     so a Standard vault's now-non-nil fact never gates `.enter`/`.leave`/`.resume`.
   - **The follow:** `runFollow` is untouched.
   - **The marker:** the new `.reencrypt` marker carries all seven `RotationMarker` fields and equals
     `advanced(to: .reencrypt)` on every road except an another-device one.
   - **One visible side effect, correct:** the Finish door's label reads `pending.entersCastle`
     (`ProtectionPane.swift:318`, `MobileProtectionSheet.swift:265`). A double-crashed another-device resume now offers
     "Finish entering Castle" instead of "Finish replacing keys". That matches the road, since the account IS Castle.
     The single-crash road's later markers already did this since 2a667130.
   - **Phone:** the phone suite's runner use (`MobileProtectionTests.swift:1477`) drives a follow only, so round 1 does
     not reach it. Its compile was re-run green by the reviewer.

## ROUND 2 — ORCHESTRATOR DISPOSITION (2026-10-08; same-model round — Opus reviewer, Opus implementer — so the orchestrator arbitrates against the spec)

Round 2 (`notes/plans/fixes/vx-99-ladder-round2.md`, d9821e8e, unedited) found 1 MAJOR (pre-existing) + MINORs + NITs.
The orchestrator verified the MAJOR's worst arm in code: `PostureSwitchModel.resume` maps `restartRequired` to
`.explain` (:554–556) while the mode stays `.resume`, so `continueFromExplain` (:214) skips the Replace All Keys branch
and walks words → `.floor` → `runner.enterCastle` (:391) — a "Finish replacing keys" press can end in ENTERING CASTLE.
A new MAJOR earns round 3 (the cap). **Dispositions:**

- **Finding 1 (MAJOR, pre-existing) — IN-UNIT.** The resume face must know WHICH act it is finishing: ONE shared
  selector over the pending marker's act (enter Castle vs Replace All Keys, follow vs ceremony) and the outcome's road,
  used by both platforms' running title, Done body and restart. Restart of a Replace All Keys marker restarts Replace
  All Keys (→ `.authorize` road), never Use Castle. The Done never says "your Apple account never held" unless the
  outcome entered Castle; the follow-of-another-device Done keeps ledger 61's words sentence. Pins per arm, red on HEAD.
- **Finding 2 (MINOR, introduced) — IN-UNIT.** `accountPostureIsStandard` reads the door's vault word, not
  `controller.posture` (the same rule as round 1's MAJOR).
- **Finding 3 (MINOR; S1 introduced, S2 pre-existing) — IN-UNIT, option (a).** In the resume's enrolled arm the ROAD's
  posture is the account's (decision 8): custody, insurance, offer, Done AND the Apple copy all from the vault's word;
  where the vault's corpus key id is not the marker's stamped `newCorpusKeyID`, the road is another device's (words not
  landed, the other-device Done). Pins for S1 and S2.
- **Finding 4 (MINOR, pre-existing) — IN-UNIT.** Decision 9: the runner refuses a Replace All Keys that reaches its
  local-only road (the door admits only enrolled libraries, so that road is only ever the check-then-act gap); Use
  Castle's local-only road stays. Pin (d) re-pointed by name to the refusal (its Use Castle half, if any, kept).
- **Finding 5 (MINOR, pre-existing, `Sources/…/Sync/`) — OUT → a ticket** (`CorpusRotation.begin` binding to the
  caller's fetched revision). A narrow cross-device race; the fix is in `Sync/` (Fable work by the standing rule) and
  wants a fetch-count seam. Not tonight.
- **Findings 6–7 (NITs) — IN-UNIT,** including passing the belt-verified `AppleKey?` into `writeNewKeyFile` (finding 7).

Cast for the fix: a FRESH `opus-implementer` (the first one passed ~490k). Round 3 (the cap): a fresh Opus 5.5
reviewer — the last review is Opus 5.5 per her ruling. Stage: one slot via the coordinator.

## ROUND 2 — FIX PASS (a fresh Opus implementer, 2026-10-08 — LIVE STATUS; PENDING = unverified)

**Scope, exactly as disposed above:** findings 1, 2, 3 (option a — S1 + S2), 4, 6 and 7 in-unit; finding 5 OUT (VX-109),
untouched. Surfaces: `Shared/PostureSwitch.swift`, `Shared/PostureSwitchModel.swift`, `Shared/PostureCopy.swift`, the Mac
`ProtectionPane.swift` (the ceremony sheet only), the phone's `MobilePostureSheets.swift`, `PostureSwitchTests.swift`. Zero
`Sources/`.

**THE SEAM (commit 1 — why the reds run on it, not on bare 8f66bc1f).** Three of finding 1's arms (the running title, the
resume's ask, the Done) are decided INSIDE the two face files (`model.mode == .replaceKeys ? … : …`), where no test can read
them. Commit 1 moves those expressions, VERBATIM in effect, into the brain so the pins can: `CeremonyAct` + the model's `act`
(mapped exactly as every `mode == .replaceKeys` branch read it — a resume of ANY marker reads `.enterCastle`), the model's
`runningTitle` / `resumeAskTitle` / `doneBody` over `ProtectionCopy.ceremonyRunningTitle` / `ceremonyResumeTitle` /
`ceremonyDoneBody` (HEAD's expressions: leave/RAK/else-Castle; `resumeBody`; `act == .replaceKeys ? replaceKeysDone :
castleDoneBody(outcome)`), the faces and the model's four flow branches keyed on `act`, plus the one unthrown error case
finding 4's pins name (`PostureSwitchError.replaceKeysNeedsSync`, worded by the switches' offline line). Behavior-identical by
construction; the pins that need no seam (the restart, the follow outcome's phase, the addendum, the S-roads, the gap, the
Apple pair) are red on 8f66bc1f's code as much as on the seam's.

### LIVE STATUS

- Pins + the seam: DONE (this commit) — `PostureSwitchTests`' MARK "VX-99 round 2" (after round 1's pins) + pin (d)
  re-pointed in place. TEST BUILD SUCCEEDED (headless). Thirteen tests:
  - F1 (i)–(iv): `aResumedCeremonysFacesSpeakForTheMarkersActNotAlwaysTheCastleCeremony` (ii + the resume's ask) ·
    `theCeremonysDoneNeverClaimsCastleUnlessTheOutcomeEnteredIt` (the selector's rule, every act) ·
    `aResumedReplaceAllKeysSpeaksItsOwnDoneNeverTheCastleClaim` (i, through the model) ·
    `aReplaceAllKeysWhoseVaultWriteNeverLandedRestartsReplaceAllKeysNeverUseCastle` (iii + the restart's own door) ·
    `aReplaceAllKeysThatBecameTheFollowIntoAnotherDevicesCastleSaysSoAndOffers` (iv).
  - F2: `theReplaceAllKeysScreensStandardAddendumReadsTheVaultsWordNotTheDevicesReading` (both directions).
  - F3: `aResumedUseCastleWhoseAccountLeftCastleElsewhereFollowsTheAccountIntoStandard` (S1, through the model) ·
    `aResumedReplaceAllKeysWhoseAccountWasRotatedAgainElsewhereIsAnotherDevicesRoad` (S2) ·
    `aDoubleCrashedAnotherDeviceResumeStaysAnotherDevicesRoadByTheStampItsMarkerCarries` (the rule on the rewritten marker) ·
    `aResumedFollowWhoseAccountEnteredCastleSinceFollowsTheAccountIntoCastle` (a follow's own marker) ·
    `aResumedCastleReplaceAllKeysMovesCustodyByTheAccountsPostureNotTheDevicesReading` (custody by the account).
  - F4: `aReplaceAllKeysWhoseSessionLapsedAfterTheDoorRefusesInsteadOfRotatingNothing` (the production gap) · pin (d)
    RE-POINTED by name: `aLocalOnlyCastleLibrarysReplaceAllKeysWritesNoAppleCopyAndAStandardOneStillDoes` →
    `aLocalOnlyLibrarysReplaceAllKeysRefusesAndItsUseCastleRoadStillRuns` (both postures refuse; Use Castle's local-only road
    kept as the control — the old pin had no Use Castle half, so the control is new).
  - F7: `theNewKeyFilesAppleCopyIsUnderTheICloudKeyTheBeltVerifiedNotOneReadAfterTheWalk`.
- Red run (the pins commit 43316f21, `PostureSwitchTests` alone): DONE — slot 4 (`vx-99-impl2`, claimed 05:43, zero
  Variorum instances), `test-without-building` over the pins commit's build: **"Test run with 65 tests in 1 suite failed …
  with 63 issues"** — EXACTLY the thirteen new pins, each at its expectations and nowhere else (52 standing tests green,
  round 1's included): pin (d) re-pointed 8 (both postures: no throw, a new key file, the library re-keyed, custody moved) ·
  F1(ii) 7 · F1 selector 10 · F1(i) 3 · F1(iii) 4 (the floor, not `.authorize`; the act `.enterCastle`; no outcome — the
  restart's door blocks sit after the throw and did not run here: their red is the F1 revert's, below) · F1(iv) 3 · F2 2 ·
  S1 7 · S2 6 · the rewritten marker 2 · the follow's own marker 3 · custody by the account 1 · the gap 5 · F7 2 (the key
  file under the swapped A; `.wrongAppleKey`).
- F1 fix: DONE (this commit's predecessor pair — see the log) — `act` maps a resume to its MARKER's act
  (`CeremonyAct(resuming:)`); the selector reads the OUTCOME first (the conflict-follow → ledger 61's sentence or its
  PROVISIONAL sibling `keysReplacedAfterAnotherDevice`; a follow's resume → `followDoneBody`; Castle entered → the Castle
  Done; else Replace All Keys' Done); the running title + the resume's ask by the act (`resumeReplacingKeysBody`,
  PROVISIONAL, where the act does not enter Castle); `replaceKeys()` reads the outcome's insurance + offer; the restart
  re-enters the marker's own ceremony through its own door (the restore hold; Replace All Keys' front check, now the ONE
  helper `replaceKeysFrontCheck` the door shares). Green PENDING.
  **REVERT V99-E (named before it runs):** on the tip, (1) `act`'s `.resume` arm → `return .enterCastle`; (2)
  `ceremonyDoneBody`'s body → `act == .replaceKeys ? replaceKeysDone : castleDoneBody(outcome)`; (3) `replaceKeys()`'s Done →
  `.done(insuranceOff: false, hasOffer: false)`. Expected RED: F1's five pins (incl. the restart's two door blocks, now
  first in that test) and S1's Done line (it rides the selector); everything else green. **RESULT (06:05, over fafafd59 +
  the three edits, built, `PostureSwitchTests`): "Test run with 65 tests in 1 suite failed … with 30 issues"** — F1(ii) 7 ·
  the selector 10 · F1(i) 3 · F1(iii) 5 (the unreachable-iCloud-key door block, the act, `.authorize`, the Done, the outcome)
  · F1(iv) 3 · S1's two Done lines; nothing else. The restore-hold block stayed GREEN under it (the reverted act reads
  `.enterCastle`, which the restart's hold check also covers) — its own red is V99-E′ below. Restored, `git diff` clean.
  **REVERT V99-E′ (named before it runs):** the restart's restore-hold check deleted (the `if act == .enterCastle || act ==
  .replaceKeys, controller.restoreHoldStands?() == true { … }` block). Expected RED: the restart pin's restore-hold block
  alone (run as that one test).
- F2 fix: DONE — `DoorFacts.vaultHasAppleHeldCopy` (the vault's word as the door read it); `accountPostureIsStandard`
  reads it, the posture only before the door answered. Green PENDING.
  **REVERT V99-F:** `accountPostureIsStandard` → `controller.posture == .standard`. Expected RED: the F2 pin's two
  directions alone. **RESULT (06:10): "Test run with 65 tests in 1 suite failed … with 2 issues"** — the F2 pin's two
  directions (:2864 `model.accountPostureIsStandard`, :2875 `!model.accountPostureIsStandard`), nothing else. Restored,
  `git diff` clean.
- F3 fix (option a, S1 + S2): DONE — in the resume's enrolled arm: the STAMP decides at every step that carries one
  (`byAnotherDevice = vaultKeyID != marker.newCorpusKeyID`; the pre-F1 device-name fallback at `.vaultWrite` only, as
  before); the road's posture is the ACCOUNT's — `roadEntersCastle = (byAnotherDevice || marker.isFollow) ? vaultSaysCastle
  : (marker.entersCastle && vaultSaysCastle)` (the insurance, the offer, the retirement, the outcome, the Done) and
  `accountPosture` from the vault for the custody target (threaded through `rekeyCustodyAndSnapshot` →
  `moveCustodyForSwitch`; every other road keeps the posture read); S1's Done names the device that left Castle and its day
  (`Outcome.otherDeviceDay`; the selector's branch 4 → copy §5's existing `followMovedToStandard`). Green PENDING.
  **REVERT V99-G (named before it runs):** on the tip, (1) the discriminator → round 1's (`guard marker.step == .vaultWrite,
  vaultKeyID != material?.corpusKeyID else { return false }` FIRST, then the stamp); (2) `roadEntersCastle = byAnotherDevice
  ? vaultSaysCastle : entersCastle`; (3) the arm's `accountPosture:` argument → nil. Expected RED: S1, S2, the rewritten
  marker, the follow's own marker, custody by the account; everything else green. **RESULT (06:15): "Test run with 65 tests in
  1 suite failed … with 19 issues"** — S1 7 · S2 6 · the rewritten marker 2 · the follow's own marker 3 · custody by the
  account 1, at the red run's own lines; nothing else. Restored, `git diff` clean.
- F4 fix: DONE — `runCeremony`: `guard enrolled || entersCastle else { throw .replaceKeysNeedsSync }` right after the
  enrolled reading, before the derive, the pause and any write; the model words it with the switches' offline line
  (`serverUnreachable`, hoisted from the URLError arm). Use Castle's local-only road untouched. Green PENDING.
  **REVERT V99-H:** the guard deleted. Expected RED: the gap pin + the re-pointed pin (d)'s two refusals; its Use Castle
  control green. **RESULT (06:20): "Test run with 65 tests in 1 suite failed … with 13 issues"** — pin (d) 8 (both postures:
  no throw, a new key file, the library re-keyed, custody moved) · the gap 5; the Use Castle control green; nothing else.
  Restored, `git diff` clean.
- F7 fix: DONE — `appleHeldCopyForStandard` returns the VERIFIED `AppleKey`; `rekeyCustodyAndSnapshot` / `writeNewKeyFile`
  take `appleKey: AppleKey?` (the key, not a Bool): the ceremony's enrolled road passes the belt's key (one A for the
  vault's M′ copy and the key file's L′ copy), the follow and the resume's arm read A only where the vault's word is Standard
  (same moment as before), the local-only road (Use Castle only, since F4) passes nil. Green PENDING.
  **REVERT V99-I:** in `runCeremony`, `appleKeyForKeyFile = appleHeld` → `appleKeyForKeyFile = appleHeld != nil ?
  leaves.appleKeys.read() : nil` (the re-read after the walk). Expected RED: the F7 pin alone. **RESULT (06:25): "Test run
  with 65 tests in 1 suite passed" — GREEN, and the NAMING was wrong, not the pin:** that edit re-reads A at the DECISION site
  (step 2, right after the belt — BEFORE the walk), so it reads the same A the belt verified; 8f66bc1f read A inside
  `writeNewKeyFile` at step 4, AFTER the walk. The red run (43316f21 = 8f66bc1f's runner) showed the pin red at the real
  site (:3173 + `.wrongAppleKey`). Restored, `git diff` clean.
  **REVERT V99-I′ (named before it runs — the corrected revert):** in `writeNewKeyFile`, the parameter binding renamed
  `appleKey decided:` and, before the detached task, `let apple: AppleKey? = decided != nil ? leaves.appleKeys.read() : nil`
  — 8f66bc1f's re-read, at its own place and time. Expected RED: the F7 pin alone. **RESULT (06:30): "Test run with 65
  tests in 1 suite failed … with 2 issues"** — the F7 pin alone (:3173 the key file's `appleKeyID` the swapped A's; the
  `.wrongAppleKey` unwrap); nothing else. Restored, `git diff` clean.
- F6 (NITs): DONE — (1) the `(:524)` cite → the symbol (`runCeremony`'s `vault.fetchVault()` after the drain); (2)
  `DoorFacts.appleKeyReadable`'s doc → "on a Standard ACCOUNT (the vault's word)"; (3) **the rewritten `.reencrypt` marker's
  `newCorpusKeyID` — NOT ADOPTED, disposition:** under finding 3's ruled rule (the stamp decides at every step) the id this
  device minted for a never-landed write is LOAD-BEARING — it is what keeps a second crash on another device's road reading
  as another device's (the other-device Done, the words rule); carrying the vault's id would read that road as this device's
  own on the second resume (the follow flag would still carry the Castle facts, but the Done would fall to the follow's and
  typed words would land). The trap the NIT foresaw does not exist under the built rule (the minted id can never equal a
  vault id); pinned by `aDoubleCrashedAnotherDeviceResumeStaysAnotherDevicesRoadByTheStampItsMarkerCarries`; the site's
  comment says why. Round 1's recorded VX-107 residual (the Done + the words rule on a double crash) is closed by the same
  rule — RECORDED, NOT CLAIMED (VX-107 stays the orchestrator's to close); (4) the "said 'keys replaced'" wording → the
  runner's LOG line (the site's comment + round 1's MINOR pin message); (5) the false "born without the Apple-held copy"
  comment and the three redundant re-wraps (`replaceAllKeysUnderStandardRefuses…`, `replaceAllKeysRefusesAnUnreachable…`,
  `twoDevicesSwitchingPostureAtOnce…`) dropped for an `#expect` that the harness landed the copy; (6) `makeWorld(
  vaultSaysCastle:)` gains a `precondition` (only a fresh enrolled world's vault). No behavioral revert — no behavior.
- F3 correction: DONE (this commit) — the tip's first green run (05:55) failed ONE line, S1's Done (`set on another device on an
  earlier day`): the first `resume(nil)` (before the passphrase ask) rewrites the `.reencrypt` marker with the ROAD's
  `entersCastle` (false on S1), so the second call no longer saw the act (and the pane's door would have said "Finish
  Replacing Keys…" over a Use Castle). Fix: the rewrite keeps the ACT's `entersCastle` on an own road (recomputed from the
  fresh vault every resume anyway) and the road's on another device's road or a follow's marker. Rebuilt; **PostureSwitchTests
  on the tip: "Test run with 65 tests in 1 suite passed"** (06:01, slot 4). The rest of the green and the reverts PENDING.
- Reverts (each named in its fix's commit, BEFORE it runs): PENDING.
- Green (PostureSwitchTests + batch 1's twenty suites + the tutorial spine, each suite its own invocation): PENDING.
- Phone compile (`MobilePostureSheets.swift` touched): PENDING.

### NEW — found by this pass, NOT fixed (the orchestrator's call; outside the ruled findings)

- **The resume door refuses its OWN mid-walk rotation.** `PostureSwitchModel.start()` reads `facts.rotationInProgress`
  (`checkDoor`: the vault carries a previous corpus key) and refuses with the still-finishing sentence BEFORE the mode switch
  — the `.resume` mode included (its exemptions cover `followPending` and the restore hold only). A ceremony interrupted
  mid-walk on THIS device (marker `.reencrypt`, the vault's previous key set — a dropped connection during an 18k-row walk)
  is exactly that state, so "Finish Replacing Keys…" / "Finish Entering Castle…" answers "A key replacement started on
  [this device] … is still finishing. Any signed-in device that has picked up the new keys can finish it. Try again after."
  and never runs `runner.resume`; with the marker set the engine refuses every round, so a one-device account stays paused
  until another device follows. By trace (no test drives `.resume` through the model before this pass; this pass's model-road
  pins pick states where the vault's previous key is already cleared). The likely fix is one exemption (`!isResume` on that
  guard — decision 32: "the acting device resumes through its marker and never starts a second"), but it is a second unit's
  call, so it is left as found.
- **Same-class residual — the "Entering Castle didn't finish" sentence OUTSIDE the sheet.** `ProtectionCopy.resumeBody` also
  captions the pane's resume door for EVERY pending marker (`ProtectionPane.swift:323` under "Finish Replacing Keys…"; the
  phone's twin in `MobileProtectionSheet.swift`, not this pass's surface) and words `PostureSwitchError.switchInProgress`.
  The sheet's own ask now reads the act (finding 1); the pane captions want the same one call
  (`ProtectionCopy.ceremonyResumeTitle(CeremonyAct(resuming: pending))`) on both platforms — left for the orchestrator so the
  two panes move together.
