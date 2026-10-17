//
//  LifecycleFixture.swift
//  VariorumCoreTests — VX-378 U3: THE LIFECYCLE FIXTURE. The facts of
//  `notes/plans/vx-266/castle-lifecycle.html` (the walk-through of
//  `notes/CastleRules.md` — one person, one library, fourteen stages),
//  extracted into ONE machine-readable value BEFORE any test was written.
//
//  Two readers, one value:
//    - the lifecycle scenario (`LifecycleScenarioTests.swift`) walks the
//      fourteen stages through the executor's real acts and asserts at every
//      stage against THIS value — never against what the model itself says;
//    - the page renderer (`LifecyclePage.swift`) renders the page from THIS
//      value; the committed page is the rendered one.
//
//  What is a fact here, and what is prose: every road chip (what opens the live
//  library and each backup, typed — a secret you type, a quiet road, or gone),
//  every "what was written" sentence (`LFact`, each quoting the page words it
//  types), and each stage's posture are FACTS; the stage text, the chips'
//  words, the notes and the page frame are PROSE riding as data. A fact the
//  model cannot produce is a FACTS DIFF — recorded here with its id, marked on
//  the fact (`LStatus.diff`) and in `Lifecycle.factsDiff`, hers to accept —
//  never a silent edit of the fact itself.
//
//  The call (recorded in the plan's U3 RECORD): a Swift literal, not JSON — a
//  JSON file in the test target needs a resource declaration in Package.swift
//  (outside this unit's scope) or draws SwiftPM's unhandled-file warning, and
//  the compiler holds every road, fact and status to a known case, so a typo
//  can't quietly turn a fact into nothing.
//

import Foundation

@testable import VariorumCore

// MARK: - The vocabulary

/// Who a road opens: the live library, or a copy the page names.
enum LSubject: String, Sendable {
    /// The library in the live place (whichever library that is at the stage).
    case library
    /// Backup A — stage 3's, Standard era.
    case backupA
    /// Backup B — stage 7's, Castle era.
    case backupB
    /// Stage 10: the library someone AirDrops you.
    case theirs
    /// Stage 12: the backup the joining device made before it joined.
    case joinersBackup
}

/// Which secret a typed road types.
enum LSecret: String, Sendable {
    case passphrase
    case words
    /// "passphrase or words": the passphrase AND the words each open it, alone.
    case either
}

/// Whose secret, and the road it walks (rules 4, 5).
enum LDay: String, Sendable {
    /// Today's secret, by any key file this Mac holds for the target: the live
    /// key file (its current key or its history) or the copy's own key file.
    case today
    /// Today's secret, through the LIVE key file — its current key or its
    /// history (rule 4: "your current passphrase or words open every backup").
    case throughTheHistory
    /// The secret current the day the copy was made, on the copy's OWN key file
    /// (rule 5: "the secrets of its day").
    case itsDay
}

/// Which Apple key an Apple road names.
enum LAppleKey: String, Sendable {
    /// The Apple lock on the target's own key file (the live key file, for the
    /// library) — opens when an Apple key readable here unwraps it.
    case itsOwnLock
    /// The Apple key the live key file named when the stage began ("old Apple
    /// road").
    case beforeThisStage
}

/// A road into a library or a copy.
enum LRoad: Sendable {
    /// A secret you type.
    case typed(LSecret, LDay)
    /// The Apple road (rule 8): your iCloud Keychain.
    case apple(LAppleKey)
    /// The on-device road (rule 8): this Mac's login keychain — a silent item
    /// holding the target's key directly. The page calls the same road "login
    /// password" in Castle, where it is gone.
    case onDevice
    /// Touch ID: a Touch ID item holding the target's key directly, read by a
    /// press.
    case touchID
    /// Every quiet road at once (the Apple road, the on-device road, Touch ID)
    /// — and Look inside, with nothing typed, refuses (rule 4: "a quiet road
    /// opens only a key it directly holds").
    case quietRoads
}

enum LState: String, Sendable {
    /// The road opens the target.
    case opens
    /// "gone — a road that no longer opens anything".
    case gone
}

/// When a road is on this stage's road.
enum LCondition: String, Sendable {
    case always
    /// "(if chosen)": opens when Use Castle chose Touch ID; under Always ask the
    /// road does not exist ("no copy stays on the device").
    case touchIDChosen
}

/// The status of a fact on the scenario's road.
enum LStatus: Sendable {
    /// The scenario asserts it, at this stage.
    case asserted
    /// The scenario asserts it at a later stage of the same road (the stage
    /// number) — where the road first reaches it (a synced clause, say).
    case assertedAt(Int)
    /// Not on this road (an "or", an "if") — where it is proven instead.
    case branch(String)
    /// Not a protection-model fact — a face's, Apple's, the server's: its owner.
    case notAModelFact(String)
    /// A FACTS DIFF: the model produces `observed` instead (the scenario asserts
    /// that); `Lifecycle.factsDiff` carries the reason. Hers to accept.
    case diff(String, observed: LFact)
    /// A FACTS DIFF on one of stage 5's roads only; on the other the page's fact
    /// is asserted.
    case diffWhen(LStage5Event, String, observed: LFact)
    /// Asserted on one of stage 5's roads only — the page states it for that road
    /// (her FD-2 ruling: stage 6's Apple-ID-road sentence); on the other road the
    /// stage's other sentence holds.
    case onlyWhen(LStage5Event)
}

/// A road chip: the road, whether it opens, its words.
struct LChip: Sendable {
    var road: LRoad
    var state: LState
    /// The chip's words (prose).
    var label: String
    var condition: LCondition = .always
    /// The road is gone on EVERY device of hers, not only this Mac (the Apple
    /// deletion reaching her other Macs — rule 11).
    var everywhere = false
    /// A FACTS DIFF id, when the model produces the other state.
    var diff: String?
}

/// A lock in a key file.
enum LLock: String, Sendable {
    case passphrase
    case words
    case apple
    /// The account's master (with its twelve-words copy beside it).
    case master
}

/// A keychain item on this Mac holding a library key.
enum LItem: String, Sendable {
    /// The on-device road: a silent item.
    case onDevice
    /// A Touch ID item.
    case touchID
}

/// What the reminder of rule 3 keys on. (The page once said "if you skip
/// writing the words down"; her FD-1 ruling made it the passphrase — rule 3 —
/// and that case left with it: no model can know whether words were written.)
enum LReminderTrigger: String, Sendable {
    case noPassphraseYet
}

/// A secret typed at a copy's door.
enum LTyped: Sendable {
    /// Today's passphrase or words (the ones that open the live library now).
    case today(LSecret)
    /// The copy's day's passphrase or words.
    case itsDay(LSecret)
    /// The other person's own passphrase or words (stage 10).
    case theirs(LSecret)
}

