# VM-10 — COLD REVIEW (Fable, 2026-10-07)

**Scope reviewed:** `git diff 0f0624e7..9946eded` (the whole unit), the record
(`vm-10-the-write-scroll-authority.md`), QUESTIONS #200, the four production files read in
context, the test file, the walk's captures (viewed: 01, 02c, 04a, 07c, 08b, 09a), and the
unit's two suites re-run by this reviewer on a fresh derived-data path
*[removed for publication]*
readings byte-matching the record (end-⏎ 1721.7 → 1754.3, first visible 1922 · short note
0 → 0, first visible 1 · memory re-entry 881.3 @ char 970). The FULL mobile suite was NOT
re-run here; the record's 818/128 line stands as the implementer's.

## Findings (severity-ranked)

**[MINOR 1] · `App/Variorum/VariorumMobileTests/MobileWriteScrollAuthorityTests.swift:215` and `:245-246` · two guards' doc comments claim "RED ON OLD" — both were GREEN on old.**
`aRelayoutAfterHerScrollUpNeverForcesTheRoom` (:215, "RED ON OLD — the number lands in the
record") and `typingAfterScrollingTheCaretAwayRevealsItMinimally` (:245-246, same words,
plus ":245's `used to throw the page back onto the room`") contradict the record's own
provenance block ("GREEN ON OLD (guards, not pins — recorded so nobody counts them as
red-on-old): … aRelayoutAfterHerScrollUpNeverForcesTheRoom … and
typingAfterScrollingTheCaretAwayRevealsItMinimally (old: 587.3 → 1717.7, caret at the foot
— minimal)") and the dispositions table's arm-3 row ("Guards green on old: …"). The :245
prose is also wrong about its own scenario: typing at a text end with NO trailing newline
was minimal on old — the implementer's trace established the room padding attaches only to
the trailing empty-line fragment. Why it matters: pin provenance in test files is
load-bearing under the hallucination guard — a future ladder reading these comments counts
two red-on-old pins that never existed. **Fix:** reword both comments to the record's
guard language. Doc-only; no pin.

