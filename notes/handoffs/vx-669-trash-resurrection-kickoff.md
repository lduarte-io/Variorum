# VX-669 run kickoff — deleted Sherlock books resurrect from sync (+ the Trash's responsiveness)

**STATUS: READY FOR KICKOFF (written 2026-10-28 on the Air, trace complete; the fix runs on the PRO — the diff lives in `Sources/VariorumCore/Sync/`, so this is the one Sync/-touching effort and it holds that slot).**

**Kickoff (paste-ready):** `/architect-phase vx-669 vx-670 vx-672` — riders to offer at kickoff: VX-671 (Trash multi-select), VX-654 (the quadratic `originalsStrandedBy` CTE — same code neighborhood as VX-670). Mint the run ticket per the skill; members by sub-issue listing. Cast: **the Sync/ half is Fable work** (CLAUDE.md — `SampleLibraryDedupe.swift` is in `Sync/`); Opus may implement the Trash-surface members; Fable cold-reviews the whole diff.

**Her reports, verbatim (2026-10-28, the morning sitting):**
- "I have 2 copies of the adventures of sherlock holmes, and several times I have tried deleting them, and they have both returned … I didn't full delete them - they restored themselves from the trash."
- "when I opened variorum on my phone, I actually did see the adventures of sherlock holmes come back, and they were suddenly the most recent thing in my library. so i actually do suspect that somehow opening my phone is removing them from the trash. and then when my computer resynced, they were once again out of the trash."
- "as part of my testing, i permanently deleted one of the sherlock holmes books + a couple notes in it from the trash, and then sync on the phone took forever (several minutes, from one book being deleted …). and then the result of that is that both sherlock holmes books came back, exactly as they were on the phone (13 notes on one and 14 notes on the other)."
- "the trash has a several second delay before it shows what items are in there after deleting them … it took so long for items in the trash to appear it was just a blank screen … i click delete, then delete now, nothing happens for a long time. it's bad."
- "i also should be able to select multiple items to delete."
- "I did delete a test note and it appeared in the trash of my mac and my phone" (ordinary deletes converge fine — consistent with the trace below).

---

## The trace (VX-669) — mechanism confirmed in code

**The resurrection is the sample-library dedupe's DEFENSE LEG** (`Sources/VariorumCore/Sync/SampleLibraryDedupe.swift` — RUN B B2 row 15 Part 2, QUESTIONS #143(b), ratified 2026-09-22), and it fires **only for seeded sample-library books with a same-name twin** — which is exactly her state: two copies of "the adventures of sherlock holmes" (the ruled both-edited outcome of the pristine dedupe, both kept).

The chain, per device receiving her delete:
1. Her Mac deletes both books (11:47 AM) → ordinary family tombstones push.
2. The phone's pull apply: each copy's **first arriving family death** fires `recordSampleCopyKillEvidence` (hooked in `Repairs.swift` ~line 241) while the copy is still whole locally.
3. `meetingStands` (the #143(b) bound, F-R2) answers YES through **arm 1 — "another same-name copy's reading row is LIVE here"** — which in a settled two-copy library holds **forever**; and for the second copy through **arm 3** — the loser's tombstone within the ONE-HOUR settle window of the arriving kill (both deleted the same minute; phone opened 11:53).
4. The kill-time classifier (`SampleCopyClassifier.classify`) reads both her copies **EDITED** (13/14 notes vs the shipped manifest, her engagement) — and the ruled matrix says "an edited copy is NEVER silently retired."
5. `defendEditedSampleCopies` → `reviveSampleCopy`: the **whole family's tombstones are flipped back exact-stamp and every row explicitly enqueued** — the phone pushes the revival, the Mac pulls it, the books leave the Trash. The deleting device never records kill evidence for its own ops, so the Mac's Trash looks right until the next round.

**Why this is a bug and not the accepted #143(b) corner:** the ratified wording promises "a deliberate cross-device delete of a kept, engaged copy a day (or month) later is NEVER second-guessed." That premise assumed the meeting is a transient once-per-store-life window. **Arm 1 falsifies it:** while a live same-name twin stands (the permanent state of every both-edited library), every deliberate delete of either copy, at any later date, is second-guessed and revived. The two books are mutually undeletable from any second device. The F-R2 ladder fix closed the dead-tombstone-lifetime hole and missed the standing-live-twin one.

**Precedent that confirms the class:** the takemania/Jekyll book was **deliberately excluded** from `Book.dedupeCovered` (`SampleLibrarySeeder.swift`, 18l-c U6) over exactly this hazard — the QUESTIONS note says "deleting the spare copy on your Mac would be undone by your phone — the exact opposite of what the disclaimer tells you to do." Sherlock remained covered, and the two-edited-copies state was never re-checked against the defense.

**The purge leg (her "permanently deleted" test):** her Delete Now minted purge intents; the purge janitor's horizon (every device's cursor past the tombstone) had not been met, so the server rows were still tombstones — the phone's revival flipped them live and pushed; nothing refused. **Fix-run obligation:** `reviveSampleCopy` deliberately does NOT void purge intents ("none exist on this road by construction" — false once a deliberate Delete Now is the kill being defended). Verify with a pin that the janitor's staleness net (`familyVerdict` → `.stale`) actually protects a revived family from a later purge execution — if it doesn't, that is a **data-loss hazard** (revived books purged under her feet) and must be fixed in the same run.

