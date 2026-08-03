# Suite-account spike (Phase 14a Step 0 — THROWAWAY)

The 14a kickoff sitting's live probes against the NEW neutral Supabase project
(the suite's account home — issuer ruling R2, shape A, in
`notes/plans/phase-14a-suite-identity.md`). Sibling of `Spikes/AuthPairingSpike/`
(9c's harness, kept as-is — its callback page still serves half 2's
Variorum-delegation probe).

**What half 1 proves (pure neutral-project work — zero contact with the live
mirror or her daily-drive sign-in):**

- **(P-ii) THE VAULT ACCESS PATH — the load-bearing unknown flagged since 9c:**
  an access token issued through the project's own OAuth 2.1 Server code flow
  is (or is not) accepted by that same project's PostgREST as an ordinary
  authenticated user JWT (`auth.uid()` resolves, RLS applies). The 14b vault's
  whole access design rides on the answer.
- **(P-signup) non-author provisioning mechanics:** a brand-new user
  self-registers on the neutral project (signups deliberately ON there) and
  completes the flow.

**Run order (the sitting drives this; field notes land in the plan file):**

1. Author creates the neutral project + enables its OAuth 2.1 Server
   (Site URL `http://localhost:3000`, Authorization Path `/consent.html` —
   REMEMBER the dashboard save trap: reload to verify values stuck).
2. Fill `config.js` (public values only — project URL + publishable key).
3. Register the spike client (architect, curl, dynamic-registration door —
   author toggles "Allow Dynamic OAuth Apps" ON, registration runs, toggle
   OFF; the 9c-proven semantics: the toggle gates only the register handler).
   Client is PUBLIC (`token_endpoint_auth_method: "none"`) — no secrets
   anywhere. Fill `SPIKE_CLIENT_ID` in `config.js`.
4. Scratch table `vault_probe` created on the neutral project (RLS'd,
   own-rows policy) via the author's PAT — see the SQL at the bottom.
5. Serve this directory: `cd Spikes/SuiteAccountSpike && python3 -m http.server 3000`.
6. Open `http://localhost:3000/start.html` → it mints a PKCE pair and sends
   the browser through authorize → consent (sign in or CREATE the throwaway
   account right there) → callback exchanges the code and runs the PostgREST
   probes, printing a redacted summary for the field notes.

**This directory is THROWAWAY** (the 9c precedent): evidence lives in the plan
file's field notes; the production consent/sign-in page is the stargazing.tech
agent's build, specced separately.

## The scratch-table SQL (run once on the NEUTRAL project)

```sql
create table if not exists vault_probe (
  id       uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid(),
  note     text
);
alter table vault_probe enable row level security;
create policy vault_probe_own_rows on vault_probe
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
grant select, insert on vault_probe to authenticated;
```

Expected probe results: with the OAuth-issued access token — insert succeeds,
select returns the row, `owner_id` = the throwaway user's uid; with the bare
publishable key — both refused (RLS; no policy for anon).
