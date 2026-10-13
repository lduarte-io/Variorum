# Apple platform facts for Variorum key custody

Research notes for the posture / backup / restore redesign. Gathered 2026-10-13. Read-only research: no repository was changed. The only file written is this one.

## How to read this

- Every fact carries a **tag** and a **confidence**:
  - **[Doc]** Apple documentation, an SDK header comment, the Apple Platform Security guide, or an Apple Support article.
  - **[DTS]** An Apple Developer Technical Support engineer (usually Quinn "The Eskimo!") on the Developer Forums. Well informed, but not a contract.
  - **[Obs]** Observed behavior: developer or community reports, or my own read-only inspection of this Mac.
  - **[Inf]** My inference from the above. Never treat it as documented.
  - **Unknown** means nothing reliable was found. I have not filled those gaps with guesses.
- SDK quotes come from the **macOS 27.0 SDK** (Xcode 27) on the Mac this ran on. Entitlement inspections (`codesign -d --entitlements -`) were run on that Mac's system apps, on **macOS 27.0**. I could not inspect macOS 14–26 binaries.
- Apple's Developer Forums block automated fetches (HTTP 403). Forum quotes come from **Internet Archive snapshots** of the thread. Where a thread is marked **(search summary)**, I only saw a search engine's summary of it, so its confidence is lower.

---

## 1. macOS data-protection keychain vs file-based keychain

