# Mobile Round 2 — WHERE MOBILE STANDS (written 2026-09-01 at her ask, by the second Fable seat)

> **NUMBER KEY (the VM-5 merge, 2026-10-07):** this record's QUESTIONS citations #84–#94 are the MOBILE-era numbers, renumbered at the merge to **#189–#199** (the mapping table heads the "Mobile Round 2 — RENUMBERED" section of `notes/QUESTIONS.md`; main's own #84–#94 are different entries).

*Her question: "I don't have much of an idea of what all the different batches are, what work
remains, if the biometric lock is already in place…" — a full accounting in one place. Everything
below is verifiable in the batch records named; counts re-derived at each unit close.*

**Suite trail:** 513/86 (round start) → 582/93 (before the Fable seats) → 632/96 (first seat's
close) → 712/102 (this seat, batch 7's close) → batch 10 pending. **Zero committed changes to
`Sources/`, `App/Variorum/Shared/`, the Mac target or `EditorBrain/` all round — the fence held.**

## A. DIRECT ANSWER — the biometric lock IS BUILT (13p Batch 4, 2026-08-30 — MobileSoul PL-15)

| what | state |
|---|---|
| At-open modes **Auto / Face ID (`.biometryCurrentSet`) / Passphrase** + the locked lobby (nothing runs before unlock) | **BUILT + PINNED** (`MobileStoreLockView`, `MobileProtectionSheet`; 19 pins in `MobileProtectionTests`) |
| Re-lock on background + long return, manual **Lock Now** (key material dropped) | BUILT |
| Passphrase-set screen with same-screen recovery phrase; the Standard nudge's two offers; the escrow dial; reminders; the reset door with one-device loss math; quick capture demands unlock under demanded modes | BUILT |
| First launch on the phone silently mints the store key; the existing store migrates on first keyed launch | BUILT, proven on iOS with zero-plaintext scans |
| **STILL OWED — only your phone can give it:** the LIVE Face ID walk and the on-device perf leg | **on your device queue** — and your phone still runs the **2026-08-21 build**, so you have never seen any of this |

## B. WHAT THE BATCHES ARE, AND WHAT IS DONE (Mobile Round 2, by batch — every ✅ is built AND cold-reviewed)

| batch | plain-language purpose | state |
|---|---|---|
| **1** | **The editor crash** (the round's reason — M1, a `BlockRangeIndex` trap on multi-line delete) + M2a–e | ✅ rounds 1+2 |
| **1b** | Whole-block-selection delete (select a whole block's text, delete it → the block goes to the tray) | ✅ |
| **2** | The **copy-the-note door** + the keyboard bar's air | ✅ |
| **3** | **Merge-then-edit** (a cross-block delete joins the remainders; its hoist exposed a 6-week-old Mac P1 violation) | ✅ |
| **3b** | **The home-screen quick note** (mint-as-you-type) | ✅ (its review found 2 BLOCKERs → 4.5a) |
| **4** | **Structural undo/redo door** · delete a note · **the Trash** · delete a book · the on-leaving savepoint | ✅ |
| **4.5a** | Capture & lifecycle fixes — the two BLOCKERs (the quick note destroying stored text; a refused save wiping the box) | ✅ |
| **4.5b** | Deletion doors — the third BLOCKER (four dead confirm buttons; the warning whose Undo cancelled it) + the accessibility test harness | ✅ |
| **4.5c-phone** | The editor's phone-local fixes: B45-2 (a stale-index trap), **no live editor over a deleted note** (the liveness seam now store-confirms every refusal, heals on Put back, speaks when it refuses), Rename Lens's confirm, two one-liners; the seam-carve gesture DEFERRED to 13u by ruling | ✅ **this seat** (the FULL ladder: 2 seam MAJORs → wave → round-2 → wave 2) |
| **4.5d** | The keyboard bar's geometry | ✅ |
| **5** | **The shelf layout** (quick note takes Today's Entry's box; books list bounded; the writing room a pinned guarantee; the starter Journal book) | ✅ |
| **6a** | **The Block History twin** — per-block savepoints/archived/deleted/came-from; closed the deleted-take dark window | ✅ |
| **6c** | **The Two-rooms IA** — Archive (a room, forever) and Trash (a utility, 30 days) as two screens, two doors; **the Versions face** (Save a Version / Versions… / Read / Restore / Promote) | ✅ first Fable seat |
| **filters** | The Library's **kind filters** (All · Books · Notes · Bookless · Scraps), books as openable rows, **All = books+notes union** (your #93), the sort glyph; the Archive inherits | ✅ first Fable seat |
| **6b** | **The per-note tray** (blocks chip → in the note · archived · leaving; deleted takes' Put back + Delete Now), archive/unarchive doors, the lens-dangle ⚠ with one-tap restore, the guide's deletion chapter — **PL-14 CLOSED** | ✅ **this seat** |
| **9** | **Your ⋯ letter:** undo/redo verified already there (built at batch 4 — your ask predates your build), `Takes…` off the block ⋯, Block History moved to each take's ⋯ (opens focused), the merge-vocabulary PROPOSAL for you; **the text-selection drag defect TRACED to four candidates** (not fixed — one minute of your finger settles it, §C) | ✅ **this seat** |
| **7** | **The fan's hands:** Move Take Up/Down, Take → New Block Below, All Takes to Blocks, **copy follows the screen** (with an honest receipt when a callout-framed note falls back), callout swatches + a real emoji keyboard, **block multi-select + bulk delete** (Merge Selected withheld pending your ruling) | ✅ **this seat** |
| **10** | **Navigation:** swipe shelf↔library ("it's killing me"), the starred-notes home page (a face, NOT the 13i smart book), New Note + New Chapter inside a book | 🔨 **BUILDING NOW** (survived the crash; resumed) |
| — | The five-MAJOR fix round (B1 starter-Journal seeding before sign-in — could have polluted your synced corpus; C2; A1; A2; C1) · PL-10(b) duplicate-book-name guard · the architecture review · the archive/trash design session (you ruled Two rooms) · the `main` iOS build break · the Fable sweep ladder | ✅ |

## C. WHAT REMAINS IN THIS ROUND (mobile-only, no Mac dependency) — in order

| # | work | notes |
|---|---|---|
| 1 | **Batch 8 — settings & judgment:** the savepoint-cadence + pruning settings rows · document settings · the Fragments-bridge row's honest copy ("your journal syncs with Fragments from your Mac") · **M14 measured only** (the Read hitch — the decision is yours) | brief drafted |
| 2 | **The leftover-backlog batch** — owns THREE routed defects: the stranded read-only page (two overlay sheets interleaving; fix ruled: one nesting-aware editability authority) · the sync-road silent keyboard drop (mechanism; the VOICE is yours) · plus batch-5/6a MINORs, refusal-copy homes, **R24** ("info"), 4.5e verification | brief to write |
| 3 | **PL-13's faces** (13l's data-safety twin): Data Safety screen (backup freshness/destination) · the sync-status line · the `SecretCheck` face (Face ID framing) · `.md`-insurance destination · note-level multi-select | unslotted → slot after 2 |
| 4 | **The dedicated stability pass** (a cold adversarial read of the crash-class fixes; owns M27) → **the whole-round pass** (the round's own cold read) → **CLOSEOUT** (13 obligations; the parity ledger burned down; the QUESTIONS pass; your handoff) | reviews, not builds |
| — | **YOUR DEVICE QUEUE (one install window):** the selection-defect experiment (3 observations, 1 minute — `mobile-batch-9-record.md` §4.5) · the Face ID walk · Read-mode memory at 100k · the emoji keyboard overlap check · the swipe's real pan (if the harness couldn't drive it) · M16 · D9 — **and the INSTALL itself: your phone is on the 08-21 build** | needs you |
| — | **YOUR RULINGS:** Merge Selected (batch 9's proposal — (A) select-then-merge + (B) Merge with Next recommended) · what the phone should SAY when sync deletes the note under you · **WHERE THE ASSIGN-TO-CHAPTER DOOR LIVES** (batch 10's named gap, given a home here at its cold review's MINOR 2: `+ New Note` inside a book lands the note UNSECTIONED, and a chapter minted on the phone can be filled only from the Mac — so the phone can now CREATE a structure it cannot USE. The mechanism is one argument — `newPostInReading` already takes `section:` — and the three candidate placements are a per-chapter trailing `+ new note`, the membership sheet, or a drag; which one is yours, and inventing one is what the guardrails forbid) · the PROVISIONAL bundle (Q8 tray door, door placements, the union stamp mapping, #87/#89/#90…) | your sitting |

## D. WHAT ARRIVES FROM 13u + THE POST-13u MERGE (the Mac phases you are running now)

| source | what mobile gets | how |
|---|---|---|
| **13u item 2** | the eager **space-eater** fix (you reported it on BOTH apps) | core/`Shared` fix — the phone inherits by construction |
| **13u item 4** | the **derived display-name snippet** (cards lead with first words when untitled) — "ONE brain… serving MOBILE'S LISTS" | a Domain function; the phone's lists compose it (a small face batch after the merge) |
| **13u item 5** | **cross-block edits stop refusing** — the semantics ruled ONCE for both platforms (edge-join merges mid-paragraph, not at a paragraph break; the fanned case open) | `Shared/EditorBrain` — the phone COMPOSES; the seam-carve gesture 4.5c deferred lands here |
| **13u item 6** | dark mode — the **phone's** dark mode is the Mac's look reference | reverse parity; shared tokens; nothing owed |
| **13u item 8** | the editor-seam backlog (U-1 fan fence source · U-2 the O(N²) twin · U-3 gap fence Mac face · U-4 empty-block plan · U-5 `CrossBlockRefusal` hoist — the phone's refusal wording follows it) + M12 + arch MINORs 1–2 | verified built-or-returned via the handback checklist at the merge |
| **13u item 9** | the **quick-capture ownership ruling** (one block or many; what ⏎ / shift-⏎ do) → **mobile batch 4.6** builds the phone's face to it (the lost-prose defect behind A5-2 is LIVE until then) | after 13u |
| **13u items 11, 12** | paste-without-newlines' RULE (the phone's edit-menu twin) · multi-block drag if ruled in (a phone row is born then) | after 13u |
| **the merge (her word)** | **the four #94 hoists** → PR21 in-note replace (`FindReplaceGate`) · copy-all-takes (`TakeClipboard`) · the tag-chip ✕/＋ grammar (`applyTypedPath`) · the voice fork (`ThemeStore`) · **+ one word**: `Queries.exportMapped` → `public` closes M23's callout-copy corner | one post-merge batch |
| **the merge (her statement 2026-09-01)** | **the 100k-word example note (Sherlock Holmes)** arrives with the Mac → mobile parity round — the phone's 100k bar (MobileSoul §2) gets its real on-device subject | with the merge; the on-device perf leg uses it |

## E. FUTURE MAC PHASES THAT WILL OWE MOBILE PARITY (not yet run — the ledger's waiting rows)

| phase | what mobile will owe | today's ledger row |
|---|---|---|
| **13i** smart-book identity, wings/libraries, the Owned book, custom shelf order, **the starred smart book + starred books**, templates, the book panel, book archiving | book faces over new core (reading assembly is core → the phone's book list renders the hybrid; wings need a face; the book panel needs a phone shape) | PL-4 + your 08-23 "don't build it yourself" |
| **13o** whole-library search | the engine lands in core `Queries` (FTS5 present since 13p); the phone gets a search face; P1/memory at the design table | PL-2 |
| **13s** voice & polish + first-run onboarding | the copy pass reaches the phone's guide and every phone-voiced line; onboarding's phone twin | (13s's closeout line) |
| **13w** automated versions | the Versions listing already windows; rotation renders there | — |
| **13v** the phone's OWN journal bridge | whether the phone runs the Fragments bridge is YOURS — a mobile phase | PL-9's held half |
| **13x** library portability | the phone is already a first-class store birthplace; adoption legs' phone faces | — |
| **13t** the sync tier | the phone's purchase channel (IAP vs web) — the 14c consideration | — |
| **13h / 13y / 13n / 13r** | expected "nothing mobile-visible" (folder bridge is files-domain; per-tenant seq is engine-level; MCP and Mac distribution are Mac-side) — each closeout must SAY so | PL-7 etc. |
| **16** images (post-v1) | a phone attachment face | — |
| **the mobile launch itself** | Stage E readiness: Dynamic Type + VoiceOver audit (**the chrome font does not scale with Dynamic Type — recorded pre-existing, app-wide**), TestFlight | MobileSoul §5.6 |

## F. THE PARITY LEDGER IN ONE LINE EACH (MobileSoul §6)

PL-1 (13e takes vocab): reorder ✅ · take→block ✅ · copy-all-takes ⏳ merge · find&replace across takes ⏳ merge ·
PL-2 (search): waits 13o · PL-3 (13j trash/restore): ✅ 6a/6b/6c · PL-4 (13i): future · PL-5/6/8 (sign-in, E2EE,
multi-tenant): ✅ closed · PL-7 (13h): future · PL-9 (bridge door judgment): batch 8 · PL-10 (13e doors):
(a)(b)(c)(d) ✅, design calls (comment-marker side, margin-comment tap) held for you · PL-11 (13j faces):
(a)–(e) ✅, (f) batch 8 · PL-12 (13u): OPEN — design together · PL-13 (13l faces): §C row 3 ·
**PL-14: CLOSED** · PL-15 (13p protection): BUILT, device walk owed · PL-16: informational.

## G. GLOSSARY — the codes these notes are full of (added at her ask: "Opus has a mania of making these odd naming schemes")

| code | means | where the list lives |
|---|---|---|
| **PL-n** | **Parity Ledger row n** — what a closed MAC phase says the phone owes; numbered in the order rows were WRITTEN, not by phase (PL-13 ← 13l · PL-14 ← the post-13l polish round · PL-15 ← 13p) | `notes/MobileSoul.md` §6 |
| **PR-n** | **Parity inventory row n** — a Mac capability the phone lacked when the round was inventoried (PR21 = in-note replace; PR20 = block multi-select; PR14 = the lens-dangle notice…) | `mobile-round-2-parity-inventory.md` |
| **M-n** | **Mobile finding n** from the round's own walks/reviews (M1 = the editor crash; M14 = the Read hitch; M16 = the drag question; M23 = copy follows the screen; M27 = the post-divide edit) | `mobile-round-2.md` §-numbered sections |
| **R-n** | **Her Ruling n** in this round (R13 no confirm on delete; R15 copy follows the screen; R16 select-and-delete should just work; R24 "info"; R28 build→review→fix as one unit; R30 the install wait) | `mobile-round-2-orchestrator-handoff.md` §4 |
| **Q-n / #n** | Q-n = a design-record question (Q8 = where the tray's door sits); **#n = a `notes/QUESTIONS.md` entry** (#84 Two rooms · #92/#93 the filters · #94 the hoist deferral) | `mobile-archive-trash-design/README.md` §7 / `notes/QUESTIONS.md` |
| **U-n** | the handback checklist's 13u-owed items (U-1 the fan fence's source … U-5 the `CrossBlockRefusal` hoist) | the standing successor handoff §2b |
| **B45-n / A1-n** | findings from the batch-4.5 investigation / the Act-1 cold read | `mobile-round-2.md` §52 / §56 |
| **a "hoist"** | MOVING a rule out of one app's private code into `App/Variorum/Shared/` so BOTH apps call one copy (the Mac's old names stay as forwarders; the Mac suite passing unmodified is the proof) — the opposite of a **fork** (a second copy that drifts) | MobileSoul §3; the KnownIssues forked-brains row |
| **the #94 hoists' direction** | NOT delivered by the Mac: they are MOBILE-round work postponed until main merges INTO mobile, because they edit `Shared/` and Mac files the Mac phases are rewriting; a Mac phase that happens to touch one hoists it then | `mobile-round-2-fable-seat-handoff.md` §4 |

## H. HER RULINGS AT THIS READ (2026-09-01, verbatim-faithful — the round PAUSES after batch 10)

- **"I think what I want is for you to just install the build on the phone that will be done now,
  at the end of this session, to my phone."** → The seat's closing act after batch 10's unit
  closes: a Release build of the closed tree (`xcodebuild -scheme VariorumMobile -configuration
  Release -destination 'generic/platform=iOS' -allowProvisioningUpdates build`, the parity round's
  recorded road) installed via `xcrun devicectl device install app --device
  *[removed for publication]*
  reads **available (paired)** at this write; the phone must be UNLOCKED at the install moment for
  the bundle to mount (the 2026-08-11 precedent). Marker 7 on both sides — no lockstep risk.
  **First launch note:** whichever build her phone runs today, this one carries 13p — the phone's
  store migrates to the keyed format on the first launch (Auto mode: silent key mint into the iOS
  Keychain; PL-15(b), proven on iOS) — and the pocket guide's corrected lessons (batch 9's tutorial
  fix) reach an already-seeded guide only through its Restore door.
- **"I probably won't finish this round before just finishing the mac side of things … And then
  I'll resume mobile development when 13u is done on the mac side."** → **The round PAUSES at
  batch 10's close.** Batch 8, the leftover-backlog batch, PL-13's faces, the two standalone
  passes and the closeout WAIT for the post-13u resume (the successor handoff carries them in
  order). Nothing closes early; the ledger rows stay open and owned.
- **"especially since the data safety screen still remains and tbh mac is going to have some
  changes still to that story that I've just decided."** → **PL-13's phone faces WAIT for the
  Mac's revised data-safety story** — build nothing there until the Mac phase that carries her
  new decision closes and writes its ledger line; the phone then builds to the RULED shape, never
  the mid-design (the PL-14 precedent she praised).
- Her read of the state: *"most of the obvious product features have been done on the mobile side
  already so I'll be able to get more of a feel for the app."* The install is what turns the
  round's five closed units into her lived experience; the device queue (§C) is what she can
  answer once it is on her phone.

- **DONE 2026-09-01 22:41 MDT — INSTALLED.** Batch 10's closed tree (`3694a82`; app bytes `8cb9c25`,
  mobile 727/103) built Release and installed to her iPhone 17 Pro via `devicectl` (bundle
  `io.lduarte.VariorumMobile`, exit 0). The seat closes; the round is PAUSED. Successor:
  `notes/plans/mobile-round-2-fable-seat-2-handoff.md` §0.