/// What a stage wrote, or what is true after it — one page sentence, typed.
indirect enum LFact: Sendable {
    // The library's key and its key file (the live place).
    /// A new library key is made, of `kind`; the scenario names it `name`.
    case newKey(name: String, kind: ProtectionMode)
    /// The library's key does not change.
    case keyUnchanged
    /// The live key file's locks.
    case keyFileLocks(has: [LLock], lacks: [LLock])
    /// One lock re-made under a new secret; the key the same.
    case lockRelocked(LLock)
    /// Nothing else changes: every other lock, this Mac's items and the Apple
    /// keys exactly as before the stage.
    case nothingElseChanges(except: LLock)
    /// The live key file's history holds these named keys (rule 4).
    case historyCarries([String])
    // This Mac's keychain.
    /// Items on this Mac for the CURRENT key.
    case custody(has: [LItem], lacks: [LItem])
    /// A Touch ID item for the current key when Touch ID was chosen; under
    /// Always ask, no item of any kind for it.
    case touchIDItemIfChosen
    /// No on-device item on this Mac for any key the library has had.
    case noOnDeviceItemForAnyKeyItHasHad
    /// No Apple key that any of the library's key files ever named is readable
    /// on any device of hers (after iCloud Keychain syncs).
    case appleKeysDeletedEverywhere
    /// Every Apple key any of the library's key files ever named is DELETED:
    /// held by no Apple account's iCloud Keychain and by no device. (Added at
    /// piece C, before the scenario first ran: piece B typed only "die
    /// everywhere"; the sentence also says "deleted".)
    case appleKeysDeleted
    /// The live key file's Apple lock names an Apple key it never named before,
    /// readable here.
    case freshAppleRoad
    /// This Mac's keychain holds the sealed copy of the live key file.
    case sealedKeyFileCopy
    /// This Mac's device ID for the library: a plain random value made now.
    case newPlainRandomDeviceID
    /// The twelve words: shown once (handed back by the door), opening the key
    /// file, and stored nowhere.
    case wordsShownOnce
    // Copies.
    /// No backup exists yet.
    case noBackups
    /// The backup is the library plus the key file of this day (rule 5).
    case backupOfItsDay(LSubject)
    /// The copy's own key file still opens with the old secret, not the new.
    case ownKeyFileWantsTheOldSecret(LSubject, LSecret)
    /// The copy's own key file's locks; and no item on this Mac holds its key.
    case copyLocks(LSubject, has: [LLock], lacks: [LLock], noItem: Bool)
    // Reminders (rule 3).
    /// The passphrase ask `assess` owes now (nil: none).
    case passphraseAsk(PassphraseAsk?)
    /// What the reminder keys on.
    case reminderTrigger(LReminderTrigger)
    // The open.
    /// The next open opens the library with nothing typed (a quiet road).
    case nextOpenAsksNothing
    /// The next open asks for a secret at once: no quiet road remains.
    case nextOpenAsksAtOnce
    /// The quiet roads re-made by that open: the on-device item and a fresh
    /// Apple road for the current key.
    case quietRoadsRemade
    // Use Castle's extras.
    /// The scheduled plain-text export turned off, with exactly one notice.
    case scheduledExportOffWithOneNotice
    /// …and she may turn it back on (a setting, not a lock).
    case scheduledExportReversible
    // The copy doors (rule 17).
    /// Look inside `subject`: each `opensWith` opens it, each `refuses` doesn't,
    /// nothing typed opens it iff `quietRoad`; nothing is written.
    case lookInside(LSubject, opensWith: [LTyped], refuses: [LTyped], quietRoad: Bool)
    /// Make this my library from `subject`: a NEW library — a fresh identity,
    /// key and device ID, in the posture of now, locked under the current pair
    /// (and not under the copy's own secrets unless they are the same), with no
    /// account, its key CARRYING THE KEY HISTORY FORWARD (her ruling on
    /// P-VX378-U4-1, VX-378 U4: the copy's key and its key file's history, and
    /// the previous library's key and its history); the previous library aside
    /// whole (with its key file) in Previous Libraries; the copy untouched.
    case makeMine(LSubject)
    /// The copy's owner keeps theirs: their library and their account's vault
    /// exactly as before.
    case theirsUntouched
    // A new Mac (stage 11).
    /// The library file and its key file arrive unchanged.
    case filesMoveWithYou
    /// The section the new device ID names adopts nothing of the old one's.
    case nothingTakenOver
    // Sync (stage 12).
    /// Turning sync on hands the library's pair up: the account's vault opens
    /// with the library's passphrase and words; the key and its locks stay.
    case syncSetUpHandsThePairUp
    /// The joiner's key file now opens with the account's passphrase and words,
    /// not with its own old words; its key unchanged.
    case joinAdoptsTheAccountsPair
    /// The act's notices.
    case notices([ActNotice])
    /// The joiner's backup from before the join opens with its old words (its
    /// own key file) and with the account's secrets (same key).
    case oldWordsStillOpenOlderBackups
    /// One device enters Castle: the account's sync key replaced in ONE vault
    /// write, the old one kept in its list.
    case accountEntersCastleInOneWrite
    /// The device that hasn't followed: its own library opens through its own
    /// quiet road with nothing typed; it holds no key for rows written since;
    /// a follow is owed that types one secret.
    case laggingDeviceReadsOnlyWhatItHas
    /// It follows by typing one secret, and holds the new sync key.
    case followTypesOneSecret
    /// One device leaves Castle: the vault's mode flag flips, no key changes;
    /// the other device follows out with nothing typed, with a notice.
    case accountLeavesCastleOtherDevicesFollowQuietly
    /// Leaving the account: the key, its locks and the secrets exactly as they
    /// were; the record names no account; the server keeps the vault.
    case leavingTheAccountChangesNoKey
    /// Signing back in is a join, and the device then holds every sync key the
    /// account has had.
    case signingBackInIsAJoinThatReadsEverything
    // Crash safety (stage 13).
    /// A crash before the act's plan lands: the next open rolls back, says so.
    case crashBeforeThePlanRollsBack
    /// A crash after it: the next open finishes from the plan, says so.
    case crashAfterThePlanFinishes
    /// After either open the library still opens with nothing typed: no key was
    /// deleted before its replacement verified.
    case noKeyDeletedBeforeItsReplacement
    // Something wrong on disk (stage 14).
    /// What this Mac remembers is four things, and they match the live place.
    case fourThingsRemembered
    /// The live place isn't what this Mac remembers: the open refuses before
    /// any write, says what it found and offers the two doors.
    case refusesWhatItDoesntRemember(LStray)
    /// The live key file lost: the next open writes it back from the sealed
    /// copy in this Mac's keychain; every backup carries its own.
    case lostKeyFileComesBack
    /// Every key-file copy gone: the open says nothing is left on this Mac and
    /// names the account road; the twelve words open the account and every
    /// sync key it has had.
    case syncedLibraryRecoversWithTheWords
    /// A sentence this road does not type — its status says where it is proven
    /// or whose it is.
    case notTypedHere
    // (Added with the FACTS DIFF, as the facts the model produces instead.)
    /// Every one of these.
    case all([LFact])
    /// Use Castle's door names the copy as one under a key this Mac can't delete
    /// (its Apple lock's key sits in an Apple account this Mac has left), and
    /// this Mac records that key retired — deleted on sight if it ever comes
    /// back (the door words `copiesUnderAKeyThisMacCantDelete`; the repair
    /// `deleteRetiredAppleKey`).
    case useCastleNamesCopiesItCantDelete(LSubject)
    /// No Touch ID item on this Mac for any key the library has had.
    case noTouchIDItemForAnyKeyItHasHad
    // (Added with her FD-2 ruling — rule 25's sentence on the Apple-ID road.)
    /// The copy's own Apple lock names a key that still sits in an Apple account
    /// none of her devices is signed into: the copy keeps that lock, and the app
    /// cannot delete it (rule 25).
    case appleLockKeptInAnAccountSheLeft(LSubject)
}

