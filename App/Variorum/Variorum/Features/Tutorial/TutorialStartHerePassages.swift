//
//  TutorialStartHerePassages.swift
//  Variorum (Mac)
//
//  VX-105 — THE FOUR START HERE PASSAGES, the field guide's one copy. VX-306
//  (2026-10-18, her kickoff word: drafted from `notes/CastleRules.md`, built as
//  drafted, PROVISIONAL — P-VX306-W-1) wrote them for the readme placeholder;
//  VX-309 U2 made them the protection chapter's key lesson's lead too ("one
//  text, two homes"); VX-105 ended the readme home (her finished readme
//  replaced the placeholder whole), so the GUIDE is their one home now —
//  moved byte for byte, the key lesson's text unchanged. R-105-7 (her words:
//  "do we not need to update the first chapter of the field guide so that even
//  though that removal happened, the four Castle passages are still in the
//  first thing that someone reads?") puts them in the first chapter's "start
//  here" lesson as well, read from this same constant — so they deliberately
//  read twice in the guide, her accepted state.
//
//  Its own file (not inside `TutorialSeeder.swift`) by the VX-105 / VX-292
//  boundary ruling: this effort's footprint in the seeder is the "start here"
//  lesson alone, beside the parallel onboarding effort's lessons.
//
//  VX-307 U2c (F-U2b-1): the second passage follows the amended rules 2, 3 and
//  7; all four are byte-pinned by `ReadmeStartHerePlanTests` to the VX-307
//  plan's U2c words block (the re-anchored source).
//

import Foundation

extension TutorialSeeder {
    nonisolated static let startHerePassages: [String] = [
        "Your work is encrypted. Every library is locked with its own random key, kept "
        + "in a small key file beside it. Variorum keeps copies of that key file for you "
        + "\u{2014} beside the library, inside every backup, and sealed in this Mac's "
        + "keychain \u{2014} so you never have to think about it.",

        // VX-307 U2c (F-U2b-1): the amended rules 2, 3 and 7 — the words shown only when she asks (the card above
        // the quick entry, the tour's end, Settings ▸ Protection), each look minting new ones, the key unchanged;
        // byte-pinned to the VX-307 plan's U2c words block (PROVISIONAL P-VX307-U2c-5).
        "Write down your twelve words. Every library has twelve words from the moment "
        + "it is made, and they open it for as long as they are its words. Variorum never "
        + "keeps them, so it shows them only when you ask \u{2014} from the card above the "
        + "quick entry, at the end of the tour, or any time in Settings \u{25B8} Protection "
        + "\u{2014} and each look makes new ones for you to write down. Your library's key "
        + "doesn't change.",

        "Set a passphrase. A passphrase is a convenience over the words: easier to type, "
        + "and either one can reset the other. Until you set one, Variorum reminds you "
        + "now and then.",

        "The Apple road is a convenience. In Standard, Variorum also keeps quiet roads to "
        + "your key \u{2014} through your iCloud Keychain and this Mac's login \u{2014} so "
        + "most people never type anything, and for most people that simply works "
        + "forever. If it ever stops, your passphrase or your words open the library, and "
        + "nothing was ever at risk. Castle is the one promise that there is no quiet road "
        + "through Apple, ever; it is a choice you can make in Settings.",
    ]
}
