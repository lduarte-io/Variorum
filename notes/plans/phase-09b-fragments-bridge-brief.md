# Phase 9b — The Fragments journal bridge — DESIGN BRIEF

> **This is a BRIEF, not the execution plan.** Written 2026-07-07 at the author's direction
> (she decided the bridge the same day: **two-way, not deferred** — she wants to journal in
> Fragments as well as in Variorum's own iOS capture). **Slotted after Phase 9 (author,
> 2026-07-07):** she won't heavily use the app until Phases 9–11 land, and the Fable budget
> goes to Phase 9 first; the bridge still precedes the views phases. The just-in-time plan
> is written at **Phase 9's closeout** (the bridge reuses Phase 8's transport patterns and
> her credential flow, both settled by then). Ratified decisions below are binding.
>
> **HARD RULE (author, 2026-07-07): this repo's coordinator and agents NEVER work in, read
> from, or write to `~/dev/fragments`.** Everything Variorum needs from the Fragments side is
> pinned in `notes/fragments-bridge-contract.md`; asks OF Fragments live there too, for the
> author to carry to her Fragments agents. If the contract seems wrong or insufficient, stop
> and report — never go look.
>
> **Model recommendation (author assigns at kickoff):** Fable implementer + Fable reviewer —
> the bridge is sync-shaped and writes to her *live Fragments journal*; it is small, so the
> spend is bounded. Her call per the standing policy.

## The doctrine (author-ratified 2026-07-07)

**Variorum is the journal's home and truth** — blocks, fans, commits, lineage. Fragments'
`journal_entries` satellite is a **co-writer projection surface**: it holds one plain-text
body per calendar day, explicitly designed (Fragments SyncSpec §8) for an external journal
app to co-write. The bridge pushes Variorum's rendered journal text out and lands
Fragments-side writing back **through ordinary Variorum operations**, so S5's
conflict-as-variant doctrine guards the Variorum side and nothing anyone typed is ever lost
where truth lives. The author's user-set `entry_date` (2026-07-07 decision, Phase 8 Step 3)
is what makes the join trivial: **both apps agree the user's stated calendar day IS the key.**

## Contract facts the bridge builds against (pinned in `notes/fragments-bridge-contract.md`)

`journal_entries(id uuid PK, user_id, date, body text, created_at, updated_at, deleted_at,
server_updated_at)`, live-unique `(user_id, date)`; deterministic id
UUIDv5(`"journal|<canonical-user>|<dayKey>"`) in Fragments' namespace; RLS on `auth.uid()`;
access via Fragments' allowlisted RPCs (`sync_push` guarded upsert / `sync_pull` keyset /
`sync_delete`); row-LWW on client-stamped `updated_at`; un-tombstone only on strictly-newer
edits; their pull carries a ~2 s visibility horizon; their editor has a clobber guard
(unchanged text never re-saves). **The bridge speaks Fragments' own RPC dialect, touches
`journal_entries` only, and authenticates as the author's Fragments user** (a user-auth
credential — NOT the Supabase personal access token, which is server-admin tooling).

## Shape of the Variorum side (the plan's skeleton)

- **`VariorumCore/Bridge/`** — headless, testable: a `FragmentsTransport` (the RPC dialect;
  supabase auth), a `BridgeEngine` with its own **local-only** state table (last-pushed body
  hash + Fragments cursor per day; local-only ⇒ no §12 lockstep), scheduled off the Mac
  app's sync cadence. Mac-side first is the whole phase: Fragments-on-phone edits land when
  the Mac bridge runs; running the bridge on Variorum-iOS is a later nicety.
- **Push:** for each journal-profile post with exactly one live entry for its date: on
  change (debounced), upsert `renderedText` under the derived deterministic id. Unchanged
  text never pushes (mirror their clobber guard — a pointless `updated_at` bump would LWW-win
  over a Fragments edit). **Duplicate-day pause:** if a date has two live entries (the
  documented offline race), that day's push pauses, visibly, until she hand-merges — and
  pause (never newest-wins) is deliberate: Fragments' side is DB-unique per (user, date)
  with a deterministic id (confirmed 2026-07-07), so a slipped duplicate push would
  LWW-overwrite one text with the other there; an overwrite the author didn't choose is
  the forbidden outcome, so the bridge holds the day instead.
- **Pull + landing:** keyset-pull `journal_entries`; land through ordinary ops — no Variorum
  entry for the date → `createPost(journal, entry_date) + newBlock(body)`; entry exists and
  only Fragments changed since the last push → **auto-commit first, then `autosave`**
  (author decision 2026-07-07 — **the fifth quiet auto-commit occasion**): before the landing
  overwrites the entry's text, if that text differs from the variant's last commit, append
  one `commit_point(kind: 'auto')` — Fragments has no history surface, so a deletion made
  there must remain one restore away in Variorum's commit view ("it's the more dedicated,
  powerful software"); the idleAutoCommit guard applies (no commit when the last commit
  already equals the current text — landings are pull-cadence snapshots, so this stays
  bounded, never keystroke-rate);
  **both sides changed** (current rendered text ≠ last-pushed hash AND incoming ≠ either) →
  land the Fragments body as a **conflict variant labeled `'fragments'`** on the entry's
  block — the S5 doctrine, extended to the second writer. Never write under a dirty open
  editor buffer except via that conflict path (the sync engine's exact discipline).
- **The graduated-entry policy (PROVISIONAL — for the author):** two-way while the entry is
  a single unfanned block (the overwhelmingly common journal shape). Once an entry *graduates*
  (multi-block, or fanned), it turns **push-only**, and a Fragments-side edit against such a
  day lands as a `'fragments'`-labeled variant on the entry's first block — never lost,
  visibly recoverable, and never diff-mapped back across blocks (mapping plain text back
  onto block structure is the rejected diff-recovered-blob model, OverallModel §8).

## Edit-war honesty (recorded, not hidden)

Same-window edits on both surfaces: Fragments keeps its row-LWW winner — acceptable because
its copy is a projection; Variorum keeps **both** texts (one as a variant). The asymmetry is
the doctrine working as designed: loss is impossible where truth lives, and the projection
surface is allowed to be momentarily behind.

## Verification skeleton

Round-trip suites against a **fake Fragments server pinned to the contract** (never the real
project in automated tests; one manual real-project pass with the author at the end):
create-in-Fragments → lands as a Variorum journal post; create-in-Variorum → appears in
Fragments; a Fragments-side edit/deletion landing over uncommitted Variorum text
auto-commits first (the pre-edit text is restorable from the commit view) while an
already-committed-identical text takes no double commit; both-changed → conflict variant,
projection converges on the LWW winner;
duplicate-day pauses; graduated entry goes push-only and rescues incoming edits as variants;
unchanged text never pushes (idempotence); the deterministic-id derivation matches the
contract's worked examples; visibility-horizon behavior honored on pull.

## Review foci

1. The bridge writes Variorum rows **only** through Operations (zero direct row writes).
2. Nothing typed in either app can be permanently lost — every landing path ends in a live
   row or a labeled variant; assert it per scenario.
3. Push idempotence (their clobber-guard mirror) — no gratuitous `updated_at` bumps.
4. The credential is user-auth, stored untracked, never committed, never the PAT.
5. The repo boundary held: no file under `~/dev/fragments` was read or touched.
