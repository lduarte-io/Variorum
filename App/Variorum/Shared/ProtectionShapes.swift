//
//  ProtectionShapes.swift
//  Variorum (shared: Mac + Mobile — ONE brain; the faces render, never
//  re-derive)
//
//  pre-13u Act 10 wave 2a — **the security-shapes model as copy**, built
//  from `notes/plans/pre-13u-memo-security-shapes.md` (R-pre13u-7: the
//  memo is the BINDING record; where anything differs, the memo wins).
//  The §9c item-3 discipline governs this file: the keystone lines —
//  key-not-backup · the sync sentence · Touch-ID-guards-this-device ·
//  "passphrase is still the path" — land ESSENTIALLY VERBATIM from the
//  memo, because almost-true paraphrase is how the original confusion got
//  built. The presentation format is the memo §3's: RECIPES + short
//  paragraphs, NO grand matrix — the three-row shapes summary below is
//  the ONLY table anywhere.
//
//  Seventh-wave truths carried in (R-pre13u-7(a)): the TWO new-device
//  rows are different mechanisms; the demanded-mode fallback is stated
//  truthfully; ONE passphrase ever; key-family internals never surface
//  (user copy speaks of the passphrase and what it opens).
//
//  Placeholder voice, honest content — 13s re-voices; her copy rider
//  stands (she rewrites copy later; capabilities stay).
//

import Foundation

