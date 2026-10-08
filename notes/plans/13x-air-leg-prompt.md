# 13x — the Air acceptance leg (brief for the AIR session; the author carries this over)

**You are the Air-side agent for Phase 13x's real AirDrop acceptance leg.** The author is at
the keyboard; this leg is HER HANDS with you as guide, safety rail and evidence recorder. The
Pro-side orchestrator (session `variorum-da`) runs the sending side and names the FINAL COMMIT
at hand-over — do not start before she gives you that SHA.

## Context in one breath

Phase 13x (VX-6, branch `vx-6-13x-library-portability`) built the library-portability doors:
File ▸ **Send Library to Another Mac…** produces a travelling pair (sealed snapshot + its key
file); File ▸ **Open Library…** adopts an arriving pair (classify → unlock → confirm →
move-aside → land under a RESTORE HOLD → one **Resume Sync** press reconciles). The VX-80
Castle-follow recovery door rides the same branch. The acceptance promise is literal:
*"airdrop your corpus to your new computer and it will work."* The Air's installed 0.9.2
(5178) has none of these doors — hence this build.

## Your steps

1. **Preflight:** `git -C ~/dev/variorum fetch origin && git -C ~/dev/variorum switch
   vx-6-13x-library-portability && git -C ~/dev/variorum pull --ff-only` (the Air's one clone
   switches branches — the standing Air rule). Confirm `git rev-parse HEAD` equals the SHA she
   carried over. Pull the shared memory repo too.
2. **Build:** from `~/dev/variorum/App/Variorum`: `xcodebuild -scheme Variorum -configuration
   Release -destination 'platform=macOS' -derivedDataPath DerivedData/13x-air-leg build`.
   Never any custom configuration. (A local Release build may wear dev signing if her
   Developer ID certs aren't on the Air — fine for a local run; `codesign -dv` and note what
   it says. The public DMG remains the fallback reinstall.)
3. **Her install choice (present both, she picks):**
   - **REAL-STORE LEG (the full promise):** A1 FIRST — a WAL-safe safety copy of the Air's
     real store, UTC name, into the container's `Backups/safety-copies/`. Then a
     ZERO-INSTANCE window: SHE quits the running app (never quit/kill it yourself), copy the
     built app over `/Applications/Variorum.app`, `codesign --verify` it, note the previous
     build number for the record. 13x carries ZERO migrations (marker stays 12) — the store
     format is untouched and the release road (Sparkle) later replaces this build.
   - **DEV-SCOPE LEG (smaller):** skip the install; run the built app as Debug instead
     (`-configuration Debug`, the fenced dev store) and accept the leg against the dev scope.
     Her real store untouched.
4. **The leg itself (she drives, you watch and record):** the pair arrives by AirDrop from
   the Pro (produced by the new Send door there) → **File ▸ Open Library…** → pick the
   arrived pair → the flow classifies and confirms (record the step-aside and sync-waits
   sentences as rendered) → adopt → the **restore-hold banner** shows with its as-of day →
   she presses **Resume Sync** → the reconciliation runs (expected shape: the arriving store
   id differs from the Air's, so custody mints fresh and the device enrolls deliberately at
   the door; the copy's non-zero cursor reconciles as a returner; after Resume it catches up
   to the account's head). **Evidence to capture:** each sheet's exact wording, the banner,
   the Resume outcome, the library whole afterwards (spot counts vs the Pro), and — real-store
   leg — the previous library sitting in `Previous Libraries/<stamp>/` WITH its key files.
5. **Report back** to her (she relays to the Pro orchestrator): the evidence list above,
   plus anything that surprised you, verbatim.

## Safety rails (absolute)

- `~/dev/variorum-fixtures/vx-80-stranded-store-2026-10-07/` is a READ-ONLY live fixture —
  never touched, never opened in place.
- Never quit or kill a running real-store instance — she does any quitting.
- A1 copy before ANYTHING touches a real store; copy-before-drill everywhere.
- No suites, no walks, no stage acts on the Air (the standing rule) — this leg is her hands.
- If anything refuses or looks wrong: STOP, record exactly what it said, and have her bring
  it back to the Pro orchestrator. Do not improvise a workaround on her real store.
