# Phase 13p-fix — the macOS data-protection keychain asymmetry

**STATUS: OPEN — opened 2026-08-30 by the author's word, minutes after
the 13p signing gap closed and unmasked this.** Her instruction,
verbatim: *"go ahead and fix it now. however, let's do /architect-phase
and call this a 13p-fix or something like that - if the change isn't
complex, do an Opus cold review at the end, ensure the work goes into
the appropriate plan files, follow normal phase discipline. Even when
fixes are found off the cuff it's important that they're recorded and
handled."*

---

## KICKOFF (self-contained — a fresh session starts here)

**Read first:** this file in full, `CLAUDE.md`, and the FINDING below.
The parent phase's record is `notes/plans/phase-13p-note-protection.md`
(its POST-CLOSEOUT section carries the signing change this phase
follows). Nothing in `Sources/VariorumCore/Sync/` is touched, so the
standing Fable rider does not apply.

**The one-sentence goal:** on macOS an ACL'd or synchronizable keychain
write lands in the DATA-PROTECTION keychain while every read in this
codebase searches the FILE-BASED one — make the three DP-resident item
families read, write, and delete in the SAME keychain.

**Do first:** read the FINDING's measurement; it is the whole design.

**Verify:** the behavioural pin (a gated write through production code
must be findable by production's own probe) fails on the pre-fix tree
and passes after; the Mac suite holds at its count.

---

## THE FINDING (traced and MEASURED, 2026-08-30 — this is the design)

**Mechanism.** On macOS, `SecItemAdd` carrying `kSecAttrAccessControl`
(a biometry ACL) or `kSecAttrSynchronizable` is routed to the
**data-protection keychain**; a `SecItemCopyMatching` that does NOT
pass `kSecUseDataProtectionKeychain: true` searches the **file-based**
keychain. `kSecUseDataProtectionKeychain` appears **nowhere** in this
codebase. So the gated and escrow items write to one keychain and are
read from another.

**Measured in the signed test host** (throwaway service, attributes
only, non-interactive — never prompts):

```
ADD  (production shape: ACL, no DP flag):            0       success
READ without DP flag (= gatedItemExists()'s shape): -25300   errSecItemNotFound
READ with    DP flag:                               -25308   errSecInteractionNotAllowed
```

The item is THERE; production simply looks in the other keychain.

**Why it was invisible until today.** Before the 13p signing gap
closed, every ACL'd write failed at `errSecMissingEntitlement`
(-34018), so the gated paths never once executed successfully on the
Mac and the asymmetry could not bite. The signing change did not break
anything that worked — it unmasked a latent defect that had never been
reachable. **iOS is unaffected**: it has only the data-protection
keychain, so reads and writes agree there. This is macOS-only.

**The consequence class, and it is data-access-shaped.** Both gated
paths delete their plain copy immediately after a "successful" gated
write:

- `DeviceKeyStore.setBiometricGate(true, …)` → `saveGated` succeeds →
  `deletePlainItem()` → on the next read `gatedItemExists()` is false
  and the plain item is gone ⇒ **the device silently de-enrolls from
  E2EE** and sync refuses until a passphrase re-enrollment.
- The 13p at-open Biometric mode → `StoreKeyGuard.saveGated` succeeds →
  `StoreKeyCustody.deviceKeychainRemove(scope:)` deletes the Auto item
  (*"a gate whose key still releases silently is theater"*) ⇒ **no
  Keychain road opens the store**; only the passphrase or recovery
  phrase does.
- `saveEscrow` (synchronizable) vs `loadEscrow` — same asymmetry: the
  escrow copy can never be read back.

**THE AUTHOR HIT BOTH, IN HER OWN HANDS, 2026-08-30**, and her report
is the confirming trace (verbatim): *"i tried opening variorum and the
touchid didn't work, even though i enrolled it, and then i entered my
passphrase, and then i had to enter it again to get sync to start
working."* Keychain state confirmed it exactly: `store-key/Variorum`
**gone** (only `Variorum-dev` left) and `e2ee-keys` **gone**, the
latter restored by her passphrase re-enrollment. No data was lost —
both secrets were verified before the signing change, and the
passphrase road is designed as exactly this fallback.

**Verification-gap note, recorded because it is the lesson.** The
signing work proved the ACL'd write LANDS (`SecItemAdd ==
errSecSuccess`) and stopped there. A feature that writes to one
keychain and reads from another passes a write-only proof and is still
broken. **Rule taken from it: a custody pin asserts the ROUND TRIP —
write, then find it through the production read path — never the write
alone.**

---

## THE FIX (design, settled by the measurement)

Exactly **three** private query builders own every DP-resident site
(verified by grep; no other `kSecAttrAccessControl` /
`kSecAttrSynchronizable` sites exist in production code):

| builder | family | callers |
|---|---|---|
| `EncryptionKeychain.swift:397` `gatedBaseQuery()` | 14b CF-12 gated device keys | clear · deleteGatedItem · gatedItemExists · saveGated · unlockGatedItem |
| `StoreKeyGuard.swift:234` `gatedQuery(scope:)` | 13p Biometric-mode store key | gatedItemExists · saveGated · deleteGated · unlockGated |
| `StoreKeyGuard.swift:280` `escrowQuery(storeID:)` | 13p iCloud escrow | loadEscrow · saveEscrow(+update) · deleteEscrow |

Each family funnels through ONE builder, so the flag lands in three
places and every add/read/delete/probe inherits it.

**What must NOT move.** The PLAIN items stay file-based: the store key
(`store-key/<scope>`), E2EE custody (`e2ee-keys/device-keys`), and the
auth tokens. They exist today in the file-based keychain; flagging them
would strand real data — including the key to her library.

**Orphan sweep, not migration code.** Her Mac carries gated items
written during today's broken window; once reads find them,
`isBiometricGateOn()` would read TRUE against stale material. That
state existed only on one machine for ~3 hours, so it is swept as an
environment act and recorded — shipping permanent migration code for a
state no other install can have would be cruft.

---

## LEDGER

| # | item | status |
|---|---|---|
| 1 | The DP flag on the three query builders | **DONE** |
| 2 | Behavioural round-trip pin (red-on-old, revert-verified) | **DONE** |
| 3 | `Phase13pKeychainFactTests.deleteProbe` cannot delete what it creates (same asymmetry — it left ACL'd litter on every run) | **DONE** |
| 4 | Sweep the author's orphaned gated items | **REFRAMED — see the batch record; impossible from tests BY DESIGN, and that is the right answer** |
| 5 | Opus cold review (her instruction), ladder per CLAUDE.md | in flight |
| 6 | Closeout: master plan row + pointer + closeout paragraph; KnownIssues; QUESTIONS; handoff | pending |
| 7 | `CanvasDragTrackingTests.theResizeGripFollowsThePointerToo` is LOAD-FLAKY (found by this phase's full run; not caused by it) | **recorded — KnownIssues row, owner 12** |

---

## CAST — and one recorded deviation

**Reviewer: OPUS, fresh, cold** — the author's explicit instruction.
Ladder per CLAUDE.md (fresh reviewer per round, `REVIEW_PROMPT.md`
verbatim, zero framing).

**DEVIATION, recorded with reasons per this skill's rule:** the batch
is implemented by the ARCHITECT rather than a fresh implementer
session. Grounds: the diff is three lines of query construction plus
pins; the mechanism was traced and MEASURED by the architect in-session
with a probe whose output is quoted above; a self-contained implementer
brief would necessarily be longer than the change it describes, and
re-deriving a measured platform fact through a briefing seam is where
this class of bug hides. The isolation that carries quality here is the
COLD REVIEW, which is preserved in full and strengthened to Opus at the
author's word. Recorded rather than silent, exactly as the mandate
requires.

**No `Sources/VariorumCore/Sync/` lines.** No schema, no SyncSpec §12
lockstep event; the marker stays 7.

---

## BINDING PRINCIPLES (the 13b constitution, copied verbatim as this skill requires)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks, the board/view-model invariant soak, the
  registry walk (P-1), the per-batch scripted screenshot walkthrough.
  Red-on-old stays absolute: no bug-class fix without a pin that fails on
  the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**P-7 is this phase's spine**, and the verification-gap note above
sharpens it: the pin must be a ROUND TRIP.

---

## ENVIRONMENT TRAPS (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the test host matches mid-run); treat real-store
instances by STORE, not path — NEVER quit or kill one; no Release
builds or `/Applications` refreshes while one lives. Mac tests run from
`App/Variorum/`, suite-level `-only-testing` only, and the "Test run
with N tests" line is the confirmation. NEVER add a custom build
configuration (anything not named exactly "Debug" builds SPM deps
RELEASE and strips VariorumCore's DEBUG-gated oracles). Backups are
WAL-safe with UTC names, ALWAYS before touching the real store (the A1
rail). Never `git checkout` over uncommitted work.

**This phase's own trap:** every keychain-touching test MUST use a
throwaway service or a throwaway scope. `StoreKeyGuard`'s gated item
takes a `scope:` parameter and is safely testable;
`E2EEKeychainStorage`'s gated item has a FIXED account
(`device-keys-biometric`) and therefore **must never be exercised
against the real Keychain from a test** — it would write over the
author's live custody. Pins for that family go through the shared
query shape, never the fixed-account door.


---

## BATCH RECORD — the one batch (architect-implemented, 2026-08-30)

**The change, whole:** `kSecUseDataProtectionKeychain: true` added to the
three private query builders that own every DP-resident site
(`EncryptionKeychain.gatedBaseQuery`, `StoreKeyGuard.gatedQuery`,
`StoreKeyGuard.escrowQuery`), each carrying the measurement in a comment
so the reason cannot be lost. Every add / read / delete / probe in those
families funnels through its builder, so they can no longer disagree.
The PLAIN items were deliberately left file-based.

**Ledger 2 — the pin, and the discipline it enforces.** Two tests join
`Phase13pKeychainFactTests`:

- `anACLdAddIsInvisibleToAReadThatDoesNotAskForTheDataProtectionKeychain`
  pins the PLATFORM FACT (add 0 · read-without -25300 · read-with
  -25308) so the reason for the flag survives its author.
- `theGatedStoreKeyIsFoundByProductionsOwnProbeAfterProductionWritesIt`
  is the RED-ON-OLD pin — a ROUND TRIP through production code:
  `StoreKeyGuardKeychain.saveGated` then
  `StoreKeyGuardKeychain.gatedItemExists`.

**Behavioural revert performed, not asserted:** the flag was stripped
from all three builders (a copy-aside restore, never `git checkout` over
uncommitted work), the suite run, and the round-trip pin FAILED at
`gatedItemExists` — with the platform-fact pin still passing, which is
correct: it is a fact about the platform, true on both trees. The fix was
restored and all five pass. Safety by construction: the pin uses a
throwaway `scope:` and a ThisDeviceOnly item, so it never touches real
custody and never writes a synchronizable byte into her iCloud Keychain.

**Deliberately NOT pinned behaviourally, with the reason:** the ESCROW
family. Its item is `kSecAttrSynchronizable`, so any real round-trip pin
would push test bytes into the author's iCloud Keychain — the 13p suite's
own standing prohibition. Its fix rides the same one-builder funnel as
the pinned family. The E2EE gated family is likewise unpinned at its own
door: its account is FIXED (`device-keys-biometric`), so a test write
would land on her live custody. Recorded as an accepted, reasoned gap
rather than papered over.

**Ledger 4 — the orphan sweep, REFRAMED by a finding.** The intent was to
sweep the gated items the broken window left on her Mac. It cannot be
done from a test, and the reason is the dev fence working exactly as
designed: **the data-protection keychain partitions by ACCESS GROUP**,
*[removed for publication]*
*[removed for publication]*
inventory returned empty from the test host for that reason alone — it is
structurally blind to them, which is precisely the isolation the
per-config group was chosen for at the signing change.

*Consequence for the author, to carry into the handoff:* those orphans
are reachable only through the product's own doors, and once the FIXED
build is installed they become visible to it. Concretely — her Mac
carries a gated E2EE item from the toggle that started this, alongside
the plain item her passphrase re-enrollment restored, so
`isBiometricGateOn()` will read TRUE and sync will ask for Touch ID.
**With the fix that will WORK** (the gated item holds real material), and
turning the toggle OFF cleans the state through the product's own door —
which also exercises the fix. Shipping migration code for a state that
existed on one machine for three hours would be cruft; the door is the
road.

**Ledger 7 — a flake found, not caused.** The full run failed
`CanvasDragTrackingTests.theResizeGripFollowsThePointerToo` (mid-drag
read `(24,16)` of a `(60,40)` pointer drag). This phase's diff is three
lines of keychain query construction and cannot reach canvas geometry.
Isolated re-runs: **3/3 green**. It is a pointer-drag simulation whose
verdict depends on machine load — the same family as the standing
latency-pin row, and it gets its own KnownIssues row at owner 12 rather
than being waved off as "probably fine".

**Counts: Mac 1845 tests / 312 suites** (1843 + the two new pins), green
but for the load-flake above. **No `Sources/VariorumCore/Sync/` lines.
No schema. No lockstep — marker stays 7.**
