# VM-46 — the phone wears the real Variorum icon and the name "Variorum"

**Not done here, first:** nothing was installed on her phone (the orchestrator installs under a stage
claim; "seen on her Home Screen" is the open item below); the PR is not merged;
`PaletteDerivationTests.theSeaGlassIsTheIconsOwnColour`, whose path string moved, was NOT run, because
it is a Mac app-suite test that needs the stage (its new path was checked to resolve on disk).

## FOR A LATER READER

**Her words.** The icon: *"please change the variorum icon to being the actual variorum icon. that
should just be done now."* The name: *"yes - let's change that to be Variorum."*

**What changed.** The phone's app icon was a placeholder (a floppy disk, `VariorumMobile/Assets.xcassets/
AppIcon.appiconset`). That set is deleted. The phone now compiles the SAME Icon Composer document the Mac
does: `App/Variorum/Shared/AppIcon.icon`. It moved there from the Mac-only `App/Variorum/Variorum/`
(round 1, MINOR-1, option a). `Shared/` is a synchronized folder that both the `Variorum` and
`VariorumMobile` targets already compile, so the project needs no exception or other icon wiring.
Both targets keep `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`. One file is both apps' icon, so a
change to it reaches both, and there is no second copy to drift. The phone's Home Screen name is set by
`INFOPLIST_KEY_CFBundleDisplayName = Variorum` in its Debug and Release configurations. Only the display
name changed: the target, product name, scheme and bundle id (`io.lduarte.VariorumMobile`) are as they
were. `CFBundleName` stays `VariorumMobile`, so the test hosts' `VariorumMobile.app/VariorumMobile`
paths are unchanged.

**The master.** `notes/brand/variorum-cards-sea-glass.svg` (THE LOGO, VX-993), placed by
`notes/brand/tools/appicon.py`, whose `ICON_DIR` now points at `Shared/`. Re-running the generator gives
byte-identical output. Nothing is redrawn. The document is `"squares": "shared"`: the cards fan sits at 62%
of the canvas width, centred, on the #C2DDD3 fill, as a flat print (no glass, shadow, specular or
translucency), and the system applies each platform's mask. The appearances are the Mac's own, nothing
new: dark pins the same sea-glass icon (VX-177's one icon all the time), and tinted is fed the same art.
On iOS, Icon Composer's `ictool` renders Default and Dark identical. Tinted and Clear are the system's
own derivations and keep the fan's silhouette.

**Evidence (headless, this tree).**
- Mac Debug build: SUCCEEDED. actool compiles `Shared/AppIcon.icon`; the bundle carries `AppIcon.icns`
  (the cards, viewed), and `CFBundleIconName` and `CFBundleIconFile` are both `AppIcon`.
- Phone iOS Simulator build: SUCCEEDED. The first full build printed only the pre-existing Swift warnings,
  the same set as VM-45's device build, with none about the icon or the asset catalog. The rebuilds were
  incremental and printed none.
- Phone Release device build (`-configuration Release -destination 'generic/platform=iOS'`, the VM-45
  road): SUCCEEDED, and `codesign --verify --deep --strict` passes. Signing identity, team, development
  profile and entitlements are byte-identical to the first VM-46 build and match VM-45's facts. The
  bundle reads `CFBundleDisplayName` Variorum, `CFBundleName` VariorumMobile, `io.lduarte.VariorumMobile`
  1.0 (1).
- In both phone bundles, `Assets.car` carries the AppIcon icon stack (light, dark, tintable) with the
  cards vector layer and 1024 renditions, plus `AppIcon60x60@2x.png` and `AppIcon76x76@2x~ipad.png`
  showing the cards; `CFBundleIconName` is `AppIcon`.
- Preview for her eye, outside the repo:
  `~/dev/variorum-vm-44/notes/plans/vm-44/design/renders/vm-46-icon-preview.png` shows the 1024 square
  and the iOS-masked icon at Home Screen size, light and dark.

**No pin.** This is an asset and setting change, not bug-class (round 1 agreed). A pin on
`CFBundleIconName` would be hollow, since the placeholder set was also named `AppIcon`. If the icon is
lost, the build fails loudly: round 1 reproduced actool refusing with no icon named "AppIcon".

**Open.**
- Seen on her Home Screen: the icon in Default and one dark or tinted style, and the name reading
  "Variorum". PENDING, the orchestrator's line after the install.

**Parity.** `notes/MobileSoul.md` §6, PL-74.

---

## Working record

| Commit | What |
|---|---|
| `251d61c51` | The placeholder set is deleted; the phone compiles the Mac's `AppIcon.icon` through a target-membership exception |
| `baacc382a` | `INFOPLIST_KEY_CFBundleDisplayName = Variorum`, both phone configurations (her word) |
| `f5264c6d9` | R1 MINOR-1: `git mv` of `AppIcon.icon` into `Shared/`. Its `git add` named the deleted old path and aborted, so this commit carries only the rename under the full message; the next commit carries the rest, and history was not rewritten |
| `3723bc740` | R1 MINOR-1 + NIT-1, the rest: the exception set deleted; `ICON_DIR`, `PaletteDerivationTests`' path and the brand README follow the move; the generator docstring opens item 1 as both apps' icon |
| this commit | R1 NIT-2: this record, the round-1 file, PL-74 |

**Round 1** (`notes/plans/fixes/vm-46-ladder-round1.md`, Opus, the only round): 0 BLOCKER · 0 MAJOR ·
1 MINOR · 2 NIT.
- MINOR-1 FIXED, option (a): the move into `Shared/` (`f5264c6d9`, `3723bc740`).
- NIT-1 FIXED (`3723bc740`).
- NIT-2 FIXED by this record and PL-74, except (ii), the use-shaped Home Screen sighting, which is the
  open item above.
