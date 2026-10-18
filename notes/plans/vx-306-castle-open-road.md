# VX-306 — Castle rebuild, phase 2: the open road (the headless core goes live in Debug builds, to the rules)

**Status: PLANNED — READY TO KICK OFF (VX-378 merged 2026-10-18). Written 2026-10-17 at VX-378's closeout, to `notes/CastleRules.md` (the contract) and VX-306's
2026-10-16 re-scoping comment (the migration is GONE — rule 26). Kicks off at the author's word with
`/architect-phase vx-306` (recommended: the phase is face- and design-heavy, and her sittings rule the words).**

- **The contract:** `notes/CastleRules.md` — read in full before anything. **The walk:** `notes/plans/vx-266/castle-lifecycle.html`
  (rendered from the lifecycle fixture — the facts the faces must agree with). **The headless core this phase wires:**
  `Sources/VariorumCore/Protection/` as VX-378 left it (`notes/plans/vx-378-castle-simplified.md` §8's unit records,
  the U2 record's "What the faces will read changed shape" paragraph FIRST — it lists every type a face consumes).
- **The old design** `notes/plans/vx-266-castle-backups-prelaunch.md` is superseded where the rules differ; its §3.10
  (Touch ID, VX-310's rule as her words) and the Apple facts (`notes/plans/vx-266/second-opinion-apple-facts.md`) stay
  live.
- **Tickets:** VX-306 (this phase; project "Castle & backups before launch"); members VX-310 (the lobby's Touch ID
  button and line — the lobby half; the re-arm half is VX-308's); VX-379 rides as the standing acceptance item (the
  guide and settings copy to the rules — the Start Here chapter FIRST); VX-301's "moves" have nothing left to do (its
  body says so).

> **KICKOFF MESSAGE** (paste-ready; the orchestrator's brief for each implementer session is this plan's unit section
> plus the standing rules below).
>
> **STEP 0 — SEAT THE PHASE (the merge is DONE: her word 2026-10-18, PR #171, merge commit `aeabdd75b`; the VX-378 session
> retired the VX-305/VX-378 in-flight row, removed `~/dev/variorum-vx-305` and the branch, took the board snapshot, moved
> VX-378/VX-305/VX-345 to Done and noted the Sync/-or-custody slot's hand-over in the stage log).** From `~/dev/variorum`
> on `main`: `git pull`; `git worktree add -b vx-306-castle-open-road ~/dev/variorum-vx-306 origin/main`, push the branch;
> add this phase's in-flight row (ticket · branch · worktree · machine — it HOLDS the one Sync/-or-custody slot) in one
> atomic pull → edit → commit → push; Linear: VX-306 → In Progress. Announce yourself to the stage coordinator
> (oct18coordinator at the time of writing) before the first `xcodebuild test` or dev-store walk.
>
> You are building **the open road**: the first time the rebuilt protection core touches the app. Nothing here changes
> a rule; where a face would need one, STOP and bring it to the author (the VX-378 stop rule, carried forward).
>
> **Read first, yourself, in full, in this order:** `CLAUDE.md` and its canon; `notes/SessionResiliencyProtocol.md`;
> **`notes/CastleRules.md`**; `notes/plans/vx-266/castle-lifecycle.html` (in a browser); this plan whole; the VX-378
> plan's §8 U2 RECORD ("What the faces will read changed shape"), the U4 RESUMPTION RECORD's piece 3 (the notice and
> the offer as built) and §5 (the hand-forwards); `notes/SyncSpec.md` §3 (custody — this phase touches keychain code,
> so it HOLDS the one Sync/-or-custody slot and its ladder is Fable's); the vx-266 design §3.10; the current open road
> in `App/Variorum/Shared/` — `AppBootstrap.swift`, `StoreLockView.swift` (`App/Variorum/Variorum/`),
> `ProtectionController.swift`, `StoreProtection.swift`, `EncryptionKeychain.swift`, `AppleKeyCustody.swift`,
> `LibraryOpenModel.swift` + `LibraryOpenCopy.swift` (13x's Open Library), `RestoreHoldModel.swift`,
> `PostureCopy.swift`, `KeyDoorCopy.swift`; Settings ▸ Data Safety (`Features/Settings/DataSafety*.swift`).
>
> **The one law of this phase:** the new road is ON IN DEBUG BUILDS ONLY (her ruling: "dormant in release is what I
> meant" — the core compiles in both configurations, the WIRING is Debug-gated), so it reaches only the fenced dev
> store and byte-copies of her stores; today's road stays alive on `main` because Release still runs it. A check proves
> a Release build still runs today's road (gate item). The dev store, once opened by this build, is the new system's —
> tell the stage coordinator (`notes/plans/…coordinator…` / the in-flight row) and merge `main` before any walk.
>
> **Hard limits:** no `Sync/` line (the server's `key_vault` change is VX-307's §12 lockstep); no migration or
> pre-design-store handling (rule 26 — a store with no protection record REFUSES with `recordMissing`, no face string:
> "no refusal string either", her word); no new dependency; nothing from the rules' considered-and-not-pursued list;
> no face that contradicts a rule or the lifecycle page's facts. Every change to a keychain or custody path is red-on-
> old pinned. Every Mac-app change ends at the dev store under a HELD `Tools/stage` claim; `xcodebuild test` only under
> the stage; the real store is never touched (`/Applications` refresh: NONE this phase — Debug-only).
>
> Checkpoint rules as ever (commit per piece, push after each, LIVE STATUS from the first commit, PENDING until
> verified, foreground waits, no trailers, `Part of VX-306`). PROVISIONAL rule as ever (options · the most
> rule-defensible built · QUESTIONS). One Sonnet lookup at most, external facts only.

---

## 1. What this phase is, and how it closes

**The headless core goes live in the Debug app, on the OPEN road only:** the lobby decides nothing before unlock and
takes the executor's roads; the four remembered things, the per-key custody items, the protection record and key file
format 3 are written by the app's own doors; the two copy doors get faces; the honest refusals and the notice get
faces; rule 1's redundancy restore runs when the live key file is absent; VX-310's Touch ID button follows the real
road; the phone builds and opens (the Debug road on the phone's fenced store). **No act that changes posture or keys
ships here** — Use Castle / Use Standard / the follows / Replace All Keys are VX-307's; the key doors and the account
doors VX-308's; Send Library, the plaintext export and the copies list VX-309's. Creating a library (rule 2: words at
birth, the once-shown words) IS this phase's, because the open road begins there.

**Closes on USE-shaped evidence (CLAUDE.md's sizing guidance):** the dev store walked through the lifecycle's stages
1–5, 9, 10 (the Standard half; Castle's entries are VX-307's) and 13–14 under a held stage claim, screenshots recorded;
the two doors used on a real backup and on an AirDropped copy; the notice and the offer seen on a hand-swapped file;
byte-copies of her stores opened read-only through Look inside (behind the A1 rail); the Release-still-runs-today's-road
check; the phone opens its fenced store; **the words the app says agree with the rules as built** (VX-379's standing
item — the Start Here chapter and every face this phase touches, checked sentence by sentence against
`CastleRules.md`); a Fable ladder closed (custody code — CLAUDE.md's cast rule); the scenario suite and the lifecycle
suite green in both configurations on the final tree.

**Sizing:** three acceptance units (below), one implementer session each; the orchestrator walks each under the stage
before its record closes. Outside two phase-sized units — said to the author at kickoff, as the guidance asks; the
split is by surface, each unit's walk its own evidence.

---

## 2. The units

### U1 — THE LOBBY ON ROADS (the open road, Debug-gated)

**Two obligations from VX-378's close, FIRST in this unit:** (1) the production `KeyFileStoreLeaf` implements
`catalogedKeyFiles(ofLibrary:)` — every catalogued key file of THIS library outside the live place (the real backups in
this Mac's and the shared iCloud Drive folders, Previous Libraries), filtered by the files' own `libraryID`; Castle
entry's sweep and its Apple-key retirement read it (rule 11; the gate's seed 3 — a missing conformer re-opens that
class); (2) VX-378's ladder round 3 NIT 1 — `PlanRunner.swift`'s DEBUG-guard-off resume call (`settleAct`, the
`!guards.planNamedBySectionOn` branch) gains the same `catch ActRolledBack` as the normal call (a defensive, DEBUG-only
line, deferred so VX-378's soaked tree stayed its final tree); (3) VX-378's round 4 — `U4PromiseCheckTests` gains the
promise-1 oracle arm on a synced FOLLOWED device (the round-4 report's appendix probe) and `Promises.swift`'s STATED
LIMITS L1 parenthetical widens (a lagging device may be Castle-recorded). All three = **VX-386**, this phase's FIRST
commit (no behaviour change; the protection set green is the proof).

**Her addition at VX-378's morning sitting (2026-10-18, P-VX378-O2-2 — "we're already here in this area"): STAMP THE LIBRARY ID
ON THE KEYCHAIN ITEMS.** Every custody item (silent and Touch ID) and every Apple key this Mac mints for a library carries the
library's ID as a plain attribute (the key file already says it in the clear; nothing new is revealed). Castle entry's sweep
then deletes every SILENT custody item and retires every Apple key OF THIS LIBRARY by the stamp — whatever the live key file
or the catalogue remembers — so the rollback corner rule 25's last sentence states closes on this Mac; the catalogue sweep
stays as the belt. Another library's items carry its own ID and are untouched (rule 17's Look-inside road for a Previous
Library survives); the sync-keys items stay per account. No migration (rule 26; Castle is Debug-only until VX-329). Lands
with the production keychain leaf in this unit; the scenario world's fake keychain gains the stamp first and the promise
checker's L6/rule-25 reading narrows with it; a red-on-old pin replays the gate's seed 3 WITHOUT the catalogue leaf. When it
ships, rule 25's last sentence may go at her word. Ticket: VX-390.

The Debug app's unlock reads `assess(facts)`'s `LobbyRoads` and nothing else before unlock: the typed roads (rule 4's
one sentence), the silent item and the Apple road (rule 8), the Touch ID button and line (VX-310: the button whenever a
Touch ID item for the current key exists; a quiet line when no finger is enrolled or no item; a press that is only
temporarily unusable says why and changes nothing), the vault road when signed in. **The facts gatherer** — the app's
`ProtectionFacts` builder from the real keychain, the real catalog, the real memory item (the world's `facts(_:)` is
the shape to mirror; the N5 hand-forward: `LobbyRoads.typed` must include rule 1's keychain mirror and the catalogued
pairs' key files as typed roads, or the face shows a stray's locks in exactly the state the offer exists for). **The
open:** `unlock` through the executor; a library with no record refuses (`recordMissing`, no string); rule 8's
ask-and-re-make path when a quiet road failed (use another quiet road, re-mint the Apple item silently, ask only when
none remains — the rule-3 `.askPassphrase(.quietRoadFailed)` fact surfaces at that launch); creating a library through
`createLibrary(passphrase:)` with the words shown ONCE ("write these down now" — the exact card is VX-379's text, hers).
Evidence: the walk of stages 1–3 and 5 on the dev store; pins on the facts gatherer (each fact from a planted keychain
state — the throwaway dev scope only; the `KeychainTestTripwire` keeps tests off the real scope); the Release check.

### U2 — THE HONEST FACES: the notice, the offer, rule 27, rule 1's restore

The notice (rule 21; her two strings are the model's constants — `U4NoticeTests.herWordsAreTheModelsValues` — the face
shows them ONCE, then the library opens); the key-file offer naming its source ("This Mac's keychain holds a copy that
does. Use it?" / "The backup from <date> holds a key file that does. Use it?"; written only at her yes); rule 27's
refusal naming the places it looked and the account road; rule 1's mirror restore when the live key file is simply
absent (one quiet repair, said in a receipt); the rule-3 reminder's two model-side moments as a calm ask
(`CalmAsks`' idiom — before the first backup; after a quiet road failed; the launch-counted schedule is a LOCAL
counter beside them, `reminderDismissals` recorded through the op). Evidence: the walk of stages 13–14 on the dev
store (a hand-swapped older file → the notice; a wrong key file beside the library → the offer; everything gone →
rule 27); pins per face-state from planted facts.

### U3 — THE TWO DOORS: Look inside / Make this my library (+ the phone opens)

Look inside (read-only; the executor's `lookInside`; the face is a window that says it is a copy and writes nothing —
closing forgets) and Make this my library (one confirmed door; the executor's `makeThisMyLibrary`; the confirm says
"a new library, in <posture>, under your current pair; your current library steps aside into Previous Libraries";
the Restore from Backup button in Settings ▸ Data Safety IS this door — 13x's landing/adoption road retires behind it,
the restore HOLD kept as the sync gate it is), on a catalogued copy (a backup pair, a Previous Library) and on a picked
folder that is NOT catalogued (an AirDropped library — filed first, as the lifecycle's stage 10 does; T-5's empty-slot
landing and T-8's plaintext-export-in stay VX-309's unless small enough here — the orchestrator rules at kickoff).
The phone: the Debug road builds and opens the phone's fenced store (no faces beyond the lobby on the phone this
phase). Evidence: the doors used on the dev store with a real backup and an AirDropped copy; a byte-copy of her real
store opened by Look inside behind the A1 rail (her credentials typed by HER — never by a session); `U2LookInsideTests`
/ `U2MakeMineTests` extended for any face-side seam; the phone's open.

---

## 3. Standing acceptance: the words (VX-379)

Every face this phase ships is checked sentence by sentence against `CastleRules.md`; the field guide's **Start Here
chapter** is rewritten FIRST (your work is encrypted · write down your twelve words · set a passphrase · the Apple
road is a convenience that works forever for most people), then the Castle/backups chapters and Settings ▸ Data
Safety's copy for the faces built here. A sentence the build makes false is a regression (P-6 applied to the words).
Her taste calls on exact strings are sitting items; the model's constants (the notice strings) are hers already.

## 4. Hand-forwards into this phase (from VX-378)

P-VX378-U3-1 (which door sets the first passphrase — the reset door's Standard road as built; the card is the face) ·
P-VX378-U1-1 (a missing memory item mints a fresh device ID — the face never mentions it) · P-VX378-O1-1 (rule 5's
reading after a Standard Replace All Keys — the lifecycle says it; no face) · the N5 lobby-roads line (§2 U1) · the
rule-21 doors on a LIVE-PLACE stray are no longer offered (her ruling: the notice instead) — the only door there is the
offer. Open for her at this phase's sittings: the exact words of the once-shown words card, the notice window, the
offer, rule 27's refusal.

## 5. Risks

The real keychain's behaviour vs the fakes (apple-facts §6, §10, §12 — synchronizable items, biometry ACLs, the login
password's reach): every custody path pinned on the throwaway dev scope; the `KeychainTestTripwire`. 13x's Open Library
retiring behind Make this my library: the restore HOLD's sync gate must survive (the hold marker beside the store; the
Resume Sync press). The dev store's one-way door: a Debug build from a branch cut before this merge cannot open a dev
store this build has written — coordinators told.

## 6. LIVE STATUS

- U1 — the lobby on roads: not started.
- U2 — the honest faces: not started.
- U3 — the two doors; the phone opens: not started.
- The ladder (Fable — custody code): not started.
- Closeout: the words checked (VX-379's first pass); canon: AppSpec §12's LIBRARY PORTABILITY line (the doors replace
  13x's landing wording); the handoff; VX-307's plan written to the rules (the crossings' faces; the `key_vault`
  lockstep — the mirror deploy ONLY at her explicit go).
