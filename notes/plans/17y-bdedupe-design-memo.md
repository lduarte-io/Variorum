# 17y B-DEDUPE — the design memo (the orchestrator, 2026-10-05, written BEFORE building; the precondition reads done this session: SyncSpec whole · the postmortem · `SampleLibraryDedupe.swift` whole · the Welcome keeper · the seeder/gathering/quicknote mint shapes · `LaunchFurniture` · the guide seeder's structural survey)

**The ruling built to:** R-17y-5 (the whole-set fold, inside 17y) as TRIMMED by R-17y-8
(Jekyll leaves the default seed; its fold leg DROPPED) and EXTENDED by the B2 ladder's
MAJOR-2 re-own (the guide's Canvas teaching derives from the (p) seam). Zero schema; the
marker stays 12; no §12 event. The `Sync/` halves are the orchestrator's own seat; a FRESH
`fable-reviewer` cold-reviews the diff with zero framing; convergence suites are mandatory
(no sync change is reviewed without one — AppSpec §15 risk 3).

## 1. What the reads established (the constraints the design must honor)

- **The pristine-classifier road does not fit the field guide.** `SampleCopyClassifier`'s
  contract is Sherlock-shaped: ONE chapter per note (its memberships-equal-chapters check),
  one active take per block, no presentation, no block name. The guide's SHIPPED seed
  violates all of these BY DESIGN (10 chapters / 41 notes; `branchVariant` mints teaching
  fans; `setBlockPresentation` mints a callout; a `duplicateAsVersion` TWIN with a
  `version_of` edge; a seeded SCRAPS POOL "tutorial scraps" with no FK tie to the book). A
  naive facts entry would classify every fresh guide EDITED and the fold would never fire;
  a widened manifest classifier would need a full structural manifest + a generation
  pipeline + a per-build variant (MAJOR-2 changes Release's note set) — heavy, drift-prone,
  and all of its failure modes land in `Sync/`.
- **The three seeded gatherings cannot use byte rule-equality.** classics and Quicknotes
  rules name a tag BY ID (`RuleGrammar .tag(id)`); two devices' copies name DIFFERENT ids
  for one path, and the `tag.path` fold re-points APPLICATIONS only — the loser's rule
  keeps naming the dead twin (assembles empty). Identity must resolve the term's tag to its
  PATH (dead rows readable), and the SURVIVOR's rule must re-point to the live tag as a
  repair write. "starred notes" is the easy case (rule `.star`, no id). Quicknotes adds a
  DESIGNATION (`setting 'quicknote_book'`) that must converge to the keeper (the
  daily-Journal keeper's designation-half precedent) — noting §20's ruling that Quicknotes
  has no comes-back trait: the repair only RE-POINTS a designation that names the loser; it
  never mints.
- **The standing §7 discipline binds every piece:** deterministic on every device;
  idempotent; repairs run inside the apply transaction with EXPLICIT outbox rows; pull-only
  occasions; stragglers defer (never guess); err toward keeping; a device without facts
  stays INERT and converges by receiving the outcome rows (the nil-inert precedent).

## 2. THE DESIGN — one mechanism: the reserved-object PAIRWISE fold

Instead of classifying each copy against a shipped manifest ("is it pristine?"), the new
repair folds a pair ONLY when the two copies are **(a) unengaged — no sign of her hands on
EITHER — and (b) content-identical TO EACH OTHER** (ids/positions aside). Then keeping the
smaller id loses NOTHING by construction: the survivor is byte-equivalent in everything she
can see. Any doubt, any difference, any engagement → BOTH SURVIVE. This is R-17y-5's
"fold only when BOTH copies read as the seed's own" taken at its safest reading, and it is
STRICTLY narrower than the pristine matrix (it can never retire an edited copy because an
edit makes the pair non-identical or engaged).

Why pairwise instead of the ruled sketch's manifest road (recorded as a PROVISIONAL
deviation, hers to overturn): zero bundled manifests, zero generation pipeline, zero
build-variant wrinkle (two copies of ONE build's seed are identical; a stale-content copy
beside a new one differs → both survive VISIBLY — the safe direction), and the guide's
structural richness (fans, callout, twin, pool) is compared, not re-described. The cost,
stated honestly: a STALE corpus guide meeting a fresh new-content guide does NOT fold
(two guides stand until one is deleted or re-seeded) — bounded by the close ritual's
standing re-seed of her real store's guide after any lesson-content edit, which makes her
corpus copy current BEFORE her Monday install meets it.

**The object grains and their identity checks (all over SYNCED rows only):**

1. **The guide BOOK** (facts: reserved name "the field guide", exact/case-sensitive — a
   rename is engagement): pair = two live readings wearing the name in one wing.
   Identity = ordered live chapter NAMES equal · per chapter, ordered member note TITLES
   equal · per note, rendered text equal (`BridgeHash.body` over `Queries.renderedText`,
   both sides live — the recipe rides the facts as today) · per note, the structural
   skeleton equal (blocks in placement order; per block: ordered live active take texts ·
   archived-take count · any locked take · block name · presentation JSON · the CHOSEN
   take's index with NULL-chosen normalized to the default) — one pure function over rows,
   same bytes on both sides or no fold. Engagement (either side) = any MANUAL savepoint ·
   comment · reference · a live tag beyond the reserved #tutorial on a member · a member's
   membership in ANY other reading · floating notes · entry_date · a locked/archived/sealed
   member or book · book sort off the mint default · extents · grouping · outflow · dial ·
   finish/seal/own/archive · shelf off the Welcome-role shelf. INDETERMINATE (either side
   straggling: a member container not arrived, a block with zero variant rows, zero
   memberships) → defer the WHOLE pass, one-shot marker re-arms (the R2-3 idiom, own key).
2. **The three seeded GATHERINGS** (facts per gathering: reserved name + rule shape):
   pair = two live gatherings in one wing matching the seed SIGNATURE (rule-by-path OR
   reserved name under `BookNaming.sameName` — the adoption predicates' own grammar).
   Identity = both rules resolve to the SAME shape by PATH (`.star` for starred notes;
   single `.tag(id)` whose tag row — live or dead — carries the declared path for classics
   / Quicknotes). Engagement = a name that matches neither the reserved name nor signature
   · a rule off the seed shape · outflow/dial/hide_owned set · finished/sealed/owned/
   archived · a shelf pointer that is neither nil/dangling nor a `role='welcome'` shelf
   (classics ships ON Welcome; starred/Quicknotes ship unshelved) · a starred flag off the
   seed's own (Quicknotes ships STARRED — un-starred = hers; the other two ship unstarred —
   starred = hers). Fold = smaller id keeps; the loser tombstones (a gathering holds
   nothing — no memberships move; its dismissal-record rows, if any ever exist, stay dead
   history); **the KEEPER's rule re-points to the LIVE tag id at the declared path when it
   names a dead twin** (explicit outbox); **the Quicknotes designation re-points to the
   keeper when it names the loser** (setting write + outbox; never minted, never created).
3. **The reserved-titled NOTES** (facts: titles "a first quick note" and
   "compare & versions — the twin"): pair = two live Home posts wearing the reserved title.
   Identity = rendered-text hash equal + structural skeleton equal (the book-grain's
   per-note function). Engagement = any manual savepoint/comment/reference · a live tag
   beyond the SEED-AUTHORED set for that note (quicknote: the `quicknote` path; twin: the
   `tutorial` path) · a membership difference (the twin may be membered in its guide copy —
   a twin membered in the RETIRED guide copy died with it already; the standalone fold
   covers the bookless shape) · entry_date/floating notes/locked/archived. Fold = smaller
   id keeps, loser's container-family tombstones (ordinary, explicit outbox, Trash-listed).
4. **The reserved-titled POOL** ("tutorial scraps", kind='pool'): same note-grain rules
   over the pool's snippets (ordered block skeletons + rendered text). No FK ties a pool to
   a guide copy, so it folds INDEPENDENTLY — which is exactly what makes the family problem
   tractable: book, pool, twin and quicknote each fold (or decline) on their own identity,
   deterministically, with no cross-object pairing heuristics.

**Occasions (pull-only, the standing grammar):** a `reading` row applied (book/gathering
grains) · a `container` row applied whose title/name is one of the declared reserved
titles (note/pool grains — TouchedRows already carries applied container ids; the title
check is one indexed read) · the pass's own one-shot deferral marker (own `sync_state`
key, spent-first exactly like `sample_dedupe_pending`). The pass runs in
`runPostApplyRepairs` AFTER the tag.path fold (same transaction, so rule re-points see the
folded tag) and is independent of the existing sample pass (which stays byte-untouched).

**The facts injection** (the keyProvider/nil-inert pattern, the ONE shared wiring site):
a new `SeededFurnitureDedupeFacts` — the guide book name + reserved tag path · the three
gathering signatures (name, rule shape, optional designation key) · the two reserved note
titles with their seed-authored tag paths · the pool title · the hash recipe. Wired at
`SyncSession.configure` beside `sampleLibraryFacts` from Shared constants
(`TutorialSeeder.bookName` is Mac-target — the MAC's configure call appends the guide
half; the phone wires the shared half only, and **the pocket guide's symmetric entry is
the recorded MOBILE PARITY row, never built here**). Empty facts = inert.

## 3. The Mac-side (non-`Sync/`) halves, same batch

- **R-17y-8 — Jekyll leaves the default seed:** `Book.launchSet = [.sherlock,
  .encryptionExplained]` and `LaunchFurniture.seed` iterates IT (`Book.all` keeps Jekyll
  for the Restore doors and the pins); existing stores never retrofitted (their marks and
  discovery already hold); Help ▸ Restore unchanged. The books-chapter lesson gains her
  intake's ONE sentence (Jekyll restorable via Help ▸ Restore — a seed-CONTENT edit; the
  standing re-seed consequence recorded, executed at the close ritual behind the A1 rail).
  The Welcome arrangement needs NO change (it shelves by name; an unseeded name shelves
  nothing — B-SEED's own mechanics). Takemania leaves with Jekyll (it lives inside it).
- **MAJOR-2 — the guide stops teaching a mode Release lacks:** the mode-row sentence in
  `TutorialSeeder` builds from `PostMode.modeList()`/`keySpan()` (the helper's precedent)
  and the "blocks · canvas" lesson gates on `PostMode.buildKeepsCanvas` (Debug keeps it;
  the tutorial spine is Debug and stays green). Under the pairwise fold this needs NO
  manifest work. Same re-seed consequence, same one execution at close.
- **The B-SEED residue note** (`LaunchFurniture`'s header + the B2/B-SEED records name the
  guide's two-copies residual): rewrite to point at this slice's fold.

## 4. Convergence suites (mandatory; the fake-server two-client harness)

Per grain: both-unengaged-identical folds to the smaller id on BOTH devices (outbox rows
asserted — SyncSpec §7's standing test rule) · engagement on EITHER side keeps both (one
per engagement axis for the gathering grain; the heavier axes for the book grain: a lesson
text edit, a fan edit on an UNCHOSEN take, a comment, a manual savepoint, a chapter
rename/reorder, a member added/removed) · the straggler deferral (book arrives before its
members → indeterminate → marker → next pull folds) · the gathering rule re-point (keeper's
rule names the dead twin → re-pointed to the live tag, outbox row, assembles correctly) ·
the Quicknotes designation converge (names the loser → keeper; names a third thing → left
alone) · idempotence (second pass = 0 repairs) · the inert arm (no facts → nothing fires,
byte-identical behavior). Plus the Mac-side pins: launchSet red-on-old (a fresh launch
seeds no Jekyll; Restore still mints it), the mode-row sentence derives (red-on-old: the
literal carries "Canvas"/"⌘7"), the Canvas lesson gate, and the end-to-end: a fresh store
seeded + a second device's seeded corpus pulled → ONE guide, ONE classics, ONE starred
notes, ONE Quicknotes, ONE quicknote, ONE scraps pool, ONE twin — the Monday bed headless.

## 5. PROVISIONALs this design creates (numbered at the batch's close, QUESTIONS-ready)

(i) the pairwise-identity road in place of the ruled sketch's manifest road (the deviation
+ why — hers to overturn toward the manifest classifier); (ii) the stale-meets-fresh guide
pair both surviving (bounded by the close re-seed; alternative: a manifest road folds the
stale one); (iii) Quicknotes' un-star / classics' shelf-move counting as engagement;
(iv) the designation re-point running only loser→keeper (never minting — §20's letter).

## 6. What this slice deliberately does NOT do

No schema, no server, no marker move. No phone code (the pocket-guide facts row = MOBILE
PARITY). No change to the existing Sherlock/EE pristine pass, its RUN B defense, or the
Welcome/daily keepers. No 13s seed-set reshaping (Encryption Explained and the classics
teaching stay for 13s — R-17y-8's letter). No KnownIssues row survives the close: the
B-SEED duplicate-class row closes WITH this slice.
