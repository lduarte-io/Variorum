# VM-260 — the morning handoff (2026-11-25, written ~06:4x by the overnight orchestrator)

## 1 · FIRST: the fresh build for your phone (R-260-7)

The app is PRE-BUILT and signed — nothing compiles while you wait. It is the run's code tip **`54c0d1cc8`**
(batches 1a + 1b + 2 + 3 and the keyboard floor, with main merged through PR #28): the new bar, the top lines,
the message-line card, the whole drawn step-down, the note's top, and Settings ▸ Look per-device with the
text-size row.

```sh
# 1 — plug in or have the phone on the same network, then find its identifier:
xcrun devicectl list devices

# 2 — install (substitute your phone's identifier):
xcrun devicectl device install app \
  --device <your-phone-identifier> \
  ~/dev/variorum-vm-260/App/Variorum/DerivedData/vm260-device/Build/Products/Release-iphoneos/VariorumMobile.app
```

If the phone refuses the developer signature, trust it once under Settings ▸ General ▸ VPN & Device
Management. Your store is untouched by the install (same bundle id, data carries over).

**What to try first:**
- Swipe between the three pages — the bar stays put while the pages slide (VM-253).
- Leave Library deep in the Trash, come back by the bar — it stands at its root (VM-256).
- The roots' top lines: the wing's name alone with its count under it; the trash door only in the Library;
  the gear where the ⋯ was (VM-255).
- The drawn step-down everywhere: 17-pt glyphs in their 44s, near-square chips, the Mac's two corners,
  chrome words one notch under yours (VM-273 — the whole set is yours to judge, P-260-2a…d).
- A note's top: title 20, the four tools quiet, the rows sitting on one another (VM-272).
- The message line: in an empty note press the copy tool — the one-line card with "›" and ✕; tap it for the
  reason (it stays while you read); flick it down; leave the note with a refusal up — it leaves with you
  (VM-265 · VM-275 · VM-277).
- Settings ▸ Look: voice, colour palette, background (Paper · Cream) and text size are now THIS PHONE's own —
  the Mac and the library's synced look are untouched (VM-247 · VM-254).
- **One known wart, already filed:** after a note's keyboard, the NEXT keyboard (e.g. the Library search) can
  sit 52 pt too low and hide the bar — VM-281, see §3. Dismiss the keyboard and reopen and it recovers.

## 2 · Your pick: the Library's top giving way (VM-259 — batch 4 waits on this)

Open **`notes/plans/vm-260/vm-259-options.html`** locally — three phone frames that really scroll, drawn at
the corrected sizes: **A** the whole top slips away with the paper · **B** a pinned slim bar (VM-148's rhyme)
· **C** the wing line stays, search and filters fold. Each says what the Bookcase and Starred would do.
Batch 4 builds only after your pick.

## 3 · Needs your ruling (bundled overnight, per your away ruling)

- **VM-281 (High) — the keyboard cure.** The bar-under-keyboard defect REPRODUCED on the old app and the new
  floor guard does NOT cure the original road: both SwiftUI's avoidance and UIKit's keyboard guide report the
  stale 52 after the editor's accessory keyboard. The traced cure is dropping the editor's accessory as its
  text view resigns — an **editor-seam line**, yours to sanction here or fold into VM-271.
- **VM-280 (Low, Suspected)** — a field may answer taps only across its text, not its drawn box; the window
  added a datapoint (the field's measured frame came out 39, not 44 — being reconciled, see §4).
- **The PROVISIONAL sets to judge on your phone:** P-260-2a…2d (the step-down as one set; the note title at
  20; the bar chip's corner; the 36-pt boxes), P-260-3a…3e (the text-size steps and smaller default; the
  system palette menu; cream as Write's room only, black in dark; the Read page keeping its own table), the
  floating card shape (A-260-4e), and the DRAFT words (the direction line's sentence, the long refusals'
  draft headlines — the full word list is in the record for your wording pass).

## 4 · Where the run stands (honesty block)

- **Built and window-verified:** batches 1a, 1b, 2 (red-on-old established for every bug-class pin that could
  be; the live line walk green; Mac legs green; both keyboard UI tests green ×2 bundles).
- **Built, evidence part-pending:** batch 3 (its red-on-old is established and its keyboard UI test green;
  its whole-target and Mac legs are queued with nov24; its captures come with the gate window).
- **Open reconciles before the ladder** (each owed to its own implementer, in flight this morning): batch 2's
  field pin measured 39/39 against laws 38.5/43.5 — drawing vs target to settle; the note top measured 145
  against its 140 cap; 1b's mounted leave-the-note walk step and the card pin's harness road (the LIVE
  behavior is proven — walk captures `notes/plans/vm-260-screens/batch-1b/`).
- **Not started:** batch 4 (your pick), the ladder (fresh reviewer per round, cap five), the merge gate
  (on a tree containing PR #27 — already merged in), closeout and canon deltas.
- **Captures for your eyes:** `notes/plans/vm-260-screens/batch-2/` (before/after; the after run's "s" pass
  accidentally ran in Terminal — Study after-shots come with the gate window's retakes) and `batch-1b/`
  (the line's walk). The gitignored folders stay local.

## 5 · Tickets this run has filed so far

- **VM-279** (Low) — authored headlines for the editor-spoken refusals (deferred behind the editor fence).
- **VM-280** (Low · Suspected) — the field's answering height (§3).
- **VM-281** (High · Needs Lillian) — the keyboard cure, editor seam (§3).
