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
| 1 | `PostureSwitchRunner.writeNewKeyFile` via `runCeremony` — Replace All Keys / Use Castle (`PostureSwitch.swift` :1092, decided at :560 / :638) | **FIXED** — pins (a), (d); revert V99-A | enrolled: `appleHeld != nil` — the vault write's own Apple-held copy, which `appleHeldCopyForStandard` gates on `posture == .standard` (and refuses an unreadable / another account's A); local-only: `!entersCastle && posture == .standard`; entering Castle: nil |
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
