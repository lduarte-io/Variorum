# VX-99 — Pro library stayed Apple-openable after Castle (the record)

**Status: FINDINGS REPORTED, no fix built.** Read-only investigation 2026-10-08. The Sync/-custody slot
stays 13x's (VX-6); the fix waits for 13x's merge or comes back to her as a sequencing question.

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

- Pins (a)–(d) written, RED on the pre-fix code: IN-PROGRESS — written in `PostureSwitchTests.swift`
  (the `VX-99` MARK after `replaceAllKeysRefusesAnUnreachableAppleKeyAtTheDoorBeforeAnyScreen`):
  (a) `aCastleReplaceAllKeysWritesNoAppleCopyIntoTheNewKeyFileWhileTheICloudKeyIsReadable`;
  (b) `aCastleReplaceAllKeysResumedAfterACrashWritesNoAppleCopyAndAStandardOneStillDoes` (three seams —
  mid re-encryption, after the vault write before custody, `.rekeyLibrary` — plus a STANDARD resume control);
  (c) the standing `replaceAllKeysThroughTheDoorIsFollowedByTheSiblingAndAStaleCopyOpensNothing` (`newFile.apple
  != nil`) untouched; (d) `aLocalOnlyCastleLibrarysReplaceAllKeysWritesNoAppleCopyAndAStandardOneStillDoes`
  (the harness reaches the runner's local-only road; the DOOR refuses a non-enrolled library —
  `replaceKeysNotEnrolled` — so (d) pins the runner's road, reached whenever its own enrolled reading fails at
  the run). Compile PENDING (build-for-testing); the red run PENDING the coordinator's stage slot.
- The fix: NOT-STARTED
- Behavioral revert (named here BEFORE it runs): NOT-STARTED
- Class sweep table: NOT-STARTED
- Core headless run: NOT-STARTED
- Mac suites under a stage slot: NOT-STARTED
