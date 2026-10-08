# VX-99 — cold review, ladder round 2 (Opus 5.5, 2026-10-08)

**Scope note, first (the reviewer contract's own rule):** this diff DOES touch custody/keychain code —
`App/Variorum/Shared/PostureSwitch.swift` is the key-file / vault-write / custody-move runner — which is
inside Fable's mandatory scope by CLAUDE.md's standing rule. The record (HER RULINGS item 2; ROUND 1 —
CLOSED) shows the author ruled an Opus 5.5 end review "either way", after Fable ran round 1 and the cast
moved to Opus at her word. This review proceeds on that ruling. Finding 5 below names a fix that lives in
`Sources/VariorumCore/Sync/` — that one is Fable's surface whoever takes it.

Diff reviewed: `git diff b6628b0e..HEAD -- App Sources` at 479af926 (`PostureSwitch.swift` +100/−10,
`PostureSwitchTests.swift` +394/−10; zero `Sources/`, verified by `--stat`). Anchor: the record
`vx-99-pro-castle-apple-wrap.md` whole + `vx-99-ladder-round1.md`. Canon read: CLAUDE.md, the three
auto-loaded docs, SyncSpec whole, `pre-13x-postures-design.md` §1 (decisions 1–35), §3.4, §3.5, §3.6, §4,
§5, §7. Code read: `PostureSwitch.swift` whole; `PostureSwitchModel.swift` (door, flows, resume);
`ProtectionController.reconcileFollow`; `StoreProtection` (`Posture.derive`, `PostureReading`);
`CorpusRotation.prepare`/`begin`/`complete`/`RotationMarker`; the Mac + phone ceremony faces
(`ProtectionPane.swift`, `MobilePostureSheets.swift`) and their copy (`PostureCopy`, `KeyDoorCopy`); the
test harness (`makeWorld`, `leaves(for:)`, `makeController`) and every new/changed test. No "Review foci"
section exists in the record. Mac suites NOT re-run (stage-gated; no claim held); the diff touches no
`Sources/`, so the core suite cannot have moved.

## Findings (severity-ranked)

**Tally.** Introduced by this diff: 0 BLOCKER · 0 MAJOR · 2 MINOR (finding 2; finding 3's S1 arm) · 2 NIT.
Pre-existing, surfaced while tracing the roads this unit pins: 1 MAJOR (finding 1) · 2 MINOR (findings 4, 5;
finding 3's S2 arm). The headline fix and both round-1 fixes are sound (clean bill). Each pre-existing item is
labeled so the orchestrator can rule in-unit vs. ticket; finding 5's fix is `Sync/` (Fable's).

**[MAJOR · PRE-EXISTING — outside the diff, on the road this unit pins] · `ProtectionPane.swift:1263–1267`,
`:1253–1256`, `:1120–1135`; `MobilePostureSheets.swift:86`, `:175`; `PostureSwitchModel.swift:214–227`,
`:289–295`, `:484`, `:554–556`; `PostureCopy.swift:866–876` · The ceremony's faces don't read the road:
`.resume(marker)` mode is hard-wired to the CASTLE ceremony, so a resumed Replace All Keys speaks a false
security claim and, on a restart, runs the wrong act.**
Evidence (each arm traced):
- (i) THE DONE. Both faces render `model.mode == .replaceKeys ? replaceKeysDone : castleDoneBody(outcome)`.
  The resume door opens `openSwitch(.resume(pending))` (`ProtectionPane.swift:321`, `VariorumApp.swift:302`,
  the phone's twins), so a resumed RAK is never `.replaceKeys` → `castleDoneBody` → (no follow flag,
  `.written` snapshot) `enteredCastleDone`: *"You're in Castle. Your library has a new key that your Apple
  account never held. … This Mac asks for Touch ID from now on"*. Pin (b)'s own STANDARD control is exactly
  this road: a Standard RAK crashed mid-walk (`setCrashNextReencrypt` — a network error during an
  18k-row walk is ordinary), resumed → the new key file carries L′ under A, the vault keeps M′ under A,
  custody `.auto`. Every clause of the Done is false, on the security act, in decision 30's exact case
  ("every surface that names the case says so").
- (ii) THE RUNNING TITLE (`ProtectionPane.swift:1254–1256`) reads `enterCastleTitle` for every `.resume`.
- (iii) THE RESTART RUNS THE CASTLE ACT. A RAK whose vault write never landed (`begin` throws a URLError →
  the `.vaultWrite` marker stays; the "Finish replacing keys" door renders from `pending.entersCastle`) →
  `resume` → `restartRequired` → `phase = .explain` (`:554–556`). The face's `case .explain where
  model.mode == .replaceKeys` misses, so the CASTLE explain renders (`:1120`); `continueFromExplain`
  (`:214–227`) takes the non-RAK branch → words → `mirrorWords` (`:289–295`) → `.floor` →
  `enterCastle(…)` → `runner.enterCastle`. A tap on "Finish replacing keys" after a dropped connection
  leads into entering Castle (consent screens intervene, but the act is not the one she chose).
- (iv) `.replaceKeys` mode ignores a FOLLOW outcome: `replaceKeys()` hard-codes `.done(insuranceOff: false,
  hasOffer: false)` (`:484`) and the face speaks `replaceKeysDone`. When the RAK's CAS refuse became the
  follow into another device's switch (`PostureSwitch.swift:599–622`, `followedAnotherDevicesSwitch`), the
  ledger-61 sentence ("the twelve words shown here are NOT your account's") is lost — after *Generate New
  Ones* she keeps paper that opens nothing — and a follow INTO Castle turns the insurance off and lists an
  offer, both unsaid.
Pins (red on today's code): `ProtectionCopy.castleDoneBody(Outcome(entersCastle: false, …, freshSnapshot:
.written(url)))` must not be `enteredCastleDone` (today it is); a model pin — a Standard RAK killed at
`.beforeVaultWrite`, `PostureSwitchModel(mode: .resume(marker))`, `start()` → `.explain` →
`continueFromExplain` → the words → expect the RAK flow (`.authorize`), never `.floor` (today `.floor`).
Fix: ONE shared Done/flow selector over (the marker's act, the outcome's road) in the brain, used by both
faces — the act from `marker.entersCastle` for `.resume`; the sentence from `followedAnotherDevicesSwitch`,
then `outcome.entersCastle`, then the RAK Done; and the restart re-enters the marker's own ceremony. Not this
unit's diff; the orchestrator's call whether it rides VX-99 or a ticket (copy is 13s-adjacent).

**[MINOR · diff-introduced (round 1's MAJOR fix)] · `PostureSwitchModel.swift:134` (`accountPostureIsStandard
{ controller.posture == .standard }`), rendered at `ProtectionPane.swift:1107–1109` and
`MobilePostureSheets.swift:48` · The decision-30 addendum still reads the posture while the act now reads
the vault — under a stale reading the RAK screen and the RAK disagree.**
Evidence: round 1 moved the door (`appleKeyReadable`, `PostureSwitch.swift:382`) and the belt
(`appleHeldCopyForStandard`, `:1212`) to the vault's word; the screen's addendum — *"In Standard this
doesn't shut out someone inside your Apple account — your Apple account holds a key to the new keys too"*
(`KeyDoorCopy.swift:90–93`) — still renders on `controller.posture`. Direction (i), the round-1 MAJOR's own
scenario: a genuinely Standard account, this device still reading Castle → `facts.appleKeyReadable == true`,
`.explain` renders WITHOUT the addendum, the runner keeps M′ under A and writes L′ under A. Before round 1 the
silence was true (the act dropped the copy — and flipped the account, the worse bug); after it, the act keeps
the copy unsaid — decision 30's "every surface that names the case says so … the Replace All Keys screen".
Direction (ii): a Castle account read as Standard → the addendum claims an Apple-held key to the new keys
that the act never writes.
Pin (red today): `makeWorld(standard: false, vaultSaysCastle: false)` (a Castle-shaped device over a Standard
vault — the harness parameter already expresses it; the controller derives Castle from the key file),
`PostureSwitchModel(mode: .replaceKeys)`, `start()` → `.explain` → `#expect(model.accountPostureIsStandard)`.
Fix: read the door's vault word (`DoorFacts` gains `vaultHasAppleHeldCopy`, or derive from
`facts?.appleKeyReadable != nil`), falling back to the posture only before the door has answered — one rule
for face, door and belt.

**[MINOR · partly diff-introduced] · `PostureSwitch.swift:1357–1358` + `:1411–1425` (and the premise comments
at `:1331–1332`, `:1353–1356`) · The resume's OWN-write arm decides the Apple copy from the vault but
`entersCastle` (custody target, insurance, the offer, retirement, the Done) from the marker — the premise
"the marker's own when the write was ours" fails whenever another device acts AFTER this device's write.**
Evidence — two reachable stories (each needs a second device to act while this one is crashed):
- S1 (diff-introduced falsehood): A's own Use Castle lands its vault write, crashes mid-walk (`.reencrypt`,
  `entersCastle: true`). B follows by passphrase — completing the walk (`runFollow` → `reencryptAndComplete`
  clears the previous key) — then runs Use Standard (`.leave` passes: no rotation in progress; `leaveCastle`
  re-wraps M′ under B's A). A resumes: no pickup (custody id = vault id), `byAnotherDevice` false,
  `vaultSaysCastle == false` → `appleCopy: true`, `roadEntersCastle == true` → L′ wrapped under A,
  custody → `.biometric`, insurance OFF, `listPreSwitchPairs` true (A's old file carried `apple`), Done (the
  `.resume` face) "a new key that your Apple account never held" while the new key file is Apple-openable,
  and the offer asks her to delete pre-switch backups on the premise that Castle now covers everything.
  Before the diff the key file got no Apple copy, so that clause was at least true of the file; the next
  ready's follow-into-Standard arm (`ProtectionController.swift:707`) heals the device either way.
- S2 (the custody half, pre-existing): A's own STANDARD RAK crashes mid-walk; B follows (completing), then
  Uses Castle (a second rotation, C″). A's `.reencrypt` resume sees `vaultKeyID != material.corpusKeyID`
  and takes the "write landed, custody did not" pickup (`:1359–1374`) as if it were its own follow's resume —
  silently following B's Castle rotation. The Apple copy is right (`!vaultSaysCastle` — this unit's fix);
  but custody moves by `effective(posture: leaves.posture())` (silent under an indeterminate reading → a
  Castle account with a silent L′ until decision 35's arm re-keys again), `retireOldKeyFiles` is skipped
  (the A-carrying old file stays in the live folder — the helper's own doc calls that "the exposure itself"),
  and the words rule treats them as A's own. The comment at `:1331–1332` ("A `.reencrypt` marker is never
  this case") is the falsified premise: the ceremony's `.reencrypt` marker stamps `newCorpusKeyID`
  (`:633–634`; `runFollow`'s does not, `:819`), so "stamped id ≠ the vault's id" at `.reencrypt` tells this
  story apart from the follow's own custody-pending resume.
Pin (red today, S1): the MINOR pin's two-world shape — A `enterCastle` crashed via `setCrashNextReencrypt`,
B `follow` then `leaveCastle`, A `resume` → expect a coherent road: either `!outcome.entersCastle` with no
offer, or no Apple copy — whichever the ruling picks.
Fix options (the orchestrator's; decision 8 points at (a)): (a) the road follows the account when the vault
contradicts the marker — `roadEntersCastle` from the vault whenever `vaultSaysCastle != marker.entersCastle`
on a road whose act was a switch, and extend the another-device discriminator to `.reencrypt` markers whose
stamped id ≠ the vault's; (b) refuse and hand to the follow (the notice road) when the vault contradicts the
marker; (c) record as the double-actor residual beside VX-107. Not a security regression of the Apple half
in either story.

**[MINOR · PRE-EXISTING; it bears on this unit's pin (d) and the fix pass's defense of the local-only line]
· `PostureSwitch.swift:494`, `:640–649` (`appleCopyInKeyFile = !entersCastle && leaves.posture() ==
.standard`); `PostureSwitchModel.swift:184–187` · The runner's local-only road is reached in production ONLY
by an ENROLLED library — the RAK door refuses every non-enrolled one — so the line the fix pass kept
"because a genuinely local-only library has no vault" never meets such a library, and the road it does meet
is decision 9's refusal case.**
Evidence: `start()` refuses `!facts.enrolled` with `replaceKeysNotEnrolled` (`:184–187`), and
`replaceAllKeys` has no other production caller (grep: `PostureSwitchModel.swift:475` only). So the runner's
`enrolled` (`:494` — vault, transport, signedIn, custody) can be false at run time only after the door read
it true: a session that lapses during the ceremony's screens, or a custody read that fails. Then the
security act silently degrades — steps 4–7 only: the master and corpus keys NOT rotated, the vault untouched,
the new key file written without the master-wrapped copy (`material == nil`), and the Done "Done. Your other
devices will ask for your passphrase" (they won't — nothing rotated). Decision 9: "Every key door is an
ONLINE act for an enrolled library … offline they refuse with one sentence." The Apple half: on that road
the controller's reading is `enrolled` (custody held) and may be INDETERMINATE, so `leaves.posture()` is the
custody shape — on a decision-35 mismatch device (silent custody, Castle account, the vault unread at ready)
it reads Standard and writes L′ under A on a Castle account, against `StoreProtection.swift:122–128`'s law
("key-file changes … require `determined`") — this ticket's class on its last road (a three-condition chain;
narrow). Pin (d) pins a world (no vault, no custody) the door never admits; it is a fine runner-level guard
but not evidence about the production road.
Pin (red today): `makeWorld()` → the door passes → re-arm the runner with `signedIn` false → `replaceAllKeys`
→ expect a refusal (today: `outcome.material == nil`, `reencrypted == 0`, the vault's corpus id unchanged).
Fix: the runner refuses the local-only road for an enrolled-shaped library (custody held, or a key file
recording a vault corpus id) with the offline sentence — or the model passes the door's verdict and the
runner requires it. A ticket, not this unit's letter.

**[MINOR · PRE-EXISTING — the fix's surface is `Sources/VariorumCore/Sync/` (Fable's)] ·
`PostureSwitch.swift:533` vs `CorpusRotation.swift:454`, `:472` · The ceremony decides the Apple-held copy
from its OWN fetch, but `CorpusRotation.begin` re-fetches and CASes against the revision IT read — so the
decision is not bound to the write, and a non-rotating vault write landing between the two fetches is
silently overwritten.**
Evidence: `runCeremony` fetches at `:533` and decides `appleHeld` from it (`:564–565`, now by the vault's
word); `prepare` builds a WHOLE new format from scratch (`KeyVaultFormat.create` + the previous key + the
copy only `if let appleHeldCopy`, `CorpusRotation.swift:413–429`); `begin` fetches AGAIN (`:454`), checks
only the previous key and the corpus id, and writes with `expectedRevision: fetched.revision` of ITS fetch
(`:472`). A Use Standard on another device in that window (no rotation, the corpus id unchanged — `begin`'s
guards pass) moves the revision before `begin`'s fetch, so the CAS passes and A's Castle-decided format
replaces B's consented Apple-held copy: the account silently re-enters Castle — round 1's MAJOR outcome by a
race instead of a stale reading. The window is the Argon2id derive + `prepare` + the marker write (about a
second, §3.6's measured 0.77 s per derivation); a re-wrap (change passphrase / regenerate words / the
relink's heal) is clobbered the same way, which decision 9's "the last change wins" accepts for words —
not for the account's posture (decision 8). Round 1's fix narrowed the stale window from "since the last
ready" to "since `:533`"; the doc at `:1201` ("this belt holds it") reads as if the vault in hand is the one
written over.
Pin: needs one harness seam (the emulated vault's fetch count, so B's `leaveCastle` lands between A's two
fetches); then expect A's `begin` refused, or the copy kept (red today: the vault loses B's copy).
Fix: `begin` takes the caller's `expectedRevision` (the revision the decision read), so any interleaving
write refuses the CAS and the ceremony's existing CAS-refused road re-reads — a `Sync/` API change, Fable's.

**[NIT] · cleanliness bundle**
- `PostureSwitch.swift:1201` cites "(:524)" for the ceremony's fetch — it is `:533`; code comments with line
  numbers rot (name the symbol instead).
- `PostureSwitch.swift:358–366` (`DoorFacts.appleKeyReadable`'s doc) still says "under a STANDARD posture" —
  it is now the Standard ACCOUNT (the vault's word).
- `PostureSwitch.swift:1397–1401`: the rewritten `.reencrypt` marker carries `newCorpusKeyID:
  marker.newCorpusKeyID` — on the another-device road that is the id A minted for a write that NEVER landed,
  under a field documented as "the corpus key id the vault write advances to". Harmless today (only the
  `.vaultWrite` discriminator reads it), but it is a trap for finding 3's option (a); carry
  `held.corpusKeyID`.
- The MINOR fix's stated consequence "said 'keys replaced' on a Castle account" (`:1388`, the pin's message
  at the test's `outcome.entersCastle` line) is the runner's LOG line only — a `.resume` face never says
  "keys replaced" (finding 1, arm (i)). The fix stands on its other three consequences (custody, retirement,
  the offer).
- `PostureSwitchTests.swift:3788–3789`'s comment ("the 2b world's vault is born without the Apple-held
  copy") is false since the harness change; the manual `settingAppleHeldCopy` setups at `:2168–2173`,
  `:2222–2226`, `:3790–3793` now re-wrap a copy the harness already landed (harmless; say so or drop them).
- `makeWorld(vaultSaysCastle:)` is silently ignored for `sharing:` and non-enrolled worlds; a
  `precondition` or a doc line keeps a later caller from believing it set the account's shape.

**[NIT · SPECULATIVE in production] · `PostureSwitch.swift:569` → `:1101` · The key file's Apple copy is
decided as a Bool and A is READ AGAIN in `writeNewKeyFile`, without the vault-id check the belt applied at
`:1217`.** The vault's copy of M′ is under the A the belt verified; the key file's copy of L′ is under
whatever `read()` returns at step 4 (after the walk). A swap of the iCloud item mid-ceremony would split the
pair. Pinnable through the `horizonWait` leaf (it runs between the two reads). Fix: thread the verified
`AppleKey?` from `appleHeldCopyForStandard` into `writeNewKeyFile` on the ceremony road.

## Clean bill (checked, found solid)

- **The headline fix's mechanism and letter:** `writeNewKeyFile` no longer reads A on "the road does not enter
  Castle" (`:1101`); every caller decides (`appleCopy:` is required) — the ceremony's enrolled road exactly
  when its own vault write carries an Apple-held copy (`:569`), the follow from the vault just fetched (`:792`,
  behavior byte-unchanged), the resume's enrolled arm from its fresh fetch (`:1415`), entering Castle nil on
  every road. §3.4's Castle row (L′ under P, W, M only) and §7 step 5's Standard parenthesis both honored.
- **Round 1's MAJOR fix:** door twin and belt read the same word (`masterWrappedByAppleHeld != nil`, `:382`,
  `:1212`); the readable/vault-id refusals kept; the caller's `entersCastle ? nil` (`:564–565`) stays
  load-bearing because the enter-Castle road's fetched vault is the OLD Standard one; `appleKeyReadable`'s
  only consumer is the `.replaceKeys` door (`PostureSwitchModel.swift:201`). The fix's new end state (vault +
  key file Standard, custody gated) heals at the next ready — the follow-into-Standard arm fires on
  `hasAppleHeldCopy && shape == .gatedOrNone` (`ProtectionController.swift:707`).
- **Round 1's MINOR fix:** the `.reencrypt` marker construction carries all seven `RotationMarker` fields
  (`CorpusRotation.swift:158–181`) and equals `advanced(to: .reencrypt)` on every non-another-device road
  (`roadEntersCastle == entersCastle`, the follow flag == `marker.isFollow`); the later markers written by
  `rekeyCustodyAndSnapshot` carry `roadEntersCastle`, and the `.custody`/`.snapshot` arms read it back.
- **The class sweep's census re-run independently:** outside tests, `setAppleWrappedCopy` has exactly five
  callers (`PostureSwitch.swift:935`, `:1122`, `:1267`; `ProtectionController.swift:1612`;
  `StoreLaunchGate.swift:372`) plus the one envelope construction (`:1103`); every verdict matches its gate
  (row 7's `!enrolled` is decision 8's pre-sync library, its own posture by definition).
- **The harness change:** the six `vaultSaysCastle: true` opt-outs are each a deliberate mismatch or the
  different-A sibling (`makeWorld(sharing:)` mints a fresh A per world — the recorded limitation); tests that
  passed through direction (ii) inside the old harness now pass for the right reason — decision 30's presence
  pin (`:2710–2713`) proves the copy KEPT, not added. No assertion weakened.
- **Every new pin traced against the code:** (a); (b) seams 1–3 + the Standard control (seam 3 correctly pins
  the ceremony's own pre-crash write, which the `.rekeyLibrary` arm reads and never rewrites); (d) + control;
  (e); the round-1 MAJOR and MINOR pins. The V99-A…D reds the record lists match the mechanisms, including the
  `:2510` "Caught error" — the `@Test` line, from a rethrowing `#expect(try …)` once the copy was dropped.
- **Sync shape:** zero `Sources/` change; the one vault write keeps its shape (one CAS write under the old
  proof); nothing scales with corpus size; no text copied across entities; key files and custody stay local.
- **Process:** pins first and red-on-old, a named revert per piece run after it was named, commit per piece
  with LIVE STATUS, no `Co-Authored-By`/`Claude-Session` trailers, no merges or rewrites in the range,
  VX-106's greening recorded and not claimed, the double-crash residual dispositioned (VX-107).
