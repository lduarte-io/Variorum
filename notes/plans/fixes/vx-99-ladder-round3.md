# VX-99 — cold review, ladder round 3 (Opus 5.5, 2026-10-08)

**Scope note, first (the reviewer contract's own rule):** this diff DOES touch custody/keychain code —
`App/Variorum/Shared/PostureSwitch.swift` is the key-file / vault-write / custody-move runner, inside Fable's
mandatory scope by CLAUDE.md's standing rule. The record (HER RULINGS item 2; ROUND 2 — ORCHESTRATOR
DISPOSITION: "Round 3 (the cap): a fresh Opus 5.5 reviewer — the last review is Opus 5.5 per her ruling")
shows the author ruled an Opus 5.5 end review, so this review proceeds on that ruling. Nothing below needs
`Sources/VariorumCore/Sync/`.

Diff reviewed: `git diff b6628b0e..HEAD -- App Sources` at 1ff2ad56 — `PostureSwitch.swift`,
`PostureSwitchModel.swift`, `PostureCopy.swift`, the Mac `ProtectionPane.swift`, the phone
`MobilePostureSheets.swift` + `MobileProtectionSheet.swift`, `PostureSwitchTests.swift` (+22 tests, 46 → 68,
counted); zero `Sources/` (verified by `--stat`). Anchor: the record `vx-99-pro-castle-apple-wrap.md` whole +
rounds 1 and 2 (`vx-99-ladder-round1.md`, `-round2.md`) with their dispositions. Canon read: CLAUDE.md, the three
auto-loaded docs, SyncSpec whole, `pre-13x-postures-design.md` §1 (decisions 1–35), §4, §5, §6, §7, the ledger's
row 61, QUESTIONS #90 (3) and her ruling on it. Code read: `PostureSwitch.swift` whole; `PostureSwitchModel.swift`
whole; `PostureCopy.swift`'s resume/Done/follow lines; `ProtectionController.reconcileFollow`; both panes' posture
sections; `EncryptionViews`' re-key banner; `PostureFollowModel`'s roads; the harness (`makeWorld`, `leaves(for:)`)
and every new/changed test. No "Review foci" section exists in the record. Mac suites NOT run (stage-gated, no
claim held); zero `Sources/`, so the core suite cannot have moved.

## Findings (severity-ranked)

**Tally.** Introduced by this diff: 1 MAJOR (finding 1 — round 2's F3) · 1 MINOR (finding 2 — round 2's F3) ·
NITs. Pre-existing, on roads this unit pins: 2 MINOR (findings 3, 4). The headline fix, round 1's two fixes,
round 2's F1/F2/F4/F7 and round 2b's door + captions are sound (clean bill).

**[MAJOR · diff-introduced (round 2's F3, S2)] · `PostureSwitch.swift:1408–1413` (the stamp now decides
`byAnotherDevice` at `.reencrypt`) → `:1517–1519` (`followedAnotherDevicesSwitch = true`) →
`PostureCopy.swift:941–944` (`ceremonyDoneBody`'s branch 1) → `:851` / `:918` · On S2 the Done tells her the
twelve words her own ceremony showed "are NOT your account's" and names words another device "showed" — but on
S2 her ceremony's words DID land, and are still the account's whenever the other device typed them.**
Evidence (traced):
- Ledger 61's premise (`pre-13x-postures-design.md` §18 ledger row 61): "the loser's ceremony becomes the follow
  (M1) and its user holds twelve words that **never landed**". Her ruling on QUESTIONS #90 (3) accepted the
  sentence for that case — "it's fine if it tells you the twelve words aren't your account's".
- The ceremony writes its stamped `.reencrypt` marker only AFTER its own vault write landed and custody took
  M′ (`PostureSwitch.swift:684–686`, after `CorpusRotation.begin` at `:629`). So at `.reencrypt` with the
  ceremony's own marker (stamp set, `follow == nil`), A's words are ALREADY the vault's W wrap (A regenerated →
  shown and landed; A typed → re-wrapped).
- S2 as F3 built it: B follows A (finishing A's walk), then B runs a SECOND rotation (Use Castle or Replace All
  Keys). B's words screen offers the existing words first (decision 33: "TYPED from the paper (they keep opening
  everything) or REGENERATED"; `PostureSwitchModel.wordsExist` reads the vault's W, `submitExistingWords`
  verifies them against the vault). If B TYPES them, B's rotation wraps M″ under A's words: the account's words
  ARE the ones A showed.
