# The Fragments ↔ Variorum journal-bridge contract

**What this file is:** the shared contract between the two apps' journal integration,
written 2026-07-07. **Audience: the author, and her Fragments agents** (she carries this to
the Fragments repo herself — Variorum's coordinator and agents never work in
`~/dev/fragments`, and Fragments' agents never work here). Variorum's side is specced in
`notes/plans/phase-09b-fragments-bridge-brief.md` (built after Variorum's Phase 9). If either side needs the contract to
change, the author is the channel.

## The arrangement (author-decided 2026-07-07)

Variorum becomes the **co-writer journal app** that Fragments' "journal satellite"
(Fragments SyncSpec §8) was explicitly designed to meet. **Variorum is the journal's home
and truth** (blocks, variants, commits, lineage); Fragments' `journal_entries` is a
**projection surface both apps write**: one plain-text body per calendar day. The join key
is the user's **stated calendar day** — Variorum's `entry_date` is user-set (past and future
allowed), so both apps simply agree the user's chosen day IS the identity.

## Facts Variorum's bridge relies on (from the 2026-07-07 survey — please keep true)

1. Table shape: `journal_entries(id uuid PK, user_id, date, body text, created_at,
   updated_at, deleted_at, server_updated_at)` with live-unique `(user_id, date)`.
2. Deterministic id: UUIDv5(`"journal|<canonical-user>|<dayKey>"`) in Fragments' namespace,
   dayKey `"yyyy-MM-dd"`; canonical user derivable via `user_settings.local_user_id`
   (Fragments SyncSpec §2.1/§2.2). Same-day creates in both apps must converge to one row.
3. Access: the allowlisted RPCs (`sync_push` guarded upsert, `sync_pull` keyset,
   `sync_delete`), RLS on `auth.uid()`; the bridge authenticates as the author's Fragments
   user and touches `journal_entries` only.
4. Merge: row-LWW on client-stamped `updated_at`; un-tombstone only on strictly-newer edits;
   clock-ahead clamp; **`sync_pull`'s ~2 s visibility horizon** (the commit-visibility fix).
5. The Day-screen **clobber guard**: unchanged text never re-saves (no pointless
   `updated_at` bumps). Load-bearing with two writers — Variorum mirrors it on its side.
6. **One-per-day is DB-enforced on the Fragments side** (confirmed by the Fragments agents
   2026-07-07): `UNIQUE (user_id, date)` plus the deterministic id — even if Variorum's
   UI-level create-or-open ever slips, the server cannot hold two rows for one day; a
   duplicate push under the same derived id would LWW-**overwrite** rather than duplicate.
   Which is exactly why Variorum's rule is **pause-the-day's-push, never newest-wins**:
   nothing is pushed for a duplicated day until the author hand-merges — an overwrite the
   author didn't choose is the one forbidden outcome.

## Asks of the Fragments side (for the author's Fragments agents)

1. **Confirm the visibility horizon applies to a third-party poller of `journal_entries`**
   via `sync_pull` (it should — same RPC — but say so explicitly): the bridge advances a
   keyset cursor and must never permanently skip a row.
2. **Keep the clobber guard** exactly as shipped; it is now part of a two-writer contract,
   not just hygiene.
3. **Treat this satellite's schema and key semantics as frozen without a contract update** —
   Fragments' own maintainer notes warn about add-a-column/migration compounding; a silent
   satellite change now breaks a second app. New columns are fine if `sync_push`'s
   key-intersection behavior preserves them for writers that don't send them (it does today).
4. **Tolerate any date** on entries arriving via sync — past, and **future** (the author
   allows future-dated journal entries). Confirm the Day screen renders a future day's
   entry sanely rather than assuming date ≤ today.
5. **The author wants journaling in Fragments to feel good as real writing** — Day-screen
   journal editor UX (comfortable size/type, maybe an expanded editor) is Fragments-side
   work with zero contract impact. This is her stated priority for your side.
6. Optional nicety: a subtle "updated elsewhere" cue/refresh when a pull changes the
   currently-visible day's body (the co-writer is live now).
7. Nothing Variorum-specific should enter Fragments: the satellite stays app-agnostic plain
   text, exactly as your spec intended ("the journal app owns richer journal tables if it
   wants them; what Fragments syncs is exactly this satellite").

### Phase 9b build asks (2026-07-09 — facts the contract turned out not to pin; the bridge
### shipped with these as injectable configuration / PROVISIONAL readings, to be confirmed
### or corrected BEFORE the post-9c real-project pass)

8. **The UUIDv5 namespace.** Fact 2 gives the recipe (`UUIDv5("journal|<canonical-user>|<dayKey>")`)
   but not the namespace UUID it runs in. Please state it verbatim. Variorum carries it as
   configuration (`FragmentsBridgeConfiguration.idNamespace`) — nothing was guessed.
9. **One worked id example.** Given a concrete canonical user string and dayKey, the exact
   resulting `journal_entries.id` — so both implementations can pin the same vector. For
   cross-checking your derivation style, Variorum's implementation (RFC 4122 §4.3, name =
   the recipe string UTF-8, id emitted lowercase) produces, under the RFC **URL namespace
   `6ba7b811-9dad-11d1-80b4-00c04fd430c8` as a stand-in**:
   `journal|alice|2026-07-09` → `efd1b644-d604-5272-860d-ab4061668e96`. If your uuid5 of the
   same name under that namespace differs, the derivations diverge and the real namespace
   will not save us — say so.
10. **The canonical-user string's exact form** (fact 2's `<canonical-user>`): is it
    `user_settings.local_user_id` verbatim, the auth user id, lowercase/uppercase UUID text,
    or something else? And is it the same value as `journal_entries.user_id` (`auth.uid()`)
    or distinct? Variorum carries both as separate config fields.
11. **The RPC wire shapes** for `sync_push` / `sync_pull` / `sync_delete` as a third-party
    client speaks them: parameter names, request/response JSON, and the `updated_at` stamp
    format you emit/compare. Variorum shipped PROVISIONAL DTOs (snake_case column-named
    keys; push → per-row `{status: applied|stale|rejected, server_updated_at, reason}`;
    pull request `{table, after_updated_at, after_id, limit}` returning row objects) pinned
    by tests — corrections are cheap now, expensive at the real pass.
12. **`created_at` on upsert-update:** Variorum's pushes include `created_at`; please
    confirm your guarded upsert preserves the existing row's `created_at` on UPDATE (the
    fake server assumes so).