/// What someone put in the live place (stage 14).
enum LStray: String, Sendable {
    case backupPairCopiedInByHand
    case replayedOldLibraryFile
    case swappedInFile
}

/// One fact, the page words it types, the rules it cites, its status.
struct LFactEntry: Sendable {
    var fact: LFact
    var quote: String
    var rules: [Int]
    var status: LStatus = .asserted
}

/// A row of the stage's definition list.
enum LRowContent: Sendable {
    /// Prose only.
    case text(String)
    /// Road chips for one subject (rendered from the facts).
    case chips(LSubject, [LChip])
    /// Prose the page shows, with the roads it states typed beside it (not
    /// rendered as chips).
    case textStating(String, LSubject, [LChip])
}

struct LRow: Sendable {
    var term: String
    var content: LRowContent
}

/// Roads the page implies but shows no row for — carried from an earlier
/// stage, or stated in a stage's words — asserted, never rendered.
struct LHiddenRoads: Sendable {
    var subject: LSubject
    var chips: [LChip]
    /// Why the page implies them.
    var source: String
}

enum LPosture: String, Sendable {
    case standard = "std"
    case castle = "cas"
    case any
}

/// The two "or"s the page offers before stage 6 — the scenario walks each.
enum LStage5Event: String, Sendable, CaseIterable {
    case appleIDChanged
    case iCloudKeychainReset
}

struct LStage: Sendable {
    var number: Int
    var title: String
    var posture: LPosture
    var postureLabel: String
    /// The road the scenario takes through this stage (rendered nowhere).
    var road: String
    var rows: [LRow]
    var note: String?
    var hidden: [LHiddenRoads] = []
    var facts: [LFactEntry] = []
}

/// A fact the model cannot produce, with its reason — hers to accept.
struct LFactsDiff: Sendable {
    var id: String
    var stage: Int
    var page: String
    var model: String
    var reason: String
}

// MARK: - The fixture

enum Lifecycle {
    /// Every road chip of a stage — shown and hidden — with its subject.
    static func chips(of stage: LStage) -> [(LSubject, LChip)] {
        var all: [(LSubject, LChip)] = []
        for row in stage.rows {
            switch row.content {
            case .text: break
            case .chips(let subject, let chips), .textStating(_, let subject, let chips):
                all += chips.map { (subject, $0) }
            }
        }
        for hidden in stage.hidden { all += hidden.chips.map { (hidden.subject, $0) } }
        return all
    }

    /// Every FACTS DIFF — none at extraction (piece B); FD-1, FD-2 and FD-3 were
    /// found by the scenario's first run (U3 piece C) and RULED by her at the
    /// U3 seam (2026-10-16): FD-1 and FD-3 accepted as the page's new words, FD-2
    /// "say it in rule 25" — the facts below carry her wording (U4 piece B), so
    /// none stands. A fact the model cannot produce is listed here, hers to
    /// accept; the page shows it on its stage as a note under review.
    static let factsDiff: [LFactsDiff] = []