**[MINOR 2] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift:373, :396` + `notes/QUESTIONS.md` #200(a) · rule 2's refusal is origin-blind: for 0.6 s after her pan it swallows reveals she just asked for through a NON-pan door — and #200(a)'s option text does not tell her so.**
Two concrete roads, mechanism traced: **(i)** typing within 0.6 s of a pan release with
the caret off-screen — the keystroke's reveal (`_scrollToCaretIfNeeded` /
`_scrollToSelectionIfNeeded` → the choke point) hits `herGestureHolds()` at :373 and
returns; the character lands with the caret invisible until the first keystroke after the
window (self-healing, ≤ 0.6 s of blind typing). **(ii)** the find navigator — live on this
surface (`isFindInteractionEnabled = true`, :946; `presentFindNavigator`,
`MobileEditorViewModel.swift:1022`): a "next match" tap within 0.6 s of her pan has its
scroll-to-match reveal refused — the match highlights but the page does not move (a second
tap works). Leg (ii) is code-traced (the implementer's own trace: every reveal on this
surface passes `scrollRectToVisible`), not run in-window by this reviewer. No existing pin
is dishonest — `typingAfterScrollingTheCaretAwayRevealsItMinimally` never stamps the clock,
so it covers the AFTER-window case only — but **#200(a)'s option (i) claims only that "a
deliberate tap to type a moment later is never swallowed,"** which is true for taps solely
because a tapped caret is already visible; her ratification record understates the window's
real cost. **Fix:** one sentence in #200(a) naming the two swallowed-reveal roads so she
ratifies the real tradeoff; optionally void the quiet window from the edit door
(`insertText`/`deleteBackward` are this subclass's own methods — typing is her newest
intent), which closes (i) without touching the fight's fix. A red-on-old pin for that
optional half exists: `noteHerScroll()`, clock +0.3 s, `insertText` with the caret
off-screen → stays off-screen on the current tree. Severity MINOR, not MAJOR: both roads
are ≤ 0.6 s wide, self-healing, and the window is already PROVISIONAL at #200(a).

**[NIT 3 — SPECULATIVE] · `MobileEditorTextView.swift:391-401` · system-initiated animated scrolls that are morally hers meet layer 2.**
VoiceOver's three-finger page scroll and `scrollsToTop` (status-bar tap) ride animated
programmatic moves: clamped at the text's foot (a VO user cannot page into the room —
defensible, nothing readable lives there) and refused entirely within the 0.6 s window.
Not traced on-device (VO's exact road unverified — hence SPECULATIVE); belongs with the
13r accessibility pass, not this unit.

**[NIT 4] · one small concept in three files.** `MobileWritePlace`
(MobileEditorTextView.swift), `MobileWritePlaces` (MobileWriteView.swift:41), the owner
property (MobileShellRouter.swift:54). The comments cross-reference and the split follows
the brief's fence, so cosmetic only; no action.

## Clean bill (the adversarial list, each item checked)

1. **The two layers + the pan clock.** Her pans/flings provably bypass both overrides
   (pans move the offset through the non-animated road; `animated: false` passes straight
   through at :392-395) — the fence binds programmatic moves only. `jumpToBlock` and
   `restore` are unanimated by design (MobileEditorViewModel.swift:1134;
   MobileEditorTextView.swift:544/548) and survive untouched; the block-list jump's
   `scrollRangeToVisible` fallback is clamped-but-runs; a match/caret rect in text never
   crosses `textBottom` except the trailing empty-line fragment — the clamp's exact target.
   The in-window swallow is MINOR 2. The second layer's `max(self.contentOffset.y, foot)`
   (:399) never pushes her deeper into the room than she already stands — verified.
2. **The one-shot re-reveal.** No loop: `revealGrantedAt` is reset BEFORE acting (:425),
   and only `scrollRectToVisible` ever stamps a grant — the one-shot's own
   `setContentOffset` does not — so the chain terminates after one verify per grant. It
   respects the pan clock (`!herGestureHolds()`, :426) and routes its own move back through
   the overridden `setContentOffset`, keeping the room clamp and gesture rule. `textBottom()`'s
   two-source min with the caret floor is the honest TEXTKIT2-§2 answer to estimation
   drift: an under-estimate is rescued by the caret floor, an over-estimate by the one-shot
   (the record's 15/15 refocus evidence). No exclusion paths, no attribute stamping — the
   §3 iOS findings are honored; all TK2 reads are one-fragment/.ensuresLayout or
   viewport-local.
3. **The session memory.** Content-anchored, never a raw pixel offset (the Mac's measured
   lesson honored); caret AND anchor clamped to today's text at restore; session-only,
   never persisted or synced; keyed by note; entries are tens of bytes, so the
   AppSession-autosave-map lesson does not bite; a deleted note leaves one inert dict
   entry; the fence excursion is a single stored property on the session-lived router
   (PROVISIONAL #200(c)) — proportionate, with the Mac's `EditorRouter.scrollPlaces` as
   precedent. `aNoteNeverVisitedOpensAtTheTop` guards the memory against inventing places.
4. **Arm 1(a)'s HOLLOW verdict — re-derived, honest.** Pre-fix there was no memory, so no
   arrival road could land anywhere but the first render's top. The adversarial roads check
   out: a Library push (focus=false) restores and issues no reveal; the Today door's
   re-entry with the caret at the end (focus=true) reveals HER caret through the clamp —
   the exact rect class pinned red-on-old in arm 2 — and the walk's 09a/09b (viewed) show
   it landing minimal with memory. Her "shows none of the text" is explained and fixed by
   the reveal clamp regardless of which door produced it; the hollow is recorded, not
   papered.
5. **Pins and captures.** Both suites re-run by this reviewer: 10/10 green, numbers
   matching the record exactly. The red-on-old numbers are quoted from TWO independent runs
   (the pre-fix tree and the behavioural revert under the final pin file) and are
   arithmetically coherent with the traced mechanism — including why the short-note red
   (254 pt) repeats across keyboard modes: under a bottom-aligned room-padded rect the
   landing offset is viewport-independent. No pin is green-over-nothing: each asserts
   concrete offsets and first-visible characters. Captures viewed (01, 02c, 04a, 07c, 08b,
   09a) each match their recorded verdicts; 04a/04b genuinely show a mid-note misfire and
   are labelled as such in the record.
6. **Her rule's other half — empty space stays reachable, never clawed back.** Pans bypass
   both layers; idle relayouts issue no reveal (the record's trace fact (i)); the only
   post-window reveals are typing (reveals her caret — the ruled shape) and keyboard
   placement (clamped at the text's foot, never deeper than she stands). Honest gap,
   stated: the walk's room-rest capture (04a) misfired, so no artifact directly shows a
   deliberate room-rest sticking — the claim holds by code-reading plus 08a/08b's
   no-claw-back evidence.

**Also verified:** the fence (diff --stat is exactly the 4 production files + 1 test file
+ the record + QUESTIONS + the brief-sanctioned `.gitignore` line; zero `Shared/`,
`Sources/`, `Sync/`, schema, project/scheme); QUESTIONS #200 well-formed, next-free marker
moved to #201; the NOT-DONE list leads the record; the room's existence untouched
(`updateTypewriterRoom` unmodified; `MobileTypewriterRoomTests` green in my run's
neighborhood per the record); the gate delegate's `scrollViewDidEndScrollingAnimation`
forward touches scroll traffic only; `notePlaceIfMoved` is equality-gated and
viewport-local (P1 clean; the record's full-suite run carried `MobilePerfWalkTests` green);
no KnownIssues entry owned by this unit is left unresolved.

**Disposition recommendation:** 0 BLOCKER / 0 MAJOR at round 1 — per the cast's ladder
shape, one fix wave (MINOR 1's two comments; MINOR 2's #200(a) sentence, with the
edit-door window-void as an optional pinned half) + orchestrator verification closes.

---

## DISPOSITIONS (orchestrator — 0B/0M ⇒ one wave + verification closes, the standing shape)

| finding | disposition |
|---|---|
| MINOR 1 (two guards' comments claimed RED ON OLD falsely) | **FIXED** — both reworded to the record's guard language; provenance in test files is load-bearing and now honest |
| MINOR 2 (the 0.6 s window is origin-blind; #200(a) understated it) | **(a) FIXED** — the CONSEQUENCE ADDENDUM on #200(a) names both swallowed-reveal roads verbatim, so her ratification is on true consequences. **(b) the optional edit-door voiding is DELIBERATELY LEFT AS #200(a)'s option** — it is a behavior choice inside an already-PROVISIONAL window; her one word picks it (red-on-old pin specified by the reviewer, one small arm) |
| NIT 3 (VoiceOver/scrollsToTop interactions, speculative) | **ROUTED** — VX-59 (the whole-app accessibility pass) gains the note; 13r's deferred-post-🚀 pass owns the device verification |
| NIT 4 (one concept in three files) | recorded; no action (the reviewer's own call) |

Orchestrator verification: the unit's two suites re-run green post-wave (10/2); the wave is docs-only (test comments + QUESTIONS), zero production lines.
