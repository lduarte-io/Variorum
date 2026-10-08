# Launch-content continuity notes

The session-independent record of the marketing/launch-content work
(2026-09-26 → 2026-10-08): what exists, the standing rules decided along the
way, and what's still owed. Written so a fresh session can pick up fine-tuning
on these posts without the original chat. Keep this file current when any of
it changes.

## What exists (the inventory)

- **`video/`** — three shorts scripts in one shape (hook → pain → turn → demo
  → kicker, 35–45s): `short-01-the-fan.md` (flagship), `short-02-speed.md`
  (the Apple Notes stunt), `short-03-delete-without-fear.md`; plus
  `filming-notes.md` (staging, 9:16 crop, WalkKit/cliclick choreography,
  AI-video rules) and the section `README.md` (series shape + 04+ candidates).
- **`why-variorum-stands-out.md`** — the ranked positioning list all copy
  draws from (13 entries, most-differentiating first, each with an on-camera
  hint).
*[removed for publication]*
  technical first comment, the comment-section crib sheet, tactics. **Gated:**
  ships only with a downloadable beta (HN's try-it rule); the blog post may go
  to HN earlier as a regular submission without burning the Show HN slot.
*[removed for publication]*
  alternate colder opening (Variant B) and video-embedding guidance at the
  tail. **She is rewriting this herself, in Variorum, in her own voice — the
  draft is fact-source material, not the text.** Future passes on her rewrite
  are FACT-ONLY (claims, not voice) unless she asks otherwise.
- **`site/variorum-product-page.md`** — the full what-is-Variorum reference
  page for stargazing.tech (15 sections + TOC), written as final copy.
- **`video/embed-shot-list.md`** — the silent-loop capture list for blog +
  product page (V1–V25, three tiers, beats + staging + hard rules), written
  for an AI-driven recording session. Blog uses at most three (V1+V2+V5
  recommended).
- **`../../stargazing-privacy-policy-brief-2026-10-04.md`** and
  **`../../stargazing-help-faq-brief-2026-10-04.md`** (notes/ root, beside
  their 13p/pre-13x predecessors) — the CURRENT pair she carries to the
  stargazing.tech agent; both self-contained and same-dated so they agree.
  Privacy: 13y closed the cross-account activity disclosure and changed the
  key proof; 13i added structure-only columns. FAQ: ruled copy verbatim; the
  three 13x-door entries are STAGE-NOW, PUBLISH ON HER GO (13x imminent at
  this writing); verify the phone Re-link twin (QUESTIONS #139) at publish.

Conventions across all of them: `[brackets]` = hers to fill or confirm;
**PENDING** markers = re-check at publish time.

## Standing rules (decided in these sessions — don't re-litigate, do apply)

1. **Frame:** build-in-public ("I built myself a writing app because…"); the
   ask is a follow, not a download, until launch. The etymology — *a variorum
   preserves the variant readings* — is the standing kicker everywhere.
2. **Claim discipline (the big one):** structural claims over benchmark
   claims; experience reports ("feels the same," "latency stays flat") over
   absolutes ("performs identically"). Performance copy is mechanism-first in
   canon wording (cost ∝ viewport + edit, never document/corpus). **Never
   claim 100k words** — AppSpec §4 keeps the within-post-virtualization
   escape hatch at exactly 100k+; 50k is the defensible number. Have one real
   measurement in pocket before any HN thread.
3. **E2EE phrasing:** never "the server only sees ciphertext." Accurate
   shape: every text-bearing column is sealed client-side (AES-256-GCM,
   per-value nonces, AAD binding); the server sees ids, timestamps, ordering
   keys, enums, sequence numbers — the CAS skeleton. Mentioning the
   maintained disclosure list is a credibility asset, not a liability.
   (Verified against SyncSpec's wire-is-ciphertext section, 2026-10-04.)
4. **Search copy — SETTLED (13o 2026-10-07 + VX-83 2026-10-08, confirmed in
   her use):** takes are in every search; savepoints behind the explicit
   "+ commits" filter; a day or a between-days span via the when ▾ calendar;
   `#tag` alone lists the tagged notes; a word naming a tag offers the tag as
   a chip; land-at-match with the find bar armed, ⌘G steps. The
   takes/savepoints claim is UNBRACKETED in every file as of 2026-10-08, with
   the fact fence beside it: savepoints only behind "+ commits"; the Trash
   and whole-note Versions are NOT searched (never "finds deleted text").
   Still never name FTS5. The FAQ brief carries its own SEARCH section (same
   date); publish-gated to the first public release carrying 13o + VX-83.
5. **Competitors:** never claim a competitor is slow without measurements
   (especially Obsidian — community favorite, benchmark bait). The
   unassailable form: file-based tools search each note's one surviving text;
   here every version is a row, so search covers the versions, not just the
   survivors. The "Apple Notes lags ~10k words" line is her own observation —
   **re-verify on current macOS before publishing** (flagged in the blog
   draft).
6. **AI-built honesty:** volunteer the process (she writes the specs and
   makes every decision; agents implement under a contract of invariants with
   cross-model adversarial review) — pre-empting beats being outed. The
   closing line: the process that makes AI-built software trustworthy turned
   out to be the app's own philosophy.
7. **Public stances deliberately taken in the copy (hers to soften):** no
   per-note locks and why (R13p-16 — curtain-locks teach false trust; the
   store is the protection); not a second brain / no transclusion; not
   collaborative, ever. All framed as conviction, not absence.
8. **Video rules:** one gesture per short; product footage is always real
   screen capture (AI tools only for hooks/B-roll/title cards/VO); no
   time-remapping in comparisons; demos staged in the DEV store only, with
   WalkKit/cliclick for repeatable choreography; blog embeds are silent
   6–12s loops (landscape crops), never the vertical shorts.
9. **Positioning order rationale** (why-variorum-stands-out): 1–3 the moat
   (nobody has it), 4–6 the proof burden (everyone claims, few deliver),
   7+ the lovable. If the target audience narrows to journalers specifically,
   privacy may legitimately rise to #2–3 and the flagship hook can become
   "your journal shouldn't live on someone's server" — offered, not decided.

## Decisions from the 2026-10-04 release-judgment round

- **Release staggering:** release (quiet, download live) and Show HN
  (the announcement) are separate days — ship when code-done, announce after
  the copy pass. Her sizing: the copy pass ≤ ~8 focused hours, worth one day.
- **The in-app copy pass precedes the video pass** (the surfaces are on
  camera). Working docs: `notes/copy-pass/priority-order.md` (her burn-down
  order) and `notes/copy-pass/all-user-facing-strings.md` (the exhaustive
  inventory she pastes into Variorum). The ruled encryption copy
  (`notes/plans/pre-13x-copy.md`) is flagged ⚠RULED inside — edit
  deliberately, keep the keystone lines.
- **No Variorum interchange format for v1** (recommendation accepted-pending
  — hers to overrule): the open story at launch is the SQLite file you own +
  AirDrop portability (13x) + Markdown/Alternates export. A granular
  export/import format matters when there are other Variorum users to
  exchange with — post-v1, alongside the recorded merge-libraries candidate.
- **The WHAT'S NEXT roadmap (her items, 2026-10-04)** now in the blog post
  and Show HN text: (1) MCP with Variorum-shaped AI permissions — per-note
  read grants, write power = add-a-take only, local models; (2) images;
  (3) collaboration; (4) Obsidian + Apple Notes importers. **Collaboration
  RULED (her words, 2026-10-04):** sync-time, never real-time same-editor
  work — "maybe a shared item between two libraries"; no locking needed
  because simultaneous edits become takes; far-future ("it has complexities
  for sure, especially given encryption"); public copy says it's
  "eventually" on the map. Blog, Show HN and the product-page FAQ all carry
  that wording. Canon's not-collaborative line (CoreDescription) still reads
  "no real-time collaborative editing, ever" — consistent with her ruling;
  a canon delta recording the shared-item future is a phase closeout's
  business if/when it's ever designed, not marketing's.

## Owed / next natural steps

- Her rewrite of the blog post (in Variorum), then a fact-only pass on it.
*[removed for publication]*
  wants the guarantee LOUD; it has two bracket slots on the product page).
- One real performance measurement captured before the HN thread.
- Re-verify the Apple Notes ~10k observation on current macOS.
- ~~After the 13o sitting: flip or delete the bracketed search claims in
  show-hn.md, blog-launch-post.md, and the product page §8.~~ DONE 2026-10-08
  (VX-83's closeout pass — flipped to the built truth with fact fences
  beside each; the FAQ brief gained its SEARCH section the same pass; all
  DRAFT, presented in the VX-83 handoff for her approval before the site
  agent sees any of it).
- Mobile status wording on the product page §13, at publish.
- Cross-link the blog post ↔ product page when both are on the site.
- Shorts 04+ (candidates in `video/README.md`); the embed captures per
  `video/embed-shot-list.md` (AI-driven session; she may shoot some herself).
- She carries the 2026-10-04 privacy + FAQ briefs to the stargazing agent;
  after 13x ships, she gives that agent the go to publish the three staged
  FAQ entries (and the launch copy's `[13x-gated]` AirDrop/portability
  claims unbracket at the same moment).
- **The 13x portability claim** ("you own the file — AirDrop your collection
  to a new Mac, open it with your passphrase") is now in the Show HN text,
  the blog privacy bullet, the product page §11 + file-format FAQ, and
  standout entry #5 — all marked 13x-gated; verify shipped before any of
  them publish.
- The product page hands off to the stargazing.tech agent (that repo has its
  own Claude agent — she tasks it; this repo only drafts content).

## Where the facts were verified (for fast re-verification)

Performance law + escape hatch: AppSpec §4. E2EE classification (18 sealed
text-bearing columns; plain skeleton): SyncSpec, the wire-is-ciphertext
paragraph. 13o scope + settled inputs (client-side by architecture, wing
isolation, facets, results-cap defect): `notes/FuturePhases.md` 13o row +
`notes/plans/phase-13i-sitting-record-2026-09-30.md` §12/§21. Release
*[removed for publication]*
*[removed for publication]*
CoreDescription / OverallModel / AppSpec §12.
