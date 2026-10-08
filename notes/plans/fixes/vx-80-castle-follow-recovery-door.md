# VX-80 — Castle follow crash window strands the library: wrong-key open has no recovery door

**Ticket:** VX-80 (urgent) · **Sibling:** VX-81 (the macOS 27.0.1 crash that triggered it) · **Branch:** `vx-80-castle-follow-recovery-door` · **Record authored:** 2026-10-07, incident day, by the diagnosing session on the Air. The fix is HERS TO SCHEDULE — after 13x merges and frees the custody slot (her word, 2026-10-07: "I'll do the real fix after 13x is merged in").

## The incident (production, the author's Air, 2026-10-07)

Her Air runs the public-road 0.9.2 install (build 5178, DMG → sign-in → full sync, installed 2026-10-06 eve). The account is in Castle; the Air was a Standard-era opener — so at open the FOLLOW notice fired (correctly: the designed repair; the *detection blindness* half of this exposure is the 13x ladder R1 BLOCKER, already fixed on `vx-6-13x-library-portability`, unmerged). Sidebar read "Synced 12:17 PM". She pressed Enter on her passphrase at ~12:18.

Timeline, all evidenced on the machine:

1. **12:18:04** — the follow ran `rekeyCustodyAndSnapshot` (PostureSwitch.swift): marker `.rekeyLibrary` written (into `sync_state` — INSIDE the store), the new key file `variorum-keys-f2839839784048cf.json` written beside the store, then `swapLibrary` → `StoreEncryptionMigration.rekey` completed its export-verify-atomic-rename (store mtime = 12:18:04; no `.rekeying` temp left). **The store file is intact under the NEW key** — the road row-count-verifies the re-keyed copy before the rename.
2. **12:18:11** — the app CRASHED: `EXC_BREAKPOINT` (Swift assertion) in **SwiftUI `BarAppearanceBridge.updatePlatformBar`**, main thread, during the root-view rebuild across the re-key's reopen. Crash report: `~/Library/Logs/DiagnosticReports/Variorum-2026-10-07-121811.ips` (the Air). That crash is VX-81's. **Her read on the variable (2026-10-07, ratified into VX-81's framing): the PRIME SUSPECT is the follow road itself — this was the first-ever production run of the second-computer follow path (the notice/dialog up while the root tears down and reopens), and these framework assertions are routinely app-triggered by chrome state churn mid-update.** The Air's macOS 27.0.1 (26A434; canon fleet 27.0/27A266a) is the SECONDARY variable; the discriminating repro is the same follow flow against a dev store on the Pro at 27.0 (stage) — the Pro holds at 27.0 until that runs, as the control environment.
3. The crash fell in the one bad window: AFTER the swap, BEFORE step 5 (`moveCustodyForSwitch`). The Keychain Auto item still holds the OLD key.
4. **Every relaunch since:** route `.open` (bound item present → the lobby arms are skipped) → open with the old key → SQLCipher **error 26 "file is not a database"** → `failedOutcome` returns `recovery: nil` → the doorless `StoreFailureView` (Retry / Reveal in Finder / Quit). Dead end.

## The mechanism (why the designed nets all miss)

- **The resume road can't run.** `RotationMarker` lives in the store's local-only `sync_state` (PostureSwitch.swift:18, `pendingMarker`) — inside the encrypted file the app can no longer open. The resume (`resume(passphrase:)`, PostureSwitch.swift:1243) is designed for exactly this window (the rekey is idempotent-by-probe) but is unreachable until the store opens.
- **The recovery lobby is scoped too narrowly.** `AppBootstrap.failedOutcome` (AppBootstrap.swift:407) offers the lobby only on `error.keyUnavailable` — the encrypted-store-with-EMPTY-custody refusal (13p ladder R1-M3's deliberate scope; its own comment: "widening this surface would be new design, not a fix"). A WRONG-key open (SQLITE_NOTADB with a key in hand) returns `recovery: nil` — even though `StoreKeyEnvelope.locate` would pick the newest sidecar (f283, most-recently-modified rule, StoreKeyEnvelope.swift:482) whose passphrase wrap holds the very key that opens the file.
- **13x does NOT cover this.** Its 84-line AppBootstrap diff is the adoption roads (Open Library… doors); its F1 BLOCKER fix (`castleKeyFileAppleOpenable`, fourth reconcile arm) closes the detection blindness, not the boot dead end. No open ticket covered it before VX-80.
- **The trigger is incidental; the window is the bug.** ANY death between the swap and the custody move (force quit, power loss, the VX-81 assertion) strands the library the same way.

## The fix shape (one acceptance unit)

In `failedOutcome` (or a sibling arm): when the open failed WITH a key in hand on a NOTADB-class error AND the newest wraps-bearing sidecar sits beside the store, offer the same lobby the empty-custody arm offers (typed secrets only). On unlock: the key opens the store → ready → `readyHousekeepingBody` → reconcile finds the pending marker → the resume completes the interrupted follow (custody finally moves, snapshot, old key file retired, marker cleared). Also verify the unlocked-key re-landing (R1-M3's `saveAuto`) does NOT fire under the Castle demanded gate (the lobby law) — the resume owns custody here.

Constraints: custody seam ⇒ Fable implements/reviews end to end (CLAUDE.md cast rule); state-transition tests for the new arm; a red-on-old pin (simulate: store under key B, custody holding key A, sidecar wrapping B ⇒ old code lands doorless `.failed`, new code offers the lobby); the two-client convergence suites untouched (no `Sync/` lines expected — this is boot routing). Zero schema; marker stays 12.

**Sequencing (hers):** after 13x merges and frees the custody slot. Estimated lift: one implementer session + a 1–2 round ladder.

## The Air's recovery (CLOSED 2026-10-07 ~12:56 — validated by her)

**Outcome:** move-aside + public-road re-sync ran clean (two designed asks: the sync unlock, then the custody confirm banner); the library returned whole (counts match pre-incident), and the reopen now ASKS via Touch ID — the Castle behavior this Mac never had. The Air is a properly-seated Castle device; the follow has nothing left to offer it, so the crash window is unreachable there in normal use. The installed binary is untouched 0.9.2 (5178) — all three defects still ship in it; fixes reach the Air by the release road (Sparkle) once VX-80/81 land.

- Safety copy of the stranded trio (store + both key files): `…/Application Support/Variorum/Backups/safety-copies/2026-10-07-castle-follow-crash/`.
- The rescue road (her go, "fix the air app now"): move `variorum.sqlite` + both `variorum-keys-*.json` into the sibling `Variorum-stranded-2026-10-07/` folder, relaunch, sign in, full re-sync — the proven Oct 6 public road. Nothing synced is lost ("Synced 12:17 PM", one minute before the follow; sync pauses for the ceremony, so nothing landed after). The stale Keychain Auto item for the old store id is inert leftover (new library = new store id = its own item); the fix session may sweep it or leave it.
- The stranded store remains openable by the fix session for a live-fire verification of the recovery arm: it is a REAL instance of the bug's exact state (store under new key, sidecar f283 wrapping it, stale custody). **Its home since 12:50 (her sweep-safety word): `~/dev/variorum-fixtures/vx-80-stranded-store-2026-10-07/` on the Air — outside the app container (safe from any container wipe / clean reinstall) and outside iCloud; a README sits inside.** Treat it read-only; copy before any drill. The redundant second copy stays in the container's `Backups/safety-copies/2026-10-07-castle-follow-crash/`.

## Evidence index

- Crash report: `~/Library/Logs/DiagnosticReports/Variorum-2026-10-07-121811.ips` (the Air)
- Stranded state (the fixture): `~/dev/variorum-fixtures/vx-80-stranded-store-2026-10-07/` (the Air) + the safety copy above
- Code anchors (main @ 59087a43): `PostureSwitch.swift:997` (`rekeyCustodyAndSnapshot` — the step order), `:1243` (`resume`), `:18` (marker home); `StoreEncryptionMigration.swift:220` (`rekey` — crash-safe, idempotent-by-probe); `AppBootstrap.swift:407` (`failedOutcome` — the empty-custody-only scope), `:294` (`routeAndOpen` — why a present bound item skips every lobby arm); `StoreKeyEnvelope.swift:482` (`locate` — newest sidecar wins)
- 13x relation: `vx-6-13x-library-portability` ladder R1 BLOCKER (detection) — see `notes/plans/phase-13x-library-portability.md` on that branch

## SEQUENCING ADDENDUM (2026-10-07, the 13x morning sitting — supersedes the header's "after 13x merges")

Her ruling at the 13x closeout sitting (verbatim in the 13x plan file's MORNING SITTING
section): VX-80 is PULLED INTO 13x — the fix builds now, on `vx-6-13x-library-portability`,
under the phase's held Sync/-custody slot, a fresh Fable implementer briefed by THIS record,
its own cold-review round over the VX-80 diff, closing with the 13x PR. The 13x walk and her
AirDrop acceptance legs follow the fix so the walk covers the new recovery arm too. The live
stranded fixture stays on the Air (read-only; the headless pin simulates the state on the Pro;
a live-fire leg against a COPY of the fixture is optional and hers).