nonisolated enum ProtectionShapes {
    // MARK: - The keystone lines (memo §§1–5 — essentially verbatim)

    /// THE ONE LAW (memo §1) — everything else derives from it.
    static let oneLaw =
        "Your passphrase protects the server's copy of your writing. A readable "
        + "copy in someone's hands is already access — no passphrase can "
        + "retroactively guard a copy that opens. An enrolled device is a "
        + "pre-assembled recipe: copy + key + sync custody, kept live. A copy "
        + "of your library on its own is only ingredients."

    /// The Touch ID keystone (memo §2, from her sharpest question). On the
    /// Mac this is byte-close to the memo's line; the phone reads its own
    /// gate word through the standing interpolation.
    static let deviceAsPowerfulAsPassphrase =
        "An unlocked, enrolled device is as powerful as your passphrase. "
        + "\(ProtectionCopy.biometryName) guards this device — your passphrase "
        + "is what lets a new device in."

    /// The ratified sync/tier sentence (memo §5.3) — VERBATIM.
    static let syncSentence =
        "Sync brings your writing back to any device — as long as you keep your "
        + "passphrase or recovery phrase. We can never reset it for you: that's "
        + "what end-to-end means."

    /// Key-not-backup + the ninth wave's ultra-clear corollary (memo §1):
    /// the spare key is never a remote sync key.
    static let spareKeyIsAKey =
        "The iCloud spare key is a key — never a backup, never the passphrase. "
        + "It opens copies you already have, nothing more: it can never pull "
        + "your writing from the server."

    /// The re-entry rule, hers (memo §1 close): "passphrase is still the
    /// path."
    static let resetRoad =
        "You never get anything from the server without a passphrase. Holding a "
        + "copy of your library and signed into your account, Replace Encryption "
        + "Keys lets you choose a NEW passphrase — your copy becomes the truth, "
        + "and sync resumes under the new one. Passphrase is still the path; the "
        + "reset road just lets you mint a new one from what you hold."

    /// The compound warning (memo §3 — ships in copy, a read sentence).
    static let compoundWarning =
        "One thing to know whole: backups in iCloud Drive plus the spare key on "
        + "means your Apple account is everything — anyone fully in your iCloud "
        + "can open your writing, and with an iCloud address as your account "
        + "email, reach sync too. For someone who wants Apple to hold it all, "
        + "that is the feature; for everyone else it is worth one read."

    // MARK: - The recipes (memo §3 — the user-facing format)

    static let openRecipesTitle = "Open your writing — any ONE of these suffices"
    static let openRecipes: [String] = [
        "an enrolled device, through its own gate",
        "any copy of your library + your passphrase",
        "any copy of your library + your recovery phrase",
        "any copy of your library + the iCloud spare key, on a "
            + "\(ProtectionCopy.deviceName) signed into your iCloud",
    ]

    static let opensNothingAloneTitle = "Opens nothing alone"
    static let opensNothingAlone: [String] = [
        "your iCloud password by itself — a key with nothing to unlock",
        "your computer password, under an asking mode",
        "a backup drive — ciphertext without a key",
        "us: the server never holds a key to anything",
    ]

    /// Seventh wave (i): the TWO new-device rows, split — different
    /// mechanisms, deliberately never conflated.
    static let newDeviceAdoptCopy =
        "Adopting a COPY of your library (AirDrop, a restored backup folder): "
        + "the iCloud spare key can open it — no Variorum secret needed."
    static let newDeviceSyncEnroll =
        "A new, empty device pulling your writing via SYNC: that takes your "
        + "encryption passphrase, once. The iCloud spare deliberately does not "
        + "substitute here — the server must never be able to hand keys around. "
        + "It is the same passphrase as everywhere; there is only ever one."

    /// Seventh wave (ii): the demanded-mode fallback, stated truthfully.
    static let demandedFallbackTruth =
        "At this device's lock under \(ProtectionCopy.biometryName), the "
        + "fallbacks are your passphrase and your recovery phrase. Variorum "
        + "never silently opens via the iCloud copy on a device whose mode "
        + "asks — that would be a lock with a hole in it."

    // MARK: - The three-row shapes summary (memo §4 — the ONLY table)

    struct ShapeRow: Equatable, Sendable {
        let name: String
        let dials: String
        let stops: String
        let doesNotStop: String
        /// The two what-ifs (memo §6) — under EVERY shape.
        let whatIfForget: String
        let whatIfComputerDies: String
        /// false = named but not offered (Shape 3 — deferred, her ruling).
        let offered: Bool
    }

    static let shapes: [ShapeRow] = [
        ShapeRow(
            name: "You hold the keys",
            dials: "asks at open · no iCloud spare · passphrase + recovery "
                + "phrase set",
            stops: "the server (us) · anyone in your iCloud · someone at your "
                + "unlocked computer",
            doesNotStop: "someone holding your secrets — or you forgetting "
                + "both, which is the flip side of maximum security, said "
                + "plainly",
            whatIfForget: "While this device still opens, set a new passphrase "
                + "now — that is why the change door stays open. Both secrets "
                + "gone AND the device gone: gone forever, everywhere — the "
                + "deal this shape chooses.",
            whatIfComputerDies: "Sync brings everything back — sign in "
                + "anywhere + your passphrase or recovery phrase. Without "
                + "sync: any backup copy + either secret.",
            offered: true),
        ShapeRow(
            name: "This device + a spare key in iCloud (the default)",
            dials: "opens silently · spare key in iCloud Keychain",
            stops: "the server (us) · an iCloud phisher — they get a key with "
                + "nothing to open (conditionally: see the compound warning)",
            doesNotStop: "someone at your unlocked "
                + "\(ProtectionCopy.deviceName) — while it's open, someone at "
                + "your computer can read it; that's what open means",
            whatIfForget: "Nothing changes day to day — this device opens "
                + "silently, and the iCloud spare can open a copy on a new "
                + "device signed into your iCloud.",
            whatIfComputerDies: "A copy of your library + the iCloud spare "
                + "key opens it on a new device — or sync + your passphrase, "
                + "if sync is on.",
            offered: true),
        ShapeRow(
            name: "iCloud holds everything",
            dials: "not offered — deliberately",
            stops: "—",
            doesNotStop: "—",
            whatIfForget: "Not built. The roundabout already exists: backups "
                + "in iCloud Drive + the spare key is the everything-in-"
                + "Apple's-hands recovery, without pretending to be a "
                + "separate mode.",
            whatIfComputerDies: "See the roundabout above.",
            offered: false),
    ]

    // MARK: - What YOU need, by mode (memo §5 — the four real states)

    struct NeedState: Equatable, Sendable {
        let name: String
        let daily: String
        let computerDies: String
        let floor: String
    }

    static let needStates: [NeedState] = [
        NeedState(
            name: "Just writing (opens silently, nothing set up)",
            daily: "Nothing.",
            computerDies: "A copy of your library + your iCloud Keychain.",
            floor: "With neither, the writing is gone — which is normal for "
                + "un-backed-up local software. Automatic backups guard "
                + "against corruption and mistakes; a backup on the same "
                + "machine dies with the machine."),
        NeedState(
            name: "Opens silently, with a secret set",
            daily: "Nothing.",
            computerDies: "Any copy of your library + any one of your keys — "
                + "passphrase, recovery phrase, or the iCloud spare.",
            floor: "A long chain, on purpose: every leg has to go wrong at "
                + "once."),
        NeedState(
            name: "Sync on",
            daily: "Nothing beyond your at-open gate.",
            computerDies: "Nothing is lost — sign in anywhere + your "
                + "passphrase (or the twelve words) and everything comes "
                + "back, current.",
            floor: "What sync can never survive: losing every device AND "
                + "both secrets — the server's copy is then sealed forever. "
                + syncSentence),
        NeedState(
            name: "Asks at open (\(ProtectionCopy.biometryName) or passphrase)",
            daily: "This device's \(ProtectionCopy.biometryName) or your "
                + "passphrase — never iCloud, never the computer password.",
            computerDies: "Sync + your passphrase, or a copy + either secret.",
            floor: "Both secrets forgotten while this device still opens: set "
                + "a new passphrase NOW — that door stays open on purpose. "
                + "Both gone and the device gone: gone forever, everywhere — "
                + "the deal this shape chooses."),
    ]

    /// The CURRENT state's row, for the pane (the explainer renders all
    /// four; the pane leads with yours).
    static func currentNeedState(
        mode: StoreAtOpenMode, hasAnySecret: Bool, syncOn: Bool
    ) -> NeedState {
        if mode.isDemanded { return needStates[3] }
        if syncOn { return needStates[2] }
        return hasAnySecret ? needStates[1] : needStates[0]
    }

    // MARK: - T2: the three-value tier, three sentences (the rendering half)

    /// "Can't tell" is never dressed as comfort or alarm — its own gentle
    /// sentence (memo §9b T2; the verification half rides 13r's
    /// fresh-machine walk).
    static func tierSentence(_ tier: ProtectionLegs.Tier) -> String {
        switch tier {
        case .covered:
            return "At least one real way back in exists beyond this device."
        case .exposed:
            return ProtectionCopy.exposedNudgeHeadline
                + " Two minutes fixes that — set a passphrase, or take the "
                + "recovery phrase."
        case .unknown:
            return "Whether a spare way in exists can't be told right now — "
                + "this library's key file exists but can't be read. That is a "
                + "fact about this check, not about your writing: whatever "
                + "opened the library still does."
        }
    }

    /// The Apple-key LEG's own three-value truth (T2 applied per-leg —
    /// pre-13x 2a, re-based from the escrow item onto the iCloud key A): a
    /// verified copy, a copy that is verifiably not landing, and a copy
    /// this launch simply hasn't checked yet.
    static func escrowLegSentence(_ verified: Bool?) -> String {
        switch verified {
        case true: return "verified this launch — the iCloud key opens the key file's copy"
        case false: return "not landing — no copy verifiably opens with the iCloud key"
        case nil: return "not checked yet this launch"
        }
    }

    // MARK: - The live "ways back in" checklist (item 3's centerpiece —
    // the actual legs THIS device/account has right now, truthfully)

    struct ChecklistRow: Equatable, Sendable {
        let name: String
        /// nil = UNKNOWN (T2's three-value truth — never dressed as
        /// present or absent).
        let present: Bool?
        let note: String
    }

    /// ONE brain for both platforms' checklists (the waysBackInLine's
    /// grown-up form; R-pre13u-4's "counting the actual legs"). Under
    /// `factsUnknown` the caller renders `tierSentence(.unknown)` instead
    /// of claiming wrap rows it cannot read — only the device row (whose
    /// truth is the mode's, not the sidecar's) survives.
    static func checklistRows(
        _ legs: ProtectionLegs, mode: StoreAtOpenMode
    ) -> [ChecklistRow] {
        var rows: [ChecklistRow] = []
        switch mode {
        case .auto:
            rows.append(ChecklistRow(
                name: "This \(ProtectionCopy.deviceName)", present: true,
                note: "its Keychain opens the library silently"))
        case .biometric:
            rows.append(ChecklistRow(
                name: "This \(ProtectionCopy.deviceName)", present: true,
                note: "\(ProtectionCopy.biometryName) unlocks it — the "
                    + "computer password never does"))
        case .passphrase:
            rows.append(ChecklistRow(
                name: "This \(ProtectionCopy.deviceName)", present: false,
                note: "nothing here opens the library silently — that is "
                    + "this mode's point"))
        }
        guard !legs.factsUnknown else { return rows }
        rows.append(ChecklistRow(
            name: "Encryption passphrase", present: legs.hasPassphraseWrap,
            note: legs.hasPassphraseWrap
                ? "opens any copy, and lets a new device into sync"
                : "not set"))
        rows.append(ChecklistRow(
            name: "Recovery phrase", present: legs.hasRecoveryWrap,
            note: legs.hasRecoveryWrap
                ? "the twelve words — the passphrase's twin, on paper"
                : "not saved"))
        if mode.isDemanded {
            rows.append(ChecklistRow(
                name: "iCloud key", present: false,
                note: "no copy opens with it in Castle"))
        } else {
            rows.append(ChecklistRow(
                name: "iCloud key",
                present: legs.appleKeyVerified,
                note: escrowLegSentence(legs.appleKeyVerified)))
        }
        return rows
    }

    // MARK: - The unchosen-state indicator (memo §6)

    /// NEVER "encryption off" — the store is always encrypted (R13p-2).
    /// What is unchosen is the lock and the keys.
    static let unchosenIndicatorLabel = "Protection: not chosen yet"
    static let unchosenIndicatorDetail =
        "Your library is encrypted either way — what's unchosen is the lock "
        + "and the spare keys. Settings ▸ Protection is the choice."

    // MARK: - The two decision ceremonies (memo §6 — the lock moment ·
    // sync signup)

    /// The LOCK MOMENT: rendered where a demanded mode is being picked
    /// (the passphrase-set sheet) — the choice arrives when you reach for
    /// the lock.
    static let lockMomentFraming =
        "Asking at open is a real lock: your computer password can NOT open "
        + "Variorum, and the iCloud spare key isn't kept in this shape. Your "
        + "passphrase — and the twelve words beside it — become your ways "
        + "back in."

    /// SYNC SIGNUP: rendered on the encryption setup flow's first step —
    /// which path you are choosing, said before any secret is typed.
    static let syncSignupFraming =
        syncSentence + " " + deviceAsPowerfulAsPassphrase
}
