# Cold read of the final design and plans — round 4, Fable (VX-266)

**Reviewer:** a fresh Fable reviewer, run as the design owner's subagent at her word: *"do the next review with your
own fable subagent - if it stalls, opus on max instead."* It didn't stall. **Target:** the design, the phase-1 plan,
the key maps and their generator, and the companion explainer, at commit `8f62d4a2`, with every earlier round's records.
**Her ask, verbatim:** *"run another cold review on the finished design + plans to make sure that the design has no
gaps and that the plans reflect the design."* Her ladder: *"then you can run another opus max cold review if any more
majors were found (that would be the fifth round). stop at that point"*.

The report follows, committed unedited. The dispositions are in `design-cold-read-r4.md`.

---

# Design cold read, round 4

**Target:** `notes/plans/vx-266-castle-backups-prelaunch.md` (design), `notes/plans/vx-305-castle-core.md` (phase-1 plan), `notes/plans/vx-266/castle-target-key-map.html` + `castle-key-cycle.html` + `castle-key-map.html` with their generator `castle-key-map.gen.py`, and `notes/plans/vx-266/castle-map-fable.html` (explainer), at `8f62d4a2`. Read also: all of rounds 1–3 and the extra read with their dispositions, `notes/SyncSpec.md`, and `notes/plans/pre-13x-postures-design.md`. The code premises the newest text leans on were checked where the design makes a claim about them.

**Result: 0 BLOCKER · 0 MAJOR · 1 MINOR · 1 NIT.** The design holds up under a fresh trace. The two findings are small; the overnight §9 provisional calls are correctly surfaced for her and hold mechanically (detailed in the clean bill). No prior-round fix is reopened by a later one.

---

## MINOR

**[MINOR] · design §3.13 step 1 (lines 837–839) and §3.15 "What stays" (lines 933–935), against §5's release-switch timing (lines 1222–1239) · The old-rotation-marker finish path is kept only "one release after the switch," but a store carrying a crashed old-build act can arrive after that window, and the design is silent on what the migration then does with it.**

- **What's wrong.** §3.15 keeps three legacy readers past the switch. Two are kept *forever* (today's mode rule; the fold's reads of old custody and 13p escrow items) because "copies made before this change exist forever." The third — "the `RotationMarker` read and today's runner's finish path" — is kept only "for one release after the switch, then deleted." §3.13 step 1 depends on it: "Finish anything in flight with today's runner — its finish path." The migration itself "runs once, at first unlock on the new build" and on Release "only once she has turned the new system on" (§3.13 lede, §5).
- **Evidence (traceable sequence).**
  1. The release switch (VX-329) ships in Release build N; the finish path is deleted at build N+2 ("one release after").
  2. A beta tester's store crashed mid-rotation on the last *old* build (the in-file `sync_state.rekey_in_progress` marker is set — the pre-13x `RotationMarker`, confirmed present in `CorpusRotation` / `SyncEngine.refuseIfRekeyIncomplete`).
  3. The tester doesn't open Variorum through builds N and N+1 and updates straight to N+2+.
  4. The migration runs for the first time on that store. Step 1 wants "today's runner … its finish path" — gone.
- The design's stated assumption is "a crash left in flight **on the last old build**" (§3.13 step 1), i.e. the migration runs right after the last old build. A tester who skips the one-release window breaks that assumption: their last-run old build can be N−1 while they migrate at N+2. A store can carry an old marker exactly as long as it can carry a no-record copy — which is why the mode reader is kept forever; the marker finish path is given a strictly shorter life for no stated reason. The impact is bounded (prepare-then-commit means the library still opens under the old or new key, and §3.13 step 9's A1 road stands), so this is not data loss — but the sequence is reachable and unhandled, and "the riskiest part is phase 2's migration, which touches every existing store" (§5).
- **Proposed fix.** Either (a) keep the old-marker handling as long as the mode reader (the same "pre-change stores exist indefinitely" reason applies), or (b) state explicitly that after the finish path is retired, any old in-flight marker the migration meets is treated as "the switch never happened" and cleared — extending step 1's existing "VX-235's stuck marker is cleared on proof that the switch never happened" arm to cover a *past-commit-point* old act whose only remaining steps were cleanup (old items linger harmlessly; the new migration folds the old keys into the history as it would any pre-change store). Say which in §3.15, and separate "the clearing check" (keep forever) from "the finish runner" (retire if you must) so the ambiguity between them is closed.

