# VX-99 handoff: your morning checklist

*Overnight run, 2026-10-08, on your word: "continue running all the way through until application refresh." The
orchestrator was Opus 5.5 (your switch from Fable). The record is `notes/plans/fixes/vx-99-pro-castle-apple-wrap.md`.
The ratify bundle is `notes/QUESTIONS.md` #204.*

## Your checklist

1. **Check which build is installed.** The `/Applications` refresh ran after the merge and installs VX-83 and VX-99
   together. The build number, the A1 safety-copy folder and the codesign result are in the **last comment on the VX-99
   Linear ticket**. If that comment says the refresh is still waiting, the coordinator holds it; ask oct7coordinator.
2. **Open the Pro normally.** Touch ID should open it. No "still holds a copy under your Apple account" notice should
   appear, because your live key file `a1e93a2d…` has no Apple copy. If that notice ever appears again, tell a session:
   it would mean something new wrote one.
3. **Enter your twelve words on the Pro.** Nothing regenerates them.
   - Make sure you're online, then go to Settings ▸ Protection ▸ **Lock Library Now**.
   - On the lock screen, choose **the twelve words** and type them.
   - The app checks them against the vault before it writes anything, so a typo or a wrong set writes nothing.
   - Don't use *Regenerate Twelve Words*, any *generate words* button, or *Replace All Keys* for this.
4. **Do the same on your phone:** lock it, then enter the twelve words on the lock screen while online.
   - The phone's key file has no local words copy either. I checked it read-only over the cable: no Apple copy, so the
     phone never had this bug.
   - The phone gets VX-99's fix (and the reworded resume caption) at its next install. It doesn't need it urgently.
5. **The 13 Apple-openable backups.** These are the app's `Backups/` snapshots named `…-182738de…`, from Sep 7 to
   Oct 7, plus any Time Machine copies from that window. They're yours to handle after this phase, as you said.
6. **Ratify or reverse QUESTIONS #204.** It covers:
   - the widened scope
   - two provisional sentences
   - one residual for 13s
   - the round 4 that didn't run (item d): whether you want a cold review of round 3's small fix before anything builds
     on it

**Hand tests: none required.** Every path the fix touches sits behind a Replace All Keys, a crash during a key rotation,
or two devices changing keys at the same moment. The tests cover them, each one failing on the old code first. **Please
don't run Replace All Keys just to test this:** it rotates every key on the account and asks both your devices for the
passphrase. Steps 2 to 4 are the useful checks.

## What happened

- **The cause (traced):** your Pro entered Castle at the pre-13x migration on Sep 5, and that was correct. On Sep 7 at
  02:15 you ran **Replace All Keys** at the pre-13x acceptance walk. The code then decided the key file's Apple copy as
  "anything that isn't *entering* Castle gets one", without asking the account's posture. So on your Castle account it
  wrapped the Pro's new library key under the iCloud key your Mac still held from its Standard days. The vault stayed
  Castle; only the Pro's local key file was wrong. 13x's new detector caught it, and your follow on Oct 8 at 00:55
  closed it.
- **The fix:** the vault's answer now decides whether the key file gets an Apple copy, on every road: the ceremony, the
  crash resume, the follow, and the offline-only road, which Replace All Keys now refuses.
- **What the three review rounds added:**
  - **Round 1 (Fable):** the same stale-posture mistake one level up. Replace All Keys decided the *vault's* Apple copy
    from the Mac's possibly stale reading, so it could silently flip the account's posture. Fixed.
  - **Round 2 (Opus 5.5), the serious older bug:** finishing a crashed Replace All Keys reused Castle's screens. A failed
    restart could walk you into *entering Castle*, and a finished one could claim "your Apple account never held" a key
    it did hold. Fixed: the resume screens on both Mac and phone now speak the act that crashed.
  - **Round 2's fix pass also found:** the resume door refused to finish a rotation this same Mac had started, which
    could leave sync paused for good on a one-device account. Fixed.
  - **Round 3 (Opus 5.5, the last round allowed):** two problems my round-2 change had introduced. A rare double-device
    crash case could tell you your paper words "are not your account's" when they are, and a resumed Replace All Keys
    could move custody silently. Both fixed by restoring the old behavior on those roads.
- **Evidence:**
  - every fix has a test that failed on the old code;
  - each named undo proof turned only its own test red;
  - the last full run: PostureSwitchTests 69/69, the custody suite set 198 tests in 20 suites, the tutorial spine 99 in
    13, both Protection pane face suites;
  - both the Mac and the phone build on the merged tree;
  - zero changes in `Sources/`, no schema change, marker 12.

## Not done / handed on

- **VX-106:** two PostureSwitchTests red on main since 13x. They pass under VX-99's corrected test setup; that's
  recorded but not claimed as VX-106's fix. The question of the order of 13x's checks stays with the 13x session. A
  message for 13x was given to you last night.
- **VX-107:** the leftovers of a crash on top of another crash (Low).
- **VX-108:** the Use Castle and Leave Castle doors still read the Mac's posture (Low; no exposure).
- **VX-109:** a race in the core `Sync/` code between two vault reads (Medium; Fable work).
- **VX-110:** Use Castle's offline-only road on a synced library, plus two banners that name one act (Medium).
- **The custody slot:** freed at this merge. It goes to VX-106, then 13s U1b; oct7coordinator holds the order.
