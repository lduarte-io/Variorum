# iOS text input under a block model: external research

Compiled 2026-11-22, for devices on iOS 27.0.x with a deployment target of iOS 26. Each fact carries its date and iOS version. Where the newest source is older than iOS 26, the fact says so. "Inference" marks my own reasoning and is never presented as a sourced fact.

Source types used below: AD = Apple documentation · WWDC = WWDC session · AE = Apple engineer on the forums (DTS or Frameworks Engineer) · OSS = open-source code or PR · DEV = developer forum report · BLOG = developer blog · PRESS = press.

---

## 1. Which UITextView changes bypass `textView(_:shouldChangeTextIn:replacementText:)`?

**Answer.** Apple documents the delegate only for typing and deleting ("whenever the user types a new character or deletes an existing character"). It does not promise coverage of any other input road. The developer record shows several roads that skip it, call it twice, or call it with a range or string that does not match what actually changed in the storage. Every road that changes visible text must end in an `NSTextStorage` edit, because the text view draws from storage. That is why the storage delegate is the reliable observer: one tested report (2020) caught every case its author tried. I found no source that measures how accurate `editedRange` or `changeInLength` is per road on iOS 26 or 27. On iOS 26 and later the single-range delegate is being replaced by `textView(_:shouldChangeTextInRanges:replacementText:)`. Apple's docs list the old method as available iOS 2.0 to 27.0, which marks it deprecated at 27.0. If only the old method is implemented, it receives the *union* of the ranges.

**Evidence**
- The delegate is documented for typing and deleting only. Its availability is listed as "iOS 2.0.0 – 27.0.0", i.e. deprecated. https://developer.apple.com/documentation/uikit/uitextviewdelegate/textview(_:shouldchangetextin:replacementtext:) — AD, current docs — high.
- The multi-range replacement (iOS 26): "the text view will, at its own discretion, choose any one of the specified ranges… and replace it… before deleting the text at the other ranges. If the delegate does not implement this method then [the single-range method] will be called and passed the union range instead." https://developer.apple.com/documentation/uikit/uitextviewdelegate/textview(_:shouldchangetextinranges:replacementtext:) — AD, iOS 26 — high.
- WWDC25 "Enhance your app's multilingual experience" (Natural Selection): in iOS 26 a selection in bidirectional text becomes several `selectedRanges`. The ranges delegate is "triggered whenever the text input system needs to modify the text… for instance… paste". The insertion point among the ranges is chosen "based on various factors, including the currently used keyboard". https://developer.apple.com/videos/play/wwdc2025/222/ — WWDC, iOS 26 — high.
- **Marked text / IME:** the delegate *is* called for each marked-text step. An Apple DTS engineer showed this with Japanese Kana on iOS 26.1 (23B85). However, `markedTextRange` is not yet updated for the incoming text when the delegate runs. DTS: uncommitted input "is still at the input-method level, which the app does not have access to… defer the action until… the change is committed." The OP of the same thread reports that the delegate also fires during **undo** and **Writing Tools** operations (OP observation). https://developer.apple.com/forums/thread/808915 — AE, Dec 2025–Jan 2026, iOS 26.1 — high for IME, medium for undo and Writing Tools.
- **The IME's storage edit differs from what the delegate is told:** with Zhuyin on iOS 18, each keystroke reported `replacementText` = one character, but the storage gained two (the character plus an invisible U+2004). On a Pinyin keyboard on iOS 18.2.1, DTS observed U+2006 spaces. DTS confirmed the spaces are "actually stored in `textView.text`" inside `markedTextRange`. https://developer.apple.com/forums/thread/772511 — AE, Jan 2025, iOS 18.2.1 — high.
- **iOS 26 changed the range shape for a candidate commit:** on iOS 18, committing "王" over marked "ㄨㄤ" reported range {0,2}. On iOS 26 the ranges method reported [{2,0}]. No Apple answer. https://developer.apple.com/forums/thread/801003 — DEV (UITextField), Sep–Nov 2025, iOS 26 — medium.
- **Korean:** `markedTextRange` stays nil throughout Korean composition, which means the composing syllable is ordinary storage text that is rewritten in place. DTS: this "looks like a bug". https://developer.apple.com/forums/thread/787069 — AE, Jun 2025 (UITextField) — medium.
- **Double calls:** on iOS 17.0–17.2, Cangjie, Sucheng and Stroke keyboards produce a second, bogus call for a single insertion (replace {n,0} with ""). This desynchronises any model that is driven by the delegate. Still reported in Aug 2024. https://developer.apple.com/forums/thread/741038 — DEV, iOS 17 — medium.
- **Long-press delete:** on the iOS 17 beta the delegate fired only once for a held delete key (on iOS 16.3.1, once per character). Apple asked for a Feedback report (FB12360292). No resolution is recorded. https://developer.apple.com/forums/thread/731885 — DEV + AE, Jun 2023, iOS 17 beta — medium (may be fixed).
- **Swipe ("gesture") typing:** one report that the delegate is not called. https://developer.apple.com/forums/thread/736183 — DEV, Aug 2023, unanswered — low.
- **Wrong ranges:** deleting a selection that follows an attachment reported {0,6} when only 5 characters were deleted (iPhone 13, iOS 17.1.2). https://developer.apple.com/forums/thread/741409 — DEV, Dec 2023 — medium.
- **Double-space period, and a suggestion tapped while the whole word is selected:** neither reached `shouldChangeTextIn`, and the second case did not even post `textDidChange`. An `NSTextStorageDelegate` `didProcessEditing` observer caught every case the author tried. https://developer.apple.com/forums/thread/649121 — DEV, Jun 2020, iOS 13/14 era — medium (old).
- **Autocorrect on space / the prediction bar with the caret at a word's end:** the same 2020 thread reports these are delivered ("if the caret sits at the end… the change is reported"). I found no 2024–2026 source that confirms the range and string. — low/medium.
- **Writing Tools** "alter your text storage… you should not persist text storage when Writing Tools is active". The guidance is to pause syncing in `textViewWritingToolsWillBegin` and check `isWritingToolsActive`. https://developer.apple.com/videos/play/wwdc2024/10168/ — WWDC, iOS 18 — high.
- **Text replacement (user shortcuts):** `autocorrectionType = .no` does not disable it. Whether it asks the delegate is not reported. https://developer.apple.com/forums/thread/723236 — DEV, Jan 2023 — low.
- **Programmatic storage edits** bypass the delegate by definition. An Apple Frameworks Engineer says they also bypass "the middle layer that tracks updates and deletions to the text view" (undo breaks). https://developer.apple.com/forums/thread/730221 — AE, Jun 2023 — high.
- **Scribble** is an iPad (Apple Pencil) feature and does not apply on iPhone. **Dictation, drag-and-drop, the spelling-correction menu, shake-to-undo:** I found no report either way on whether they ask the delegate on iOS 26 or 27. — unknown.
- **"Widened range" on iOS:** I found no source documenting `editedRange` wider than the real change on iOS 26 or 27. Apple's archive docs say `edited(_:range:changeInLength:)` accumulates "the range of its characters affected since… beginEditing" and that `processEditing` fixes attributes over that recorded range. So any batched UIKit edit (for example, a correction plus a space in one editing session) arrives as one unioned range. That consequence is inference. https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextStorageLayer/Tasks/ChangingTextStorage.html — AD (archive) — medium.

