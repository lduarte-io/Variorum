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

## Next

1. Her rulings: sequencing of the fix (after 13x's merge, or ask 13x to lend the slot), the reviewer model
   for the fix, and whether to delete the 13 Apple-openable snapshots.
2. The fix session: the pins above red first, the fix, the class sweep, a cold review over the diff.