13. **Optional, closes the residual loss windows:** when `sync_push` LWW-overwrites a live
    row, consider returning the REPLACED body in the response. Variorum's pushes stamp
    minimally above the last server-row stamp the bridge has seen (a compare-and-set
    discipline added at its Phase 9b review), so an unseen Fragments save now survives as
    `.stale`-then-rescued — but three residues remain: a day's FIRST-EVER push carries no
    known stamp (falls back to wall clock), stamps quantize at 1 s, and an unparseable
    stamp falls back to wall clock (ask 11). With the previous body returned on overwrite,
    the bridge would land it as a variant → zero loss in every case.
    *(Related, from the same review: Variorum's re-projection stamps may sit only 1 s
    above the row they answer rather than at wall-clock time — confirm your `updated_at`
    semantics tolerate content-newer-than-stamp rows; it is pure LWW ordering to us.)*

## What each side promises operationally

- Variorum pushes only when its rendered text actually changed; pauses a day's push while
  that day has two live entries (a rare offline-race state, hand-merged by the author);
  lands every Fragments-side edit in durable Variorum rows (worst case: a labeled variant —
  nothing typed in Fragments can be lost by the bridge).
- Fragments keeps LWW semantics as-is; no special cases for the co-writer.
- Credentials: the bridge uses a user-auth session for the author's Fragments account,
  stored untracked on her machines; the Supabase *personal access token* (server tooling)
  is never used as the bridge's identity.
