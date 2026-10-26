# VM-8 — ladder round 1 (cold review, Opus)

**Reviewer:** a fresh Opus cold reviewer, `notes/REVIEW_PROMPT.md` verbatim, zero implementation context. **Diff:**
`git diff main...HEAD` on `vm-8-protection-recovery-faces` (tip `5d74548b0`). **Anchor:** `notes/plans/vm-8-castle-catchup.md`
(no "Review foci" section exists in it or in `notes/handoffs/vm-8-kickoff.md`).

**Scope check (first, as the brief asks):** the diff touches NO `Sources/` line (none under `Sources/VariorumCore/Sync/`),
no editor seam, no custody or keychain code (the four `Shared/Protection/` files changed are words and pure faces:
`ProtectionWords` phone arms, `RoadAccountDoorOpen.saysRuleTwelve`, `RoadDoorOpen.saysRuleTwelve` + one phone-nil
sentence, `RoadKeyDoorFaces.pairGate`), and changes no default's meaning. Her kickoff names an Opus reviewer for this
run. No re-spawn as `fable-reviewer` is owed.

*[removed for publication]*
down):** the tip's phone target built from the worktree (`build-for-testing` EXIT 0), then the run's ten new suites plus
`MobileNoRedirectSweepTests` and `MobileCopyRegisterSweepTests`: `✔ Test run with 35 tests in 12 suites passed after
60.129 seconds` (0 skipped; `MobileProtectionRoadTests` not re-run). And ONE scratch probe — a copy of the tip made by
`git archive` into my scratchpad (never the worktree, never committed) with one extra hosted test that mounts the real
`MobileProtectionScreen` over hand-made faces and prints what it says (results quoted in MAJOR-1 / MINOR-1). No revert was
re-run; the record's red-on-old results are taken from its own logged runs.

## Findings (severity-ranked)

### MAJOR-1 · `MobileProtectionScreen.swift:171` + `MobileProtectionDoors.swift:225-236, 391-421, 511-524` · the held rule-12 arms leave sentences on the phone's screen that send her to roads the phone doesn't render