- A resumes (`resume`, `:1408`): stamp ≠ the vault's id → `byAnotherDevice` → `outcome.followedAnotherDevicesSwitch
  = true` (`:1517–1519`) → `ceremonyDoneBody` branch 1 → `enteredCastleAfterAnotherDevice` (B used Castle) or
  `keysReplacedAfterAnotherDevice` (B replaced the keys): "Another device entered Castle first … The twelve
  words shown here are NOT your account's: your account's words are the ones sibling device showed when it
  entered Castle — those are the set to keep." Every clause is false in the typed case: A's replacement landed
  FIRST, A's words ARE the account's, B showed no words. The sentence directs her away from the only valid paper
  copy of Castle's floor secret (decision 21: "lose every enrolled device and both secrets and it is gone").
- Without F3's S2 arm (F1's selector alone) this road reads as A's own (`byAnotherDevice` required
  `.vaultWrite`) and speaks Replace All Keys' Done — no words claim; V99-G's arm (1) (the discriminator's old
  order) is exactly that revert. The existing S2 pin (`aResumedReplaceAllKeysWhoseAccountWasRotatedAgainElsewhereIsAnother
  DevicesRoad`, `PostureSwitchTests.swift:2950`) passes only because `makeWorld(sharing:)` mints FRESH words per world
  (`PostureSwitchTests.swift:700`) — the B-regenerated sub-case, the one where the sentence happens to be true;
  its message at `:2982`, "the account's words are B's", encodes the false premise.
- Likelihood: an interrupted walk (the long step — her corpus is 18k rows), another device's ordinary follow,
  that device's ordinary second switch typing the existing words, then "Finish Replacing Keys…". Every step is an
  ordinary act; the consequence is a false instruction about the recovery secret. (The words RULE on this road —
  not landing typed words — is conservative and harmless; production passes `recoveryWords: nil` anyway.)
- Same ambiguity, pre-existing and narrower, at `.vaultWrite`: A's write landed, custody did not
  (`afterVaultWriteBeforeCustody`'s window), B follows then rotates again → the stamp differs → the same Done.
Pin (red on HEAD; green under the fix — and under V99-G's arm (1), which proves the mechanism): S2's world with `b.words = a.words` before B's `enterCastle`
(B TYPES the account's words); A resumes through `PostureSwitchModel(mode: .resume(aMarker))` → `start()` →
`resume(passphrase:)` → expect `!model.doneBody.lowercased().contains("not your account's")`, and the vault's W
still opens with `a.words` (the fact the Done must not deny). Today: the ledger-61 sentence.
Fix (the orchestrator's; the sentence is copy → QUESTIONS/13s): the runner tells the selector whether THIS
ceremony's words could have landed — e.g. `Outcome.ceremonyWordsLanded` set on an another-device road reached
from the ceremony's OWN `.reencrypt` marker (`marker.step == .reencrypt && !marker.isFollow`), and the selector
speaks, there, a sibling that names the other device's later change WITHOUT the words claim (her words are
whichever set that change used; the vault's recovery-wrap digest vs the key file's recorded one can say which at
the next ready — the 4a change-notice road). The `.vaultWrite` and second-crash ambiguities stay recorded
residuals beside VX-107 (the marker cannot tell them apart without a `Sync/` field).

**[MINOR · diff-introduced (round 2's F3, custody by the account)] · `PostureSwitch.swift:1442` + `:1516`
(`accountPosture` into `moveCustodyForSwitch`, `:1211–1212`) · A resumed Replace All Keys on a Castle-shaped
device whose ACCOUNT left Castle elsewhere now performs the follow into Standard's custody move — Touch ID → silent
— with no sentence; §7's one-time notice for that move can no longer fire.**
Evidence (traced): the F3 pin's own world (`aResumedCastleReplaceAllKeysMovesCustodyByTheAccountsPostureNotThe
DevicesReading`): A Castle (custody `.biometric`), its RAK killed mid-walk, B follows and uses Standard. A's
resume: own road (stamp = the vault's id), `roadEntersCastle = false`, `accountPosture = .standard` → custody
`.auto`, the key file gains L′ under A. The Done: `ceremonyDoneBody(act: .replaceKeys)` → branch 5 →
`replaceKeysDone` ("Done. Your other devices will ask for your passphrase the next time they open.") — the pin
asserts exactly this (`PostureSwitchTests.swift:3113`). Then `leaves.reconcile()` → `reconcileFollow`'s follow-into-Standard arm
(`ProtectionController.swift:707`: `reading.hasAppleHeldCopy, keyFile?.apple == nil || shape == .gatedOrNone`) —
the key file now carries `apple` and the shape is silent, so the arm never fires and `movedToStandardNotice`
(`:711`, "Your account is back in Standard — set on [device] on [day]. This Mac opens silently again") is never
set — not now, not at any later ready. Before F3 (custody by the read) the device stayed gated, and the next
ready's arm made the move WITH that notice (§7: "custody goes silent, a one-time notice names the device and
day"). Her Mac stops asking for Touch ID and nothing ever says why. S1 (the Use Castle act) says it in its Done
(branch 4, `followMovedToStandard`) — the Replace All Keys act on the same road does not. (Facet: the ceremony
road `runCeremony` → `rekeyCustodyAndSnapshot(..., accountPosture: nil)` still moves custody by the read, so one
act now carries two custody rules — harmless there only because it leaves the move to the announcing reconcile.)
Pin (red on HEAD): the F3 custody pin's world through `PostureSwitchModel(mode: .resume(marker))` → expect the
Done to name the account's move (`followMovedToStandard(device: "sibling device", …)`), or — the other fix —
custody left gated and the controller's next reconcile setting `movedToStandardNotice`.
Fix (either): (a) the runner tags this road like S1 (`otherDeviceName`/`otherDeviceDay` when the road ends
Standard on a library that was Castle-shaped — `wasStandardShaped == false`) and the selector's branch 4 keys on
the outcome ("the road moved this device into Standard") rather than on `act == .enterCastle`; or (b) for the
into-Standard direction, keep custody by the read on the resume too and let the ready's arm move it with its
notice (the into-Castle direction of `accountPosture` is a tightening and may stay).

**[MINOR · pre-existing; the sibling of round 2's finding 4 that F4's guard left open] · `PostureSwitch.swift:535`
(`guard enrolled || entersCastle`), `PostureSwitchModel.swift:258` (`case .enter: phase = .explain` — no
enrolled check) · USE CASTLE still runs its local-only road for an ENROLLED-shaped library (sync custody held,
signed out or the session lapsed) — decision 9 names both switches as online-only for an enrolled library; the
Done says "You're in Castle" and the next signed-in ready silently reverts it.**
Evidence (traced): `runCeremony`'s `enrolled` is `vault && transport && signedIn && custody` (`:521`); a device
signed out (design §5: "Sign out … the keys stay in this device's custody") or whose session lapsed during the
screens has `custody != nil`, `enrolled == false`. F4's guard exempts by the ACT (`entersCastle`), not by the
library, so Use Castle passes into the `else` road (`:692–701`): L′ under P (+W) only — no master copy
(`material == nil`), custody behind the gate, the insurance OFF, the offer LISTED (`listPreSwitchPairs:
entersCastle`), the Castle Done. The vault is untouched — still Standard (the Apple-held copy). At the next
signed-in ready: custody's corpus id = the vault's, `reading.hasAppleHeldCopy` and the key file without `apple`
→ the follow-into-Standard arm (`ProtectionController.swift:707`) re-adds L′ under A and moves custody silent,
speaking "Your account is back in Standard — set on [the vault's last writer] on [day]" — her deliberate Castle
act undone, and any pre-switch backups she deleted at the offer were deleted for a Castle that never happened.
The door does not stop it: the pane offers Use Castle whenever `controller.posture == .standard` (an indeterminate
reading collapses silent custody to Standard — decision 35), and `start()`'s `.enter` arm reads no `enrolled`.
Pin (red on HEAD): `makeWorld()` (enrolled, Standard account), re-arm the runner with `signedIn = { false }`
(the F4 gap pin's own move), `enterCastle(...)` → expect a refusal (today: `outcome.entersCastle`,
`material == nil`, the vault's Apple-held copy still present).
Fix: discriminate the local-only road by the library's enrolled SHAPE — refuse a switch whose library holds sync
custody (or whose key file records a vault corpus id) but is not enrolled now (the switches' offline sentence);
the genuinely pre-sync library (no custody, no recorded id) keeps §4's "Without sync: steps 4–7 only". Round 2's
disposition ruled "Use Castle's local-only road stays" — this keeps that road; it closes only the enrolled-shaped
gap. The orchestrator's call whether it rides VX-99 or a ticket.

**[MINOR · pre-existing (VX-107's class); on the road round 2's F1(iv) pins] · `PostureSwitch.swift:659–668`
(`clearMarker()` then `runFollow`) + `:871` (the follow's marker: no stamp) · A ceremony whose CAS refuse became
the follow loses ledger 61's sentence if that follow is interrupted — the resume speaks the follow's ordinary
Done over twelve words that never landed.**
Evidence (traced): the CAS-refused road clears the ceremony's marker and runs `runFollow`, whose rotation road
writes `RotationMarker(step: .reencrypt, entersCastle:, startedAt:, follow: true)` — no `newCorpusKeyID`.
`followedAnotherDevicesSwitch` is set only after `runFollow` RETURNS (`:671`). A dropped connection during that
follow's walk (the other device's rotation still incomplete — any M′-holder finishes it) leaves the follow
marker; the resume's discriminator finds no stamp and `marker.step != .vaultWrite` → `byAnotherDevice == false`
(`:1409–1410`) → no flag → the face's act is `.follow(...)` → `ceremonyDoneBody` branch 2 → `followDoneBody`
("Your new keys are in place on this Mac, and sync is back on."). If she chose *Generate New Ones* in that
ceremony she holds paper that opens nothing, unsaid — ledger 61's exact case, which F1(iv) pinned on the
uninterrupted road only.
Pin (red on HEAD): F1(iv)'s world (`aReplaceAllKeysThatBecameTheFollowIntoAnotherDevicesCastleSaysSoAndOffers`)
with B's walk left incomplete and A's follow walk crashed (`setCrashNextReencrypt` before each), then A's resume
through the model → expect `outcome.followedAnotherDevicesSwitch` and the ledger-61 Done (today:
`followDoneBody`).
Fix: the CAS-refused road's follow marker carries the ceremony's minted, never-landed id (`prepared.corpusKeyID`
— a `stamp:` parameter on `runFollow`), so round 2's stamp rule reads the resume as another device's road (the
flag, the words rule, the Done) with zero `Sync/` change; here ledger 61's premise (the words never landed) is
TRUE, unlike finding 1's road.

**[NIT] · cleanliness / sweep bundle**
- `EncryptionViews.swift:120–122` (`rekeyIncompletePrompt`: "Key replacement didn't finish … Run Replace
  Encryption Keys again"), `:664` (the banner's door, always `finishReplacingKeysDoor`) and
  `SyncStatusViews.swift:147` ("Finish key replacement…") — the third and fourth resume surfaces, shown for EVERY
  `RotationMarker` (`AppServices.swift:261`, `RotationMarker.isSet`), still name one act whatever the marker
  records. Round 2b's caption rule (the act selector over the pending marker) swept the two panes only. Over a
  Use Castle marker these say "Key replacement" — the inverse of the fixed direction and far milder (entering
  Castle does replace every key, decision 6), so a NIT; one `ceremonyResumeTitle(CeremonyAct(resuming:))` read
  (the banner already reads the marker) would make every resume surface one rule.
- `PostureSwitchModel.swift:35` — `CeremonyAct` (a pure function of `RotationMarker`) lives in the face-model file,
  while the runner's error type now carries it (`PostureSwitch.swift:84`) and the runner builds it at three sites
  (`:511`, `:749`, `:803`): the brain's error depends on a type declared beside the ceremony's view model. Same
  module, so it compiles; housing it beside `RotationMarker`'s other readers in `PostureSwitch.swift` (or as
  `RotationMarker.act`) keeps the dependency pointing down.
- `PostureSwitch.swift:1505` — SPECULATIVE in production: the resume's own-write Standard arm re-reads A after the
  walk (`leaves.appleKeys.read()`), without the vault-id check round 2's F7 gave the ceremony's half of the same
  act, so a swap of the iCloud item between the crash and the resume splits the pair F7 joined. Any check must be
  own-road only (another device's road and a different-Apple-ID device legitimately wrap under their own A — the
  `followIntoStandard` precedent).
- The record's class-sweep rows 1–2 still cite round-1 line numbers (`:560`, `:638`, `:1338–1339`, `:1376`) —
  the code moved twice since; name the symbols (round 2's own NIT rule for code comments).

## Clean bill (checked, found solid)

- **The headline fix, on every road that writes a key file:** `writeNewKeyFile` takes the caller's `appleKey`
  and never reads A itself (`PostureSwitch.swift:1145–1182`). The ceremony's enrolled road passes the
  belt-verified A exactly when the vault write carries an Apple-held copy (`:611–622`). The resume's vault arm
  reads A only when the vault just fetched says Standard (`:1505`). The follow keeps its `!entersCastle` from the
  vault (`:860`, `:879`). Entering Castle is nil on every road. Replace All Keys never reaches the local-only road
  (`:535`). §3.4's Castle row (L′ under P, W and M only) holds on all four. Her Pro's mechanism
  (`entersCastle ? nil : read()` on a Castle account) is gone.
- **Round 1's MAJOR fix:** the door (`appleKeyReadable`, `:398–412`) and the belt (`appleHeldCopyForStandard`,
  `:1272–1285`) gate on the same vault word. The readable and vault-id refusals are kept. The caller's
  `entersCastle ? nil :` (`:611–612`) is still load-bearing: the enter-Castle road's fetched vault is still the
  old Standard one.
- **Round 2's F1 selector:** `CeremonyAct(resuming:)` maps every marker shape. Its `entersCastle` always equals
  the marker's, so the door label (`pending.entersCastle`) and the caption (`ceremonyResumeTitle`) can't disagree.
  The selector puts the outcome first: a conflict-follow speaks ledger 61 or its sibling, a follow speaks the
  follow's Done (the same body `PostureFollowModel`'s own Done renders, `ProtectionPane.swift:915`), Castle
  entered speaks the Castle Done by snapshot fate, and the act's own Done comes last. No face branch still reads
  `mode == .replaceKeys` (grep: the only `mode ==` left is the restore-hold door, `PostureSwitchModel.swift:236`).
  The restart re-enters the marker's own ceremony. It passes that ceremony's restore hold and Replace All Keys'
  front check, and `continueFromExplain` / `mirrorWords` / `authorize` / `commitNewPassphrase` all key on `act`.
  `replaceKeys()` reads the outcome's insurance and offer. The Mac and phone faces are line-for-line twins.
- **Round 2's F2:** `accountPostureIsStandard` reads `facts.vaultHasAppleHeldCopy`. That field is nil until the
  door answers and nil when not enrolled, and the Replace All Keys door refuses non-enrolled libraries anyway.
- **Round 2's F4 (for Replace All Keys):** the guard sits after `busy` and before `pauseSyncForCeremony`. A
  refusal there pauses nothing, so `balancingSync`'s resume is a no-op (the pin's `pauses == resumes`). No marker
  and no write happen.
- **Round 2's F7:** one A for the vault's M′ copy and the key file's L′ copy on the ceremony road. V99-I's
  mis-sited first revert and V99-I′'s correct one are both recorded honestly.
- **Round 2's F3 discriminator:** the stamp decides at every step that carries one. The ceremony's
  `.vaultWrite` / `.reencrypt` markers carry it. The follow's markers (`:871`) and the CAS-refused road's don't,
  so an ordinary follow's resume still reads as its own. The rewritten another-device marker keeps the minted
  never-landed id, so a second crash stays on that road. The F6 non-adoption is justified and pinned. The F3
  correction (the own road's rewritten marker keeps the ACT's `entersCastle` across the passphrase ask) is right:
  S1's Done and the pane's door label both depend on it. The issues above are with what F3 makes the face SAY
  (finding 1) and announce (finding 2), not with its custody/Apple/retirement facts on the another-device road.
- **Round 2b, item 1 (the resume's exemption from the still-finishing refusal):** sound by trace.
  `restartRequired` can't fire while the vault carries a previous key (`:1372` requires it nil), so the
  exemption never sends a restart into a live rotation. A `.vaultWrite` marker beside ANOTHER device's
  in-progress rotation becomes that rotation's follow and helps finish it, which decision 6 allows ("any enrolled
  device can finish a rotation"). The `.rekeyLibrary` / `.custody` / `.snapshot` arms write no vault. Every other
  mode keeps decision 32's door (pinned for `.enter` / `.replaceKeys` / `.leave`).
- **Round 2b, item 2:** both panes caption the door through the selector over `pending`; `switchInProgress`
  carries the pending marker's act at the three marker sites (`:511`, `:749`, `:803`); `message(for:)` matches
  `(_, let act?)` before the bare case; no production code compares the error by value (grep). The busy arm's
  wording is honestly recorded as a residual.
- **The harness and the count:** `makeWorld(vaultSaysCastle:)`'s precondition covers what it shapes. The six
  opt-outs are each a deliberate mismatch or the different-A sibling. 46 → 68 tests, counted
  (4 + 2 + 13 + 3 = 22 new by name, pin (d) re-pointed in place). The source-reading caption pin resolves its
  paths from `#filePath` correctly and drops `//` lines before matching.
- **Sync shape and process:** zero `Sources/`. The only vault write is unchanged in shape (one CAS write under the
  old proof). Key files and custody stay local. Nothing scales with corpus size and no text is copied across
  entities. The commits in range carry no `Co-Authored-By` / `Claude-Session` trailers, and the range has no
  merges or rewrites. Each piece was pinned first and red on old, with a named revert recorded before it ran.
  VX-106's greening is recorded, not claimed. Finding 5 → VX-109 is untouched.
