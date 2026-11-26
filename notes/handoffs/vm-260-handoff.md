# VM-260 — your handoff: the phone's look, the explicit changes (2026-11-25)

Everything you asked for is built, and the phone side is checked and green. **Two things are left: the Mac's whole
test run, which waits for you to say "done looking" (the dev store is still dressed for your VX-1036 look), and then
the merge.** After that the umbrella's real close is yours: how it feels on your phone.

## Your checklist

1. [ ] **Say "done looking"** when you have finished with the dressed dev store. Then the whole Mac target runs
   (about an hour) and, if it reads at main's baseline, the branch merges. **PENDING.**
2. [ ] **Install the build on your phone** (§1). It needs no stage and changes nothing in your store.
3. [ ] **Try the things in §2 first.**
4. [ ] **Judge the PROVISIONAL sets on the phone** (§3; every call is QUESTIONS #286).
5. [ ] **Answer four open calls** (§4): R1-7 · C-4b-1 · R1-4 · R1-2.
6. [ ] **Confirm three short addenda** (§5): QUESTIONS #281 (2) · #277 (2) · #280 (2).
7. [ ] **Look over the tickets this run filed** (§6), grouped by priority.
8. [ ] Later, at your own pace: **the wording pass** — every new sentence is listed at the foot of QUESTIONS #286.

## 1 · The build for your phone

The app is pre-built and signed from **`<TIP>`**. No schema or migration rides this run, and it keeps the same bundle
id, so your phone's store carries over untouched.

```sh
# 1 — have the phone plugged in or on the same network, then find its identifier:
xcrun devicectl list devices

# 2 — install (put your phone's identifier in):
xcrun devicectl device install app \
  --device <your-phone-identifier> \
  ~/dev/variorum-vm-260/App/Variorum/DerivedData/vm260-device/Build/Products/Release-iphoneos/VariorumMobile.app
```

If the phone refuses the developer signature, trust it once under Settings ▸ General ▸ VPN & Device Management.

## 2 · What to try first

- **A note with the keyboard up** (your screenshot's frame). The title has its own row, centred and wrapping; under it
  one row of six icons — copy · find · book · # · blocks/lens/more info · ⋯ — with no line between them. Scroll down:
  the title goes and only the row stays. Type low in the note: the page gives the room back. (This is still the
  standing first thing to try.)
- **On that row:** # opens the note's tags in place, and the same # closes them. The book icon is grey when the note is
  in no book, and a tap adds it to one. The stack icon opens blocks · lens · more info. ⋯ opens the Note sheet, with
  Lock and the date as two easy buttons at its top.
- **Swipe between Bookcase and Library.** The bar stays still; only the highlighted word moves.
- **Leave a page with a note open** (go deep in the Library, then tap Bookcase) and come back by the bar. The page is at
  its root, and the note was closed with its one quiet savepoint, as Back closes it.
- **The top lines.** Each root says the wing's name alone, with no count. The trash is on the Library only; New Note is
  the pencil; the gear opens Settings.
- **Scroll the Library down.** The top folds into one slim line. Nudge up and it comes back; tap the slim line's search
  icon and the field opens with the keyboard.
- **A refusal.** In an empty note press copy: one short line with "›" and ✕. Tap it for the reason (it stays while you
  read), flick it down, or leave the note with it up — it leaves with you. A direction now reads grey, not red.
- **Settings ▸ Look:** Voice · Colour palette · Background (Paper · Cream) · Appearance · Text size. All of it is this
  phone's own now; your Mac doesn't move when you change it, and the phone no longer wears the Mac's colours.
- **The keyboard after a note.** Open a new note with the keyboard up, go Back, open the Library search: the bar rides
  on top of the keyboard (VM-281, the fix you sanctioned). Back from a note with its keyboard up: it leaves once.
- **The Blocks sheet while picking:** "Cancel" beside "Done" — no more two "Done" buttons.

## 3 · The PROVISIONAL sets to judge on the phone (QUESTIONS #286 has each with its options)

- **The drawn step-down as one set** (P-260-2a…2d): chrome one notch under your words, icons 17 pt in their 44-pt tap
  areas, near-square chips, the Mac's two corners (4 and 8), field and button boxes 36 tall, the note's title at 20.
- **The text-size steps and the smaller default** (P-260-3a/3b): five steps, whole points; Large is wave 1's size back.
- **The look's details** (P-260-3c…3e): the palette as the system menu in the Mac's words; the cream on the note in
  Write only, black in dark.
- **The message line's card** (A-260-4): a floating card clear of the bar and the screen's sides.
- **The slim top's feel** (P-260-4a-1, C-4a-1…8): how far you scroll before it folds, and how small a nudge brings
  it back.
- **The note's top details** (C-4b-2…13, P-260-4b-1): 100 pt at rest under a one-line title, 48 scrolled.
- **The small ones:** the bookless book icon's grey (C-G2-1); "Cancel" on the Blocks sheet (P-260-3b-1); the push
  that doesn't open and says where its note landed (P-260-1a).

## 4 · Four open calls that need your word

- **R1-7.** An opened reason card raised on a Bookcase, Library or Starred page stays up until its ✕, a flick or a newer
  message. Should a page change close it? The orchestrator recommends yes; it stays for now.
- **C-4b-1.** Your drawing has the title ride away with your text frame by frame. That needs a change inside the
  editor itself, so it was built as a quick slide instead: the title and your text move together once as you leave the
  top. Feel it on the phone; the frame-by-frame version is an editor change with its own Fable review, at your word.
- **R1-4.** With the chips gone, the lens state shows as the stack icon's colour (the accent, or red when a pick fell
  back), not in words on the page. Keep it, or add a word or mark there?
- **R1-2.** On Back from a note, the bar is drawn over the leaving note for the slide (about a third of a second).
  The walk saw it as mild and no ticket was filed. Keep it, or ticket a small fix?

## 5 · Three addenda to confirm

- **QUESTIONS #281 (2) — wave 1's forty-one look calls, against what shipped.** Nine are settled by this run, four are
  partly overtaken, and twenty-eight stand open as built.
- **#277 (2) — VM-55's message-line calls.** P-55-19 is built (the neutral colour), and P-55-3's refusal arm is replaced
  by your VM-277 ruling.
- **#280 (2) — P-71-1 retired.** Your "Note closes on leaving" made every page change a leaving.

## 6 · The tickets this run filed

- **High:** **VM-281** — the next keyboard after a note's keyboard sat 52 pt low and hid the bar. **Fixed in this
  run** at your word, as the run's one change inside the editor.
- **Medium:** **VM-282** — the Fable review round over the whole diff (VM-281's editor change first, then the editor's
  look file), at your R-260-10. It does not gate this merge.
- **Low:**
  - **VM-279** — the editor's own refusals get short headlines; they use the one-line clip meanwhile.
  - **VM-280** — a field's 44-pt tap area may be drawn only. Measured: the field's own view is about 22 pt tall.
  - **VM-283** — one phone helper for the refusal slot, instead of thirteen copies.
  - **VM-284** — a short note's page hops a few points when the note's top changes height. The cure is in the editor
    and waits for VM-271.
  - **VM-285** — an unlabelled element on the note page that VoiceOver can stop on. It is older than this run.

## 7 · Where the run stands

- **Built:** all eleven members, plus VM-281 and the Blocks sheet's "Cancel", in seven batches; two review rounds on
  Opus (one major, fixed); three findings from the merge gate's checks, each fixed with a test that failed on the old
  code.
- **The phone gate is green** at code tip `a8c0a49ad`: the whole phone test target, 1,335 tests in 239 suites, with
  only main's 6 known issues; the four keyboard tests green; every bug fix's test red on the old code and green on
  the new; the walk's captures read.
- **PENDING:** the whole Mac target (at your "done looking"; main's baseline is 0 failed, 14 known), then the merge.
  If the Mac run finds anything, this handoff and the record say so before the merge.
- **Not done here, on purpose:** the title's frame-by-frame ride (C-4b-1); the editor's own refusal headlines
  (VM-279); renaming a note in place on its top (VM-148's); the Mac's toasts (untouched — yours to say later); a count
  for each shelf on the phone (waits for the phone's shelves, VM-113).
- **The rulings, re-read against what shipped:** R-260-5's "leaving a page returns it to its root" holds on every road
  (the Protection ask's road by construction, with no test of its own). VM-277's shorter, dismissable refusals hold for
  every refusal spoken through the shared table; the editor's own refusals still use the clip (VM-279). VM-273's
  "phone-wide" step-down lives in the central files; two remainders are recorded but not ticketed: the segmented
  control keeps the system's track, and a few hand-built corners elsewhere stay as they are.
- **Captures,** local only: `notes/plans/vm-260-screens/` (`batch-1a`, `batch-1b`, `batch-2`, `gate`, `gate2`).
- **Canon changed:** AppSpec §12 (the phone's look is the device's own); SurfaceContracts — the phone's look, sizes and
  drawn step-down, the bar and the leaving law, Settings ▸ Look and the gear, the message line's card, the Library's
  slim top, the roots' top lines, the note's top; MobileSoul PL-84 (the mobile parity row).
  `Tools/canon-size`: `144596  total (harness limit 150000, headroom 5404)` — no crossing.
- **The record:** `notes/plans/fixes/vm-260-phone-look.md` (FOR A LATER READER at its top); the AppSpecRecord entry of
  2026-11-25.
