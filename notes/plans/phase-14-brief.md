# Phase 14 — Accounts & multi-tenant — ORIENTATION SKETCH

> **Weaker status than the 10–12 briefs (author-requested, 2026-07-07):** a Fable pass over
> likely shape and tradeoffs, expected to partially stale (the commercial landscape, Supabase
> feature set, and the author's productization intent will all have moved). Binding content
> is only what it cites from the spec; the just-in-time plan (at Phase 13's closeout) treats
> the rest as a head start.

> **Author input (2026-07-11, at the 9c Step 6 sitting):** she leans toward **offering
> encryption** ("I do think that offering encryption would be good") — and spotted the
> load-bearing constraint herself: **the Fragments bridge projects the journal as plaintext
> into Fragments' own server** (their contract has no encryption), so E2EE on Variorum's
> mirror cannot cover the one surface the bridge exports — arguably the most intimate
> content. The E2EE decision round must design around this explicitly (options sketched
> then: encrypt everything Variorum-side anyway with the journal's exposure named; make the
> bridge opt-out/off under E2EE; or condition on Fragments gaining encryption). Also note
> 9c already shipped much of cluster 1 (auth core, refresh, sign-in) — this phase's auth
> work is the COMMERCIAL half only (see the KnownIssues row as narrowed 2026-07-10).

`owner_id TEXT` (nullable) sits on every top-level entity since schema v1 (S4); the sync
protocol was designed to reuse unchanged under RLS partitioning (SyncSpec §2: "accounts
phase adds owner_id population + RLS partitioning of the same endpoints"); the mirror carries
no constraints to migrate. The phase is population + policy + auth — not a sync redesign.

## Work clusters (likely shape)

1. **Auth.** Supabase Auth replacing the single-user token (KnownIssues "Sync auth
   hardening" owned here): token lifecycle on both platforms, refresh, device sign-out/
   revocation, the author's standing key-rotation practice formalized. Credentials handling
   per platform stays out of the repo (the Phase 5/8 posture).
2. **`owner_id` backfill + RLS.** A migration stamps her user id onto existing rows — on
   BOTH stores and the mirror, under SyncSpec §12's lockstep choreography (this is the
   biggest lockstep exercise yet; rehearse on a backup copy first — A1's cold copies are the
   rehearsal material). RLS policies on every mirror table; the changefeed and CAS RPCs gain
   owner filtering. **Isolation tests are the phase's verification core:** two users, two
   stores each, prove zero cross-tenant reads/writes at the RPC layer.
3. **The E2EE decision memo** (KnownIssues, owned here — decision, not necessarily build).
   The frame to put before the author: the server never *needs* to read text (dumb CAS —
   the architecture's deliberate E2EE door), so client-side encryption of the text-bearing
   columns (`working_text`, `commit_point.text`, `title`, `floating_notes`, `label`?) is
   architecturally viable. Real costs to weigh: **key management is the product** (key loss
   = corpus loss; a recovery-key ritual is mandatory, and its UX is real work); every future
   client complicates; server-side debugging of sync issues loses text visibility; metadata
   (structure, timestamps, tags?) likely stays readable — decide the boundary honestly.
   The floor alternative: documented at-rest posture + access discipline. Her call; both
   paths keep the protocol unchanged.
4. **"Variorum edition" full-fidelity export** (KnownIssues, owned here). Sketch:
   folder-of-markdown + `manifest.json` carrying what `.md` can't (fans, commits, lineage
   edges, readings, tags, by UUID); **import-as-copy** mints fresh UUIDs while preserving
   the internal edge graph (the pool-copy remap pattern, writ large). Presentation of the
   lossless SQLite archive — never a second truth. If Phase 11's export made this look
   trivial, it may have been pulled earlier; check before planning it here.
5. **Multi-tenant server notes** (verify, they look sound): global `server_seq` stays global
   — RLS filters each tenant's pull window, per-tenant sequences are unnecessary; rate
   limiting becomes real; the GC horizon (Phase 12's memo) becomes per-user.

## Explicitly not this phase's calls

Pricing, distribution (App Store vs direct), marketing shape — the author's, on her
timeline. The phase makes the *architecture* commercial-ready; it does not commit her to a
launch.

## Standing risks

- The backfill migration touches every row she owns — lockstep + backup rehearsal are
  non-negotiable; treat it like the schema-change equivalent of surgery.
- Auth integration is where third-party SDK surface usually creeps in — new dependencies
  remain an author-only call (CLAUDE.md).
- Don't let the E2EE memo silently become an E2EE *build* — the KnownIssues entry is
  explicit: decision first, scope deliberately.