---

## NIT

**[NIT] · design §6, the VX-310 row (line 1289) against the phase table §5 (phase 2 vs phase 4) · VX-310's phase column reads "2" only, but the Touch ID re-arm it owns is assigned to phase 4, and VX-310 is absent from phase 4's members.**

- The §6 VX-310 row's own note says: "the re-arm question that follows a failed press is **phase 4's door**." Phase 4's "what" column (§5, line 1207) carries it: "the Touch ID re-arm (only after a press fails on an item that exists; a new device identity starting on Always ask, §3.10)." Yet §6's phase column for VX-310 says only "2," and phase 4's members column lists "VX-314, VX-313, VX-263, VX-301, VX-264, VX-239, VX-243" — no VX-310.
- This is the exact phase-membership-disagreement class rounds 1–3 kept catching (m16 / F5 / N1), one survivor. Harmless to the build, but the ledger should name where the phase-4 re-arm is owned.
- **Fix.** Either make VX-310's §6 phase read "2, 4" and add it to phase 4's members, or state in phase 4's row that the re-arm is tracked under VX-313 (whose "no repair makes a Touch ID item" is its sibling) — one or the other, not the current silent gap.

---

## Clean bill — load-bearing things checked and found solid

**The two review questions.**

- **Gaps.** I traced every reachable crossing and setup against §3.1 and §4.1's promises and her §1 rulings and found only the MINOR above. In particular: the **three-state vault leave** (wrap → Standard; id-with-no-wrap → leaving in progress; neither → Castle) is mechanically supported — `KeyVaultFormat` carries `appleKeyID` and `masterWrappedByAppleHeld` as independent fields, `key_vault_update` sets each from its payload (`11_pre13x_postures.sql:947–948`), today's builds read only the wrap (`ProtectionController.swift:2135`), and `CorpusRotation.complete`'s `clearingPreviousCorpusKey()` carries `appleKeyID` through untouched, so an older build's completion leaves the id-with-no-wrap state intact for the finishing write — the design's "an older build clears it first" path holds. The **seal/record** claims are correctly Castle-scoped (§3.6, §3.3): the mode is structurally the current key's kind, not the record's text, so a forged Standard record can't flip a mode or steer a Castle repair; in Standard no repair acts destructively on the record's word alone. **Leaving an account in Standard mints nothing** (extra-read M1(b)) is sound — every Standard-key-holding path (create / join-in-Standard / migration step 7 / follow-into-Standard) already mints this Mac's own key, so reuse is always available. **Entering Castle retires every own id this Mac's section lists** (M1), the **former-Apple-ID exception C-11**, and the **replacement-Mac/clone adopt + heal via Re-link's library arm** are each internally consistent and covered by stated §8 residue. Promise 2's "no retired key exists" and the C-11 exception don't collide (C-11 keys are never recorded retired; they are rule 2's last stated exception). No prior-round fix is reopened: fresh-key-at-landing/empty-history (r2 F1/M5), the two sealed homes (r1 M1), the export-off step (r2 M6), the lost-own-Apple-key → Re-link's library arm (r3 M5), and the Castle-kind-custody-through-the-rotation reach rule (r3 m7 + extra m8) all survive re-trace. Decision 30 (master under the account key in the vault) and §3.5 (library key under this Mac's own key in the key file) are two different wraps, not a contradiction.
- **Fidelity.** The three map pages are **byte-identical to fresh generator output** (`python3 -I castle-key-map.gen.py target|full|cycle`, `cmp` clean). The acceptance checklist is **47 rows** (matching the branch's "46 → 47" commit note), and its newest rows carry the newest design: C-11 (former-Apple-ID exception), R-5 (hardware marker as a salted hash, no raw identifier in encodings, no marker/salt in any log), R-6 (replacement Mac adopts all predecessor own ids). The phase-1 plan tracks the design on every overnight change — the follower anchor under the secret typed at its follow (U1), the salted hardware marker and its encoding/log scans (U1/U3), "every own key retired at entering Castle" (U3), "leaving an account in Standard mints nothing" (U3), the three-state leave (U2/U3), and the fixed-scenario/mutation-pin lists (U4) carry all the extra-read scenarios and guards. The plan's treatment of "off in Release = app wiring" as a go/no-go gate is the PROVISIONAL rule applied correctly (the most defensible reading, built and marked PROVISIONAL in both §5 and plan §2). §5/§6 agree on every ticket's phases except VX-310 (the NIT). The §7 canon deltas match the body. The **companion explainer** carries every r3 m16 fix (the step-3/4 who-lines now match the maps, the "except a library sent before this change" hand-off exception, the pointer to the stated exceptions on the Castle pane, "yes, if set" not "yes — always") and has been brought current to the overnight design (step 7 has "every Apple key … not only the one its key file names … a replacement Mac takes over its predecessor's" and the C-11 exception; the Out-of-Castle step 7 has the follower-anchor-under-the-follow-typed-secret rule); wherever it says less than the maps it says nothing contradicting them, and its footer correctly subordinates it to the maps.

**The overnight §9 provisional calls, reviewed as design text.** Each is correctly flagged for her and holds mechanically:
- The **follower's anchor also locked under the secret typed at its follow** (§3.4): the follow-typed secret is a current secret (it opened the vault), and both P and W are non-Apple-reachable, so this is a strictly additive owner road under a secret — it does not expose the anchor to anything Apple/login (promise 13 untouched) and is a birth-time lock, not a re-lock (so the frozen-anchor property for later doors is untouched). It makes her sentence true on the pressing device and, with honest per-copy *Opens with* wording and the §8 residue, approximately true on followers (words-only followers and stale-words copies named). It touches the premise of her frozen-anchor ruling, so §9 rightly keeps it her call.
- **"Off in Release" = app wiring** (§5): internally consistent with plan §2; the literal option is named; her call.
- **Touch ID re-arm only after a press fails on an existing item** (§3.10): closes the VX-313-by-deletion attack (r3 M4(a)) and the both-homes-rollback re-arm attack (extra m6) — with no item there is no press and no self-appearing question, so the adversary can't reach the question (it appears only after *she* unlocks with her passphrase). The residual "any enrolled finger passes Touch ID" is the pre-existing accepted shared-Mac model (decision 19 / corner 22), stated honestly in the question's own words.
- **New device identity starts on Always ask** (§3.10), the **real-scope rehearsal** (§9 open), and **today's bugs live in Release until the switch** (§9) are each her call and correctly parked.

**Code premises confirmed at HEAD:** `KeyVaultFormat` keeps `appleKeyID`/`masterWrappedByAppleHeld` apart and `clearingPreviousCorpusKey()` nulls only the previous key + seq; `key_vault_update` sets each apple field from the payload; today's reconcile reads the posture from the wrap alone; `CorpusRotation` is the shared rotation driver any enrolled device can run/complete. No invariant is relaxed; no lockstep or server change is introduced (the record, export-identity and MCP-grants families are the local-only precedent; the leave's id-with-no-wrap is this build's reading of an existing vault field). Phase 1 writes no `Sync/` line.

**Files (absolute):**
- `<home>/dev/variorum-vx-266/notes/plans/vx-266-castle-backups-prelaunch.md`
- `<home>/dev/variorum-vx-266/notes/plans/vx-305-castle-core.md`
- `<home>/dev/variorum-vx-266/notes/plans/vx-266/castle-key-map.gen.py` and its three output pages
- `<home>/dev/variorum-vx-266/notes/plans/vx-266/castle-map-fable.html`

The MINOR and NIT are the only two items that want a disposition. I'm available to recheck or push back on either.
