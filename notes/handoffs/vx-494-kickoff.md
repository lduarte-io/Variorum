# VX-494 — the catch-up hang: the successor's kickoff (written 2026-10-23 ~03:20 MDT by the VX-488 orchestrator
at her word at its context ceiling; HER RELEASE WINDOW IS OPEN AND HELD ON THIS BUG)

## THE PASTE-READY KICKOFF PROMPT (for her)

```
/architect-phase vx-494 — the 0.10 window's blocker: the first catch-up on my real corpus hangs after one pull
call, so my Pro's crossing can't finish and the release tail is held. You take over from the VX-488 orchestrator
(at its ceiling). READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-494-kickoff.md (this file — the evidence, the
debugging plan, my-hands list, credential file pointers), then notes/plans/fixes/vx-488-window-hotfixes.md WHOLE
(the merged run + THE CROSSING ATTEMPT RECORD + THE REHEARSAL RECORD's machinery notes), then the standard
preflight: CLAUDE.md + canon, SyncSpec WHOLE (this is Sync/ work — the fix is Fable's own hands), CastleRules
WHOLE, SessionResiliencyProtocol, notes/handoffs/vx-488-kickoff.md (the held window steps + appendices A/B).
I'm present at the start for sign-ins and any typed secrets (the permission classifier blocks credential-shaped
driving — hand those moments to me; my ! road runs commands you're blocked on). Normal discipline: reproduce at
scale on the throwaway FIRST (the M3 walk opt-in exists for exactly this), trace to a concrete mechanism, fix
with a red-on-old pin, fresh fable-reviewer ladder (Sync/ — no waiver), then my crossing retry on the Pro, and
only then the held release tail. Variorum is QUIT on both Macs; the stage is FREE — claim directly.
```

## WHERE THE WORLD STANDS (verify, never trust: git log, the tickets, the server probes)

- **VX-488 IS MERGED** (PR #184, merge `e63602bac`) and fully closed as a run: VX-487 (Castle+TouchID sync keys,
  both halves LIVE-PROVEN at the throwaway rehearsal — act-side "Synced 2:21 AM", unlock-side "Synced 2:27 AM"
  off her one press), VX-486 (the locked row's Protection… door + reworded line — verified in production during
  the crossing attempt), VX-483 (the walk-rounds opt-in — the reproduction tool this bug needs), VX-489 (the
  0.10 version pins + bundled What's New notes). Born: VX-490, VX-491. The record:
  `notes/plans/fixes/vx-488-window-hotfixes.md` (ladder two rounds, closing runs Mac 5118/898 + phone 808/126).
- **0.10 (9093) IS INSTALLED on the Pro** (A1 `variorum-vx488-a1-20261023T083711Z`; codesign OK; sha256
  identical). Both Macs QUIT. The stage FREE. The Air still 0.9.8 (its A1 taken; appendix A of the VX-488
  kickoff is its install prompt — HELD).
- **HER CROSSING IS BLOCKED BY VX-494** (Urgent, Pre-launch, Confirmed): on her real corpus the first catch-up's
  round makes EXACTLY ONE pull call and hangs — `device_cursor.seen_at` single-stamped per round start (three
  launches: ~08:44, 08:56:55, 09:06:20 UTC on 2026-10-23), `last_seq` PINNED AT 0, `data_max` unmoved at 229138
  (no batch applied, no seed-row push, no second call), the row "Syncing…" with Sync now greyed forever. The
  idle lock (VX-492) and the stranded flag (VX-493) were filed mid-diagnosis but the cursor was pinned BEFORE
  any lock fired — they are real but secondary. The SAME build's throwaway catch-up (a handful of rows) synced
  clean the same night ⇒ SCALE-DEPENDENT. Suspects (untraced — trace before fixing): the first pull page's
  client-side apply (one transaction over a large encrypted batch), the purged-ids/returner fencing a
  from-zero cursor meets (her account's purged ledger has real mass), the A5 horizon interplay, a
  main-actor/writer deadlock on the round's first apply, the page-size loop.
- **NOTHING IS LOST, repeatedly verified:** her old library whole in `~/Documents/Variorum-pre-0.10-store-KEEP`
  AND in Previous Libraries; the server corpus intact (ceiling 229138); the Air's 0.9.8 library untouched; A1s
  on both Macs. The fresh Pro library (bound, Castle) holds only seed furniture + her gate re-arm.
- **THE RELEASE IS NOT PUBLISHED. THE TAIL HOLDS ON THIS BUG**, in order (the VX-488 kickoff file's steps + its
  appendices): her crossing retry and acceptance → the Air install (appendix A — update its "contains the
  VX-488 merge" check to also contain VX-494's fix) → the release publish at her standing word (notes approved;
  the road is the memory `variorum-release-publishing` + `notes/handoffs/vx-348-handoff.md`) → the site delta
  (`notes/stargazing-castle-rebuild-delta-brief.md`) → the window close-out on main (the vx307 checklist flip,
  SyncSpec §12's HELD marker-14 entry gains the result, the master-plan closeout paragraph, canon deltas in the
  two-file shape, `Tools/canon-size`, memory) → VM-8 (appendix B) LAST. The VM-8 prompt should ALSO name
  VX-494's fix (the phone's first catch-up is the same class at the same scale).

## THE DEBUGGING PLAN (the ruled direction; you propose exact seams)

1. **Reproduce at scale on the THROWAWAY first** — never on her store. The §8 fixture pattern (the vx-329 plan)
   + M3's walk opt-in: a scratchpad tool against the core plants a LARGE corpus for throwaway user B (tens of
   thousands of rows through the real serializer; B's vault state is VX-308-era Standard — plant/reset per the
   *[removed for publication]*
   DerivedData tag, never the standard path) with the walk env, a fresh library, sign in as B, turn on sync,
   and watch the first catch-up. Expect the hang; if it does NOT reproduce, say so loudly — the trace then
   needs her corpus's specific shape (purged ledger mass is the differentiator to try next: plant purge
   history).
   A HEADLESS reproduction (the fixture tool's pull arm against the planted corpus) is even better if it shows
   the same hang — faster loop, no stage.
2. **Trace to the concrete mechanism** — `Sources/VariorumCore/Sync/` is FABLE'S OWN HANDS (the standing cast
   rule; an implementer may code-read and propose, never write there). Instrument in the walk/scratch, not in
   product, until the mechanism is named.
