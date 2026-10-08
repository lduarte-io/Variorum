# VX-99 — cold review, ladder round 1 (Fable, 2026-10-08)

Diff reviewed: `git diff b6628b0e..HEAD -- App Sources` (`PostureSwitch.swift` +65/−10,
`PostureSwitchTests.swift` +229). Anchor: `notes/plans/fixes/vx-99-pro-castle-apple-wrap.md` whole;
canon read: SyncSpec whole, `pre-13x-postures-design.md` §1 (decisions 3/6/7/8/9/28/30/32/33/35),
§3.4/§3.5/§3.6, §4, §5, §7; the touched code and its reach (`PostureSwitch.swift` whole,
`ProtectionController.reconcileFollow`/`reconcileAppleKey`/`landAppleCopyOffMain`,
`StoreLaunchGate.effectiveGate`, `StoreProtection.PostureReading`, `CorpusRotation.prepare`/
`RotationMarker.advanced`, `StoreBackup.writeSnapshotKeyFile`, `LibraryAdoption`), the test harness
(`makeWorld`, the scripted leaves) and all five new/changed test roads. No "Review foci" section
exists in the record. Mac suites not re-run here (stage-gated; the record's runs are the evidence —
internally consistent and named test-by-test); the diff touches no `Sources/`, verified by
`git diff --stat`, so the core suite cannot have moved from the 13x baseline.

## Findings