    static let stages: [LStage] = [
        // MARK: 1
        LStage(
            number: 1, title: #"You create a library"#, posture: .standard, postureLabel: #"Standard"#,
            road: "createLibrary with no passphrase (rule 2: twelve words always)",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"A random key is made. The key file is written beside the library, with the key locked under your <b>twelve words</b> and under this Mac's quiet roads. The words are shown once: "write these down now". A sealed copy of the key file goes into this Mac's keychain. A plain random device ID is written [1, 2, 23]."#)),
                LRow(term: #"Opens the library"#, content: .chips(.library, [
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"Apple road"#),
                    LChip(road: .onDevice, state: .opens, label: #"on-device road"#),
                ])),
                LRow(term: #"Backups so far"#, content: .text(#"none"#)),
            ],
            note: #"Until you set a passphrase, the app reminds you — at the third launch, weekly twice, then with "don't show again", and always before your first backup [3]."#,
            facts: [
                LFactEntry(fact: .newKey(name: "K1", kind: .standard), quote: "A random key is made.", rules: [1]),
                LFactEntry(
                    fact: .keyFileLocks(has: [.words, .apple], lacks: [.passphrase, .master]),
                    quote: "The key file is written beside the library, with the key locked under your twelve words and under this Mac's quiet roads.",
                    rules: [1, 2]),
                LFactEntry(
                    fact: .custody(has: [.onDevice], lacks: [.touchID]),
                    quote: "…and under this Mac's quiet roads.", rules: [8]),
                LFactEntry(fact: .wordsShownOnce, quote: #"The words are shown once: "write these down now"."#, rules: [2]),
                LFactEntry(fact: .sealedKeyFileCopy, quote: "A sealed copy of the key file goes into this Mac's keychain.", rules: [1, 21]),
                LFactEntry(fact: .newPlainRandomDeviceID, quote: "A plain random device ID is written [1, 2, 23].", rules: [23]),
                LFactEntry(fact: .noBackups, quote: "Backups so far: none", rules: [5]),
                LFactEntry(fact: .passphraseAsk(.beforeFirstBackup), quote: "…and always before your first backup [3].", rules: [3]),
                LFactEntry(
                    fact: .reminderTrigger(.noPassphraseYet),
                    quote: "Until you set a passphrase, the app reminds you", rules: [3]),
                LFactEntry(
                    fact: .notTypedHere, quote: #"at the third launch, weekly twice, then with "don't show again""#, rules: [3],
                    status: .notAModelFact("the schedule's face — phase 3 (the model keeps the facts: `passphraseSet`, `reminderDismissals`)")),
            ]),

        // MARK: 2
        LStage(
            number: 2, title: #"The tutorial ends: you set a passphrase"#, posture: .standard, postureLabel: #"Standard"#,
            road: "the passphrase set — Standard's plain-confirm passphrase door (resetPassphrase .plainConfirm)",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"The key file gains a passphrase lock. Nothing else changes [3, 6]."#)),
                LRow(term: #"Opens the library"#, content: .chips(.library, [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: #"passphrase"#),
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"Apple road"#),
                    LChip(road: .onDevice, state: .opens, label: #"on-device road"#),
                ])),
            ],
            note: #"Either secret can reset the other. If you never set a passphrase, every later stage simply has one fewer road; nothing below depends on it except entering Castle."#,
            facts: [
                LFactEntry(fact: .keyUnchanged, quote: "The key file gains a passphrase lock.", rules: [6]),
                LFactEntry(fact: .keyFileLocks(has: [.passphrase, .words, .apple], lacks: [.master]), quote: "The key file gains a passphrase lock.", rules: [3]),
                LFactEntry(fact: .nothingElseChanges(except: .passphrase), quote: "Nothing else changes [3, 6].", rules: [3, 6]),
                LFactEntry(
                    fact: .notTypedHere, quote: "Either secret can reset the other.", rules: [3],
                    status: .branch("the key doors — `KeyDoorTests`/`DoorAndDeviceActTests` (reset by the words; new words by the passphrase)")),
                LFactEntry(
                    fact: .notTypedHere,
                    quote: "If you never set a passphrase, every later stage simply has one fewer road; nothing below depends on it except entering Castle.",
                    rules: [3], status: .branch("not on this road (she sets one) — Use Castle's door sets a passphrase where none exists (`doorSecrets`)")),
            ]),

        // MARK: 3
        LStage(
            number: 3, title: #"Your first backup"#, posture: .standard, postureLabel: #"Standard"#,
            road: "the backup service: backup A",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"The backup is the library plus the key file of this day [5]. If you still have no passphrase, the reminder shows right before the backup is made."#)),
                LRow(term: #"Opens backup A"#, content: .chips(.backupA, [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: #"passphrase"#),
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"Apple road (while it holds this key)"#),
                    LChip(road: .onDevice, state: .opens, label: #"on-device road (while it holds this key)"#),
                ])),
            ],
            note: #"The quiet roads open backup A because it is sealed under the very key they hold today. They stop opening it the day the library's key changes (stage 6) [5]."#,
            hidden: [
                LHiddenRoads(subject: .library, chips: [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: "passphrase"),
                    LChip(road: .typed(.words, .today), state: .opens, label: "twelve words"),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: "Apple road"),
                    LChip(road: .onDevice, state: .opens, label: "on-device road"),
                ], source: "carried from stage 2 — a backup changes nothing in the live place"),
            ],
            facts: [
                LFactEntry(fact: .backupOfItsDay(.backupA), quote: "The backup is the library plus the key file of this day [5].", rules: [5]),
                LFactEntry(
                    fact: .passphraseAsk(nil),
                    quote: "If you still have no passphrase, the reminder shows right before the backup is made.", rules: [3]),
                LFactEntry(
                    fact: .notTypedHere, quote: "They stop opening it the day the library's key changes (stage 6) [5].", rules: [5],
                    status: .assertedAt(6)),
            ]),

        // MARK: 4
        LStage(
            number: 4, title: #"You change your passphrase, or make new words"#, posture: .standard, postureLabel: #"Standard"#,
            road: "Change Passphrase (the first \"or\"; New Words is stage 7's)",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"The current key is re-locked under the new secret; the key itself does not change. Backup A's own key file still wants the <em>old</em> secret — and your <b>new</b> secret opens it too, because it is the same key [6]."#)),
                LRow(term: #"Opens backup A"#, content: .chips(.backupA, [
                    LChip(road: .typed(.either, .today), state: .opens, label: #"today's passphrase or words"#),
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: #"that day's passphrase or words"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"Apple road"#),
                    LChip(road: .onDevice, state: .opens, label: #"on-device road"#),
                ])),
            ],
            note: nil,
            hidden: [
                LHiddenRoads(subject: .library, chips: [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: "passphrase"),
                    LChip(road: .typed(.words, .today), state: .opens, label: "twelve words"),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: "Apple road"),
                    LChip(road: .onDevice, state: .opens, label: "on-device road"),
                ], source: "carried from stage 2 — the key is re-locked, not changed (today's passphrase is the new one)"),
            ],
            facts: [
                LFactEntry(fact: .keyUnchanged, quote: "the key itself does not change.", rules: [6]),
                LFactEntry(fact: .lockRelocked(.passphrase), quote: "The current key is re-locked under the new secret", rules: [6]),
                LFactEntry(
                    fact: .ownKeyFileWantsTheOldSecret(.backupA, .passphrase),
                    quote: "Backup A's own key file still wants the old secret", rules: [5, 6]),
            ]),

        // MARK: 5
        LStage(
            number: 5, title: #"You change your Apple ID, or iCloud Keychain is reset"#, posture: .standard,
            postureLabel: #"Standard — "the real issue""#,
            road: "each \"or\" walked: her devices move to another Apple ID, or iCloud Keychain is reset; then the next open, nothing typed",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"The Apple road may stop working. The app can't see this coming and doesn't try to. At the next open it uses the on-device road — which never depended on iCloud — and quietly makes a fresh Apple road under the new account. Nothing is asked. Only if <em>both</em> quiet roads are gone (a keychain reset) does it ask for your passphrase or words first [8]."#)),
                LRow(term: #"Opens the library"#, content: .chips(.library, [
                    LChip(road: .onDevice, state: .opens, label: #"on-device road"#),
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: #"passphrase"#),
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .apple(.beforeThisStage), state: .gone, label: #"old Apple road"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"new Apple road, after the open"#),
                ])),
                LRow(term: #"Backups so far"#, content: .textStating(
                    #"Open with their day's secrets, today's, or the on-device road [4, 5]. Their old Apple lock is dead, and that is fine."#,
                    .backupA, [
                        LChip(road: .typed(.either, .itsDay), state: .opens, label: "their day's secrets"),
                        LChip(road: .typed(.either, .today), state: .opens, label: "today's"),
                        LChip(road: .onDevice, state: .opens, label: "the on-device road"),
                        LChip(road: .apple(.itsOwnLock), state: .gone, label: "Their old Apple lock is dead"),
                    ])),
            ],
            note: #"The reminder of rule 3 still shows once here if you have no passphrase. This is why there is no secretless library: the one state where an Apple ID change could strand you no longer exists [2, 25]."#,
            facts: [
                LFactEntry(
                    fact: .nextOpenAsksNothing,
                    quote: "At the next open it uses the on-device road — which never depended on iCloud — … Nothing is asked.", rules: [8]),
                LFactEntry(fact: .freshAppleRoad, quote: "and quietly makes a fresh Apple road under the new account.", rules: [8]),
                LFactEntry(
                    fact: .nextOpenAsksAtOnce,
                    quote: "Only if both quiet roads are gone (a keychain reset) does it ask for your passphrase or words first [8].",
                    rules: [8], status: .assertedAt(11)),
                LFactEntry(
                    fact: .passphraseAsk(nil), quote: "The reminder of rule 3 still shows once here if you have no passphrase.",
                    rules: [3]),
            ]),

        // MARK: 6
        LStage(
            number: 6, title: #"Use Castle"#, posture: .castle, postureLabel: #"Castle — Touch ID or Always ask"#,
            road: "the scheduled export on (so its turn-off can be seen), then Use Castle typing the passphrase and the twelve words — each gate walked: Touch ID, Always ask",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"You type your passphrase and your twelve words. A new Castle key is made; every earlier key moves into its history, under the new key [4, 11]. The Apple and on-device keychain entries are <b>deleted</b> — and the Apple deletion reaches your other Macs too, so backup A's quiet locks die everywhere. (If your Apple ID changed at stage 5, backup A's Apple lock sits under a key in the Apple account you have since left: backup A keeps that lock, which the app cannot delete [25] — no device of yours reads it, and Use Castle names backup A as a copy under a key it can't delete.) If you chose Touch ID, this Mac keeps the new key behind your fingerprint; under Always ask, no copy stays on the device. The scheduled plain-text export is turned off, with one notice you may reverse. Synced: the account gets a new sync key in one write and keeps the old one in its list; every other device must type a secret once to follow [10, 15]."#)),
                LRow(term: #"Opens the library"#, content: .chips(.library, [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: #"passphrase"#),
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .touchID, state: .opens, label: #"Touch ID (if chosen)"#, condition: .touchIDChosen),
                    LChip(road: .apple(.itsOwnLock), state: .gone, label: #"Apple road"#),
                    LChip(road: .onDevice, state: .gone, label: #"login password"#),
                ])),
                LRow(term: #"Opens backup A (Standard era)"#, content: .chips(.backupA, [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: #"today's passphrase or words (through the history)"#),
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: #"its day's secrets"#),
                    LChip(road: .apple(.itsOwnLock), state: .gone, label: #"its Apple lock"#, everywhere: true),
                ])),
            ],
            note: #"Entering takes everything in: backup A is now Castle-protected along with the live library — its quiet locks are dead and only typed secrets reach it, through the history [4, 11]."#,
            hidden: [
                LHiddenRoads(subject: .backupA, chips: [
                    LChip(road: .quietRoads, state: .gone, label: "its quiet locks are dead"),
                ], source: "stated in the note: \"its quiet locks are dead and only typed secrets reach it\""),
            ],
            facts: [
                LFactEntry(fact: .newKey(name: "K2", kind: .castle), quote: "A new Castle key is made", rules: [11]),
                LFactEntry(fact: .historyCarries(["K1"]), quote: "every earlier key moves into its history, under the new key [4, 11].", rules: [4, 11]),
                LFactEntry(
                    fact: .keyFileLocks(has: [.passphrase, .words], lacks: [.apple, .master]),
                    quote: "You type your passphrase and your twelve words.", rules: [9, 11]),
                LFactEntry(
                    fact: .appleKeysDeletedEverywhere,
                    quote: "The Apple and on-device keychain entries are deleted — and the Apple deletion reaches your other Macs too, so backup A's quiet locks die everywhere.",
                    rules: [9, 11]),
                LFactEntry(
                    fact: .appleKeysDeleted, quote: "The Apple and on-device keychain entries are deleted", rules: [11],
                    status: .onlyWhen(.iCloudKeychainReset)),
                LFactEntry(
                    fact: .all([.appleLockKeptInAnAccountSheLeft(.backupA), .useCastleNamesCopiesItCantDelete(.backupA)]),
                    quote: "If your Apple ID changed at stage 5, backup A's Apple lock sits under a key in the Apple account you have since left: backup A keeps that lock, which the app cannot delete [25] — no device of yours reads it, and Use Castle names backup A as a copy under a key it can't delete.",
                    rules: [25, 9, 11], status: .onlyWhen(.appleIDChanged)),
                LFactEntry(fact: .noOnDeviceItemForAnyKeyItHasHad, quote: "The Apple and on-device keychain entries are deleted", rules: [11]),
                LFactEntry(
                    fact: .touchIDItemIfChosen,
                    quote: "If you chose Touch ID, this Mac keeps the new key behind your fingerprint; under Always ask, no copy stays on the device.",
                    rules: [9]),
                LFactEntry(fact: .scheduledExportOffWithOneNotice, quote: "The scheduled plain-text export is turned off, with one notice", rules: [11]),
                LFactEntry(fact: .scheduledExportReversible, quote: "you may reverse.", rules: [11]),
                LFactEntry(
                    fact: .accountEntersCastleInOneWrite,
                    quote: "Synced: the account gets a new sync key in one write and keeps the old one in its list; every other device must type a secret once to follow [10, 15].",
                    rules: [10, 15], status: .assertedAt(12)),
            ]),

        // MARK: 7
        LStage(
            number: 7, title: #"In Castle: new words, or a backup"#, posture: .castle, postureLabel: #"Castle"#,
            road: "New Words (asking the passphrase), then the backup service: backup B",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"New words re-lock the current key; the history still carries everything, so older backups still open with today's secrets [4, 6]. A backup made now — <b>backup B</b> — carries this day's Castle key file: no Apple lock, no login-password lock."#)),
                LRow(term: #"Opens backup B"#, content: .chips(.backupB, [
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: #"Castle passphrase or words of its day"#),
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: #"today's, through the history"#),
                    LChip(road: .touchID, state: .opens, label: #"Touch ID on this Mac (if chosen)"#, condition: .touchIDChosen),
                ])),
            ],
            note: nil,
            hidden: [
                LHiddenRoads(subject: .library, chips: [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: "passphrase"),
                    LChip(road: .typed(.words, .today), state: .opens, label: "twelve words"),
                    LChip(road: .touchID, state: .opens, label: "Touch ID (if chosen)", condition: .touchIDChosen),
                    LChip(road: .apple(.itsOwnLock), state: .gone, label: "Apple road"),
                    LChip(road: .onDevice, state: .gone, label: "login password"),
                ], source: "carried from stage 6 — new words re-lock the current key (today's words are the new ones)"),
                LHiddenRoads(subject: .backupA, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "older backups still open with today's secrets"),
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: "its day's secrets"),
                    LChip(road: .quietRoads, state: .gone, label: "its quiet locks"),
                ], source: "stated in the stage's words: \"the history still carries everything, so older backups still open with today's secrets\"; the rest carried from stage 6"),
            ],
            facts: [
                LFactEntry(fact: .keyUnchanged, quote: "New words re-lock the current key", rules: [6]),
                LFactEntry(fact: .lockRelocked(.words), quote: "New words re-lock the current key", rules: [6]),
                LFactEntry(fact: .historyCarries(["K1"]), quote: "the history still carries everything", rules: [4]),
                LFactEntry(fact: .backupOfItsDay(.backupB), quote: "A backup made now — backup B — carries this day's Castle key file", rules: [5]),
                LFactEntry(
                    fact: .copyLocks(.backupB, has: [.passphrase, .words], lacks: [.apple], noItem: false),
                    quote: "no Apple lock", rules: [9]),
                LFactEntry(
                    fact: .copyLocks(.backupB, has: [], lacks: [], noItem: true), quote: "no login-password lock.", rules: [9]),
            ]),

        // MARK: 8
        LStage(
            number: 8, title: #"Use Standard (you leave Castle)"#, posture: .standard, postureLabel: #"Standard again"#,
            road: "Use Standard typing the passphrase and the twelve words",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"You type your passphrase and your twelve words. A new Standard key carrying every earlier key — the Castle ones included — with a fresh Apple road and the on-device road back [12]. Your text, the server's rows, the sync key and <b>every backup you have ever made</b> are Standard from now on. This Mac's on-device road and its sealed key-file copy now hold the new key. Other devices follow out quietly, with a notice."#)),
                LRow(term: #"Opens the library"#, content: .chips(.library, [
                    LChip(road: .typed(.passphrase, .today), state: .opens, label: #"passphrase"#),
                    LChip(road: .typed(.words, .today), state: .opens, label: #"twelve words"#),
                    LChip(road: .apple(.itsOwnLock), state: .opens, label: #"Apple road"#),
                    LChip(road: .onDevice, state: .opens, label: #"on-device road"#),
                ])),
                LRow(term: #"Opens backup B (Castle era)"#, content: .chips(.backupB, [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: #"today's passphrase or words (through the history)"#),
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: #"its day's Castle secrets"#),
                    LChip(road: .quietRoads, state: .gone, label: #"quiet roads (they hold only the new key)"#),
                ])),
                LRow(term: #"Opens backup A (before Castle)"#, content: .chips(.backupA, [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: #"today's passphrase or words (through the history)"#),
                    LChip(road: .typed(.either, .itsDay), state: .opens, label: #"its day's secrets"#),
                    LChip(road: .quietRoads, state: .gone, label: #"quiet roads"#),
                ])),
            ],
            note: #"<b>One posture at a time: leaving hands everything to Standard</b> [12, 13]. A Castle-era backup was protected while your library was in Castle; now your typed Standard secrets open it like any other backup (quiet roads still open only the live key they hold — a backup file never opens through iCloud by itself). The leave screen says: <em>your library and all your backups will open through your Apple account and this Mac again; if you want Castle-era writing to stay Castle-protected, don't leave.</em>"#,
            facts: [
                LFactEntry(fact: .newKey(name: "K3", kind: .standard), quote: "A new Standard key", rules: [12]),
                LFactEntry(fact: .historyCarries(["K2", "K1"]), quote: "carrying every earlier key — the Castle ones included", rules: [4, 12]),
                LFactEntry(fact: .keyFileLocks(has: [.passphrase, .words, .apple], lacks: [.master]), quote: "You type your passphrase and your twelve words.", rules: [12]),
                LFactEntry(fact: .freshAppleRoad, quote: "with a fresh Apple road", rules: [12]),
                LFactEntry(fact: .custody(has: [.onDevice], lacks: []), quote: "and the on-device road back [12].", rules: [8, 12]),
                LFactEntry(
                    fact: .all([.custody(has: [.onDevice], lacks: [.touchID]), .noTouchIDItemForAnyKeyItHasHad]),
                    quote: "This Mac's on-device road … now hold[s] the new key.", rules: [8, 12]),
                LFactEntry(fact: .sealedKeyFileCopy, quote: "…and its sealed key-file copy now hold the new key.", rules: [1, 12]),
                LFactEntry(
                    fact: .accountLeavesCastleOtherDevicesFollowQuietly,
                    quote: "Your text, the server's rows, the sync key … are Standard from now on. … Other devices follow out quietly, with a notice.",
                    rules: [12, 15], status: .assertedAt(12)),
                LFactEntry(
                    fact: .notTypedHere,
                    quote: "The leave screen says: your library and all your backups will open through your Apple account and this Mac again; if you want Castle-era writing to stay Castle-protected, don't leave.",
                    rules: [12], status: .notAModelFact("the leave screen's face — VX-307 (the model's Use Standard door carries rule 5's words)")),
            ]),

        // MARK: 9
        LStage(
            number: 9, title: #"You open a Castle-era backup after leaving"#, posture: .any,
            postureLabel: #"Look inside, or Make this my library"#,
            road: "Look inside backup B (each secret typed in turn), then Make this my library from it",
            rows: [
                LRow(term: #"Look inside"#, content: .text(#"Type your current passphrase or words (or backup B's own Castle ones). It opens read-only. Nothing is written — no key file, no keychain item, no change to your library. Close it and the app forgets it [17]."#)),
                LRow(term: #"Make this my library"#, content: .text(#"One confirmed door. Backup B becomes a <b>new library</b> with a fresh key in the posture you are in now (Standard, here), under your current pair — the new key carrying backup B's key history forward, and your previous library's keys with it, so every earlier backup still opens with today's secrets [4, 17] — and your current library steps aside whole into Previous Libraries [17]. Backup B itself is untouched. The app's Restore from Backup button is this door."#)),
            ],
            note: nil,
            hidden: [
                LHiddenRoads(subject: .backupA, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "today's passphrase or words, through the new library's history"),
                ], source: "stated in the stage's words: \"every earlier backup still opens with today's secrets\" (her ruling on P-VX378-U4-1)"),
                LHiddenRoads(subject: .backupB, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "today's passphrase or words, through the new library's history"),
                ], source: "stated in the stage's words: \"the new key carrying backup B's key history forward\" (her ruling on P-VX378-U4-1)"),
            ],
            facts: [
                LFactEntry(
                    fact: .lookInside(
                        .backupB, opensWith: [.today(.passphrase), .today(.words), .itsDay(.passphrase), .itsDay(.words)],
                        refuses: [], quietRoad: false),
                    quote: "Type your current passphrase or words (or backup B's own Castle ones). It opens read-only. Nothing is written — no key file, no keychain item, no change to your library. Close it and the app forgets it [17].",
                    rules: [17]),
                LFactEntry(
                    fact: .makeMine(.backupB),
                    quote: "Backup B becomes a new library with a fresh key in the posture you are in now (Standard, here), under your current pair — the new key carrying backup B's key history forward, and your previous library's keys with it … — and your current library steps aside whole into Previous Libraries [17]. Backup B itself is untouched.",
                    rules: [4, 17]),
                LFactEntry(
                    fact: .notTypedHere, quote: "The app's Restore from Backup button is this door.", rules: [17],
                    status: .notAModelFact("the face — VX-309 (the model has the one door, `makeThisMyLibrary`)")),
            ]),

        // MARK: 10
        LStage(
            number: 10, title: #"Someone AirDrops you their library"#, posture: .any, postureLabel: #"any posture"#,
            road: "their library made on their Mac (another Apple ID, their own account), sent to this Mac; Look inside it, then Make this my library from it",
            rows: [
                LRow(term: #"Look inside"#, content: .text(#"Opens with <em>their</em> secrets, read-only, writes nothing [17]."#)),
                LRow(term: #"Make this my library"#, content: .text(#"It becomes a new library of yours, with a fresh identity and a fresh key in your posture, under your current pair — the new key carrying their library's key history forward, and your previous library's keys with it, so your own earlier backups still open with today's secrets [4, 17]; you never leave Castle by opening something [17, 18]. From here the two copies diverge — sharing a library across devices is what sync is for. If you sync, their writing joins <em>your</em> account as a copy and nothing leaves theirs: the server keeps every account's rows apart, reachable only with that account's own sign-in and sync key [18]."#)),
            ],
            note: nil,
            hidden: [
                LHiddenRoads(subject: .backupA, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "today's passphrase or words, through the new library's history"),
                ], source: "stated in the stage's words: \"your own earlier backups still open with today's secrets\" (her ruling on P-VX378-U4-1)"),
                LHiddenRoads(subject: .backupB, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "today's passphrase or words, through the new library's history"),
                ], source: "stated in the stage's words: \"your own earlier backups still open with today's secrets\" (her ruling on P-VX378-U4-1)"),
                LHiddenRoads(subject: .theirs, chips: [
                    LChip(road: .typed(.either, .throughTheHistory), state: .opens, label: "today's passphrase or words, through the new library's history"),
                ], source: "stated in the stage's words: \"the new key carrying their library's key history forward\" (her ruling on P-VX378-U4-1)"),
            ],
            facts: [
                LFactEntry(
                    fact: .lookInside(
                        .theirs, opensWith: [.theirs(.passphrase), .theirs(.words)], refuses: [.today(.passphrase), .today(.words)],
                        quietRoad: false),
                    quote: "Opens with their secrets, read-only, writes nothing [17].", rules: [17]),
                LFactEntry(
                    fact: .makeMine(.theirs),
                    quote: "It becomes a new library of yours, with a fresh identity and a fresh key in your posture, under your current pair — the new key carrying their library's key history forward, and your previous library's keys with it",
                    rules: [4, 17, 18]),
                LFactEntry(
                    fact: .notTypedHere, quote: "you never leave Castle by opening something [17, 18].", rules: [17],
                    status: .branch("not on this road (Standard here) — `U2MakeMineTests.inCastleTheNewLibraryIsCastle`")),
                LFactEntry(
                    fact: .theirsUntouched,
                    quote: "From here the two copies diverge … nothing leaves theirs", rules: [18]),
                LFactEntry(
                    fact: .syncSetUpHandsThePairUp, quote: "If you sync, their writing joins your account as a copy", rules: [18],
                    status: .assertedAt(12)),
                LFactEntry(
                    fact: .notTypedHere,
                    quote: "the server keeps every account's rows apart, reachable only with that account's own sign-in and sync key [18].",
                    rules: [18], status: .notAModelFact("the server's row-level security (SyncSpec §2; 14c) — the model keeps one vault per account, asserted in `theirsUntouched`")),
            ]),

        // MARK: 11
        LStage(
            number: 11, title: #"You move to a new Mac with Migration Assistant"#, posture: .any, postureLabel: #"any posture"#,
            road: "the library and its key file moved to new hardware; no keychain item arrives (her iCloud Keychain not on yet there); the first open",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"The library and its key file move with you. This Mac's keychain items may or may not arrive — that is Apple's behaviour, which the app doesn't answer for [25]. If the quiet roads didn't survive the move, the first open asks for your passphrase or words and re-makes them [8]; Castle re-arms Touch ID on the new hardware the same way. Nothing is "taken over" and nothing is fingerprinted — the device ID is a plain random value [23]."#)),
            ],
            note: nil,
            facts: [
                LFactEntry(fact: .filesMoveWithYou, quote: "The library and its key file move with you.", rules: [1]),
                LFactEntry(
                    fact: .notTypedHere, quote: "This Mac's keychain items may or may not arrive — that is Apple's behaviour, which the app doesn't answer for [25].",
                    rules: [25], status: .notAModelFact("Apple's (rule 25) — this road takes the branch where none arrives")),
                LFactEntry(
                    fact: .nextOpenAsksAtOnce, quote: "If the quiet roads didn't survive the move, the first open asks for your passphrase or words",
                    rules: [8]),
                LFactEntry(fact: .quietRoadsRemade, quote: "and re-makes them [8]", rules: [8]),
                LFactEntry(
                    fact: .notTypedHere, quote: "Castle re-arms Touch ID on the new hardware the same way.", rules: [8, 9],
                    status: .branch("not on this road (Standard here) — the re-arm is a press, never a repair: the guard `noRepairMakesTouchIDOn` and its pins; the face is VX-306's")),
                LFactEntry(fact: .newPlainRandomDeviceID, quote: "the device ID is a plain random value [23].", rules: [23]),
                LFactEntry(fact: .nothingTakenOver, quote: #"Nothing is "taken over" and nothing is fingerprinted"#, rules: [23]),
            ]),

        // MARK: 12
        LStage(
            number: 12, title: #"You turn on sync, or join from a new device"#, posture: .any, postureLabel: #"any posture"#,
            road: "this Mac turns sync on first; a second device makes its own library, backs it up, and joins typing the account's passphrase; the second device enters Castle, this Mac lags, then follows typing one secret; this Mac leaves Castle and the second device follows out quietly; the second device leaves the account and signs back in",
            rows: [
                LRow(term: #"Turning sync on first"#, content: .text(#"Your library's passphrase and twelve words become the account's. Nothing is replaced [7]."#)),
                LRow(term: #"Joining from another device"#, content: .text(#"You type the account's passphrase or words once. Your library's own pair is <b>replaced</b> by the account's, and the app tells you so and shows the words: write them down; the old ones still open backups you made before today (same key, old locks) [7, 14]. For anyone who never wrote their words down, this is the reminder, while they still have access."#)),
                LRow(term: #"Castle, account-wide"#, content: .text(#"When one device enters Castle, each other device types a secret once at its next sync to follow; until then it reads only what it already has, through its own quiet road [10]. The account keeps every sync key it has had, so a device joining later reads everything [15]."#)),
                LRow(term: #"Leaving the account"#, content: .text(#"Changes none of your keys or secrets; your library just stops syncing. The server keeps what you pushed. Signing back in is a join [16]."#)),
            ],
            note: nil,
            facts: [
                LFactEntry(
                    fact: .syncSetUpHandsThePairUp, quote: "Your library's passphrase and twelve words become the account's. Nothing is replaced [7].",
                    rules: [7, 14]),
                LFactEntry(fact: .theirsUntouched, quote: "(stage 10) nothing leaves theirs — re-read once this library syncs", rules: [18]),
                LFactEntry(
                    fact: .joinAdoptsTheAccountsPair,
                    quote: "You type the account's passphrase or words once. Your library's own pair is replaced by the account's", rules: [7, 14]),
                LFactEntry(fact: .notices([.wordsReplacedByAccount]), quote: "and the app tells you so", rules: [7]),
                LFactEntry(
                    fact: .notTypedHere, quote: "and shows the words: write them down", rules: [7],
                    status: .notAModelFact("the face (VX-308) — P-VX378-U2-3 (a), binding for U3: the words are shown when they were typed")),
                LFactEntry(
                    fact: .oldWordsStillOpenOlderBackups,
                    quote: "the old ones still open backups you made before today (same key, old locks) [7, 14].", rules: [5, 7]),
                LFactEntry(
                    fact: .notTypedHere,
                    quote: "For anyone who never wrote their words down, this is the reminder, while they still have access.", rules: [14],
                    status: .notAModelFact("the join's face (VX-308) — the model's fact is that the join types one of the account's secrets (`joinAdoptsTheAccountsPair`)")),
                LFactEntry(
                    fact: .accountEntersCastleInOneWrite,
                    quote: "When one device enters Castle … (stage 6) Synced: the account gets a new sync key in one write and keeps the old one in its list",
                    rules: [11, 15]),
                LFactEntry(
                    fact: .laggingDeviceReadsOnlyWhatItHas,
                    quote: "each other device types a secret once at its next sync to follow; until then it reads only what it already has, through its own quiet road [10].",
                    rules: [10, 15]),
                LFactEntry(fact: .followTypesOneSecret, quote: "each other device types a secret once at its next sync to follow", rules: [10]),
                LFactEntry(
                    fact: .accountLeavesCastleOtherDevicesFollowQuietly,
                    quote: "(stage 8) Your text, the server's rows, the sync key … are Standard from now on. … Other devices follow out quietly, with a notice.",
                    rules: [12, 15]),
                LFactEntry(
                    fact: .leavingTheAccountChangesNoKey,
                    quote: "Changes none of your keys or secrets; your library just stops syncing. The server keeps what you pushed.", rules: [16]),
                LFactEntry(
                    fact: .signingBackInIsAJoinThatReadsEverything,
                    quote: "Signing back in is a join [16]. … The account keeps every sync key it has had, so a device joining later reads everything [15].",
                    rules: [15, 16]),
            ]),

        // MARK: 13
        LStage(
            number: 13, title: #"A crash in the middle of any of this"#, posture: .any, postureLabel: #"any posture"#,
            road: "Replace All Keys crashed after its first write, then after its plan — each followed by the next open",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"Every act that changes keys is planned. The next open finds either the old state or the new one, finishes or rolls back from what is on disk, and says which [20]. A key is deleted only after its replacement has been verified [22]."#)),
            ],
            note: nil,
            facts: [
                LFactEntry(
                    fact: .crashBeforeThePlanRollsBack,
                    quote: "The next open finds either the old state or the new one, finishes or rolls back from what is on disk, and says which [20].",
                    rules: [20]),
                LFactEntry(
                    fact: .crashAfterThePlanFinishes,
                    quote: "The next open finds either the old state or the new one, finishes or rolls back from what is on disk, and says which [20].",
                    rules: [20]),
                LFactEntry(
                    fact: .noKeyDeletedBeforeItsReplacement, quote: "A key is deleted only after its replacement has been verified [22].",
                    rules: [22]),
            ]),

        // MARK: 14
        LStage(
            number: 14, title: #"Something is wrong on disk"#, posture: .any, postureLabel: #"any posture"#,
            road: "a backup pair copied into the live place by hand, a replayed old library file, someone else's file swapped in — each opened, then put back; the live key file deleted; then every key-file copy gone",
            rows: [
                LRow(term: #"What happens"#, content: .text(#"This Mac remembers four things about its library: its ID, its current key, its device ID and a sealed copy of its key file — and only the app's own doors change them [21]. If the file in the live place isn't the one it remembers — a swapped-in file, a replayed old file, or a backup pair you copied in by hand — the app refuses to open, says what it found, and offers the two doors: Look inside, or Make this my library. It never repairs by guessing. The honest way to go back to a backup is the app's own Restore from Backup door (stage 9)."#)),
                LRow(term: #"Lost the key file?"#, content: .text(#"The app kept copies: beside the library, inside every backup, sealed in this Mac's keychain [1]. Synced libraries recover from the account with the twelve words [27]."#)),
            ],
            note: nil,
            facts: [
                LFactEntry(
                    fact: .fourThingsRemembered,
                    quote: "This Mac remembers four things about its library: its ID, its current key, its device ID and a sealed copy of its key file",
                    rules: [21]),
                LFactEntry(
                    fact: .refusesWhatItDoesntRemember(.backupPairCopiedInByHand),
                    quote: "a backup pair you copied in by hand — the app refuses to open, says what it found, and offers the two doors: Look inside, or Make this my library. It never repairs by guessing.",
                    rules: [21]),
                LFactEntry(
                    fact: .refusesWhatItDoesntRemember(.replayedOldLibraryFile),
                    quote: "a replayed old file — the app refuses to open, says what it found, and offers the two doors", rules: [21]),
                LFactEntry(
                    fact: .refusesWhatItDoesntRemember(.swappedInFile),
                    quote: "a swapped-in file — the app refuses to open, says what it found, and offers the two doors", rules: [21]),
                LFactEntry(
                    fact: .notTypedHere, quote: "The honest way to go back to a backup is the app's own Restore from Backup door (stage 9).",
                    rules: [17, 21], status: .notAModelFact("the face — VX-309 (the door is stage 9's Make this my library)")),
                LFactEntry(
                    fact: .lostKeyFileComesBack,
                    quote: "The app kept copies: beside the library, inside every backup, sealed in this Mac's keychain [1].", rules: [1]),
                LFactEntry(
                    fact: .syncedLibraryRecoversWithTheWords,
                    quote: "Synced libraries recover from the account with the twelve words [27].", rules: [14, 27]),
            ]),
    ]
}