1. **There are two implementations.** On macOS, SecItem targets the file-based keychain by default. It targets the data-protection (DP) keychain when `kSecUseDataProtectionKeychain` or `kSecAttrSynchronizable` is true. iCloud Keychain, biometric protection and Secure Enclave keys all require the DP keychain. **[Doc] high.** [TN3137 On Mac keychain APIs and implementations](https://developer.apple.com/documentation/technotes/tn3137-on-mac-keychains)
2. **There is one DP keychain per user, and it exists only in a user context.** TN3137: "Each user gets exactly one data protection keychain. The system selects the correct keychain based on the context of the caller." Also: "The data protection keychain is only available in a user login context. You can't use it, for example, from a `launchd` daemon." **[Doc] high.** TN3137.
3. **Where it lives (this is an implementation detail, not API):**
   - The DP keychain is a SQLite database at `~/Library/Keychains/UUU/keychain-2.db`, "where UUU is a UUID". Quinn warns: "Do not depend on the location and structure of this file." **[DTS] high.** [SecItem: Fundamentals, thread 724023](https://developer.apple.com/forums/thread/724023) (archived 2024)
   - "For Mac computers, the user's keybag is stored in their Keychains folder inside a folder named with the hardware UUID". The example given is `.../user.kb`. **[Doc] high.** [Platform Security: Keybags for Data Protection](https://support.apple.com/guide/security/keybags-for-data-protection-sec6483d5760/web) (Dec 2024)
   - The secret value of each item is encrypted with a per-row key that "always requires a round trip through the Secure Enclave". The metadata key is SE-protected but cached in the application processor. **[Doc] high.** [Platform Security: Keychain data protection](https://support.apple.com/guide/security/keychain-data-protection-secb0694df1a/web) (Dec 19 2024)
4. **Access is controlled by keychain access groups.** The groups come from code-signing entitlements, which "must be authorized by a provisioning profile". An optional `SecAccessControl` can add further conditions. Library code inherits the entitlements of its host app. A sandboxed app with a real App ID and profile works normally. **[Doc] high.** TN3137; [Sharing access to keychain items among a collection of apps](https://developer.apple.com/documentation/security/sharing-access-to-keychain-items-among-a-collection-of-apps)
5. **The accessibility attribute is honored for DP items on macOS.** The `SecItem.h` comment for `kSecUseDataProtectionKeychain` says: "Set to kCFBooleanTrue to use kSecAttrAccessGroup and/or kSecAttrAccessible on macOS without requiring the item to be marked synchronizable." **[Doc] high.** SDK `Security/SecItem.h`
6. **What "WhenUnlocked" means on macOS is not documented.** Platform Security: "The various Apple operating systems use differing mechanisms to enforce the guarantees associated with the different keychain protection classes. On devices with macOS, Data Protection isn't used directly to enforce these guarantees."
   - No Apple text says whether a `WhenUnlocked` item becomes unreadable while a logged-in Mac's screen is locked.
   - One hint that the DP keychain has a lock and unlock cycle tied to the screen lock: a DTS engineer described a known bug (FB13128730). In it, authorization plug-ins "fail to unlock the data protection keychain" when unlocking from the screen-saver context. Source: thread 796487 **(search summary)**.
   - Quinn's general rule: iOS statements "typically apply to macOS when you target the data protection keychain" (thread 724023).
   - **[Doc] for the absence; [Obs] and [DTS] for the hints. Medium-low confidence on the actual screen-lock behavior.** Test it before relying on it.
7. **On macOS, ThisDeviceOnly reliably means the item never syncs.** Synchronizable items may not use a ThisDeviceOnly class. Apple's "won't migrate" wording is phrased for iOS backups. There is no documented macOS equivalent for Time Machine or Migration Assistant (see §3). **[Doc] high** for the no-sync part; **[Inf] medium** for the rest.
8. **Context only: macOS 26.4 changed file-based keychains.** TN3137: "In macOS 26.4 and later … A keychain file might reference a protected entropy file. To unlock such a keychain you need both the keychain password and the protected entropy file." Those files live in `/var/db/SystemKeys`.
   - On macOS 27.0 here, `security help` describes `unlock-keychain` as follows: it "might succeed even if an incorrect password is presented, if other unlock factors are available."
   - Neither point is about the DP keychain. Both show Apple binding keychains to the individual Mac.
   - **[Doc] and [Obs] high.** TN3137; local `security help`.

## 2. Keychain items across app deletion and reinstall

1. **On iOS, items survive deletion, but Apple has never promised this.** Quinn: "All versions of iOS prior to 10.3 beta preserve keychain items when an app is deleted. IMPORTANT This was most definitely an implementation detail of the original iOS keychain. Our keychain documentation has never specified what would happen in this case."
   - The 10.3 beta deleted such items. Apple "rolled back before 10.3 GM".
   - Quinn later (iOS 14 era) called persistence "expected behaviour (except in some beta releases of 10.3)".
   - His advice: "write your app so that it acts reasonably if this behaviour changes." For delete-on-uninstall, "entangle it with a random key you store on disk."
   - **[DTS] high** that items persist today; **medium** on whether that will last. [Thread 36442](https://developer.apple.com/forums/thread/36442) (pages 1–2, archived 2022/2025)
2. **No change was found for iOS 15–26.** No Apple announcement and no documented change. **[Absence] medium.**
3. **Erasing the device ("Erase All Content and Settings") removes the items.** **[Obs/forum] high.** Thread 36442.
4. **macOS has no uninstall step that touches the keychain.**
   - Quinn: "I know when a User uninstall application, keychian content still exist. FYI, that's an implementation detail that could change in the future." [Thread 98398](https://developer.apple.com/forums/thread/98398)
   - A Catalyst developer: deleting the app from /Applications "is leaving the keychain items created in Local Items keychain." [Thread 697215](https://developer.apple.com/forums/thread/697215)
   - **[DTS] and [Obs] high.**
5. **A reinstall sees the old items exactly when its entitlements resolve to the same access groups** (same team, same app ID or a shared group). Quinn names entitlement changes as the usual cause of "lost" keychain items. Check the built app with `codesign -d --entitlements -`, not the `.entitlements` file. **[DTS] high.** [SecItem: Pitfalls and Best Practices, thread 724013](https://developer.apple.com/forums/thread/724013)

## 3. ThisDeviceOnly, backups and migration

### iOS (well documented)

1. **Encrypted Finder or iTunes backups:**
   - "nonmigratory keychain items remain wrapped with the UID-derived key, allowing them to be restored to the device they were originally backed up from but rendering them inaccessible on a different device." (Platform Security: Keybags)
   - Classes without ThisDeviceOnly "will migrate to a new device when using encrypted backups." (`SecItem.h`)
   - **[Doc] high.**
2. **iCloud Backup:** "iCloud Backup is also used to back up the local device keychain, encrypted with a key derived from the Secure Enclave UID root cryptographic key of the device … This allows the database to be restored only to the same device from which it originated."
   - So **no local keychain item, ThisDeviceOnly or not, reaches a different iPhone through iCloud Backup.**
   - Quinn's December 2018 test matrix agrees. Normal items: unencrypted backup restores to the same device only; encrypted backup restores to the same or a different device; iCloud Backup restores to the same device only. ThisDeviceOnly items: same device only in every case.
   - **[Doc] and [DTS] high.** [Platform Security: iCloud Backup](https://support.apple.com/guide/security/sec2c21e7f49/web) (Dec 2022); [thread 93373](https://developer.apple.com/forums/thread/93373) (archived 2024)
3. **The same iPhone after Erase All Content and Settings counts as the same device.** Quinn: "that's not a different device. That is, restoring the backup will restore these keychain items." In the same post: "Erasing the device does result in a 'new' SE." **[DTS] medium-high.** [Thread 682480](https://developer.apple.com/forums/thread/682480) (c. 2021)
4. **Quick Start (direct iPhone-to-iPhone transfer) may carry ThisDeviceOnly items.**
   - A developer reported an `…AlwaysThisDeviceOnly` item surviving Quick Start. Quinn replied: "it does seem odd that it would let a ThisDeviceOnly credential escape. If that's what you're seeing, I recommend that you file a bug." [Thread 112555](https://developer.apple.com/forums/thread/112555) (c. 2018)
   - A 2025 thread reports the same for `AfterFirstUnlockThisDeviceOnly`, and it is unresolved. [Thread 802526](https://developer.apple.com/forums/thread/802526) **(search summary)**
   - This is undocumented. **[Obs] medium.**
5. **Synchronizable items come back on any device that joins the account's iCloud Keychain**, regardless of backups. **[Doc] high.**

### macOS (thinly documented)

6. **Apple's Keychain Access guide:**
   - "If you migrate your data to a different Mac using Setup Assistant, your keychains are automatically transferred to the new computer."
   - But: "Note: You can't copy passwords stored in your Local Items or iCloud Keychain. To transfer these keychain items to another computer, set up iCloud Keychain on the other computer by signing in to your Apple Account."
   - It also says not to copy "encrypted folders with names that appear as a series of numbers".
   - **[Doc] high** that these sentences exist; they are ambiguous about whether Migration Assistant moves Local Items. [Copy keychains to another Mac](https://support.apple.com/guide/keychain-access/kyca1121/mac)
7. **Community reports say Local Items did not arrive on a new Mac.** This covers both Migration Assistant and Time Machine restores, mostly on older macOS. One 2020 report says the store "can only be restored onto the exact same machine". **[Obs] medium; not verified on macOS 14–27.** [TidBITS Talk](https://talk.tidbits.com/t/it-seems-local-items-keychain-can-not-easily-be-transferred-to-a-new-machine/19109); [HN 24626562](https://news.ycombinator.com/item?id=24626562)
8. **ThisDeviceOnly vs other classes under Time Machine or Migration Assistant on macOS: Unknown.** No Apple statement draws that distinction.
9. **Time Machine restore to the same Mac after an erase: Unknown.** Points that bear on it:
   - Erasing destroys effaceable and SE-protected key material.
   - SE-protected keys become "permanently useless" after an erase (Quinn, §8).
   - On iOS the backup path explicitly re-wraps items with the never-changing UID. Time Machine copies files and has no documented equivalent.
   - **[Inf] low.** The design should assume the local DP keychain may or may not come back.
10. **On macOS 26.4 and later, file-based login keychains from a different Mac "almost certainly" can't be unlocked.** **[Obs] medium.** [Eclectic Light, 2026-09-14](https://eclecticlight.co/2026/09/14/how-can-you-copy-or-restore-keychains/); [lapcatsoftware 2026/9/5](https://lapcatsoftware.com/articles/2026/9/5.html)
11. **Secure Enclave keys never migrate and never survive an erase** (see §8). **[DTS] high.**

## 4. kSecAccessControlBiometryCurrentSet

1. **What invalidates the item:** "Touch ID must be available and enrolled with at least one finger, or Face ID available and enrolled. The item is invalidated if fingers are added or removed for Touch ID, or if the user re-enrolls for Face ID." `SecAccessControl.h` says the same. **[Doc] high.** [biometryCurrentSet](https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/biometrycurrentset)
2. **Adding then removing a finger probably still invalidates it.** The LAEnvironment header says the enrollment state hash "does not directly map to the enrolled templates, e.g. if a finger is added to Touch ID enrollment and then removed, the final state would be different." **[Doc]** for the hash; **[Inf] medium** that the item is invalidated too.
3. **Removing all fingers is covered by "removed".** **[Doc] high.**
4. **Two other actions are not documented triggers:**
   - Switching off a Touch ID toggle without changing enrollment.
   - Changing the login password. Platform Security says "a change of passcode just rewraps the class key", so items should survive a password change. [Data Protection overview](https://support.apple.com/guide/security/sece8608431d/web)
   - A forgotten-password reset (as opposed to a change) is undocumented for the DP keychain. Community reports say Local Items became unusable after `resetpassword`.
   - **[Inf] medium** for the password change; **Unknown** for the reset.
5. **The item is made unreadable, not deleted.** Apple says "invalidated", never "deleted". Observed read results:
   - iOS 14.6 and earlier return `errSecItemNotFound` (-25300).
   - iOS 15 and later return `errSecAuthFailed` (-25293).
   - `errSecAuthFailed` is also returned when the app goes to the background mid-authentication, so the code alone is ambiguous.
   - Whether the stale row stays behind (so a fresh `SecItemAdd` hits `errSecDuplicateItem`) is undocumented. Delete before re-adding.
   - I found no macOS-specific report.
   - **[Obs] medium.** [Thread 690546](https://developer.apple.com/forums/thread/690546); [thread 690778](https://developer.apple.com/forums/thread/690778) (both archived 2022)
6. **Temporary unavailability is not invalidation.** The password is required after a restart, after logout, after 48 h without an unlock, after 156 h without the password combined with 4 h without biometrics, and after five failed matches. **[Doc] high.** [Platform Security: Optic ID, Face ID, Touch ID, passcodes, and passwords](https://support.apple.com/guide/security/sec9479035f1/web)
7. **Detecting a change before trying a read:**
   - **`LAContext.evaluatedPolicyDomainState`** is deprecated in macOS 15 / iOS 18, replaced by `domainState.biometry.stateHash`.
     - It is non-nil only after `canEvaluatePolicy` succeeds for a biometric policy, or after a successful biometric evaluation.
     - "The value of this property is different in different processes, so you can't compare the value from one app to the value from another app."
     - **[Doc] high.** [evaluatedPolicyDomainState](https://developer.apple.com/documentation/localauthentication/lacontext/evaluatedpolicydomainstate)
   - **`LAContext.domainState`** (macOS 15+ / iOS 18+) exposes `.biometry.stateHash`.
     - "If biometric database was modified (fingers, faces were removed or added), `stateHash` data will change." It is nil when nothing is enrolled.
     - Header warning: "the value returned by this property can change exceptionally between major OS versions even if the state of biometry has not changed."
     - **[Doc] high.** SDK `LADomainState.h`; [LADomainState](https://developer.apple.com/documentation/localauthentication/ladomainstate)
   - **`LAEnvironment.currentUser.state.biometry`** (macOS 15+) offers `biometryType`, `isEnrolled`, `isLockedOut`, `isUsable`, `stateHash` and `builtInSensorInaccessible`.
     - `stateHash` "changes whenever the biometric enrollment is changed" and "returns different values to different apps".
     - An `LAEnvironment.Observer` reports changes.
     - **[Doc] high.** SDK `LAEnvironmentMechanismBiometry.h`, `LAEnvironmentState.h`
   - **Net:** a stored hash that changes means "probably invalidated", but a major OS update can raise a false alarm. The read itself is the final word.

## 5. Touch ID with the lid closed, or with a Magic Keyboard

1. **macOS 15 and later expose the lid-closed case directly.** `LAEnvironmentMechanismBiometry.builtInSensorInaccessible`: "Whether the built in biometric sensor is inaccessible in the current configuration, preventing the use of biometry. Currently, the only example of this is a Clamshell Mode on macOS. The user will be not able to use Touch ID if the MacBook lid is closed while connected to external monitor and keyboard, unless the external keyboard has Touch ID." **[Doc] high.** SDK header.
2. **LAError codes:**

   | Code | Value | Since | Header meaning |
   |---|---|---|---|
   | `biometryNotPaired` | -12 | macOS 11.2 | "this device supports biometry only via removable accessories and no accessory has been paired" |
   | `biometryDisconnected` | -13 | macOS 11.2 | "...the paired accessory is not connected" |
   | `biometryNotAvailable` | -6 | | |
   | `biometryNotEnrolled` | -7 | | |
   | `biometryLockout` | -8 | | |
   | `systemCancel` | -4 | | |

   **[Doc] high.** SDK `LAError.h`, `LAPublicDefines.h`
3. **What `canEvaluatePolicy` returns with the lid closed is not documented.** Observed:
   - `canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)` returns false with the lid closed, reportedly even with a Touch ID Magic Keyboard attached. A DTS engineer treated that as a bug. [Thread 711838](https://developer.apple.com/forums/thread/711838) **(search summary)**
   - Evaluation failures show up as `LAError.systemCancel` (-4) with the debug text "Touch ID is not available in closed clamshell mode". [tashian/tsm PR #24](https://github.com/tashian/tsm/pull/24); a 1Password community log.
   - **[Obs] medium-low.** Don't key logic on one code.
4. **A Magic Keyboard with Touch ID is only a sensor.**
   - The Mac's Secure Enclave "performs the enrollment and matching operations".
   - "If a finger that was enrolled on a built-in Mac Touch ID sensor is presented on a Magic Keyboard with Touch ID, the Secure Enclave in the Mac successfully processes the match and vice versa."
   - A keyboard pairs with one Mac at a time; a Mac can pair with up to five keyboards.
   - **[Doc] high.** [Platform Security: Magic Keyboard with Touch ID](https://support.apple.com/guide/security/secf60513daa/web)
   - Observed: a keyboard can lose its pairing while the lid is closed; re-pair it over USB. **[Obs] low-medium.** tsm PR #24.
5. **The item should still be readable after the lid opens.** This is not stated explicitly. But closing the lid doesn't change enrollment, and the documented triggers are all enrollment changes, so a `.biometryCurrentSet` item should work again once Touch ID is usable. **[Inf] medium-high.**
6. **Telling "no Touch ID hardware" from "temporarily unavailable":**
   - On macOS 15+, `LAEnvironment.currentUser.state.biometry` is "`nil` if biometry is not supported by this device".
   - `biometryType` "always reads the type of biometry supported by device hardware".
   - `isUsable`, `isLockedOut`, `isEnrolled` and `builtInSensorInaccessible` give the reason it can't be used.
   - Before macOS 15, `LAContext.biometryType` "is set only after you call the canEvaluatePolicy(_:error:) method, and is set no matter what the call returns", and the error codes add detail.
   - **[Doc] high.** [LAContext.biometryType](https://developer.apple.com/documentation/localauthentication/lacontext/biometrytype)
   - **Unknown:** on a Mac without built-in Touch ID and no paired keyboard, whether `biometry` is nil or reports Touch ID as present but unusable. The -12 code suggests "supported via accessory".

## 6. iCloud Keychain and synchronizable items

**(a) Adding a synchronizable item while iCloud Keychain is off, or while signed out of iCloud.**
- No Apple page states the result. It is widely observed to succeed: the item is stored in the local DP keychain with the sync flag set, and it syncs once iCloud Keychain is on.
- Supporting context:
  - TN3137: Keychain Access shows the DP keychain "as either *iCloud Keychain* or *Local Items*, depending on whether the user has enabled iCloud Keychain". It is one store with two labels.
  - Quinn: set `kSecAttrSynchronizable` "if you want the item to synchronise via iCloud (if the user has enabled iCloud Keychain)". [Thread 676891](https://developer.apple.com/forums/thread/676891)
  - Platform Security: every item that will sync must be explicitly marked `kSecAttrSynchronizable`.
- **[Obs] plus [Doc] context: medium.**
- Which account it later syncs into: presumably whichever account turns iCloud Keychain on for that device. **[Inf] low-medium.**

**(b) Signing out of iCloud.**
- **Mac:** "If you want to keep a copy of your iCloud data on your Mac before you sign out, make sure that you select the appropriate checkboxes. Then click Keep a Copy." Also: "Your iCloud data will be removed from your device unless you choose to keep a copy of that data when prompted."
- **iPhone:** "Choose Erase this [Device] or Sign Out But Don't Erase … Follow the onscreen prompts to learn what information will remain on your device or be erased."
- Source: [Sign out of iCloud](https://support.apple.com/en-us/104958) (Sept 14 2026).
- **Keychain specifically:** "When you sign out of iCloud on your device while iCloud Keychain is turned on, you're asked to keep or delete your Keychain information. If you choose to keep the information, your passwords and passkeys are stored locally on your device, but aren't deleted or updated when you make changes on other devices. If you don't keep the information, your passwords and passkeys aren't available on your device. An encrypted copy of your Keychain data is kept on iCloud servers. If you turn iCloud Keychain back on, your passwords and passkeys will sync to your device again." [Set up iCloud Keychain](https://support.apple.com/en-us/109016) (Oct 1 2026)
- **Turning iCloud Keychain off without signing out:** "password, passkey, and credit card information is stored locally on your device." (same article)
- **[Doc] high** for the user-facing flow. **Medium** that a third-party app's synchronizable generic passwords follow it: Apple's text only says "passwords and passkeys" and "Keychain information".
- Observed: OS updates have silently re-enabled iCloud Keychain (macOS 13.6.7 and 14.5, iOS 17; reported 2024). Turning sync off left the cloud copy in place. **[Obs] medium.** [Michael Tsai](https://mjtsai.com/blog/2024/05/21/apple-updates-silently-enable-icloud-keychain/); [lapcatsoftware 2024/10/4](https://lapcatsoftware.com/articles/2024/10/4.html)

**(c) Signing into a different Apple ID.**
- If the user kept a copy at sign-out, the old items stay on the device, frozen.
- **Unknown:** whether those kept synchronizable items upload into the new account's iCloud Keychain once it is enabled.
- If no copy was kept, the old items are absent until the original account syncs them back.

**(d) Detecting sync status or the Apple ID.**
- No public API reports whether iCloud Keychain sync is on, or which Apple ID it belongs to. None appears in the docs or SDK headers I read.
- Proxies only:
  - `FileManager.ubiquityIdentityToken`: "An opaque token that represents the current user's iCloud Drive Documents identity". It is nil when iCloud is unavailable and changes when the account changes, alongside `NSUbiquityIdentityDidChange`.
  - CloudKit `accountStatus` and `fetchUserRecordID`, which need the CloudKit capability.
  - Neither says anything about the keychain.
- **[Doc] medium-high.** [ubiquityIdentityToken](https://developer.apple.com/documentation/foundation/filemanager/ubiquityidentitytoken); [CKContainer.accountStatus](https://developer.apple.com/documentation/cloudkit/ckcontainer/accountstatus(completionhandler:))

**(e) How fast a new item reaches another device.**
- No bound is documented. Platform Security: devices "exchange individual keychain items through CloudKit, or iCloud key-value storage … If both circle members have updates to the same item, one or the other is chosen, resulting in eventual consistency."
- **[Doc] high** that there is no bound. [Platform Security: Secure keychain syncing](https://support.apple.com/guide/security/secure-keychain-syncing-sec0a319b35f/web) (May 2024)

**Also documented:**
- "Updating or deleting items using the kSecAttrSynchronizable key affects all copies of the item, not just the one on your local device."
- Since iOS 14 and macOS 11 the keychain syncs passwords, certificates and keys.
- Don't use persistent references to synchronizable items.
- **[Doc] high.** [kSecAttrSynchronizable](https://developer.apple.com/documentation/security/ksecattrsynchronizable)

## 7. Who can recover iCloud Keychain contents

1. **iCloud Keychain is end-to-end encrypted whether or not Advanced Data Protection (ADP) is on.**
   - "15 data categories — including Health and passwords in iCloud Keychain — are end-to-end encrypted. Apple doesn't have the encryption keys for these categories, and we can't help you recover this data if you lose access to your account." [iCloud data security overview](https://support.apple.com/en-us/102651)
   - Turning ADP off uploads service keys again, but "This never includes keys for services that are end-to-end encrypted under standard data protection, such as iCloud Keychain and Health." [Platform Security: ADP](https://support.apple.com/guide/security/advanced-data-protection-for-icloud-sec973254c5f/web)
   - **[Doc] high.**
2. **Who can obtain the contents.** **[Doc] high.**
   - **Every trusted device** in the account's syncing circle.
   - **A new device**, after Apple Account sign-in with two-factor authentication. Either an existing device approves it, or the user enters "the login password or passcode of a device that already has iCloud Keychain set up". [Mac User Guide](https://support.apple.com/guide/mac-help/mh43699/mac)
   - **Escrow recovery.** It needs the Apple Account and password, a reply to an SMS sent to the registered number, then the iCloud security code. For two-factor accounts, "the device passcode is used to recover an escrowed keychain".
     - The HSMs allow 10 attempts. After the 10th, "the HSM cluster destroys the escrow record and the keychain is lost forever".
     - Sources: [Platform Security: Secure iCloud Keychain recovery](https://support.apple.com/guide/security/secure-icloud-keychain-recovery-secdeb202947/web); [Escrow security for iCloud Keychain](https://support.apple.com/guide/security/escrow-security-for-icloud-keychain-sec3e341e75d/web)
   - **Account recovery contacts** (up to five). They help recover "their Apple Account and data, including all of their end-to-end encrypted data, whether or not they have turned on Advanced Data Protection."
     - Safeguards include a liveness check. If the account is in active use, recovery through a contact also requires an iCloud Security Code.
     - Source: [Platform Security: Account recovery contact security](https://support.apple.com/guide/security/secafa525057/web)
   - **A recovery key.** "using your device passcode or password, recovery contact, or recovery key" (support article 102651).
   - **Not legacy contacts:** their keys don't "encompass the information necessary to decrypt the decedent's iCloud Keychain." [Legacy Contact security](https://support.apple.com/guide/security/secebf027fb8/web)
   - **Not Apple.**
3. **The cloud copy can be destroyed.** **[Doc] high.** [Support 101345](https://support.apple.com/en-us/101345) (Dec 2025); support 109016.
   - "If you enter the wrong iCloud Security Code too many times … your keychain in iCloud is deleted."
   - "Reset iCloud Keychain to replace your keychain in iCloud with the iCloud Keychain from your device."
   - "If you're unable to approve, reset your end-to-end encrypted data when prompted."

## 8. Secure Enclave alternative: wrapping L under an SE key

1. **The approach is supported.**
   - SE keys "Works only with NIST P-256 elliptic curve keys. These keys can only be used for creating and verifying cryptographic signatures, or for elliptic curve Diffie-Hellman key exchange (and by extension, symmetric encryption)."
   - "you can use the key for encryption … using the kSecKeyAlgorithmECIESEncryptionCofactorX963SHA256AESGCM algorithm."
   - `privateKeyUsage` can be combined with biometry flags.
   - Hardware: A7 or later, a Mac with Touch Bar and Touch ID, or Apple silicon.
   - **[Doc] high.** [Protecting keys with the Secure Enclave](https://developer.apple.com/documentation/security/protecting-keys-with-the-secure-enclave)
2. **Use the variable-IV ECIES algorithm, and note its key size.**
   - `SecKey.h` labels the fixed-IV ECIES variants "Legacy … use kSecKeyAlgorithmECIESEncryptionCofactorVariableIVX963SHA256AESGCM in new code".
   - For that algorithm, "AES Key size is 128bit for EC keys <=256bit". **So a P-256 ECIES wrap is AES-128-GCM.**
   - The `LAPrivateKey` header gives `…StandardVariableIVX963SHA256AESGCM` as its example decrypt algorithm.
   - Production SDKs use the variable-IV algorithm with SE keys, for example [Ping Identity SecuredKey](https://developer.pingidentity.com/reference/sdks/ios/api-reference/FRCore/Structs/SecuredKey.html).
   - **[Doc] high; [Obs] medium.**
3. **Quinn gave this exact pattern.** Generate an SE EC key, "Use SecKeyCreateEncryptedData to encrypt the RSA key with the EC key", then "Store that in the keychain as kSecClassGenericPassword." **[DTS] high.** Thread 682480.
4. **The wrapped key can live in a file.**
   - SE-protected keys are "stored in the standard keychain database … the key is wrapped in such a way that only the SE can use it" (Quinn, thread 724013).
   - CryptoKit: "the data isn't the raw key. Instead, the Secure Enclave exports an encrypted block that only the same Secure Enclave can later use to restore the key." [Storing CryptoKit Keys in the Keychain](https://developer.apple.com/documentation/cryptokit/storing-cryptokit-keys-in-the-keychain)
   - So `SecureEnclave.P256.KeyAgreement.PrivateKey.dataRepresentation` can sit in a file beside the wrapped L. Its access control, for example `[.privateKeyUsage, .biometryCurrentSet]`, is enforced each time the key is used.
   - CryptoKit's default `accessControl` is `AfterFirstUnlockThisDeviceOnly` with no flags.
   - macOS / iOS 26 also add `SecureEnclave.MLKEM768`/`MLKEM1024` (with `decapsulate`) and ML-DSA keys.
   - **[Doc] high.** SDK CryptoKit `.swiftinterface`
5. **Lifecycle:**
   - A biometry change makes it unusable, by the same flag semantics as for items.
   - Erase: Quinn says "If you erase the device then the key material needed to use the key is erased and so the key becomes permanently useless", and "Erasing the device does result in a 'new' SE."
   - A new Mac has a different SE, so the key is unusable there.
   - A Time Machine restore brings the blob back, but no SE can use it after an erase or on another Mac.
   - **[DTS] and [Doc] high.**
6. **With the lid closed it can't unwrap until biometry is usable again.** A private-key operation needs the ACL satisfied, so with `.biometryCurrentSet` alone, unwrapping waits for an open lid or a paired Touch ID keyboard.
   - The documented fallbacks are `.or` with `.devicePasscode` (the Mac login password) or `.companion` (Apple Watch, macOS 15+).
   - Either fallback lets whoever holds that factor unwrap too.
   - **[Doc] semantics, high.** SDK `SecAccessControl.h`
7. **Entitlements:** "Using the Secure Enclave requires that your app have a registered App ID, which means it must be signed with this entitlement [`com.apple.application-identifier`] and that entitlement must be authorised by a provisioning profile."
   - Without a profile the call fails with -34018 (`errSecMissingEntitlement`), which is why bare command-line tools fail.
   - The App Sandbox itself is not a barrier.
   - **[DTS] high.** [Thread 728150](https://developer.apple.com/forums/thread/728150) (2023)
8. **One prompt for several operations.** Fetch the key, or build the CryptoKit key with `init(dataRepresentation:authenticationContext:)`, using an `LAContext` that is already authenticated. Quinn: "This context gets authenticated the first time you use it, and subsequent uses can reuse that authentication." The developer confirmed it worked. **[DTS] and [Obs] medium-high.** [Thread 655966](https://developer.apple.com/forums/thread/655966)
9. **Alternative: `LARightStore` and `LAPersistedRight`** (macOS 13+ / iOS 16+).
   - "The system stores your secret in the keychain and protects it with a unique key in the Secure Enclave. The system associates the key with your right and with an access control list…"
   - `biometryCurrentSetRequirement` fails on "a change in the enrollment database".
   - Backup and migration behavior is undocumented.
   - **[Doc] medium** for this use. [LARightStore](https://developer.apple.com/documentation/localauthentication/larightstore); [LAPersistedRight](https://developer.apple.com/documentation/localauthentication/lapersistedright); WWDC22 session 10108.

## 9. Debug vs Release builds, and shared access groups

1. **Keychain visibility depends on entitlements, not on the build configuration or certificate type.**
   - An app's access-group list is its `keychain-access-groups`, then the app ID (team ID plus bundle ID), then its app groups.
   - "The system considers the first item in the list of access groups to be the app's default access group."
   - **[Doc] high.** "Sharing access to keychain items among a collection of apps"
2. **Two builds see the same items only when they share an access group.**
   - Same team and same app ID (or a shared listed group): Debug and Release see the same items.
   - Different bundle IDs give different default groups, so the builds are isolated unless both list a common group and the items live in it.
   - Quinn: "If the two versions of your app have different entitlements, one version may not be able to 'see' items created by the other." Check `codesign -d --entitlements -` on the built product.
   - **[Doc] and [DTS] high.**
3. **On macOS the entitlement must be backed by a provisioning profile.** Ad-hoc or "Sign to Run Locally" builds can't use the DP keychain, and fail with -34018. **[Doc] and [DTS] high.**
4. **Two apps can share an access group.**
   - Both must come from the same team and list the group, and write with `kSecAttrAccessGroup` (or list it first so it is the default).
   - For synced items: "the kSecAttrAccessGroup key must be specified, and each application using this password must have the keychain-access-groups enabled, and a common access group specified."
   - **[Doc] high.**
5. **No documented Debug/Release difference beyond entitlements.** **[Absence] medium.**

## 10. Synchronizable items that carry an access control

1. **Documented restrictions:**
   - Synchronizable items may not use a ThisDeviceOnly class.
   - They cannot use file-keychain `SecAccess` (`kSecAttrAccess`).
   - **[Doc] high.** `kSecAttrSynchronizable` docs; `SecItem.h`
2. **Synchronizable plus `SecAccessControl` (`kSecAttrAccessControl`) is not addressed in public docs.** The evidence that it fails:
   - **Apple's own test:** a Security-framework regression test, [`secd-81-item-acl-stress.m`](https://github.com/apple-oss-distributions/Security/blob/main/keychain/securityd/Regressions/secd-81-item-acl-stress.m), adds an item carrying an ACL with operation constraints.
     - With `kSecAttrSynchronizable = false` the add succeeds ("add local").
     - With `kSecAttrSynchronizable = true` the test expects `errSecParam` (-50) ("add sync").
     - The test is compiled out (`SKIP_ITEM_ACL_STRESS_TESTS 1`).
   - **Developer reports** show -50 when combining the two.
   - **Platform Security:** ACLs "are evaluated inside the Secure Enclave", which is device-local.
   - **Treat the combination as unsupported:** a synced item can't be biometry-gated. Verify on the target OS if it matters.
   - **[Apple source] and [Obs] medium.**

## 11. LAContext reuse

1. **Without a context, every read prompts; with an authenticated context, later reads don't.** The `SecItem.h` comment for `kSecUseAuthenticationContext`:
   - "If the item requires authentication and this key is omitted, a new context will be created just for the purpose of the single call."
   - "If the specified context has been previously authenticated, the operation will succeed without asking user for authentication."
   - So without a context, each read of a `.biometryCurrentSet` item prompts again. With one evaluated context, several reads (or SE-key operations) succeed on one prompt.
   - **[Doc] high.**
2. **`touchIDAuthenticationAllowableReuseDuration` only reuses a recent lock-screen unlock.** The header text:
   - "Time interval for accepting a successful Touch ID or Face ID device unlock (on the lock screen) from the past."
   - "This property is meant only for reusing biometric matches from the device lock screen. It does not allow reusing previous biometric matches in application or between applications."
   - The maximum is 5 minutes and the default is 0.
   - **[Doc] high.** SDK `LAContext.h`; [Accessing keychain items with Face ID or Touch ID](https://developer.apple.com/documentation/localauthentication/accessing-keychain-items-with-face-id-or-touch-id)
3. **An authenticated context has no documented expiry.** It ends on `invalidate()` or when deallocated.
   - `canEvaluatePolicy` results are "guaranteed to stay valid until the application enters background".
   - Setting `interactionNotAllowed` makes keychain calls fail with `errSecInteractionNotAllowed` instead of showing UI.
   - **[Doc] high** for the stated parts; **Unknown** whether some unstated expiry exists.
4. **macOS-specific reuse behavior** different from the above: **none found.**

## 12. What a person with the Mac login password can do

The question: can they view, reveal or delete (a) a DP-keychain generic password that is `WhenUnlockedThisDeviceOnly` with no ACL, and (b) a synchronizable `AfterFirstUnlock` generic password in the app's team group?

1. **Keychain Access can reach every access group.**
   - On macOS 27.0, `codesign` shows `/System/Library/CoreServices/Applications/Keychain Access.app` with `keychain-access-groups = ["com.apple.keychainaccess", "*"]` (a wildcard) and `com.apple.authorization.extract-password`.
   - So it can read DP-keychain items in **every** access group, third-party team groups included.
   - **[Obs] high** for 27.0. **Not inspected on 14–26**; presumed similar.
2. **It displays password items from the DP keychain.**
   - TN3137: "Keychain Access displays all keychain items in file-based keychains but only password items in the data protection keychain." It shows that keychain as "iCloud Keychain" or "Local Items".
   - Generic and internet passwords are password items, so both (a) (Local Items or iCloud) and (b) (iCloud) should be listed.
   - Supporting observations: Keychain Access showed an item in another group (`com.apple.ssh.passphrases`) with its access group visible (thread 676891). A Catalyst app's items were left "in Local Items keychain" (thread 697215).
   - **[Doc] and [Obs] medium-high.**
3. **It can very likely reveal them.** Apple: "If you want to see the password for an item, select 'Show password,' then enter the password for the keychain that contains that item." For Local Items and iCloud, that is the login password.
   - So **a login-password holder can very likely reveal both (a) and (b).** Untested here.
   - How a raw 32-byte non-UTF-8 value displays or copies is unverified, and in any case it's not a protection.
   - **[Doc] and [Inf] medium-high.** [View the information stored in a keychain](https://support.apple.com/guide/keychain-access/kyca1085/mac)
4. **Castle-style items are different.** An item with a biometric `SecAccessControl` is evaluated in the Secure Enclave, so the login password alone shouldn't reveal it. **[Doc] and [Inf] medium-high.**
5. **The `security` command-line tool can't read DP items.** `/usr/bin/security` has no `keychain-access-groups` entitlement (inspected). TN3137 says its keychain support "is primarily focused on the file-based keychain". Its `find-generic-password` searches the file-keychain search list. **[Doc] and [Obs] high.**
6. **The Passwords app (macOS 15+) doesn't show third-party app items.** Its `keychain-access-groups` lists only Apple groups (`com.apple.cfnetwork`, `com.apple.password-manager`, `com.apple.webkit.webauthn`, and so on), with no wildcard. **[Obs] high** for 27.0.
7. **Deletion:**
   - Keychain Access can presumably delete what it lists. Untested: **[Inf] medium.**
   - Deleting a synchronizable item "affects all copies of the item, not just the one on your local device". **[Doc] high.**
8. **There is no "Recently Deleted" recovery for app items.**
   - The Passwords app's recovery is documented for passwords and passkeys: "you have 30 days to recover it … The password or passkey is returned to your Mac and iCloud Keychain." [Recover a recently deleted password](https://support.apple.com/guide/passwords/mchlee73013a/mac)
   - It is implemented with dedicated `…-recently-deleted` access groups that exist only for Apple's own groups, per the entitlement list.
   - **No documented recovery exists for app-created generic passwords** removed by `SecItemDelete` or Keychain Access. **[Doc] and [Obs] medium-high.**
9. **`kSecAttrIsInvisible` is a display hint, not a control.** The header says the item "should not be displayed". It is not access control, and whether Keychain Access honors it for DP items is untested. **[Doc] high** for what it is; **Unknown** in practice.
10. **iOS has no Keychain Access equivalent**, and the Passwords app doesn't list third-party generic passwords. **[Inf] medium-high.**

---

## Open unknowns worth a short test (dev store, held stage claim)

- Whether Keychain Access lists and reveals the app's own Standard L (Local Items) and iCloud key A, and how a 32-byte binary secret renders. §12.
- On macOS, the read result for an invalidated `.biometryCurrentSet` item after adding a finger, and whether the row persists. §4.
- Whether a `WhenUnlocked` DP item is readable while the logged-in Mac's screen is locked. §1.
- What a Time Machine restore and Migration Assistant actually do to Local Items on macOS 26/27, on the same Mac and on a new one. §3.
- The `canEvaluatePolicy` error and `LAEnvironment` values in clamshell mode, and on a desktop Mac with no paired keyboard. §5.
- What happens to kept synchronizable items after signing into a different Apple ID. §6c.

## Implications for a key-custody design

1. On any Mac where the items are present, the Mac login password is likely enough to read the raw Standard L and the synced iCloud key A, using Apple's Keychain Access (wildcard access group). Only SE-evaluated biometric items resist.
2. Anyone who can add a device to the user's iCloud Keychain can obtain A. That takes the Apple Account plus 2FA and any one trusted device's passcode or login password, or escrow recovery, or a recovery contact or recovery key. Apple cannot, and E2EE holds with or without ADP.
3. The iCloud copy of A can disappear without the app noticing: "Reset iCloud Keychain", too many wrong security-code attempts, a reset of end-to-end encrypted data, or a delete on any one device. Deletes propagate and there is no Recently Deleted for app items.
4. Sync state is invisible and unstable. There is no API for "is iCloud Keychain on" or "which Apple ID". OS updates have re-enabled sync silently, and sign-out may remove the local synced copy at the user's choice. Posture decisions can't rest on the presence of A.
5. ThisDeviceOnly means "never synced", not "never leaves". iOS Quick Start has been seen to carry such items; iOS backups restore them to the same erased device; Mac Time Machine and Migration Assistant handling of Local Items is undocumented and reportedly lossy.
6. A `.biometryCurrentSet` item dies on any enrollment change, including add-then-remove, and the read errors are ambiguous (`errSecItemNotFound` vs `errSecAuthFailed`, where the latter is also transient). The Touch ID copy must be a rebuildable cache: delete the stale row first, and always keep a passphrase or recovery fallback.
7. On macOS 15+, use `LAEnvironment` (`builtInSensorInaccessible`, `isUsable`, `isLockedOut`, `biometryNotPaired`/`biometryDisconnected`) to tell "open the lid / reconnect the keyboard" apart from "the Touch ID copy is gone". The lid-closed state doesn't invalidate items.
8. The biometric `stateHash` is per-app, needs a successful biometric preflight or evaluation first, and can change across major OS upgrades with no enrollment change. Treat a changed hash as a hint, never a verdict.
9. A Secure Enclave wrap works for Castle's Touch ID copy. A CryptoKit SE P-256 (or ML-KEM) key with `[.privateKeyUsage, .biometryCurrentSet]` can unwrap L from a file blob. The blob is useless after an erase, on a new Mac, or after an enrollment change, which matches Castle semantics. It needs a provisioning-profile-signed app, and P-256 ECIES gives AES-128-GCM.
10. A synced item can't carry a biometric or other `SecAccessControl` (`errSecParam` in Apple's own test). A synced copy is therefore protected only by the iCloud Keychain trust circle, plus the device login once it has landed on a Mac.
11. Keychain items outlive app deletion on both platforms (an implementation detail on iOS). A reinstall can find stale L/A items, so their presence must not be read as proof of the current posture.
12. Debug and Release builds share items only through a common access group. Access is purely entitlement-based (default group = first `keychain-access-groups` entry, else the app ID), and on macOS needs a provisioning profile.