**[MAJOR] · App/Variorum/Shared/PostureSwitch.swift:1193 (`appleHeldCopyForStandard`, consumed at
:556 and — via VX-99's `appleCopyInKeyFile = appleHeld != nil`, :560 — now also deciding the key
file) · The enrolled ceremony's Apple-held decision reads the ACTING posture instead of the vault it
holds in hand — the one road of the four that still decides from `leaves.posture()`, and it is the
road that rewrites the VAULT, so a stale or indeterminate posture read silently flips the ACCOUNT's
posture.**
Evidence (traced, both directions):
- The rule the diff itself ratifies — decision 8 ("posture is the ACCOUNT's once a vault exists"),
  decision 35's letter, and `StoreProtection.swift:122–128`'s documented law ("every posture-DRIVEN
  write … requires `determined`, and an indeterminate reading writes NOTHING") — is applied by this
  diff to the resume arm (:1326–1339, `vaultSaysCastle` from the fetch) and was already `runFollow`'s
  (:783). The ceremony's enrolled road fetches the same vault (`fetched`, :524) three lines above the
  decision, yet gates on `leaves.posture()` — the COLLAPSED `PostureReading.acting`
  (ProtectionController:1039), which under an indeterminate reading is the custody shape and under
  staleness is the last ready's word.
- Direction (i), reachable in one ordinary step: account STANDARD; another device runs `leaveCastle`
  (decision 7 — nothing rotates, so THIS device's custody still holds the CURRENT master and the
  door's corpus-id front check passes; its proof passes; the step-1 fetch sees the current revision).
  This device's acting posture is still `.castle` until its next reconcile (decision 35's
  follow-into-Standard arm, ProtectionController:707, fires only at a later ready). The user runs
  Replace All Keys here → `appleHeldCopyForStandard` returns nil (:1193's guard) →
  `CorpusRotation.prepare(appleHeldCopy: nil)` (CorpusRotation.swift:426 — "nil writes none") → the
  vault is rewritten WITHOUT the Apple-held copy → **the account silently enters Castle**: every
  other device is forced to follow into Castle at its next ready (type P/W, re-key), the
  Apple-account recovery road dies with no consent sentence, no ceremony, no notice that says so —
  the Done reads "keys replaced". §5's Replace-All-Keys row ("the vault rewritten under the same
  posture's wrappers (+ the iCloud copy again in Standard)" — the ACCOUNT's posture) is violated.
  The door is no guard: `checkDoor().appleKeyReadable` is nil under a `.castle` posture read (:373),
  and `replaceAllKeys` carries no posture/vault cross-check by design (it serves both postures).
- Direction (ii), the mirror, narrow (chained corners — needs current-master custody beside a
  silent/stale `.standard` read on a Castle account, e.g. finding 2's end state): the posture guard
  passes, the vault's `appleKeyID` is nil under Castle (`KeyVaultFormat.create` absent the copy), so
  the id guard at :1198 cannot fire → the vault GAINS an Apple-held copy of M′ → the account
  silently leaves Castle.
- The class-sweep's row 1 records this gate as the SAFE mechanism ("which `appleHeldCopyForStandard`
  gates on `posture == .standard`"); the gate's premise — that the posture read speaks for the
  account — is the thing falsified. It is the exact premise whose key-file half this ticket just
  fixed, one call above the fix.
Pin (red on today's code): two sharing worlds — A `makeWorld(standard: false)` (Castle), B
`makeWorld(sharing: a)`; B runs `leaveCastle()` (the vault gains the Apple-held copy; A's scripted
posture stays `.castle`); A runs `replaceAllKeys` → expect the vault STILL carries
`masterWrappedByAppleHeld` (red today: dropped) and A's new key file carries `apple` under the
shared A (red today: absent). The Standard controls (b)/(d) and pin (c) stay green.
Fix: derive the Standard/Castle word for `appleHeldCopyForStandard` from the fetched vault —
`fetched.format.masterWrappedByAppleHeld != nil` in place of the `leaves.posture()` guard, keeping
the readable/vault-id refusals — one rule on all four roads, exactly the orchestrator's 5ce7175b
grounds. PRE-EXISTING (not introduced by this diff; the same bug class as the ticket's headline,
account-grade instead of file-grade); whether it lands in this unit — a one-line decision change
plus the pin, the same shape as the resume-rule delta — or as a sibling ticket is the orchestrator's
call. Note: the fix will surface the harness-world question the record already hands to VX-106 (the
default `makeWorld()` vault is Castle-shaped under a Standard key file — a mismatch state the
Standard controls currently paper over).

**[MINOR] · App/Variorum/Shared/PostureSwitch.swift:1362 (`writeMarker(marker.advanced(to:
.reencrypt))` in the `.vaultWrite`/`.reencrypt` arm) · The double-crash residual the record hands to
this review — the advanced marker drops the road's corrected facts, so a second crash inside the
walk of an another-device resume finishes under the stale ones.**
Evidence: `RotationMarker.advanced(to:)` carries "the same facts" (CorpusRotation.swift:236–240) —
the original `entersCastle` (false for Replace All Keys) and no follow flag. In pin (e)'s road
(`byAnotherDevice`, vault says Castle), a second crash in the window between :1362 and the
`.rekeyLibrary` marker (:1032) — i.e. during `reencryptAndComplete`, which has real work whenever
the other device's rotation is still incomplete — leaves a `.reencrypt` marker with
`entersCastle=false`, `follow=nil`. The next resume re-enters the arm; `byAnotherDevice` cannot fire
at `.reencrypt` (:1316 requires `.vaultWrite`), so `roadEntersCastle = false`: the Apple copy stays
CORRECT (`!vaultSaysCastle` reads the fresh fetch — the headline class is closed), but custody moves
by `effective(posture: leaves.posture())` (silent under an indeterminate `.standard` collapse — the
scenario's own enabling condition), `retireOldKeyFiles` is skipped (`follow && entersCastle`), no
offer is listed, and the outcome says "keys replaced" on a Castle account. Bounded: decision 35's
mismatch arm (ProtectionController:662 — custody silent + account Castle ⇒ the follow into Castle
owed) heals it at the next DETERMINED ready; until then the library key sits Standard-shaped
(silent) on a Castle account.
Pin (red on today's code): pin (e)'s world with B's rotation left incomplete (B killed mid-walk so
`previousCorpusKey` stands), A's first resume crashed via `setCrashNextReencrypt(true)`, then a
second resume → expect custody `.biometric`, `outcome.entersCastle`, the old Standard-era key file
retired.
Fix: write the advanced marker with the road's facts — step `.reencrypt`, `entersCastle:
roadEntersCastle`, `follow: (marker.isFollow || byAnotherDevice) ? true : nil`, the other fields
carried — so the second resume's `.reencrypt` arm (and every later arm) inherits them. One marker
construction; red-on-old pinnable. Needs a disposition (in-unit or ticket) — the record logged it
as outside the ruled scope.

**[NIT] · notes/plans/fixes/vx-99-pro-castle-apple-wrap.md, "THE CLASS SWEEP" row 1 · The row's
"the gate / the mechanism" column states the posture gate as the enrolled road's safety mechanism
without naming its limit** — that the gate reads the acting posture, which the record's own RESUME
RULE section establishes can diverge from the account. If MAJOR-1 above is deferred to a ticket,
this row should carry the residual the way row 2 carries its double-crash corner, so the sweep
stays an honest census. Doc-only; no pin.

## Clean bill (checked, found solid)

- **The headline fix's mechanism and letter**: `writeNewKeyFile` no longer reads "any readable
  iCloud key" (`apple = appleCopy ? read() : nil`, :1092); the decision is threaded per road —
  enrolled ceremony `appleHeld != nil` (consistent with the vault write it mirrors), local-only
  `!entersCastle && posture == .standard` (a genuinely local-only library's posture IS its own —
  decision 8's second sentence; the derivation's local arms are determined, and the door refuses the
  not-enrolled in-between states), follow `!entersCastle` from the vault just fetched (behavior
  byte-identical to pre-diff), resume `!vaultSaysCastle` from the vault just fetched. §3.4's Castle
  row (L′ under P, W, M only) and §7 step 5's Standard parenthesis both honored.
- **The resume rule (2a667130)**: `roadEntersCastle = byAnotherDevice ? vaultSaysCastle :
  entersCastle` drives custody, retirement, the offer and the outcome symmetrically with
  `runFollow`'s own gates (`listPreSwitchPairs: entersCastle && wasStandardShaped`, retire only
  `follow && entersCastle`); the own-write arm's `!vaultSaysCastle` equals the ceremony's decision
  for every own-write shape (Standard RAK → copy; Castle RAK / enterCastle → none); markers written
  by `rekeyCustodyAndSnapshot` after the decision point carry the corrected facts, so single-crash
  re-resumes are coherent (only the :1362 window above is exposed).
- **All five new tests** traced against the harness: the Castle world is coherent (vault with no
  Apple-held copy and nil `appleKeyID`, key file P+M only, custody gated, posture `.castle`, iCloud
  key READABLE — her Pro's state); the scripted posture derives from the custody moves exactly as
  the custody-shape reading would; seam 1/2/3 marker states verified against the runner's step
  order (seam 3 correctly pins the ceremony's own pre-crash write, which the `.rekeyLibrary` resume
  reads and never rewrites); pin (e)'s expectations each map to a traced line of the fixed road.
  The Standard controls guard decision 30's pinned PRESENCE on both the resume and local-only
  roads; the standing pin (c) (:2865, `newFile.apple != nil` at :2903) is untouched.
- **The class sweep's census re-run independently**: `setAppleWrappedCopy` callers outside tests
  are exactly PostureSwitch :926 (followIntoStandard — reached only from the vault-says-Standard
  reconcile arm, ProtectionController:707), :1113 (writeNewKeyFile — this fix), :1248 (leaveCastle
  — the consent act, posture-guarded `.castle`), ProtectionController:1612 (landAppleCopyOffMain —
  gated `postureReading.determined == .standard`, decision 35's compliant pattern), StoreLaunchGate
  :372 (gated `!enrolled && custody==.silent && apple==nil && passphrase!=nil && belongs` — corner
  45). Snapshot key files are byte-copies never rewritten (StoreBackup:589–593, decision 11);
  the 13x adoption/hand-off/open roads byte-copy and read only. The sweep's verdicts match the
  code, with row 1's premise caveat above.
- **The 13x detector and the pre-existing reds**: `castleKeyFileAppleOpenable` owes-and-returns at
  ProtectionController:680–684, before `changeElsewhere` (:696) — the record's traced mechanism for
  the two VX-106 reds is exact; both tests exist (:2764, :3034), are untouched by this diff
  (additive-only, verified in the diff hunks), and are correctly fenced out of this unit's green
  criterion.
- **Process**: pins-first with revert-verified red (V99-A exactly the pre-fix decision for every
  road; V99-B exactly the two resume lines), commit-per-piece with LIVE STATUS, no
  Co-Authored-By/Claude-Session trailers, no history rewrites, `Sources/VariorumCore/Sync/`
  untouched except nothing (the diff is App-side only), stage discipline followed per the record
  (slots held, zero-instance starts, pre-existing reds proven on main's exact code). Record-file
  line citations spot-checked exact (:1338–1339, :1376, :556/:560, :638, :1092).
- **Sync-shape**: no synced write changes — key files and custody are local artifacts; the one
  vault write path is unchanged in shape (same CAS + proof); nothing scales with corpus size;
  no text copied across entities.