**Launch relevance:** a fresh user with Mac + phone who engages the seeded book on both devices before their first sync lands in both-edited → a standing pair → undeletable seeded books. This is not "just her library." It also binds VX-633 (the Machiavelli seed book): whatever replaces Sherlock joins `Book.dedupeCovered` and inherits this unless fixed first — which is why this run precedes the seed build.

## Fix directions (her ruling needed at kickoff — #143(b) is HER ratified behavior; none of these is autonomous)

The defense's true target (F-1) is the crossing race: the retiring device classified PRISTINE because this device's engagement hadn't reached it yet. The predicate should detect **in-flight-ness**, not standing state.

- **Option A (recommended):** narrow `meetingStands` to in-flight evidence only — **drop arm 1** (the standing live twin) **and the bare arm 3** (settle window alone), and replace them with: the defended copy's own family/engagement rows are **still in this device's outbox** at kill time (my unpushed edit — the race's actual signature), or arm 2 (my own retirement unpushed). A deliberate delete between synced devices is then never defended. Residual accepted: an edit pushed seconds before the kill arrives falls back to the retirement landing in the Trash — visible, Put back real — instead of auto-revival.
- **Option B (simplest):** delete the defense leg entirely. The F-1 race then costs an edited copy a trip to the Trash (tombstones only, recoverable; the known 14-row Put back annoyance, QUESTIONS #85(e)) instead of being auto-revived. The dedupe's core matrix (both-edited → both survive at the PASS) is untouched either way.
- **Option C (not recommended pre-launch):** wire provenance onto retirement tombstones so deliberate deletes are distinguishable — a schema/lockstep event for a repair edge case.

Either A or B also needs: the purge-intent staleness pin (above); a **red-on-old convergence pin** in the two-client fake-server harness reproducing her exact scenario (both-edited standing pair → deliberate delete of both on client A → client B applies → assert NO revival, tombstones converge; old code revives = red); and a scenario pin for the single-copy-deleted case (arm-1-only). Her testing worry ("we might need tests that open the phone sim signed into a test account") is answerable headless: the fake-server harness reaches this entire class without any simulator — the live Mac+phone round is the ACCEPTANCE walk, not the pin.

**Her current library's cleanup is part of acceptance:** after the fix lands on both devices (NB: the phone build must carry it too — the defense runs on whichever device receives the tombstones; until the phone is refreshed, deleting from the Mac will still resurrect), she deletes the copies she doesn't want and the run proves they stay deleted across rounds on both devices. Any stale purge intents from her earlier Delete Now presses get reconciled (verify none threaten the copy she keeps).

## VX-670 (Trash unresponsiveness) — pointers, not yet profiled

- The blank-listing delay: `RecoveryView.swift` awaits `observeTrash`'s first value; `Queries.trash`'s stranded-originals arm walks `originFamilies` (documented as the deliberately-expensive half), and VX-654 already confirms `Queries.originalsStrandedBy` (the lineage CTE) **quadratic in seam history — 13 s at 600 rounds, awaited in the Delete Block receipt chain**. Profile first; likely one root serving both tickets.
- Delete Now / Put back latency: the purge-family expansion and restore walks run awaited before the UI answers; check what runs on the main actor vs reader pool, and whether the confirm sheet could present before the family walk completes.
- VX-672 (the minutes-long phone round after a purge) is a member: profile during the live acceptance round (candidates: the revival defense re-pushing whole families — which dissolves with the VX-669 fix — purge-ledger reconciliation, per-row apply cost).

## Environment notes for the run

- Worktree `~/dev/variorum-vx-<run>` on the Pro; the run holds the one Sync/ slot (in-flight table currently clear — only VX-216, her-hands, remains).
- Headless `swift test` on the core package covers the convergence pins; no stage claim needed for those. The live acceptance (dev-store or test-account rounds, any GUI walk) holds `Tools/stage`.
- The dev store does not sync by design; the live proof road is the PROD TEST ROAD with vxtest accounts (`Tools/WalkKit/first-run-walk.sh`, `~/.variorum/prod-test-accounts.env`) or her own hands on her real account at her word. Her real store: A1 safety copy first, always.
- SyncSpec read IN FULL before touching `Sync/` (binding); the fix is a client-side repair change — **no schema, no lockstep event** under options A/B.

## Her items bundled from this sitting (answer/rule at the Pro kickoff)

1. **Rule the fix direction:** Option A (narrow to in-flight evidence) or B (remove the defense leg) — A recommended.
2. **Pre-launch label:** hers per ticket — VX-669 (and VX-670?) gate the Wednesday beta build? (Seed work VX-633 depends on 669's fix per the trace.)
3. VX-671 (multi-select) as a rider on this run, or later?
4. The one-hour settle window and #143(b)'s wording: after the fix, the QUESTIONS #143(b) row and SyncSpec §7's dedupe bullet need the delta recorded at closeout (the two-file rule).
