# VM-44 audit — reader D: protection, sync, accounts, first run, doors to the outside, launch readiness

Read-only audit of `~/dev/variorum` at `main` 5dde1bcf9 (2026-11-12). Every claim is marked **VERIFIED** (code read,
`file:line` given — paths relative to `App/Variorum/` unless they start with `Sources/` or `notes/`) or **INFERRED**
(with what it rests on). Canon read in full for this area: `notes/CastleRules.md` (all 27 rules), SurfaceContracts
"The app" and "Doors to the outside", MobileSoul §1–5 plus ledger rows PL-6/13/15/17/20/37/42/47/48/51/58/59/60/66/72/73.
Tickets were read on Linear (VM-3, 9, 11, 13, 15, 23–30, 32).

Status words: PRESENT · PARTIAL · STALE (follows a retired rule, or visibly behind) · ABSENT · RULED-EXCLUDED.

---

## 1. Gap matrix

### 1a. Library protection (Castle faces, lobby, words, Protection screen)

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D-01 | Lobby: passphrase field, words behind a door, Face ID button that asks on its own, refusals, the E6 line, the vault road | CastleRules 8, 9, 14; SC Doors ▸ Library protection ("the phone opens on the same road…") | PRESENT | `VariorumMobile/Features/Protection/MobileRoadFaces.swift:31-237` | Shared (`ProtectionLobbyModel`, `ProtectionOpenRoad`) | PL-42, PL-59, PL-60 | — | VERIFIED. It asks for Face ID on appear and on every return to `.active` (`MobileRoadFaces.swift:86-94`; `Shared/Protection/ProtectionLobbyModel.swift:111-114`). Chrome is lowercased in Terminal ("unlock with face id"), and the fonts are fixed size (D-64). |
| D-02 | The pre-design face (Start fresh only) | Rule 26; SC | PRESENT | `MobileRoadFaces.swift:50-111` | Shared | P-VM8-1 | — | VERIFIED. There is no Open Library door because the phone has no picker road. |
| D-03 | The library-missing face | pre-13x §3.7; SC | PARTIAL | `Features/Protection/MobileLibraryMissingView.swift` | Shared `LibraryMissingLobby` | PL-20 | S | VERIFIED. Only "Start a New Library" is offered; the Mac's Restore and Open doors have no phone road. Its busy line is a hard-coded "Starting…". |
| D-04 | Rule 21's notice, the key-file offer, the Face ID re-arm card | Rule 21; SC | PRESENT, wording STALE | `MobileRoadFaces.swift:300-366` | Shared | F-PH-1 (hers), PL-51(c) | S | VERIFIED (ledger and record). Her CastleRules sentences say "this Mac" when shown on the phone. The phone wording is hers to give. |
| D-05 | Rule 27's faces (lobby moment; sheet once per open) | Rule 27 | PRESENT | `VariorumMobileApp.swift:79-89`; `MobileRoadFaces.swift:370-398` | Shared | — | — | VERIFIED |
| D-06 | **The creation words card shown before the first screen** | Rule 2 as amended: "never before the first screen". SC: "The creation-time words card is retired" | **STALE** | `Shared/Protection/ProtectionRoad.swift:46-54` (`wordsCardAtCreation(mac:)` returns `!mac`); `Shared/AppBootstrap.swift:517-521`; `MobileRoadFaces.swift:241-296` | Shared flag; phone face | VM-23, VM-28, P-VX307-U2b-0 | M | VERIFIED. A fresh phone shows twelve words before anything else. A Mac user adding the phone gets twelve words for a throwaway library that the join is about to replace (her device-moment reaction: "did it change my 12 words?", VM-28). **New finding:** the card is drawn in the `.newLibraryWords` arm (`VariorumMobileApp.swift:202-204`), outside the app-switcher redaction, which is attached only to the `.ready` arm (`:73`). So the words are probably *not* covered in the app-switcher snapshot. INFERRED from SwiftUI: `.privacySensitive()` redacts only under a `.privacy` redaction reason. |
| D-07 | The band card above the quick entry (offers the words with Copy, Later and ✕; retires once an account act lands) | Rules 2, 3, 7; SC | ABSENT | — | Shared state reader `WordsBand` | VM-23, VM-28 | M | VERIFIED: no `WordsBand` or band use anywhere under `VariorumMobile/` (grep). |
| D-08 | **Rule 3's recurring passphrase reminder** | Rule 3: "Every library is asked for a passphrase" | **ABSENT** | the shell's comment at `Features/Shell/MobileShellView.swift:265` | Shared `PassphraseReminderModel` | VM-28 | S–M | VERIFIED. A library born on the phone is never asked for a passphrase. The only place to set one is a row deep in Settings ▸ Protection. So a phone-only user's library rests on the quiet roads plus words they saw once. This is a CastleRules contract gap on a phone that creates libraries. |
| D-09 | The E6 card (the account's passphrase has never been typed on this device) | Rule 3, last clause; R-529-6; VX-538 | ABSENT | — | Shared `WordsBand` | VM-28, PL-59 | S | VERIFIED (no band exists) |
| D-10 | The tutorial's closing cards (the passphrase ask, then the words) | Rules 2, 3; SC "the tour" | ABSENT | — | Mac-local `Features/Onboarding/TourScript.swift` | — | M | VERIFIED. The phone has no tour (D-47). |
| D-11 | The Settings ▸ Protection screen | SC; P-VM8-2 | PRESENT | `Features/Protection/MobileProtectionScreen.swift:41-123` | Shared faces | PL-60 | — | VERIFIED. Section order follows the Mac pane: passphrase, words, check, crossings, then the account section. That puts **the join door at the bottom of a long scroll** (`:93-96`). |
| D-12 | Set a passphrase / Change / Reset forgotten | Rules 3, 6; VX-308 U3 | PRESENT | `Features/Protection/MobileProtectionDoors.swift:249-430` | Shared | PL-60 | — | VERIFIED |
| D-13 | New words, shown through the one look | Rules 2, 6 | PARTIAL | `MobileProtectionDoors.swift:431-470`; `MobileProtectionScreen.swift:527-639` | Shared `WordsLookModel` | — | S | VERIFIED. There is **no Copy door**. On the Mac the words copy as a concealed pasteboard type that is cleared at lock and at quit (VX-447/448). The phone has no words-clipboard road (P-2). |
| D-14 | Check my passphrase or twelve words | VX-513 | PRESENT | `MobileProtectionDoors.swift:472-535` | Shared | — | — | VERIFIED |
| D-15 | Use Castle… / Replace All Keys… / the Face ID gate choice | Rules 9–11 | PRESENT | `MobileProtectionDoors.swift:537-731` | Shared | PL-60 | — | VERIFIED. The shared leads talk about "your backups" on a phone that keeps none (F-U2-H). |
| D-16 | Use Standard… | Rule 12 | ABSENT (held) | the skip at `MobileProtectionDoors.swift:563` | Shared | F-PH-2, VM-28 | S | VERIFIED. **A phone-only user in Castle cannot leave Castle on the phone.** The posture line "You're in Castle." stands with no door under it. |
| D-17 | The follow into Castle and the pair follow | Rules 7, 10; VX-529 | PRESENT | `MobileProtectionScreen.swift:188-200` | Shared | PL-59, PL-60 | — | VERIFIED |
| D-18 | The follow out of Castle; a join or Move that leaves Castle | Rules 12, 15 | ABSENT (held), a dead end | `MobileProtectionScreen.swift:190, 214` (`saysRuleTwelve` arms render nothing) | Shared | F-PH-2, P-VM8-10, VM-28 | S | VERIFIED. If the account leaves Castle on another device, the phone is stuck until her phone wording lands; the only road is the Mac. |
| D-19 | Doors locked by an owed follow: the Mac shows each refusing in place, the phone hides them whole | R-529-3 | PARTIAL (a deliberate divergence) | `MobileProtectionDoors.swift:214-247` | Shared | P-VM8-9 (her question) | S | VERIFIED |
| D-20 | The gate-style row (Face ID / Always ask) | vx-266 §3.10 | PRESENT | `MobileProtectionDoors.swift:600-635` | Shared | — | — | VERIFIED. Terminal lowercases it to "on this iphone". |
| D-21 | **The idle-lock dial** | pre-13x decision 18; VX-308 R-U4-3; SC: "Castle's On this Mac section carries the idle-lock dial and Lock Library Now" | **ABSENT** | `MobileProtectionDoors.swift:634` (comment: "The idle dial and Lock Library Now sit here on the Mac — not this unit's") | Shared: `RoadCrossingsModel.setIdleMinutes` (`Shared/Protection/RoadCrossingsModel.swift:352-363`), `RoadGateRow.idleChoices = [5,10,30,nil]` (`RoadCrossingFaces.swift:171`), copy in `ProtectionCopy.swift:254-263` | VM-25 | S | VERIFIED. The model, the choices and the copy are shared and ready, and the phone already holds `crossings`. Only the face is missing. |
| D-22 | **Lock Library Now** | Same as D-21; the Mac's File menu ⌃⌘L | **ABSENT** | — (the doc comment at `MobileShellView.swift:94-97` promises a Lock Now door that does not exist) | Shared: `RoadCrossingsModel.lockNow` (`:365-370`) → `AppBootstrap.lock()` | VM-25; her 2026-11-12 word | S | VERIFIED. No `canLock` or `lockNow` call exists anywhere in `VariorumMobile/`. |
| D-23 | **Re-lock when Variorum leaves the screen (Castle)** | Mac: locks on sleep, on screen lock and after the idle time; switching apps never locks (`Shared/ProtectionController.swift:76-138`; `ProtectionCopy.idleSubline`) | **STALE** (her high-priority complaint) | `Features/Protection/MobileRelock.swift:46-145`; `Features/Shell/MobileShellRouter.swift:326-351` | Phone coordinator over the shared policy | her 2026-11-12 words | M | VERIFIED. Every background locks under Castle. Full trace in §2. |
| D-24 | Lock after time away, read on return | Decision 18 | ABSENT in effect | `MobileRelock.swift:126-145` | — | (part of D-23) | — | VERIFIED **unreachable**. Under Castle every leaving locks and clears `leftAt`, so `locksOnReturn` never fires. Under Standard the policy is nil. |
| D-25 | Coming back to where she was after a relock | (the Mac also rebuilds its tree — INFERRED) | ABSENT | `MobileShellView.swift:100-102` | — | — | M | VERIFIED. A lock sets `state = .opening` (`AppBootstrap.swift:1479`), which tears down `MobileShellView`. Its `@State` tab, `shelfPath` and `libraryPath` come back fresh at the shelf with empty stacks, so the open note is lost. |
| D-26 | The keystone line ("While Variorum is open and unlocked…") | SC; `Features/Settings/ProtectionPane.swift:93-100` | ABSENT | — | Shared `ProtectionCopy.keystoneOpenMeansReadable` | VM-26 | S | VERIFIED |
| D-27 | Protection receipts | The status seam | PARTIAL (provisional home) | `MobileProtectionScreen.swift:62-73` | Shared `speak` | P-VM8-8 | S | VERIFIED. A receipt that an open owes waits until she next opens the screen. |
| D-28 | The app-switcher snapshot cover | PL-6 (accepted at her walk) | PARTIAL | `Features/Shell/SnapshotPrivacy.swift`; `VariorumMobileApp.swift:73` | phone | PL-6 | S | VERIFIED. Only spans marked privacy-sensitive are covered (the words and secret fields), and only in `.ready`. Note text appears in the switcher even under Castle: the lock lands after the network round (`MobileShellRouter.swift:276` then `:351`), and the snapshot is taken at background entry (INFERRED, Apple lifecycle). |
| D-29 | Keep the store and key file out of the iOS device backup (a sibling phone that hasn't followed) | Rule 10; the VX-191 audit | ABSENT | Only plan files are excluded: `Shared/Protection/FilePlanStoreLeaf.swift:39` | Shared | VM-15 | S | VERIFIED |
| D-30 | Look inside, Open Library, Restore from Backup, Previous Libraries, Send Library | Rules 17–19; SC Library portability | ABSENT (Mac-only "this phase") | — | Shared `LookInsideModel`, `CopyDoorsModel` | PL-48, P-VX306-U3-18 | L | VERIFIED. This is a deferral, not a ruled exclusion. |
| D-31 | Data Safety backups and the iCloud Drive offer | Rules 1, 5 | RULED-EXCLUDED | — | Shared `StoreBackup`, not wired | PL-20 | — | The phone's store is re-derivable from the mirror (PL-20). |
| D-32 | The plaintext export (sqlite) and the scheduled `.md` export | R13p-8; rule 11 | ABSENT | — | Shared `PlaintextExportModel` | VM-30, PL-20, P-VM8-4 | M | VERIFIED. There is no document-picker road. |
| D-33 | Rule 11's export-off notice | Rule 11 | RULED-EXCLUDED (by construction) | — | — | F-U2-A | — | The phone has no scheduled export, so the notice can never stand. |
| D-34 | Acknowledgments | R13p-11 | PRESENT | `Features/Protection/MobileAcknowledgmentsSheet.swift` | Shared `AcknowledgmentsCopy` | PL-72 | — | VERIFIED |
| D-35 | The guide's protection chapter (three lessons, new road) and the compromise-recovery page | SC: "the guide seeds its protection chapter (three lessons) in every build" | STALE | `Features/Tutorial/MobileTutorialSeeder.swift:86-99` | phone seeder | VM-28 | M | VERIFIED. The phone's chapter is the one-lesson pre-13x copy, and the guide is Debug-only anyway (D-49). |

### 1b. Sync and accounts

| # | Capability | Mac | Phone | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D-36 | Sign in, create an account, delete the account (the Account sheet) | SC Doors (account) | PRESENT | reached through `SyncStatusRow` from `Features/Shell/MobileSettingsView.swift:124-139` | Shared `AuthViews` | PL-5, 8, 9 | — | VERIFIED |
| D-37 | The sync status row (states, progress counts, retrying) | SC; PL-66 | PARTIAL | `MobileSettingsView.swift:134` | Shared `SyncStatusViews` | PL-47, 58, 66 | M | VERIFIED. It lives **only inside the Settings sheet**: nothing on the shelf, Library, Starred or shell shows sync state (grep). The out-of-date face has no door because the phone has no update road (`Shared/SyncStatusViews.swift` `.appOutOfDate` arm). |
| D-38 | Two "Protection…" doors stacked | — | STALE (bug) | `MobileSettingsView.swift:134-161` | — | VM-27 (her word: a bug) | S | VERIFIED |
| D-39 | Turn on sync (set-up), Sync this library (join), the first-round sheet that stays | Rules 7, 14; VX-498/507 | PRESENT | `MobileProtectionScreen.swift:127-520` | Shared | PL-60 (proven live on her phone) | — | VERIFIED. The set-up asks for the twelve words; a phone-only user who did not write them down at the creation card has to make New Words first (INFERRED from the set-up's ask, `Shared/Protection/RoadAccountFaces.swift:326-333`). |
| D-40 | The leaves: Stop syncing here, This iPhone only, delete from this iPhone, sign out | Rule 16 | PRESENT (arms that leave Castle are held) | as D-39 | Shared | — | — | VERIFIED |
| D-41 | The row's door when the keys were replaced | `SyncStatusViews.swift:205-227` | PARTIAL | shared | Shared | — | S | INFERRED: the door opens the Account sheet, but on the new road the follow lives in Protection, not in the Account sheet. Same on the Mac. |
| D-42 | The offline typed unlock that heals once the vault answers | VX-544 | PRESENT by construction | shared | Shared | PL-73 | — | Ledger |
| D-43 | A first catch-up's save holds the writer for minutes | — | PARTIAL (performance) | core | Core | VX-497 | — | About 4–5 minutes on her corpus (PL-60) |
| D-44 | Syncing while the app is not open (background refresh or push) | — | ABSENT (today's design) | — | — | — | — | VERIFIED: no `BGTaskScheduler`, `UIBackgroundModes` or push anywhere. The phone syncs only while open, plus one round on leaving. A Castle library behind its lock could not sync anyway. |

### 1c. First run and onboarding

| # | Capability | Mac | Phone | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D-45 | The calm first open (Bookcase and quick entry, nothing in front) | Rule 2; SC The app | STALE | `AppBootstrap.swift:517` | — | VM-23 | (= D-06) | VERIFIED |
| D-46 | The welcome card (yes · no) | SC The app (VX-559) | ABSENT | — | Mac-local | — | M | VERIFIED (no phone face) |
| D-47 | The tour (thirteen steps plus the leg) | SC says "Mac-only" | ABSENT | — | Mac-local `TourEngine` | none. SurfaceContracts says Mac-only, but MobileSoul §4.5 does not list it among the exclusions | L | VERIFIED |
| D-48 | The launch seed set (field guide, the prince, empty starred notes, the disclaimer snippet, the readme letter) | SC "The seed set" | PARTIAL | `Features/Shell/MobileFirstWriteFurniture.swift:176-275`; `MobileStarterJournal` | Shared Prince seeder; Mac-local `BirthFurnitureSeeders` and readme | PL-17, 46, 51, 65 | M | VERIFIED. The phone seeds **only** the Prince (fresh stores only) and the starter Journal, at the first write. There is no readme letter and no guide. `StarredGatheringSeeder` is Shared but nothing on the phone calls it (grep). |
| D-49 | **The pocket guide (the phone's tutorial)** | — | ABSENT in Release, STALE in content | `MobileSettingsView.swift:294-372` (`#if DEBUG`); `MobileTutorialSeeder.swift:593-608` | phone | PB1-1 (placement is hers); VM-3 | M | VERIFIED. **A Release phone user has no tutorial at all.** The guide still teaches the duplicate divide ("copied onto both halves"), while the phone actually divides keep-on-top (`Features/Write/MobileStructural.swift:165`). Its test pin is wrapped in `withKnownIssue`. |
| D-50 | Empty-state copy | PL-17(c) | PRESENT (provisional) | `Features/Shell/MobileEmptyStore.swift` | — | — | S | VERIFIED. It says "Have an account? Settings ▸ Sync signs you in." Signing in is only half the road: the user then has to go to Protection ▸ Sync this library, and the copy doesn't say so. |
| D-51 | The sample library and per-book restore doors (the prince, sherlock, jekyll, the classics, the readme, the guide) | SC seed set | ABSENT | — | Shared `SeededBookRestore` | VM-29 | M | VERIFIED |
| D-52 | What's New | Mac `Features/WhatsNew/` | ABSENT | — | Mac-local (notes bundled per version) | PL-47(b), VM-9 (her call) | S–M | VERIFIED |
| D-53 | A door on the Mac pointing to the phone app | — | ABSENT | — | — | — | S | VERIFIED: no Mac text mentions the iPhone app (grep) |

### 1d. Doors to the outside, the Private mark and AI marks

| # | Capability | Mac | Phone | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D-54 | Copy full text (the Variorum document format) | SC Doors ▸ Import and Copy full text; `Core/Views/CopyForAI.swift` uses `Queries.variorumDocumentText` | STALE / PARTIAL | `Features/Write/MobileNoteClipboard.swift:181-185` (`Queries.exportPost`) | Core | — | S | VERIFIED. The phone copies the plain export: no title or tags header and no takes. A copy made on the phone does not round-trip through the Mac's Import the way the Mac's own copy does. Her original ask on the phone was "copy everything i've written". |
| D-55 | Export Note… (a `.md` file) and the share sheet | SC | ABSENT | — | Core | MobileSoul §5.7 (future list) | M | VERIFIED: no `ShareLink`, `fileExporter` or `UIActivityViewController` in the phone app |
| D-56 | Export Library and PDF | SC; `Features/Export/` | ABSENT | — | Core; Mac-local PDF | — | M | VERIFIED |
| D-57 | Import (a file becomes a Pool note, a folder becomes a book) | AppSpec §9 `importDocument` / `importBook` | ABSENT | — | Core op | MobileSoul §5.7 | M | VERIFIED: no `fileImporter`, document types or `onOpenURL` |
| D-58 | The MCP door | MCPSpec | RULED-EXCLUDED (by platform, recorded in the ledger) | — | — | PL-52, 55, 56, 70 | — | The phone runs no MCP server. This is recorded as "Mac-only" in the ledger, not in §4.5's exclusion list. |
| D-59 | The Private eye shown on notes and books (see-your-data) | SC Doors ▸ MCP; `ai_marks` | ABSENT | — | Core flags; Mac-local `Core/Views/PrivateMark*.swift` | — | S | VERIFIED: no `aiPrivate` or `ai_marks` reference in the phone app. A note she marked Private on the Mac shows no sign of it on the phone. |
| D-60 | A door to set or clear Private | `Sources/VariorumCore/Operations/Operations+PrivateMark.swift:38, 55` | ABSENT | — | Core | — | S | VERIFIED. Whether the phone offers it is her call (§4 Q7). |
| D-61 | The shared-with-AI icon, the AI section, the `ai_marks` switch | SC | RULED-EXCLUDED by construction | — | Grants are local-only | — | — | INFERRED: grants never sync, so the phone has nothing to draw. |

### 1e. Launch readiness

| # | Capability | Reference | Phone | File(s) | Ticket | Size | Note |
|---|---|---|---|---|---|---|---|
| D-62 | Crash-report opt-in | Mac `Features/Diagnostics/CrashReporting.swift` and the Diagnostics pane | ABSENT | — | PL-47(a), VM-9 | M | VERIFIED: no MetricKit code in the phone app |
| D-63 | Dynamic Type | MobileSoul §5.6 | ABSENT / PARTIAL | `Shared/Theme/VoiceTokens.swift:293-298, 329-334` (Terminal: all fixed `.system(size:)`); `:366-371, 403-408` (Study: body, title and heading scale; small 11.5 pt, mono 12.5 pt and navigation 13 pt are fixed) | VM-9 | L | VERIFIED. This explains her "weirdly tiny font": `tokens.small` (11.5 pt, fixed in both voices) is the face of every Settings row and every Protection caption. Only the editor text view adjusts (`Features/Write/MobileEditorTextView.swift:933`). |
| D-64 | A VoiceOver audit | §5.6 | PARTIAL | `accessibility*` modifier counts: Shell 56, Write 59, Takes 22, Protection 7, Read 0, Tutorial 0 | VM-9 | M | VERIFIED counts; no audit has been done |
| D-65 | The privacy manifest (`PrivacyInfo.xcprivacy`) | App Store requirement | ABSENT | none in the repo | — | S | VERIFIED absent. INFERRED required: the phone uses `UserDefaults` (a required-reason API) across Shared code. |
| D-66 | The export-compliance key (`ITSAppUsesNonExemptEncryption`) | — | ABSENT | `Variorum.xcodeproj/project.pbxproj` (mobile target) | — | S | VERIFIED absent. INFERRED: SQLCipher and CryptoKit encryption means App Store Connect will ask on every upload. |
| D-67 | The app icon | SC: "The sea-glass cards fan (#C2DDD3) is the app's one icon in every appearance"; VX-993 | STALE | `VariorumMobile/Assets.xcassets/AppIcon.appiconset/` | — | S | VERIFIED. The phone icon is a floppy disk on a cloud, and the dark and tinted slots are empty. The Mac uses `Variorum/AppIcon.icon` (`cards.svg`). |
| D-68 | The display name | — | ABSENT | pbxproj: no `INFOPLIST_KEY_CFBundleDisplayName`; `PRODUCT_NAME = $(TARGET_NAME)` | — | S | INFERRED: the home screen reads "VariorumMobile" |
| D-69 | Build-number stamping | Mac's "Stamp Build Number" phase (pbxproj 519-541) | ABSENT | the mobile target's phases are only Sources, Frameworks and Resources (pbxproj 326-330); the version is fixed at 1.0 (1) | — | S | VERIFIED. INFERRED: TestFlight needs a build number that rises with every upload. |
| D-70 | A TestFlight / App Store pipeline | VM-9 | ABSENT | `Tools/Release/release.sh` is Mac-only (notarytool) | VM-9 | M | VERIFIED. Installs today go by `devicectl` (VM-4 plan §3). |
| D-71 | Release Settings still ships a temporary "Diagnostics ▸ Record edit trace" | — | STALE | `MobileSettingsView.swift:208-292` | VM-13 (retires at the device walk) | S | VERIFIED |
| D-72 | Debug and Release share one bundle id (`io.lduarte.VariorumMobile`) | Mac Debug is `…Variorum.debug` | note | pbxproj (mobile Debug and Release) | — | — | VERIFIED. INFERRED: a Debug install replaces her Release app on the phone. |
| D-73 | Phone suite health | — | PARTIAL | `VariorumMobileTests/` (89 files, 857 `@Test`); UI tests are the Xcode template plus the TK2 spike | VM-24 (VM-34/36/37/38 are duplicates); VM-3's `withKnownIssue` | — | VERIFIED. One standing red (`MobileMarkdownCaretTests`, rescue-point replace). The last recorded green whole run was 824 tests / 129 suites with 4 declared known issues. |
| D-74 | The device queue: Face ID walk, 100k perf and memory leg, Display-Zoom strip, and more | MobileSoul §2 | ABSENT (needs her hands) | — | VM-13 | — | Ticket |
| D-75 | The Sherlock-deletes-stick acceptance round | — | open | — | VM-32 | — | Ticket (waits on an install) |

---

## 2. High priority: "app staying unlocked for a few minutes"

Her words, 2026-11-12:
- "app staying unlocked for a few minutes damn."
- "fully closing the app rather than just backgrounding it should make the library lock automatically though."
- "and a lock now button should be there like the mac."

This section prepares her ruling; it does not make it.

### 2.1 What happens today (VERIFIED trace)

1. **Leaving.** `scenePhase → .background` (`VariorumMobileApp.swift:215-256` → `mobileScenePhaseChanged`, `MobileShellRouter.swift:326-357`):
   1. A background grant is taken.
   2. `performBackgroundFlush` runs: the quick note files (`:232`), the editors flush, the leaving savepoints land, then **one network sync round** (`:276`).
   3. Then `relock?.didLeaveTheScreen()` (`:351`). It is deliberately not gated on cancellation.
2. **The decision.** `MobileRelockPolicy.locksOnLeaving` returns `policy != nil` (`MobileRelock.swift:50-52`). The policy is non-nil exactly when the open library's record says Castle (`Shared/Protection/ProtectionRoadLock.swift:31-34`). So under Castle **every** background locks: an app switch, a notification tap, Control Center into another app, Siri. Standard never locks.
3. **The lock** is `AppBootstrap.lock()` → `lockOnNewRoad` (`Shared/AppBootstrap.swift:1455-1489`):
   1. It waits out any act in flight (`awaitTheLockSeam`).
   2. `runWillLock` runs the phone's teardown (`mobileWillLock`, `MobileRelock.swift:80-96`): flush again, leaving savepoints, `services.stop()`, then `services = nil` and `firstWrite = nil`.
   3. `state = .opening` takes the whole `.ready` tree down.

   **Key material dropped:**
   - `ProtectionRoadLock.dropSessionMemory`: the pending typed-unlock sync-keys load and its derived secret, plus the account's sync keys held in session memory (`ProtectionRoadLock.swift:60-64`).
   - `roadStanding`, `roadSession` (the unlocked library), and the engine's key seam (`newRoadSyncKeys.attach(nil)`).
   - `binding.lock()`: the writer and the key are set to nil, the WAL is checkpointed, and the SQLCipher pool is closed (`Sources/VariorumCore/Persistence/StoreBinding.swift:89-114`).

   It then lands in the open road's own lobby. Quiet roads are not tried at a lock.
4. **Returning.**
   - `.active` → `didReturnToTheScreen` (`MobileShellRouter.swift:316-325`). `leftAt` is already nil (the lock cleared it), so nothing more happens there.
   - The lobby (`MobileRoadLockView`) re-reads its roads and asks for Face ID on its own (`MobileRoadFaces.swift:86-94`). Under Always ask she types the passphrase or the words instead.
   - On success the whole open road runs again: settle, repairs, `openStoreOffMain`. Fresh services start, which INFERRED includes a sync round, and the first-write furniture is primed.
   - A **fresh `MobileShellView` lands at the shelf with empty navigation stacks** (`MobileShellView.swift:100-102`). The note she was writing is gone from the screen.

   So every app switch costs, in order: a lobby, a Face ID glance (or typing), a store reopen, and the loss of her place. **That last cost is probably the sharpest part of "damn".** INFERRED from the code path; it is worth confirming with her.
5. **The idle minutes are dead code on the phone today.** `locksOnReturn` reads `DeviceSettings.idleLockMinutes` (default 10; `Sources/VariorumCore/Protection/Model/DeviceSection.swift:46-55`). It can never fire, because a Castle leaving already locked and cleared `leftAt`, and Standard has no policy (`MobileRelock.swift:126-145`). VERIFIED.
6. **The switcher snapshot.** The lock lands after the network round, so the snapshot iOS takes at background entry (INFERRED, Apple lifecycle) shows her open note. Only the privacy-marked spans are redacted (D-28). Even today's "real boundary" therefore leaves the last page visible in the app switcher.

### 2.2 "Fully closing always locks": verified, with the edges named

- **The key lives only in process memory.** The store opens with in-memory custody, "the road's key in hand" (`AppBootstrap.swift`, the `openStoreOffMain` doc). No "unlocked" flag is persisted. There is no state restoration: no `SceneStorage`, `NSUserActivity` or restoration identifiers anywhere in the phone app or Shared (grep). Ending the process — a swipe-away, a jetsam eviction, a crash — therefore leaves nothing open. VERIFIED.
- **A cold launch under Castle always meets the lobby.** At launch `route` tries the quiet roads (`Shared/Protection/ProtectionOpenRoad.swift:345-382`). Those are only `.silent` custody items and Apple wraps (`:963-975`).
  - A Castle key's custody class is always `.touchid` (a `.biometryCurrentSet` item), or no item at all under Always ask: `CustodyClass.for` in `Sources/VariorumCore/Protection/Model/Names.swift:22-31`.
  - Entering Castle deletes the Apple and silent items (rule 11).

  So nothing quiet opens a Castle library. The lobby then asks for Face ID, or for typing. VERIFIED.
- **What could make it false.**
  1. **A phone that has not followed into Castle.** Locally it is still Standard and opens quietly. That is rule 10 ("Until a device follows, it can still read what it already has… That is accepted and said plainly"), and VM-15 for the iCloud device-backup copy.
  2. **The ordinary Face ID item.** A Face ID glance opens the library at cold launch; that is the gate she chose, not a hole.
  3. **iOS cannot tell a user's swipe-away from a system eviction.** A backgrounded app that iOS evicts inside the grace window also comes back locked. That fails safe.
  4. **iOS "prewarming"** may start the process before she opens the app. `route` would land in the lobby, and the Face ID ask waits for `.active` (`ProtectionLobbyModel.swift:112`). INFERRED harmless.

### 2.3 The Mac's Lock Now and idle lock (VERIFIED) versus the phone

**The Mac:**
- **File menu: Lock Library Now ⌃⌘L.** Rendered only when `bootstrap.canLock`, which means Castle (`Variorum/EditorCommands.swift:643-655`). It calls `bootstrap.lock()`.
- **Settings ▸ Protection ▸ "On this Mac".** The idle Picker offers 5 · 10 · 30 · never, from `RoadGateRow.idleChoices`. The copy reads "Lock your library after you haven't used Variorum for:" plus "Switching to another app doesn't lock it; time away does. Variorum always locks when your Mac sleeps or its screen locks." Beside it is a Lock Library Now button (`Variorum/Features/Protection/RoadCrossingSheet.swift:245-272`) → `RoadCrossingsModel.lockNow` (`Shared/Protection/RoadCrossingsModel.swift:365-370`) → `AppBootstrap.swift:1038-1039` → `lock()`.
- **One declared capability:** `.lockLibraryNow` (`Variorum/Registry/CapabilityRegistry.swift:3179-3188`).
- **The monitors** (`Shared/ProtectionController.swift:76-138`): `NSWorkspace.willSleepNotification`, the `com.apple.screenIsLocked` distributed notification, and a local event monitor that stamps "last used". A 30-second tick then compares that stamp against the sealed minutes. **Nothing locks on app deactivation.**

**The phone:** no dial, no Lock Now (VM-25, verified as D-21 and D-22). Every Castle background locks instead.

**Notable:** the shared sentence `ProtectionCopy.idleSubline` (`ProtectionCopy.swift:256-258`) already reads, on the phone, "Switching to another app doesn't lock it; time away does. Variorum always locks when your **iPhone** sleeps or its screen locks." That describes a grace window. It is untrue of the phone today, and it is not rendered there.

### 2.4 What the canon says (quoted exactly)

- **CastleRules says nothing about re-locking, sleep, screen lock, idle time or Lock Now.** VERIFIED by reading all 27 rules. The rules a grace window must keep:
  - Rule 9: "Castle is one promise: no quiet road through Apple, ever, on any device of the account. Touch ID on this Mac is optional; 'Always ask' means no copy of the key on the device at all, and you type every time."
  - Rule 8, with R13p-14: Standard has quiet roads, so a lock there would be theater.
  - Rule 10: a device that has not followed reads through its own quiet road.
- **Decision 18** (`notes/plans/pre-13x-postures-design.md:110-111`; the file states "Every decision below is the author's, final as of 2026-09-04"): "**Castle's controls:** Always ask (no Touch ID copy at all); Lock after time away — 10 minutes default, offered 5 · 10 · 30 · never, the clock = time since Variorum was last used; re-lock on sleep / screen lock always on; Lock Library Now; …"
- **Decision 19** (`:112`): "**The open-app attacker is out of scope** and said once."
- **The keystone line** (`:205`; `ProtectionCopy.keystoneOpenMeansReadable`): "While Variorum is open and unlocked, everything in it is readable — that is what open means. Locking is how you end that."
- **vx-266 design** (`notes/plans/vx-266-castle-backups-prelaunch.md:240`): each device's facts hold "the settings that could weaken protection (the gate style, the idle lock, the scheduled Markdown export)". §3.10 (`:783-784`): a device with no choice yet starts with "its idle lock at the default".
- **VX-308 R-U4-3** (`notes/plans/vx-308-accounts-key-doors.md:1753-1758`): "THE IDLE SETTING HONORED IS THIS MAC'S SEALED ONE … `DeviceSettings.idleLockMinutes` (default 10, decision 18's, kept). The EXISTING timer — the controller's monitors (sleep and screen lock, always on in Castle; the 30-second tick over Variorum's own activity clock)…"
- **Where "lock on background" came from** (`notes/plans/phase-13p-note-protection.md:604-635`). Her verbatim words there are only the rider: "make sure that the mobile plan is thoroughly updated with what it'll need too in terms of autominting on keychain, setting passphrase, etc. some people will be mobile only users." Item **(g)**, "Re-lock on background as the phone's re-lock dial + the manual Lock Now act in demanded modes (the hand-someone-your-phone case — a REAL boundary here, key material dropped)", is one of the planner's expansion items (a)–(i) under that rider. The batch's PROVISIONALs were ratified "by the architect" (`:1331`, `:1999`). `MobileRelock.swift:5-9` calls item (g) "her words". **INFERRED from the plan's structure: the background-equals-screen-lock mapping was a planner's reading that the architect ratified, not her own ruling.** Her one recorded ruling from that batch, on item (i), points the other way: "i think that's fine on demanding unlock first, **if a user wants to set the app to force unlock on every open**" (`:1037-1039`). It treats unlocking on every open as a choice a user makes.

### 2.5 Does iOS give the app a reliable device-lock signal? (INFERRED throughout; a device probe is owed)

- Nothing in the codebase observes device lock today (grep found no `protectedData` or `isProtectedDataAvailable`). VERIFIED.
- The documented public signals are:
  - `UIApplication.protectedDataWillBecomeUnavailableNotification` and `…DidBecomeAvailableNotification`
  - `UIApplication.isProtectedDataAvailable`

  INFERRED from Apple's data-protection documentation:
  - They fire only when the user has a passcode.
  - "Will become unavailable" arrives some seconds after the lock (Complete-class keys are dropped about 10 seconds after locking).
  - They reach the app only while it is running. Whether a suspended app receives them when it resumes is uncertain.
- Pressing the side button with Variorum frontmost goes through `.background` exactly like an app switch, so the app cannot tell the two apart at that edge. It could:
  - keep its existing background grant alive for roughly 10–15 seconds to catch the notification (a small battery cost), or
  - check on return whether an unlock notification arrived while it was away.

  Both are **unproven on a device**. One honest fallback always works: with the idle minutes on return, a phone that sat locked longer than N minutes comes back locked anyway.
- A private Darwin notification (`com.apple.springboard.lockcomplete`) exists. Not recommended: it is undocumented and an App Review risk.

### 2.6 Three shapes that keep every Castle rule

None of them writes a key anywhere new. The key stays in process memory only, exactly as the Mac keeps it while another app is frontmost and as a Standard phone keeps it across every background today. So rules 8–11 and 20–22 are untouched, and termination still drops everything (§2.2). Each shape assumes Lock Library Now exists, per her word.

**Option A — the Mac's reading on the phone (the shared idle copy already describes it)**
- Leaving does not lock.
- On return, if she was away at least the dial's minutes (`DeviceSettings.idleLockMinutes`: default 10; 5 · 10 · 30 · never), the library locks *before* any content shows.
- A device lock also locks, wherever the signal in §2.5 proves reliable.
- The process ending always locks.
- Lock Library Now sits in the On this iPhone section, and possibly in one quicker home.
- The dead `locksOnReturn` arm becomes the live one, and the dial face (VM-25) ships with it.

*Cost in the hand-someone case:* for N minutes after leaving Variorum, anyone holding her **unlocked** phone can open her library unless she pressed Lock Now. If the phone itself is locked, they need her passcode or face first. That is decision 19's stated stance, and the keystone line says it.

**Option B — Option A plus an "Immediately" choice on the dial (today's behavior kept as an opt-in)**
- The same as A, but the dial offers Immediately (or a 1-minute step) beside 5 · 10 · 30 · never.
- She chooses the phone's default. The dial is per device (decision 1: "the idle minutes… is per device"), so the phone can differ from the Mac.
- This honors her 13p wording ("if a user wants to set the app to force unlock on every open") and keeps the hand-someone answer one setting away.

*Cost:* it changes decision 18's offered set (5 · 10 · 30 · never), which is hers to rule. It adds one choice to a shared face, and the Mac would either render it too or the phone would carry a phone-only choice.

**Option C — the device lock is the boundary**
- No timer while the phone stays unlocked. The library locks on device lock, on process end, and on Lock Now.
- The idle dial still covers long absences, measured from leaving.

*Cost:*
- It leans entirely on a signal (§2.5) that is unproven. Where the signal misses, it degrades to Option A's timer.
- The hand-someone window stays open for as long as her phone is unlocked and Variorum hasn't hit its idle minutes.
- After a phone unlock she meets two Face ID asks: the phone's, then Variorum's. That matches the Mac, where unlocking the screen is followed by Variorum's Touch ID.

### 2.7 What is still open for her (the shape is mostly ruled: background keeps the library open, a full close locks, Lock Now exists)

1. **How many minutes, and whether the phone reads the existing dial.**
   - (a) The existing per-device dial at its default of 10 minutes (5 · 10 · 30 · never); no new setting.
   - (b) The same dial with a phone default she names.
   - (c) Add "Immediately" or a 1-minute step (Option B).

   CastleRules is silent. Decision 18 owns the offered set.
2. **What happens on device lock.**
   - (a) Lock, as the Mac does on screen lock (decision 18's "always on"), using the signal wherever it works and the idle minutes otherwise.
   - (b) Ignore device lock and rely on the idle minutes, reasoning that a locked phone is already a boundary.

   Option (b) changes decision 18's "re-lock on sleep / screen lock always on" for the phone and needs her explicit word. Either way the signal needs a device probe before it is promised in copy.
3. **What the app switcher shows during the window.**
   - (a) As today: the page, with the words and secret fields redacted.
   - (b) Under Castle, the whole shell covered whenever the scene is not active. This is the existing `SnapshotPrivacy` seam widened. It also hides the page during Control Center or notification pull-downs, and it closes the "last page visible in the switcher" gap that exists today (§2.1 step 6).
   - (c) A cover only once the window has lapsed. Not reliably possible: the snapshot is taken at leaving, before anyone knows how long she will be away (INFERRED).

   CastleRules is silent. Rule 11's "a plain copy on disk would undo the promise" is the nearest principle, since iOS stores the snapshot on disk (INFERRED).
4. **Where she lands after a relock that does happen.**
   - (a) The shelf, as today.
   - (b) Back on the note and tab she left, remembered in memory only, so nothing is written while locked. This is not a Castle rule; it is UX, and probably half of her pain.
5. **Where Lock Now lives.** The On this iPhone section (VM-25, the Mac pane's twin) for sure. Possibly also the top of the Settings sheet, or a Home Screen quick action (INFERRED feasible). This is a design call, not a rule.
6. **Always ask phones.** Under Always ask, a lapsed window costs typing the passphrase, not a glance. Should the dial default differ by gate style? Hers. CastleRules 9 is satisfied either way, because the key is never kept at rest.

Considered and not recommended: re-using the device's Face ID unlock (`LAContext.touchIDAuthenticationAllowableReuseDuration`) to skip the second glance. It still closes and reopens the store and still loses her place, so it does not address the pain.

---

## 3. What's there but behind (the existing faces, judged as they stand)

1. **Castle on the phone is punishing.** It re-locks on every app switch, makes her glance for Face ID or type, rebuilds the shell at the shelf, and re-runs the open road and service start-up. Both the idle dial and Lock Now are missing (§2).
2. **The first open is not calm.**
   - The phone still shows its creation words card before anything else (rule 2's amendment, VM-23).
   - The card has no Copy, and it says "Variorum won't show them again" even when a join is about to replace the words.
   - It is not covered in the app switcher (D-06).
   - For the launch's central flow, a Mac user adding the phone, the very first thing shown is twelve words they don't need.
3. **Rule 3 is unmet on a phone that creates libraries.** Nothing ever asks a phone-only user for a passphrase: no band card, no tour cards, no reminder (D-08). Her 13p rider ("some people will be mobile only users") is exactly the case left without it.
4. **There is no tutorial in Release.** The pocket guide is reachable only from a Debug Settings door. It teaches the retired duplicate divide, and its privacy chapter predates the Castle rebuild (D-35, D-49).
5. **Settings is hard to reach and hard to read.**
   - Its only door is a small "Settings" text label in the shelf's masthead (`Features/Shell/MobileShelfView.swift:247-255`), not reachable from the Library or Starred.
   - The sheet is a fixed `VStack` with no `ScrollView` (`MobileSettingsView.swift:88-380`). It fits today only because its 11.5 pt chrome does not scale (INFERRED).
   - Release still ships the temporary "Record edit trace" diagnostics (D-71).
   - Two "Protection…" doors stack while sync reads locked or not-yet (VM-27).
6. **The Protection screen buries the join.**
   - The account section, which holds "Sync this library…", the one door a Mac user adding the phone needs, comes last after four sections (D-11).
   - Every caption is 11.5 pt fixed.
   - Terminal lowercases "on this iphone".
   - A Castle user meets "You're in Castle." with no door beside it (D-16).
   - If the account leaves Castle elsewhere, the phone dead-ends (D-18).
7. **Sync state is invisible outside Settings** (D-37). A user cannot tell whether the phone is caught up without opening Settings. That matters for "people actually using variorum synced between devices", since the phone only syncs while open (D-44).
8. **Copy on the phone is not Copy full text** (D-54). The phone copies plain prose with no header or takes, so it does not round-trip through the Mac's Import.
9. **Stale words in the code.** `MobileShellView.swift:94-97` documents a Lock Now door that doesn't exist. `MobileRelock.swift:5-9` attributes item (g) to "her words" (see §2.4). The shared idle sentence contradicts the phone's behavior (§2.3).
10. **Launch plumbing.** The icon is the wrong brand mark. The display name is probably "VariorumMobile". There is no privacy manifest, no export-compliance key and no build stamping (D-65 to D-70).

---

## 4. Flow notes (navigation as built)

**(a) A brand-new phone user (Release build).**
1. Install and open. The store opens off the main thread (`MobileStoreOpeningView`).
2. `route` → `.startFresh` creates a Standard library with a silent item and an Apple road. The **words card** follows: twelve numbered words and "I've written them down" (`AppBootstrap.swift:517`).
3. The shelf appears: "No books yet — Today's Entry starts your journal." and "Have an account? Settings ▸ Sync signs you in." (`MobileEmptyStore.swift`). There is no welcome card, no tour and no passphrase ask.
4. The first write (quick note, New Note, Today's Entry, New Book, a new scrap) quietly seeds the starter Journal and the Prince (`MobileFirstWriteFurniture.swift:176-275`). There is no guide and no readme letter.
5. To sync: shelf masthead "Settings" → Sync row "Signed out · Sign in…" → the Account sheet (create an account) → back in Settings the row reads "Sync isn't on for this library yet" → **Protection…** (Settings dismisses, the screen is pushed on the shelf stack) → scroll to the bottom → "Turn on sync…". This set-up asks for the twelve words and a new passphrase typed twice. A user who did not record the words at the card must first use New words (INFERRED from the set-up's ask). Then the first-round sheet stays to show progress.

*Awkward points:* the twelve words come before any context; the passphrase is never asked; the sync road crosses three surfaces; the empty state names only the first of them.

**(b) A Mac user adding their phone (the launch's central flow; proven live on her phone at VM-8, PL-60).**
1. Install and open. Words card for a throwaway library ("did it change my 12 words?").
2. The empty shelf, then Settings, then Sign in… on the Account sheet.
3. The sync row reads "not on yet", with a doubled Protection… door (VM-27).
4. Protection screen → scroll past the passphrase, words, check and crossings sections → "Sync this library…".
5. Type one of the account's secrets (rule 14). Into a Castle account, choose Face ID or Always ask.
6. Joining a Castle account re-keys the library, so the screen goes down and comes back (F-U1-3).
7. The words moment (shown if she typed the words; said if she typed the passphrase).
8. The first-round sheet: "Syncing — N of M"; about 6 minutes on her corpus, with the save about 4–5 minutes (VX-497).
9. Then she has no ambient sign of sync.
10. Under Castle, leaving the app mid-round locks it. The download resumes from its stage after Face ID (PL-60), and she lands at the shelf.
11. Her wings all show mixed together (another reader's area).

*Awkward points:* about 12 taps across 4 surfaces; the most important door is buried; the first thing shown is irrelevant; the first hour of Castle use is a Face ID lobby on every app switch. If she wrote before signing in, the seeded Prince and Journal ride up with the join and rely on SyncSpec §7's pristine-copy dedupe and seeded-furniture fold (rules VERIFIED present at `notes/SyncSpec.md:81, 92`; their behavior on this road INFERRED).

**(c) Everyday Castle use.** Writing → switch to Messages → back means: lobby, Face ID glance, "Opening your library…", the shelf. The note she was in is gone from screen (§2.1).

**(d) Getting to Protection.** Shelf root only → "Settings" (11.5 pt text) → Sync section → "Protection…". The Library, Starred and Write surfaces have no road there.

---

## 5. Open questions for the author (real product calls only)

1. **The grace window** (§2.7): the minutes and whether to read the dial (a/b/c); device lock (lock vs. idle only); the switcher cover (as today / whole-shell cover under Castle); landing after a relock (shelf / where she was).
2. **The phone's first open.**
   - (a) The phone's own band card above the quick entry, holding the words (with Copy), rule 3's reminder and E6, as VM-23 and VM-28 scope it.
   - (b) (a) plus a short phone welcome card offering a phone tour or guide, which closes with the passphrase and words cards.
   - (c) (a) only, with the pocket guide seeded at the first write as the phone's teacher.
3. **The road for a Mac user adding the phone.**
   - (a) A first-open fork ("New to Variorum" / "I already use Variorum"). The second arm goes straight to Sign in and then "Sync this library…", and never mints throwaway words. Rule 2's retirement at a landed join would then be moot.
   - (b) Keep the Settings road, but lead the empty state and the Protection screen with the join.
   - (c) (b) plus a Mac-side pointer to the phone app (there is none today, D-53).
4. **F-PH-2 and F-PH-1 (her wording).** The phone wording of her rule-12 leave sentence and of the rule-21 "this Mac" sentences.
   - (a) Word them, so Use Standard, the follow out and the leaving join/Move render (D-16, D-18).
   - (b) Keep leaving Castle a Mac-only road and say so on the phone. That conflicts with MobileSoul §4's no-redirect rule unless she rules it an exclusion.
5. **What's New on the phone.**
   - (a) None; the App Store's notes stand in.
   - (b) An in-app card from the shared notes source.
   - (c) A "What's new" row in Settings.
6. **Crash reports.**
   - (a) A MetricKit opt-in (default off, verbatim), like the Mac's mail-draft road.
   - (b) Rely on TestFlight and App Store Connect's own Apple-consent crash logs.
   - (c) Both.
7. **The Private mark on the phone.**
   - (a) Show the eye only (see-your-data).
   - (b) The eye plus a set/clear door. It is her hand, and MCPSpec's "no MCP road writes" fence is not touched.
   - (c) Nothing, because the phone has no AI door.
8. **Words Copy on the phone.**
   - (a) None (today).
   - (b) A copy kept local to the device and expiring, the iOS twin of the Mac's concealed type cleared at lock.
9. **The phone's outside doors** (D-54 to D-57).
   - (a) Align the phone's Copy to Copy full text (the document format) and add the share sheet for one note.
   - (b) Keep the plain prose copy and add Copy full text beside it.
   - (c) Also bring Import through the Files picker into scope for v1, or leave it for later.

---

## 6. Notes for other readers and the orchestrator

- **Fonts (overlaps the shell/design reader).** The "tiny font" and "tiny affordances" complaints trace to fixed token sizes in Shared `VoiceTokens` (D-63). Any fix is cross-platform: the Mac reads the same tokens.
- **A wrong attribution.** `MobileRelock.swift` calls the background-lock rule "her words", but the 13p plan shows it was the planner's item (g) (§2.4). Her her-words.md note "built to her 13p words" should be read with that in mind.
- **SurfaceContracts versus MobileSoul.** SurfaceContracts calls the tour "Mac-only", while MobileSoul §4.5's exclusion list does not include it. A planner should not treat the tour as excluded without her word.
- **Overlapping tickets.** VM-23 sits inside VM-28. VM-25 and VM-26 are small faces over shared models. VM-24 is the one standing red (VM-34/36/37/38 are its duplicates).
- **Performance.** The perf reader may want D-43 (VX-497) and VX-672 (a phone sync round after a book delete takes minutes; Suspected).

---

## 7. Counts

75 rows (D-01 to D-75). Each row is counted once, by the first status in its cell.

| Status | Count | Rows |
|---|---|---|
| PRESENT | 16 | D-01, 02, 04 (its wording is stale; F-PH-1), 05, 11, 12, 14, 15, 17, 20, 34, 36, 39, 40, 42, 50 |
| PARTIAL | 11 | D-03, 13, 19, 27, 28, 37, 41, 43, 48, 64, 73 |
| STALE | 8 | D-06, 23, 35, 38, 45, 54, 67, 71 |
| ABSENT | 34 | D-07, 08, 09, 10, 16, 18, 21, 22, 24, 25, 26, 29, 30, 32, 44, 46, 47, 49, 51, 52, 53, 55, 56, 57, 59, 60, 62, 63, 65, 66, 68, 69, 70, 74. Of these, D-16 and D-18 are held for her wording, D-30 is a Mac-only deferral, and D-74 needs her hands. |
| RULED-EXCLUDED | 4 | D-31, 33, 58, 61 |
| Note or open item | 2 | D-72 (the shared bundle id), D-75 (VM-32's acceptance round) |