**What's wrong.** F-U1-1 (A) / F-U2-G hide every arm whose confirm says her rule-12 sentence (the follow OUT of Castle,
the join and Move that leave Castle, Use Standard). The ruling covers the DOORS ("nothing in their place — the phone had
no road there before"). It doesn't cover the OTHER sentences this run now renders, which point at those same doors. Two
states reach it:

1. **The follow out of Castle is owed** (her account left Castle on a Mac; this iPhone's library is still in Castle).
   `Assess.acts` (`Sources/VariorumCore/Protection/Assess/Assess.swift:449-452`) owes `.follow(.intoStandard, …)`.
   `Assess.doors` then refuses with `.followOwed` every key door (`:598`), Use Castle and Replace All Keys (the `gate()`
   at `:561-566` runs before the wrong-mode check) and Stop syncing here (`:615`). The shared derives turn each into
   `ProtectionWords.doorRefusedFollowOwed`, "Your account changed on another device. Follow it first."
   (`RoadKeyDoorFaces.swift:154-155`, `RoadCrossingFaces.refusalSentence`, `RoadAccountFaces.swift:304-305`). Because
   `pairOwed == nil`, `pairGate` stays false. The one door that sentence points at, `followNow`, has
   `words: [.ruleFive]` (`Assess.swift:643-646`), so `saysRuleTwelve` is true and the phone renders nothing for it
   (`MobileProtectionScreen.swift:171`). Its notice ("Your account left Castle …") goes too. Nothing on the app road
   performs the follow out by itself: the only automatic follow is the lobby's pair catch-up
   (`ProtectionOpenRoad.swift:501-503`). **Probe, the real screen over these faces:** `generic count=4 followDoor=false`.
   The four are the passphrase section, the words section, the crossings section and the Sync section. In that state the
   phone also can't leave the account (Stop syncing here is refused). Only "Delete the account from this iPhone" and
   Sign out remain.
2. **Another account is signed in, and Move would leave Castle** (a Castle library, the signed-in account in
   Standard). Move is hidden, but the situation line `accountOtherAccountLine` still says "This library syncs with a
   different account. Sign out, or move this library to the account that's signed in."
   (`MobileProtectionScreen.swift:153-156`). **Probe:** `line=true move=false`. The existing pin
   `theRuleTwelveArmsRenderNothing` mounts exactly this state and asserts only that Move is absent, so it doesn't catch
   the line.

This is the no-redirect bar (MobileSoul §4.4: "a road must exist on the phone, even a modest one, except where she has
ruled the exclusion"). It is also P-2's sentence-level twin, which the orchestrator itself invoked at F-U1-2 (b): "a
sentence naming a nonexistent road is the no-redirect doctrine's exact red flag". Her exclusion isn't ruled; F-PH-2 is
open. The state is reachable by one press on any Mac of the account (Use Standard…). It is new with this run: before
VM-8 the phone had no screen to say it.

**Red-on-old pin (red on this tip, green after any fix).** A hosted `MobileProtectionScreen` over: the key doors refused
with `doorRefusedFollowOwed`; Castle crossings with Use Castle and Replace All Keys refused the same way; the Sync section
`.inSync` with `follow: .open(followDoor(.intoStandard, DoorSpec(… words: [.ruleFive])…))` and Stop syncing here refused.
Expect: if `ProtectionWords.followDoor` isn't visible, no label equals `doorRefusedFollowOwed`. A second case: the
`.otherAccount` + leaving-Move faces of `theRuleTwelveArmsRenderNothing`; expect the line never says "move this library"
while no Move door renders. (The probe's two prints are exactly these tests' observations.)

**Proposed fix.** The real fix is F-PH-2 — her phone wording for the follow out (and Move out), which makes the pointers
true. So: add this consequence to F-PH-2 in her bundle. Holding those arms is not just a face left out: in this state
the phone is stuck. It can't follow, can't Stop syncing here, and every key door is locked, while the screen tells her
four times to follow.

For the interim, the orchestrator arbitrates against P-2 and logs it in `notes/QUESTIONS.md`:
- **(a) Say nothing.** When the owed follow is a held arm, render the `.followOwed` refusals as nothing (the doors
  can't act). Likewise, when Move is a held arm, leave out `accountOtherAccountLine`; the situation line and Sign out…
  still stand. The screen is then silent about why the doors are gone.
- **(b) Keep the sentences as they are**, recorded as a known dead end until F-PH-2.

No new words either way.

### MINOR-1 · `MobileProtectionDoors.swift:225-236, 404-409, 511-524`; `MobileProtectionScreen.swift:165-170` · the follow-owed refusal still repeats across the screen for the follow kinds unit 2 chartered ("the follow, all three kinds")

P-VM8-9 (a) dedupes identical refusals once per SECTION and special-cases only the PAIR follow (`pairGate`). Two cases
still repeat on one screen:

- **A posture or key-replacement follow** (`.intoCastle`, `.keysReplaced`; the follow door does render). Every gated door
  says the same `doorRefusedFollowOwed`. **Probe (`.keysReplaced`):** `generic count=4 followDoor=true`: the passphrase
  section, the words section, the crossings section and Stop syncing here.
- **The pair state.** The generic sentence is still said TWICE: the crossings section, plus Stop syncing here in the
  Sync section.

This is VX-542's class (one sentence per locked door), which the kickoff said not to copy. F-U2-D's line "the crossings'
generic `doorRefusedFollowOwed` … is said once" holds only within the crossings section.
`aPairChangedElsewhereLocksTheKeyDoorsAndTheScreenSaysItOnce` counts only the pair sentence and the road.

**Not a bug against a ruling; a face call.** Proposed: bundle it beside P-VM8-9 as option (c), "once per screen". If
(c) is ruled, the pin is the probe's count `== 1` (red now).

### MINOR-2 · `MobileRoadFaces.swift:138-140` · the phone lobby's E6 line is a bug-class face fix with no pin

Unit 1 added `if let line = face.accountPassphraseLine { sentence(line) }` to the phone's standing lobby (R-529-6: "the
why and the road"). The record says why: the phone "rendered the field without its why". No phone test names
`accountPassphraseLine` or `lobbyAccountPassphraseNotTypedHere` (grep over `VariorumMobileTests/`: nothing). The only
pins are the Mac's (`LobbyVaultRoadTests.swift:327-355`, face-level). CLAUDE.md: every bug-class fix lands with a
red-on-old pin.

**Pin.** A hosted `MobileRoadLockView` over a `ProtectionLobbyModel` whose face has `accountPassphraseNotTypedHere`
(E6: synced, no passphrase lock, signed in). Expect `ProtectionWords.lobbyAccountPassphraseNotTypedHere` visible. Red on
`fd56f2279`'s `MobileRoadFaces.swift`.

### MINOR-3 · the run record, FINDINGS FOR THE ORCHESTRATOR + THE LEDGER · F-U2-F and the keystone line are found but have no owner

The phone's Castle "On this iPhone" section now stands without the idle-lock dial and Lock Library Now
(`MobileProtectionDoors.swift:587`, "(… not this unit's: F-U2-F.)"). SurfaceContracts (Doors ▸ Library protection) says
"Castle's On this Mac section carries the idle-lock dial and Lock Library Now". PL-20 shows the phone had both before
VX-329 deleted today's road. The phone's relock coordinator reads the sealed minutes, but nothing on the phone can set
them or lock now. The Mac pane's keystone line ("While Variorum is open and unlocked…") is likewise "not chartered".

The ledger names a ticket for W-U2-1's Mac twin (VX-547) and the caret suite (VM-24), but none for these two. CLAUDE.md:
deferred work is a ticket with an owner or an explicit Parked reason.

**Fix.** File them (Area: Castle & sync), or fold them into unit 3's charter at her sitting. Either way, the ledger
names the owner.

### NIT-1 · comments the build made stale

- `Shared/SyncStatusViews.swift:104, 369`: "the phone injects none (its Protection screen is VM-8's)". The phone now
  injects it (`MobileSettingsView.swift:136`).
- `Shared/Protection/ProtectionSheetPresenter.swift:3`: "the phone's protection faces present through it when they
  land".
- `RoadKeyDoorFaces.swift:3`, `RoadKeyDoorsModel.swift:3` and `ProtectionSecretCheck.swift:3`: "the phone's key doors
  are later".
- `ProtectionLobbyFace.swift:68`: "the phone renders them until VM-8 builds its…".
- `RoadAccountModel.swift:99, 431, 437, 521`: "(the phone until VM-8 …)".
- `MobileProtectionScreen.swift:5-17`: "carrying ONLY the Sync/account section" and "Unit 2 builds them". Unit 2 added
  four sections and deliberately did NOT build the rule-12 arms.
- `MobileStructuralTests.swift:1121-1123`: the `herRuleTwelve` exemption's `why` says "until VM-8". It should now say
  that VM-8 renders those faces but holds every rule-12 arm (F-U1-1 (A), F-U2-G). Re-wording the `why` widens nothing;
  the literal and its one-match cap stay. The orchestrator ruled the entry byte-untouched, so this is the orchestrator's
  call.

### NIT-2 · `MobileProtectionScreen.swift:228-235, 252-278` · a Mac sentence is reachable for a moment, and one arm is dead

The Protection row is gated only on `bootstrap?.roadStanding?.account != nil` (`MobileSettingsView.swift:81-84`), while
`services` is optional and composed later in the `.ready` arm's `.task`. In that window *Sign in…* on the screen
presents `MobileProtectionSheetNotHere` with `ProtectionWords.signInUnavailable`, "Signing in isn't available in this
window." On a phone that names a window it doesn't have. The no-redirect sweep only looks for "Mac", so it can't see
this.

The host now maps every `ProtectionSheetPresenter.Sheet` case, so `MobileProtectionSheetNotHere`'s `sentence == nil` arm
(the auto-dismiss in `onAppear`) is dead code. Either gate the row on `services != nil` too, or bundle a phone sentence;
and drop the nil arm.

### NIT-3 · `MobileProtectionScreen.swift:44-46, 92` · while words are shown, only the back button is held

The screen quotes `WordsLookModel.holdsWords`' contract ("a host keeps its other doors back meanwhile — closing them
would put the words away without the warning") but holds only the back button. While New words' look shows words, Use
Castle… and Replace All Keys… stay pressable. Both reopen the library, which tears the screen and its `@State wordsLook`
down. The words go away without the warning, and the look's `recorded()` never runs.

The impact is low: both doors make her type the twelve words, which are on screen, and the Mac pane has the same shape.
Either disable the screen's re-keying doors while `wordsLook?.holdsWords == true`, or reword the comment.

### NIT-4 · `MobileProtectionDoors.swift:246-251` · W-U2-1's fix re-reads on Cancel too

`RoadStandingModel.makeSetPassphraseSheet` calls `close()` on BOTH a set and a cancel (`ProtectionOpenFaces.swift:575-577`).
So the fix's `Task { await standing.refreshPane() }` runs the whole pane wave on every Cancel, including the vault read
when the library syncs. It's harmless and bounded (P1 holds), but the read is owed only when `wasSet`. Re-reading in the
set path, or checking `standing.passphraseIsSet`, says what it means.

### NIT-5 · tidiness

- `MobileRoadFaces.swift:114-143`: `standingLobby`'s body keeps its old 16-space indentation inside a 4-space property.
- `MobileRoadAccountSection`'s private `door/line/caption` (`MobileProtectionScreen.swift:181-206`) re-implement
  `MobileProtectionChrome`, which unit 2 introduced.
- The "hers in ink" sets differ from the Mac's crossing sheet. The phone's crossing confirm inks `castlePromise`
  (`MobileProtectionDoors.swift:610`); the Mac's `RoadCrossingSheet.swift:34` inks only `leaveSentence`. The phone
  matches the Mac's ACCOUNT sheet (`RoadAccountSheet.swift:133-134`), so the Mac crossing sheet is the odd one out. Worth
  one line in the record.
- `MobilePlantedProtection.swift` is a verbatim 300-line copy of the Mac support (I diffed it: identical). Nothing
  enforces its own "keep the two in step". A source-equality pin, or shared target membership, would stop drift.

### NIT-6 · `MobileShellView.swift:494-499` + `MobileProtectionDoors.swift:190-207` · P-VM8-8 (A)'s receipts can wait a long time

Setting `speak` drains the open's owed receipts at the shell's appear (`ProtectionOpenFaces.swift:325-327, 556-559`). So
rule 1's restore receipt ("…This iPhone's sealed copy was put back.") sits in the holder until she next opens Settings ▸
Protection in that process, possibly hours later, and then reads as the screen's latest news. Her (A)/(B) choice should
name that consequence; (B), a shell-wide line, says it at once.

Small: the comments say "ONE muted line", but the screen renders up to three (`kept = 3`).

## Clean bill (checked and found solid)

- **Scope:** zero `Sources/` lines; no `Sync/`, custody or keychain code, editor seam or default's meaning touched (the
  diffstat plus each Shared file read).
- **The Mac stays byte-identical:** `gateTouchIDLine`, `deleteHerePointer` and `firstRoundCloseNote` keep their Mac text
  verbatim behind `ProtectionRoad.isMac` (a compile-time `#if os(macOS)` value). `RoadCrossingFaces.sentence
  (.exportAPlainCopyFirst)` stays the Mac's there, and its nil drops cleanly at all three call sites (`if let`). No Mac
  test compares `RoadKeyDoorFaces` by equality, so the new `pairGate` field moves no Mac pin.
- **`pairGate`'s derive** reduces to "a PAIR follow is owed and no other account is signed in". `assess` refuses all
  three key doors `.followOwed` whenever any follow is owed (`Assess.swift:597-599`). The fact can't fire on an ordinary
  follow.
- **Rule 12 never reached on the phone:** `MobileNoRedirectSweepTests` untouched and green. Use Standard is outside
  `phoneDoors`, and the `saysRuleTwelve` belt covers both the crossing and the account faces. Verified in code and in my
  run.
- **The composition:** `attach(services:)` runs before `start()`, replacing the inline deletion hook (`attach`'s own
  first line). On a reopen, `reopenAround` → `onWillLock` → `mobileWillLock`'s `stopServices` sets `services = nil`, so
  the reopened `.task` composes fresh services and attaches them. D-B0's generation round then resolves (walk B10).
  `adoptsProtectionRequest` adopts each ask once; the counter and mark live on the controller, which outlives the
  shell.
- **The one presenter's phone host maps every `Sheet` case.** Every confirm's `cancel()` returns early while `busy`, so
  the screen's teardown under a running re-keying act can't cancel it. The sheet re-presents on the re-pushed screen
  (pinned by the walk). The signed-out road's `replace` keeps the floor (`theSignedOutRoadIsUseCastlesOwnDoor` passes).
- **F-U2-A holds:** the phone composes `backupEnabled: false`, and no phone source names `MarkdownInsurance`,
  `StoreBackup` or `ExportWriter`. Rule 11's notice can't stand on the phone.
- **Receipts reach the screen:** `speak`'s `didSet` drains the owed receipts. Act receipts, key doors' included, ride
  `roadStanding?.speak` (`AppBootstrap.swift:1027, 1079`). A re-keying act's receipt rides `receiptsForNextRoadOpen` into
  the reopened standing, which the new shell attaches.
- **W-U2-1:** the fix's mechanism matches its pin (`heard.keyDoorReads > before`). The account landing already re-reads
  the key doors (`AppBootstrap.swift:1020-1026`), so Turn on sync with a new passphrase doesn't have that gap.
- **Secrets:** every typed-words field on the phone is a `PeekableSecretField` (the six new sites pinned in
  `WordsFieldsConcealTests`). The words panel is `.privacySensitive()` with `.textSelection(.disabled)` and has no Copy
  door. No secret reaches a receipt, a log line or a capture in the diff.
- **Performance (P1):** the screen does one pane wave per appearance plus each section's own landing read. Nothing in
  the diff scales with the corpus.
- **The tests:** the run's phone suites are green at the tip (35/12, my run above). The copied test support is
  identical to the Mac's (diffed). The test-count bookkeeping is consistent: unit 2's 21/6 at `af91fea73`, plus W-U2-1's
  pin, gives 22/6, and with unit 1's six suites and the copy-register sweep that makes 41/13. The record names the
  source-text pins as guards, honestly.
- **Ledger honesty:** unit 3 is NOT STARTED, the device install is HELD for her, and the not-done lines are first in
  each LIVE STATUS.

---

## THE ORCHESTRATOR'S DISPOSITIONS (round 1, 2026-10-25 — same-model round, arbitrated against the spec; repo-first before the fix session)

- **MAJOR-1 — CONFIRMED as a real gap; the INTERIM stands as built (arbitrated), the consequence to HER (F-PH-2).**
  P-2's letter is about doors: the key doors render and deliver the operations layer's REAL refusal — that part is
  conformant. The offense is the named remedy (the follow-out door, the Move door) being held for her rule-12 wording.
  The alternatives: hiding the refusals hides the FACT that the account changed (CastleRules' posture is detect and
  SAY, never silence), and rendering the doors would invent her words. So: **the dead end stands, recorded as
  P-VM8-10** — a temporary state while F-PH-2 is hers (the road exists on the Mac that made the change; the state is
  unreachable on her own account before her sitting, and the device install is also held for it). MINOR-1's fix makes
  the state read ONCE, cleanly, instead of four times. The consequence is named in HER BUNDLE under F-PH-2 (now its
  first line) and joins the QUESTIONS bundle at the closeout. NO pin freezing either direction (the state flips at her
  sitting; a pin on a days-long interim is churn — the round file records the probe's observations as the evidence).
- **MINOR-1 — CONFIRMED, FIX (the fix session):** the follow-owed refusal (every kind, the pair included) reads ONCE
  PER SCREEN — the follow door's notice where that door renders, and still exactly once when it does not (MAJOR-1's
  state keeps its truth-teller). Locked doors keep their rows; the per-section short pointer collapses to the one
  saying. Red-on-old pin = the probe's count (4 → 1 generic; 2 → 1 pair). This is her kickoff's own line ("don't copy
  the repetition") applied whole; P-VM8-9 extends to (a-unified), in her bundle. Note the Mac's repetition on VX-542
  (the once-per-screen option, this fix as the phone's precedent).
- **MINOR-2 — CONFIRMED, FIX:** the E6 lobby line's hosted pin (`MobileRoadLockView` in the E6 state), red on
  `fd56f2279`'s copy of the file, green at the tip. A bug-class face fix without a pin violates the standing guard.
- **MINOR-3 — CONFIRMED, TICKETS (the orchestrator mints now, offered in her bundle):** F-U2-F (the phone's Castle
  On-this-iPhone section: no idle-lock dial, no Lock Library Now — the mechanism exists, the faces don't) and the
  keystone line's phone home. Both off the critical path; hers to fold into unit 3 or leave ticketed.
- **NIT-1 — FIX (comments only):** the stale comments trued (`SyncStatusViews.swift:104, 369`,
  `ProtectionSheetPresenter.swift:3`, `RoadKeyDoorFaces.swift:3`, `MobileProtectionScreen.swift:5-17`, the record's
  list). **The `herRuleTwelve` exemption reason stays BYTE-UNTOUCHED** (my standing ruling; its "until VM-8" is still
  true today — the leave faces are not built; re-worded only at the closeout if the arms still wait, under my eye).
- **NIT-2 — CONFIRMED, FIX:** the Protection row renders only when `services` exist (the sync row's "Starting…"
  pattern — P-2: a door that cannot act is not rendered); the dead nil-sentence arm removed. Hosted pin if cheap.
- **NIT-3 — RECORD-ONLY:** matches the Mac's shape; both roads re-type the words. A later polish ticket if she wants
  one — her bundle's taste flags carry it.
- **NIT-4 — RECORD-ONLY:** one extra bounded read on an explicit Cancel; not corpus-scaled, not per-keystroke. Narrowing
  it is churn tonight.
- **NIT-5 — ONE FIX + record:** add the byte-parity guard (a test diffing `MobilePlantedProtection.swift` against the
  Mac's source support file, so the 300-line copy can never drift silently). The indentation, chrome-reuse and ink
  items are record-only tidiness.
- **NIT-6 — BUNDLE + comment fix:** the hours-waiting receipt consequence is named beside her P-VM8-8 (A)/(B) choice;
  the "one muted line" comment trued to the stacking truth (up to three).

**The fix session (L1): MINOR-1, MINOR-2, NIT-1 (comments), NIT-2, NIT-5's guard, NIT-6's comment — each behavior fix
with a red-on-old pin verified by behavioral revert; zero new product words; the phone suites + the sweeps green at the
tip. Round 2 (a fresh Opus reviewer) re-reviews the fixes.**

## THE ORCHESTRATOR'S NOTE ON L1's MINOR-1 READING (2026-10-25, before round 2)

L1's shape DEVIATES from the disposition's letter — "locked doors keep their rows" became "every door the follow locks
renders nothing in its own section; the one sentence sits in the account section's follow place" (a door refused for
any OTHER reason keeps its row). Weighed against the spec: the Mac's ruled shape (R-529-3) renders the locked doors
REFUSING, naming the change — L1's phone shape is a platform divergence, but one in the decision grammar's first tool
(same brain, phone-native face), it maximally honors her "don't copy the repetition" kickoff line, and nothing is
lost (the one sentence names the change; the doors return when the follow lands). ACCEPTED PROVISIONALLY as
P-VM8-9 (a-unified)'s letter, with the shape question — locked doors hidden vs. rows kept with a short pointer —
added to HER BUNDLE beside P-VM8-9. ROUND 2 is explicitly asked to judge this reading: if hiding the key doors whole
while a follow is owed reads as a defect on the small screen (where did Change passphrase go?), say so as a finding.
