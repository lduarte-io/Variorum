# VM-46 — ladder round 1 (cold review, Opus)

Diff reviewed: `origin/main...vm-46-phone-app-icon` at `baacc382a` (two commits: `251d61c51` the icon,
`baacc382a` the Home Screen name), PR #6. `notes/REVIEW_PROMPT.md` run verbatim; the anchor is the ticket
(VM-46 names no plan file or ledger rows). Scope check first: the diff touches no editor seam, no custody or
keychain code, nothing under `Sources/VariorumCore/Sync/`, and no default's meaning, so an Opus round is the
right cast.

Totals: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.

## Findings

**[MINOR-1] · `App/Variorum/Variorum.xcodeproj/project.pbxproj:83–91, 101–103` with the file at
`App/Variorum/Variorum/AppIcon.icon` · architectural clarity: the one resource both apps compile lives in the
Mac's folder and reaches the phone through the project's first and only
`PBXFileSystemSynchronizedBuildFileExceptionSet`, while the project already has a cross-platform home that
does this by folder membership alone.**
- Evidence. AppSpec §2 gives the layout: `App/Variorum/Variorum/` is the Mac entry, `App/Variorum/Shared/`
  holds the cross-platform pieces, and `VariorumMobile/` holds the phone's. `Shared/` is a synchronized root
  group in BOTH app targets' `fileSystemSynchronizedGroups` (pbxproj 276–279 and 348–351), with no exceptions
  (132–136). It already carries resources both apps compile: `Shared/SampleLibrary/*.txt` land in the phone
  bundle with no project edit. This diff instead leaves the icon in the Mac-only folder and adds a
  hand-authored exception object to the Mac's root group.
- Degradation, traced. The coupling shows in only two places: the pbxproj and the generator's docstring
  (`appicon.py:35–39`). Someone reading the tree, or AppSpec §2, takes `Variorum/` to be Mac-only. A change
  scoped to the Mac's icon, such as the user-selectable icons the brand README floats (`README.md:136`) or a
  macOS-only design-generation tweak, would then re-skin the phone with no sign on the phone's side. It
  isn't a silent break in the other direction. I reproduced headless that dropping the exception set fails
  the phone build, with actool exiting 1: `None of the input catalogs contained a matching stickers icon
  set, app icon set, or icon stack named "AppIcon"`. So the cost is clarity and discoverability, not
  correctness.
- Fair to the build: this exception set is exactly what Xcode writes when you tick a file's target-membership
  box. It is a first-class mechanism, it works (verified, see the clean bill), and it is documented in the
  generator and the brand README.
- Proposed fix, options:
  - (a) `git mv App/Variorum/Variorum/AppIcon.icon App/Variorum/Shared/AppIcon.icon`, then delete the
    exception set and the root group's `exceptions` entry. Both targets already compile `Shared/`, and
    `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` resolves the same way in both. Then update the three
    readers of the path: `notes/brand/tools/appicon.py:53` `ICON_DIR` plus docstring item 1,
    `App/Variorum/VariorumTests/PaletteDerivationTests.swift:156`, and `notes/brand/README.md:9`. Historical
    records keep their old paths. `VariorumMark.imageset` stays in the Mac catalog. One cost: any copy road
    outside this repo that follows README line 9's path has to follow the move.
  - (b) Keep it as built.

  I recommend (a). Not bug-class, so no pin; the evidence for either option is the two headless builds.

**[NIT-1] · `notes/brand/tools/appicon.py:24` and `:13` · the generator's docstring still introduces the
document as "the macOS 26 app icon" and speaks of "the Dock and Finder".** The VM-46 sentence appended at
lines 35–39 corrects the scope, but only at the end of a long paragraph whose lead still says macOS. Proposed
fix: item 1's lead reads "the app icon of both apps (macOS 26 and iOS 26) as an Icon Composer document", and
line 13 reads "so the icon never changes with the room" (or names the Home Screen beside the Dock). Comment
only; if MINOR-1's option (a) lands, this goes with the `ICON_DIR` edit.

**[NIT-2] · process, owed at closeout, not a defect in the diff (CLAUDE.md Build workflow: Sizing; Fixes;
the closeout ritual).**
- (i) A ladder is running, so a repo record `notes/plans/fixes/vm-46-<slug>.md` with its FOR A LATER READER
  section is owed. None exists on the branch yet; only this round file sits in `fixes/`.
- (ii) The use-shaped evidence. The PR body says "Not installed on the phone", and the ticket's own second
  half is "then a fresh build goes on the phone". CLAUDE.md closes a batch only on use-shaped evidence, so
  that means the icon seen on her Home Screen, ideally in Default and in one dark or tinted style, and the
  name reading "Variorum".