## 2. Inline predictions (iOS 17+)

**Answer.** The grey completion is delivered to the text view as **marked text**. UIKit calls `setAttributedMarkedText(_:selectedRange:)` with the predicted suffix, styled with a system-grey foreground and a clear background, and with the selection at offset 0 inside the marked range, which puts the caret before the grey text. UITextView puts marked text into its text storage (DTS confirmed this for IME marked text). So while a prediction shows, it is very likely real characters in the storage, inside a non-nil `markedTextRange`. That last step is inference for the prediction case specifically: it is consistent with every source below, but I found no published log of a UITextView's storage during a prediction. A custom `UITextInput` that does not implement `setAttributedMarkedText` gets no inline predictions at all. Setting `inlinePredictionType = .no` removes the grey completions for that view and leaves the prediction bar alone. I found no published UIKit-level description of exactly what accepting (space or tap) or rejecting (typing on, backspace) does to the storage.

**Evidence**
- WebKit's iOS text view (main branch, Nov 2026): "UIKit doesn't include the `NSTextCompletionAttributeName`, so the next best way to detect if this method is being used for a text completion is to check if the attributes match these hard-coded ones": `NSForegroundColorAttributeName: UIColor.systemGrayColor, NSBackgroundColorAttributeName: UIColor.clearColor`, inside `setAttributedMarkedText:selectedRange:`. https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/WKContentViewInteraction.mm — OSS (Apple-maintained), current — high.
- WebKit commit 286628@main (Nov 2024): "surface the predicted text as marked text when UIKit requests the current document editing context… This allows the system (e.g. the software keyboard) to show additional UI." Its test sets marked "lo" after "Hel" with selection {0,0}. https://github.com/WebKit/WebKit/commit/c2ce8f771a56e311b3e1d8ed5634989575ef1c7c — OSS, iOS 18 era — high.
- Flutter engineer (Apr 2025): "Our current `UITextInput` does not implement setAttributedMarkedText… so the prediction is not showing." The engine now forwards it to `setMarkedText` with the comment "iOS 17+ inline predictive text uses setAttributedMarkedText:selectedRange:". The engine defaults to `inlinePredictionType = .no` unless the app opts in. https://github.com/flutter/flutter/issues/135221 · https://github.com/flutter/flutter/blob/master/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterTextInputPlugin.mm · https://flutter.googlesource.com/mirrors/packages/+/69dea74fb3fd4c2b05bc4a7d0d34343a98ab86fb — OSS, 2025–Apr 2026 — high.
- DTS: marked text, including IME-inserted spaces, is stored in `textView.text` inside `markedTextRange`. https://developer.apple.com/forums/thread/772511 — AE, iOS 18.2.1 — high (for IME; by analogy for predictions).
- `inlinePredictionType` (iOS 17): default `.default`. "You might want to turn off inline text predictions if your app provides its own text suggestions." `textView.inlinePredictionType = .no`. https://developer.apple.com/documentation/uikit/uitextinputtraits/inlinepredictiontype — AD — high. Users have a separate "Show Predictions Inline" toggle since iOS 17.2. https://9to5mac.com/2023/11/14/ios-17-2-disable-inline-text-predictions/ — PRESS.
- **Known bugs when the app changes text or selection during predictions:** React Native's fully controlled UITextView-backed input drifted its cursor and inserted characters mid-word when it re-set the attributed string while autocorrect or inline predictions were on. Turning both off removed it, a maintainer saw it in native apps too, and the fix was to stop rewriting when the text is effectively equal (Oct 2024). https://github.com/facebook/react-native/issues/44157 — OSS, iOS 17–18 — medium-high. WebKit had to drop its own prediction state on any selection change that does not continue the suggestion (`Editor::respondToChangedSelection`). Its selection-after-accepting test broke on iOS 17 and 18 (bug 284380). https://bugs.webkit.org/show_bug.cgi?id=284380 — OSS — medium.

