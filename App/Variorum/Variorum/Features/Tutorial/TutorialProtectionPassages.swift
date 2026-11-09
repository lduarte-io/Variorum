//
//  TutorialProtectionPassages.swift
//  Variorum (Mac)
//
//  VX-916 (the VX-915 run, batch 4) — THE PROTECTION CHAPTER'S TWO NEW PIECES, re-homed from VX-379 (VX-529's riders):
//
//    1. R-529-6's ONE guide line — the "your account's passphrase hasn't been typed on this Mac yet" state: why it
//       happens, why it isn't a state to stay in, and the road out. Her direction (R-529-6, verbatim in
//       `notes/plans/fixes/vx-529-pair-catchup.md`): the WHY and the ROAD, never the mechanism, and "make it clear it's
//       not the 'ideal' state". It QUOTES the band card's own words (VX-538 — `ProtectionWords.accountPassphraseCardLine`
//       and `accountPassphraseCardForgot`) and the follow sheet's ratified window sentence (R-529-5 —
//       `pairWordsWindow`), so the guide and the card can never disagree; the cadence is rule 3's own clause.
//    2. THE COMPROMISE-RECOVERY RECIPE — her words to VX-379 (2026-10-25, the vx-529 record's §THE COMPROMISE-RECOVERY
//       RECIPE) are the CONTENT direction; these sentences are drafted in the guide's voice and checked one by one
//       against `notes/CastleRules.md` (the self-check table is the vx-915 record's BATCH 4 LIVE STATUS). Two departures
//       from her draft, both forced by the rules: (a) her "leaving changes no key" is true of the ACCOUNT's keys (rule
//       15 — the sync key changes only when an account enters Castle) but rule 12 gives the LIBRARY a new key on the way
//       out, so the sentence says both; (b) her "it puts every session out of reach" is said through the app's own door,
//       Sign Out Everywhere, then the password change at stargazing.tech (her #90 (7) ruling: name the website's road) —
//       "session" is a word the guide's register never uses (the two-register rule). The internal nouns of her draft
//       (master, proof) stay out for the same reason; "a new sync key" is rule 11's own word.
//
//  PROVISIONAL P-915-B4-1 (the seat): both join lesson 2, "Standard and Castle", after its six paragraphs — the E6 line
//  first (it qualifies "What you must keep … either one opens your library and every backup of it" and the passphrase
//  floor before it), then the recipe (its moves are lesson 2's crossings). The chapter keeps its three lessons.
//  PROVISIONAL P-915-B4-2 (the home): this Mac-side file beside `TutorialStartHerePassages.swift` (the VX-105
//  precedent), quoting `ProtectionWords` / `ProtectionCopy` and never editing them; the alternative home is
//  `ProtectionWords`' guide section (Shared — where the phone's future pocket guide, VM-28, would read it).
//  Wording PROVISIONAL throughout (her wording pass), sentence case, no shouty caps.
//

import Foundation

extension TutorialSeeder {
    /// **R-529-6's guide line** (VX-916 piece 1). Why: a synced library that joined by its twelve words, or caught up with
    /// them (rule 3's own clause), has no lock of the account's passphrase here; why it isn't a state to stay in: copies
    /// made here open with the twelve words only (R-529-5's ratified sentence); the road: type the passphrase once, or
    /// set one you know with Reset forgotten passphrase (rule 3; the card's own words, quoted).
    nonisolated static let accountPassphraseNotTypedHerePassage =
        "If this library joined your account with your twelve words, or caught up with them, and your account's "
        + "passphrase hasn't been typed on this \(ProtectionCopy.deviceName) since, the card above the quick entry says "
        + "so: \u{201C}\(ProtectionWords.accountPassphraseCardLine)\u{201D} It isn't a state to stay in. "
        + ProtectionWords.pairWordsWindow
        + " So the card comes back from the third launch, and a week after each time you put it away, until a "
        + "passphrase is typed here. " + ProtectionWords.accountPassphraseCardForgot

    /// **The compromise-recovery recipe** (VX-916 piece 2) — five passages: the lead with the first move (the account),
    /// the second (the pair), the third (Castle, and staying in Standard afterward), the already-in-Castle road, and the
    /// honest limit with why no new account is needed. The doors are named by their own constants.
    nonisolated static let compromiseRecoveryPassages: [String] = [
        "If you think someone has your passphrase, your twelve words or your library's key, three moves keep what you "
            + "write from then on out of reach of what they took. Make them in this order. First, your account: "
            + "\(ProtectionCopy.signOutEverywhereDoor) (Account\u{2026}, at the bottom of the sidebar), then change your "
            + "account password at stargazing.tech \u{2014} changing it happens on the website, not in the app. Every "
            + "device is signed out and the old password signs no one back in; sign in again here with the new one.",

        "Second, your passphrase and your twelve words: \(ProtectionWords.changePassphraseDoor) and "
            + "\(ProtectionWords.wordsSectionDoor) in Settings \u{25B8} Protection give you new ones. With sync on, they "
            + "replace your account's too, on every device, and each of your other devices, once it signs in again, "
            + "catches up with \(ProtectionWords.followDoor) there by typing the new passphrase or the new words once. "
            + "This comes "
            + "before the third move, so the new keys it makes are locked under secrets they don't have.",

        "Third, \(ProtectionWords.useCastleDoor) in Settings \u{25B8} Protection. Entering asks for your passphrase and "
            + "your twelve words, gives your library a new key and your account a new sync key, and seals what you write "
            + "from then on under keys none of their copies hold; each of your other devices follows by typing one of "
            + "the two once. Rather stay in Standard? \(ProtectionWords.useStandardDoor) afterward: leaving keeps your "
            + "account's new sync key, which changes only when an account enters Castle, and gives your library "
            + "another new key on the way out.",

        "Already in Castle? Then the third move is \(ProtectionWords.useStandardDoor), then "
            + "\(ProtectionWords.useCastleDoor) again, since entering is what makes the new keys. Between the two "
            + "crossings your library and every backup open through your Apple account and this "
            + "\(ProtectionCopy.deviceName) again, until entering deletes those roads once more, so make both in one "
            + "sitting, one right after the other.",

        "What no move can do: anything they already copied \u{2014} an old backup, your library as it stood, what "
            + "the server held until now \u{2014} stays readable to them with the keys they took. New keys protect what "
            + "you write from now on, never what's already taken. And you don't need a new account: after the three "
            + "moves your old password signs no one in, your old passphrase and words open nothing you write from then "
            + "on, and the new keys are locked under secrets they don't have. A fresh account would only clear the old "
            + "sealed writing off the server, and whatever of it they copied, they already have.",
    ]

    /// **Lesson 2 as the seed mints it** ("Standard and Castle"): `ProtectionWords.guidePosturesLesson`'s six
    /// paragraphs, byte-unchanged, then R-529-6's line, then the recipe (P-915-B4-1).
    nonisolated static var posturesLessonParagraphs: [String] {
        ProtectionWords.guidePosturesLesson + [accountPassphraseNotTypedHerePassage] + compromiseRecoveryPassages
    }
}