- (iii) Her two words, the icon (quoted in the ticket) and the display name ("yes - let's change that to be
  Variorum.", in the commit and PR only), belong in the record.
- (iv) The MOBILE PARITY / `notes/MobileSoul.md` line: this is mobile-visible.

## Clean bill (checked and found solid)

- **The exception set's semantics, verified by my own build rather than the implementer's.** VariorumMobile
  does not list the `Variorum` root group, so the set's `membershipExceptions` ADDS `AppIcon.icon` to that
  target. I ran headless Debug builds for `generic/platform=iOS Simulator` in a scratch DerivedData, at
  `251d61c51` and again at `baacc382a`. Both succeeded. actool ran with `VariorumMobile/Assets.xcassets` and
  `Variorum/AppIcon.icon` as its inputs and `--app-icon AppIcon`, and printed no warnings, notices or errors
  section. In the built app:
  - `Assets.car` carries the `AppIcon` icon stack in UIAppearanceLight, UIAppearanceDark and
    ISAppearanceTintable, with the `AppIcon_Assets/cards` vector layer and 1024 renditions for phone and pad.
  - `AppIcon60x60@2x.png` is the cards on sea-glass (viewed).
  - `CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconName = AppIcon`.

  No Mac source leaked into the phone target: only `AppIcon.icon` is excepted, and an AppKit file would not
  compile for iOS.
- **The Mac is unaffected.** My own headless Mac Debug build at the branch head succeeded. actool still
  compiles `Variorum/AppIcon.icon` for the Mac, and the bundle carries `AppIcon.icns` with
  `CFBundleIconName` and `CFBundleIconFile` both `AppIcon`. `AppMarkTests.theAppIconIsCompiledIntoTheBundle`'s
  premise holds.
- **"No pin" is defensible.** The regression road (the exception set dropped by a later project edit) fails
  the build loudly; reproduced above. A pin on the icon's name (`CFBundleIconName == "AppIcon"`) would be green
  on the old tree too, because the floppy set was also named `AppIcon`, so it would be hollow. A pixel-sampling
  pin would be red-on-old but fragile, and isn't owed for an Improvement-class asset change.
- **The generator claim holds.** I re-ran `appicon.py` (`python3 -I`) in a scratch copy holding only the
  script and `variorum-cards-sea-glass.svg`. Its `AppIcon.icon/` and `VariorumMark.imageset/` came out
  byte-identical to the tree. The docstring's `"squares": "shared"` matches the code (`appicon.py:162`), and
  "62% of the canvas width, centred, flat print" matches `MARK_WIDTH_SHARE`, `OPTICAL_DROP_SHARE = 0` and the
  icon.json flags (glass false, shadow none, specular false, translucency off).
- **The appearances follow rulings; nothing new was invented.** icon.json pins the dark fill and art to the
  sea-glass edition and feeds tinted the same art. That is the ruled "ONE icon in every appearance"
  (AppSpecRecord §12, VX-177 and VX-192) and the logo "everywhere" (VX-993). I rendered the iOS renditions
  headless with Icon Composer's `ictool` (`--platform iOS`, renditions Default, Dark, TintedLight, TintedDark,
  ClearLight and ClearDark). Default and Dark are identical sea-glass. Tinted and Clear keep the fan's
  silhouette: the black ink card drops into the ground, exactly as on the Mac's tinted style, which shares
  this same document. No product silence needs a QUESTIONS entry.
- **Ticket scope and her word.**
  - VM-46 quotes her: "please change the variorum icon to being the actual variorum icon".
  - The deleted placeholder was author-provided art (`notes/plans/phase-08-ios-capture.md:57`). Her word
    authorizes replacing it, and it survives in history.
  - The ticket's "AppIcon asset … in the sizes iOS needs" is met by actool deriving the sizes from the `.icon`.
    That is a different shape from a copied phone appiconset, and a defensible one, since it leaves no second
    copy to drift.
- **The second commit (Home Screen name).**
  - `INFOPLIST_KEY_CFBundleDisplayName = Variorum` is set in both phone configurations (pbxproj 957 and 993).
  - The built Info.plist reads `CFBundleDisplayName = Variorum` and `CFBundleName = VariorumMobile`.
  - The phone test bundles' `TEST_HOST` paths are unchanged (`VariorumMobile.app/VariorumMobile`, pbxproj 1036
    and 1059).
  - Nothing in `VariorumMobile/`, `Shared/`, the phone tests, `Tools/` or the core reads
    `CFBundleDisplayName` or `CFBundleName` (grep).
  - The Face ID system prompt will now name "Variorum".
  - Debug and Release share one bundle id on the phone, so one name for both is right (unlike the Mac's fenced
    "Variorum Dev").
- **The pbxproj form.** The new section sits in Xcode's isa order (PBXFileReference, then the exception set,
  then PBXFileSystemSynchronizedRootGroup), and its comment uses Xcode's own wording. The hand-minted id
  `E1A460012F00000000004601` occurs exactly twice (the definition and the root group's reference).
  `objectVersion = 77` already supports synchronized groups. Readers that parse the pbxproj (`PinBeltTests`,
  `Tools/verify-pins`, `VersionSchemeTests`, `MobileShellTests:417`, the release scripts) read package
  references, versions and orientation keys, none of which the diff touches.
- **Main's drift.** The changes on main since the branch point (`082c8aedc` to `04e632373`, VX-999) touch no
  pbxproj or asset, so the merge carries no conflict.
- **Public-repo hygiene.** Neither commit message nor the PR body carries a trailer line or a private
  identifier.
- The worktree was left unchanged by this review (`git status` clean apart from this file).