## 3. Changing text programmatically while the keyboard is mid-input

**Answer.** Three findings from Apple and the largest cross-platform text stack agree:
- Do not decide anything about uncommitted (marked) input; defer until it is committed.
- Make programmatic edits through the text-input API (`insertText(_:)`, `replace(_:withText:)`), not by editing `textStorage` or setting `attributedText`, if undo and input state are to stay coherent.
- Never rewrite text synchronously inside a UIKit text-change callback. React Native's October 2026 change makes delegate callbacks "decision-only": it rejects the system edit and applies an *incremental* `UITextInput` replacement on the next main-queue turn, only if the base text is unchanged and no marked text is present. "Marked-text composition remains UIKit-owned."

Setting `attributedText` is reported to kill dictation and to break Korean input. Custom `UITextInput` views must bracket their own changes with `inputDelegate?.textWillChange/textDidChange` and `selectionWillChange/selectionDidChange`. UITextView manages its private input delegate itself, and I found no Apple guidance for calling it on a UITextView. I found no authoritative statement on whether UITextView shifts the selection for storage edits made before the caret. The only report found is that developers shift it by hand.

**Evidence**
- AE (Frameworks Engineer, Jun 2023): "By modifying a UITextView's textStorage directly, you're circumventing the middle layer that tracks updates… I would suggest calling the various methods on UITextInput… `insertText(_:)`… `replace(_:withText:)`… set `typingAttributes` before calling." https://developer.apple.com/forums/thread/730221 — high.
- AE (DTS, Jan 2026): defer until the input commits; uncommitted text is "at the input-method level". https://developer.apple.com/forums/thread/808915 — high.
- React Native commit 6f67e185ad (21 Oct 2026, PR #59239): "UIKit text change delegate callbacks now remain decision-only… rejects the original UIKit edit… applies an incremental `UITextInput` replacement on the next main-queue turn after validating the backing-view generation and base text… without synchronously replacing the full attributed string or selection. Marked-text composition remains UIKit-owned… Stale edits are discarded when the backing text changes." The drain skips when `markedTextRange != nil`. https://github.com/facebook/react-native/commit/6f67e185ad · https://github.com/facebook/react-native/blob/main/packages/react-native/Libraries/Text/TextInput/RCTBackedTextInputDelegateAdapter.mm — OSS, iOS 26/27 era — high.
- React Native source comments: "When the dictation is running we can't update the attributed text… because setting the attributed string will kill the dictation… updating the attributed text while inputting Korean language will break input mechanism." The system also adds `NSOriginalFont` for emoji. RN falls back to plain-string comparison whenever `markedTextRange` is set, during dictation, or in Korean. https://github.com/facebook/react-native/blob/main/packages/react-native/React/Fabric/Mounting/ComponentViews/TextInput/RCTTextInputComponentView.mm — OSS, current — high.
- Apple doc on `UITextInputDelegate`: UIKit "provides a private text input delegate, which it assigns at runtime" to `inputDelegate`; the protocol is `textWillChange/textDidChange/selectionWillChange/selectionDidChange`. https://developer.apple.com/documentation/uikit/uitextinputdelegate — AD — high.
- Custom-view practice: Runestone brackets every programmatic edit with `textWillChange`/`selectionWillChange` and their `did` pairs. It has a documented workaround of calling `selectionDidChange(nil)` "to get the selection change to be reflected properly while still supporting Korean, Chinese, and deleting words with Option+Backspace", and notes "Even the Swift Playgrounds app does not get this right for all languages". https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Core/TextInputView.swift — OSS, current — high.
- Stale-state pitfall (out-of-process keyboard, iOS 17+): "aspects of this new asynchronous approach now exist throughout the entire keyboard and can introduce some slight differences in timing… [for] text entry, selection changes, or any other text related operations". https://developer.apple.com/videos/play/wwdc2023/10281/ — WWDC, iOS 17 — high. *Inference:* the keyboard's view of the document is copied asynchronously, so a storage rewrite the keyboard is not told about can leave it correcting or predicting against old text. I found no published reproduction of "correction re-applied at an old offset" on iOS 26 or 27.
- Selection adjustment for storage edits before the caret: no authoritative source. Developers save the selection, shift it, and reassign it. https://developer.apple.com/forums/thread/652653 — DEV — low.

## 4. Can a UITextView subclass intercept system edits by overriding UITextInput methods?

**Answer.** Partly, and not reliably. `insertText(_:)` overrides are called for keyboard typing. The dictation hooks (`dictationRecordingDidEnd`, `removeDictationResultPlaceholder`) are delivered to subclasses, and React Native relies on them. But `replace(_:withText:)` overrides are reported as not called on UIKit text-view subclasses (UITextField 2014 and 2019; UITextView dictation since iOS 16). Overriding `insertText` has broken predictive text. Text that the keyboard composes arrives as `setMarkedText`/`unmarkText` rather than `insertText`. The subclass is not a complete interception seam. I found no public documentation of a private input controller, so the routing per road is unknown beyond these reports.

**Evidence**
- `insertText(_:)` override in a UITextView subclass fires for software and hardware typing. https://developer.apple.com/forums/thread/800342 — DEV, Sep 2025 — medium.
- Overriding `replaceRange:withText:` caught dictation up to iOS 15; "From iOS 16, this method is no longer called for dictation". `insertDictationResult:` fires only when dictation ends, not while streaming. https://developer.apple.com/forums/thread/746678 — DEV, Feb 2024 — medium.
- `replace(_:withText:)` and `deleteBackward` not called on UITextField subclasses (rdar://19263531, iOS 8; and 2019). https://www.cocoanetics.com/2014/12/radar-uitextfields-implementation-of-uitextinput-protocol/ · https://developer.apple.com/forums/thread/113342 — DEV — medium (old).
- Overriding `insertText` "broke predictive text and prevented inserting whitespace". https://developer.apple.com/forums/thread/786099 — DEV, May 2025 — low-medium.
- Apple staff (Jun 2021): with `UITextInput`, "you may not see `insertText` at all. Instead you get `setMarkedText:selectedRange:` for the preview and `unmarkText`" (Live Text camera input). https://developer.apple.com/forums/thread/682090 — AE, iOS 15 — high.
- React Native's UITextView subclass overrides `dictationRecordingDidEnd` and `removeDictationResultPlaceholder:willInsertResult:` (live). https://github.com/facebook/react-native/blob/main/packages/react-native/Libraries/Text/TextInput/Multiline/RCTUITextView.mm — OSS — high.
- Mac Catalyst autocorrect into a custom `UITextInput` arrived only as `setSelectedTextRange:`, with no replace call. https://developer.apple.com/forums/thread/703651 — DEV, Apr 2022 — low.

## 5. A fully custom UITextInput view in 2025–2026

**Answer.** The system now provides a lot, provided the view implements `UITextInput` completely and correctly:

| System provides | Since |
|---|---|
| Gestures, selection, loupe, edit menu, keyboard shortcuts, autocorrect UI, marked text (`UITextInteraction`) | iOS 13 |
| Find (`UIFindInteraction`), edit menu (`UIEditMenuInteraction`) | iOS 16 |
| Selection UI without gestures (`UITextSelectionDisplayInteraction`), standalone loupe (`UITextLoupeSession`) | iOS 17 |
| Inline predictions (if `setAttributedMarkedText` is implemented) | iOS 17 |
| Basic Writing Tools panel (if `UITextInteraction` is adopted) | iOS 18 |
| Full inline Writing Tools (`UIWritingToolsCoordinator`) | iOS 18.2 |
| Grammar presentation APIs on the coordinator | iOS 27 |

The app still builds itself:
- layout and rendering, caret and selection geometry, and the tokenizer;
- undo;
- spelling underlines and the tap-to-correct menu (the system's correction popup uses a private replacement object);
- drag and drop (`UITextDraggable`/`UITextDroppable` are UITextView/UITextField-only conformances);
- accessibility text navigation;
- Writing Tools previews, underline paths and the hide/unhide animation;
- many keyboard edge cases.

The shipped experience reports describe a long tail measured in years.

**Evidence**
- WWDC23 10058: `UITextSelectionDisplayInteraction` "just provides the selection UI without the gestures"; the loupe API "can be used on any view". https://developer.apple.com/videos/play/wwdc2023/10058/ — WWDC, iOS 17 — high. Availability iOS 17.0: https://developer.apple.com/documentation/uikit/uitextselectiondisplayinteraction — AD.
- WWDC24 10168: "as long as your custom text view adopts UITextInteraction, you'll get Writing Tools in the callout bar or context menu for free… The rewritten text will be shown in the panel." https://developer.apple.com/videos/play/wwdc2024/10168/ — WWDC — high. WWDC25 265: for the full experience the coordinator delegate "prepares the context… incorporates changes, provides preview objects… provides coordinates… to draw proofreading marks". https://developer.apple.com/videos/play/wwdc2025/265/ — WWDC, iOS 26 — high. Coordinator: iOS 18.2+. https://developer.apple.com/documentation/uikit/uiwritingtoolscoordinator. Grammar presentation `showGrammarPresentation(for:in:)`: iOS 27.0+. https://developer.apple.com/documentation/uikit/uiwritingtoolscoordinator/showgrammarpresentation(for:in:) — AD — high.
- **Runestone** (shipping iOS code editor by Simon Støvring; custom `UITextInput` + `UITextInteraction`; MIT). In Oct–Nov 2026 it was still landing basics:
  - Writing Tools via `UIWritingToolsCoordinator`, owner-confirmed on a physical iPhone (#453);
  - spell checking built on `UITextChecker` because "UIKit's built-in correction popup uses a private replacement object" (#454);
  - a missing final change notification on `unmarkText` (#447);
  - quote auto-pairing breaking Czech dead-key composition (#445);
  - multilingual spelling (#478).

  Source comments record further workarounds: the caret vanishing when `markedTextRange` updates (it removes and re-adds the interaction), the iOS 17 caret not appearing (FB12622609), negative-length selection ranges from UIKit on iOS 16, and observing the private `UITextRangeAdjustmentGestureRecognizer`. #455 notes "iOS 27's public grammar checker does not by itself supply a complete native presentation workflow for this custom editor." https://github.com/simonbs/Runestone/pull/453 · /pull/454 · /pull/455 · /pull/447 · /pull/445 · /pull/478 · https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift — OSS, iOS 26–27 — high. Runestone implements `setMarkedText` but not `setAttributedMarkedText` (grep of current source), so by Flutter's finding it shows no inline predictions. That last step is inference.
- **Steve Shepard (Storyist, a shipped writing app) on UITextInteraction:** no autoscroll, zoom issues, missing Emacs shortcuts, and spelling correction calls a private `replace:` with a private `UITextReplacement` sender. "a hard stop". https://steveshepard.com/blog/adventures-with-uitextinteraction/ — BLOG, Jun 2020, iOS 13.4 — medium (old).
- **PSPDFKit/Nutrient Content Editor** (shipped): UITextInteraction gives "cursor handling, selection, the edit menu, the magnifier, marked text, keyboard shortcuts, autocorrect UI, Apple Pencil Scribble"; you can't set selection colours; there was a pre-iOS 16 leak with spell checking. https://www.nutrient.io/blog/adopting-uitextinteraction/ — BLOG, Sep 2023 — medium.
- **STTextView** (Marcin Krzyżanowski): its UIKit/iOS target exists (iOS 16+) and lists spelling and dictation. Licence is GPL v3 or a commercial licence. Its UIKit `setMarkedText` is minimal: it falls back to the *local* `selectedRange` argument as the replacement range when nothing is marked, which looks wrong for IME (my reading of the code). There is no `setAttributedMarkedText`, Writing Tools or find interaction in the UIKit target, and the last UIKit commits were Oct 2026. I found no shipped iPhone app named as using it. https://github.com/krzyzanowskim/STTextView · https://github.com/krzyzanowskim/STTextView/blob/main/Sources/STTextViewUIKit/STTextView%2BUITextInput.swift — OSS — medium.
- **Proton** (Apache 2.0) is a *UITextView wrapper* with nested editors in attachments, not a custom `UITextInput`. Last push Apr 2025. https://github.com/rajdeep/proton — OSS — high.
- **Apple's current advice for a new full-featured iOS 27 editor:** "Option 1 (`UITextView` with the viewport controller delegate)" over a custom TextKit 1 or 2 view. https://developer.apple.com/forums/thread/832728 — AE (Frameworks Engineer), Jun 2026 — high.

## 6. How shipped block or prose editors on iPhone handle selection across paragraphs or blocks

| App | Surface | Cross-block drag-select and edit on iPhone | Evidence |
|---|---|---|---|
| Notion | Editor is a **web view** (everything else native since 2025) | Since Jan 2022: "Double tap to select text, and drag your selection to include content across multiple blocks" (select/copy/paste; replacing not stated) | https://www.notion.com/releases/2022-01-19 (vendor, 2022) · https://www.macrumors.com/2026/06/12/notion-is-migrating-to-swiftui/ (PRESS, Jun 2026: "most of the mobile experience now running natively except for the editor") · Apple interview Oct 2026: "we're reaching the end of it, where the editor ships natively" https://developer.apple.com/news/?id=tejokjnx — editor architecture details not published |
| Craft | Native; per-block structure (guess that each block is its own text view: unverified) | Documented road is **block selection** (swipe a block; swipe along the circles for several). Cross-block character selection not documented; Anytype's survey says Craft "fall[s] back to whole-block selection" | https://support.craft.do/en/introduction/mobile-features/gestures (vendor) · Anytype PR below |
| Anytype (native, open source, one text view per block in a collection view) | Per-block | July 2026: dragging a selection past a block edge **escalates to whole-block multi-select**; character-precise cross-block selection planned as a synthetic, Flutter-`SelectableRegion`-style selection. Survey: "none shipping true cross-block character selection (Notion mobile is a WebView editor; Craft and Gutenberg mobile fall back to whole-block selection)" | https://github.com/anyproto/anytype-swift/pull/5078 (OSS, Jul 2026) — high for Anytype, medium for its survey |
| Gutenberg mobile (WordPress) | Per-block | Whole-block fallback (per the Anytype survey) | as above — medium |
| Bear 2 | Markdown note, not blocks; editor internals unpublished (guess: one text surface) | Ordinary cross-paragraph selection (user-observable; not sourced) | https://blog.bear.app/2023/08/behind-the-scenes-of-the-journey-to-bear-2/ — no tech details |
| Apple Notes | Not block-based; single text surface (guess; no teardown found) | Cross-paragraph selection works (common knowledge) | — |
| Obsidian mobile | CodeMirror 6 in a Capacitor web view (community statements, not official) | Single surface | https://forum.obsidian.md/t/what-technology-obsidian-mobile-is-developed-with/40125 — low |
| Ulysses, iA Writer, Day One, Google Docs | Not block editors on the surface; no engineering source found | Assumed single surface (guess) | — |

**Answer.** No source shows a native, per-block iPhone editor that lets the user drag one character-precise selection across block boundaries and then type over it. The one published native attempt (Anytype, Jul 2026) escalates to block selection. Notion's cross-block selection exists only in its web-view editor. Prose apps that are not block-based get it for free from one text surface.

## 7. Native text selection spanning several UITextViews

**Answer.** I found no supported technique and nothing shipping. TextKit 1 can share one layout manager across several containers, but on iOS "after adding a second text container to the layout manager, the text views become uneditable and unselectable" (Apple's sample, quoted by the developer). DTS confirmed this was a TextKit limitation and that "NSTextLayoutManager (TextKit2) still doesn't support multiple containers" (Aug 2024). The only working approaches are custom:
- synthetic selection drawn across views, which Anytype has planned but not shipped;
- escalation to block selection, which Anytype shipped in July 2026. It hooks the private `UITextRangeAdjustmentGestureRecognizer` through the public `shouldRecognizeSimultaneouslyWith` and `addTarget`, a technique taken from Runestone and Steve Shepard.

**Evidence**
- https://developer.apple.com/forums/thread/761941 — AE (DTS), Aug 2024 — high.
- https://github.com/anyproto/anytype-swift/pull/5078 — OSS, Jul 2026 — high.
- I found nothing newer than Aug 2024 that says TextKit 2 gained multi-container support. The iOS 27 TextKit additions are viewport rendering surfaces and attachment reuse, not multi-container (see §9).

## 8. Custom attributes under system edits

**Answer.**
- **Autocorrect and other OS replacements:** in a UITextView these hand the storage a replacement string that carries the standard attributes (font, colour, paragraph style) but **not the app's custom keys**. One app (Aztec/WordPress) had to re-inject its custom heading key inside `replaceCharacters(in:with:)`, after attempts to force typing attributes in `shouldChangeTextIn` "failed". The newest source for this is 2021–2022. I found no 2025–2026 source that re-tests it.
- **New typed characters:** these get `typingAttributes`. Apple: "When the text view's selection changes, the contents of the dictionary are cleared automatically." Apps have had typing attributes lost inside `insertText`/`deleteBackward` (iOS 11).
- **Not established:** whether custom keys in `typingAttributes` survive a selection change, meaning whether the reset re-derives custom keys from the neighbouring character. Also not established for dictation, inline-prediction acceptance, Writing Tools or the iOS 27 proofreading replacements.

**Evidence**
- Aztec PR 1334 (merged Feb 2022): OS replacements "aren't copying all of the existing attributes for the range they're replacing" (autocorrect, keyboard suggestions, double-space period). Standard attributes were present; the custom `headingRepresentation` was missing. The fix is in `TextStorage.replaceCharacters`. https://github.com/wordpress-mobile/AztecEditor-iOS/pull/1334 — OSS, iOS 15 era — medium-high (dated).
- `typingAttributes`: https://developer.apple.com/documentation/uikit/uitextview/typingattributes — AD — high.
- Aztec PR 752 (Oct 2017): "iOS 11's `insertText` / `deleteBackward`'s inner workings result into loosing the typingAttributes". https://github.com/wordpress-mobile/AztecEditor-iOS/pull/752 — OSS, iOS 11 — low (old).
- Writing Tools hands back attributed strings and "may add display attributes" even for plain-text views. Protected ranges exist via `textView(_:writingToolsIgnoredRangesInEnclosingRange:)`. https://developer.apple.com/videos/play/wwdc2025/265/ · https://developer.apple.com/videos/play/wwdc2024/10168/ — WWDC — high. Whether custom keys survive a rewrite: unknown.
- Related: the system attaches `NSOriginalFont` when an emoji is inserted (React Native comment), so the system does add its own attributes to storage. https://github.com/facebook/react-native/blob/main/packages/react-native/React/Fabric/Mounting/ComponentViews/TextInput/RCTTextInputComponentView.mm — OSS — high.

## 9. New in iOS 26 and iOS 27

- **iOS 26, Natural Selection:** UITextView/UITextField selections can be **several ranges** (`selectedRanges`). There are new ranges-based delegates (`shouldChangeTextInRanges`, `editMenuForTextInRanges`). Accessing `.layoutManager` (TextKit 1) disables Natural Selection. https://developer.apple.com/videos/play/wwdc2025/222/ — WWDC — high. A third-party iOS 26 SDK review lists the single-range forms as deprecated. https://sebvidal.com/blog/whats-new-in-uikit-26/ — BLOG, Aug 2025 — medium. Apple's docs list the single-range text-change delegate as ending at iOS 27.0. — AD — high.
- **iOS 26:** the IME candidate-commit range changed shape (see §1, thread 801003). Writing Tools gained follow-up requests, presentation-intent results, standard toolbar items and menu items, and "Result Options" (renamed from "Allowed Input Options"). https://developer.apple.com/videos/play/wwdc2025/265/ — WWDC — high. `UITextInput.unobscuredContentRect` arrived in iOS 26.4. https://www.ikyle.me/blog/2026/whats-new-in-uikit-ios-27 — BLOG — medium.
- **iOS 27, TextKit:**
  - UITextView now conforms to `NSTextViewportLayoutControllerDelegate`, so a subclass can override the viewport-layout callbacks.
  - New `NSTextViewportRenderingSurface` and `NSTextViewportRenderingSurfaceKey`; `NSTextLayoutFragment` is a key.
  - Attachment view-provider reuse policies (`.onEditingInlineParagraphs`, scrolling out of the viewport).
  - Text tables (`NSTextBlock`/`NSTextTable`) on iOS.

  Apple's example uses these for line numbers and collapsible sections inside a stock UITextView. https://developer.apple.com/videos/play/wwdc2026/370/ · https://www.ikyle.me/blog/2026/whats-new-in-uikit-ios-27 — WWDC + BLOG — high. *Inference:* this makes per-block gutter decorations in one UITextView much easier than before.
- **iOS 27, input:** the header diff of beta 1 shows **no** changes to `UITextInputTraits`, `UITextInteraction`, keyboard or prediction APIs. https://www.ikyle.me/blog/2026/whats-new-in-uikit-ios-27 — BLOG — medium.
- **iOS 27, Apple Intelligence automatic proofreading:** spelling and grammar suggestions "as users type across the system", blue underlines, accept or reject one at a time. https://www.macrumors.com/2026/06/08/apple-intelligence-gains-smarter-writing-tools/ · https://9to5mac.com/2026/09/16/ios-27-adds-three-new-iphone-features-youll-use-all-the-time/ — PRESS — medium.
  - Custom views get new grammar presentation hooks on `UIWritingToolsCoordinator` (iOS 27.0). — AD — high.
  - **Bug:** in a TextKit 1 UITextView, flagged words **disappear** during grammar checking. It did not reproduce in TextKit 2. Engineering is aware (FB24319258), and DTS asked the reporter to retest on 27.0 (24A437). https://developer.apple.com/forums/thread/842744 — AE, Aug–Sep 2026 — high.
  - Whether proofreading replacements ask the delegate, and what they do to custom attributes: unknown.
- **Standing TextKit 2 UITextView risk for long notes:** tapping after a fast scroll in a 50k-word document puts the caret thousands of characters away (FB15241823). Seen on iOS 17, 18 and 18.1, and acknowledged as a UITextView bug by DTS. The same developer reverted to TextKit 1 because of it (Aug 2026 thread). Fix status unknown. https://developer.apple.com/forums/thread/764442 · https://developer.apple.com/forums/thread/842744 — AE — medium-high.
- **iOS 27 beta report:** in a keyboard extension, marked text disappears when the user taps into it. Apple says this is expected to work and asked for a Feedback report. https://developer.apple.com/forums/thread/833053 — AE, Jun 2026 — low relevance.

---

## (a) Input road × asks the delegate first × visible in the storage delegate × marked text

"Storage" = `NSTextStorageDelegate` `didProcessEditing` with a character edit. "yes (inferred)" means the change is visible on screen, so it must have gone through storage, but no source logged it.

| Input road | Asks `shouldChangeTextIn(Ranges)` first? | Visible in storage delegate? | Marked text? |
|---|---|---|---|
| Typing (soft or hardware key) | Yes (documented) | Yes | No (except dead keys / IME) |
| Long-press delete (repeat) | Once only on iOS 17 beta (2023); current behaviour unknown | Yes (inferred) | No |
| Autocorrect on space | Reported yes in the common case (2020); not re-verified on iOS 26/27 | Yes (2020; Aztec 2022 saw it at `replaceCharacters`) | No |
| Prediction bar tap, caret at word end | Reported yes (2020) | Yes | No |
| Prediction bar tap, word fully selected | Reported **no** (2020) | Yes (2020) | No |
| Double-space period | Reported **no** (2020) | Yes (2020) | No |
| Inline prediction appears or updates | Unknown | Yes (inferred: marked text lives in storage) | **Yes** (`setAttributedMarkedText`, grey, caret at its start) |
| Inline prediction accepted (space or tap) | Unknown | Unknown in detail (commit and/or insert) | Ends |
| Inline prediction rejected (type on, backspace) | Unknown | Unknown in detail | Replaced or cleared |
| Dictation, forming (iOS 16+ live) | Unknown | Yes (inferred) | Unknown |
| Dictation, final | Unknown (`insertDictationResult` fires at end on a subclass) | Yes (inferred) | Unknown |
| Text replacement (user shortcut) | Unknown | Yes (inferred) | Unknown |
| IME composition (Japanese, Chinese) | **Yes**, but marked range not yet updated, and range/replacement can differ from the actual storage edit (iOS 18 spaces; iOS 26 range shape) | Yes (DTS) | Yes |
| Korean composition | Unknown per keystroke | Yes | **No** (`markedTextRange` stays nil; DTS: "looks like a bug") |
| Cangjie / Sucheng / Stroke digits | Twice (one bogus call), iOS 17 | Yes | — |
| Spelling-menu correction | Unknown (private `UITextReplacement` path) | Yes (inferred) | No |
| Swipe typing | Reported **no** (2023, unanswered) | Yes (inferred) | Unknown |
| Undo/redo, shake-to-undo | Reported yes (OP, 2025/26) | Yes | No |
| Writing Tools rewrite | Reported yes (OP, 2025/26) | Yes (WWDC24: "alter your text storage") | No (OP) |
| iOS 27 proofreading accept | Unknown | Yes (inferred) | Unknown |
| Paste | Yes (WWDC25 names paste) | Yes | No |
| Drag and drop into the view | Unknown | Yes (inferred) | No |
| Scribble | N/A on iPhone (iPad-only) | — | — |
| App's own `textStorage` edit | No (bypasses delegate and undo layer) | Yes | No |

## (b) The three facts I most wanted and could not establish, with the experiment for each

1. **The exact UIKit call and storage sequence for an inline prediction in a UITextView on iOS 27.0.x.** This covers what is shown, what accepting with space or a tap does, and what typing on or backspacing does. It also covers whether `shouldChangeTextInRanges` is consulted and what `editedRange`/`changeInLength` arrive.
   *Experiment:* on a device on 27.0.x, with an English keyboard and inline predictions on:
   - Build a UITextView subclass whose overrides of `setAttributedMarkedText`, `setMarkedText`, `unmarkText`, `insertText`, `deleteBackward` and `replace(_:withText:)` log and call `super`.
   - Add a delegate that logs both change delegates, `textViewDidChange` and `textViewDidChangeSelection`.
   - Add an `NSTextStorageDelegate` that logs `editedMask`, `editedRange`, `delta`, the edited substring, `markedTextRange` and `selectedRanges`.
   - Type "Hel", then accept by space, accept by tap, reject by typing a non-matching letter, and reject by backspace.
   - Repeat with `inlinePredictionType = .no` as the control.
2. **Whether custom `NSAttributedString.Key`s on existing characters survive each system road on iOS 27, and what new characters inherit.** The roads are autocorrect, prediction-bar tap, inline-prediction accept, live dictation, text replacement, the spelling menu, Writing Tools rewrite and proofreading accept. For new characters, the question is whether `typingAttributes` after a tap or selection change carry custom keys from the neighbouring character.
   *Experiment:* stamp every character with a custom block-id key, then drive each road on a device. After each road, dump attribute runs (`enumerateAttribute`) and `typingAttributes` before and after.
3. **Whether attribute-only storage edits, and character edits outside the edited range, are safe while the keyboard is mid-input.** The edits in question are made after `didProcessEditing` or on the next runloop turn. "Safe" means: no lost or duplicated letters, no correction re-applied at an old offset, no killed dictation, and no broken marked text or prediction. The question also covers whether UITextView shifts `selectedRanges` for a character edit before the caret.
   *Experiment:* the same harness, with a timer that, while the user types, dictates, or has a prediction showing:
   - (a) re-stamps attributes over the paragraph being typed;
   - (b) inserts or deletes characters in a paragraph above the caret, using direct storage edits;
   - (c) makes the same edit as (b) through `replace(_:withText:)`.

   Record text and selection divergence over a few hundred keystrokes per road.

## (c) Judgment, labelled as such: which option the evidence favours

**My judgment, not a sourced fact.**

- **(B) One UITextView per block is ruled out by the non-negotiable.** UIKit cannot carry a native selection across text views. Multi-container layouts make the extra views unselectable, and TextKit 2 has no multi-container support. The only native per-block editor that has published its attempt (Anytype, Jul 2026) escalates to whole-block selection. Every block editor surveyed falls back the same way, except Notion's web view. B also trades one problem for another: replacing or re-creating the focused text view restarts the keyboard session, and Anytype shipped exactly that bug ("autocorrect then computed suggestions from the word minus its first letter").
- **(C) A read-only whole-note view plus a live editor over one block** keeps reading-time selection across blocks. It still cannot let a user *type over* a cross-block selection without custom routing. The keyboard sees only the focused block's context. Every block switch is a new input session (the B failure mode at every boundary). It fails "feels like a normal editor" at block edges (backspace at a block start, arrowing across, a selection spanning two blocks).
- **(E) A fully custom `UITextInput`** is feasible: Runestone, Textastic and PSPDFKit ship one. But the evidence shows a multi-year long tail that is still being paid in late 2026: spelling UI hand-built because the system's correction object is private, Writing Tools via the coordinator, `setAttributedMarkedText` needed for predictions, Korean and Chinese selection workarounds, caret-vanishing hacks. Apple's own June 2026 advice for a new iOS 27 editor is a stock UITextView with the viewport delegate. E is the last resort, not the first.
- **(A) Hardening the veto model in a single UITextView** fights the evidence:
  - Several roads never ask (double-space period, a suggestion on a selected word, swipe typing per one report, and the app's own edits).
  - Roads that do ask can report a range or string that differs from what the storage actually does (iOS 17 attachment case, iOS 18 IME spaces, iOS 26 commit-range shape, iOS 17 bogus double calls).
  - The single-range delegate is deprecated as of iOS 27.0.
  - Uncommitted input is, in Apple's words, "at the input-method level, which the app does not have access to".
- **(D) The evidence most favours D: one UITextView, storage as truth while typing, block membership re-derived after each edit.** It keeps native cross-paragraph selection and editing, and it matches how the best-evidenced code behaves today:
  - React Native, Oct 2026: decision-only delegate callbacks; never rewrite inside a UIKit callback; apply corrections as incremental `UITextInput` replacements on the next turn, only when the base text is unchanged and nothing is marked.
  - Apple, 2023: programmatic edits go through `insertText` or `replace(_:withText:)`, not raw storage edits.
  - Apple, 2026: defer decisions until composition commits.

  D must be built around four sourced hazards:
  1. **Marked text, including inline predictions, is in the storage.** Never save the marked range as a block's text. Re-derive and save only when `markedTextRange == nil`. Korean is the exception that never marks, so the save logic must not rely on marking alone. Turning `inlinePredictionType` off is a cheap fallback if predictions misbehave.
  2. **OS replacements can drop custom attribute keys.** A re-derivation keyed only on a custom attribute must repair unattributed runs, for example from neighbours or paragraph separators, rather than trust the key.
  3. **Writing Tools and proofreading rewrite storage.** Pause persistence across `textViewWritingToolsWillBegin`/`DidEnd`, and protect ranges via `writingToolsIgnoredRanges` where needed.
  4. **Stay on TextKit 2.** TextKit 1 has the iOS 27 disappearing-text bug and loses Natural Selection. Long-document caret placement (FB15241823) is a known TextKit 2 risk to test against real note lengths.

  The three experiments in (b) are the ones that would confirm or sink D before it is built.