3. **Fix + red-on-old pin** (the two-client fake-server harness for the engine side; a scale pin if the
   mechanism is scale-keyed — "a sync change without a convergence test is unreviewed").
4. **Ladder:** fresh `fable-reviewer`, REVIEW_PROMPT verbatim — Sync/, no waiver.
5. **The closing runs** (full Mac + phone at the final tree), **merge by PR** (merge commit; the usual board
   duties; this file's row in the in-flight table — ADD one at kickoff, the VX-488 row is retired).
6. **Rebuild + A1 + install on the Pro → HER CROSSING RETRY → the held tail above.**

## HER-HANDS LIST + CREDENTIAL POINTERS (values NEVER in records — the files below are on the Pro; she reads
them herself or runs your command via the `!` road)

- **The classifier lesson (this session's recorded reality):** the auto-mode permission classifier blocked
  credential-shaped typing (cliclick with secrets), credential-file sourcing into UI drivers, some throwaway
  SQL writes, and occasionally plain clicks/captures. Plan for HER to do: all typed secrets (sign-ins,
  passphrase sheets, crossing secrets), Touch ID/Face ID presses, and any blocked SQL via `!`. Keep driving
  everything non-secret yourself; hand off cleanly when blocked, never work around.
*[removed for publication]*
  design; hers to delete after the window): `VARIORUM_THROWAWAY_PROJECT_URL`, `_ANON_KEY`, `_PAT`,
  `_USER_A/_PASS_A/_UID_A`, `_USER_B/_PASS_B/_UID_B`. **The walk switch wants DIFFERENT names — MAP THEM:**
  `VARIORUM_WALK_PROJECT_URL="$VARIORUM_THROWAWAY_PROJECT_URL"`, same for `_ANON_KEY`; verify in-process via
  `ps eww <pid>` BEFORE any credential. Note: user A was reset tonight (fresh vault born of the walk library's
  pair, later orphaned when the walk library was deleted at the restore — reset A again per the §8 precedent
  before reusing, or use B). Tonight's walk-library secrets are DEAD (the library was deleted).
- `~/.variorum/dev-castle.env` — the DEV store's real pair. NEVER typed into driven UI; the dev library sits
  restored with its October-20 hold, untouched by this bug's work if you stay on throwaway users.
- `.env.supabase.local` at the repo root — the PRODUCTION PAT road (`SUPABASE_ACCESS_TOKEN`,
  *[removed for publication]*
  device_cursor/data_max reads in the crossing record are the worked examples); any production WRITE is hers
  alone, explicitly, which this bug should never need.
- Her REAL credentials (account passphrase, words, sign-in): NEVER handled, typed, or echoed by a session.
  Her crossing is her hands end to end.

## MACHINERY NOTES THAT WILL SAVE YOU HOURS (tonight's lessons, beyond the VX-488 record's)

- The real dev slot is in the DEBUG container (`io.lduarte.Variorum.debug/.../Variorum-dev/`); aside = ALL
  top-level FILES by `mv` (dirs stay); restore same-inode; rule 21's notice once at the next plain launch.
- cliclick `kp:return` doesn't drive SwiftUI onSubmit or dialog defaults — System Events `key code 36` does.
  A click on a background window only focuses it (click-through) — activate, then click twice.
- `walk-cap` (Tools/WalkKit) captures window-region PNGs; captures while SECRETS are on screen get blocked —
  capture after they leave.
- "The wrong Variorum": launching from Finder recents can open a stale copy — launch `/Applications/Variorum
  .app` explicitly, or the walk build by its full DerivedData path.
- Linear MCP is OAuth'd in HER session only — if yours lacks it, the raw GraphQL road (`~/.variorum/linear.key`).
- `Tools/stage claim/release` — no coordinator; renew per row on long walks.

## OPEN ITEMS RIDING THE WINDOW (bundle for her sitting; none block the bug)

- **M1 (c), now FIELD-PROVEN to matter** (the VX-488 record's OPEN ITEMS + the crossing record): a typed unlock
  loads no sync keys — she hit it live; the heal was the gate re-arm. Her call on (i)/(ii)/(iii) should come
  while the window's fresh.
- P-VX486-1/-2 (the locked row's door label + line — as built, hers to reword), the VX-488 handoff's filed
  tickets by priority: VX-492 (High) · VX-493 (High) · VX-490 (Low) · VX-491 (Low). VX-492/493 may fall out of
  VX-494's fix — re-check both against the fixed engine before closing either.
- The VX-488 run's canon deltas (SurfaceContracts' locked-row line; AppSpecRecord's dated entry) land at the
  WINDOW close-out with the rest — deliberately not piecemeal tonight.
