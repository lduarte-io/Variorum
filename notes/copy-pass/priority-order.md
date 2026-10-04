# The copy pass — priority order (≤ 8 focused hours)

2026-10-04. The burn-down order for the pre-release copy pass, against
`all-user-facing-strings.md` (3,630 strings, grouped by surface, `path:line`
per string). Budget allocations sum to ~8h; they are a box, not a floor —
bank time wherever a tier runs fast. Two framing facts: (1) the onboarding
FLOW isn't designed yet, so Tier 1's order is a best guess at the first ten
minutes — re-order freely once the flow exists; (2) most strings are short
labels: the pass is a full READ everywhere but a full REWRITE only where
flagged.

## Tier 0 — defects, not voice (~30 min, do first)

Concrete pre-release fixes the sweep caught; each is a one-line code edit.

Internal references leaking into visible copy:
- `(SyncSpec §12)` — `Sources/VariorumCore/Sync/SyncSchema.swift:698`
- `(R13 — the transient marker)` — `TakesBoardView.swift:472`
- `(Sitting 9, R60)` — `CompareBoardView.swift:1239`
- `(windowing arrives with Phase 12)` — `BookView.swift:1523`
- `ProjectConfig.swift` named in user-visible text — `AppServices.swift`,
  `AuthViews.swift`
- the repo path `notes/DataSafetyRunbook.md` inside the user-facing runbook —
  `DataSafetyCopy.swift:83`

Banned-register words (the ruled copy's never-list) in NON-exempt strings:
- "escrow" — `SettingsShape.swift:258` (Settings ▸ Protection blurb)
- "vault" — `PassphraseSetModel.swift:78`, `:241`; `SecretCheck.swift:57`,
  `:131`, `:209`
- (The four "vault" strings in `EncryptionSession.swift` 661/672/674/679 are
  documented §11 exemptions — leave them.)

## Tier 1 — the first ten minutes (~1.5h, full read, rewrite freely)

What a brand-new user meets before they've written a paragraph. ~290 strings,
mostly short.

1. **Onboarding, first run & the locked lobby** (22) — the literal first
   screen.
2. **Welcome setup names** (in Seeded content: the Welcome shelf, "a first
   quick note", Quicknotes/Journal/Home names) — the first nouns they see.
3. **Empty states & placeholders** (75) — a new library is MADE of these.
4. **Sidebar & Library chrome** (122) + **Note chrome** (33) — the standing
   furniture.
5. **Quick note & capture** (17).

## Tier 2 — the app's spoken voice (~2.5h, the highest value-per-word)

The sentences the app SAYS, every day, forever. This is where AI-flavored
text does the most damage and your voice does the most good.

1. **Refusals, offers & receipts** (377) — read every one; these are the
   personality. A door that says no in your voice is a feature.
2. **Dialogs, sheets & ceremonies** (161) — the Divide/Merge sheets are also
   about to be ON CAMERA (V8/V9), so they pay twice.
3. **The 96 ⚠RULED (§11 provisional) protection strings** — explicitly
   marked provisional FOR this voice pass; they're yours to settle now.
4. **Menus, command palette & undo labels** (154) — scan; mostly nouns, fix
   outliers only.

## Tier 3 — the settings panes (~1h, full read)

You named these specifically. ~255 strings excluding the protection blurbs:
window chrome & search (24) · General (52) · Editor (39) · Takes (10) ·
Writing (21) · Shortcuts (2) · Tags (22) · Data Safety (68) ·
Acknowledgments (15 — the five licence TEXTS are excluded legal text, don't
touch). Settings ▸ Protection's two strings plus its blurb land with the
ruled corpus (Tier 6), except the Tier-0 "escrow" fix.

## Tier 4 — the field guide & demo content (~2h, TIMEBOXED — decide scope first)

- **The tutorial field guide** (`TutorialSeeder.swift`, ~11,200 words, 10
  chapters / 42 lessons) is the single largest voice surface in the app and
  cannot be fully rewritten inside this budget. The honest options: (a)
  timebox 2h on chapter 1 + whichever chapters the onboarding flow will
  surface first, and let the rest ride into an update; (b) rewrite it
  properly as its own sitting and accept a day more. Since the onboarding
  flow design is pending anyway, (a) now + (b) alongside the flow design is
  the natural split. Its "keeping it private" chapter renders ruled copy —
  that part is already yours.
- **takemania demo note** (~4,400 words + take labels and savepoint names) —
  if the welcome flow points at it, it's effectively tutorial; skim for
  voice, fix the labels (they're the fan's first impression).
- **Encryption Explained** (~2,400 words) — ruled §7b; already your words.
  Skip unless deliberately re-ruling.
- **RESTORE.md runbook** (~2,770 words) — accuracy over voice; verify the
  Tier-0 path leak fix lands here. Skim only.
- **Sherlock / Jekyll** (~113,700 words) — public domain, no pass.

## Tier 5 — the mode surfaces (~45 min, scan for outliers only)

~1,600 strings of working-surface labels: Books & gatherings (479) ·
Bookcase/shelves/wings (168) · Write (206) · Takes (160) · Archived & Trash
(124) · Tray & Block History (102) · Pool & Snippets (88) · Compare (68) ·
Blocks (63) · Lenses (55) · Versions (50) · Canvas (43) · Read (40) ·
Import & export (23). Scroll each group fast; stop only where a sentence
sounds like a manual instead of you.

## Tier 6 — deliberately OUT of the 8 hours

- **The ruled encryption corpus** (254 ⚠RULED of the 561 protection-surface
  strings): already ruled word-by-word against `pre-13x-copy.md` with the
  keystone lines. Re-voicing it is RE-RULING — a deliberate act against that
  file, not a casual pass. 13s remains its slot.
- **Tooltips & help / the Shortcuts & Dictionary window** (159) — lowest
  stakes; sweep up in an update or if time banks.
- **Accessibility-only labels** (11) + **Anything else** (7) — glance.

## Appendix — words the sweep can't show you (short checklist, review in code)

User-facing words that live as enum case names / derived values:
- the mode names Write…Canvas (`PostMode.swift:40–46`)
- the Timeline sort labels; the Blocks workbench filter/sort words
- the Snippets sort words recent / oldest / longest
- the time-stamp words edited / created / dated (`TimeStampFace.swift`)
- the book settings field names; `BookOrderAndConversion.swift:60` renders a
  sort field with `_` → space
- composed text: menu titles + appended shortcuts (`Capability.swift:406`),
  the ⌘K palette reusing command names, sentences assembled from fragments
- not ours to edit: passed-through system error text, standard macOS
  menus/panels, the Touch ID sheet (only the reason string
  "Unlock your Variorum library" is ours), locale-formatted dates

## Practical notes

- The full inventory is ~512 KB / 3,630 bullets. If pasting into Variorum,
  consider one note per tier (the group headings split cleanly) so the
  burn-down maps to notes.
- `VariorumMobile/` is excluded — the mobile copy pass is its own later
  effort, after this one settles the voice it inherits.
- When the pass changes a string the launch material quotes (ceremony names,
  mode names, "takes" vocabulary), tell the marketing side — the brand
  continuity notes (`notes/brand/LAUNCH-CONTENT-NOTES.md`) assume today's
  nouns.
